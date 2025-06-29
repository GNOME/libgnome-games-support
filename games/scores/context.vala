/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
 * Copyright © 2015 Michael Catanzaro <mcatanzaro@gnome.org>
 *
 * This file is part of libgnome-games-support.
 *
 * libgnome-games-support is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * libgnome-games-support is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with libgnome-games-support.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Games {
namespace Scores {

public enum Style
{
    POINTS_GREATER_IS_BETTER,
    POINTS_LESS_IS_BETTER,
    TIME_GREATER_IS_BETTER,
    TIME_LESS_IS_BETTER
}

public class Context : Object
{
    public string app_name { get; construct; }
    public string category_type { get; construct; }
    public Gtk.Window? game_window { get; construct; }
    public Style style { get; construct; }
    public string icon_name { get; construct; }

    [Version (deprecated=true, deprecated_since="2.2")]
    public Importer? importer { get; construct; }

    private Category? current_category = null;

    private static Gee.HashDataFunc<Category?> category_hash = (a) => {
        return str_hash (a.key);
    };
    private static Gee.EqualDataFunc<Category?> category_equal = (a,b) => {
        return str_equal (a.key, b.key);
    };
    private Gee.HashMap<Category?, Gee.List<Score>> scores_per_category =
        new Gee.HashMap<Category?, Gee.List<Score>> ((owned) category_hash, (owned) category_equal);

    private string user_score_dir;
    private bool scores_loaded = false;

    /* A function provided by the game that converts the category key to a
     * category. Why do we have this, instead of expecting games to pass in a
     * list of categories? Because some games need to create categories on the
     * fly, like Mines, which allows for custom board sizes. These games do not
     * know in advance which categories may be in use.
     */
    public delegate Category? CategoryRequestFunc (string category_key);
    private CategoryRequestFunc? category_request = null;

    [Version (since="2.2")]
    public signal void dialog_closed ();

    class construct
    {
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
    }

    public Context (string app_name,
                    string category_type,
                    Gtk.Window? game_window,
                    CategoryRequestFunc category_request,
                    Style style)
    {
        this.with_importer_and_icon_name (app_name, category_type, game_window, category_request, style, null, null);
    }

    public Context.with_icon_name (string app_name,
                                   string category_type,
                                   Gtk.Window? game_window,
                                   CategoryRequestFunc category_request,
                                   Style style,
                                   string icon_name)
    {
        this.with_importer_and_icon_name (app_name, category_type, game_window, category_request, style, null, icon_name);
    }

    [Version (deprecated=true, deprecated_since="2.2")]
    public Context.with_importer (string app_name,
                                  string category_type,
                                  Gtk.Window? game_window,
                                  CategoryRequestFunc category_request,
                                  Style style,
                                  Importer? importer)
    {
        this.with_importer_and_icon_name (app_name, category_type, game_window, category_request, style, importer, null);
    }

    [Version (deprecated=true, deprecated_since="2.2")]
    public Context.with_importer_and_icon_name (string app_name,
                                                string category_type,
                                                Gtk.Window? game_window,
                                                CategoryRequestFunc category_request,
                                                Style style,
                                                Importer? importer = null,
                                                string? icon_name = null)
    {
        Object (app_name: app_name,
                category_type: category_type,
                game_window: game_window,
                style: style,
                importer: importer,
                icon_name: icon_name ?? app_name);

        /* Note: the following functionality can be performed manually by
         * calling Context.load_scores, to ensure Context is usable even if
         * constructed with g_object_new.
         */
        this.category_request = (key) => { return category_request (key); };
        try
        {
            load_scores_from_files ();
        }
        catch (Error e)
        {
            warning ("Failed to load scores: %s", e.message);
        }

        /* Unset this manually because it holds a circular ref on Context. */
        this.category_request = null;
    }

    public override void constructed ()
    {
        user_score_dir = Path.build_filename (Environment.get_user_data_dir (), app_name, "scores", null);

        if (importer != null)
            importer.run (this, user_score_dir);
    }

    internal List<Category?> get_categories ()
    {
        var categories = new List<Category?> ();
        var iterator = scores_per_category.map_iterator ();

        while (iterator.next ())
        {
            categories.append (iterator.get_key ());
        }

        return categories;
    }

    /* Primarily used to change name of player and save the changed score to file */
    internal void update_score_name (Score old_score, Category category, string new_name)
    {
        foreach (var score in scores_per_category[category])
        {
            if (Score.equals (score, old_score))
            {
                score.user = new_name;
                return;
            }
        }
        assert_not_reached ();
    }

    /* Get the best n scores from the given category, sorted */
    public Gee.List<Score> get_high_scores (Category category, int n = 10)
    {
        var result = new Gee.ArrayList<Score> ();
        if (!scores_per_category.has_key (category))
            return result;

        if (style == Style.POINTS_GREATER_IS_BETTER || style == Style.TIME_GREATER_IS_BETTER)
        {
            scores_per_category[category].sort ((a,b) => {
                return (int) (b.score > a.score) - (int) (a.score > b.score);
            });
        }
        else
        {
            scores_per_category[category].sort ((a,b) => {
                return (int) (b.score < a.score) - (int) (a.score < b.score);
            });
        }

        for (int i = 0; i < n && i < scores_per_category[category].size; i++)
            result.add (scores_per_category[category][i]);
        return result;
    }

    private bool is_high_score (long score_value, Category category)
    {
        var best_scores = get_high_scores (category);

        /* The given category doesn't yet exist and thus this score would be the first score and hence a high score. */
        if (best_scores == null)
            return true;

        if (best_scores.size < 10)
            return true;

        var lowest = best_scores.@get (9).score;

        if (style == Style.POINTS_LESS_IS_BETTER || style == Style.TIME_LESS_IS_BETTER)
            return score_value < lowest;

        return score_value > lowest;
    }

    private async void save_score_to_file (Score score, Category category, Cancellable? cancellable) throws Error
    {
        if (DirUtils.create_with_parents (user_score_dir, 0766) == -1)
        {
            throw new FileError.FAILED ("Failed to create %s: %s", user_score_dir, strerror (errno));
        }

        var file = File.new_for_path (Path.build_filename (user_score_dir, category.key));
        var stream = file.append_to (FileCreateFlags.NONE);
        var line = @"$(score.score) $(score.time) $(score.user)\n";

        yield stream.write_all_async (line.data, Priority.DEFAULT, cancellable, null);
    }

    private async bool add_score_internal (Score score, Category category, Cancellable? cancellable) throws Error
    {
        /* Check if category exists in the HashTable. Insert one if not. */
        if (!scores_per_category.has_key (category))
            scores_per_category.set (category, new Gee.ArrayList<Score> ());

        if (scores_per_category[category].add (score))
            current_category = category;

        var high_score_added = is_high_score (score.score, category);
        if (high_score_added && game_window != null)
        {
            ulong id = dialog_closed.connect (() => add_score_internal.callback ());
            do_present_dialog (score);
            yield;
            disconnect (id);
        }

        yield save_score_to_file (score, category, cancellable);
        return high_score_added;
    }

    /* Returns true if a dialog was launched on attaining high score. */
    public async bool add_score (long score, Category category, Cancellable? cancellable) throws Error
    {
        return yield add_score_internal (new Score (score), category, cancellable);
    }

    internal bool add_score_sync (Score score, Category category) throws Error
        requires (game_window == null)
    {
        var main_context = new MainContext ();
        var main_loop = new MainLoop (main_context);
        var ret = false;
        Error error = null;

        main_context.push_thread_default ();
        add_score_internal.begin (score, category, null, (object, result) => {
            try
            {
                ret = add_score_internal.end (result);
            }
            catch (Error e)
            {
                error = e;
            }
            main_loop.quit ();
        });
        main_loop.run ();
        main_context.pop_thread_default ();

        if (error != null)
            throw error;
        return ret;
    }

    private void load_scores_from_file (FileInfo file_info) throws Error
    {
        var category_key = file_info.get_name ();
        var category = category_request (category_key);
        if (category == null)
            return;

        var filename = Path.build_filename (user_score_dir, category_key);
        var scores_of_single_category = new Gee.ArrayList<Score> ();
        var stream = FileStream.open (filename, "r");
        string line;
        while ((line = stream.read_line ()) != null)
        {
            var tokens = line.split (" ", 3);
            string? user = null;

            if (tokens.length < 2)
            {
                warning ("Failed to read malformed score %s in %s.", line, filename);
                continue;
            }

            var score_value = long.parse (tokens[0]);
            var time = int64.parse (tokens[1]);

            if (score_value == 0 && tokens[0] != "0" ||
                time == 0 && tokens[1] != "0")
            {
                warning ("Failed to read malformed score %s in %s.", line, filename);
                continue;
            }

            if (tokens.length == 3)
                user = tokens[2];
            else
                debug ("Assuming current username for old score %s in %s.", line, filename);

            scores_of_single_category.add (new Score (score_value, time, user));
        }

        scores_per_category.set (category, scores_of_single_category);
    }

    private void load_scores_from_files () throws Error
        requires (!scores_loaded)
    {
        scores_loaded = true;

        if (game_window != null && game_window.visible)
        {
            error ("The application window associated with the GamesScoresContext " +
                   "was set visible before loading scores. The Context performs " +
                   "synchronous I/O in the default main context to load scores, so " +
                   "so you should do this before showing your main window.");
        }

        var directory = File.new_for_path (user_score_dir);
        if (!directory.query_exists ())
            return;

        var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
        FileInfo file_info;
        while ((file_info = enumerator.next_file ()) != null)
        {
            load_scores_from_file (file_info);
        }
    }

    /* Must be called *immediately* after construction, if constructed using
     * g_object_new. */
    public void load_scores (CategoryRequestFunc category_request) throws Error
        requires (this.category_request == null)
    {
        this.category_request = (key) => { return category_request (key); };
        load_scores_from_files ();

        /* Unset this manually because it holds a circular ref on Context. */
        this.category_request = null;
    }

    /* This code violates the essential rule:
     *
     *   Never iterate a context created outside the library, including the
     *   global-default or thread-default contexts. Otherwise, sources created
     *   in the application may be dispatched when the application is not
     *   expecting it, causing re-entrancy problems for the application code.
     *
     * This is why gtk_dialog_run() was removed.
     */
    [Version (deprecated=true, deprecated_since="2.2")]
    public void run_dialog ()
        requires (game_window != null)
    {
        var main_loop = new MainLoop (null);
        var dialog = new Dialog (this, category_type, style, null, current_category, game_window, icon_name);
        dialog.closed.connect (() => main_loop.quit ());
        dialog.present (game_window);
        main_loop.run ();
    }

    private void do_present_dialog (Score? new_high_score = null)
        requires (game_window != null)
    {
        var dialog = new Dialog (this, category_type, style, new_high_score, current_category, game_window, icon_name);
        dialog.closed.connect (() => dialog_closed ());
        dialog.present (game_window);
    }

    [Version (since="2.2")]
    public void present_dialog ()
        requires (game_window != null)
    {
        do_present_dialog ();
    }

    public bool has_scores ()
    {
        foreach (var scores in scores_per_category.values)
        {
            if (scores.size > 0)
                return true;
        }
        return false;
    }
}

} /* namespace Scores */
} /* namespace Games */

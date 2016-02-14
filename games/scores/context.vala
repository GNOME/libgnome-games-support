/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
 * Copyright © 2015 Michael Catanzaro <mcatanzaro@gnome.org>
 *
 * This file is part of libgames-support.
 *
 * libgames-support is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * libgames-support is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with libgames-support.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Games {
namespace Scores {

public enum Style
{
    PLAIN_DESCENDING,
    PLAIN_ASCENDING,
    TIME_DESCENDING,
    TIME_ASCENDING
}

public class Context : Object
{
    /* All these variables are needed by dialog and as parameters to Dialog constructor. */
    private Category? current_category = null;
    private Style style;
    private string category_type;
    private Gtk.Window? game_window;
    private string app_name;

    /* A priority queue enables us to easily fetch the top 10 scores */
    private Gee.HashMap<Category?, Gee.PriorityQueue<Score> > scores_per_category = new Gee.HashMap<Category?, Gee.PriorityQueue<Score> > ((owned) category_hash, (owned) category_equal);

    private string user_score_dir;

    /* Comparison and hash functions for Map and Priority Queue.*/
    private CompareDataFunc<Score?> scorecmp;
    private static Gee.HashDataFunc<Category?> category_hash = (a) => {
        return str_hash (a.key);
    };

    private static Gee.EqualDataFunc<Category?> category_equal = (a,b) => {
        return str_equal (a.key, b.key);
    };

    /* A function provided by the game that converts the category key to a
     * category. Why do we have this, instead of expecting games to pass in a
     * list of categories? Because some games need to create categories on the
     * fly, like Mines, which allows for custom board sizes. These games do not
     * know in advance which categories may be in use.
     */
    public delegate Category? CategoryRequestFunc (string category_key);
    private CategoryRequestFunc category_request;

    private Importer? importer;

    public Context (string app_name,
                    string category_type,
                    Gtk.Window? game_window,
                    CategoryRequestFunc category_request,
                    Style style)
    {
        this.with_importer (app_name, category_type, game_window, category_request, style, null);
    }

    public Context.with_importer (string app_name,
                                  string category_type,
                                  Gtk.Window? game_window,
                                  CategoryRequestFunc category_request,
                                  Style style,
                                  Importer? importer)
    {
        this.app_name = app_name;
        this.category_type = category_type;
        this.game_window = game_window;
        this.category_request = (key) => { return category_request (key); };
        this.style = style;
        this.importer = importer;

        if (style == Style.PLAIN_DESCENDING || style == Style.TIME_DESCENDING)
        {
            scorecmp = (a,b) => {
                return (int) (b.score > a.score) - (int) (a.score > b.score);
            };
        }
        else
        {
            scorecmp = (a,b) => {
                return (int) (b.score < a.score) - (int) (a.score < b.score);
            };
        }

        user_score_dir = Path.build_filename (Environment.get_user_data_dir (), app_name, "scores", null);

        try
        {
            if (importer != null)
                importer.run (user_score_dir);
        }
        catch (Error e)
        {
            warning ("Score importer failed: %s", e.message);
        }

        try
        {
            load_scores_from_files ();
        }
        catch (Error e)
        {
            warning ("%s", e.message);
        }
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
        var list_scores = new List<Score> ();
        var scores_of_this_category = scores_per_category[category];
        Score? score = null;

        while (scores_of_this_category.size > 0)
        {
            score = scores_of_this_category.poll ();

            if (Score.equals (score, old_score))
            {
                score.user = new_name;
                list_scores.append (score);
                break;
            }
            else
                list_scores.append (score);
        }

        list_scores.foreach ((x) => scores_of_this_category.add (x));
    }

    /* Get a maximum of best n scores from the given category */
    public Gee.List<Score> get_high_scores (Category category, int n = 10)
    {
        var result = new Gee.ArrayList<Score> ();
        if (!scores_per_category.has_key (category))
            return result;

        /* Remove the first n elements and then add them back. Seems insane, but
         * it's necessary because the PriorityQueue iterators are unordered. */
        for (int i = 0; i < n && scores_per_category[category].size > 0; i++)
            result.add (scores_per_category[category].poll ());
        foreach (var score in result)
            scores_per_category[category].add (score);

        return result;
    }

    /* Return true if a dialog was launched on attaining high score */
    public async bool add_score (long score_value, Category category, Cancellable? cancellable = null) throws Error
    {
        var high_score_added = false;
       /* We need to check for game_window to be not null because thats a way to identify if add_score is being called by the test file.
          If it's being called by test file, then the dialog wouldn't be run and hence player name wouldn't be updated. So, in that case,
          we wish to save scores to file right now itself rather than waiting for a call to update_score. */
        if (is_high_score (score_value, category) && game_window != null)
            high_score_added = true;

        var current_time = new DateTime.now_local ().to_unix ();
        var score = new Score (score_value, current_time, Environment.get_real_name ());

        /* check if category exists in the HashTable. Insert one if not */
        if (!scores_per_category.has_key (category))
            scores_per_category.set (category, new Gee.PriorityQueue<Score> ((owned) scorecmp));

        if (scores_per_category[category].add (score))
            current_category = category;

        /* Note that the score's player name can change while the dialog is running. */
        if (high_score_added)
            run_dialog_internal (score);

        yield save_score_to_file (score, current_category, cancellable);
        return high_score_added;
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

    private void load_scores_from_file (FileInfo file_info) throws Error
    {
        var category_key = file_info.get_name ();
        var category = category_request (category_key);
        if (category == null)
            return;

        var filename = Path.build_filename (user_score_dir, category_key);
        var scores_of_single_category = new Gee.PriorityQueue<Score> ((owned) scorecmp);
        var stream = FileStream.open (filename, "r");
        string line;

        while ((line = stream.read_line ()) != null)
        {
            var tokens = line.split (" ", 3);
            string? user = null;

            if (tokens.length < 2)
            {
                throw new FileError.FAILED ("Failed to parse %s for scores.", filename);
            }

            if (tokens.length < 3)
            {
                user = Environment.get_real_name ();
                debug ("Treating user as %s for old score in %s.", user, filename);
            }

            var score_value = long.parse (tokens[0]);
            var time = int64.parse (tokens[1]);

            if (user == null)
                user = tokens[2];

            scores_of_single_category.add (new Score (score_value, time, user));
        }

        scores_per_category.set (category, scores_of_single_category);
    }

    private void load_scores_from_files () throws Error
    {
        if (game_window != null && game_window.visible)
        {
            error ("The application window associated with the GamesScoresContext " +
                   "was set visible before the Context was constructed. The Context " +
                   "performs synchronous I/O in the default main context to load " +
                   "scores when it is constructed, so you should create the Context " +
                   "before showing your main window.");
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

    private bool is_high_score (long score_value, Category category)
    {
        var best_scores = get_high_scores (category);

        /* The given category doesn't yet exist and thus this score would be the first score and hence a high score. */
        if (best_scores == null)
            return true;

        if (best_scores.size < 10)
            return true;

        var lowest = best_scores.@get (9).score;

        if (style == Style.PLAIN_ASCENDING || style == Style.TIME_ASCENDING)
            return score_value < lowest;

        return score_value > lowest;
    }

    internal void run_dialog_internal (Score? new_high_score)
        requires (game_window != null)
    {
        var dialog = new Dialog (this, category_type, style, new_high_score, current_category, game_window, app_name);
        dialog.run ();
        dialog.destroy ();
    }

    public void run_dialog ()
    {
        run_dialog_internal (null);
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

/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
 *
 * This file is part of libgames-scores.
 *
 * libgames-scores is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * libgames-scores is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with libgames-scores.  If not, see <http://www.gnu.org/licenses/>.
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
    private string dialog_label;
    private Gtk.Window? game_window;

    /* A priority queue enables us to easily fetch the top 10 scores */
    private Gee.HashMap<Category?, Gee.PriorityQueue<Score> > scores_per_category = new Gee.HashMap<Category?, Gee.PriorityQueue<Score> > ((owned) category_hash, (owned) category_equal);

    private string user_score_dir;

    /*Comparison and hash functions for Map and Priority Queue.*/
    private CompareDataFunc<Score?> scorecmp;
    private static Gee.HashDataFunc<Category?> category_hash = (a) => {
        return str_hash (a.name);
    };

    private static Gee.EqualDataFunc<Category?> category_equal = (a,b) => {
        return str_equal (a.name, b.name);
    };

    /* A signal that asks the game to provide the Category given the category key. This is mainly used to fetch category names. */
    public signal Category? request_category (string category_key);

    public Context (string app_name, string dialog_label, Gtk.Window? game_window, Style style)
    {
        this.game_window = game_window;
        this.style = style;

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

        var base_name = app_name;
        this.dialog_label = dialog_label;

        user_score_dir = Path.build_filename (Environment.get_user_data_dir (), base_name, null);

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
    internal List<Score>? get_best_n_scores (Category category, int n)
    {
        if (!scores_per_category.has_key (category))
        {
            return null;
        }

        var n_scores = new List<Score> ();
        var scores_of_this_category = scores_per_category[category];

        for (int i = 0; i < n; i++)
        {
            if (scores_of_this_category.size == 0)
                break;
            n_scores.append (scores_of_this_category.poll ());
        }

        n_scores.foreach ((x) => scores_of_this_category.add (x));
        return n_scores;
    }

    /* Return true if a dialog was launched on attaining high score */
    public bool add_score (long score_value, Category category) throws Error
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

        /* Don't save the score to file yet if it's a high score. Since the Player name be changed on running dialog. */
        if (!high_score_added)
        {
            save_score_to_file (score, category);
            return false;
        }
        else
        {
            run_dialog_internal (score);
            return true;
        }
    }

    private void save_score_to_file (Score score, Category category) throws Error
    {
        if (!FileUtils.test (user_score_dir, FileTest.EXISTS))
        {
            if (DirUtils.create_with_parents (user_score_dir, 0766) == -1)
            {
                throw new FileError.FAILED ("Error: Could not create directory.");
            }
        }

        var file = File.new_for_path (Path.build_filename (user_score_dir, category.key));

        var dos = new DataOutputStream (file.append_to (FileCreateFlags.NONE));

        dos.put_string (score.score.to_string () + " " +
                        score.time.to_string () + " " +
                        score.user + "\n");
    }

    private void load_scores_from_files () throws Error
    {
        if (game_window != null && game_window.visible)
        {
            warning ("The application window associated with the GamesScoresContext " +
                     "was set visible before the Context was constructed. The Context " +
                     "performs synchronous I/O to load scores when it is constructed, " +
                     "so you should create the Context before showing your main window.");
        }

        var directory = File.new_for_path (user_score_dir);

        if (!directory.query_exists ())
            return;

        var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
        FileInfo file_info;

        while ((file_info = enumerator.next_file ()) != null)
        {
            var category_key = file_info.get_name ();
            var category = request_category (category_key);

            if (category == null)
                continue;

            var filename = Path.build_filename (user_score_dir, category_key);
            var scores_of_single_category = new Gee.PriorityQueue<Score> ((owned) scorecmp);
            var file = File.new_for_path (filename);

            /* Open file for reading and wrap returned FileInputStream into a
             DataInputStream, so we can read line by line */
            var dis = new DataInputStream (file.read ());
            string line;

            /* Read lines until end of file (null) is reached */
            while ((line = dis.read_line (null)) != null)
            {
                var tokens = line.split (" ", 3);
                string? user = null;

                if (tokens.length < 2)
                {
                    throw new FileError.FAILED ("Failed to parse %s for scores.", filename);
                }

                if (tokens.length < 3)
                {
                    debug ("Importing old score from %s.", filename);
                    user = Environment.get_real_name ();
                }

                var score_value = long.parse (tokens[0]);
                var time = int64.parse (tokens[1]);

                if (user == null)
                    user = tokens[2];

                scores_of_single_category.add (new Score (score_value, time, user));
            }

            scores_per_category.set (category, scores_of_single_category);
        }
    }

    private bool is_high_score (long score_value, Category category)
    {
        var best_scores = get_best_n_scores (category, 10);

        /* The given category doesn't yet exist and thus this score would be the first score and hence a high score. */
        if (best_scores == null)
            return true;

        if (best_scores.length () < 10)
            return true;

        var lowest = best_scores.nth_data (9).score;

        if (style == Style.PLAIN_ASCENDING || style == Style.TIME_ASCENDING)
            return score_value < lowest;

        return score_value > lowest;
    }

    internal void run_dialog_internal (Score? new_high_score) throws Error
        requires (game_window != null)
    {
        var dialog = new Dialog (this, dialog_label, style, new_high_score, current_category, game_window);
        dialog.run ();
        dialog.destroy ();

        if (new_high_score != null)
            save_score_to_file (new_high_score, current_category);
    }

    public void run_dialog () throws Error
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

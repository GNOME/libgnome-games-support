/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
 *
 * This file is part of libgames-scores.
 *
 * libgames-scores is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * libgames-scores is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with libgames-scores.  If not, see <http://www.gnu.org/licenses/>.
 */
namespace Games
{
namespace Scores
{

public enum Style
{
    PLAIN_DESCENDING,
    PLAIN_ASCENDING,
    TIME_DESCENDING,
    TIME_ASCENDING
}

public struct Category
{
    string key;
    string name;
}

public class Context : Object
{
    private Score? last_score = null;
    private Category? current_category = null;
    private Style style;
    /* A priority queue should enable us to easily fetch the top 10 scores */
    private Gee.HashMap <Category?, Gee.PriorityQueue<Score> > scores_per_category = new Gee.HashMap <Category?, Gee.PriorityQueue<Score>> ((owned) category_hash, (owned) category_equal);
    private string base_name;
    private string user_score_dir;

    private CompareDataFunc<Score?> scorecmp;
    private static Gee.HashDataFunc<Category?> category_hash = (a) =>
    {
        return str_hash (a.name);
    };
    private static Gee.EqualDataFunc<Category?> category_equal = (a,b) =>
    {
        return str_equal (a.name, b.name);
    };

    public Context (string app_name, Style style = Style.PLAIN_DESCENDING)
    {
        this.style = style;
        if (style == Style.PLAIN_DESCENDING || style == Style.TIME_DESCENDING)
        {
            scorecmp = (a,b) =>
            {
                return (int) (b.score > a.score) - (int) (a.score > b.score);
            };
        }
        else
        {
            scorecmp = (a,b) =>
            {
                return (int) (b.score < a.score) - (int) (a.score < b.score);
            };
        }
        this.base_name = app_name;
        this.user_score_dir = Path.build_filename (Environment.get_user_data_dir (), this.base_name, "scores", null);
        try
        {
            this.load_scores_from_files ();
        }
        catch (Error e)
        {
            stderr.printf ("%s\n", e.message);
        }
    }

    /* this assumes that we intend to store ALL scores per category and not just the top 10. */
    public bool add_score (long score_value, Category category)
    {
        string user = Environment.get_user_name ();
        var current_time = new DateTime.now_local ().to_unix ();
        //TODO: Find a way around lossy conversion when long is 32 bit
        int64 time = current_time;
        Score score = new Score ();
        score.score = score_value;
        score.user = user;
        score.time = time;
        /* check if category exists in the HashTable. Insert one if not */
        if (this.scores_per_category.has_key (category) ==  false)
        {
            // TODO: check if insert was successful. Glib.HashMap.set returns void
            this.scores_per_category.set (category, new Gee.PriorityQueue<Score> ((owned) scorecmp));
        }
        try
        {
            /* We first try and save the score to disc. If it succeeds, then we add the score to in-memory HashMap.
               Even if adding score to in-memory HashMap fails, the score would be retrieved the next
               time scores are loaded from the disc. */
            save_score_to_file (score, category);
            if (scores_per_category[category].add (score))
            {
                last_score = score;
                current_category = category;
            }
            return true;

        }
        catch (Error e)
        {
            stderr.printf ("%s\n", e.message);
            return false;
        }
    }

    /* for debugging purposes */
    public void print_scores ()
    {
        var iterator = scores_per_category.map_iterator ();
        while (iterator.next ())
        {
            stdout.printf("Key:%s\n", iterator.get_key ().name);
            var queue_iterator = iterator.get_value ().iterator ();
            while (queue_iterator.next ())
            {
                var time = new DateTime.from_unix_local (queue_iterator.get ().time);
                stdout.printf("%ld\t%s\t%s\n",queue_iterator.get ().score, queue_iterator.get ().user, time.to_string());
            }
        }
    }

    private void save_score_to_file (Score score, Category category) throws Error
    {
        /*create the directory if it doesn' exist*/
        if (!FileUtils.test (this.user_score_dir,FileTest.EXISTS))
        {
            if (DirUtils.create_with_parents (this.user_score_dir, 0766) == -1)
            {
                throw new FileError.ACCES ("Error: Could not create directory.");
            }
        }

        string filename = Path.build_filename (this.user_score_dir, category.key);

        var file = File.new_for_path (filename);

        try
        {
            var dos = new DataOutputStream (file.append_to (FileCreateFlags.NONE));

            string time_string = score.time.to_string ();

            dos.put_string (score.score.to_string () + " " +
                            time_string + " " +
                            score.user + "\n");
        }
        catch (Error e)
        {
            throw e;
        }
    }

    private void load_scores_from_files () throws Error
    {
        var directory = File.new_for_path (this.user_score_dir);

        // return false if directory doesn't exist
        if (!directory.query_exists ())
        {
            throw new FileError.ACCES ("Directory doesn't exist to load scores from.");
        }

        try
        {
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null)
            {
                string category_key = file_info.get_name ();
                string filename = Path.build_filename (this.user_score_dir, category_key);

                var scores_of_single_category = new Gee.PriorityQueue<Score> ((owned) scorecmp);

                var file = File.new_for_path (filename);

                /* Open file for reading and wrap returned FileInputStream into a
                 DataInputStream, so we can read line by line */
                var dis = new DataInputStream (file.read ());
                string line;
                /* Read lines until end of file (null) is reached */
                while ((line = dis.read_line (null)) != null)
                {
                    //TODO: better error handling here?
                    string[] tokens = line.split (" ", 3);
                    if (tokens.length < 3)
                    {
                        throw new FileError.ACCES ("Failed to parse file for scores.");
                    }
                    long score_value = long.parse (tokens[0]);
                    int64 time = int64.parse (tokens[1]);
                    string user = tokens[2];
                    Score score = new Score ();
                    score.score = score_value;
                    score.user = user;
                    score.time = time;
                    scores_of_single_category.add (score);
                }
                //TODO: How to retrieve name of category?
                Category category = {category_key, category_key};
                this.scores_per_category.set (category, scores_of_single_category);
            }
        }
        catch (Error e)
        {
            throw e;
        }
    }

    /* Get a maximum of best n scores from the given category */
    private List<Score> get_best_n_scores (Category category, int n) throws Error
    {
        if (!this.scores_per_category.has_key (category))
        {
            //TODO: Throw appropriate error
        }

        List<Score> n_scores = new List<Score> ();
        var scores_of_this_category = this.scores_per_category[category];

        for (int i = 0; i < n; i++)
        {
            if (scores_of_this_category.size == 0)
            {
                break;
            }
            n_scores.append (scores_of_this_category.poll ());
        }

        /* insert the scores back into the priority queue*/
        n_scores.foreach ((x) =>
                             {
                                 scores_of_this_category.add (x);
                             }
                         );
        return n_scores;

    }
    /* public void run_dialog ()
     {
     new Dialog (this).run ();
     }*/
}

} /* namespace Scores */
} /* namespace Games */

/*TODO: Discuss following issues
 Retreive category name and category key from file names (sol: another file that stores the mapping)
 */

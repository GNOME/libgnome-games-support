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

struct Score
{
    public long score;
    public string user;
    public time_t time;
}

public class Scores : Object
{
    private Score? last_score = null;
    private Category? current_category = null;
    private Style style;
    /* A priority queue should enable us to easily fetch the top 10 scores */
    private Gee.HashMap <Category?, Gee.PriorityQueue<Score?> > scores_per_category = new Gee.HashMap <Category?, Gee.PriorityQueue<Score?>> (category_hash, category_equal);
    private string base_name;

    public CompareDataFunc<Score?> scorecmp;
    public static Gee.HashDataFunc<Category?> category_hash = (a) =>
    {
        return str_hash (a.name);
    };
    public static Gee.EqualDataFunc<Category?> category_equal = (a,b) =>
    {
        return str_equal (a.name, b.name);
    };

    public Scores (string app_name, Style style = Style.PLAIN_DESCENDING)
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
    }

    public Scores.load_existing_scores (string category = "")
    {
        // Load existing scores, if they exist.
        // else, create new Scores
        // check if default category exists, otherwise include a new entry into the hashtable with category as default_category
    }

    /* this assumes that we intend to store ALL scores per category and not just the top 10. */
    public bool add_score (long score_value, Category category)
    {
        // TODO: Get user name from machine
        string user = Environment.get_user_name();
        // TODO: Get current time
        var current_time = new DateTime.now_local ();
        //TODO: Find a way to get current_time in time_t
        time_t time = 1234;
        Score score = { score_value, user, time };
        /* check if category exists in the HashTable. Insert one if not */
        if (this.scores_per_category.has_key(category) ==  false)
        {
            // TODO: check if insert was successful. Glib.HashTable.insert returns void
            this.scores_per_category.set(category, new Gee.PriorityQueue<Score?>(scorecmp));
        }
        if (scores_per_category[category].add(score))
        {
            last_score = score;
            current_category = category;
            return true;
        }
        return false;
    }

    /* for debugging purposes */
    public void print_scores ()
    {
        /*this.scores_per_category.foreach((key,list) =>
          {	list.foreach((val) =>
          {
          stdout.printf("%s:\t%l",key,val.score);
          } );
          } );*/
        /*HashTableIter<string, Gee.PriorityQueue<Score?>> iter = HashTableIter<string, Gee.PriorityQueue<Score?>>(this.scores_per_category);
          stdout.printf("%u\n",this.scores_per_category.size());
          string key;
          unowned Gee.PriorityQueue<Score?> val;
          while(iter.next(out key, out val))
          {
          stdout.printf("%s:\t",key);
          stdout.printf("Count:%u\n",scores_per_category[key].size);
          var iterator = scores_per_category[key].iterator();
          while(iterator.next())
          {
          stdout.printf("%ld\n",iterator.get().score);
          }*/
        /*	stdout.printf("%ld\n",val.poll().score);
                stdout.printf("%ld\n",val.poll().score);
                stdout.printf("%ld\n",val.poll().score);
                stdout.printf("%ld\n",val.poll().score);*/
        //}
        var iterator = scores_per_category.map_iterator();
        while (iterator.next())
        {
            stdout.printf("Key:%s\n",iterator.get_key().name);
            var queue_iterator = iterator.get_value().iterator();
            while(queue_iterator.next())
            {
                stdout.printf("%ld\n",queue_iterator.get().score);
            }
        }
    }

    public void save_scores_to_file ()
    {
        string home_dir = Environment.get_home_dir();
        string user_score_dir = Path.build_filename (home_dir,this.base_name + "_scores",null);

        stdout.printf("%s\n",user_score_dir);
        /*create the directory if it doesn' exist*/
        if (!FileUtils.test(user_score_dir,FileTest.EXISTS))
        {
            stdout.printf("created dir\n");
            DirUtils.create_with_parents (user_score_dir, 0766);
        }

        var category_iterator = scores_per_category.map_iterator();
        while (category_iterator.next())
        {
            string filename = Path.build_filename (user_score_dir, category_iterator.get_key().name);

            var file = File.new_for_path (filename);

            /* if the file already exists, delete it since we wish to overwrite the contents.*/
            if (file.query_exists ())
            {
                file.delete ();
            }

            var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));

            var score_iterator = category_iterator.get_value().iterator();

            while (score_iterator.next())
            {
                Score single_score = score_iterator.get();

                string s = "%ld".printf(single_score.time);

                dos.put_string (single_score.score.to_string() + " " +
                                s + " " +
                                single_score.user + "\n");
            }

        }

    }

    public bool load_scores_from_files ()
    {
        string home_dir = Environment.get_home_dir();
        string user_score_dir = Path.build_filename (home_dir,this.base_name + "_scores",null);

        var directory = File.new_for_path (user_score_dir);

        // return false if directory doesn't exist
        if (!directory.query_exists())
        {
            return false;
        }

        var enumerator = directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);

        FileInfo file_info;
        while ((file_info = enumerator.next_file ()) != null)
        {
            string category_name = file_info.get_name();
            string filename = Path.build_filename (user_score_dir, category_name);

            var scores_of_single_category = new Gee.PriorityQueue<Score?>(scorecmp);

            stdout.printf ("%s\n", filename);
            var file = File.new_for_path (filename);

            // Open file for reading and wrap returned FileInputStream into a
            // DataInputStream, so we can read line by line
            var dis = new DataInputStream (file.read ());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = dis.read_line (null)) != null)
            {
                //TODO: error handling here
                string[] tokens = line.split (" ", 3);
                long score_value = long.parse(tokens[0]);
                time_t time = long.parse(tokens[1]);
                string user = tokens[2];
                Score score = {score_value, user, time};
                scores_of_single_category.add(score);
            }
            //TODO: How to retrieve key of category?
            Category category = {category_name, category_name};
            this.scores_per_category.set(category, scores_of_single_category);
        }

        return true;
    }

    /*  public Scores (string app_name, Style style)
        {
        }

        public void add_score (int score, Category category) throws Error
        {
        }

        public void run_dialog ()
        {
        new Dialog (this).run ();
        }*/
}

void main()
{
    Scores s = new Scores("app");
    s.load_scores_from_files();
    s.print_scores();
    Scores a = new Scores ("second_app");
    a.load_scores_from_files();
    a.print_scores();
    /*time_t t = time_t();
    Category cat = {"cat1", "cat1"};
    s.add_score (22, cat);
    s.add_score (23, cat);
    cat = {"cat2", "cat2"};
    s.add_score (21, cat);
    s.add_score (24, cat);
    s.print_scores();
    s.save_scores_to_file();
    s.load_scores_from_files();
    Scores a = new Scores("second_app",Style.PLAIN_ASCENDING);
    a.add_score (20, cat);
    a.add_score (23, cat);
    cat = {"cat3","cat3"};
    a.add_score (21, cat);
    a.add_score (24, cat);
    a.print_scores();
    a.save_scores_to_file();
    a.load_scores_from_files();*/
}

} /* namespace Scores */
} /* namespace Games */

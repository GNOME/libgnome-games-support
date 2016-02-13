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

private Category category_request (string category_key)
{
    // TODO: This isn't tested....
    return new Category("test", "test");
}

private void add_score_sync (Context context, int score, Category category) {
    var main_loop = new MainLoop (MainContext.@default (), false);
    context.add_score.begin (score, category, null, (object, result) => {
        try
        {
            (void) context.add_score.end (result);
        }
        catch (Error e)
        {
            assert_not_reached ();
        }
        main_loop.quit ();
    });
    main_loop.run ();
}

private void create_scores ()
{
    Context context = new Context ("libgames-scores-test", "Games Type", null, category_request, Style.PLAIN_DESCENDING);
    Category cat = new Category ("cat1", "cat1");
    add_score_sync (context, 101, cat);
    add_score_sync (context, 102, cat);

    cat.key = "cat2";
    cat.name = "cat2";
    add_score_sync (context, 21, cat);
    add_score_sync (context, 24, cat);
}

private string get_score_directory_name ()
{
    return Path.build_filename (Environment.get_user_data_dir (), "libgames-scores-test", "scores", null);
}

private string get_score_filename_for_category (string category_name)
{
    return Path.build_filename (get_score_directory_name (), category_name);
}

private void delete_scores ()
{
    try
    {
        var directory_name = get_score_directory_name ();
        var directory = File.new_for_path (directory_name);
        var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);

        FileInfo file_info;
        while ((file_info = enumerator.next_file ()) != null)
        {
            var file_name = file_info.get_name ();
            var file = directory.get_child (file_name);
            file.@delete ();
        }

        directory.@delete ();
        var parent_name = Path.build_filename (Environment.get_user_data_dir (), "libgames-scores-test", null);
        var parent_directory = File.new_for_path (parent_name);
        parent_directory.@delete ();
    }
    catch (Error e)
    {
        error (e.message);
    }
}

private void test_scores_files_exist ()
{
    create_scores ();

    var filename = get_score_filename_for_category ("cat1");
    var file = File.new_for_path (filename);
    assert (file.query_exists ());

    filename = get_score_filename_for_category ("cat2");
    file = File.new_for_path (filename);
    assert (file.query_exists ());
}

private void test_save_score_to_file ()
{
    try
    {
        create_scores ();
        var filename = get_score_filename_for_category ("cat1");
        var file = File.new_for_path (filename);
        var dis = new DataInputStream (file.read ());

        string line;
        assert ((line = dis.read_line (null)) != null);

        var tokens = line.split (" ", 3);
        assert (tokens.length == 3);
        assert (tokens[0] == "101");
        assert ((line = dis.read_line (null)) != null);

        tokens = line.split (" ", 3);
        assert (tokens.length == 3);
        assert (tokens[0] == "102");
        assert ((line = dis.read_line (null)) == null);

        filename = get_score_filename_for_category ("cat2");
        file = File.new_for_path (filename);
        dis = new DataInputStream (file.read ());
        assert ((line = dis.read_line (null)) != null);

        tokens = line.split (" ", 3);
        assert (tokens.length == 3);
        assert (tokens[0] == "21");
        assert ((line = dis.read_line (null)) != null);

        tokens = line.split (" ", 3);
        assert (tokens.length == 3);
        assert (tokens[0] == "24");
        assert ((line = dis.read_line (null)) == null);
    }
    catch (Error e)
    {
        error (e.message);
    }
}

public int main (string args[])
{
    Test.init (ref args);
    var test_suite = TestSuite.get_root ();
    test_suite.add (new TestCase ("Scores Files Exist", () => {}, test_scores_files_exist, delete_scores));
    test_suite.add (new TestCase ("Save Score To File", () => {}, test_save_score_to_file, delete_scores));
    return Test.run ();
}

}
}

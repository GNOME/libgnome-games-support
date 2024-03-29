/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
 * Copyright © 2016 Michael Catanzaro <mcatanzaro@gnome.org>
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

private Category? category_request (string category_key)
{
    // TODO: This isn't tested....
    return new Category (category_key, category_key);
}

private void add_score_sync (Context context, int score, Category category) {
    var main_loop = new MainLoop (MainContext.@default (), false);
    context.add_score.begin (score, category, null, (object, result) => {
        try
        {
            context.add_score.end (result);
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
    Context context = new Context ("libgnome-games-support-test", "Games Type", null, category_request, Style.POINTS_GREATER_IS_BETTER);
    Category cat = new Category ("cat1", "cat1");
    add_score_sync (context, 101, cat);
    add_score_sync (context, 102, cat);

    cat.key = "cat2";
    cat.name = "cat2";
    add_score_sync (context, 21, cat);
    add_score_sync (context, 24, cat);
}

private string get_test_directory_name ()
{
    return Path.build_filename (Environment.get_user_data_dir (), "libgnome-games-support-test", null);
}

private string get_score_directory_name ()
{
    return Path.build_filename (get_test_directory_name (), "scores", null);
}

private string get_score_filename_for_category (string category_name)
{
    return Path.build_filename (get_score_directory_name (), category_name);
}

private void delete_scores ()
{
    try
    {
        var directory = File.new_for_path (get_score_directory_name ());
        if (directory.query_exists ())
        {
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
            FileInfo file_info;
            while ((file_info = enumerator.next_file ()) != null)
            {
                var file_name = file_info.get_name ();
                var file = directory.get_child (file_name);
                file.@delete ();
            }
            directory.@delete ();
        }

        var parent_directory = File.new_for_path (get_test_directory_name ());
        if (parent_directory.query_exists ())
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

private void test_import_from_score_directory ()
{
    try
    {
        var expected_score = new Score (42,
                                        new DateTime.now_local ().to_unix (),
                                        Environment.get_real_name ());
        var category = new Category ("new-cat", "");

        var test_directory = File.new_for_path (get_test_directory_name ());
        test_directory.make_directory_with_parents ();

        var old_scores_file = File.new_for_path (Path.build_filename (get_test_directory_name (),
                                                                      "old-cat",
                                                                      null));
        var stream = old_scores_file.append_to (FileCreateFlags.NONE);
        stream.write_all (@"$(expected_score.score) $(expected_score.time)\n".data, null);
        stream.close ();
        assert (old_scores_file.query_exists ());

        var context = new Context.with_importer (
            "libgnome-games-support-test",
            "",
            null,
            (key) => {
                assert (key == "new-cat");
                return category;
            },
            Games.Scores.Style.POINTS_GREATER_IS_BETTER,
            new Games.Scores.DirectoryImporter.with_convert_func ((old_key) => {
                assert (old_key == "old-cat");
                return "new-cat";
            }));
        assert (!old_scores_file.query_exists ());

        var imported_scores = context.get_high_scores (category);
        assert (imported_scores.size == 1);

        var imported_score = imported_scores.first ();
        assert (Score.equals (expected_score, imported_score));
    }
    catch (Error e)
    {
        error (e.message);
    }
}

private void test_import_from_history_file ()
{
    try
    {
        var expected_score = new Score (42,
                                        1455426945,
                                        Environment.get_real_name ());
        var category = new Category ("new-cat", "");

        var test_directory = File.new_for_path (get_test_directory_name ());
        test_directory.make_directory_with_parents ();

        var old_scores_file = File.new_for_path (Path.build_filename (get_test_directory_name (),
                                                                      "history",
                                                                      null));
        var stream = old_scores_file.append_to (FileCreateFlags.NONE);
        stream.write_all ("2016-02-13T23:15:45-0600 old-cat 42\n".data, null);
        stream.close ();
        assert (old_scores_file.query_exists ());

        var context = new Context.with_importer (
            "libgnome-games-support-test",
            "",
            null,
            (key) => {
                assert (key == "new-cat");
                return category;
            },
            Games.Scores.Style.POINTS_GREATER_IS_BETTER,
            new Games.Scores.HistoryFileImporter ((line, out score, out out_category) => {
                assert (line == "2016-02-13T23:15:45-0600 old-cat 42");
                score = new Score (42, HistoryFileImporter.parse_date ("2016-02-13T23:15:45-0600"));
                assert (score.time == 1455426945);
                out_category = category;
            }));
        assert (!old_scores_file.query_exists ());

        var imported_scores = context.get_high_scores (category);
        assert (imported_scores.size == 1);

        var imported_score = imported_scores.first ();
        assert (Score.equals (expected_score, imported_score));
    }
    catch (Error e)
    {
        error (e.message);
    }
}

private void test_import_from_nonexistent_history_file ()
{
    new Context.with_importer (
        "libgnome-games-support-test",
        "",
        null,
        (key) => {
            return null;
        },
        Games.Scores.Style.POINTS_GREATER_IS_BETTER,
        new Games.Scores.HistoryFileImporter ((line, out score, out category) => {
            score = null;
            category = null;
        }));

    /* No error */
}

public int main (string[] args)
{
    /* Start fresh.... */
    delete_scores ();

    Test.init (ref args);
    var test_suite = TestSuite.get_root ();
    test_suite.add (new TestCase ("Scores Files Created", () => {}, test_scores_files_exist, delete_scores));
    test_suite.add (new TestCase ("Save Score to File", () => {}, test_save_score_to_file, delete_scores));
    test_suite.add (new TestCase ("Import from Score Directory", () => {}, test_import_from_score_directory, delete_scores));
    test_suite.add (new TestCase ("Import from History File", () => {}, test_import_from_history_file, delete_scores));
    test_suite.add (new TestCase ("Import from Nonexistent History File", () => {}, test_import_from_nonexistent_history_file, delete_scores));
    return Test.run ();
}

}
}

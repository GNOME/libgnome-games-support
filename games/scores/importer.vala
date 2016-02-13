/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2016 Michael Catanzaro <mcatanzaro@gnome.org>
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

/* Time for a history lesson. Once upon a time, scores were stored under
 * /var/games in a format basically the same as what we use now, split into
 * different files based on category. Games were installed setgid for the games
 * group, allowing scores to be shared between users (fun in a computer lab or
 * shared machine) while preventing cheating, since editing the scores file
 * would require some privilege escalation exploit.
 *
 * When Robert started rewriting games in Vala, he changed the scores format so
 * that all scores for a game would be saved in one file, in the home directory.
 * Placing the file in the home directory has an important advantage in that you
 * do not lose your scores if you copy your home directory to another computer.
 * Of course, this had the one-time cost that scores were lost upon upgrading
 * to the new Vala version of the game, as there was no score importer. It also
 * makes importing a bit tricky, because the columns in the scores file are
 * different for each game.
 *
 * Then, for GNOME 3.12, I (Michael) changed all the remaining C games to store
 * scores in the home directory, without changing the format except for removing
 * the player name column, since it didn't seem relevant if all scores were in
 * the home directory. Again, all users' scores were lost in this transition.
 * Currently, scores use this same format, except the player name column is back
 * because it turns out people share user accounts and want to record scores
 * separately.
 *
 * This importer exists so that we don't delete everyone's scores a second time.
 *
 * Some users have complained that scores are now saved in the home directory.
 * Using /var/games was a clever setup and it's a bit of a shame to see it go;
 * bug #749682 exists to restore that old behavior. It has been suggested that
 * we could hardlink scores files from the home directory to /var/games to get
 * the best of both worlds. I don't see why not, except some distro folks really
 * don't like using the setgid bit. Another possibility would be to make this
 * some configurable option. Few enough people have been complaining that I
 * don't plan to spend more time on this, though.
 */

/* Note that all file I/O here is performed synchronously, because the importer
 * is only used before scores are loaded, and the library ensures scores are
 * always loaded before showing the main window.
 */

/* TODO: Support importing scores from Vala games, bug #745489. */
namespace Importer
{
    /* This scores format is mostly-compatible with the current format, the only
     * differences are (a) the scores file nowadays has a column for the player
     * name, (b) scores nowadays are kept under ~/.local/share/APPNAME/scores
     * whereas they used to be saved one level up, and (c) some category names
     * have changed. All we have to do here is copy the files from the parent
     * directory to the subdirectory, and rename them according to the new
     * category names. Context.load_scores_from_file handles the missing player
     * name column by assuming it matches the current UNIX account if missing.
     * Notice that we are importing only home directory scores, not any scores
     * from /var/games, since it's been several years since scores were removed
     * from there and most players will have lost them by now anyway.
     *
     * TODO: Use this for Five or More, Four-in-a-row, Klotski, Robots, and Tali.
     */
    private static void importOldScoresFromCGame (File new_scores_dir,
                                                  Gee.Map<string, string> category_map) throws GLib.Error
    {
        var original_scores_dir = new_scores_dir.get_parent ();
        if (original_scores_dir == null)
            return;

        foreach (var entry in category_map.entries)
        {
            var original_file = original_scores_dir.get_child (entry.key);
            if (original_file.query_exists ())
            {
                var new_file = new_scores_dir.get_child (entry.value);
                original_file.copy (new_file, FileCopyFlags.NONE);
                original_file.@delete ();
                debug ("Moved scores from %s to %s", original_file.get_path (), new_file.get_path ());
            }
        }
    }

    private static void run (string new_scores_dir) throws GLib.Error
    {
        var new_dir = File.new_for_path (new_scores_dir);
        if (new_dir.query_exists ())
            return;
        new_dir.make_directory ();

        /* TODO: Add API so that the mapping can be done by the games themselves. */
        if (Environment.get_prgname () == "org.gnome.Nibbles")
        {
            var category_map = new Gee.HashMap<string, string> ();
            category_map.@set ("1.0", "beginner");
            category_map.@set ("2.0", "slow");
            category_map.@set ("3.0", "medium");
            category_map.@set ("4.0", "fast");
            category_map.@set ("1.1", "beginner-fakes");
            category_map.@set ("2.1", "slow-fakes");
            category_map.@set ("3.1", "medium-fakes");
            category_map.@set ("4.1", "fast-fakes");
            importOldScoresFromCGame (new_dir, category_map);
        }
    }
} /* namespace Importer */

} /* namespace Scores */
} /* namespace Games */

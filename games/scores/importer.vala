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

public class Importer
{
    public enum OldFormat
    {
        C_GAMES_MULTI_FILE_FORMAT,
        VALA_GAMES_SINGLE_FILE_FORMAT,
    }

    /* A function provided by the game that converts the old category key to a
     * new key. If the keys have not been changed, this function should return
     * the same string. If the key is invalid, it should return null, as this
     * function will be called once for each file in the game's local data
     * directory, and some of those files might not be valid categories.
     *
     * FIXME: Is this only useful for C_GAMES_MULTI_FILE_FORMAT?
     */
    public delegate string? CategoryConvertFunc (string old_key);
    private CategoryConvertFunc category_convert;

    private OldFormat format;

    public Importer (OldFormat format, CategoryConvertFunc category_convert)
    {
        this.format = format;
        this.category_convert = category_convert;
    }

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
     */
    private void importCMultiFileScores (File new_scores_dir) throws GLib.Error
    {
        var original_scores_dir = new_scores_dir.get_parent ();
        assert (original_scores_dir != null);

        var enumerator = original_scores_dir.enumerate_children (FileAttribute.STANDARD_NAME, 0);
        FileInfo file_info;

        while ((file_info = enumerator.next_file ()) != null)
        {
            var new_key = category_convert (file_info.get_name ());
            if (new_key == null)
                continue;

            var new_file = new_scores_dir.get_child (new_key);
            var original_file = original_scores_dir.resolve_relative_path (file_info.get_name ());
            debug ("Moving scores from %s to %s", original_file.get_path (), new_file.get_path ());
            original_file.copy (new_file, FileCopyFlags.NONE);
            original_file.@delete ();
        }
    }

    private void importOldScores (File new_scores_dir) throws GLib.Error
        /* TODO: Support importing scores from Vala games, bug #745489. */
        requires (format == OldFormat.C_GAMES_MULTI_FILE_FORMAT)
    {
        importCMultiFileScores (new_scores_dir);
    }

    internal void run (string new_scores_dir) throws GLib.Error
    {
        var new_dir = File.new_for_path (new_scores_dir);
        if (new_dir.query_exists ())
            return;
        new_dir.make_directory ();

        importOldScores (new_dir);
    }
}

} /* namespace Scores */
} /* namespace Games */

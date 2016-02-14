/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2016 Michael Catanzaro <mcatanzaro@gnome.org>
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

/* Imports scores from a Vala game's history file directory, where each category
 * of scores is saved together in the same file. This is the format used by
 * games that were converted to Vala before switching to libgames-support. This
 * class should probably be used by Klotski, Mines, Swell Foop, Mahjongg,
 * Tetravex, Quadrapassel, and nothing else.
 */
public class HistoryFileImporter : Importer
{
    /* A function provided by the game that converts a line in its history file
     * to a Score and Category we can use.
     */
    public delegate void HistoryConvertFunc (string line, out Score score, out Category category);
    private HistoryConvertFunc history_convert;

    public HistoryFileImporter (HistoryConvertFunc history_convert)
    {
        this.history_convert = (line, out score, out category) => {
            history_convert (line, out score, out category);
        };
    }

    /* Copied from Robert's Vala games. This is useful for games to use when
     * implementing their HistoryConvertFuncs.
     */
    public static DateTime? parse_date (string date)
    {
        if (date.length < 19 || date[4] != '-' || date[7] != '-' || date[10] != 'T' || date[13] != ':' || date[16] != ':')
            return null;

        var year = int.parse (date.substring (0, 4));
        var month = int.parse (date.substring (5, 2));
        var day = int.parse (date.substring (8, 2));
        var hour = int.parse (date.substring (11, 2));
        var minute = int.parse (date.substring (14, 2));
        var seconds = int.parse (date.substring (17, 2));
        var timezone = date.substring (19);

        return new DateTime (new TimeZone (timezone), year, month, day, hour, minute, seconds);
    }

    /* Each game uses a somewhat different format for its scores; one game might
     * use one column to store the category, while another might use two or
     * more. Pass the game one line of the history file at a time, and let the
     * game convert it to a Score and Category for us.
     */
    protected override void importOldScores (Context context, File new_scores_dir) throws GLib.Error
    {
        var history_filename = Path.build_filename (new_scores_dir.get_path (), "..", "history", null);
        debug ("Importing scores from %s", history_filename);

        var stream = FileStream.open (history_filename, "r");
        string line;
        while ((line = stream.read_line ()) != null)
        {
            Score score;
            Category category;
            history_convert (line, out score, out category);
            if (score == null || category == null)
                warning ("Failed to import from %s score line %s", history_filename, line);
            context.add_score_sync (score, category);
        }

        var history_file = File.new_for_path (history_filename);
        history_file.@delete ();
    }
}

} /* namespace Scores */
} /* namespace Games */

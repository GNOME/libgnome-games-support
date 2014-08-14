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

using Gtk;

private class Dialog : Gtk.Dialog
{
    private Context scores;
    private ComboBoxText combo;
    private Category? active_category;
    private Gtk.Grid grid;
    private int rows_to_display = 10;

    public Dialog (Context scores, string dialog_label, Window window)
    {
        Object (use_header_bar : 1);
        this.scores = scores;
        this.transient_for = window;

        var header = (HeaderBar) this.get_header_bar ();
        string header_title = "";
        if (scores.score_style == Style.PLAIN_ASCENDING || scores.score_style == Style.PLAIN_DESCENDING)
            header_title = "High Scores";
        else
            header_title = "Best Times";
        header.title = _(header_title);

        var vbox = this.get_content_area ();
        vbox.set_spacing (20);
        set_border_width (5);

        var catbar = new Box (Orientation.HORIZONTAL, 12);
        vbox.pack_start (catbar, false, false, 0);

        var hdiv = new Separator (Orientation.HORIZONTAL);
        vbox.pack_start (hdiv, false, false, 0);

        var label = new Label (dialog_label);
        label.set_use_markup (true);
        catbar.pack_start (label, false, false, 0);

        combo = new ComboBoxText ();
        combo.set_focus_on_click (false);
        catbar.pack_start (combo, true, true, 0);
        combo.changed.connect (load_scores);

        grid = new Grid ();
        vbox.pack_start (grid, false, false, 0);

        grid.column_homogeneous = true;
        grid.row_homogeneous = true;
        grid.set_column_spacing (10);
        grid.set_row_spacing (10);
        grid.margin_left = 20;
        grid.margin_right = 20;

        var label_column_1 = new Label (_("Rank"));
        label.set_use_markup (true);
        grid.attach (label_column_1, 0, 0, 1, 1);

        string score_or_time = "";
        if (scores.score_style == Style.PLAIN_ASCENDING || scores.score_style == Style.PLAIN_DESCENDING)
            score_or_time = "Score";
        else
            score_or_time = "Time";

        var label_column_2 = new Label (_(score_or_time));
        label.set_use_markup (true);
        grid.attach (label_column_2, 1, 0, 1, 1);

        var label_column_3 = new Label (_("Player"));
        label.set_use_markup (true);
        grid.attach (label_column_3, 2, 0, 3, 1);

        grid.set_baseline_row (0);
        fill_grid_with_labels ();

        load_categories ();

        vbox.show_all ();
    }

    private void fill_grid_with_labels ()
    {
        for (int row = 1; row <= rows_to_display; row++)
        {
            for (int column = 0; column <= 2; column++)
            {
                var label = new Label ("");
                if (column == 2)
                    grid.attach (label, column, row, 3, 1);
                else
                    grid.attach (label, column, row, 1, 1);
            }
        }
    }

    /* load names and keys of all categories in ComboBoxText */
    private void load_categories ()
    {
        var categories = scores.get_categories ();
        categories.foreach ((x) => combo.append (x.key, x.name));
        if (categories.length() > 0)
        {
            if (scores.active_category == null)
                combo.set_active_id (categories.nth_data (0).key);
            else
                combo.set_active_id (scores.active_category.key);
            active_category = {categories.nth_data (0).key, categories.nth_data (0).name};
        }
        else
            active_category = null;
    }

    /* loads the scores of current active_category */
    private void load_scores()
    {
        active_category = { combo.get_active_id (), combo.get_active_text ()};
        var best_n_scores = scores.get_best_n_scores (active_category, rows_to_display);

        int row_count = 1;

        best_n_scores.foreach ((x) =>
        {
            var rank = (Label) grid.get_child_at (0, row_count);
            rank.set_use_markup (true);
            rank.set_text (row_count.to_string ());

            var score = (Label) grid.get_child_at (1, row_count);
            score.set_use_markup (true);
            score.set_text (x.score.to_string ());

            var name = (Label) grid.get_child_at (2, row_count);
            name.set_use_markup (true);
            name.set_text (x.user);

            row_count++;
        });

        if (row_count < rows_to_display + 1)
            make_remaining_labels_empty (row_count);
    }

    /*Fill all labels from row row_count onwards with empty strings*/
    private void make_remaining_labels_empty (int row_count)
    {
        for (int i = row_count; i <= rows_to_display; i++)
        {
            for (int j = 0; j <= 2; j++)
            {
                var label = (Label) grid.get_child_at (j, i);
                label.set_text ("");
            }
        }
    }
}

} /* namespace Scores */
} /* namespace Games */

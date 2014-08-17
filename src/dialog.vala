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
    private ComboBoxText? combo = null;
    private Category? active_category = null;
    private Label? category_label = null;
    private HeaderBar? header = null;
    private Gtk.Grid grid;
    private int rows_to_display = 10;

    public Dialog (Context scores, string dialog_label, Window window)
    {
        Object (use_header_bar : 1);
        this.scores = scores;
        this.transient_for = window;

        header = (HeaderBar) this.get_header_bar ();
        string header_title = "";
        if (scores.high_score_added)
            header_title = "Congratulations!";
        else if (scores.score_style == Style.PLAIN_ASCENDING || scores.score_style == Style.PLAIN_DESCENDING)
            header_title = "High Scores";
        else
            header_title = "Best Times";
        header.title = _(header_title);
        header.subtitle = "";

        var vbox = this.get_content_area ();
        vbox.set_spacing (20);
        set_border_width (10);

        var catbar = new Box (Orientation.HORIZONTAL, 12);
        catbar.margin_top = 10;
        vbox.pack_start (catbar, false, false, 0);

        var hdiv = new Separator (Orientation.HORIZONTAL);
        vbox.pack_start (hdiv, false, false, 0);

        var label = new Label (dialog_label);
        label.set_use_markup (true);
        catbar.pack_start (label, false, false, 0);

        if (scores.high_score_added)
        {
            category_label = new Label (scores.active_category.name);
            category_label.set_use_markup (true);
            category_label.halign = Align.CENTER;
            category_label.valign = Align.CENTER;
            catbar.pack_start (category_label, true, false, 0);
        }
        else
        {
            combo = new ComboBoxText ();
            combo.set_focus_on_click (false);
            catbar.pack_start (combo, true, true, 0);
            combo.changed.connect (load_scores);
        }

        grid = new Grid ();
        vbox.pack_start (grid, false, false, 0);

        grid.column_homogeneous = true;
        grid.row_homogeneous = true;
        grid.set_column_spacing (30);
        grid.set_row_spacing (1);
        grid.margin_left = 20;
        grid.margin_right = 20;

        string string_rank = _("Rank");
        var label_column_1 = new Label ("<span weight='bold'>" + string_rank + "</span>");
        label_column_1.use_markup = true;
        grid.attach (label_column_1, 0, 0, 1, 1);

        string score_or_time = "";
        if (scores.score_style == Style.PLAIN_ASCENDING || scores.score_style == Style.PLAIN_DESCENDING)
            score_or_time = _("Score");
        else
            score_or_time = _("Time");

        var label_column_2 = new Label ("<span weight='bold'>" + score_or_time + "</span>");
        label_column_2.use_markup = true;
        grid.attach (label_column_2, 1, 0, 1, 1);

        string string_player = _("Player");
        var label_column_3 = new Label ("<span weight='bold'>" + string_player + "</span>");
        label_column_3.use_markup = true;
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
                var stack = new Stack ();
                stack.visible = true;
                stack.set_homogeneous (true);
                stack.set_transition_type (StackTransitionType.NONE);

                var label = new Label ("");
                label.visible = true;
                label.halign = Align.CENTER;
                label.valign = Align.CENTER;
                stack.add_named (label, "label");

                var entry = new Entry ();
                entry.visible = true;
                entry.set_size_request (20,20);
                entry.expand = false;
                stack.add_named (entry, "entry");

                stack.set_visible_child_name ("label");

                if (column == 2)
                    grid.attach (stack, column, row, 3, 1);
                else
                    grid.attach (stack, column, row, 1, 1);
            }
        }
    }

    /* load names and keys of all categories in ComboBoxText */
    private void load_categories ()
    {
        if (scores.high_score_added)
            load_scores ();
        if (combo == null)
            return;
        var categories = scores.get_categories ();
        categories.foreach ((x) => combo.append (x.key, x.name));
        if (categories.length() > 0)
        {
            if (scores.active_category == null)
                combo.set_active_id (categories.nth_data (0).key);
            else
                combo.set_active_id (scores.active_category.key);

            if (active_category == null)
                active_category = new Category (categories.nth_data (0).key, categories.nth_data (0).name);
            else
            {
                active_category.key = categories.nth_data (0).key;
                active_category.name = categories.nth_data (0).name;
            }
        }
        else
            active_category = null;
    }

    /* loads the scores of current active_category */
    private void load_scores()
    {
        if (scores.high_score_added)
            active_category = new Category (scores.active_category.key, scores.active_category.name);
        else
            active_category = new Category (combo.get_active_id (), combo.get_active_text ());

        var best_n_scores = scores.get_best_n_scores (active_category, rows_to_display);

        int row_count = 1;

        best_n_scores.foreach ((x) =>
        {
            var rank_stack = (Stack) grid.get_child_at (0, row_count);
            var rank = (Label) rank_stack.get_visible_child ();

            rank.set_use_markup (true);
            rank.set_text (row_count.to_string ());

            var score_stack = (Stack) grid.get_child_at (1, row_count);
            var score = (Label) score_stack.get_visible_child ();
            score.set_use_markup (true);
            score.set_text (x.score.to_string ());

            if (scores.high_score_added
            && x.score == scores.latest_score.score
            && x.time == scores.latest_score.time
            && x.user == scores.latest_score.user)
            {
                string subtitle = "";
                if (best_n_scores.length () > 1 && row_count == 1)
                    subtitle = "Your score is the best!";
                else
                    subtitle = "Your score has made the top ten.";
                header.subtitle = _(subtitle);

                var temp_stack = (Stack) grid.get_child_at (2, row_count);
                temp_stack.set_visible_child_name ("entry");
                var visible = (Entry) temp_stack.get_visible_child ();
                visible.set_text (x.user);
                visible.activate.connect (() =>
                {
                    scores.update_score_name (x, visible.get_text (), active_category);
                    x.user = visible.get_text ();
                    temp_stack.set_visible_child_name ("label");
                    var label = (Label) temp_stack.get_visible_child ();
                    label.set_text (x.user);
                });
                scores.high_score_added = false;
            }

            var name_stack = (Stack) grid.get_child_at (2, row_count);
            var widget =  name_stack.get_visible_child ();
            Label? label = widget as Label;
            if (label != null)
            {
                label.set_use_markup (true);
                label.set_text (x.user);
            }
            else
            {
                var entry = (Entry) widget;
                entry.set_text (x.user);
            }

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
                var stack = (Stack) grid.get_child_at (j,i);
                var label = (Label) stack.get_visible_child ();
                label.set_text ("");
            }
        }
    }
}

} /* namespace Scores */
} /* namespace Games */

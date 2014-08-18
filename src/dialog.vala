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

namespace Games {
namespace Scores {

using Gtk;

private class Dialog : Gtk.Dialog
{
    private Context scores;
    private Category? active_category = null;
    private int rows_to_display = 10;

    private ComboBoxText? combo = null;
    private Label? category_label = null;
    private HeaderBar? header = null;
    private Gtk.Grid grid;

    private Style scores_style;
    private Score? scores_latest_score;
    private Category? scores_active_category;

    public Dialog (Context scores, string dialog_label, Style style, Score? latest_score, Category? current_cat, Window window)
    {
        Object (use_header_bar : 1);

        this.scores = scores;
        this.transient_for = window;
        scores_latest_score = latest_score;
        scores_style = style;
        scores_active_category = current_cat;

        header = (HeaderBar) this.get_header_bar ();

        if (scores.high_score_added)
            header.show_close_button = false;
        else
            header.show_close_button = true;

        string header_title = "";

        if (scores.high_score_added)
            header_title = "Congratulations!";
        else if (scores_style == Style.PLAIN_ASCENDING || scores_style == Style.PLAIN_DESCENDING)
            header_title = "High Scores";
        else
            header_title = "Best Times";

        header.title = _(header_title);
        header.subtitle = "";

        var vbox = this.get_content_area ();
        vbox.spacing = 20;
        border_width = 10;

        var catbar = new Box (Orientation.HORIZONTAL, 12);
        catbar.margin_top = 10;
        catbar.halign = Align.CENTER;
        vbox.pack_start (catbar, true, false, 0);

        var hdiv = new Separator (Orientation.HORIZONTAL);
        vbox.pack_start (hdiv, false, false, 0);

        var label = new Label (dialog_label);
        label.use_markup = true;
        label.halign = Align.CENTER;
        catbar.pack_start (label, false, false, 0);

        if (scores.high_score_added)
        {
            category_label = new Label (scores_active_category.name);
            category_label.use_markup = true;
            category_label.halign = Align.CENTER;
            category_label.valign = Align.CENTER;
            catbar.pack_start (category_label, false, false, 0);
        }
        else
        {
            combo = new ComboBoxText ();
            combo.focus_on_click = false;
            catbar.pack_start (combo, true, true, 0);
            combo.changed.connect (load_scores);
        }

        grid = new Grid ();
        vbox.pack_start (grid, false, false, 0);

        grid.column_homogeneous = true;
        grid.row_homogeneous = true;
        grid.column_spacing = 30;
        grid.row_spacing = 1;
        grid.margin_start = 20;
        grid.margin_end = 20;

        string string_rank = _("Rank");
        var label_column_1 = new Label ("<span weight='bold'>" + string_rank + "</span>");
        label_column_1.use_markup = true;
        grid.attach (label_column_1, 0, 0, 1, 1);

        string score_or_time = "";
        if (scores_style == Style.PLAIN_ASCENDING || scores_style == Style.PLAIN_DESCENDING)
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

        grid.baseline_row = 0;
        fill_grid_with_labels ();

        if (scores.high_score_added)
            add_button ("Done", ResponseType.OK).get_style_context ().add_class ("suggested-action");

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
                stack.homogeneous = true;
                stack.transition_type = StackTransitionType.NONE;

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

                stack.visible_child_name = "label";

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
        /* If we are adding a high score, we don't wish to load all categories. We only wish to load scores of active category. */
        if (scores.high_score_added)
            load_scores ();

        if (combo == null)
            return;

        var categories = scores.get_categories ();
        categories.foreach ((x) => combo.append (x.key, x.name));

        if (categories.length() > 0)
        {
            if (scores_active_category == null)
                combo.active_id = categories.nth_data (0).key;
            else
                combo.active_id = scores_active_category.key;

            if (active_category == null)
            {
                active_category = new Category (categories.nth_data (0).key, categories.nth_data (0).name);
            }
            else
            {
                active_category.key = categories.nth_data (0).key;
                active_category.name = categories.nth_data (0).name;
            }
        }
        else
        {
            active_category = null;
        }
    }

    /* loads the scores of current active_category */
    private void load_scores ()
    {
        if (scores.high_score_added)
            active_category = new Category (scores_active_category.key, scores_active_category.name);
        else
            active_category = new Category (combo.get_active_id (), combo.get_active_text ());

        var best_n_scores = scores.get_best_n_scores (active_category, rows_to_display);
        uint no_scores = best_n_scores.length ();

        int row_count = 1;

        best_n_scores.foreach ((x) =>
        {
            display_single_score (x, row_count, no_scores);
            row_count++;
        });

        if (row_count < rows_to_display + 1)
            make_remaining_labels_empty (row_count);
    }

    /* Use Stack to switch between Entry and Label. All data displayed as labels except when a new high score is being added.
       In which case, Label needs to be replaced by Entry allowing for player to enter name. */
    private void display_single_score (Score x, int row_count, uint no_scores)
    {
        var rank_stack = (Stack) grid.get_child_at (0, row_count);
        var rank = (Label) rank_stack.get_visible_child ();

        rank.use_markup = true;
        rank.set_text (row_count.to_string ());

        var score_stack = (Stack) grid.get_child_at (1, row_count);
        var score = (Label) score_stack.get_visible_child ();
        score.use_markup = true;
        score.set_text (x.score.to_string ());

        if (scores.high_score_added
            && scores_latest_score != null
            && Score.equals (x, scores_latest_score))
        {
            string subtitle = "";

            if (no_scores > 1 && row_count == 1)
                subtitle = "Your score is the best!";
            else
                subtitle = "Your score has made the top ten.";

            header.subtitle = _(subtitle);

            var temp_stack = (Stack) grid.get_child_at (2, row_count);
            temp_stack.visible_child_name = "entry";

            var visible = (Entry) temp_stack.get_visible_child ();
            visible.text = x.user;
            visible.activate.connect (() => {
                                                scores.update_score_name (x, visible.get_text (), active_category);
                                                x.user = visible.get_text ();
                                            });

            scores.high_score_added = false;
        }

        var name_stack = (Stack) grid.get_child_at (2, row_count);
        var widget = name_stack.get_visible_child ();
        Label? label = widget as Label;
        if (label != null)
        {
            label.use_markup = true;
            label.set_text (x.user);
        }
        else
        {
            var entry = (Entry) widget;
            entry.text = x.user;
        }
    }

    /* Fill all labels from row row_count onwards with empty strings. */
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

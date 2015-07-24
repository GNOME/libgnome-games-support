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

private class Dialog : Gtk.Dialog
{
    private Context context;
    private Category? active_category = null;
    private int rows_to_display = 10;

    private Gtk.ComboBoxText? combo = null;
    private Gtk.Label? category_label = null;
    private Gtk.HeaderBar? headerbar = null;
    private Gtk.Grid grid;

    private Style scores_style;
    private Score? new_high_score;
    private Category? scores_active_category;

    public Dialog (Context context, string dialog_label, Style style, Score? new_high_score, Category? current_cat, Gtk.Window window, string app_name)
    {
        Object (use_header_bar : 1);

        resizable = false;

        this.context = context;
        this.transient_for = window;
        this.new_high_score = new_high_score;

        scores_style = style;
        scores_active_category = current_cat;

        headerbar = (Gtk.HeaderBar) this.get_header_bar ();

        headerbar.show_close_button = (new_high_score == null);

        if (new_high_score != null)
        /* Appears at the top of the dialog, as the heading of the dialog */
            headerbar.title = _("Congratulations!");
        else if (scores_style == Style.PLAIN_ASCENDING || scores_style == Style.PLAIN_DESCENDING)
            headerbar.title = _("High Scores");
        else
            headerbar.title = _("Best Times");

        if (!context.has_scores () && new_high_score == null)
        {
            var vbox = this.get_content_area ();
            vbox.spacing = 4;
            vbox.border_width = 10;
            vbox.valign = Gtk.Align.CENTER;
            vbox.get_style_context ().add_class ("dim-label");

            var image = new Gtk.Image ();
            image.icon_name = app_name + "-symbolic";
            image.pixel_size = 64;
            image.opacity = 0.2;
            vbox.pack_start (image, false, false);

            var title_label = new Gtk.Label ("<b><span size=\"large\">" + _("No scores yet") + "</span></b>");
            title_label.use_markup = true;
            vbox.pack_start (title_label, false, false);

            var description_label = new Gtk.Label (_("Play some games and your scores will show up here."));
            vbox.pack_start (description_label, false, false);

            vbox.show_all ();

            width_request = 450;
            height_request = 500;

            return;
        }

        var vbox = this.get_content_area ();
        vbox.spacing = 20;
        border_width = 10;

        var catbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        catbar.margin_top = 10;
        catbar.halign = Gtk.Align.CENTER;
        vbox.pack_start (catbar, true, false, 0);

        var hdiv = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        vbox.pack_start (hdiv, false, false, 0);

        var label = new Gtk.Label (dialog_label);
        label.use_markup = true;
        label.halign = Gtk.Align.CENTER;
        catbar.pack_start (label, false, false, 0);

        if (new_high_score != null)
        {
            category_label = new Gtk.Label (scores_active_category.name);
            category_label.use_markup = true;
            category_label.halign = Gtk.Align.CENTER;
            category_label.valign = Gtk.Align.CENTER;
            catbar.pack_start (category_label, false, false, 0);
        }
        else
        {
            combo = new Gtk.ComboBoxText ();
            combo.focus_on_click = false;
            catbar.pack_start (combo, true, true, 0);
            combo.changed.connect (load_scores);
        }

        grid = new Gtk.Grid ();
        vbox.pack_start (grid, false, false, 0);

        grid.row_homogeneous = true;
        grid.column_spacing = 30;
        grid.margin = 20;
        grid.halign = Gtk.Align.CENTER;

        /* A column heading in the scores dialog */
        string string_rank = _("Rank");
        var label_column_1 = new Gtk.Label ("<span weight='bold'>" + string_rank + "</span>");
        label_column_1.use_markup = true;
        grid.attach (label_column_1, 0, 0, 1, 1);

        string score_or_time = "";

        if (scores_style == Style.PLAIN_ASCENDING || scores_style == Style.PLAIN_DESCENDING)
            /* A column heading in the scores dialog */
            score_or_time = _("Score");
        else
            score_or_time = _("Time");

        var label_column_2 = new Gtk.Label ("<span weight='bold'>" + score_or_time + "</span>");
        label_column_2.use_markup = true;
        grid.attach (label_column_2, 1, 0, 1, 1);

        /* A column heading in the scores dialog */
        string string_player = _("Player");
        var label_column_3 = new Gtk.Label ("<span weight='bold'>" + string_player + "</span>");
        label_column_3.use_markup = true;
        grid.attach (label_column_3, 2, 0, 1, 1);

        grid.baseline_row = 0;
        fill_grid_with_labels ();

        if (new_high_score != null)
            /* Appears on the top right corner of the dialog. Clicking the button closes the dialog. */
            add_button (_("Done"), Gtk.ResponseType.OK).get_style_context ().add_class ("suggested-action");

        load_categories ();

        vbox.show_all ();
    }

    private void fill_grid_with_labels ()
    {
        for (int row = 1; row <= rows_to_display; row++)
        {
            for (int column = 0; column <= 1; column++)
            {
                var label = new Gtk.Label ("");
                label.visible = true;
                label.halign = Gtk.Align.CENTER;
                label.valign = Gtk.Align.CENTER;

                grid.attach (label, column, row, 1, 1);
            }

            var stack = new Gtk.Stack ();
            stack.visible = true;
            stack.homogeneous = true;
            stack.transition_type = Gtk.StackTransitionType.NONE;

            var label = new Gtk.Label ("");
            label.visible = true;
            label.justify = Gtk.Justification.CENTER;
            label.valign = Gtk.Align.CENTER;
            stack.add_named (label, "label");

            var entry = new Gtk.Entry ();
            entry.visible = true;
            entry.set_size_request (20, 20);
            entry.expand = false;
            stack.add_named (entry, "entry");

            stack.visible_child_name = "label";
            grid.attach (stack, 2, row, 1, 1);
        }
    }

    /* load names and keys of all categories in ComboBoxText */
    private void load_categories ()
    {
        /* If we are adding a high score, we don't wish to load all categories. We only wish to load scores of active category. */
        if (new_high_score != null)
        {
            load_scores ();
        }

        if (combo == null)
            return;

        var categories = context.get_categories ();
        categories.foreach ((x) => combo.append (x.key, x.name));

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

    /* loads the scores of current active_category */
    private void load_scores ()
    {
        if (new_high_score != null)
            active_category = new Category (scores_active_category.key, scores_active_category.name);
        else
            active_category = new Category (combo.get_active_id (), combo.get_active_text ());

        var best_n_scores = context.get_best_n_scores (active_category, rows_to_display);
        uint no_scores = best_n_scores.length ();

        int row_count = 1;

        best_n_scores.foreach ((x) => {
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
        var rank = (Gtk.Label) grid.get_child_at (0, row_count);
        rank.set_text (row_count.to_string ());

        var score = (Gtk.Label) grid.get_child_at (1, row_count);
        score.set_text (x.score.to_string ());

        if (new_high_score != null && Score.equals (x, new_high_score))
        {
            if (no_scores > 1 && row_count == 1)
                headerbar.subtitle = _("Your score is the best!");
            else
                headerbar.subtitle = _("Your score has made the top ten.");

            var temp_stack = (Gtk.Stack) grid.get_child_at (2, row_count);
            temp_stack.visible_child_name = "entry";

            var entry = (Gtk.Entry) temp_stack.get_visible_child ();
            entry.text = x.user;
            entry.notify["text"].connect (() => {
                context.update_score_name (x, active_category, entry.get_text ());
                x.user = entry.get_text ();
            });
        }

        var name_stack = (Gtk.Stack) grid.get_child_at (2, row_count);
        var widget = name_stack.get_visible_child ();
        Gtk.Label? label = widget as Gtk.Label;

        if (label != null)
        {
            label.set_text (x.user);
        }
        else
        {
            var entry = (Gtk.Entry) widget;
            entry.text = x.user;
        }
    }

    /* Fill all labels from row row_count onwards with empty strings. */
    private void make_remaining_labels_empty (int row_count)
    {
        for (int i = row_count; i <= rows_to_display; i++)
        {
            for (int j = 0; j <= 1; j++)
            {
                var label = (Gtk.Label) grid.get_child_at (j, i);
                label.set_text ("");
            }

            var stack = (Gtk.Stack) grid.get_child_at (2, i);
            var label = (Gtk.Label) stack.get_visible_child ();
            label.set_text ("");
        }
    }
}

} /* namespace Scores */
} /* namespace Games */

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
    private ListStore list;
    private Category? active_category;

    public Dialog (Context scores, string dialog_label/*, Window window*/)
    {
        Object (use_header_bar : 1);
        this.scores = scores;
//	this.transient_for = window;

        var vbox = this.get_content_area ();
        set_border_width (5);

        TreeViewColumn column;
        CellRenderer renderer;

        var scroll = new ScrolledWindow (null, null);
        scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.set_size_request (250, 265);
        scroll.set_shadow_type (ShadowType.ETCHED_IN);
        vbox.pack_end (scroll);

        var catbar = new Box (Orientation.HORIZONTAL, 12);
        vbox.pack_start (catbar, false, false, 0);

	var label = new Label (dialog_label);
	label.set_use_markup (true);
	catbar.pack_start (label, false, false, 0);

        combo = new ComboBoxText ();
        combo.set_focus_on_click (false);
        catbar.pack_start (combo, true, true, 0);
        combo.changed.connect (load_scores);

/*	var headerbar = new HeaderBar ();
	headerbar.show_close_button = true;
	headerbar.custom_title = catbar;
	headerbar.show ();
	set_titlebar (headerbar);*/

        //var hdiv = new Separator (Orientation.HORIZONTAL);
        list = new ListStore (3, typeof (string), typeof (string), typeof (string));
        var listview = new TreeView.with_model (list);

        var name_renderer = new CellRendererText ();
        var name_column = new TreeViewColumn.with_attributes (_("Name"), name_renderer, "text", 0, null);
	name_column.expand = true;
        listview.append_column (name_column);

	var score_renderer = new CellRendererText ();
	score_renderer.xalign = 1;
        var score_column = new TreeViewColumn.with_attributes (_("Score"), score_renderer, "text", 1, null);
        listview.append_column (score_column);
        scroll.add (listview);

        load_categories ();

        vbox.show_all ();
    }

    /* load names and keys of all categories in ComboBoxText */
    private void load_categories ()
    {
        var categories = scores.get_categories ();
        categories.foreach ((x) => combo.append (x.key, x.name));
        if (categories.length() > 0)
        {
            combo.set_active_id (categories.nth_data (0).key);
            active_category = {categories.nth_data (0).key, categories.nth_data (0).name};
        }
        else
            active_category = null;
    }

    /* loads the scores of current active_category */
    private void load_scores()
    {
        active_category = { combo.get_active_id (), combo.get_active_text ()};
        var best_10_scores = scores.get_best_n_scores (active_category, 10);

        list.clear ();
        best_10_scores.foreach ((x) =>
        {
            TreeIter iter;
            list.append (out iter);
            list.set (iter, 0, x.user, 1, x.score.to_string (), -1);
        });

    }
}

} /* namespace Scores */
} /* namespace Games */

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

    public Dialog (Context scores)
    {
        this.scores = scores;
    }

    public void run_dialog ()
    {
	//Widget listview;
	TreeViewColumn column;
        CellRenderer renderer;

	var vbox = new Box (Orientation.VERTICAL, 6);
	set_border_width (5);

	var scroll = new ScrolledWindow (null, null);
	scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
	scroll.set_size_request (250, 265);
	scroll.set_shadow_type (ShadowType.ETCHED_IN);
	vbox.pack_end (scroll);

	//var hdiv = new Separator (Orientation.HORIZONTAL);
	var list = new ListStore (3, typeof (string), typeof (string), typeof (string));
	var listview = new TreeView.with_model (list);

	var name_renderer = new CellRendererText ();
	var name_column = new TreeViewColumn.with_attributes (_("Name"), name_renderer, "text", 0, null);

	listview.append_column (name_column);

	var time_renderer = new CellRendererText ();
	var time_column = new TreeViewColumn.with_attributes (_("Time"), time_renderer, "text", 1, null);

	listview.append_column (time_column);

	var score_renderer = new CellRendererText ();
	var score_column = new TreeViewColumn.with_attributes (_("Score"), score_renderer, "text", 2, null);

	listview.append_column (score_column);
	scroll.add (listview);

	vbox.show_all ();
    }
}

} /* namespace Scores */
} /* namespace Games */

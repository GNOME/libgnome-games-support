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

// FIXME - make these real tests
void main()
{
    /*   Context s = new Context("app");
       s.load_scores_from_files();
       s.print_scores();
       Context a = new Context ("second_app");
       a.load_scores_from_files();
       a.print_scores();*/
    Context s = new Context ("app");
    Category cat = {"cat1", "cat1"};
    s.add_score (101, cat);
    s.add_score (102, cat);
    cat = {"cat2", "cat2"};
    s.add_score (21, cat);
    s.add_score (24, cat);
    s.print_scores();
    //  s.save_scores_to_files();
    Context a = new Context("second_app",Style.PLAIN_ASCENDING);
    a.add_score (111, cat);
    a.add_score (123, cat);
    cat = {"cat3","cat3"};
    a.add_score (21, cat);
    a.add_score (24, cat);
    a.print_scores();
//    a.save_scores_to_files();
}

}
}

/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
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

public class Score : Object
{
    public long score { get; set; }
    public string user { get; set; }
    public int64 time { get; set; }

    public Score (long score, int64 time, string? user = null)
    {
        this.score = score;
        this.time = time;
        this.user = (user == null ? Environment.get_real_name () : user);
    }

    public static bool equals (Score a, Score b)
    {
        return a.score == b.score && a.time == b.time && a.user == b.user;
    }
}

} /* namespace Scores */
} /* namespace Games */

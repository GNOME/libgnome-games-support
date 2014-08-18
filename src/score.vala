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

internal class Score : Object
{
    public long score { get; set; }
    public string? user { get; set; }
    public int64 time { get; set; }

    public Score (long score, int64 time, string? user = null)
    {
        this.score = score;
        this.time = time;
        this.user = user;
    }

    public static bool equals (Score a, Score b)
    {
        return a.score == b.score && a.time == b.time && a.user == b.user;
    }
}

} /* namespace Scores */
} /* namespace Games */

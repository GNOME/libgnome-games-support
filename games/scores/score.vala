/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2014 Nikhar Agrawal
 *
 * This file is part of libgnome-games-support.
 *
 * libgnome-games-support is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * libgnome-games-support is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with libgnome-games-support.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Games {
namespace Scores {

public class Score : Object
{
    public long score { get; set; }

    /* Although the scores dialog does not currently display the time a
     * score was achieved, it did in the past and it might again in the future.
     */
    private int64 _time;
    public int64 time
    {
        get { return _time; }
        set { _time = (value == 0 ? new DateTime.now_local ().to_unix () : value); }
    }

    private string _user;
    public string user
    {
        get { return _user; }
        set { _user = (value == null ? Environment.get_real_name () : user); }
    }

    public Score (long score, int64 time = 0, string? user = null)
    {
        Object (score: score, time: time, user: user);
    }

    public static bool equals (Score a, Score b)
    {
        return a.score == b.score && a.time == b.time && a.user == b.user;
    }
}

} /* namespace Scores */
} /* namespace Games */

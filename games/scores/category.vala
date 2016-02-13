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

public class Category : Object
{
    private string _key;
    public string key
    {
        get { return _key; }
        set
        {
            for (int i = 0; value[i] != '\0'; i++)
            {
                if (!value[i].isalnum () && value[i] != '-')
                {
                    error ("Category keys may contain only hyphens and alphanumeric characters.");
                }
            }
            _key = value;
        }
    }

    /* This is a user-friendly name. It should be marked for translation. */
    public string name { get; set; }

    public Category (string key, string name)
    {
        this.key = key;
        this.name = name;
    }
}

} /* namespace Scores */
} /* namespace Games */

/* -*- Mode: vala; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * Copyright © 2026 Will Warner
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

[CCode (cheader_filename = "miniaudio.h", lower_case_cprefix = "ma_", cprefix = "MA_")]
namespace MiniAudio {

    [CCode (cname = "ma_result", cprefix = "MA_")]
    public enum Result {
        SUCCESS,
        ERROR;
    }

    [CCode (cname = "ma_engine", destroy_function = "ma_engine_uninit", has_type_id = false)]
    public struct Engine {
        [CCode (cname = "ma_engine_init")]
        public Result init (void* config);

        [CCode (cname = "ma_engine_start")]
        public Result start ();

        [CCode (cname = "ma_engine_uninit")]
        public void uninit ();
    }

    [CCode (cname = "ma_sound", destroy_function = "ma_sound_uninit", has_type_id = false)]
    public struct Sound {
        [CCode (cname = "ma_sound_init_from_file")]
        public static Result init_from_file (Engine* engine, string file_path, uint32 flags, void* group, void* fence, out Sound sound);

        [CCode (cname = "ma_sound_start")]
        public Result start ();

        [CCode (cname = "ma_sound_stop")]
        public Result stop ();

        [CCode (cname = "ma_sound_set_volume")]
        public void set_volume (float volume);

        [CCode (cname = "ma_sound_set_looping")]
        public void set_looping (bool isLooping);

        [CCode (cname = "ma_sound_uninit")]
        public void uninit ();
    }
}


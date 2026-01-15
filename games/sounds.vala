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

using MiniAudio;

namespace Games {

public class Sounds : Object
{
    private class SoundWrapper
    {
        public MiniAudio.Sound sound;
        public bool initialized = false;

        public SoundWrapper (Engine engine, string path)
        {
            if (Sound.init_from_file(&engine, path, 0, null, null, out sound) == Result.SUCCESS)
                initialized = true;
            else
                warning ("Failed to load sound: %s", path);
        }

        public void play ()
        {
            sound.start ();
        }
    }

    private Engine engine;
    private HashTable<string, SoundWrapper> library =
        new HashTable<string, SoundWrapper>(str_hash, str_equal);

    public Sounds (string sound_dir)
        throws Error
    {
        if (this.engine.init(null) != Result.SUCCESS) // Initializing with null uses default settings
        {
            error ("Failed to initialize Audio Engine");
        }

        var directory = File.new_for_path(sound_dir);
        if (!directory.query_exists())
            return;

        var enumerator = directory.enumerate_children(FileAttribute.STANDARD_NAME, 0);
        FileInfo file_info;
        while ((file_info = enumerator.next_file()) != null)
        {
            var filename = file_info.get_name();
            var path = Path.build_filename (sound_dir, filename);
            var wrapper = new SoundWrapper (engine, path);
            if (wrapper.initialized == false)
                library.insert (filename, wrapper);
        }
    }

    /**
     * Plays a sound by filename
     */
    public void play (string filename)
    {
        unowned var wrapper = library[filename];
        if (wrapper != null)
            wrapper.play ();
        else
            warning ("Sound not found: %s", filename);
    }

    public override void dispose ()
    {
        this.engine.uninit();
        base.dispose ();
    }
}

} /* namespace Games */

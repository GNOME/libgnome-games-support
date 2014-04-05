#!/bin/sh
# Run this to generate all the initial makefiles, etc.

which gnome-autogen.sh || {
    echo "You need to install gnome-common from GNOME git (or from"
    echo "your OS vendor's package manager)."
    exit 1
}

. gnome-autogen.sh

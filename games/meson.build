includesubdir = get_option('superproject_name') + '_gnome-games-support'

lggs_interface_deps = [
    adw_dependency,
    gio_dependency,
    glib_dependency,
    gtk_dependency,
]

sources = [
    'config.vapi',
    'appearance-group.vala',
    'gridframe.vala',
    'scores/category.vala',
    'scores/context.vala',
    'scores/dialog.vala',
    'scores/score.vala',
]

vala_args = []

if get_option('sounds')
    sources += 'sounds.vala'

    vala_args += '--vapidir=' + meson.project_source_root () / 'games' / 'vapi'

    lggs_interface_deps += [
        sndfile_dependency,
        openal_dependency,
    ]
endif

lggs = static_library('gnome-games-support-3',
    sources,
    c_args: [
        '-w',
        '-DGETTEXT_PACKAGE="@0@"'.format (gettext_package),
        '-DLOCALEDIR="@0@"'.format (localedir),
    ],
    vala_header: 'libgnome-games-support.h',
    vala_args: vala_args,
    dependencies: lggs_interface_deps,
)

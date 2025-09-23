includesubdir = get_option('superproject_name') + '_gnome-games-support'

lggs_interface_deps = [
    adw_dependency,
    gio_dependency,
    glib_dependency,
    gtk_dependency,
]

sources = [
    'config.vapi',
    'gridframe.vala',
    'theme-selector-dialog.vala',
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
    vala_gir: 'GnomeGamesSupport-3.0.gir',
    dependencies: lggs_interface_deps,
)

g_ir_compiler = find_program('g-ir-compiler')
typelib = custom_target('gnome-games-support-3-typelib',
    input: lggs.vala_gir(),
    output: 'GnomeGamesSupport-3.0.typelib',
    command: [
        g_ir_compiler,
        '--output',
        '@OUTPUT@',
        '@INPUT@',
    ],
    install: true,
    install_dir: libdir / 'girepository-1.0',
)

gidocgen = find_program('gi-docgen', required: false)

if gidocgen.found()
    custom_target('gnome-games-support-3-doc',
        input: lggs.vala_gir(),
        output: 'GnomeGamesSupport-3.0',
        command: [
            gidocgen,
            'generate',
            '--quiet',
            '--output-dir=@OUTPUT@',
            '--no-namespace-dir',
            '--content-dir=@0@'.format(meson.current_build_dir()),
            '@INPUT@',
        ],
        build_by_default: true,
        install: true,
        install_dir: datadir / 'doc',
    )
endif

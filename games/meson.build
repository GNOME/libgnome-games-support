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

c_args = [
    '-w',
    '-DGETTEXT_PACKAGE="@0@"'.format (gettext_package),
    '-DLOCALEDIR="@0@"'.format (localedir),
]

lggs = static_library('gnome-games-support-3',
    sources,
    c_args: c_args,
    vala_header: 'libgnome-games-support.h',
    dependencies: lggs_interface_deps,
)

valac = find_program('valac', required: true)

gir = custom_target('gnome-games-support-3-gir',
    input: sources,
    output: 'GnomeGamesSupport-3.0.gir',
    command: [
        valac,
        '-c',
        '--pkg=gee-0.8',
        '--pkg=gio-2.0',
        '--pkg=gtk4',
        '--pkg=libadwaita-1',
        '-X', '-DGETTEXT_PACKAGE="@0@"'.format (gettext_package),
        '-X', '-DLOCALEDIR="@0@"'.format (localedir),
        '--library', 'unused',
        '--gir=@OUTPUT@',
        '@INPUT@',
    ],
    install: true,
    install_dir: datadir / 'gir-1.0',
)

g_ir_compiler = find_program('g-ir-compiler')

typelib = custom_target('gnome-games-support-3-typelib',
    input: gir,
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
        input: gir[0],
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

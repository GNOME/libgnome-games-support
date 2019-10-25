lggs = library('libgnome-games-support-1',
    [
        'config.vapi',
        'gridframe.vala',
        'scores/category.vala',
        'scores/context.vala',
        'scores/dialog.vala',
        'scores/directory-importer.vala',
        'scores/history-file-importer.vala',
        'scores/importer.vala',
        'scores/score.vala'
    ],
    name_prefix: '',
    install: true,
    install_dir: [true, true, true],    # default directories for header and vapi
    c_args: [
        '-include', 'config.h'
    ],
    vala_header: 'libgnome-games-support.h',
    vala_vapi: 'libgnome-games-support-1.vapi',
    vala_args: [
        '--abi-stability',
        '--target-glib', '2.44'
    ],
    dependencies: [
        gee_dependency,
        gio_dependency,
        glib_dependency,
        gtk_dependency
    ]
)

pkg = import('pkgconfig')
pkg.generate(lggs)

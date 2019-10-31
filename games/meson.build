includesubdir = 'gnome-games-support-1'

lggs_interface_deps = [
    gee_dependency,
    gio_dependency,
    glib_dependency,
    gtk_dependency,
]

lggs = library('gnome-games-support-1',
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
    install: true,
    install_dir: [
        true, # default libdir
        join_paths(includedir, includesubdir), # headers
        true, # default vapidir
    ],
    c_args: [
        # https://github.com/mesonbuild/meson/issues/4763
        '-include', 'config.h'
    ],
    vala_header: 'libgnome-games-support.h',
    vala_vapi: 'libgnome-games-support-1.vapi',
    vala_args: [
        '--abi-stability',
        '--target-glib', '2.44'
    ],
    soversion: lggs_soversion,
    version: lggs_library_version,
    dependencies: lggs_interface_deps,
)

lggs_dependency = declare_dependency(
    link_with: lggs,
    include_directories: include_directories('.'),
)

pkg = import('pkgconfig')
pkg.generate(
    lggs,
    filebase: 'libgnome-games-support-1',
    requires: lggs_interface_deps,
    name: meson.project_name(),
    description: 'Useful functionality shared among GNOME games',
    subdirs: includesubdir,
)

lggs_tests = executable('libgnome-games-support-tests',
    [ 'test-scores.vala' ],
    c_args: [
        '-include', join_paths(meson.build_root(), 'games', 'libgnome-games-support.h')
    ],
    vala_args: [
        '--target-glib', '2.44'
    ],
    dependencies : [
        gee_dependency,
        glib_dependency,
        gtk_dependency
    ],
    link_with: lggs
)
test('libgnome-games-support-tests', lggs_tests, timeout : 1)

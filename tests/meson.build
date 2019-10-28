lggs_tests = executable('libgnome-games-support-tests',
    [ 'test-scores.vala' ],
    vala_args: [
        '--target-glib', '2.44'
    ],
    dependencies : [
        gee_dependency,
        glib_dependency,
        gtk_dependency,
        lggs_dependency,
    ],
)
test('libgnome-games-support-tests', lggs_tests, timeout : 1)

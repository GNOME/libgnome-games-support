gir_toml = configure_file(
    input: 'Gir.toml.in',
    output: 'Gir.toml',
    configuration: {
        'gir_files':
            '"' + meson.current_source_dir() + '/../../gir-files/",' +
            '"' + meson.current_source_dir() + '/../../libadwaita-rs/",' +
            '"' + meson.current_build_dir() + '/../../games/"'
    },
)

sys = custom_target('gir-rs',
    input: [gir_toml],
    output: 'Cargo.toml',
    depends: [gir],
    # output: 'GnomeGamesSupport-3.0.gir',
    command: [
        'gir',
        '-c',
        meson.current_build_dir() / 'Gir.toml',
        '-o',
        meson.current_build_dir(),
    ],
    install: true,
    install_dir: datadir / 'aaaa',
)

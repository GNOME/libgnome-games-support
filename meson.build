project(
    'libgnome-games-support', ['vala', 'c'],
    version: '2.2.0',
    license: 'LGPLv3+',
    meson_version: '>= 0.50.0',
)

# Before making a release, the library_version string should be modified.
#
#  * Bump the first component if binary compatibility has been broken; or
#  * Bump the second component if new APIs are added; or
#  * Bump the third component otherwise.
#
# When bumping the first component version, set the second and third components
# to 0. When bumping the second version, set the third one to zero.
#
# A lot easier than libtool, right?
library_version = '4.1.0'
soversion = library_version.split('.')[0]

# libgnome-games-support-2
api_version = '2'

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')

adw_dependency = dependency ('libadwaita-1', version: '>= 1.0')
gee_dependency = dependency('gee-0.8', version: '>= 0.14.0')
gio_dependency = dependency('gio-2.0', version: '>= 2.44.0')
glib_dependency = dependency('glib-2.0', version: '>= 2.44.0')
gtk_dependency = dependency('gtk4', version: '>= 4.2.0')

localedir = join_paths(get_option('prefix'), get_option('localedir'))
includedir = join_paths(get_option('prefix'), get_option('includedir'))

conf = configuration_data()
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name() + api_version)
conf.set_quoted('LOCALEDIR', localedir)

configure_file(output: 'config.h', configuration: conf)

subdir('po')
subdir('games')
subdir('tests')

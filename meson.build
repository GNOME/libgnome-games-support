project(
    'libgnome-games-support', ['vala', 'c'],
    version: '1.8.1',
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
library_version = '3.0.3'
soversion = library_version.split('.')[0]

# used to install help
gnome = import('gnome')
# used for internationalization
i18n = import('i18n')

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')  # TODO 0.39.6 min

gee_dependency = dependency('gee-0.8', version: '>= 0.14.0')
gio_dependency = dependency('gio-2.0', version: '>= 2.40.0')
glib_dependency = dependency('glib-2.0', version: '>= 2.40.0')
gtk_dependency = dependency('gtk+-3.0', version: '>= 3.19.2')

localedir = join_paths(get_option('prefix'), get_option('localedir'))
includedir = join_paths(get_option('prefix'), get_option('includedir'))

conf = configuration_data()
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('LOCALEDIR', localedir)

configure_file(output: 'config.h', configuration: conf)

subdir('po')
subdir('games')
subdir('tests')

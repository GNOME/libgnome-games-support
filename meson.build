project(
  'libgnome-games-support', ['vala', 'c'],
  version: '1.4.4',
  license: 'LGPLv3+',
  meson_version: '>= 0.50.0',
)

# used to install help
gnome = import('gnome')
# used for internationalization
i18n = import('i18n')

cc = meson.get_compiler('c')
valac = meson.get_compiler('vala')  # TODO 0.39.6 min

# * If the library source code has changed at all since the last update, then
#   increment revision (‘c:r:a’ becomes ‘c:r+1:a’).
# * If any interfaces have been added, removed, or changed since the last
#   update, increment current, and set revision to 0.
# * If any interfaces have been added since the last public release, then
#   increment age.
# * If any interfaces have been removed or changed since the last public
#   release, then set age to 0)
#
# http://www.gnu.org/software/libtool/manual/html_node/Updating-version-info.html
lggs_soversion = 3
revision = 1
age = 0
lggs_library_version = '@0@.@1@.@2@'.format(lggs_soversion, age, revision)

gee_dependency      = dependency('gee-0.8',     version: '>= 0.14.0')
gio_dependency      = dependency('gio-2.0',     version: '>= 2.40.0')
glib_dependency     = dependency('glib-2.0',    version: '>= 2.40.0')
gtk_dependency      = dependency('gtk+-3.0',    version: '>= 3.19.2')

localedir = join_paths(get_option('prefix'), get_option('localedir'))
includedir = join_paths(get_option('prefix'), get_option('includedir'))

conf = configuration_data ()
conf.set_quoted ('VERSION', meson.project_version())
conf.set_quoted ('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted ('LOCALEDIR', localedir)

configure_file(output: 'config.h', configuration: conf)

subdir('po')
subdir('games')
subdir('tests')

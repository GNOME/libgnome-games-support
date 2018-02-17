AC_PREREQ([2.69])
AC_INIT([libgnome-games-support], [1.2.3], [https://bugzilla.gnome.org])

dnl http://people.gnome.org/~walters/docs/build-api.txt
dnl https://bugzilla.gnome.org/show_bug.cgi?id=751624
echo \#buildapi-variable-no-builddir >/dev/null

dnl * If the library source code has changed at all since the last update, then
dnl   increment revision (‘c:r:a’ becomes ‘c:r+1:a’).
dnl * If any interfaces have been added, removed, or changed since the last
dnl   update, increment current, and set revision to 0.
dnl * If any interfaces have been added since the last public release, then
dnl   increment age.
dnl * If any interfaces have been removed or changed since the last public
dnl   release, then set age to 0)
dnl
dnl http://www.gnu.org/software/libtool/manual/html_node/Updating-version-info.html
AC_SUBST([LIBGNOME_GAMES_SUPPORT_LT_VERSION], [3:0:0])

AC_SUBST([LIBGNOME_GAMES_SUPPORT_API_VERSION], [1])

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign subdir-objects])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE([enable])

AM_PROG_VALAC([0.39.6])

LT_PREREQ([2.2])
LT_INIT([disable-static])

AX_REQUIRE_DEFINED([PKG_CHECK_MODULES])
PKG_CHECK_MODULES([GEE], [gee-0.8])
PKG_CHECK_MODULES([GIO], [gio-2.0 >= 2.40])
PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.40])
PKG_CHECK_MODULES([GTK], [gtk+-3.0 >= 3.19.2])

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.19.8])
AC_SUBST([GETTEXT_PACKAGE], [AC_PACKAGE_NAME])

AC_CONFIG_FILES([
  Makefile
  libgnome-games-support-1.pc
  po/Makefile.in
  games/Makefile
  tests/Makefile
])

AC_OUTPUT

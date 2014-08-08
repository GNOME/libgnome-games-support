AC_PREREQ([2.69])
AC_INIT([libgames-scores], [0.1], [https://bugzilla.gnome.org])

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
LIBGAMES_SCORES_LT_VERSION=0:0:0
AC_SUBST(LIBGAMES_SCORES_LT_VERSION)

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([src/context.vala])

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE([enable])

GNOME_MAINTAINER_MODE_DEFINES

AM_PROG_VALAC([0.24])

LT_PREREQ([2.2])
LT_INIT([disable-static])

PKG_CHECK_MODULES(LIBGAMES_SCORES, [
  glib-2.0 >= 2.40
  gio-2.0 >= 2.40
  gtk+-3.0 >= 3.12
  gee-0.8
])

GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
IT_PROG_INTLTOOL(0.50.2)

AC_CONFIG_FILES([
	Makefile
	libgames-scores.pc
	src/Makefile
	po/Makefile.in
])

AC_OUTPUT

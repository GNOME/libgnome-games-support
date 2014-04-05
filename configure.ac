AC_PREREQ([2.63])
AC_INIT([libgames-scores], [3.13.0], [https://bugzilla.gnome.org])

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

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
LT_PREREQ([2.2])
LT_INIT([disable-static])

AC_CONFIG_SRCDIR([games-scores/games-scores.c])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([config.h])

AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE([enable])
GNOME_MAINTAINER_MODE_DEFINES

AC_PROG_CC
AC_PROG_INSTALL

AM_PROG_CC_C_O

GTK_REQUIRED=3.10

PKG_CHECK_MODULES(LIBGAMES_SCORES, [
  glib-2.0
  gio-2.0
  gtk+-3.0 >= $GTK_REQUIRED
])

GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
IT_PROG_INTLTOOL(0.40)

AC_CONFIG_FILES([
	Makefile
	include/Makefile
	games-scores/Makefile
	po/Makefile.in
])

AC_OUTPUT

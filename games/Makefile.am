lib_LTLIBRARIES = libgnome-games-support-@LIBGNOME_GAMES_SUPPORT_API_VERSION@.la

libgnome_games_support_@LIBGNOME_GAMES_SUPPORT_API_VERSION@_la_SOURCES = \
	config.vapi				\
	gridframe.vala				\
	scores/category.vala			\
	scores/context.vala			\
	scores/dialog.vala			\
	scores/directory-importer.vala		\
	scores/history-file-importer.vala	\
	scores/importer.vala			\
	scores/score.vala

libgnome_games_support_@LIBGNOME_GAMES_SUPPORT_API_VERSION@_la_CFLAGS = \
	-w

libgnome_games_support_@LIBGNOME_GAMES_SUPPORT_API_VERSION@_la_CPPFLAGS = \
	-I$(top_srcdir)/include				\
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\"	\
	-DLOCALEDIR=\"$(localedir)\"			\
	$(LIBGNOME_GAMES_SUPPORT_CFLAGS)

libgnome_games_support_@LIBGNOME_GAMES_SUPPORT_API_VERSION@_la_LDFLAGS = \
	-version-info $(LIBGNOME_GAMES_SUPPORT_LT_VERSION) \
	-no-undefined

libgnome_games_support_@LIBGNOME_GAMES_SUPPORT_API_VERSION@_la_LIBADD = \
	$(LIBGNOME_GAMES_SUPPORT_LIBS)

libgnome_games_support_@LIBGNOME_GAMES_SUPPORT_API_VERSION@_la_VALAFLAGS = \
	--pkg glib-2.0				\
	--pkg gtk+-3.0				\
	--pkg gio-2.0				\
	--pkg gee-0.8				\
	--header=libgnome-games-support.h	\
	--vapi=libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).vapi

libgnome-games-support.h libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).vapi: \
	libgnome_games_support_$(LIBGNOME_GAMES_SUPPORT_API_VERSION)_la_vala.stamp

games_includedir = $(includedir)/gnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION)
dist_games_include_HEADERS = libgnome-games-support.h

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).vapi

MAINTAINERCLEANFILES = \
	libgnome-games-support.h	\
	libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).vapi

-include $(top_srcdir)/git.mk

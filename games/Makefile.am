lib_LTLIBRARIES = libgames-support-@LIBGAMES_SUPPORT_API_VERSION@.la

libgames_support_@LIBGAMES_SUPPORT_API_VERSION@_la_SOURCES = \
	config.vapi				\
	gridframe.vala				\
	scores/category.vala			\
	scores/context.vala			\
	scores/dialog.vala			\
	scores/directory-importer.vala		\
	scores/history-file-importer.vala	\
	scores/importer.vala			\
	scores/score.vala

libgames_support_@LIBGAMES_SUPPORT_API_VERSION@_la_CFLAGS = \
	-w

libgames_support_@LIBGAMES_SUPPORT_API_VERSION@_la_CPPFLAGS = \
	-I$(top_srcdir)/include				\
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\"	\
	-DLOCALEDIR=\"$(localedir)\"			\
	$(LIBGAMES_SUPPORT_CFLAGS)

libgames_support_@LIBGAMES_SUPPORT_API_VERSION@_la_LDFLAGS = \
	-version-info $(LIBGAMES_SUPPORT_LT_VERSION) \
	-no-undefined \
	$(LIBGAMES_SUPPORT_LIBS)

libgames_support_@LIBGAMES_SUPPORT_API_VERSION@_la_VALAFLAGS = \
	--pkg glib-2.0			\
	--pkg gtk+-3.0			\
	--pkg gio-2.0			\
	--pkg gee-0.8			\
	--header=libgames-support.h	\
	--vapi=libgames-support-$(LIBGAMES_SUPPORT_API_VERSION).vapi

libgames-support.h libgames-support-$(LIBGAMES_SUPPORT_API_VERSION).vapi: \
	libgames_support_$(LIBGAMES_SUPPORT_API_VERSION)_la_vala.stamp

games_includedir = $(includedir)/games-support-$(LIBGAMES_SUPPORT_API_VERSION)
dist_games_include_HEADERS = libgames-support.h

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = libgames-support-$(LIBGAMES_SUPPORT_API_VERSION).vapi

MAINTAINERCLEANFILES = \
	libgames-support.h	\
	libgames-support-$(LIBGAMES_SUPPORT_API_VERSION).vapi

-include $(top_srcdir)/git.mk

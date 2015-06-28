lib_LTLIBRARIES = libgames-support.la

libgames_support_la_SOURCES = \
	config.vapi		\
	scores/category.vala	\
	scores/context.vala	\
	scores/dialog.vala	\
	scores/score.vala

libgames_support_la_CFLAGS = \
	-w

libgames_support_la_CPPFLAGS = \
	-I$(top_srcdir)/include				\
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\"	\
	-DLOCALEDIR=\"$(localedir)\"			\
	$(LIBGAMES_SUPPORT_CFLAGS)

libgames_support_la_LDFLAGS = \
	-version-info $(LIBGAMES_SUPPORT_LT_VERSION) \
	-no-undefined \
	$(LIBGAMES_SUPPORT_LIBS)

libgames_support_la_VALAFLAGS = \
	--pkg glib-2.0			\
	--pkg gtk+-3.0			\
	--pkg gio-2.0			\
	--pkg gee-0.8			\
	--header=games-support.h	\
	--vapi=games-support.vapi

games-support.h games-support.vapi : libgames_support_la_vala.stamp

games_includedir = $(includedir)/gnome-games
dist_games_include_HEADERS = games-support.h

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = games-support.vapi

noinst_PROGRAMS = test-scores

TESTS = test-scores

test_scores_SOURCES = \
	games-support.vapi \
	scores/test-scores.vala

test_scores_CFLAGS = \
	-w

test_scores_CPPFLAGS = \
	$(LIBGAMES_SUPPORT_CFLAGS)

test_scores_LDADD = \
	libgames-support.la \
	$(LIBGAMES_SUPPORT_LIBS)

test_scores_VALAFLAGS = \
	--pkg gee-0.8 \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg gtk+-3.0

MAINTAINERCLEANFILES = \
	games-support.h		\
	games-support.vapi

-include $(top_srcdir)/git.mk

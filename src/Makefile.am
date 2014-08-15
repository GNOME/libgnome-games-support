lib_LTLIBRARIES = libgames-scores.la

noinst_PROGRAMS = test-scores

TESTS = test-scores

libgames_scores_la_SOURCES = \
	config.vapi \
	context.vala \
	dialog.vala \
	score.vala

libgames_scores_la_CFLAGS = \
	-w

libgames_scores_la_CPPFLAGS = \
	-I$(top_srcdir)/include \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(LIBGAMES_SCORES_CFLAGS)

libgames_scores_la_LDFLAGS = \
	-version-info $(LIBGAMES_SCORES_LT_VERSION) \
	-no-undefined \
	$(LIBGAMES_SCORES_LIBS)

libgames_scores_la_VALAFLAGS = \
	--pkg glib-2.0 \
	--pkg gtk+-3.0 \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--header=games-scores.h \
	--vapi=games-scores.vapi

games-scores.h games-scores.vapi : libgames_scores_la_vala.stamp

games_includedir = $(includedir)/gnome-games
dist_games_include_HEADERS = games-scores.h

vapidir = $(datadir)/vala/vapi
dist_vapi_DATA = games-scores.vapi

test_scores_SOURCES = \
	games-scores.vapi \
	test-scores.vala

test_scores_CFLAGS = \
	-w

test_scores_CPPFLAGS = \
	$(LIBGAMES_SCORES_CFLAGS)

test_scores_LDADD = \
	libgames-scores.la \
	$(LIBGAMES_SCORES_LIBS)

test_scores_VALAFLAGS = \
	--pkg gee-0.8 \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg gtk+-3.0

MAINTAINERCLEANFILES = \
	games-scores.h \
	games-scores.vapi

-include $(top_srcdir)/git.mk

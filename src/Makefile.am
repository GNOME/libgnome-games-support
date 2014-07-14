lib_LTLIBRARIES = libgames-scores.la

libgames_scores_la_SOURCES = \
	config.vapi \
	dialog.vala \
	score.vala \
	scores.vala

libgames_scores_la_CFLAGS = \
	$(LIBGAMES_SCORES_CFLAGS) \
	-w

libgames_scores_la_CPPFLAGS = \
	-I$(top_srcdir)/include \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DLOCALEDIR=\"$(localedir)\" \
	$(LIBGAMES_SCORES_CPPFLAGS)

libgames_scores_la_LDFLAGS = \
	-version-info $(LIBGAMES_SCORES_LT_VERSION) \
	-no-undefined \
	$(LIBGAMES_SCORES_LDFLAGS)

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

MAINTAINERCLEANFILES = \
	games-scores.h \
	games-scores.vapi

-include $(top_srcdir)/git.mk

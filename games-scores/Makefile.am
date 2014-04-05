lib_LTLIBRARIES = libgames-scores.la

libgames_scores_la_SOURCES = \
	games-score.c \
	games-scores.c \
	games-scores-backend.c \
	games-scores-dialog.c

libgames_scores_la_CFLAGS = \
	$(LIBGAMES_SCORES_CFLAGS)

libgames_scores_la_CPPFLAGS = \
	-I$(top_srcdir)/include \
	$(LIBGAMES_SCORES_CPPFLAGS)

libgames_scores_la_LDFLAGS = \
	-version-info $(LIBGAMES_SCORES_LT_VERSION) \
	$(LIBGAMES_SCORES_LDFLAGS)

-include $(top_srcdir)/git.mk

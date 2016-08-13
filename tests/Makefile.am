noinst_PROGRAMS = test-scores

TESTS = test-scores

test_scores_SOURCES = \
	$(top_srcdir)/games/libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).vapi	\
	test-scores.vala

test_scores_CFLAGS = \
	-w

test_scores_CPPFLAGS = \
	-I$(top_srcdir)/games		\
	$(LIBGNOME_GAMES_SUPPORT_CFLAGS)

test_scores_LDADD = \
	$(top_builddir)/games/libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).la	\
	$(LIBGNOME_GAMES_SUPPORT_LIBS)

test_scores_VALAFLAGS = \
	--pkg gee-0.8	\
	--pkg glib-2.0	\
	--pkg gio-2.0	\
	--pkg gtk+-3.0

-include $(top_srcdir)/git.mk

SUBDIRS = games po tests

pkgconfigdir = $(libdir)/pkgconfig

pkgconfig_DATA = libgnome-games-support-$(LIBGNOME_GAMES_SUPPORT_API_VERSION).pc

EXTRA_DIST = \
	COPYING.LESSER

MAINTAINERCLEANFILES = \
	$(GITIGNORE_MAINTAINERCLEANFILES_TOPLEVEL)	\
	$(GITIGNORE_MAINTAINERCLEANFILES_MAKEFILE_IN)	\
	$(GITIGNORE_MAINTAINERCLEANFILES_M4_LIBTOOL)

# We currently have no custom macros
GITIGNOREFILES = m4

-include $(top_srcdir)/git.mk

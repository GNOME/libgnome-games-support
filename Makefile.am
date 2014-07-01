SUBDIRS = src po

ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}

pkgconfigdir = $(libdir)/pkgconfig

pkgconfig_DATA = libgames-scores.pc

EXTRA_DIST = \
	autogen.sh \
	COPYING \
	INSTALL \
	NEWS \
	README

MAINTAINERCLEANFILES = \
	$(GITIGNORE_MAINTAINERCLEANFILES_TOPLEVEL) \
	$(GITIGNORE_MAINTAINERCLEANFILES_MAKEFILE_IN) \
	$(GITIGNORE_MAINTAINERCLEANFILES_M4_LIBTOOL)

# We currently have no custom macros
GITIGNOREFILES = m4

-include $(top_srcdir)/git.mk

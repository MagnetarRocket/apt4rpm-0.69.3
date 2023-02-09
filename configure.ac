AC_PREREQ(2.59)

m4_define(_VERSION,0.69.3)

AC_INIT([apt4rpm],[_VERSION],[apt4rpm-users@lists.sourceforge.net])
AC_CONFIG_SRCDIR(server)
AC_CONFIG_AUX_DIR(.)

AM_INIT_AUTOMAKE([gnu 1.9 dist-bzip2 no-dist-gzip])
AM_MAINTAINER_MODE

AC_PREFIX_DEFAULT([/usr])

AC_ARG_ENABLE([pkgdocdir],
  [AC_HELP_STRING([--enable-pkgdocdir=DIR],
    [where to install the documentation (default: DATADIR/doc)])],
  [pkgdocdir="$enable_pkgdocdir"],
  [pkgdocdir="\$(datadir)/doc/${PACKAGE}"])
AC_SUBST(pkgdocdir)

AC_ARG_ENABLE([docs],
  [AC_HELP_STRING([--enable-docs=<yes|no>],
    [whether to rebuild the documentation (default: no)])],
  [case $enable_docs in
   yes | no ) ;;
   *) enable_docs=no
   esac],
  [enable_docs=no])

AC_PATH_PROG(PERL,[perl])
if test -z "$PERL"; then
   AC_MSG_ERROR([perl not found])
fi

AC_PATH_PROG(XMLTO,[xmlto],[])
AM_CONDITIONAL(XMLTO,[test -n "$XMLTO"])

AC_PATH_PROG(DB2PS,[db2ps],[])
AM_CONDITIONAL(DB2PS,[test -n "$DB2PS"])

AC_PATH_PROG(BASH,[bash],[])
if test -z "$BASH"; then
   AC_MSG_ERROR([bash not found])
fi

AM_MISSING_PROG(HELP2MAN,[help2man])
AM_CONDITIONAL(HELP2MAN,[test -n "$HELP2MAN"]) 

AC_PATH_PROGS(DTD2HTML,[dtd2html dtd2html.pl],[])
AM_CONDITIONAL(DTD2HTML,[test -n "$DTD2HTML"])

AC_PATH_PROG(XMLLINT,[xmllint],[])
AM_CONDITIONAL(XMLLINT,[test -n "$XMLLINT"])

AC_CONFIG_FILES([
Makefile
apt4rpm.spec
])

AS_IF([test -f configure.ac],,[
if test x"$enable_maintainer_mode" = x"yes"; then
    AC_MSG_ERROR([not supported: using maintainer mode in VPATH built])
fi
AC_CONFIG_LINKS([doc/apt4rpm.xml:doc/apt4rpm.xml])
DOCLINKS="$DOCLINKS doc/apt4rpm.xml"

AC_SUBST(DOCLINKS)
])

AC_OUTPUT


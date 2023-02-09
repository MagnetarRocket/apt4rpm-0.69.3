EXTRA_DIST =
CLEANFILES =

pkgdoc_DATA = AUTHORS COPYING TODO NEWS README ChangeLog doc/index.html

EXTRA_DIST += doc/index.html

htmldocdir = $(pkgdocdir)/html

noinst_HEADERS = @PACKAGE@.spec

# Work around to autoconf's deficiencies
distclean-local:
	rm -rf $(srcdir)/autom4te*.cache

clientdocdir = $(pkgdocdir)/client

dist_clientdoc_DATA  = client/README
dist_clientdoc_DATA += client/aptrpm-2

if MAINTAINER_MODE
if HELP2MAN
server/aptate.8: server/aptate server/aptate.x
	$(HELP2MAN) -I server/aptate.x -N -s 8 ./server/aptate > $(srcdir)/server/aptate.8
endif
MAINTAINERCLEANFILES = server/aptate.8
endif

dist_man8_MANS = server/aptate.8

EXTRA_DIST += server/aptate.x

apt4rpm_libdir = $(pkglibdir)
apt4rpm_methodsdir = $(pkglibdir)/methods

sysconf_aptdir = $(sysconfdir)/apt
sysconf_apt_DATA = config/aptate.conf

BUILT_SOURCES = config/aptate.conf

config/aptate.conf: config/aptate.minimal.xml
	@$(mkinstalldirs) config
	sed -e s,SYSTEM.*aptate\.dtd\",SYSTEM\ \"$(pkgdatadir)/aptate\.dtd\", \
	$(srcdir)/config/aptate.minimal.xml > config/aptate.conf
CLEANFILES += config/aptate.conf

EXTRA_DIST += config/aptate.xml
EXTRA_DIST += config/aptate.minimal.xml

dist_pkgdata_DATA = config/aptate.dtd
dist_pkgdata_DATA += config/ref.conf

EXTRA_DIST += config/rpmpriorities/README.suse-7.x
EXTRA_DIST += config/rpmpriorities/redhat-7.x
EXTRA_DIST += config/rpmpriorities/suse-7.x-deflt-system
EXTRA_DIST += config/rpmpriorities/suse-7.x-minimal-system

if XMLLINT
check-xmllint:
	$(XMLLINT) --dtdattr --postvalid --noout $(srcdir)/config/aptate.xml || exit 1

check-convert:
	perllibdir="lib" ./config/aptate-convert \
	--dtd $(srcdir)/config $(srcdir)/config/aptate.xml > /dev/null || exit 1
endif

check: check-xmllint check-convert

# produce the dtd manual
dtddocdir = $(pkgdocdir)/dtd-manual

DTDDOCS_sources  = config/man/style.css
DTDDOCS_sources += config/man/elt.accept.html
DTDDOCS_sources += config/man/elt.add-arg.html
DTDDOCS_sources += config/man/elt.archive.html
DTDDOCS_sources += config/man/elt.authorization.html
DTDDOCS_sources += config/man/elt.component.html
DTDDOCS_sources += config/man/elt.distribution.html
DTDDOCS_sources += config/man/elt.excludedir.html
DTDDOCS_sources += config/man/elt.language.html
DTDDOCS_sources += config/man/elt.name.html
DTDDOCS_sources += config/man/elt.opt.html
DTDDOCS_sources += config/man/elt.reject.html
DTDDOCS_sources += config/man/elt.repdir.html
DTDDOCS_sources += config/man/elt.script.html
DTDDOCS_sources += config/man/elt.sharedir.html
DTDDOCS_sources += config/man/elt.sources-list-file.html
DTDDOCS_sources += config/man/elt.sources-list-ftp.html
DTDDOCS_sources += config/man/elt.sources-list-http.html
DTDDOCS_sources += config/man/elt.topdir.html
DTDDOCS_sources += config/man/elt.url.html
DTDDOCS_sources += config/man/elt.wget.html
EXTRA_DIST += $(DTDDOCS_sources)

DTDDOCS   = config/dtd-manual.book.home.html
DTDDOCS  += config/dtd-manual.book.elements_index.html
DTDDOCS  += config/dtd-manual.book.entities_index.html
DTDDOCS  += config/dtd-manual.book.examples_list.html
DTDDOCS  += config/dtd-manual.book.home.html
DTDDOCS  += config/dtd-manual.book.notations_index.html
DTDDOCS  += config/dtd-manual.book.prolog.html
DTDDOCS  += config/dtd-manual.elt.accept.html
DTDDOCS  += config/dtd-manual.elt.add-arg.html
DTDDOCS  += config/dtd-manual.elt.architecture.html
DTDDOCS  += config/dtd-manual.elt.archive.html
DTDDOCS  += config/dtd-manual.elt.authorization.html
DTDDOCS  += config/dtd-manual.elt.component.html
DTDDOCS  += config/dtd-manual.elt.distribution.html
DTDDOCS  += config/dtd-manual.elt.email.html
DTDDOCS  += config/dtd-manual.elt.excludedir.html
DTDDOCS  += config/dtd-manual.elt.language.html
DTDDOCS  += config/dtd-manual.elt.name.html
DTDDOCS  += config/dtd-manual.elt.opt.html
DTDDOCS  += config/dtd-manual.elt.reject.html
DTDDOCS  += config/dtd-manual.elt.repdir.html
DTDDOCS  += config/dtd-manual.elt.script.html
DTDDOCS  += config/dtd-manual.elt.sharedir.html
DTDDOCS  += config/dtd-manual.elt.sources-list-file.html
DTDDOCS  += config/dtd-manual.elt.sources-list-ftp.html
DTDDOCS  += config/dtd-manual.elt.sources-list-http.html
DTDDOCS  += config/dtd-manual.elt.topdir.html
DTDDOCS  += config/dtd-manual.elt.url.html
DTDDOCS  += config/dtd-manual.elt.version.html
DTDDOCS  += config/dtd-manual.elt.wget.html
DTDDOCS  += config/dtd-manual.ex.aptate.conf.html
DTDDOCS  += config/dtd-manual.ex.aptate.xml.html
DTDDOCS  += config/style.css
DTDDOCS  += config/home.png
DTDDOCS  += config/next.png
DTDDOCS  += config/prev.png
DTDDOCS  += config/up.png
DTDDOCS  += config/dtd-frame.html
DTDDOCS  += config/dtd-frame.main.html
DTDDOCS  += config/dtd-frame.alpha.html
DTDDOCS  += config/dtd-frame.tree.html

dist_dtddoc_DATA = $(DTDDOCS)

if MAINTAINER_MODE
if DTD2HTML
# style must be in the same directory as the resulting *html files
# from dtd2html
config/style.css: config/man/style.css
	cp $(top_srcdir)/config/man/style.css config/style.css

config/dtd-manual.book.home.html: $(DTDDOCS_sources) config/style.css
	cd $(srcdir)/config && \
	$(DTD2HTML) -b -t "aptate configuration manual" -s style -o dtd-manual \
	  -D -H -x 'aptate.xml aptate.conf' aptate.xml

config/dtd-frame.html: $(DTDDOCS_sources)
	cd $(srcdir)/config && \
	$(DTD2HTML) -f -t "aptate configuration manual" -s style -o dtd-frame \
	  -D -H -x 'aptate.xml aptate.conf' aptate.xml
MAINTAINERCLEANFILES += $(DTDDOCS)
endif
endif

if MAINTAINER_MODE
# It's very unfortenate but xmlto is not capable of processing apt4rpm.xml
# to ps output :(
if DB2PS
doc/apt4rpm.ps: doc/apt4rpm.xml \
    doc/example/aptate.minimal.xml doc/example/aptate.xml
	cd $(srcdir)/doc && $(DB2PS) apt4rpm.xml
MAINTAINERCLEANFILES += doc/apt4rpm.ps
# garbage produced by db2ps:
CLEANFILES += doc/apt4rpm.tex
CLEANFILES += doc/apt4rpm.out
CLEANFILES += doc/apt4rpm.log
CLEANFILES += doc/apt4rpm.dvi
CLEANFILES += doc/apt4rpm.aux
CLEANFILES += doc/CATALOG.local
CLEANFILES += doc/suse-html.dsl
CLEANFILES += doc/suse-print.dsl
endif
endif
dist_pkgdoc_DATA = doc/apt4rpm.ps

if MAINTAINER_MODE
doc/example/aptate.minimal.xml: config/aptate.minimal.xml
	@$(mkinstalldirs) doc/example
	( echo "<![CDATA["; \
	sed -e s,SYSTEM.*aptate\.dtd\",SYSTEM\ \"file://$(pkgdatadir)/aptate\.dtd\", \
	$(top_srcdir)/config/aptate.minimal.xml; \
	echo "]]>" ) > doc/example/aptate.minimal.xml
CLEANFILES += doc/example/aptate.minimal.xml

doc/example/aptate.xml: config/aptate.xml
	@$(mkinstalldirs) doc/example
	( echo "<![CDATA["; \
	sed -e s,SYSTEM.*aptate\.dtd\",SYSTEM\ \"file://$(pkgdatadir)/aptate\.dtd\", \
	$(top_srcdir)/config/aptate.xml; \
	echo "]]>" ) > doc/example/aptate.xml
CLEANFILES += doc/example/aptate.xml
endif

if MAINTAINER_MODE
if XMLTO
doc/html/ar01.html: doc/apt4rpm.xml \
    doc/example/aptate.minimal.xml doc/example/aptate.xml
	## Use "-o html" as xmlto creates an index.html for the html output
	## type, the xmlto index.html file would otherwise overwrite my
	## index.html file.
	cd $(srcdir)/doc && $(XMLTO) -o html html apt4rpm.xml
MAINTAINERCLEANFILES += doc/html/index.html
MAINTAINERCLEANFILES += doc/html/ar01s*.html
MAINTAINERCLEANFILES += doc/html/ar01.html
endif
endif
dist_htmldoc_DATA = doc/html/ar01.html

if MAINTAINER_MODE
if XMLTO
doc/apt4rpm.html: doc/apt4rpm.xml \
   doc/example/aptate.minimal.xml doc/example/aptate.xml
	cd $(srcdir)/doc && $(XMLTO) html-nochunks apt4rpm.xml
MAINTAINERCLEANFILES += doc/apt4rpm.html
endif
endif
dist_htmldoc_DATA += doc/apt4rpm.html

install-data-hook: doc/html/ar01.html
	for i in $(srcdir)/doc/html/ar01s*.html; do \
	  $(INSTALL_DATA) $$i $(DESTDIR)$(htmldocdir); \
	done

uninstall-local:
	for i in $(srcdir)/doc/html/ar01s*.html; do \
	  b=`basename $$i`; rm $(DESTDIR)$(htmldocdir)/$$b; \
        done

dist-hook:
	@for i in $(srcdir)/doc/html/ar01s*.html; do \
	  $(INSTALL_DATA) $$i $(distdir)/doc/html; \
	done

EXTRA_DIST += doc/apt4rpm.xml

aptate_perlmoddir = $(pkgdatadir)/Aptate
aptate_perlmod_DATA = lib/Aptate/Version.pm
aptate_perlmod_DATA += lib/Aptate/Config.pm
aptate_perlmod_DATA += lib/Aptate/Yum.pm
aptate_perlmod_DATA += lib/Aptate/Repo.pm

EXTRA_DIST += lib/Aptate/Version.pm.in
EXTRA_DIST += lib/Aptate/Config.pm
EXTRA_DIST += lib/Aptate/Yum.pm
EXTRA_DIST += lib/Aptate/Repo.pm

do_subst = sed \
	-e 's,[@]PACKAGE_VERSION[@],$(PACKAGE_VERSION),g' \
	-e 's,[@]PACKAGE[@],$(PACKAGE_NAME),g' \
	-e 's,[@]PACKAGE_BUGREPORT[@],$(PACKAGE_BUGREPORT),g' \
	-e 's,[@]APTATECONFDIR[@],$(sysconfdir)/apt,g' \
	-e 's,[@]APTATEDATADIR[@],$(pkgdatadir),g' \
	-e 's,[@]APTATELIBDIR[@],$(pkglibdir),g' \
	-e 's,[@]BASH[@],$(BASH),g' \
	-e 's,[@]PERL[@],$(PERL),g'

bin_SCRIPTS = server/aptate
server/aptate: server/aptate.in Makefile
	$(do_subst) <$(srcdir)/server/aptate.in >$@
	chmod a+x server/aptate
CLEANFILES += server/aptate
EXTRA_DIST += server/aptate.in

apt4rpm_methods_SCRIPTS = server/methods/script
server/methods/script: server/methods/script.in Makefile
	@$(mkinstalldirs) server/methods
	$(do_subst) <$(srcdir)/server/methods/script.in >$@
	chmod a+x server/methods/script
CLEANFILES += server/methods/script
EXTRA_DIST += server/methods/script.in

apt4rpm_lib_SCRIPTS = server/compare_rpm_version
server/compare_rpm_version: server/compare_rpm_version.in Makefile
	@$(mkinstalldirs) server
	$(do_subst) <$(srcdir)/server/compare_rpm_version.in >$@
	chmod a+x server/compare_rpm_version
CLEANFILES += server/compare_rpm_version
EXTRA_DIST += server/compare_rpm_version.in

apt4rpm_lib_SCRIPTS += config/aptate-convert
config/aptate-convert: config/aptate-convert.in Makefile
	@$(mkinstalldirs) config
	$(do_subst) <$(srcdir)/config/aptate-convert.in >$@
	chmod a+x config/aptate-convert
CLEANFILES += config/aptate-convert
EXTRA_DIST += config/aptate-convert.in

lib/Aptate/Version.pm: lib/Aptate/Version.pm.in Makefile
	@$(mkinstalldirs) lib/Aptate
	$(do_subst) <$(srcdir)/lib/Aptate/Version.pm.in >$@
CLEANFILES += lib/Aptate/Version.pm
EXTRA_DIST += lib/Aptate/Version.pm.in

DISTCLEANFILES = @DOCLINKS@


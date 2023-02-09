Name:		apt4rpm
Summary:	Create an APT repository
Version:	0.69.3
Release:	0
Source:		%{name}-%{version}.tar.bz2
Copyright:	GPL
BuildRoot:	%{_tmppath}/%{name}-%{version}-root
BuildArch:	noarch
URL:            http://apt4rpm.sourceforge.net
Packager:       apt4rpm-devel@lists.sourceforge.net

Requires:	perl-XML-LibXML wget mktemp
BuildRequires:  perl bash

%if "%{_vendor}" == "suse"
Group:		System/Packages
Requires:	apt-server perl-XML-LibXML-Common perl-XML-SAX
BuildRequires:	docbook-toys
%define pkgdocdir	%{_defaultdocdir}/%{name}
%else
Group:		System Environment/Base
%define pkgdocdir	%{_defaultdocdir}/%{name}-%{version}
%endif

%description
This application creates an Advanced Package Tool (APT) 
repository from rpm packages

#----------------------------------------------------------
%prep
%setup

#----------------------------------------------------------
%build
./configure \
  --prefix=%{_prefix} \
  --mandir=%{_mandir} \
  --datadir=%{_datadir} \
  --libdir=%{_libdir} \
  --sysconfdir=%{_sysconfdir} \
  --enable-pkgdocdir=%{pkgdocdir}

# In case you do not get the right sized postscript (or pdf, etc)
# output you can change your LANG variable to for example LANG=C.
# If LANG=C the output will be A4.
make

#----------------------------------------------------------
%install
make DESTDIR=${RPM_BUILD_ROOT} install

#----------------------------------------------------------
%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

#----------------------------------------------------------
%files
%defattr(-,root,root)
%config(noreplace) %{_sysconfdir}/apt/aptate.conf
%{_bindir}/*
%{_mandir}/man?/*
%{_datadir}/apt4rpm
%{_libdir}/apt4rpm

%doc %{pkgdocdir}

%changelog
* Tue Oct 28 2003 Richard Bos <rbos@users.sourceforge.net>
- Updated the group for suse
- check RPM_BUILD_ROOT for "/" during clean up
* Sat Aug 23 2003 R. Bos
- Moved the mktemp dependency from buildrequires to requires
- Added buildrequires docbook-toys jadetex for suse
* Wed Feb 26 2003 R. Bos
- Added mktemp dependency
* Tue Oct 11 2002 R. Bos
- Remove wget requirement (not in case rsync is used e.g.)
* Tue Oct 09 2002 R. Bos
- Add RedHat build requirement
* Tue Jun 04 2002 R. Corsepius
- Add %{_datadir}.
- Add mirrorlist.dtd.
* Tue May 28 2002 R. Corsepius
- Use auto*tools-based configuration
* Mon Feb 25 2002 R Bos
- Added docbook sgml formatted documentation

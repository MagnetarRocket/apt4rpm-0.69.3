# XML parser for converting the xml formatted mirrorfile into
# something that aptate can easily process

# Derived and rewritten based on code from Richard Bos's aptate.pl
# by Ralf Corsepius

# Copyright (C) 2002 Richard Bos
# Copyright (C) 2002,2003,2004 Ralf Corsepius, Ulm, Germany

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

package Aptate::Config;

use strict;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw (distattrs dist query mirror config new
  ActionConfig ActionDist ActionDistAttrs ActionMirror ActionQuery 
  ActionGetSourcesList);

use Aptate::Version;

use XML::LibXML;

sub getrepdir($);
sub getarchdir($$);
sub checkarchdirs($);
sub getsourceslist($$);
sub content_yesno($$);

# Create a parser
sub new($)
{
  my ($infile) = @_;
  my $parser = XML::LibXML->new();

  # This is a validating parser
  $parser->validation(1);
  $parser->expand_entities(1); 
  $parser->complete_attributes(1);
  $parser->keep_blanks(0); # Don't care about blanks

# Parse the file
  my $doc = $parser->parse_file($infile)
    or die "Failed to open $infile.\n";

# Get the root element
  my $root = $doc->documentElement()
    or die "Could not get root node";

  die "illegal document root node <$root->nodeName>\n"
    if ( $root->nodeName ne 'opt' );

  return $doc;
}

sub getrepdir($)
{
  my ($doc) = @_;

  my $repdir;
  if ( !$doc->findnodes( 'opt/repdir' ) ) {
# if repdir is not specified in aptate.conf, default to /apt
          $repdir = '/apt';
  } else {
          $repdir = $doc->findvalue( 'opt/repdir' );
          if ( $repdir =~ /^\/.*/o ) {
            die "<repdir>$repdir</repdir> is not a relative subdirectory\n";
          }
	  if ( $repdir ) {
# if repdir is not empty, prepend / to it.
            $repdir = '/' . $repdir ;
	  }
  }
  return $repdir ;
} 

sub config($)
{
  my ($doc) = @_;

  my %global = (

    BAD_RPMS_MODE	=> sub { $doc->findvalue( 'opt/attribute::bad-rpm-mode')},
    BLOAT 		=> sub { $doc->findvalue( 'opt/attribute::bloat')},
    FOLLOW 		=> sub { $doc->findvalue( 'opt/attribute::follow')},
    UPDATE_RPMS		=> sub { $doc->findvalue( 'opt/attribute::update-rpms')},
    FLAT		=> sub { $doc->findvalue( 'opt/attribute::flat')},
    OLD_HASHFILE	=> sub { $doc->findvalue( 'opt/attribute::old-hashfile')},
    PATCH_RPM_STR	=> sub { $doc->findvalue( 'opt/attribute::patch-rpm-string')},
    VERBOSE		=> sub { $doc->findvalue( 'opt/attribute::verbose')},
    TOPDIR      	=> sub { $doc->findvalue( 'opt/topdir')},
    REPDIR		=> sub { &getrepdir($doc); },
    SHAREDIR		=> sub {
        my $sharedir = $doc->findvalue( 'opt/sharedir' );
	$sharedir = 'apt/share' if ( ! $sharedir );
        if ( $sharedir =~ /^\/.*/o ) {
          return $sharedir;
        } else {
          my $topdir = $doc->findvalue( 'opt/topdir' );
	  return $topdir . '/' . $sharedir ;
        }
      },
    KEY_NAME		=> sub { $doc->findvalue( 'opt/authorization/name')},
    KEY_EMAIL		=> sub { $doc->findvalue( 'opt/authorization/email')},
    MK_PATCH_RPM_COMP	=> sub { $doc->findvalue( 'opt/attribute::patch-rpm-component')},
    MK_SEC_COMP		=> sub { $doc->findvalue( 'opt/attribute::security-component') },
    SIGN		=> sub { $doc->findvalue( 'opt/attribute::sign-repository') },
    SIGNED_PKGS_ONLY	=> sub { $doc->findvalue( 'opt/attribute::signed-pkgs-only') },

    WGET_TRIES		=> sub { int($doc->findvalue('opt/attribute::wget-tries')) },
    WGET_WAIT		=> sub { int($doc->findvalue('opt/attribute::wget-wait')) },
  );

  foreach my $key ( keys %global )
  {
    print $key, "=\"", $global{$key}->(), "\"\n";
  }
} 

sub distattrs($$)
{
  my ($doc, $dva) = @_;

  my $distxpath = 'child::opt'
    . '/child::distribution[attribute::id=\'' . $dva . '\']';
  my @dists = $doc->findnodes( $distxpath )
    or die "invalid distribution $dva\n" ;

  my $patch = $dists[0]->findvalue( 'attribute::patch-rpm-component' );
  if ( not $patch ) {
    $patch = $doc->findvalue( 'opt/attribute::patch-rpm-component' );
  }
  my $security = $dists[0]->findvalue( 'attribute::security-component' );
  if ( not $security ) {
    $security = $doc->findvalue( 'opt/attribute::security-component' );
  }

  print "MK_PATCH_RPM_COMP=", $patch, "\n";
  print "MK_SEC_COMP=", $security, "\n";
  print "ARCH_STRUCTURE=",$dists[0]->findvalue( 'attribute::structure' ),"\n";
}

sub dist($$)
{
  my ($doc, $dva) = @_;

  my $distxpath = 'child::opt'
    . '/child::distribution[attribute::id=\'' . $dva . '\']';
  my @dists = $doc->findnodes( $distxpath )
    or die "invalid distribution $dva\n" ;

  print "VERSION=",$dists[0]->findvalue( 'child::version'),"\n";
  print "ARCH=",$dists[0]->findvalue( 'child::architecture'),"\n";
  print "DIST=",$dists[0]->findvalue( 'child::name'),"\n";
  print "LANGUAGE=",$dists[0]->findvalue( 'child::language'),"\n";
  print "ARCHIVE=",&getarchdir($dists[0],$dva),"\n";
}

sub getarchdir($$)
{
  my ($dist,$dva) = @_;

  my $structure = $dist->findvalue( 'attribute::structure' );

  my $archive = undef ;
  if ( $structure == 1 ) {
    $archive = 
      $dist->findvalue('child::name') . '/' .
      $dist->findvalue('child::version') . '-' . 
      $dist->findvalue('child::architecture');
  } elsif ( $structure == 2 ) {
    $archive = 
      $dist->findvalue('child::name') . '/' . 
      $dist->findvalue('child::version') . '/' . 
      $dist->findvalue('child::architecture');
  } elsif ( $structure == 3 ) {
    die "missing <language> for <distribution> $dva\n"
      if( not $dist->findnodes('child::language') );

    $archive = 
      $dist->findvalue('child::name') . '/' . 
      $dist->findvalue('child::version') . '/' . 
      $dist->findvalue('child::language') . '/' . 
      $dist->findvalue('child::architecture');
  } elsif ( $structure == 4 ) {
    die "missing <archive> for <distribution> $dva\n"
      if( not $dist->findnodes('child::archive') );
    $archive = $dist->findvalue('child::archive') ;
  } else {
    die "invalid structure $structure\n" ;
  }

  $archive =~ s,/+,/,g;
  $archive =~ s,/$,,;

  if ( $archive =~ /^\/.*/o ) {
    die "archive directory $archive for distribution $dva is not a relative subdirectory\n";
  }

  return $archive;
}

sub checkarchdirs($)
{
  my ($doc) = @_;
  my @dists = $doc->findnodes( 'child::opt/child::distribution' );

# archdir -> distid lookup table
  my %arch2id = ();
  foreach my $dist (@dists) {
    my $distid = $dist->findvalue( 'attribute::id' );
    my $archdir = &getarchdir( $dist, $distid );
    if ( $arch2id{$archdir} ) {
# archdir has already been used, complain ...
      print STDERR "distribution $distid: archive directory \"$archdir\",\n" .
        "conflicts with archive directory of distribution: " .
	"\"$arch2id{$archdir}\"\n" ;
      exit(3)
    }
# register archdir/distid
    $arch2id{$archdir} = $distid;
  }
}

# query($doc, $xpath)
sub query($$)
{
  my ($doc,$xpath) = @_;
  my $root = $doc->documentElement()
    or die "Could not get root node\n";

  my $dist = undef ;
  if ( $xpath ne '' )
  {
    my @tmp;
    @tmp = split / /, $xpath;
    $xpath = '';
    for (my $i = 0; $i <= $#tmp; $i++) {
      $xpath = $xpath . '['. $tmp[$i] .']';
    }
  }

  my @dists = $root->findnodes("child::distribution$xpath");
  my @distids = ();
  for my $d ( @dists )
  {
    push @distids, $d->findvalue( 'attribute::id');
  }
  print join( ' ', @distids ),"\n" ;
}

# mirror ($doc,$dva,$updatedir)
sub mirror($$$)
{
  my ($doc,$dva,$updatedir) = @_;

  my $distxpath = 'child::opt'
    . '/child::distribution[attribute::id=\'' . $dva . '\']';
  my @dists = $doc->findnodes( $distxpath )
    or die "invalid distribution $dva\n" ;

  my @confout = ();
  my @ftpdirs;

  my @components = $dists[0]->findnodes( 'child::component' );
  foreach my $c ( @components )
  {
    my $active = lc($c->findvalue( 'attribute::active' ));

    if ( $active eq 'yes' ) {
      my $name = $c->findvalue( 'child::name' );

      my $update_rpms = lc($c->findvalue( 'attribute::update-rpms' ) );
      if ( $update_rpms ne 'yes' ) { $update_rpms = 'no'; }

      my $list_most_recent = lc($c->findvalue( 'attribute::list-most-recent' ) );
      if ( $list_most_recent ne 'no' ) { $list_most_recent = 'yes'; }

      my $scan = lc($c->findvalue( 'attribute::scan' ) );
      if ( $scan ne 'yes' ) { $scan = 'no'; }

      my $add_arg = '';
      my $continue = $c->findvalue( 'wget/attribute::continue' );
      if ( $continue eq 'yes' )
      {
        $add_arg = "-c";
      }

      foreach my $node  ( $c->findnodes( 'wget/child::add-arg' ) )
      {
        $add_arg .= ' ' . $node->textContent(); 
      }

      my $cutdirs = $c->findvalue( 'wget/attribute::cutdirs' );
      if ( $cutdirs eq '' ) {
        $cutdirs = 0;
      } else {
        $cutdirs = int($cutdirs);
      }

      my $url = $c->findvalue( 'child::url' );
      my $method = undef ;
      my @scripts = $c->findnodes( 'script' );
      if ( @scripts )
      {
        $method = 'script';
      }
      else
      {
        $method = $c->findvalue( 'url/attribute::method' );
      }

      my $node;
      my $local_accept = '';
      my $local_reject = '';

      for $node ( $c->findnodes( "child::accept" ) ) {
        if ( $local_accept eq '' ) {
	  $local_accept = $node->textContent;
	} else {
	  $local_accept .= "|" . $node->textContent;
	}
      }

      for my $node ( $c->findnodes( "child::reject" ) ) {
        if ( $local_reject eq '' ) {
	  $local_reject = $node->textContent;
	} else {
	  $local_reject .= "|" . $node->textContent;
	}
      }

      my $srchdir  = '';
      my $excldirs = '';

      if ( $method eq 'ftp' ) {
        # do the equivalent of the bash command:
        #   echo $url | cut -d"/" -f$cutdirs-
        my $n = ( @ftpdirs = split '/', $url );
        $srchdir = join '/', @ftpdirs [$cutdirs+1..$n-1];

        $srchdir = "$updatedir/$srchdir";
        $add_arg = "--no-host-directories --cut-dirs=$cutdirs $add_arg";

        if ( $update_rpms eq 'yes' ) {
          my @excludedirs = $c->findnodes( "wget/child::excludedir" );
          for my $dir (@excludedirs) {
            $excldirs .= $dir->textContent . ",";
          }

          $excldirs =~ s/,+$//;
          if ( $excldirs !~ '^$' ) { $add_arg = '-X '.$excldirs.' '.$add_arg }

        } else {
          $add_arg = '';
        }
      } elsif ( $method eq 'script' ) {
        # $srchdir = "$updatedir/" . $url;
	$srchdir = $url;
      } else {
        # only 2 methods supported: ftp and file
        $srchdir = $url;
        $add_arg = '';
      }

      push @confout, "$name;$method;$update_rpms;$url;$srchdir;$add_arg;$local_accept;$local_reject;$list_most_recent;$scan";
    }
  }
  # The $cnt value is used to uniquely identify a record
  my $cnt = 1;
  for my $line (@confout) {
    print $cnt++ .  ";$line\n"
  }
}

sub getsourceslist($$)
{
  my ($doc,$rep_dir) = @_;

  my %global = (
    PREFIX_FILE		=> sub {
      my $srclist = undef ;
      if ( $doc->findnodes( 'opt/sources-list-file' ) ) {
        # sources-list-file was given, return value
        $srclist = $doc->findvalue( 'opt/sources-list-file');
        if ( ! $srclist ) {
          $srclist = $rep_dir;
        }
      } else 
      { # sources-list-file was not given
        if ( $doc->findnodes( 'opt/sources-list-ftp' )
          or $doc->findvalue( 'opt/sources-list-http') )
        { # ftp or http was given, suppress "file"
          $srclist = '';
        } else {
          # no sources-list was given, default "file" to $rep_dir
          $srclist = $rep_dir;
        }
      }
      return $srclist;
    },
    PREFIX_FTP		=> sub { $doc->findvalue( 'opt/sources-list-ftp')},
    PREFIX_HTTP		=> sub { $doc->findvalue( 'opt/sources-list-http')}
  );

  foreach my $key ( keys %global )
  {
    print $key, "=", $global{$key}->(), "\n";
  }
} 

sub content_yesno($$)
{
  my $node  = shift ;
  my $xpath = shift ;
  my @n = $node->findnodes( $xpath );
  if ( @n ) {
    my $content = uc($node->findvalue( $xpath ));
    if ( $content eq '' ) { $content = 'YES'; };
    return $content ;
  } else {
          return 'NO' ;
  }
}

# ---
sub ActionConfig($)
{
  my ( $infile ) = @_ ;
  my $doc = Aptate::Config::new($infile);
  &Aptate::Config::config($doc);
  &Aptate::Config::checkarchdirs($doc);
}

sub ActionDist($$)
{
  my ( $infile,$dva ) = @_ ;
  my $doc = Aptate::Config::new($infile);
  &Aptate::Config::dist($doc,$dva);
}

sub ActionDistAttrs($$)
{
  my ( $infile,$dva ) = @_ ;
  my $doc = Aptate::Config::new($infile);
  &Aptate::Config::distattrs($doc,$dva);
}

sub ActionMirror($$$)
{
  my ( $infile,$dva,$updatedir ) = @_ ;
  my $doc = Aptate::Config::new($infile);
  &Aptate::Config::mirror($doc,$dva,$updatedir);
}

sub ActionQuery($$)
{
  my ( $infile,$xpath ) = @_ ;
  my $doc = Aptate::Config::new($infile);
  &Aptate::Config::query($doc,$xpath);
}

sub ActionGetSourcesList($$$)
{
  my ( $infile,$dva,$rep_dir ) = @_ ;
  my $doc = Aptate::Config::new($infile);
  &Aptate::Config::getsourceslist($doc,$rep_dir);
}

1;;

# Copyright (C) 2004 Ralf Corsepius, Ulm, Germany

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

#
# Support for repodata repositories (EXPERIMENTAL)
#
# Cf. http://linux.duke.edu/projects/metadata/ and
# http://linux.duke.edu/projects/metadata/generate/
#

package Aptate::Repo;

use strict;

use vars qw(@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw (Repo);

use Cwd;
use XML::LibXML;
use Aptate::Config;

my @dirs = ();

sub pushd($)
{
  my ( $dir ) = ( @_ );
  my $cwd = getcwd();
  push @dirs, $cwd;
  chdir($dir);
}

sub popd()
{
  my $dir = pop @dirs ;
  chdir($dir);
}

# simple path walk
sub which($)
{
  my ( $f ) = @_ ;
  foreach my $p ( split(/:/,$ENV{PATH}) )
  { 
    if ( -x "$p/$f" ) {
      return "$p/$f" ;
    }
  }
  return undef ;
}

sub Repo($$$$$)
{
  # FIXME: We should not use archive_tmp_root.
  #	Instead, we should directly evaluate $infile.

  my ($infile,$distid,$archive_tmp_root,$complist,$verbose) = @_ ;

  if ( ! $complist ) { return 0 ; } # Nothing to do.

  # Check if Repo is enabled?
  my $doc = Aptate::Config::new( $infile );
  my $doyum = $doc->findvalue( "opt/child::distribution[attribute::id=\'$distid\']/attribute::yum" )
    or die "Unable to find attribute yum for <opt><distribution id=\"$distid\">" ;

  # Repo is disabled
  if ( $doyum eq "no" ) { return 0; }

  my $createrepo = which( "createrepo" );
  if ( ! defined $createrepo ) {
    warn "warning: Aptate::Repo.pm: Could not find createrepo.\n" ;
    return -1; 
  } 

  my @components = split(/ /,$complist);
  $createrepo .= " -q ";

  # Flat repository?
  my $flat = $doc->findvalue( 'opt/attribute::flat' );

  if ( ! -d "$archive_tmp_root/yum" ) {
    mkdir ("$archive_tmp_root/yum") 
     || die( "Failed to create $archive_tmp_root/yum");
  }

  printf STDOUT "Creating yum/repodata repositories\n" if ( $verbose );
  foreach my $component ( @components ){

    printf STDOUT " %-16s  -> ", $component if ( $verbose );
    if ( ! -d "$archive_tmp_root/yum/$component" ) {
      mkdir ("$archive_tmp_root/yum/$component") 
        || die( "Failed to create $archive_tmp_root/yum/$component");
    }
    unlink "$archive_tmp_root/yum/$component/RPMS";
    unlink "$archive_tmp_root/yum/$component/SRPMS";

    pushd ( "$archive_tmp_root/yum/$component" );

    symlink ("../../RPMS.$component", "RPMS" )
      || die ("Failed to symlink ../../RPMS.$component RPMS");

    my $archive_tmp_srpms;
    # FIXME: Are non-flat repositories of any importance?
    if ( $flat eq "no" ) {
      $archive_tmp_srpms = "../../../SRPMS.$component";
    } else {
      $archive_tmp_srpms = "../../SRPMS.$component" ;
    }

    if ( -d  $archive_tmp_srpms ) {
      symlink ( $archive_tmp_srpms, "SRPMS" )
        || die ("Failed to symlink $archive_tmp_srpms SRPMS" );
    }

    # Must run in '.', because createrepo up to 0.3.9 is not able to handle 
    # absolute directories containing whitespaces
    my $call = $createrepo . " .";
    system( "$call" ) == 0
      or die ( "Failed to run \'$call\'" );

    popd();

    printf STDOUT "done\n" if ( $verbose );
  } # foreach $component
}

1; # for require

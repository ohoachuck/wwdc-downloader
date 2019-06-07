#! /usr/bin/perl -w
#
# Class name: AvailHelper
# Synopsis: Helper code for availability
#
# Last Updated: $Date: 2014/02/14 17:55:29 $
# 
# Copyright (c) 2006 Apple Computer, Inc.  All rights reserved.
#
# @APPLE_LICENSE_HEADER_START@
#
# This file contains Original Code and/or Modifications of Original Code
# as defined in and that are subject to the Apple Public Source License
# Version 2.0 (the 'License'). You may not use this file except in
# compliance with the License. Please obtain a copy of the License at
# http://www.opensource.apple.com/apsl/ and read it before using this
# file.
# 
# The Original Code and all software distributed under the License are
# distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
# EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
# INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
# Please see the License for the specific language governing rights and
# limitations under the License.
#
# @APPLE_LICENSE_HEADER_END@
#
######################################################################

# /*!
#     @header
#     @abstract
#         Generates hash tables for automatic availability.
#     @discussion
#         This file contains the <code>AvailHelper</code> class, which is used
#         for generating hash tables related to availability
#         macros.
#
#         See the class documentation below for more details.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         <code>AvailHelper</code> Class
#     @discussion
#         The <code>AvailHelper</code> class generates hash tables related
#         to availability macros.
#
#  */
package HeaderDoc::AvailHelper;

my $HD_VERSION_MAX = 100;

BEGIN {
	foreach (qw(Mac::Files)) {
	    $MOD_AVAIL{$_} = eval "use $_; 1";
    }
}
use HeaderDoc::HeaderElement;
use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash sanitize);
use File::Basename;
use Cwd;
use Carp qw(cluck);

use strict;
use vars qw(@ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::AvailHelper::VERSION = '$Revision: 1392429329 $';

# Inheritance
# @ISA = qw(HeaderDoc::HeaderElement);
################ Portability ###################################
my $isMacOS;
my $pathSeparator;
if ($^O =~ /MacOS/io) {
	$pathSeparator = ":";
	$isMacOS = 1;
} else {
	$pathSeparator = "/";
	$isMacOS = 0;
}
################ General Constants ###################################
my $debugging = 0;
my $theTime = time();
my ($sec, $min, $hour, $dom, $moy, $year, @rest);
($sec, $min, $hour, $dom, $moy, $year, @rest) = localtime($theTime);
# $moy++;
$year += 1900;
my $dateStamp = HeaderDoc::HeaderElement::strdate($moy, $dom, $year, "UTF-8");
######################################################################

my $depth = 0;

# /*!
#     @abstract
#         Creates a new <code>AvailHelper</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::AvailHelper->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param; 
    my $self = {}; 
    
    bless($self, $class);
    $self->_initialize();
    return($self);
} 

# class variables and accessors
{
    my $_versionHash = _initVersionHash();
    my $_versionStringHash = _initVersionStringHash();

    # /*!
    #     @abstract
    #         Initializes an instance of an <code>AvailHelper</code> object.
    #     @param self
    #         The object to initialize.
    #  */
    sub _initialize
    {
	my ($self) = shift;
    }

    # /*!
    #     @abstract
    #         Initializes and returns a hash that maps availabity
    #               tokens to version numbers.
    #  */
    sub _initVersionHash()
    {
	my %hash = ();
	my $x = 0;
	while ($x <= $HD_VERSION_MAX) {
		my $string = "MAC_OS_X_VERSION_10_".$x;
		my $value = 1000 + (10 * $x);
		# print STDERR "STRING: $string VALUE: $value\n";
		$hash{$string} = $value;
		$x++;
	}
	return \%hash;
    }

    # /*!
    #     @abstract
    #         Initializes and returns a hash that maps version
    #         numbers to human-readable availability strings.
    #  */
    sub _initVersionStringHash()
    {
	my %hash = ();
	my $x = 0;
	while ($x <= $HD_VERSION_MAX) {
		my $string = "Mac OS X v10.".$x;
		my $value = 1000 + (10 * $x);
		$hash{$value} = $string;
		$x++;
	}
	return \%hash;
    }

    # /*!
    #     @abstract
    #         Converts an availability token to a version number.
    #     @param self
    #         An <code>AvailHelper</code> object.
    #     @param string
    #         The version token to convert into a version
    #         number code.
    #  */
    sub versionnum
    {
	my $self = shift;
	my $string = shift;
	my %hash = %{$_versionHash};

	if (defined($hash{$string})) {
		return $hash{$string};
	}
	return $string;
    }


    # /*!
    #     @abstract
    #         Converts a version number to a human-readable availability string.
    #     @param self
    #         An <code>AvailHelper</code> object.
    #     @param num
    #         The version number code to convert into a version string.
    #  */
    sub versionstring
    {
	my $self = shift;
	my $num = shift;
	my %hash = %{$_versionStringHash};

	if (defined($hash{$num})) {
		return $hash{$num};
	}
	return "";
    }
}

# /*!
#     @abstract
#         Tears apart an availbility macro token string and
#         converts to a human-readable availability string.
#     @param self
#         An <code>AvailHelper</code> object.
#     @param string
#         A simple availability string (the ones without arguments).
#     @param fullpath
#         The path of the file where this string appears.
#     @param line
#         The line number in the file where this string appears.
#  */
sub parseString
{
	my $self = shift;
	my $string = shift;
	my $fullpath = shift;
	my $line = shift;

	my $localDebug = 0;

	print STDERR "STRING WAS \"$string\".\n" if ($localDebug);

	my $minver = "";
	my $minop = "";
	my $minrev = 0;
	if ($string =~ /MAC_OS_X_VERSION_MIN_REQUIRED\s*([<>=!]+)\s*(\w+)/) {
		$minop = $1;
		$minver = $2;
		$minrev = 0;
	}
	if ($string =~ /(\w+)\s*([<>=!]+)\s*MAC_OS_X_VERSION_MIN_REQUIRED/) {
		$minop = $2;
		$minver = $1;
		$minrev = 1;
	}
	my $maxver = "";
	my $maxop = "";
	my $maxrev = 0;
	# print STDERR "STRING: $string\n";
	if ($string =~ /MAC_OS_X_VERSION_MAX_ALLOWED\s*([<>=!]+)\s*(\w+)/) {
		$maxop = $1;
		$maxver = $2;
		$maxrev = 0;
		# print STDERR "FOUND MAC_OS_X_VERSION_MAX_ALLOWED \"$1\" \"$2\"";
	}
	if ($string =~ /(\w+)\s*([<>=!]+)\s*MAC_OS_X_VERSION_MAX_ALLOWED/) {
		$maxop = $2;
		$maxver = $1;
		$maxrev = 1;
		# print STDERR "FOUND MAC_OS_X_VERSION_MAX_ALLOWED $2 $1";
	}
	if ($minrev) {
		if ($minop eq "<") { $minop = ">"; }
		elsif ($minop eq "<=") { $minop = ">="; }
		elsif ($minop eq ">") { $minop = "<"; }
		elsif ($minop eq ">=") { $minop = "<="; }
	}
	if ($maxrev) {
		if ($maxop eq "<") { $maxop = ">"; }
		elsif ($maxop eq "<=") { $maxop = ">="; }
		elsif ($maxop eq ">") { $maxop = "<"; }
		elsif ($maxop eq ">=") { $maxop = "<="; }
	}

	# print STDERR "MINVER: $minver OP: $minop REV: $minrev\n";
	# print STDERR "MAXVER: $maxver OP: $maxop REV: $maxrev\n";

	$string = "";
	if (length($maxver)) {
		# print STDERR "MAXVER: $maxver OP: $maxop REV: $maxrev\n";
		if ($maxop eq ">" || $maxop eq ">=") {
			my $val = $self->versionnum($maxver); # convert to num if needed
			if ($maxop eq ">") {
				$val += 10; # available in next version.
			}
			my $name = $self->versionstring($val); # convert to string
			if ($name ne "") {
				if (length($string)) { $string .= "  "; }
				$string .= "Introduced in ".$name.";";
			} else {
				warn "Could not get name for $maxver ($val)!\n";
			}
		} else {
			warn "$fullpath:$line:Unsupported use of MAC_OS_X_VERSION_MAX_ALLOWED!\n";
		}
	}
	if (length($minver)) {
		# print STDERR "MINVER: $minver OP: $minop REV: $minrev\n";
		if ($minop eq "<" || $minop eq "<=") {
			my $val = $self->versionnum($minver); # convert to num if needed

			if ($minop eq "<") {
				$val -= 10; # depreated in previous version.
			}
			my $name = $self->versionstring($val); # convert to string
			if ($name ne "") {
				if (length($string)) { $string .= "  "; }
				$string .= "Removed in ".$name.";";
			} else {
				warn "Could not get name for $minver ($val)!\n";
			}
		} else {
			warn "$fullpath:$line:Unsupported use of MAC_OS_X_VERSION_MIN_REQUIRED!\n";
		}
	}
	print STDERR "Returning availability string \"$string\".\n" if ($localDebug);
	return $string;
}


1;


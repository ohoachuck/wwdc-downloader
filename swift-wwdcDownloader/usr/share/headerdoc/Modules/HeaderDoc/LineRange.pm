#! /usr/bin/perl -w
#
# Class name: LineRange
# Synopsis: Helper code for availability (line ranges)
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

# /*! @header
#     @abstract
#         <code>LineRange</code> class package file.
#     @discussion
#         This file contains the <code>LineRange</code> class, a class for
#         storing a range of (raw) lines from a header file.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Describes a range of lines in a header file.
#     @discussion
#         The <code>LineRange</code> class stores a range of (raw) lines from a
#         header file, along with information about the line numbers
#         that they came from within the header.  This is used to simplify
#         handling of <code>#if</code> directives.
#     @var _start
#         The starting line number.
#     @var _end
#         The ending line number.
#     @var _text
#         A string containing the raw source code from this range
#         of lines.
#  */
package HeaderDoc::LineRange;

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
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::LineRange::VERSION = '$Revision: 1392429329 $';

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
#         Creates a new <code>LineRange</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::LineRange->new()</code> to allocate
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
    # /*!
    #     @abstract
    #         Initializes an instance of a <code>LineRange</code> object.
    #     @param self
    #         The object to initialize.
    #  */
    sub _initialize
    {
	my ($self) = shift;
	$self->{_start} = 0;
	$self->{_end} = 0;
	$self->{_text} = "";
    }

    # /*! @abstract
    #         Getter/setter for the start of the range.
    #     @param self
    #         This <code>LineRange</code> object.
    #  */
    sub start
    {
	my ($self) = shift;
	if (@_) {
		$self->{_start} = shift;
	}
	return $self->{_start};
    }

    # /*! @abstract
    #         Getter/setter for the end of the range.
    #     @param self
    #         This <code>LineRange</code> object.
    #  */
    sub end
    {
	my ($self) = shift;
	if (@_) {
		$self->{_end} = shift;
	}
	return $self->{_end};
    }

    # /*!
    #     @abstract
    #         Getter/setter for text derived from range.
    #     @discussion
    #         Basically, this is the result of parsing
    #         availabilty macros and similar. */
    sub text
    {
	my ($self) = shift;
	if (@_) {
		$self->{_text} = shift;
	}
	return $self->{_text};
    }

    # /*!
    #     @abstract
    #         Returns whether the specified line number falls within this
    #         <code>LineRange</code>.
    #     @param line
    #         The line number to check.
    #  */
    sub inrange
    {
	my ($self) = shift;
	my $line = shift;

	my $localDebug = 0;

	print STDERR "START: ".$self->{_start}." END: ".$self->{_end}." VAL: $line\n" if ($localDebug);

	if ($line < $self->{_start}) {
		print STDERR "LT\n" if ($localDebug);
		return 0;
	}
	if ($line > $self->{_end}) {
		print STDERR "GT\n" if ($localDebug);
		return 0;
	}
	print STDERR "INRANGE\n" if ($localDebug);
	return 1;
    }
}

1;


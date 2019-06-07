#! /usr/bin/perl -w
#
# Class name: CPPClass
# Synopsis: Holds comments pertaining to a C++ class, as parsed by HeaderDoc
# from a C++ header
#
# Last Updated: $Date: 2011/02/18 19:02:57 $
# 
# Copyright (c) 1999-2004 Apple Computer, Inc.  All rights reserved.
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
BEGIN {
	foreach (qw(Mac::Files)) {
	    $MOD_AVAIL{$_} = eval "use $_; 1";
    }
}

# /*!
#     @header
#     @abstract
#         <code>CPPClass</code> class package file.
#     @discussion
#         This file contains the <code>CPPClass</code> class.  This class
#         is used to represent classes, modules, and packages
#         in every supported language except Objective-C.
#
#         See the class documentation below for more details.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that describes most classes, modules, and packages.
#     @discussion
#         This class is used to represent classes, modules,
#         and packages in every supported language except
#         Objective-C.
#
#         This class is also used to represent COM interfaces
#         in C.
#     @var ISCOMINTERFACE
#         Set high (1) if this object represents a C COM interface, else low (0).
#  */
package HeaderDoc::CPPClass;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash sanitize);
use HeaderDoc::APIOwner;

use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::CPPClass::VERSION = '$Revision: 1298084577 $';

# Inheritance
@ISA = qw( HeaderDoc::APIOwner );
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
my $tracing = 0;
my $outputExtension = ".html";
my $tocFrameName = "toc.html";
# my $theTime = time();
# my ($sec, $min, $hour, $dom, $moy, $year, @rest);
# ($sec, $min, $hour, $dom, $moy, $year, @rest) = localtime($theTime);
# $moy++;
# $year += 1900;
# my $dateStamp = "$moy/$dom/$year";
######################################################################

# /*!
#     @abstract
#         Initializes an instance of a <code>CPPClass</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    $self->tocTitlePrefix('Class:');
    $self->{ISCOMINTERFACE} = 0;
    $self->{CLASS} = "HeaderDoc::CPPClass";
}

# /*!
#     @abstract
#         Duplicates this <code>CPPClass</code> object into another one.
#     @param self
#                The object to clone.
#     @param clone
#                The victim object.
#  */
sub clone {
    my $self = shift;
    my $clone = undef;
    if (@_) {
	$clone = shift;
    } else {
	$clone = HeaderDoc::CPPClass->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    $clone->{ISCOMINTERFACE} = $self->{ISCOMINTERFACE};
    return $clone;
}

# /*!
#     @abstract
#         Gets/sets whether this class is a COM interface (0/1).
#  */
sub isCOMInterface {
    my $self = shift;

    if (@_) {
	$self->{ISCOMINTERFACE} = shift;
    }

    return $self->{ISCOMINTERFACE};
}

# we add the apple_ref markup to the navigator comment to identify
# to Project Builder and other applications indexing the documentation
# that this is the entry point for documentation for this class
# /*!
#     @abstract
#         Returns a comment marker for
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}.
#     @discussion
#         Returns an HTML comment that identifies the index file
#         (Header vs. Class, name, and so on).  The
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}
#         tool uses this information to create a master TOC for the
#         generated doc.
#     @param self
#         The APIOwner object.
# */
sub docNavigatorComment {
    my $self = shift;
    my $name = $self->name();
    $name =~ s/;//sgo;
    # my $uid = "//apple_ref/cpp/cl/$name";
    my $type = "cl";

    if ($self->fields()) {
	# $uid = "//apple_ref/cpp/tmplt/$name";
	$type = "tmpl";
    }
    # registerUID($uid);

    my $uid = $self->apiuid($type);

    my $indexgroup = $self->indexgroup(); my $igstring = "";
    if (length($indexgroup)) { $igstring = "indexgroup=$indexgroup;"; }

    my $appleRef = "<a name=\"$uid\"></a>";
    my $navComment = "<!-- headerDoc=cl; uid=$uid; $igstring name=$name-->";
    
    return "$navComment\n$appleRef";
}


##################### Debugging ####################################

# /*! @abstract
#         Prints this object for debugging.
#     @param self
#         The <code>CPPClass</code> object.
#  */
sub printObject {
    my $self = shift;
 
    $self->SUPER::printObject();
    print STDERR "CPPClass\n";
    print STDERR "\n";
}

1;


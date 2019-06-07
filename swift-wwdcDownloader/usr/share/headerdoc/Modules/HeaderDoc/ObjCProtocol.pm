#! /usr/bin/perl -w
#
# Class name: ObjCProtocol
# Synopsis: Holds comments pertaining to an ObjC protocol, as parsed by HeaderDoc
# from an objC header
#
# Initial modifications: SKoT McDonald <skot@tomandandy.com> Aug 2001
#
# Last Updated: $Date: 2011/02/18 19:02:58 $
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

# /*! @header
#     @abstract
#         <code>ObjCProtocol</code> class package file.
#     @discussion
#         This file contains the <code>ObjCProtocol</code> class, a class for content
#         relating to an Objective-C protocol.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */
# /*!
#     @abstract
#         API object that describes an Objective-C protocol.
#     @discussion
#         The <code>ObjCProtocol</code> class stores information relating to an
#         Objective-C protocol.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCContainer ObjCContainer},
#         which is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner},
#         which is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found in
#         those two classes.
#  */
package HeaderDoc::ObjCProtocol;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash);
use HeaderDoc::ObjCContainer;

# Inheritance
@ISA = qw( HeaderDoc::ObjCContainer );

use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::ObjCProtocol::VERSION = '$Revision: 1298084578 $';

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
#         Initializes an instance of a <code>ObjCProtocol</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    $self->tocTitlePrefix('Protocol:');
    $self->{CLASS} = "HeaderDoc::ObjCProtocol";
}


# we add the apple_ref markup to the navigator comment to identify
# to Project Builder and other applications indexing the documentation
# that this is the entry point for documentation for this protocol
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
    my $uid = $self->apiuid("intf"); # "//apple_ref/occ/intf/$name";

    my $indexgroup = $self->indexgroup(); my $igstring = "";
    if (length($indexgroup)) { $igstring = "indexgroup=$indexgroup;"; }

    my $navComment = "<!-- headerDoc=intf; uid=$uid; $igstring name=$name-->";
    my $appleRef = "<a name=\"$uid\"></a>";
    
    return "$navComment\n$appleRef";
}

1;


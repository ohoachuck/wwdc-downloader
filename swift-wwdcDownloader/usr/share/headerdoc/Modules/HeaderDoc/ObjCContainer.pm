#! /usr/bin/perl -w
#
# Class name: ObjCContainer
# Synopsis: Container for doc declared in an Objective-C interface.
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
#         <code>ObjCContainer</code> class package file.
#     @discussion
#         This file contains the <code>ObjCContainer</code> class, a class for content
#         relating to an Objective-C class, category, or protocol.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */
# /*!
#     @abstract
#         Intermediate API object base class for Objective-C
#         classes, categories, and protocols.
#     @discussion
#         This class is subclassed by
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCClass ObjCClass},
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCCategory ObjCCategory}, and
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCProtocol ObjCProtocol}.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner},
#         which is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found in
#         those two classes.
#
#     This API object type should never actually be emitted as output; only
#     its subclasses are relevant.
#  */
package HeaderDoc::ObjCContainer;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash);
use HeaderDoc::APIOwner;

# Inheritance
@ISA = qw( HeaderDoc::APIOwner );

use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::ObjCContainer::VERSION = '$Revision: 1298084578 $';

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
#         Initializes an instance of a <code>ObjCContainer</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    $self->tocTitlePrefix('Class:');
    $self->{CLASS} = "HeaderDoc::ObjCContainer";
}

# /*!
#     @abstract
#         Returns +/- depending on whether a
#         method is a class method or instance method.
#     @param self
#         This ObjC class, category, or protocol object.
#     @param obj
#         The method object to check.
#  */
sub getMethodPrefix {
    my $self = shift;
	my $obj = shift;
	my $prefix;
	my $type;
	
	$type = $obj->isInstanceMethod();
	
	if ($type =~ /YES/o) {
	    $prefix = "- ";
	} elsif ($type =~ /NO/o) {
	    $prefix = "+ ";
	} else {
	    $prefix = "";
	}
	
	return $prefix;
}

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
    
    return "<!-- headerDoc=cl; name=$name-->";
}

################## Misc Functions ###################################

# /*!
#     @abstract
#         Sets the list of protocols to which this class
#         conforms.
#  */
sub conformsToList {
    my $self = shift;
    my $string = shift;
    my $localDebug = 0;

    print STDERR "ObjC object ".$self->name." conforms to: ".$string."\n" if ($localDebug);
    $string =~ s/\s*//sg;
    $string =~ s/,/\cA/g;

    if ($string ne "") {
	$self->attribute("Conforms&nbsp;to", $string, 0, 1);
    }
}

##################### Debugging ####################################

# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         This object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "------------------------------------\n";
    print STDERR "ObjCContainer\n";
    print STDERR "    - no ivars\n";
    print STDERR "Inherits from:\n";
    $self->SUPER::printObject();
}

1;

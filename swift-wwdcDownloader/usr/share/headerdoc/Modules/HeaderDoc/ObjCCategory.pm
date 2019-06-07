#! /usr/bin/perl -w
#
# Class name: ObjCCategory
# Synopsis: Holds comments pertaining to an ObjC category, as parsed by HeaderDoc
# from an ObjC header
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
#         <code>ObjCCategory</code> class package file.
#     @discussion
#         This file contains the <code>ObjCCategory</code> class, a class for content
#         relating to an Objective-C category.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */
# /*!
#     @abstract
#         API object that describes an Objective-C category.
#     @discussion
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCContainer ObjCContainer},
#         which is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner},
#         which is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found in
#         those two classes.
#  */
package HeaderDoc::ObjCCategory;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash registerUID unregisterUID);
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
$HeaderDoc::ObjCCategory::VERSION = '$Revision: 1298084578 $';

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
#         Initializes an instance of a <code>ObjCCategory</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
	$self->SUPER::_initialize();
    $self->tocTitlePrefix('Category:');
    $self->{CLASS} = "HeaderDoc::ObjCCategory";
}

# /*!
#     @abstract
#         Splits the raw name out into separate class and
#         category fields.  Returns the class name portion.
#     @param self
#         This object.
#  */
sub className {
    my $self = shift;
    my ($className, $categoryName) = &getClassAndCategoryName($self->name(), $self->fullpath(), $self->linenum());
    return $className;
}

# /*!
#     @abstract
#         Splits the raw name out into separate class and
#         category fields.  Returns the category name portion.
#     @param self
#         This object.
#  */
sub categoryName {
    my $self = shift;
    my ($className, $categoryName) = &getClassAndCategoryName($self->name(), $self->fullpath(), $self->linenum());
    return $categoryName;
}

# we add the apple_ref markup to the navigator comment to identify
# to gatherHeaderDoc, Xcode, and other applications indexing the documentation
# that this is the entry point for documentation for this category
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

    my $olduid = $self->apiuid();
    
    # regularize name by removing spaces and semicolons, if any
    $name =~ s/\s+//go;
    $name =~ s/;//sgo;

    my $indexgroup = $self->indexgroup(); my $igstring = "";
    if (length($indexgroup)) { $igstring = "indexgroup=$indexgroup;"; }
    
    my $uid = $self->apiuid("cat"); # "//apple_ref/occ/cat/$name";
    my $navComment = "<!-- headerDoc=cat; uid=$uid; $igstring name=$name-->";
    my $appleRef = "<a name=\"$uid\"></a>";

    unregisterUID($olduid, $name, $self);
    registerUID($uid, $name, $self);
    
    return "$navComment\n$appleRef";
}

################## Misc Functions ###################################

# /*!
#     @abstract
#         Splits the raw name out into separate class and
#         category fields.  Returns them in an array.
#     @param fullName
#         The full name line for this category (from a call to
#         <code>$self->name()</code>).
#     @param fullpath
#         The full path of this header (from a call to
#         <code>$self->fullpath()</code>).
#     @param linenum
#         The line number of this object (from a call to
#         <code>$self->linenum()</code>).
#  */
sub getClassAndCategoryName {
    my $fullName = shift;
    my $className = '';
    my $categoryName = '';
    my $fullpath = shift; # $HeaderDoc::headerObject->fullpath();
    my $linenum = shift; 

    if ($fullName =~ /(\w+)\s*(\((.*)\))?/o) {
    	$className = $1;
    	$categoryName =$3;
    	if (!length ($className)) {
            print STDERR "$fullpath:$linenum: warning: Couldn't determine class name from category name '$fullName'.\n";
    	}
    	if (!length ($categoryName)) {
            print STDERR "$fullpath:$linenum: warning: Couldn't determine category name from category name '$fullName'.\n";
    	}
    } else {
        print STDERR "$fullpath:$linenum: warning: Specified category name '$fullName' isn't complete. Expecting a name of the form 'MyClass(CategoryName)'\n";
    }
    return ($className, $categoryName);
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
    my $className = $self->className();
    my $categoryName = $self->categoryName();
 
    print STDERR "------------------------------------\n";
    print STDERR "ObjCCategory\n";
    print STDERR "    associated with class: $className\n";
    print STDERR "    category name: $categoryName\n";
    print STDERR "Inherits from:\n";
    $self->SUPER::printObject();
}

1;


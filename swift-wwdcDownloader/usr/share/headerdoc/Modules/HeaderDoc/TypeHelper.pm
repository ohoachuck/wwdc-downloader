#! /usr/bin/perl -w
#
# Class name: TypeHelper
# Synopsis: Helper code for block parser data type returns
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
#         <code>TypeHelper</code> class package file.
#     @discussion
#         This file contains the <code>TypeHelper</code> class, a data
#         structure for passing around a combination of name and
#         HeaderDoc object type data.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc Parser Pieces
#  */

# /*!
#     @abstract
#         Describes the names and declaration types for a
#         declaration.
#     @discussion
#         
#         The <code>TypeHelper</code> class is a data structure for passing

#         around  a combination of name and HeaderDoc object type
#         data.  It is primarily used in the interface between the
#         {@link blockParseReturnState} and {@link blockParseOutside}
#         functions in the
#         {@link //apple_ref/perl/cl/HeaderDoc::BlockParse BlockParse}
#         class.
#
#         The reason for this class is that some C data types are
#         relatively complex.  A <code>typedef struct</code> can
#         have multiple comma-separated names at the end that are
#         <code>type</code> names, plus a name at the beginning that
#         is a <code>struct</code>.  Thus, that single declaration
#         has multiple names, each of which has a list of symbol
#         types that can legally match against that name.
#
#     @var NAME
#         The name parsed from the declaration.
#     @var TYPE
#         The primary (outer) type parsed from the declaration.
#     @var STARS
#         The number of leading '*' characters before this particular
#         name.  For example, <code>char *k</code> would have:
#
#         <ul><li><code>char</code> in the <code>TYPE</code> field,</li>
#
#         <li><code>k</code> in the <code>NAME</code> field, and</li>
#
#         <li><code>*</code> in the <code>STARS</code> field.</li></ul>
#     @var POSSTYPES
#         A list of possible types for this name.  (For example, a
#         function matches with either the <code>\@function</code>
#         or <code>\@method</code>  tag in a HeaderDoc comment.
#     @var EXTENDSCLASS
#         The name of the class that this one extends (if applicable).
#     @var IMPLEMENTSCLASS
#         The name of the abstract class that this class implements
#         (if applicable).
#     @var INSERTEDAT
#         A string that tells where in {@link blockParseReturnState}
#         that this name object was created.
#     @var ACTIVE
#         Used in {@link blockParseOutside} to avoid interpretation of
#         a name object more than once.
#  */
package HeaderDoc::TypeHelper;

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
$HeaderDoc::TypeHelper::VERSION = '$Revision: 1392429329 $';

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
#         Creates a new <code>TypeHelper</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::TypeHelper->new()</code> to allocate
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
    #         Initializes an instance of a <code>TypeHelper</code> object.
    #     @param self
    #         The object to initialize.
    #  */
    sub _initialize
    {
	my ($self) = shift;
	$self->{NAME} = 0;
	$self->{TYPE} = 0;
	$self->{POSSTYPES} = "";
    }
}

1;


#! /usr/bin/perl -w
#
# Class name: 	IncludeHash
# Synopsis: 	Used by headerDoc2HTML.pl to hold include info
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

# /*! @header
#     @abstract
#         <code>IncludeHash</code> class package file.
#     @discussion
#         This file contains the <code>IncludeHash</code> class.  It is used
#         as a data structure for keeping track of where #include
#         directives appear within a header file.
#
#         See the class documentation below for details.
#     @indexgroup HeaderDoc Parser Pieces
#  */

# /*! @abstract
#         Stores the content and line number of an include directive.
#     @discussion
#         The <code>IncludeHash</code> class is basically used as a data structure
#         without accessor methods.
#
#         This class stores where a particular #include
#         directive appears within a header file.  Each header
#         file has an array containing one <code>IncludeHash</code>
#         instance for each header that it includes.
#
#     @var FILENAME
#         The filename (and leading path parts) included
#         at a particular line number.
#     @var LINENUM
#         The line number at which the include statement
#         appears.
#     @var HASHREF
#         The <code>HeaderDoc::HeaderFileCPPHashHash</code>
#         hash for the file specified by <code>FILENAME</code>,
#         which in turn comes from the <code>CPP_HASH</code> in
#  {@link //apple_ref/perl/cl/HeaderDoc::BlockParse BlockParse}.
#         This includes the C preprocessor tokens defined by
#         the file in question.
#  */
package HeaderDoc::IncludeHash;

use strict;
use vars qw($VERSION @ISA);
use HeaderDoc::Utilities qw(isKeyword );

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::IncludeHash::VERSION = '$Revision: 1298084578 $';
################ General Constants ###################################
my $debugging = 0;

my $treeDebug = 0;

# /*!
#     @abstract
#         Creates a new <code>IncludeHash</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::IncludeHash->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param;
    my $self = {};
    
    bless($self, $class);
    $self->_initialize();
    # Now grab any key => value pairs passed in
    my (%attributeHash) = @_;
    foreach my $key (keys(%attributeHash)) {
        $self->{$key} = $attributeHash{$key};
    }  
    return ($self);
}

# /*!
#     @abstract
#         Initializes an instance of an <code>IncludeHash</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;

    $self->{FILENAME} = undef;
    $self->{LINENUM} = undef;
    $self->{HASHREF} = undef;

    return $self;
}

1;

#! /usr/bin/perl
#
# Class name: Struct
# Synopsis: Holds struct info parsed by headerDoc
#
# Last Updated: $Date: 2011/02/18 19:02:59 $
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
#         <code>Struct</code> class package file.
#     @discussion
#         This file contains the <code>Struct</code> class, a class for content
#         relating to a data structure declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that that describes a data structure
#         (<code>struct</code> or <code>record</code>).
#     @discussion
#         The <code>Struct</code> class stores information relating to a data
#         structure declaration.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#     @var ISUNION
#         Holds 1 if this object holds a union, 0 if it holds a struct.
#         See {@link isUnion}.
#     @var FIELDS
#         An array of fields in this structure.
#         See {@link //apple_ref/perl/instm/HeaderDoc::Struct/fields//() fields}.
#  */
package HeaderDoc::Struct;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;
use HeaderDoc::MinorAPIElement;
use HeaderDoc::APIOwner;

@ISA = qw( HeaderDoc::HeaderElement );

use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::Struct::VERSION = '$Revision: 1298084579 $';

use strict;


# /*!
#     @abstract
#         Initializes an instance of a <code>Struct</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    # $self->{ISUNION} = 0;
    $self->{FIELDS} = ();
    $self->{CLASS} = "HeaderDoc::Struct";
}

# /*!
#     @abstract
#         Duplicates this <code>Struct</code> object into another one.
#     @param self
#         The object to clone.
#     @param clone
#         The victim object.
#  */
sub clone {
    my $self = shift;
    my $clone = undef;
    if (@_) {
	$clone = shift;
    } else {
	$clone = HeaderDoc::Struct->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to function

    $clone->{ISUNION} = $self->{ISUNION};
    $clone->{FIELDS} = $self->{FIELDS};

    return $clone;
}

# /*!
#     @abstract
#         Gets/sets whether this is actually a union.
#     @param self
#         This object.
#     @param isunion
#         The value to set. (Optional.)
#     @discussion
#         The same HeaderDoc class is used for both struct
#         and union declarations.  This allows you to tell
#         one from the other.
#  */
sub isUnion {
    my $self = shift;
    if (@_) {
	$self->{ISUNION} = shift;
    }
    return $self->{ISUNION};
}

# /*! @abstract
#         Gets/sets the array of fields that are associated with a
#         struct or union.
#     @param self
#         This object.
#     @param VARS
#         The array value to set. (Optional)
#  */
sub fields {
    my $self = shift;
    if (@_) { 
        @{ $self->{FIELDS} } = @_;
    }
    ($self->{FIELDS}) ? return @{ $self->{FIELDS} } : return ();
}

# /*!
#     @abstract
#         Sets the declaration.
#     @param self
#         This object.
#     @param declaration
#         The line array.
#  */
sub setDeclaration {
    my $self = shift;
    my $dec = shift;
    my $localDebug = 0;
    $self->declaration($dec);
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw declaration is: $dec\n" if ($localDebug);

    # my $newdec = $self->structformat($dec, 1);
    
    # print STDERR "new dec is:\n$newdec\n" if ($localDebug);
    # $dec = $newdec;

    if (length ($dec)) {$dec = "<pre>\n$dec</pre>\n";};
    
    print STDERR "Struct: returning declaration:\n\t|$dec|\n" if ($localDebug);
    print STDERR "============================================================================\n" if ($localDebug);
    $self->declarationInHTML($dec);
    return $dec;
}


# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         This object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "Struct\n";
    $self->SUPER::printObject();
    print STDERR "Fields:\n";
    my $fieldArrayRef = $self->{FIELDS};
    if ($fieldArrayRef) {
	my $arrayLength = @{$fieldArrayRef};
	if ($arrayLength > 0) {
            &printArray(@{$fieldArrayRef});
	}
    }
    print STDERR "\n";
}

1;


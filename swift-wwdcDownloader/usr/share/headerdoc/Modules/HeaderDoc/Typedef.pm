#! /usr/bin/perl
#
# Class name: Typedef
# Synopsis: Holds typedef info parsed by headerDoc
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
#         <code>Typedef</code> class package file.
#     @discussion
#         This file contains the <code>Typedef</code> class, a class for content
#         relating to a type definition declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that that describes a type declaration.
#     @discussion
#         The <code>Typedef</code> class stores information relating to a type definition
#         declaration.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#     @var FIELDS
#         An array of fields in this structure.
#         See {@link //apple_ref/perl/instm/HeaderDoc::Typedef/fields//() fields}.
#     @var RESULT
#         The contents of the <code>\@result</code> or <code>\@return(s)</code>
#         tags.
#     @var ISFUNCPTR
#         Contains 1 if this is a function pointer.  See
#         {@link isFunctionPointer}.
#     @var ISENUMLIST
#         Contains 1 if this is an enumeration.  See
#         {@link isEnumList}.
#  */
package HeaderDoc::Typedef;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;
use HeaderDoc::MinorAPIElement;
use HeaderDoc::APIOwner;
use Carp qw(cluck);

@ISA = qw( HeaderDoc::HeaderElement );

use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::Typedef::VERSION = '$Revision: 1298084579 $';


# /*!
#     @abstract
#         Initializes an instance of a <code>Typedef</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    # $self->{RESULT} = undef;
    $self->{FIELDS} = ();
    # $self->{ISFUNCPTR} = 0;
    # $self->{ISENUMLIST} = 0;
    $self->{CLASS} = "HeaderDoc::Typedef";
}

# /*!
#     @abstract
#         Duplicates this <code>Typedef</code> object into another one.
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
	$clone = HeaderDoc::Typedef->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to function

    $clone->{RESULT} = $self->{RESULT};
    $clone->{FIELDS} = $self->{FIELDS};
    $clone->{ISFUNCPTR} = $self->{ISFUNCPTR};
    $clone->{ISENUMLIST} = $self->{ISENUMLIST};

    return $clone;
}

# /*! @abstract
#         Gets/sets the array of fields that are associated with a
#         struct or union (in a typedef).
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

# /*! @abstract
#         Gets/sets a flag indicating that this typedef
#         contains an enumeration (or at least is marked up
#         with <code>\@const</code> or <code>\@constant</code>
#         tags in the comment).
#     @param self
#         This object.
#     @param ISENUMLIST
#         The value to set. (Optional)
#     @result
#         Returns 0 or 1.
#  */
sub isEnumList {
    my $self = shift;

    if (@_) {
        $self->{ISENUMLIST} = shift;
    }
    return $self->{ISENUMLIST};
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
    my $decType;
    my $localDebug = 0;
    my $fullpath = $self->fullpath();
    my $linenum = $self->linenum();

	# print STDERR "SETDEC: $self: $dec\n";

    if ($self->isFunctionPointer() && $dec =~ /typedef(\s+\w+)*\s+\{/o) {
	# Somebody put in an @param instead of an @field
	$self->isFunctionPointer(0);
	warn("$fullpath:$linenum: warning: typedef markup invalid. Non-callback typedefs should use \@field, not \@param.\n");
    }

    $self->declaration($dec);

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
 
    print STDERR "Typedef\n";
    $self->SUPER::printObject();
    SWITCH: {
        if ($self->isFunctionPointer()) {print STDERR "Parameters:\n"; last SWITCH; }
        if ($self->isEnumList()) {print STDERR "Constants:\n"; last SWITCH; }
        print STDERR "Fields:\n";
    }

    my $fieldArrayRef = $self->{FIELDS};
    if ($fieldArrayRef) {
        my $arrayLength = @{$fieldArrayRef};
        if ($arrayLength > 0) {
            &printArray(@{$fieldArrayRef});
        }
    }
    print STDERR "is function pointer: $self->{ISFUNCPTR}\n";
    print STDERR "is enum list: $self->{ISENUMLIST}\n";
    print STDERR "\n";
}

1;


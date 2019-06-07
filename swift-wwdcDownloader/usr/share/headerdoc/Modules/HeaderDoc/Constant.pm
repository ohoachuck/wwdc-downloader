#! /usr/bin/perl -w
#
# Class name: Constant
# Synopsis: Holds constant info parsed by headerDoc
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

# /*!
#     @header
#     @abstract
#         <code>Constant</code> class package file
#     @discussion
#         This file contains the <code>Constant</code> class.  This class
#         is used to represent constants.
#
#         See the class documentation below for more information.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that describes a standalone constant.
#     @discussion
#         This class is used to represent constants that are
#         not part of a typedef or enumeration.  There is
#         very little useful distinction between this and the
#         {@link //apple_ref/perl/cl/HeaderDoc::Var Var} class.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#  */
package HeaderDoc::Constant;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;
use HeaderDoc::APIOwner;

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
$HeaderDoc::Constant::VERSION = '$Revision: 1298084577 $';


# /*!
#     @abstract
#         Initializes an instance of a <code>Constant</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    $self->{CLASS} = "HeaderDoc::Constant";
}

# /*!
#     @abstract
#         Duplicates this <code>Constant</code> object into another one.
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
        $clone = HeaderDoc::Constant->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to var

    return $clone;
}


# /*!
#     @abstract
#         Sets the declaration.
#     @param self
#         The constant object.
#     @param declaration
#         The line array.
#  */
sub setDeclaration {
    my($self) = shift;
    my ($dec) = @_;
    my $localDebug = 0;
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw constant declaration is: $dec\n" if ($localDebug);
    $self->declaration($dec);
    $self->declarationInHTML($dec);
    return $dec;
}


# /*!
#     @abstract
#         Prints the object's fields for debugging purposes.
#     @param self
#         The <code>Constant</code> object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "Constant\n";
    $self->SUPER::printObject();
    print STDERR "\n";
}

1;


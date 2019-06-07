#! /usr/bin/perl
#
# Class name: Var
# Synopsis: Holds class and instance data members parsed by headerDoc
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
#         <code>Var</code> class package file.
#     @discussion
#         This file contains the <code>Var</code> class, a class for content
#         relating to a variable declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that that describes a global variable, class instance
#         variable, or package variable.
#     @discussion
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#     @var ISPROPERTY
#         Value is 1 if this is an Objective-C property, else 1.
#     @var RESULT
#         The contents of the <code>\@result</code> or <code>\@return(s)</code>
#         tags.
#  */
package HeaderDoc::Var;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;
use HeaderDoc::Struct;

# making it a subclass of Struct, so that it has the "fields" ivar.
@ISA = qw( HeaderDoc::Struct );
use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::Var::VERSION = '$Revision: 1298084579 $';


# /*!
#     @abstract
#         Initializes an instance of a <code>Var</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    $self->{CLASS} = "HeaderDoc::Var";
}

# /*!
#     @abstract
#         Duplicates this <code>Var</code> object into another one.
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
        $clone = HeaderDoc::Var->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to var

    return $clone;
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
    my($self) = shift;
    my ($dec) = @_;
    my $localDebug = 0;

    $self->declaration($dec);
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw var declaration is: $dec\n" if ($localDebug);
    $self->declarationInHTML($dec);
    return $dec;
}

# /*!
#     @abstract
#         Returns whether the variable described by this
#         object is an Objective-C property.
#     @param self
#         This object.
#     @param newvalue
#         The new value. (Optional.)
#     @result
#         Returns 0 or 1.
#  */
sub isProperty {
    my $self = shift;
    if (@_) {
	my $isprop = shift;
	$self->{ISPROPERTY} = $isprop;
    }
    return $self->{ISPROPERTY} || 0;
}

# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         This object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "Var\n";
    $self->SUPER::printObject();
    print STDERR "\n";
}


1;


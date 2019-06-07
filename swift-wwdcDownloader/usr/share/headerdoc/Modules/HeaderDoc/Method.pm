#! /usr/bin/perl
#
# Class name: Method
# Synopsis: Holds Objective C method info parsed by headerDoc (not used for C++)
#
# Original Author: SKoT McDonald  <skot@tomandandy.com> Aug 2001
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
#         <code>Method</code> class package file.
#     @discussion
#         This file contains the <code>Method</code> class, a class for content
#         relating to an Objective-C method declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that describes an Objective-C method.
#     @discussion
#         The <code>Method</code> class stores information relating to an
#         Objective-C method declaration.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#     @var RESULT
#         The contents of the <code>\@result</code> or <code>\@return(s)</code>
#         tags.
#     @var CONFLICT
#         Set high (1) if this function conflicts with another function
#         of the same name.  This causes the method signature to be shown.
#     @var ISINSTANCEMETHOD
#         Set to <code>YES</code> if this function is an instance method, else
#         <code>NO</code> for a class method.
#  */
package HeaderDoc::Method;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;
use HeaderDoc::MinorAPIElement;
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
$HeaderDoc::Method::VERSION = '$Revision: 1298084578 $';

# Inheritance
@ISA = qw( HeaderDoc::HeaderElement );


# /*!
#     @abstract
#         Initializes an instance of a <code>Method</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;

    $self->SUPER::_initialize();
    # $self->{RESULT} = undef;
    # $self->{CONFLICT} = 0;
    $self->{ISINSTANCEMETHOD} = "UNKNOWN";
    $self->{CLASS} = "HeaderDoc::Method";
}

# /*!
#     @abstract
#         Duplicates this <code>Method</code> object into another one.
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
	$clone = HeaderDoc::Method->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to function

    $clone->{RESULT} = $self->{RESULT};
    $clone->{CONFLICT} = $self->{CONFLICT};
    $clone->{ISINSTANCEMETHOD} = $self->{ISINSTANCEMETHOD};

    return $clone;
}

# /*!
#     @abstract
#         Sets a flag to indicate whether this is an
#         instance method or a class method.
#     @param self
#         This object.
#     @param ISINSTANCEMETHOD
#         The new value.  Should be either <code>YES</code> or <code>NO</code>.
#  */
sub setIsInstanceMethod {
    my $self = shift;
    
    if (@_) {
        $self->{ISINSTANCEMETHOD} = shift;
    }
    return $self->{ISINSTANCEMETHOD};
}

# /*!
#     @abstract
#         Returns a cached indication of whether this is an
#         instance method or a class method.
#     @param self
#         This object.
#     @result
#         Returns <code>YES</code> or <code>NO</code>.  Do not count on the
#         specific values.  This is subject to change.
#  */
sub isInstanceMethod {
    my $self = shift;
    return $self->{ISINSTANCEMETHOD};
}

# /*!
#     @abstract
#         Sets/gets whether this symbol name has
#         multiple variants with different numbers of
#         arguments.
#     @param self
#         This object.
#     @param CONFLICT
#         The new value. (Optional.)
#     @discussion
#         This method is basically nonsensical now that this
#         object is used exclusively for Objective-C methods.
#         Still, for compatibility, it remains (for now).
#  */
sub conflict {
    my $self = shift;
    my $localDebug = 0;
    if (@_) { 
        $self->{CONFLICT} = @_;
    }
    print STDERR "conflict $self->{CONFLICT}\n" if ($localDebug);
    return $self->{CONFLICT};
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
    my ($dec) = @_[0];
    my $classType = @_[1];
    my ($retval);
    my $localDebug = 0;
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw declaration is: $dec\n" if ($localDebug);
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
 
    print STDERR "Method\n";
    $self->SUPER::printObject();
    print STDERR "Result: $self->{RESULT}\n";
}

1;


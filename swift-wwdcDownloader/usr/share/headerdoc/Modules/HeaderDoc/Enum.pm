#! /usr/bin/perl -w
#
# Class name: Enum
# Synopsis: Holds struct info parsed by headerDoc
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

# /*! @header
#     @abstract
#         <code>Enum</code> class package file.
#     @discussion
#         This file contains the <code>Enum</code> class, a class for content
#         relating to an enumeration declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract 
#         API object that that describes an enumeration declaration.
#     @discussion
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#  */
package HeaderDoc::Enum;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;
use HeaderDoc::MinorAPIElement;
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
$HeaderDoc::Enum::VERSION = '$Revision: 1298084578 $';

# /*!
#     @abstract
#         Initializes an instance of an <code>Enum</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    
    $self->SUPER::_initialize();
    $self->{CLASS} = "HeaderDoc::Enum";
}

# /*!
#     @abstract
#         Duplicates this <code>Enum</code> object into another one.
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
	$clone = HeaderDoc::Enum->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to enum

    return $clone;
}

# /*! 
#     @abstract
#         Legacy formatter for <code>Enum</code> declarations.
#     @param self
#         The <code>Enum</code> object.
#     @param dec
#         The raw input declaration.
#     @discussion
#         This usually just returns the declaration (for performance reasons)
#         because the declaration is going to be thrown away anyway.
#
#         This should probably go away eventually.
#  */
sub getEnumDeclaration {
    my $self = shift;
    my $dec = shift;
    my $localDebug = 0;
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw declaration is: $dec\n" if ($localDebug);
    if ($HeaderDoc::use_styles) {
	return $dec;
    }
    
    $dec =~ s/\t/  /go;
    $dec =~ s/</&lt;/go;
    $dec =~ s/>/&gt;/go;
    if (length ($dec)) {$dec = "<pre>\n$dec</pre>\n";};
    
    print STDERR "Enum: returning declaration:\n\t|$dec|\n" if ($localDebug);
    print STDERR "============================================================================\n" if ($localDebug);
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
 
    print STDERR "Enum\n";
    $self->SUPER::printObject();
    print STDERR "Constants:\n";
}

1;


#! /usr/bin/perl
#
# Class name: Function
# Synopsis: Holds function info parsed by headerDoc
#
# Last Updated: $Date: 2011/03/04 16:12:05 $
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
#         <code>Function</code> class package file.
#     @discussion
#         This file contains the <code>Function</code> class, a class for content
#         relating to a function or non-Objective-C method declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that describes a function declaration.
#     @discussion
#         The <code>Function</code> class stores information relating to a function
#         declaration.  It is also used for methods except in
#         Objective-C.  Objective-C methods use the
#         {@link //apple_ref/perl/cl/HeaderDoc::Method Method} class.
#
#         The <code>Function</code> class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#     @var RESULT
#         The contents of the <code>\@result</code> or <code>\@return(s)</code>
#         tags.
#     @var CONFLICT
#         Set high (1) if this function conflicts with another function
#         of the same name.  This causes the method signature to be shown.
#  */
package HeaderDoc::Function;

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
$HeaderDoc::Function::VERSION = '$Revision: 1299283925 $';

use strict;


# /*!
#     @abstract
#         Initializes an instance of a <code>Function</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;

    $self->SUPER::_initialize();
    # $self->{RESULT} = undef;
    # $self->{CONFLICT} = 0;
    $self->{CLASS} = "HeaderDoc::Function";
}

# /*!
#     @abstract
#         Duplicates this <code>Function</code> object into another one.
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
	$clone = HeaderDoc::Function->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to function

    $clone->{RESULT} = $self->{RESULT};
    $clone->{CONFLICT} = $self->{CONFLICT};

    return $clone;
}

# /*!
#     @abstract
#         Gets/sets whether this function has a conflict with
#         another function of the same name.
#     @param self
#         The <code>Function</code> object.
#     @param conflict
#         The value to set.  (Optional.)
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
#         Strips out keywords like <code>static</code> from the return type.
#     @param self
#         The <code>Function</code> object from which the return type should
#         be obtained.
#     @discussion
#         Some keywords prior to a function name modify the function as a
#         whole, not the return type.  These keywords should never be part
#         of the return type.
#  */
sub sanitizedreturntype
{
    my $self = shift;
    my $localDebug = 0;

    my $temp = $self->returntype();

    print STDERR "Debugging return value for NAME: ".$self->name()." RETURNTYPE: $temp\n" if ($localDebug);

    my $ret = ""; my $space = "";
    my @parts = split(/\s+/, $temp);
    foreach my $part (@parts) {
	print STDERR "PART: $part\n" if ($localDebug);
	if (length($part) && $part !~ /^(virtual|static)$/) {
		$ret .= $space.$part;
		$space = " "
	}
    }
    print STDERR "Returning $ret\n" if ($localDebug);
    return $ret;
}

# /*!
#     @abstract
#         Gets the parameter signature for a function.
#     @param self
#         The <code>Function</code> object.
#  */
sub getParamSignature
{
    my $self = shift;

    if ($self->isBlock()) {
	return "";
    }

    my $formatted = 0;
    if (@_) {
	$formatted = shift;
    }

    my $localDebug = 0;
    my $space = "";
    if ($formatted) { $space = " "; }

    # To avoid infinite recursion with debugging on, do NOT change this to $self->name()!
    print STDERR "Function name: ".$self->{NAME}."\n" if ($localDebug);

    my @params = $self->parsedParameters();
    my $signature = "";
    my $returntype = $self->sanitizedreturntype();

    $returntype =~ s/\s*//sg;

    foreach my $param (@params) {
	bless($param, "HeaderDoc::HeaderElement");
	bless($param, $param->class());
	my $name = $param->name();
	my $type = $param->type();

	print STDERR "PARAM NAME: $name\nTYPE: $type\n" if ($localDebug);

	if (!$formatted) {
		$type =~ s/\s//sgo;
	} else {
		$type =~ s/\s+/ /sgo;
	}
	if (!length($type)) {
		# Safety valve, just in case
		$type = $name;
		if (!$formatted) {
			$type =~ s/\s//sgo;
		} else {
			$type =~ s/\s+/ /sgo;
		}
	} else {
		$signature .= ",".$space.$type;
		if ($name =~ /^\s*([*&]+)/) {
			$signature .= $space.$1;
		}
	}
    }
    $signature =~ s/^,\s*//s;

    if (!$formatted) {
	$signature = $returntype.'/('.$signature.')';
    }

    print STDERR "RETURN TYPE WAS $returntype\n" if ($localDebug);

    return $signature;
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
    my ($dec) = @_;
    my ($retval);
    my $localDebug = 0;
    my $noparens = 0;
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw declaration is: $dec\n" if ($localDebug);
    $self->declaration($dec);

    $self->declarationInHTML($dec);
    return $dec;
}

# /*!
#     @abstract
#         Prints an object for debugging purposes.
#     @param self
#         The <code>Function</code> object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "Function\n";
    $self->SUPER::printObject();
    print STDERR "Result: $self->{RESULT}\n";
}


1;


#! /usr/bin/perl -w
#
# Class name: MinorAPIElement
# Synopsis: Class for parameters and members of structs, etc.
#
# Last Updated: $Date: 2011/05/26 14:13:20 $
#
# Copyright (c) 1999-2008 Apple Computer, Inc.  All rights reserved.
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
#         <code>MinorAPIElement</code> class package file.
#     @discussion
#         This file contains the <code>MinorAPIElement</code> class, a class for content
#         relating to an enumeration declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that describes an API element that is documented only
#         as part of another API element.
#     @discussion
#         The <code>MinorAPIElement</code> class stores information relating to a field
#         in a structure or type declaration, a constant in an enumeration,
#         or a parameter (parsed or tagged) to a function or callback typedef.
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#
#     @var POSITION
#         The position of this element in the declaration.
#         See {@link position}.
#     @var TYPE
#         The type of minor API element.  See
#  {@link //apple_ref/perl/instm/HeaderDoc::MinorAPIElement/type//() type}.
#     @var USERDICTARRAY
#         A bunch of key-value pairs in sorted order.
#         See {@link addToUserDictArray}.
#     @var USERDICT
#         A bunch of arbitrary key-value pairs in sorted order.
#         See {@link addKeyAndValueInUserDict}.
#     @var HIDDEN
#         Indicates that this should not be emitted in HTML.  Used
#         in inherited bits.
#     @var AUTODECLARATION
#         A flag that is set to 1 for certain special declarations
#         (Perl instance variables or other variables created by the
#         <code>\@var</code> tag in class markup) to indicate that the discussion
#         functions should return a synthesized declaration rather
#         than anything from the parse tree.
#     @var TAGNAME
#         The label for an Objective-C method parameter.
#  */

package HeaderDoc::MinorAPIElement;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash registerUID);
use HeaderDoc::HeaderElement;

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
$HeaderDoc::MinorAPIElement::VERSION = '$Revision: 1306444400 $';


# /*!
#     @abstract
#         Initializes an instance of a <code>MinorAPIElement</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->SUPER::_initialize();
    # $self->{POSITION} = undef;
    # $self->{TYPE} = undef;
    $self->{USERDICTARRAY} = ();
    # $self->{HIDDEN} = 0;
    $self->{CLASS} = "HeaderDoc::MinorAPIElement";
}

# /*!
#     @abstract
#         Duplicates this <code>MinorAPIElement</code> object into another one.
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
	$clone = HeaderDoc::MinorAPIElement->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to function

    $clone->{POSITION} = $self->{POSITION};
    $clone->{TYPE} = $self->{TYPE};
    $clone->{HIDDEN} = $self->{HIDDEN};
    $clone->{USERDICTARRAY} = $self->{USERDICTARRAY};

    return $clone;
}

# /*!
#     @abstract
#         Gets/sets the Objective-C label for a parameter.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param TAGNAME
#         The new name. (Optional.)
#  */
sub tagname {
    my $self = shift;

    if (@_) {
        $self->{TAGNAME} = shift;
    }
    return $self->{TAGNAME};
}

# /*!
#     @abstract
#         Gets/sets the position of this parameter.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param POSITION
#         The new position. (Optional.)
#     @discussion
#         The first parameter has position 0, the second
#         has position 1, and so on.
#  */
sub position {
    my $self = shift;

    if (@_) {
        $self->{POSITION} = shift;
    }
    return $self->{POSITION};
}

# /*!
#     @abstract
#         Gets/sets whether this parameter is hidden.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param HIDDEN
#         The new value. (Optional.)
#     @discussion
#         Parsed parameters merged in from other places are
#         not emitted in the XML output.  Set to 1 for
#         those parameters.  Otherwise, set to 0 or leave
#         unset.
#  */
sub hidden {
    my $self = shift;

    if (@_) {
        $self->{HIDDEN} = shift;
    }
    return $self->{HIDDEN};
}

# /*!
#     @abstract
#         Gets/sets what type of parameter this is.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param TYPE
#         The new value. (Optional.)
#     @discussion
#         These values are one of:
#
#         <ul>
#             <li>(empty string)</li>
#             <li><code>callback</code></li>
#             <li><code>funcPtr</code></li>
#         </ul>
#  */
sub type {
    my $self = shift;

    if (@_) {
        $self->{TYPE} = shift;
    }
    return $self->{TYPE};
}

# /*!
#     @abstract
#         Gets/sets the user dictionary array.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @discussion
#         Used for miscellaneous data, such as the parameters
#         within a <code>typedef struct</code> of callbacks
#         stored as an array to preserve order.
#  */
sub userDictArray {
    my $self = shift;

    if (@_) {
        @{ $self->{USERDICTARRAY} } = @_;
    }
    ($self->{USERDICTARRAY}) ? return @{ $self->{USERDICTARRAY} } : return ();
}

# /*!
#     @abstract
#         Adds values to the user dictionary array (and returns it).
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param ...
#         The objects to add.
#     @discussion
#         Used for miscellaneous data, such as the parameters
#         within a <code>typedef struct</code> of callbacks
#         stored as an array to preserve order.
#  */
sub addToUserDictArray {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
            push (@{ $self->{USERDICTARRAY} }, $item);
        }
    }
    return @{ $self->{USERDICTARRAY} };
}


# /*!
#     @abstract
#         Adds key-value pairs to the user dictionary
#         (and returns it).
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param ...
#         The objects to add.
#     @discussion
#         Used for miscellaneous data.
#  */
sub addKeyAndValueInUserDict {
    my $self = shift;
    
    if (@_) {
        my $key = shift;
        my $value = shift;
        $self->{USERDICT}{$key} = $value;
    }
    return %{ $self->{USERDICT} };
}

# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         This object.
#  */
sub printObject {
    my $self = shift;
    my $dec = $self->declaration();
 
    $self->SUPER::printObject();
    print STDERR "position: $self->{POSITION}\n";
    print STDERR "type: $self->{TYPE}\n";
}

# /*!
#     @param value
#     @abstract
#         Sets or gets a state flag.
#     @discussion
#         The APPLEREFISDOC state flag controls whether to use a
#         language-specific or doc-specific apple_ref marker for a
#         doc block.
#
#         This version overrides the
#  {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/appleRefIsDoc//() appleRefIsDoc}
#         method in
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderDoc::HeaderElement}
#         because of the complexity of working with minor API
#         elements that live in normal (non-API-owner) objects.
#  */
sub appleRefIsDoc
{
    my $self = shift;
    if (@_) {
	my $value = shift;
	$self->{APPLEREFISDOC} = $value;
    }   
	# print STDERR "ARID: ".$self->{APPLEREFISDOC}." for $self\n";
    if ($self->{APPLEREFISDOC}) {
	return $self->{APPLEREFISDOC};
    } elsif ($self->apiOwner()) {
	my $apio = $self->apiOwner();
	bless($apio, "HeaderDoc::HeaderElement");
	bless($apio, $apio->class());
	my $apioval = $apio->appleRefIsDoc();
	# print STDERR "APIOVAL: $apioval for $apio (".$apio->name().")\n";
	if ($apioval) { return $apioval; }
    }
    return $self->{APPLEREFISDOC};
}

# /*!
#     @abstract
#         Sets the group.
#     @discussion
#         This overrides the declaration in HeaderElement.pm because
#         we want the groups for local variables to be separate and
#         distinct from normal function/data type/variable groups unless
#         the owning object really is an APIOwner subclass.
#  */
sub group
{
    my $self = shift;

    if ($self->apiOwner()->isAPIOwner()) {
	return $self->SUPER::group(@_);
    }

    if (@_) {
        $self->{GROUP} = shift;
    }
    return $self->{GROUP};
}

# /*!
#     @abstract
#         Gets/sets the legacy text declaration.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @discussion
#         For special declarations (Perl instance variables,
#         function-local variables, and so on),
#         returns a synthesized declaration from
#         {@link //apple_ref/perl/data/HeaderDoc::MinorAPIElement/AUTODECLARATION AUTODECLARATION}.
#         Otherwise, hands off the request to the superclass,
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#  */
sub declaration
{
    my $self = shift;
    if ($self->{AUTODECLARATION}) { return $self->{AUTODECLARATION}; }
    return $self->SUPER::declaration();
}

# /*!
#     @abstract
#         Gets the HTML declaration.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @discussion
#         For special declarations (Perl instance variables,
#         function-local variables, and so on),
#         returns a synthesized declaration from
#         {@link //apple_ref/perl/data/HeaderDoc::MinorAPIElement/AUTODECLARATION AUTODECLARATION}.
#         Otherwise, hands off the request to the superclass,
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#  */
sub declarationInHTML
{
    my $self = shift;
    if ($self->{AUTODECLARATION}) { return $self->{AUTODECLARATION}; }
    return $self->SUPER::declarationInHTML();
}

# /*!
#     @abstract
#         Gets/sets the
#         {@link //apple_ref/perl/data/HeaderDoc::MinorAPIElement/AUTODECLARATION AUTODECLARATION}
#         value.
#     @param self
#         This <code>MinorAPIElement</code> object.
#     @param AUTODECLARATION
#         The new value to set.
#     @discussion
#         For special declarations (Perl instance variables,
#         function-local variables, and so on), declaration functions
#         return a synthesized declaration based on the
#         {@link //apple_ref/doc/functionparam/HeaderDoc::MinorAPIElement/autodeclaration/AUTODECLARATION AUTODECLARATION}
#         parameter.  This function supports that.
#  */
sub autodeclaration
{
    my $self = shift;
    if (@_) {
	if ($self->lang() eq "perl") {
		$self->{AUTODECLARATION} = "\$self->{".$self->name()."}";
	} else {
		$self->{AUTODECLARATION} = $self->name();
	}
    }
    return $self->{AUTODECLARATION};
}

# /*!
#     @abstract
#         Returns a custom API reference for function
#         parameters, struct fields, and so on.
#     @discussion
#         Overrides the function in
# {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}
#         because these minor API elements need lots of special
#         treatment.  In particular, this function only
#         overrides the behavior if the main function does not
#         return anything.  This is necessary because some other
#         data types use the <code>MinorAPIElement</code> class
#         in nonstandard ways.
#  */
sub apiuid
{
    my $self = shift;
    my $args = 0;
    my $type = "AUTO";
    my $paramSignature_or_alt_define_name = "";
    if (@_) {
      $args = 1;
      $type = shift;
      if (@_) {
        $paramSignature_or_alt_define_name = shift;
      }
    }

    my $ret = "";
    if ($args) {
	$ret = $self->SUPER::apiuid($type, $paramSignature_or_alt_define_name);
    } else {
	$ret = $self->SUPER::apiuid();
    }

    # print STDERR "MINORAPIELEMENT NAME: ".$self->name()." UID: $ret\n";

    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();

    if ($ret eq "") {
	my $fieldtype = "";
	my $apio = $self->apiOwner();
	my $apioclass = ref($apio) || $apio;

	if (!$apio) {
		# We're disposing of the node.  Return the last known value.

		return $self->{APIUID};
	}

	my $include_class = 1;
	if ($apioclass eq "HeaderDoc::Enum") {
		$fieldtype = "enumconstant";
	} elsif ($apioclass eq "HeaderDoc::Function") {
		$fieldtype = "functionparam";
		if ($self->autodeclaration()) {
			$fieldtype = "functionvar";
		}
	} elsif ($apioclass eq "HeaderDoc::Method") {
		$fieldtype = "methodparam";
		if ($self->autodeclaration()) {
			$fieldtype = "methodvar";
		}
	} elsif ($apioclass eq "HeaderDoc::PDefine") {
		$fieldtype = "defineparam";
		if ($self->autodeclaration()) {
			$fieldtype = "definevar";
		}
		$include_class = 0;
	} elsif ($apioclass eq "HeaderDoc::Struct") {
		$fieldtype = "structfield";
	} elsif ($apioclass eq "HeaderDoc::Typedef") {
		$fieldtype = "typedeffield";
	} elsif ($apioclass eq "HeaderDoc::Var") {
		$fieldtype = "typedeffield";
	}

	if ($fieldtype) {
		my $apiOwnerOwner = $apio->apiOwner();
		my $apiOwnerOwnerClass = ref($apiOwnerOwner) || $apiOwnerOwner;

		my $uid = "";
		if ((!$include_class) || ($apiOwnerOwnerClass eq "HeaderDoc::Header") || (!$apiOwnerOwner)) {
			$uid = $self->genRefSub("doc", $fieldtype, $self->apiuidname, $apio->apiuidname());
		} else {
			$uid = $self->genRefSub("doc", $fieldtype, $self->apiuidname, $apio->apiuidname(), undef, $apiOwnerOwner->apiuidname);
		}

		# print STDERR $self->name().": //$apiUIDPrefix/doc/$fieldtype/".$apio->apiuidname()."/".$self->name()." VERSUS $uid\n";
		# return "//$apiUIDPrefix/doc/$fieldtype/".$apio->apiuidname()."/".$self->name();

		$self->{APIUID} = $uid;

		registerUID($uid, $self->rawname(), $self);

		return $uid;
	}
    }

    return $ret;
}

1;

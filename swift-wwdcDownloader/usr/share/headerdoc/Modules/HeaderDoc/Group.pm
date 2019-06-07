#! /usr/bin/perl -w
#
# Class name: Group
# Synopsis: Holds group info parsed by headerDoc
#
# Last Updated: $Date: 2011/02/18 19:02:58 $
# 
# Copyright (c) 2007 Apple Computer, Inc.  All rights reserved.
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
#         <code>Group</code> class package file.
#     @discussion
#         This file contains the <code>Group</code> class, a class for content
#         relating to a group of related symbols.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         Stores information about a group of symbols.
#     @discussion
#         A new instance of <code>Group</code> is created for each distinct name
#         value in the <code>\@group</code>, <code>\@functiongroup</code>, or
#         <code>\@vargroup</code> tag (if the <code>\@vargroup</code> tag is
#         used in a class or header declaration).
#
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#
#     @var MEMBEROBJECTS
#         A reference to an array of objects that are a member of this group.
#
#  */
package HeaderDoc::Group;

use HeaderDoc::Utilities qw(findRelativePath safeName getAPINameAndDisc printArray printHash validTag);
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
$HeaderDoc::Group::VERSION = '$Revision: 1298084578 $';


# /*!
#     @abstract
#         Initializes an instance of a <code>Group</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    
    $self->SUPER::_initialize();
    $self->{CLASS} = "HeaderDoc::Group";
}

# /*!
#     @abstract
#         Duplicates this <code>Group</code> object into another one.
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
	$clone = HeaderDoc::Group->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to enum

    return $clone;
}

# /*!
#     @abstract
#         Processes the comment for an <code>\@group</code> tag.
#     @param self
#         The <code>Group</code> object.
#     @param fieldref
#         A reference to a field array.
#  */
sub processComment {
    my $self = shift;
    my $fieldref = shift;

    my @fields = @{$fieldref};

    my $first = 1;
    foreach my $field (@fields) {
	# print STDERR "FIELD: $field\n";
	if ($first) { $first = 0; next; }
	SWITCH: {
		($field =~ s/^(group|name|functiongroup|methodgroup)\s+//si) && do {
			my ($name, $desc, $is_nameline_disc) = getAPINameAndDisc($field, $self->lang());

			$name =~ s/^\s+//smgo;
			$name =~ s/\s+$//smgo;

			# Preserve compatibility.  Group names may be multiple words without a discussion.
			if ($is_nameline_disc) { $name .= " ".$desc; $desc = ""; }
			# print STDERR "name: $name\n";

			$name =~ s/^\s+//smgo;
			$name =~ s/\s+$//smgo;

			$self->name($name);

			$self->discussion($desc);

			my $apio = $self->apiOwner();
			my $newobj = $apio->findGroup($name);

			if ($newobj) { return $newobj; }
			last SWITCH;
		};
		($field =~ s/^abstract\s+//sio) && do {$self->abstract($field); last SWITCH;};
		($field =~ s/^brief\s+//sio) && do {$self->abstract($field, 1); last SWITCH;};
		($field =~ s/^(discussion|details|description)(\s+|$)//sio) && do {
                        # print STDERR "DISCUSSION ON $self: $field\n";
# 
                        if (!length($field)) { $field = "\n"; }
                        $self->discussion($field);
                        last SWITCH;
                };
		{
			my $fullpath = $self->fullpath();
			my $linenum = $self->linenum();

			if (length($field)) {
				warn "$fullpath:$linenum: warning: Unknown field (\@$field) in group comment (".$self->name().")\n";
				# cluck("Here\n");
			}
		};
	}
    }

    return $self;
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


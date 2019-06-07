#! /usr/bin/perl -w
#
# Class name: 	Dependency
# Synopsis: 	Used by headerdoc2html to handle dependency tracking.
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

# /*!
#     @header
#     @abstract
#         <code>Dependency</code> class package file.
#     @discussion
#         This file contains the <code>Dependency</code> class.  This class
#         is used to describe a dependency between two headers.
#
#         See the class documentation below for more details.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Represents an inter-header dependency.
#     @discussion
#         Instances of this class describe dependencies between
#         headers.A
#
#         The actual dependency ordering process is described in the
#         documentation for the {@link fix_dependency_order} function.
#
#     @var NAME
#         The name of the header.
#     @var DEPNAME
#         The name of the header with leading path parts
#         stripped off.
#     @var MARKED
#         Used by upper layers.
#     @var EXISTS
#         Set to 1 if this header was one of the headers
#         listed on the command line.
#     @var PARENT
#         The parent for this dependency (the header that
#         has a #include directive for this one).
#     @var CHILDREN
#         An array of references to other dependency nodes
#         for the headers that this header includes.
#     @var DEPTH
#         The depth for the deepest place that this
#         header appears within the dependency tree.  Used
#         in a depth-first traversal of the tree.
#     @var PRINTED
#         Used to flag nodes already traversed.  This prevents
#         the possibility of loops in the graph from causing
#         incorrect behavior (a hang).
#  */
package HeaderDoc::Dependency;

use strict;
use vars qw($VERSION @ISA);

use HeaderDoc::Utilities qw(isKeyword casecmp);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::Dependency::VERSION = '$Revision: 1298084578 $';
################ General Constants ###################################
my $debugging = 0;

my $treeDebug = 0;
my %defaults = (
	NAME => undef,
	DEPNAME => undef,
	MARKED => 0,
	EXISTS => 0,
	PARENT => undef,
	CHILDREN => ()
);

# /*!
#     @abstract
#         Creates a new <code>Dependency</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::Dependency->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param;
    my %selfhash = %defaults;
    my $self = \%selfhash;
    
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
#         Initializes an instance of a <code>Dependency</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    # my($self) = shift;
    # $self->{NAME} = undef;
    # $self->{DEPNAME} = undef;
    # $self->{MARKED} = 0;
    # $self->{EXISTS} = 0;
    # $self->{PARENT} = undef;
    # $self->{CHILDREN} = ();
}

# /*!
#     @abstract
#         Duplicates this <code>Dependency</code> object into another one.
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
        $clone = HeaderDoc::Dependency->new(); 
    }

    # $self->SUPER::clone($clone);

    # now clone stuff specific to Dependency

    $clone->{PARENT} = $self->{PARENT};
    $clone->{CHILDREN} = $self->{CHILDREN};

}

# /*!
#     @abstract
#         Adds a dependency.
#     @param self
#         The <code>Dependency</code> object for the current header.
#     @param name
#         The child <code>Dependency</code> object for the header this
#         header includes.
#  */
sub addchild {
    my $self = shift;
    my $child = shift;

    push(@{$self->{CHILDREN}}, \$child);
}

my %namehash = ();

# /*!
#     @abstract
#         Returns the dependency object for a given header filename.
#     @param self
#         The <code>Dependency</code> object.
#     @param name
#         The name to look up.
#  */
sub findname {
    my $self = shift;
    my $name = shift;

    # print STDERR "FINDNAME: $name\n";
    # print STDERR "RETURNING: ".$namehash{$name}."\n";

    return $namehash{$name};
}

# /*!
#     @abstract
#         Gets/sets the name for this header/dependency.
#     @param self
#         The <code>Dependency</code> object.
#     @param name
#         The new name.  (Optional.)
#     @discussion
#         The <code>name</code> value contains the name,
#         including any leading path parts.  The
#         <code>depname</code> value contains the name of the
#         header without any leading path parts.  
#  */
sub name {
    my $self = shift;
    if (@_) {
	my $name = shift;
	$self->{NAME} = $name;
    }
    return $self->{NAME};
}

# /*!
#     @abstract
#         Gets/sets the short name for this header/dependency.
#     @param self
#         The <code>Dependency</code> object.
#     @param name
#         The new name.  (Optional.)
#     @discussion
#         The <code>depname</code> value contains the name of the
#         header without any leading path parts.  The <code>name</code>
#         value contains the name of the header with any leading path
#         parts.
#  */
sub depname {
    my $self = shift;
    if (@_) {
	my $depname = shift;
	$self->{DEPNAME} = $depname;
	# print STDERR "Setting \$namehasn{$depname} to $self\n";
	$namehash{$depname} = \$self;
    }
    return $self->{DEPNAME};
}

# /*!
#     @abstract
#         Reparents a depdency under another one.
#     @discussion
#         Currently unused.
#  */
sub reparent {
    my $self = shift;
    my $name = shift;

    my $node = ${findname($name)};
    bless("HeaderDoc::Dependency", $node);
    my $oldparent = $node->parent;

    my @children = @{$oldparent->{CHILDREN}};
    my @newkids = ();
    foreach my $childref (@children) {
	if ($childref != \$node) {
		push(@newkids, $childref);
	}
    }
    $oldparent->{CHILDREN} = @newkids;
    $self->addchild($node);
}

# /*! @abstract
#         Prints the object for debugging purposes.
#  */
sub dbprint {
    my $self = shift;
    my $indent = "";
    if (@_) {
	$indent = shift;
    }

    print STDERR $indent."o---+".$self->{NAME}." (DEPTH ".$self->{DEPTH}.")\n";
    if ($self->{PRINTED}) {
	print STDERR $indent."    |--- Infinite recursion detected.  Aborting.\n";
	return;
    }

    my $childindent = $indent."|   ";
    $self->{PRINTED} = 1;

    foreach my $childref (@{$self->{CHILDREN}}) {
	my $childnode = ${$childref};
	bless($childnode, "HeaderDoc::Dependency");
	$childnode->dbprint($childindent);
    }
    # $self->{PRINTED} = 0;
    print STDERR "$indent\n";
}

1;


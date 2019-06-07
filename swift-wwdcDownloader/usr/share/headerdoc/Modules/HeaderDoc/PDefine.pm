#! /usr/bin/perl
#
# Class name: PDefine
# Synopsis: Holds headerDoc comments of the @define type, which
#           are used to comment symbolic constants declared with #define
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
#         <code>PDefine</code> class package file.
#     @discussion
#         This file contains the <code>PDefine</code> class, a class for content
#         relating to a C preprocessor macro (<code>#define</code>) declaration.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         API object that describes a C preprocessor macro declaration.
#     @discussion
#         This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.
#         The majority of related fields and functions can be found there.
#     @var RESULT
#         The contents of the <code>\@result</code> or <code>\@return(s)</code> tags.
#     @var BLOCKDISCUSSION
#         The discussion for the define block that contains this define.
#     @var PARSEONLY
#         Set by the <code>\@parseOnly</code> flag.  See {@link parseOnly}.
#     @var ISAVAILABILITYMACRO
#         Set to 1 if this macro is an availability macro, else 0.
#  */


package HeaderDoc::PDefine;
use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash validTag);
use HeaderDoc::HeaderElement;

@ISA = qw( HeaderDoc::HeaderElement );
use strict;
use vars qw($VERSION @ISA);
use Carp qw(cluck);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::PDefine::VERSION = '$Revision: 1299283925 $';


# /*!
#     @abstract
#         Initializes an instance of a <code>PDefine</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {    
    my($self) = shift;

    $self->SUPER::_initialize();
    # $self->{ISBLOCK} = 0; # in HeaderElement.
    # $self->{RESULT} = undef;
    $self->{BLOCKDISCUSSION} = "";
    $self->{PARSETREELIST} = ();
    $self->{PARSEONLY} = ();
    $self->{CLASS} = "HeaderDoc::PDefine";
}

# /*!
#     @abstract
#         Duplicates this <code>PDefine</code> object into another one.
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
	$clone = HeaderDoc::PDefine->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to function

    $clone->{ISBLOCK} = $self->{ISBLOCK};
    $clone->{RESULT} = $self->{RESULT};
    $clone->{BLOCKDISCUSSION} = $self->{BLOCKDISCUSSION};
    $clone->{PARSETREELIST} = $self->{PARSETREELIST};
    $clone->{PARSEONLY} = $self->{PARSEONLY};

    return $clone;
}

# /*!
#     @abstract
#         Gets/sets the discussion; returns block discussion
#         for <code>#define</code> macros that don't have a discussion of
#         their own.
#     @param self
#         This object.
#     @param newvalue
#         The value to set. (Optional.)
#     @discussion
#         This differs from the main function in that it checks for
#         discussion locking (used by define blocks) and falls back
#         on the block discussion for individual defines if no
#         define-specific discussion exists.
#  */
sub discussion
{
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
	if ($localDebug) {
		print STDERR "Set Discussion for #define (or block) to ".@_[0]."..\n";
	}
	return $self->SUPER::discussion(@_);
    }

    my $realdisc = $self->SUPER::discussion();
    my $realCheckDisc = $self->SUPER::halfbaked_discussion();

    if (!length($realCheckDisc) || ($realCheckDisc !~ /\S/)) {
	# print STDERR "RETURNING BLOCK DISC FOR $self (".$self->name().")\n";

	my $bd = $self->blockDiscussion();

	# print STDERR "WILL BE $bd\n";
	# cluck("here\n");

	return $self->blockDiscussion();
    }
    # print STDERR "RETURNING LOCAL DISC FOR $self (".$self->name().")\n";

    return $realdisc;
}

# /*!
#     @abstract
#         Gets/sets the abstract for a <code>#define</code>.
#     @param self
#         The current object.
#     @param throws
#         The new value. (Optional.)
#     @param isbrief
#         Use for compatibility the Doxygen <code>\@brief</code> tag.  Pass 1
#         for the <code>\@brief</code> behavior (abstract is limited to one paragraph
#         of content, so everything after a gap becomes part of the
#         discussion), 0 for the normal <code>\@abstract</code> behavior.
#     @discussion
#         This differs from the main function only in that it checks for
#         abstract locking (used by define blocks).
#  */
sub abstract
{
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
	if ($localDebug) {

	# cluck("here\n");
		print STDERR "Set abstract for #define (or block) to ".@_[0]."..\n";
	}
	return $self->SUPER::abstract(@_);
    }

    return $self->SUPER::abstract();
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
    my $fullpath = $self->fullpath();
    my $line = $self->linenum();

    # if ($dec =~ /#define.*#define/so && !($self->isBlock)) {
	# warn("$fullpath:$line:WARNING: Multiple #defines in \@define.  Use \@defineblock instead.\n");
    # }
    
    print STDERR "============================================================================\n" if ($localDebug);
    print STDERR "Raw #define declaration is: $dec\n" if ($localDebug);
    $self->declarationInHTML($dec);
    return $dec;
}

# /*!
#     @abstract
#         Gets/sets whether this macro is an availability macro.
#     @param self
#         This object.
#     @param newvalue
#         The new value. (Optional.)
#     @discussion
#         Triggered by the <code>\@availabilitymacro</code> tag.
#  */
sub isAvailabilityMacro {
    my $self = shift;

    if (@_) {
	$self->{ISAVAILABILITYMACRO} = shift;
    }

    return $self->{ISAVAILABILITYMACRO};
}


# /*!
#     @abstract
#         Gets/sets the block discussion for a <code>#define</code>.
#     @param self
#         This object.
#     @param newvalue
#         The new block discussion. (Optional.)
#     @discussion
#         The block discussion for a <code>#define</code> is the discusion
#         from the enclosing <code>\@defineblock</code> comment.  A copy is
#         stored in each <code>#define</code> object.  It is returned by the
#  {@link //apple_ref/perl/instm/HeaderDoc::PDefine/discussion//() discussion}
#         function if no discussion specific to a given <code>#define</code>
#         is available.
#  */
sub blockDiscussion {
    my $self = shift;
    my $localDebug = 0;
    
    if (@_) {
        $self->{BLOCKDISCUSSION} = shift;
	if ($localDebug) {
		print STDERR "SET BLOCK DISCUSSION for #define (or block) $self to ".$self->{BLOCKDISCUSSION}."\n";
	}
    }
    return $self->{BLOCKDISCUSSION};
}

# /*!
#     @abstract
#         Returns whether the macro is a function-like macro or not.
#  */
sub isFunctionLikeMacro()
{
    my $self = shift;

    my $ps = $self->parserState();

    # print STDERR "PS: $ps\n";

    if ($ps) {
	return $ps->{cppMacroHasArgs};
    } else {
	warn("No parser state object found for $self\n");
    }

    return 0;
}


# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         This object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "#Define\n";
    $self->SUPER::printObject();
    print STDERR "Result: $self->{RESULT}\n";
    print STDERR "\n";
}

# /*!
#    @abstract
#         Gets/sets the parse tree associated with this object.
#    @param self
#         This object.
#    @param treeref
#         A reference to the parse tree to set/add. (Optional.)
#    @discussion
#        If this is a block declaration, the parse tree is added to
#        its list of parse trees.
#  */
sub parseTree
{
    my $self = shift;
    my $xmlmode = 0;
    if ($self->outputformat eq "hdxml") {
	$xmlmode = 1;
    }

    if (@_) {
	my $treeref = shift;

	$self->SUPER::parseTree($treeref);
	my $tree = ${$treeref};
	my ($success, $value) = $tree->getPTvalue();
	# print STDERR "SV: $success $value\n";
	if ($success) {
		my $vstr = "";
		if ($xmlmode) {
			$vstr = sprintf("0x%x", $value)
		} else {
			$vstr = sprintf("0x%x (%d)", $value, $value)
		}
		if (!$self->isBlock) { $self->attribute("Value", $vstr, 0); }
	}
	return $treeref;
    }
    return $self->SUPER::parseTree();
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
#         Gets/sets the "parse only" flag for this <code>#define</code>.
#     @param self
#         This object.
#     @param newvalue
#         The new "parse only" flag value. (Optional.)
#     @discussion
#         This is triggered by the <code>\@parseOnly</code> tag in the
#         HeaderDoc comment.  If set, the declaration is
#         parsed for C preprocessing purposes, but is not
#         emitted in the HTML.
#  */
sub parseOnly
{
    my $self = shift;
    if (@_) {
	$self->{PARSEONLY} = shift;
    }
    return $self->{PARSEONLY};
}

1;


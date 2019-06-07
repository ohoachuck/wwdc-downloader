#! /usr/bin/perl -w
#
# Class name: HeaderElement
# Synopsis: Root class for Function, Typedef, Constant, etc. -- used by HeaderDoc.
#
# Last Updated: $Date: 2014/03/06 11:05:55 $
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
#         <code>HeaderElement</code> class package file.
#     @discussion
#         This file contains the <code>HeaderElement</code> class, the base class
#         for all API elements.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#     @abstract
#         Base class for all API objects.
#     @discussion
#         The <code>HeaderElement</code> class is the base class for all objects
#         representing API elements, including headers, structs,
#         functions, classes, etc.  The majority of HeaderDoc
#         classes are subclasses of this class.
#
#         This class provides services common to all API elements
#         (or services common to several elements).  The most
#         important functions in this class are:
#
#         <dl>
#         <dt>{@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/processComment//() processComment}</dt>
#             <dd>Parses a HeaderDoc comment block.</dd>
#         <dt>{@link declarationInHTML}</dt>
#             <dd>Returns the declaration in HTML/XML by calling into the
#             {@link //apple_ref/perl/cl/HeaderDoc::ParseTree ParseTree}
#             class.</dd>
#         <dt>{@link documentationBlock} and {@link XMLdocumentationBlock}</dt>
#             <dd>Return the entire documentation output for this
#                 object (class, function, enumeration, data structure, and so on) and any
#                 descendants enclosed within it.</dd>
#         <dt>{@link keywords}</dt>
#             <dd>Returns a set of keywords for parsing declarations in
#                 the current programming language and returns whether
#                 those keywords should be interpreted in a case-sensitive
#                 or case-insensitive fashion.</dd>
#         <dt>{@link apirefSetup}</dt>
#             <dd>Does a lot of the work setting up the API reference for
#                 this object and its subclasses.</dd>
#         <dt>{@link apiref} and {@link apiuid}</dt>
#             <dd>Get and set the API reference, respectively.</dd>
#         </dl>
#
#     This API object type should never actually be emitted as output; only
#     its subclasses are relevant.
#
#     @var ABSTRACT
#         The contents of the associated <code>\@abstract</code> tag.
#     @var ABSTRACTLOCKED
#         Temporary storage for the <code>ABSTRACT</code> field, used when fields are locked
#         during define block parsing.  For more information, see the
#         documentation for the {@link discussionLocked} and
#         {@link unlockDiscussion} functions.
#     @var ACCESSCONTROL
#         The access control state for this API element (e.g. public, private...)
#     @var APIOWNER
#         The {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner} object
#         whose declaration includes this one.  This owning object may be a
#         class, header, protocol, category, etc.
#     @var APIREFSETUPDONE
#         Set to 1 when the {@link apirefSetup} call finishes.  This avoids
#         doing unnecessary work (and makes the UID collision protection easier).
#     @var APIUID
#         A cache of the raw UID for this object.  Set by {@link apiuid}.  This
#         is not actually used because it is often wrong.
#     @var APPLEREFISDOC
#         Holds 1 if this object should emit a doc-style API reference,
#         else 0.
#     @var ATTRIBUTELISTS
#         The list-style attributes associated with this API element.
#         See {@link attributelist}, {@link getAttributeLists}, and
#         {@link checkAttributeLists}.
#     @var AUTORELATE
#         Used to store a list of automatically-generated cross-references
#         for blocks containing mixed types.  For more information, see the
#         documentation for the {@link autoRelate} function.
#     @var AVAILABILITY
#         The availability information for this element (from <code>\@availability</code>
#         or from availability macros.
#     @var BLOCKOFFSET
#         The offset of the start of the block of lines in which this declaration
#         appears.  (Added to <code>RAWLINENUM</code> to get the actual line
#         number.)
#     @var CASESENSITIVE
#         A cache of the value for case sensitivity from the last time the
#         {@link keywords} method was called.
#     @var CLASS
#         The HeaderDoc object class for this object (e.g. HeaderDoc::Method).
#         Used to bless the object properly from a hash reference.
#     @var CONSTANTS
#         An array of constants in this enumeration or API owner object.  Each
#         item in this array is a
#         {@link //apple_ref/perl/cl/HeaderDoc::MinorAPIElement MinorAPIElement}
#         object.
#     @var DECLARATION
#         The (vestigial) text declaration for this element.
#     @var DECLARATIONINHTML
#         A cache of the HTML declaration for this element.
#     @var DISCUSSION
#         The contents of the <code>\@discussion</code> tag (or untagged content elsewhere
#         in the comment).
#     @var DISCUSSION_SET
#         Set to 1 when an actual discussion has been seen.  This is used
#         to determine whether additional words in the name line should be
#         treated as discussion or part of the name.  See {@link nameline_discussion}
#         for more info.
#     @var DISCUSSIONLOCKED
#         Temporary storage for the <code>DISCUSSION</code> field, used when fields are locked
#         during define block parsing.  For more information, see the
#         documentation for the {@link discussionLocked} and
#         {@link unlockDiscussion} functions.
#     @var DISCUSSION_SETLOCKED
#         Temporary storage for the <code>DISCUSSION_SET</code> field, used when fields are locked
#         during define block parsing.  For more information, see the
#         documentation for the {@link discussionLocked} and
#         {@link unlockDiscussion} functions.
#     @var FIELDHEADING
#         A cache of the last field heading displayed.  <b>Unused.</b>
#     @var FIELDS
#         An array of fields in this struct, union, or typedef.
#     @var FILENAME
#         The filename containing this declaration (with leading path parts removed).
#     @var FIRSTCONSTNAME
#         The first constant name within an enumeration.  Used as the name of
#         an anonymous enumeration if no name is specified in the comment.
#     @var FORCENAME
#         The contents of an \@name tag, which overrides any name obtained in any other way.
#     @var FULLPATH
#         The filename containing this declaration (with leading parts left intact).
#     @var FUNCORMETHOD
#         A cache of the last <code>func_or_method</code> value returned by
#         {@link apirefSetup}.  <b>Unused.</b>
#     @var FUNCTIONCONTENTS
#         The contents within the outer braces of a function.
#     @var GROUP
#         The name of the (documentation) group that this object is in.
#     @var HASPROCESSEDCOMMENT
#         Set to 1 after the
#  {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/processComment//() processComment}
#         function has executed.  This prevents doing that twice (which would cause
#         a number of problems).
#     @var HIDECONTENTS
#         Set to 1 if the <code>\@hidecontents</code> tag is found in a macro's HeaderDoc comment.
#         See {@link hideContents}.
#     @var HIDEDOC
#         Set by the block parser to indicate that this object should not emit any
#         documentation.  This is set on <code>#define</code> objects within a
#         <code>#define</code> block if the <code>HIDESINGLETONS</code> flag is set
#         on the enclosing block.
#     @var HIDESINGLETONS
#         This flag is set (to 1) if the <code>\@hidesingletons</code> tag is found inside an
#         <code>\@defineblock</code> (or <code>\@definedblock</code>) comment.
#     @var INCLUDED_DEFINES
#         An array of <code>#define</code> objects nested in an <code>\@defineblock</code>
#         (or <code>\@definedblock</code>).
#     @var INDEFINEBLOCK
#         Set on individual <code>#define</code> objects within an <code>\@defineblock</code>
#         (or <code>\@definedblock</code>).
#     @var INDEXGROUP
#         The group in which this object and its descendants should appear inside
#         the master TOC as generated by
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc.pl}.
#     @var INHERITDOC
#         The discussion for the superclass.  Inserted if requested.  See
#         {@link fixup_inheritDoc}.
#     @var INSERTED
#         Set to 42 once this object has been added to its enclosing API owner.
#     @var ISBLOCK
#         Set to 1 for <code>#define</code> blocks, 2 for <code>#ifdef</code> blocks around
#         multiple variants of a function.
#     @var ISCALLBACK
#         Set to 1 for a <code>typedef</code> of a callback.
#     @var ISDEFINE
#         Set for <code>#define</code> members in a non-<code>#define</code> block to prevent
#         lovely problems.
#     @var ISFUNCPTR
#         Set to 1 for a variable or type definition if the <code>\@result</code> tag is included.
#     @var ISINTERNAL
#         Set to 1 for internal variables/functions that should only be
#         documented if a special flag is set.
#     @var ISTEMPLATE
#         Set for functions that have template parameters.
#     @var KEEPCONSTANTS
#         A cached array of constants generated by {@link apirefSetup}.
#     @var KEEPFIELDS
#         A cached array of fields generated by {@link apirefSetup}.
#     @var KEEPPARAMS
#         A cached array of parameters generated by {@link apirefSetup}.
#     @var KEEPVARIABLES
#         A cached array of variables generated by {@link apirefSetup}.
#     @var KEYWORDHASH
#         A cache of the keyword hash from the last time the
#         {@link keywords} method was called.
#     @var LANG
#         The programming language for this declaration.
#     @var LINENUM
#         The line number in which this declaration begins relative to the start
#         of the header.  (This is the sum of<code>BLOCKOFFSET</code> and
#         <code>RAWLINENUM</code>.)
#     @var LINKAGESTATE
#         The linkage state.  <b>Unused.</b>
#     @var LINKUID
#         A cache of the "link UID".  See {@link generateLinkUID}.
#     @var LONGATTRIBUTES
#         An array of "long" attributes (those containing multiple paragraphs
#         as opposed to just a line or so).
#     @var MAINOBJECT
#         The main object (block object) in a block declaration.
#     @var MASTERENUM
#         The main enum object that owns the enclosing constants.
#         Originally used for apple_ref emission purposes.  <b>Unused.</b>
#     @var NAME
#         The name of the API symbol that this object represents.
#         Usually accessed with
#         {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/name//() name}.
#     @var NAMELINE_DISCUSSION
#         The portion of the discussion that appears on the same line as
#         the name in an old-style HeaderDoc comment.  See {@link nameline_discussion}
#         for more information.
#     @var NAMEREFS
#         An array of names for this object that appear within the
#         {@link HeaderDoc::namerefs} array.  Used when
#         destroying this object to allow those references to be destroyed.
#     @var NAMESPACE
#         Contains a text string representing the namespace for this class.
#         See {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/namespace//() namespace}.
#     @var NOREGISTERUID
#         Set to 1 when an object's UID has been unregistered to prevent it from being
#         registered again.  See {@link noRegisterUID}.
#     @var ORIGCLASS
#         The name of the class that a method, variable, etc. was inherited from.
#         See {@link origClass}.
#     @var ORIGTYPE
#         The type of the original object (generated based on the HeaderDoc comment)
#         from which this object (of a different type) was later cloned.  For more
#         information, see the documentation for the {@link origType} function.
#     @var OUTPUTFORMAT
#         The current output format ("html" or "hdxml").
#     @var PARSEDPARAMETERS
#         For methods, an array of parsed parameters for a method.  For
#         a structure, union, or type definition, an array of parsed
#         fields.  For an enumaration, an array of parsed constants.
#     @var PARSERSTATE
#         The parser state object associated with this API object.
#     @var PARSETREE
#         The parse tree object containing the declaration for this API object.
#     @var PARSETREECLEANUP
#         An array of parse tree objects that reference this API object.  Used when
#         destroying this object to allow those references to be destroyed.
#     @var PARSETREELIST
#         An array of parse trees containing the declarations for
#         API objects within this block-style API object.  Only
#         relevant if {@link isBlock} returns 1.
#     @var PPFIXUPDONE
#         Set to 1 to indicate that {@link fixupParsedParameters} has
#         already been called on this object.
#     @var PRESERVESPACES
#         Set to 1 to indicate that the user wants to preserve
#         whitespace within this declaration.  See {@link preserve_spaces}.
#     @var PRIVATEDECLARATION
#         The private declaration portion of a C++ method (after the colon).
#     @var RAWLINENUM
#         The line number in which this declaration begins relative to the start
#         of the block of lines.  (Added to <code>BLOCKOFFSET</code> to get the actual
#         line number.)
#     @var RAWNAME
#         See {@link rawname}.
#     @var REQUESTEDUID
#         A UID explicitly provided with the <code>\@apiuid</code> tag.  See {@link requestedUID}.
#     @var RETURNTYPE
#         The return type for a function (parsed from the code).
#     @var SEEALSODUPCHECK
#         Used to prevent duplicates in auto-generated cross-linking.
#         See {@link seeDupCheck} for details.
#     @var SINGLEATTRIBUTES
#         An array of "short" attributes (those containing just a word or a line
#         as opposed to multiple paragraphs).
#     @var SUBLANG
#         The programming language variant for this object (e.g. <code>cpp</code> for C++).
#     @var SUPPRESSCHILDREN
#         Indicates that UIDs for child elements (e.g. fields) should be suppressed
#         in the HTML output.  See {@link suppressChildren} for more information.
#     @var TAGGEDPARAMETERS
#         An array of explicitly tagged (<code>\@param</code>) parameters in a function/method.
#     @var THROWS
#         The content of the <code>\@throws</code> tag in the comment (with HTML formatting added).
#         See also <code>XMLTHROWS</code> below.
#     @var TPCDONE
#         Set to 1 after {@link taggedParsedCompare} is called so that this
#         isn't done repeatedly for the same function, union, struct, or typedef.
#     @var TYPEDEFCONTENTS
#         The contents of a typedef declaration.
#     @var UPDATED
#         The last updated date.  See
#         {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/updated//() updated}.
#     @var USESTDOUT
#         Set to 1 if the <code>-P</code> (pipe) flag is passed to HeaderDoc, else 0.
#     @var VALUE
#         The value of a constant/variable.
#         See {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/value//() value}.
#     @var VARIABLES
#         An array of variables enclosed in a normal (usually function) object.  These are
#         {@link //apple_ref/perl/cl/HeaderDoc::MinorAPIElement MinorAPIElement} objects.
#     @var VARS
#         An array of variables enclosed in an API owner object.  These are
#         {@link //apple_ref/perl/cl/HeaderDoc::Var Var} objects.
#     @var XMLTHROWS
#         A copy of the value in <code>THROWS</code> with XML formatting.
#     @var AS_CLASS_SELF
#         A <code>CPPClass</code> object cloned from the current function object that holds
#         any scripts that are nested within the function.  See
#         {@link cloneAppleScriptFunctionContents} and {@link processAppleScriptFunctionContents}
#         for more information.
#     @var AS_FUNC_SELF
#         The <code>Function</code> object that the current class object was cloned from.  See
#         {@link cloneAppleScriptFunctionContents} and {@link processAppleScriptFunctionContents}
#         for more information.
#     @var ASCONTENTSPROCESSED
#         Set to 1 after the {@link processAppleScriptFunctionContents} method runs.
#         for more information.
#     @var PARSEDPSEUDOCLASSNAME
#         The name of the directory where the contents from any classes within the {@link AS_CLASS_SELF}
#         container are written.
#  */
package HeaderDoc::HeaderElement;

use HeaderDoc::Utilities qw(findRelativePath safeName getAPINameAndDisc printArray printHash unregisterUID registerUID html2xhtml sanitize parseTokens unregister_force_uid_clear dereferenceUIDObject filterHeaderDocTagContents validTag printFields splitOnPara getDefaultEncoding html_fixup_links xml_fixup_links);

use File::Basename;
use strict;
use vars qw($VERSION @ISA);
use POSIX qw(strftime mktime localtime);
use Carp qw(cluck);
use URI::Escape;
use locale;
use Encode qw(encode decode);

use Devel::Peek;

my $isMacOS;
my $pathSeparator;
if ($^O =~ /MacOS/io) {
        $pathSeparator = ":";
        $isMacOS = 1;
} else {
        $pathSeparator = "/";
        $isMacOS = 0;
}

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::HeaderElement::VERSION = '$Revision: 1394132755 $';

# /*!
#     @abstract
#         Creates a new <code>HeaderElement</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::HeaderElement->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param;
    my $self = {};
    
    # cluck("Created header element\n"); # @@@
    
    bless($self, $class);
    $self->_initialize();

    # Now grab any key => value pairs passed in
    my (%attributeHash) = @_;
    foreach my $key (keys(%attributeHash)) {
        $self->{$key} = $attributeHash{$key};
    }

    # if ((!$self->{LANG}) || (!$self->{SUBLANG})) {
	# cluck("Allocation with no language or sublanguage.\n");
    # }
    # if ($self->{LANG} ne $HeaderDoc::lang) {
	# cluck("Allocation with non-matching language.  ".$self->{LANG}." != ".$HeaderDoc::lang."\n");
    # }
    # if ($self->{SUBLANG} ne $HeaderDoc::sublang) {
	# cluck("Allocation with non-matching sublanguage.  ".$self->{SUBLANG}." != ".$HeaderDoc::sublang."\n");
    # }

    return ($self);
}

# /*!
#     @abstract
#         Initializes an instance of a <code>HeaderElement</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    # $self->{ABSTRACT} = undef;
    # $self->{DISCUSSION} = undef;
    # $self->{DECLARATION} = undef;
    # $self->{DECLARATIONINHTML} = undef;
    # $self->{PRIVATEDECLARATION} = undef;
    # $self->{OUTPUTFORMAT} = undef;
    # $self->{FILENAME} = undef;
    # $self->{NAME} = undef;
    # $self->{RAWNAME} = undef;
    $self->{GROUP} = $HeaderDoc::globalGroup;
    $self->{INDEXGROUP} = "";
    # $self->{THROWS} = undef;
    # $self->{XMLTHROWS} = undef;
    # $self->{UPDATED} = undef;
    # $self->{LINKAGESTATE} = undef;
    # $self->{ACCESSCONTROL} = undef;
    $self->{AVAILABILITY} = "";

    # These must now be passed in via the new() parameters.
    # $self->{LANG} = $HeaderDoc::lang;
    # $self->{SUBLANG} = $HeaderDoc::sublang;

    $self->{SINGLEATTRIBUTES} = ();
    $self->{LONGATTRIBUTES} = ();
    # $self->{ATTRIBUTELISTS} = undef;
    $self->{APIOWNER} = $HeaderDoc::currentClass;
    # $self->{APIUID} = undef;
    # $self->{LINKUID} = undef;
    $self->{ORIGCLASS} = "";
    # $self->{ISTEMPLATE} = 0;
    $self->{VALUE} = "UNKNOWN";
    $self->{RETURNTYPE} = "";
    $self->{TAGGEDPARAMETERS} = ();
    $self->{PARSEDPARAMETERS} = ();
    $self->{CONSTANTS} = ();
    $self->{VARIABLES} = ();
# print STDERR "Initted VARIABLES in $self\n";
    # $self->{LINENUM} = 0;
    $self->{CLASS} = "HeaderDoc::HeaderElement";
    # $self->{CASESENSITIVE} = undef;
    # $self->{KEYWORDHASH} = undef;
    # $self->{MASTERENUM} = 0;
    # $self->{APIREFSETUPDONE} = 0;
    # $self->{TPCDONE} = 0;
    # $self->{NOREGISTERUID} = 0;
    # $self->{SUPPRESSCHILDREN} = 0;
    # $self->{NAMELINE_DISCUSSION} = undef;
}

my %CSS_STYLES = ();

# /*!
#     @abstract
#         Duplicates this <code>HeaderElement</code> object into another one.
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
	$clone = $self->new("lang" => $self->{LANG}, "sublang" => $self->{SUBLANG});
	$clone->{CLASS} = $self->{CLASS};
    }

    # $self->SUPER::clone($clone);

    # now clone stuff specific to header element

    $clone->{ABSTRACT} = $self->{ABSTRACT};
    $clone->{DISCUSSION} = $self->{DISCUSSION};
    $clone->{DECLARATION} = $self->{DECLARATION};
    $clone->{DECLARATIONINHTML} = $self->{DECLARATIONINHTML};
    $clone->{PRIVATEDECLARATION} = $self->{PRIVATEDECLARATION};
    $clone->{OUTPUTFORMAT} = $self->{OUTPUTFORMAT};
    $clone->{FILENAME} = $self->{FILENAME};
    $clone->{FULLPATH} = $self->{FULLPATH};
    $clone->{NAME} = $self->{NAME};
    $clone->{RAWNAME} = $self->{RAWNAME};
    $clone->{GROUP} = $self->{GROUP};
    $clone->{THROWS} = $self->{THROWS};
    $clone->{XMLTHROWS} = $self->{XMLTHROWS};
    $clone->{UPDATED} = $self->{UPDATED};
    $clone->{LINKAGESTATE} = $self->{LINKAGESTATE};
    $clone->{ACCESSCONTROL} = $self->{ACCESSCONTROL};
    $clone->{AVAILABILITY} = $self->{AVAILABILITY};
    $clone->{LANG} = $self->{LANG};
    $clone->{SUBLANG} = $self->{SUBLANG};
    $clone->{SINGLEATTRIBUTES} = $self->{SINGLEATTRIBUTES};
    $clone->{LONGATTRIBUTES} = $self->{LONGATTRIBUTES};
    $clone->{NAMELINE_DISCUSSION} = $self->{NAMELINE_DISCUSSION};
    $clone->{ATTRIBUTELISTS} = $self->{ATTRIBUTELISTS};
    $clone->{APIOWNER} = $self->{APIOWNER};
    $clone->{APIUID} = $self->{APIUID};
    $clone->{LINKUID} = undef; # Don't ever copy this.
    $clone->{ORIGCLASS} = $self->{ORIGCLASS};
    $clone->{ISTEMPLATE} = $self->{ISTEMPLATE};
    $clone->{VALUE} = $self->{VALUE};
    $clone->{RETURNTYPE} = $self->{RETURNTYPE};
    my $ptref = $self->{PARSETREE};
    if ($ptref) {
	bless($ptref, "HeaderDoc::ParseTree");
	$clone->{PARSETREE} = $ptref; # ->clone();
	my $pt = ${$ptref};
	if ($pt) {
		$pt->addAPIOwner($clone);
	}
    }
    $clone->{TAGGEDPARAMETERS} = ();
    if ($self->{TAGGEDPARAMETERS}) {
        my @params = @{$self->{TAGGEDPARAMETERS}};
        foreach my $param (@params) {
	    my $cloneparam = $param->clone();
	    push(@{$clone->{TAGGEDPARAMETERS}}, $cloneparam);
	    $cloneparam->apiOwner($clone);
	}
    }
    $clone->{PARSEDPARAMETERS} = ();
    if ($self->{PARSEDPARAMETERS}) {
        my @params = @{$self->{PARSEDPARAMETERS}};
        foreach my $param (@params) {
	    my $cloneparam = $param->clone();
	    push(@{$clone->{PARSEDPARAMETERS}}, $cloneparam);
	    $cloneparam->apiOwner($clone);
        }
    }
    $clone->{VARIABLES} = ();
    if ($self->{VARIABLES}) {
        my @local_variables = @{$self->{VARIABLES}};
        foreach my $local_variable (@local_variables) {
	    my $cloned_local_variable = $local_variable->clone();
	    push(@{$clone->{VARIABLES}}, $cloned_local_variable);
	    $cloned_local_variable->apiOwner($clone);
	}
    }
    $clone->{CONSTANTS} = ();
    if ($self->{CONSTANTS}) {
        my @params = @{$self->{CONSTANTS}};
        foreach my $param (@params) {
	    my $cloneparam = $param->clone();
	    push(@{$clone->{CONSTANTS}}, $cloneparam);
	    $cloneparam->apiOwner($clone);
	}
    }

    $clone->{LINENUM} = $self->{LINENUM};
    $clone->{CASESENSITIVE} = $self->{CASESENSITIVE};
    $clone->{KEYWORDHASH} = $self->{KEYWORDHASH};
    $clone->{MASTERENUM} = 0; # clones are never the master # $self->{MASTERENUM};
    $clone->{APIREFSETUPDONE} = 0;
    $clone->{APPLEREFISDOC} = $self->{APPLEREFISDOC};
    # $clone->{NOREGISTERUID} = 0;
    # $clone->{SUPPRESSCHILDREN} = 0;

    return $clone;
}

# /*!
#     @abstract
#         Gets/sets the contents of a simple typedef.
#     @param self
#         The (generally 
#         {@link //apple_ref/perl/cl/HeaderDoc::Typedef Typedef})
#         object.
#     @param contents
#         The value to set. (Optional.)
#     @discussion
#         This is populated by the <code>simpleTDcontents</code>
#         field in the parser state object.
#  */
sub typedefContents {
    my $self = shift;
    if (@_) {
	my $newowner = shift;
	$self->{TYPEDEFCONTENTS} = $newowner;
    }
    return $self->{TYPEDEFCONTENTS};
}

# /*!
#     @abstract
#         Gets/sets the original class info.
#     @param self
#         The (generally <code>Function</code>, <code>Method</code>,
#         or <code>Var</code>) object.
#     @param origclass
#         The new value. (Optional.)
#     @discussion
#         When the contents of a class are explicitly included in its
#         subclasses using the <code>\@superclass</code> tag, the inherited methods
#         and similar get the <code>origClass</code> value set to the owning
#         class so that we don't insert an apple_ref marker for
#         inherited content.
#  */
sub origClass {
    my $self = shift;
    if (@_) {
	my $newowner = shift;
	$self->{ORIGCLASS} = $newowner;
    }
    return $self->{ORIGCLASS};
}

# /*!
#     @abstract
#         The HeaderDoc class for this object.
#     @param self
#         The object.
#     @discussion
#         This is used when blessing a reference to a HeaderDoc object.
#         First, bless the object as a <code>HeaderDoc::HeaderElement</code>,
#         then use its <code>CLASS</code> field to re-bless it as
#         the original subclass.
#  */
sub class {
    my $self = shift;
    return $self->{CLASS};
}

# /*!
#     @abstract
#         Returns whether the current function is a constructor or destructor.
#     @param self
#         The (generally <code>Function</code>) object.
#     @return
#         Returns 1 if it is a constructor or destructor, else 0.
#  */
sub constructor_or_destructor {
    my $self = shift;
    my $localDebug = 0;

    if ($self->{CLASS} eq "HeaderDoc::Function") {
	my $apio = $self->apiOwner();
	if (!$apio) {
		print STDERR "MISSING API OWNER\n" if ($localDebug);
		return 0;
	} else {
	    my $apioclass = ref($apio) || $apio;
	    if ($apioclass ne "HeaderDoc::CPPClass") {
		print STDERR "Not in CPP Class\n" if ($localDebug);
		return 0;
	    }
	}
	my $name = $self->rawname();
	print STDERR "NAME: $name : " if ($localDebug);

	if ($name =~ /^~/o) {
		# destructor
		print STDERR "DESTRUCTOR\n" if ($localDebug);
		return 1;
	}
	$name =~ s/^\s*\w+\s*::\s*//so; # remove leading class part, if applicable
	$name =~ s/\s*$//so;

	my $classname = $apio->name();

	if ($name =~ /^\Q$classname\E$/) {
		print STDERR "CONSTRUCTOR\n" if ($localDebug);
		return 1;
	}
	print STDERR "FUNCTION\n" if ($localDebug);
	return 0;
    } elsif ($self->{CLASS} eq "HeaderDoc::Method") {
	# @@@ DAG: If ObjC methods ever get any syntactically-special
	# constructors or destructors, add the checks here.
	return 0;
    } else {
	return 0;
    }
}

# /*!
#     @abstract
#         Gets/sets the array of local variables associated with a
#               function, etc.
#     @param self
#         The (generally <code>Function</code>) object.
#     @param variables
#         The array of variables to set. (Optional.)
#  */
sub variables {
    my $self = shift;
    if (@_) { 
	@{ $self->{VARIABLES} } = @_;
    }
    # foreach my $const (@{ $self->{VARIABLES}}) {print STDERR $const->name()."\n";}
    ($self->{VARIABLES}) ? return @{ $self->{VARIABLES} } : return ();
}

# /*!
#     @abstract
#         Gets/sets the array of constants associated with an
#               <code>APIOwner</code>, <code>Enum</code>, etc.
#     @param self
#         The object.
#     @param constants
#         The array of constants to set. (Optional.)
#  */
sub constants {
    my $self = shift;
    if (@_) { 
        @{ $self->{CONSTANTS} } = @_;
    }
    # foreach my $const (@{ $self->{CONSTANTS}}) {print STDERR $const->name()."\n";}
    ($self->{CONSTANTS}) ? return @{ $self->{CONSTANTS} } : return ();
}

# /*!
#     @abstract
#         Gets/sets whether this array is the "master" enum.
#     @param self
#         The (generally <code>Enum</code>) object.
#     @param newvalue
#         The value to set. (Optional.)
#     @discussion
#         This is legacy cruft that was once used for apple_ref purposes.
#         it is no longer used and should be removed in the future.
#  */
sub masterEnum {
    my $self = shift;
    if (@_) {
	my $masterenum = shift;
	$self->{MASTERENUM} = $masterenum;
    }
    return $self->{MASTERENUM};
}

# /*!
#     @abstract
#         Adds a variable to the array of local variables associated with a
#               function, etc.
#     @param self
#         The (generally <code>Function</code>) object.
#     @param variables
#         An array of variables to add.
#  */
sub addVariable {
    my $self = shift;
    if (@_) { 
	foreach my $item (@_) {
		# print "ADDED $item to $self\n";
		if ($self->can("addToVars")) {
			$self->addToVars($item);
        	} else {
			my $desc = $item->abstract();
			$item->discussion($desc);
			$item->abstract("");
			push (@{$self->{VARIABLES}}, $item);
		}
		# print "COUNT: ".$#{$self->{VARIABLES}}."\n";
	}
    }
}

# /*!
#     @abstract
#         Adds a constant to the array of constants associated with an
#         object.
#     @param self
#         This object.
#     @param constants
#         An array of constants to add.
#  */
sub addConstant {
    my $self = shift;
    if (@_) { 
	foreach my $item (@_) {
        	push (@{$self->{CONSTANTS}}, $item);
		# warn("Added constant to $self\n");
	}
    }
    return @{ $self->{CONSTANTS} };
}

# /*!
#     @abstract
#         Adds a field to the array of fields associated with an
#         object.
#     @param self
#         This object.
#     @param fields
#         An array of fields to add.
#  */
sub addToFields {
    my $self = shift;
    if (@_) { 
        push (@{$self->{FIELDS}}, @_);
    }
    return @{ $self->{FIELDS} };
}

# /*!
#     @abstract
#         Gets/sets whether this is a template function/class.
#     @param self
#         This object.
#     @param istemplate
#         The value to set. (Optional.)
#  */
sub isTemplate {
    my $self = shift;
    if (@_) {
        $self->{ISTEMPLATE} = shift;
    }
    return $self->{ISTEMPLATE};
}

# /*!
#     @abstract
#         Gets/sets whether this is a callback.
#     @param self
#         This object.
#     @param istemplate
#         The value to set. (Optional.)
#  */
sub isCallback {
    my $self = shift;
    if (@_) {
        $self->{ISCALLBACK} = shift;
    }
    if ($self->can("type")) {
	if ($self->type() eq "callback") { return 1; }
    }
    return $self->{ISCALLBACK};
}

# /*!
#     @abstract
#         Returns whether this is an API owner (class, header, etc.)
#     @param self
#         This object.
#     @discussion
#         This is overridden by the
#         {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner}
#         class.
#  */
sub isAPIOwner {
    return 0;
}

# /*!
#     @abstract
#         Parent discussion for inheritance
#     @discussion
#         We don't want to show this, so we can't use an
#        attribute.  This is private.
#  */
sub inheritDoc {
    my $self = shift;

    if (@_) {
        my $inheritDoc = shift;
        $self->{INHERITDOC} = $inheritDoc;
    }
    return $self->{INHERITDOC};
}

# /*!
#     @abstract
#         The line number where a declaration began relative to the block.
#     @discussion
#         We don't want to show this, so we can't use an
#        attribute.  This is private.
#  */
sub linenuminblock
{
    my $self = shift;

    if (@_) {
        my $linenum = shift;
        $self->{RAWLINENUM} = $linenum;
    }
    return $self->{RAWLINENUM};
}


# /*!
#     @abstract
#         The line number of the start of the block containing a declaration.
#     @discussion
#         We don't want to show this, so we can't use an
#         attribute.  This is private.
#  */
sub blockoffset
{
    my $self = shift;
    # my $localDebug = 0;

    if (@_) {
        my $linenum = shift;
        $self->{BLOCKOFFSET} = $linenum;

	# cluck "For object ".$self->name()." set blockoffset to $linenum.\n" if ($localDebug);
    }
    return $self->{BLOCKOFFSET};
}


# /*!
#     @abstract
#         The line number where a declaration began.
#     @discussion
#         We don't want to show this, so we can't use an
#         attribute.  This is private.
#
#         This uses <code>linenuminblock</code> and <code>blockoffset</code> to get the values.
#         Setting this attribute is no longer supported.
#  */
sub linenum {
    my $self = shift;

    if (@_) {
        my $linenum = shift;
        $self->{LINENUM} = $linenum;
    }
    # return $self->{LINENUM};
    return $self->{RAWLINENUM} + $self->{BLOCKOFFSET};
}

# /*!
#     @abstract
#         Value for constants, variables, etc.
#     @discussion
#         This is not typically shown in the HTML output, so this can't be
#         stored in a normal attribute.
#  */
sub value {
    my $self = shift;

    if (@_) {
        my $value = shift;
        $self->{VALUE} = $value;
    }
    return $self->{VALUE};
}

# /*!
#     @abstract
#         Gets/sets the output format (html, xml).
#     @param self
#         This object.
#     @param format
#         The value to set. (Optional.)
#  */
sub outputformat {
    my $self = shift;

    if (@_) {
        my $outputformat = shift;
        $self->{OUTPUTFORMAT} = $outputformat;
    } else {
    	my $o = $self->{OUTPUTFORMAT};
		return $o;
	}
}

# /*!
#     @abstract
#         Gets/sets the USESTDOUT flag (0/1).
#     @param self
#         This object.
#     @param format
#         The value to set. (Optional.)
#     @discussion
#         If 0, the output is sent to files as usual.
#         If 1, the XML output is sent to stdout.
#  */
sub use_stdout {
    my $self = shift;

    if (@_) {
        my $use_stdout = shift;
        $self->{USESTDOUT} = $use_stdout;
    } else {
    	my $o = $self->{USESTDOUT};
		return $o;
	}
}

# /*!
#     @abstract
#         Gets/sets the function body for a function.
#     @param self
#         This object.
#     @param format
#         The value to set. (Optional.)
#  */
sub functionContents {
    my $self = shift;

    if (@_) {
	my $string = shift;
        $self->{FUNCTIONCONTENTS} = $string;
	# cluck("SET CONTENTS OF $self TO $string\n");
    }
    return $self->{FUNCTIONCONTENTS};
}

# /*!
#     @abstract
#         Gets/sets the full path to a header file.
#     @param self
#         This object.
#     @param path
#         The path to set. (Optional.)
#     @discussion
#         This contains the path as passed in on the command
#         line, including any leading path components.
#  */
sub fullpath {
    my $self = shift;

    if (@_) {
        my $fullpath = shift;
        $self->{FULLPATH} = $fullpath;
    } else {
    	my $n = $self->{FULLPATH};
		return $n;
	}
}

# /*!
#     @abstract
#         Gets/sets the filename for a header file.
#     @param self
#         This object.
#     @param filename
#         The filename to set. (Optional.)
#     @discussion
#         This contains the filename as passed in on the command
#         line, with any leading path components stripped off.
#  */
sub filename {
    my $self = shift;

    if (@_) {
        my $filename = shift;
        $self->{FILENAME} = $filename;
    } else {
    	my $n = $self->{FILENAME};
		return $n;
	}
}

# /*!
#     @abstract
#         Gets/sets the name of the first constant in an enumeration.
#     @param self
#         This object.
#     @param firstconstname
#         The value to set. (Optional.)
#     @discussion
#         If no name could be determiend for an enumeration, this value is
#         used.
#  */
sub firstconstname {
    my $self = shift;
    my $localDebug = 0;

    my($class) = ref($self) || $self;

    print STDERR "$class\n" if ($localDebug);

    if (@_) {
        my $name = shift;
	print STDERR "Set FIRSTCONSTNAME to $name\n" if ($localDebug);
	$self->{FIRSTCONSTNAME} = $name;
    }
    return $self->{FIRSTCONSTNAME};
}

# /*!
#     @abstract
#         Gets/sets the name of this function/var/class/*.
#     @param self
#         This object.
#     @param name
#         The value to set. (Optional.)
#     @discussion
#         This function returns the name as taken from the
#         HeaderDoc comment.  If the nameline contains multiple
#         words and there are additional nonempty discussion
#         lines, the entire name line is treated as the
#         name, and the nameline discussion is appended to
#         the value returned by {@link mediumrarename} to
#         obtain the value that this function returns.
#
#         An explicit <code>\@discussion</code> tag forces the
#         nameline discussion to be treated as part of the name
#         even if the contents of the discussion tag are empty.
#
#         This may be a separate value from the <code>rawname</code>
#         and <code>rawname_extended</code> values.
#  */
sub name {
    my $self = shift;
    my $localDebug = 0;

    # cluck("namebacktrace\n");

    my($class) = ref($self) || $self;

    print STDERR "IN NAME: $class\n" if ($localDebug);

    if (@_) {
        my $name = shift;

	# cluck("name set to $name\n");

	my $oldname = $self->{NAME};
	# cluck("namebacktrace: set to \"$name\", prev was \"$oldname\".\n");
	my $fullpath = $self->fullpath();
	my $linenum = $self->linenum();
	my $class = ref($self) || $self;

	print STDERR "NAMESET: $self -> $name\n" if ($localDebug);

	if (!($class eq "HeaderDoc::Header") && ($oldname && length($oldname)) && !length($self->{FORCENAME})) {
		# Don't warn for headers, as they always change if you add
		# text after @header.  Also, don't warn if the new name
		# contains the entire old name, to avoid warnings for
		# multiword names.  Otherwise, warn the user because somebody
		# probably put multiple @function tags in the same comment
		# block or similar....

		my $nsoname = $oldname;
		my $nsname = $name;
		if ($class =~ /^HeaderDoc::ObjC/) {
			$nsname =~ s/\s//g;
			$nsoname =~ s/\s//g;
		} elsif ($class =~ /^HeaderDoc::Method/) {
			$nsname =~ s/:$//g;
			$nsoname =~ s/:$//g;
		# } else {
			# warn("CLASS: $class\n");
		}

		if ($nsname !~ /\Q$nsoname\E/) {
			if (!$HeaderDoc::ignore_apiuid_errors) {
				warn("$fullpath:$linenum: warning: Name being changed ($oldname -> $name)\n");
			}
		} elsif (($class eq "HeaderDoc::CPPClass" || $class =~ /^HeaderDoc::ObjC/o) && $name =~ /:/o) {
			warn("$fullpath:$linenum: warning: Class name contains colon, which is probably not what you want.\n");
		}
	} elsif (length($self->{FORCENAME})) {
        $name = $self->{FORCENAME};
    }

	$name =~ s/\n$//sgo;
	$name =~ s/\s$//sgo;

        $self->{NAME} = $name;
    }

    my $n = $self->{NAME};

    # Append the rest of the name line if necessary.
    if ($self->{DISCUSSION_SET}) {
	# print STDERR "DISCUSSION IS: ".$self->{DISCUSSION}."\n";
	# print STDERR "ISAPIO: ".$self->isAPIOwner()."\n";
	# print STDERR "ISFW: ".$self->isFramework()."\n";
	if ((!$HeaderDoc::ignore_apiowner_names) || (!$self->isAPIOwner() && ($HeaderDoc::ignore_apiowner_names != 2)) || $self->isFramework()) {
		print STDERR "NAMELINE DISCUSSION for $self CONCATENATED (".$self->{NAMELINE_DISCUSSION}.")\n" if ($localDebug);
		print STDERR "ORIGINAL NAME WAS \"$n\"\n" if ($localDebug);
		if (length($self->{NAMELINE_DISCUSSION})) {
			$n .= " ".$self->{NAMELINE_DISCUSSION};
		}
	}
    }

    if ($class eq "HeaderDoc::Function" && $self->conflict()) {
	$n .= "(";
	$n .= $self->getParamSignature(1);
	$n .= ")";
    }

    # If there's nothing to return, try returning the first constant in the case of enums.
    if ($n !~ /\S/) {
	$n = $self->firstconstname();
    }

    return $n;
}

# /*!
#     @abstract
#         Gets/sets the SEEALSODUPCHECK value.
#     @param self
#         This object.
#     @param name
#         The value to set. (Optional.)
#     @discussion
#         This is used when doing cross-linking between
#         multiple objects (in {@link blockParseOutside})
#         to ensure that duplicate entries are not inserted.
#  */
sub seeDupCheck {
    my $self = shift;
    my $name = shift;
    my $set = 0;
    if (@_) {
	$set = shift;
    }

    my %dupcheck = ();
    if ($self->{SEEALSODUPCHECK}) {
	%dupcheck = %{$self->{SEEALSODUPCHECK}};
    }

    my $retval = $dupcheck{$name};

    if ($set) {
	$dupcheck{$name} = $name;
    }

    $self->{SEEALSODUPCHECK} = \%dupcheck;

    return $retval;
}

# /*!
#     @abstract
#         Add see/seealso (JavaDoc compatibility enhancement)
#  */
sub see {
    my $self = shift;
    my $liststring = shift;
    my $type = "See";
    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();    

    my $dupDebug = 0;

    print STDERR "see called\n" if ($dupDebug);

#    $liststring =~ s/<br>/\n/sg; # WARNING \n would break attributelist!

    # Is it a see or seealso?

    if ($liststring =~ s/^seealso\s+//iso) {
	$type = "See Also";
    } else {
	$liststring =~ s/^see\s+//iso;
    }
    # $liststring =~ s/(\n|\r|\<br\>|\s)+$//sgi;
    my @items = split(/[\n\r]/, $liststring);

# print STDERR "LS: $liststring\n";
    foreach my $item (@items) {
      if ($item !~ /^\/\/\w+\// && $item =~ /\S/) { ## API anchor (apple_ref or other)
	# print STDERR "NO API ANCHOR: $item\n";

	my @list = split(/\s+/, $item, 2);

	# Generate it with its own name as the title.  We're just going
	# to rip it back apart anyway.
	my $see = $list[0];
	my $name = $list[1];

	# my $apiref = $self->genRefHTML("", $see, $see);

	if ($name !~ /\S/) { $name = $see; }

	# print STDERR "NAME: $name SEE: $see\n";

	print STDERR "Checking \"$see\" for duplicates.\n" if ($dupDebug);
	if (!$self->seeDupCheck($see)) {
		# my $apiuid = $apiref;
		# $name =~ s/\s+/ /sg;
		# $name =~ s/\s+$//sg;
		# $apiuid =~ s/^.*<!--\s*a\s+logicalPath\s*=\s*\"//so;
		# $apiuid =~ s/"(?:\s+machineGenerated=\"[^"]+\")\s*-->\s*.*?\s*<!--\s*\/a\s*-->//s;
		# print STDERR "APIREF: $apiref\n";
		# print STDERR "NAME: $name APIUID: $apiuid\n";

		my $apiuid = $see;

		$self->attributelist($type, $name."\n$apiuid");
		$self->seeDupCheck($see, 1);
		print STDERR "Not found.  Adding.\n" if ($dupDebug);
	} else {
		print STDERR "Omitting duplicate \"$see\"[1]\n" if ($dupDebug);
	}
      } elsif ($item =~ /\S/) {
	# print STDERR "API ANCHOR: $item\n";

	$item =~ s/^\s*//s;
	$item =~ s/\s+/ /sg;
	my @parts = split(/\s+/, $item, 2);
	my $name = $parts[1];
	$name =~ s/\s+$//sg;

	print STDERR "Checking \"$name\" for duplicates.\n" if ($dupDebug);
	if (!$self->seeDupCheck($name)) {
		# print STDERR "$type -> '".$name."' -> '".$parts[0]."'\n";

        	$self->attributelist($type, $name."\n".$parts[0]);
		$self->seeDupCheck($name, 1);
		print STDERR "Not found.  Adding.\n" if ($dupDebug);
	} else {
		print STDERR "Omitting duplicate \"$name\"[2]\n" if ($dupDebug);
	}
      }
    }

}

# /*!
#     @abstract
#         Returns the "medium rare" name.
#     @param self
#         This object.
#     @discussion
#         Returns the value of the name from the HeaderDoc comment without
#         appending the nameline discussion (ever).  See
#         {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/name//() name}
#         for more explanation.
#  */
sub mediumrarename {
    my $self = shift;
    return $self->{NAME};
}

# /*!
#     @abstract
#         Returns the "raw" name.
#     @param self
#         This object.
#     @discussion
#         Returns the value of the name from the HeaderDoc comment without further
#         processing.
#
#         If no "raw" name was set, returns the main name (from {@link mediumrarename}.
#  */
sub rawname {
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
	my $name = shift;
	$self->{RAWNAME} = $name;
	print STDERR "RAWNAME: $name\n" if ($localDebug);
    }

    my $n = $self->{RAWNAME};
    if (!($n) || !length($n)) {
	$n = $self->{NAME};
    }


    return $n;
}

# /*!
#     @abstract
#         Clears the group for this object.
#     @param self
#         This object.
#  */
sub clearGroup {
    my $self = shift;
    $self->{GROUP} = undef;
}

# /*!
#     @abstract
#         Gets/sets the group for this object and adds it to the group object.
#     @param self
#         This object.
#     @param group
#         The group to set for this object. (Optional.)
#  */
sub group {
    my $self = shift;

    if (@_) {
        my $group = shift;
        $self->{GROUP} = $group;
	if (!$self->isAPIOwner()) {
		# cluck("SELF: $self\nAPIO: ".$self->apiOwner()."\n");
		# $self->dbprint();
		# $self->apiOwner()->addGroup($group);
		$self->apiOwner()->addToGroup($group, $self);
	}
    } else {
    	my $n = $self->{GROUP};
		return $n;
	}
}

# /*!
#     @abstract
#         This function adds an attribute for a class or header.
#     @param name
#         The name of the attribute to be added
#     @param attribute
#         The contents of the attribute
#     @param long
#         0 for single line, 1 for multi-line.
#  */
sub attribute {
    my $self = shift;
    my $name = shift;
    my $attribute = shift;
    my $long = shift;
    my $programmatic = 0;
    if (@_) {
	$programmatic = shift;
    }
    my $localDebug = 0;

    cluck("Attribute added:\nNAME => $name\nATTRIBUTE => $attribute\nLONG => $long\nPROGRAMMATIC => $programmatic\n") if ($localDebug);

    my %attlist = ();
    if ($long) {
        if ($self->{LONGATTRIBUTES}) {
	    %attlist = %{$self->{LONGATTRIBUTES}};
        }
    } else {
        if ($self->{SINGLEATTRIBUTES}) {
	    %attlist = %{$self->{SINGLEATTRIBUTES}};
        }
	$attribute =~ s/\n/ /sgo;
	$attribute =~ s/^\s*//so;
	$attribute =~ s/\s*$//so;
    }

    if ($programmatic || !$long) {
	$attlist{$name}=$attribute;
    } else {
	$attlist{$name}=filterHeaderDocTagContents($attribute);
    }

# print STDERR "AL{$name}: ".$attlist{$name}."\n";

    if ($long) {
        $self->{LONGATTRIBUTES} = \%attlist;
    } else {
        $self->{SINGLEATTRIBUTES} = \%attlist;
    }

    my $temp = $self->getAttributes(2);
    print STDERR "Attributes: $temp\n" if ($localDebug);

}

# /*!
#     @abstract
#         Returns the attributes for this object, formatted in HTML
#         for output.
#     @param self
#         This HeaderDoc API object.
#     @param long
#         Pass 0 for short attributes by themselves, 1 for long
#         attributes by themselves, or 2 for both short and long
#         attributes.
#  */
sub getAttributes
{
    my $self = shift;
    my $long = shift;
    my %attlist = ();
    my $localDebug = 0;
    my $xml = 0;
    my $newTOC = $HeaderDoc::newTOC;

    my $class = ref($self) || $self;
    my $uid = $self->apiuid();

    # Only use this style for API Owners.
    if (!$self->isAPIOwner()) { $newTOC = 0; }

    my $apiowner = $self->apiOwner();
    if ($apiowner->outputformat() eq "hdxml") { $xml = 1; }
    my $first = 1;

    # my $declaredin = $self->declaredIn();
	# print STDERR "DECLARED IN: $declaredin\n";

    my $maybe = 0;

    my $retval = "";
    if ($long != 1) {
        if ($self->{SINGLEATTRIBUTES}) {
	    %attlist = %{$self->{SINGLEATTRIBUTES}};
        }

        foreach my $key (sort strcasecmp keys %attlist) {
	    my $keyname = $key; # printed name.
	    if ($key eq "Superclass" && ($HeaderDoc::superclassName =~ /\S/)) {
		$keyname = $HeaderDoc::superclassName;
	    }
	    print STDERR "KEY NAME CHANGED TO \"$keyname\"\n" if ($localDebug);

	    my $value = $attlist{$key};
	    my $newatt = $value;
	    if (($key eq "Superclass" || $key eq "Extends&nbsp;Class" || $key eq "Extends&nbsp;Protocol" || $key eq "Conforms&nbsp;to" || $key eq "Implements&nbsp;Class")) {
		my $classtype = "class";
		my $selfclass = ref($self) || $self;
		if ($selfclass =~ /HeaderDoc::ObjC/) {
			if ($key eq "Conforms&nbsp;to" || $key eq "Extends&nbsp;Protocol") {
				$classtype = "protocol";
			}
		}
		my @valparts = split(/\cA/, $value);
		$newatt = "";
		# print STDERR "CLASSTYPE: $classtype\n";
		foreach my $valpart (@valparts) {
			# print STDERR "VALPART: $valpart\n";
			if (length($valpart)) {
				$valpart =~ s/^\s*//s;
				if ($valpart =~ /^(\w+)(\W.*)$/) {
					# print STDERR "1: $1 2: $2\n";
					$newatt .= $self->genRef("$classtype", $1, $1).$self->textToXML($2);
				} else {
					$newatt .= $self->genRef("$classtype", $valpart, $self->htmlToXML($valpart));
				}
				if (!$xml) {
					$newatt  .= ", ";
				}
			}
		}
		$newatt =~ s/, $//s;
		if ($xml) {
			$keyname =~ s/&nbsp;/ /sg;
		}
	    } elsif ($key eq "Path To Headers" && !$xml) {
		$newatt = "<!-- headerDoc=headerpath;uid=".$uid.";name=start -->\n$value\n<!-- headerDoc=headerpath;uid=".$uid.";name=end -->\n";
	    } elsif ($key eq "Framework Path" && !$xml) {
		$newatt = "<!-- headerDoc=frameworkpath;uid=".$uid.";name=start -->\n$value\n<!-- headerDoc=frameworkpath;uid=".$uid.";name=end -->\n";
	    } elsif ($key eq "Requested Copyright" && !$xml) {
		$newatt = "<!-- headerDoc=frameworkcopyright;uid=".$uid.";name=start -->\n$value\n<!-- headerDoc=frameworkpath;uid=".$uid.";name=end -->\n";
	    } elsif ($key eq "Requested UID" && !$xml) {
		$newatt = "<!-- headerDoc=frameworkuid;uid=".$uid.";name=start -->\n$value\n<!-- headerDoc=frameworkuid;uid=".$uid.";name=end -->\n";
	    } elsif ($xml) {
		$keyname = $self->htmlToXML($keyname);
		$newatt = $self->htmlToXML($newatt);
	    } else {
		print STDERR "KEY: $key\n" if ($localDebug);
	    }

	    if ($xml) {
		$retval .= "<attribute><name>$keyname</name><value>$newatt</value></attribute>\n";
	    } else {
		if ($newTOC) {
			if ($first) { $retval .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n"; $first = 0; }
			$retval .= "<tr><td scope=\"row\"><b>$keyname:</b></td><td><div style=\"margin-bottom:1px\"><div class=\"content_text\">$newatt</div></div></td></tr>\n";
		} else {
			$retval .= "<p><b>$keyname</b></p>\n\n<p>$newatt</p>\n";
		}
	    }
        }

	my $declaredin = $self->declaredIn();
	if ($declaredin && (
		# $HeaderDoc::enable_custom_references || 
		$self->isAPIOwner())) {

	    my $blockclass = "\$\$customref_show_block\@\@";
	    my $rowclass = " class=\"customref_show_row\"";

	    if ($self->isAPIOwner()) {
		$blockclass = "";
		$rowclass = "";
	    }

	    if (!$xml) {
		if ($newTOC) {
			if ($first) { $retval .= "<div class=\"".$blockclass."spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n"; $first = 0; $maybe = 1; }
			$retval .= "<tr$rowclass><td scope=\"row\"><b>Declared In:</b></td><td><div style=\"margin-bottom:1px\"><div class=\"content_text\">$declaredin</div></div></td></tr>\n";
		} else {
			$retval .= "<p><b>Declared In</b></p><p>$declaredin</p>\n";
		}
	    }
	# cluck("Backtrace\n");
	# warn "DECLAREDIN: $declaredin\n";
	# warn "RV: $retval\n";
	}
    }

    if ($long != 0) {
        if ($self->{LONGATTRIBUTES}) {
	    %attlist = %{$self->{LONGATTRIBUTES}};
        }

        foreach my $key (sort strcasecmp keys %attlist) {
	    my $value = $attlist{$key};
	    if ($xml) {
		$key = $self->htmlToXML($key);
		$value = $self->htmlToXML($value);
		$retval .= "<longattribute><name>$key</name><value>$value</value></longattribute>\n";
	    } else {
		$maybe = 0;
		if ($newTOC) {
			if ($first) { $retval .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n"; $first = 0; }
			$retval .= "<tr><td scope=\"row\"><b>$key:</b></td><td><div style=\"margin-bottom:1px\"><div class=\"content_text\">$value</div></div></td></tr>\n";
		} else {
			$retval .= "<p><b>$key</b></p>\n\n<p>$value</p>\n";
		}
	    }
        }
    }
    if ((!$xml) && ($newTOC && !$first)) {
	$retval .= "</table></div>\n";
    } # elsif (!$newTOC) { $retval = "<p>$retval</p>"; } # libxml parser quirk workaround

    # if ((!$xml) && $HeaderDoc::enable_custom_references) {
	# # This only gets inserted if the entire spec box should go away.
	# if ($maybe) {
		# $retval =~ s/\$\$customref_show_block\@\@/customref_show_block /sg;
	# } else {
		# $retval =~ s/\$\$customref_show_block\@\@//sg;
	# }
    # }

    return $retval;
}

# /*!
#     @abstract
#         Returns the value of an attribute in
#               the object's long or short attributes whose
#               name matches the one passed in.
#     @param self
#         This object.
#     @param name
#         The name to look for.
#  */
sub checkShortLongAttributes
{
    my $self = shift;
    my $name = shift;
    my $localDebug = 0;

    my %singleatts = ();
    if ($self->{SINGLEATTRIBUTES}) {
	%singleatts = %{$self->{SINGLEATTRIBUTES}};
    }
    my %longatts = ();
    if ($self->{LONGATTRIBUTES}) {
	%longatts = %{$self->{LONGATTRIBUTES}};
    }

    my $value = $singleatts{$name};
    if ($value && length($value)) {return $value;}

    $value = $longatts{$name};
    if ($value && length($value)) {return $value;}

    return 0;
}

# /*!
#     @abstract
#         Returns the value of an attribute list whose
#               name matches the one passed in.
#     @param self
#         This object.
#     @param name
#         The name to look for.
#  */
sub checkAttributeLists
{
    my $self = shift;
    my $name = shift;
    my $localDebug = 0;

    my %attlists = ();
    if ($self->{ATTRIBUTELISTS}) {
	%attlists = %{$self->{ATTRIBUTELISTS}};
    }

    # print STDERR "list\n";
    my $retval = "";

    my $value = $attlists{$name};
    if ($value) { return $value; }

    return 0;
}

# /*!
#     @abstract
#         Returns the attribute lists for this object.
#     @param self
#         This object.
#     @param composite
#          Pass 1 to obtain the list for the composite page,
#          else 0.  Used for generating API references for
#          any <code>#define</code> declarations in define blocks.
#  */
sub getAttributeLists
{
    my $self = shift;
    my $composite = shift;
    my $localDebug = 0;
    my $xml = 0;
    my $newTOC = $HeaderDoc::newTOC;

    my $uid = $self->apiuid();

    my $isFramework = 0;
    if ($self->can('isFramework') && $self->isFramework()) {
	$isFramework = 1;
    }

    # Only use this style for API Owners.
    if (!$self->isAPIOwner()) { $newTOC = 0; }

    my $apiowner = $self->apiOwner();
    if (!$apiowner) {
	cluck("No api owner for $self\n");
    }
    if ($apiowner->outputformat() eq "hdxml") { $xml = 1; }

    my %attlists = ();
    if ($self->{ATTRIBUTELISTS}) {
	%attlists = %{$self->{ATTRIBUTELISTS}};
    }

    # print STDERR "list\n";
    my $retval = "";
    my $first = 1;
    # print STDERR "START OF SORTED LIST\n";
    foreach my $key (sort strcasecmp (keys %attlists)) {
	# print STDERR "KEY: $key\n";
	my $prefix = "";
	my $suffix = "";

	if ($isFramework && ($key eq "See" || $key eq "See Also")) {
		$prefix = "<!-- headerDoc=frameworkrelated;uid=".$uid.";name=start -->\n";
		$suffix = "\n<!-- headerDoc=frameworkrelated;uid=".$uid.";name=end -->\n";
	}

	if ($xml) {
	    $retval .= "<listattribute><name>$key</name><list>\n";
	} else {
	    $retval .= $prefix;
	    if ($newTOC) {
		if ($first) { $retval .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n"; $first = 0; }
		$retval .= "<tr><td scope=\"row\"><b>$key:</b></td><td><div style=\"margin-bottom:1px\"><div class=\"content_text\"><dl>\n";
	    } else {
		$retval .= "<p><b>$key</b></p><div class='list_indent'><dl>\n";
	    }
	}
	print STDERR "key $key\n" if ($localDebug);
	my @list = @{$attlists{$key}};
	foreach my $item (@list) {
	    if ($item !~ /\S/s) { next; }
	    print STDERR "item: $item\n" if ($localDebug);
	    my ($name, $disc, $namedisc) = &getAPINameAndDisc($item, $self->lang());

	    if ($key eq "Included Defines") {
		# @@@ CHECK SIGNATURE
		my $apiref = $self->apiref($composite, "macro", $name);
		$name .= "$apiref";
	    }
	    if ($xml) {
		$name = $self->htmlToXML($name);
		$disc = $self->htmlToXML($disc);
	    }
	    if (($key eq "See Also" || $key eq "See")) {
		$name =~ s/^(\s|<br>|<p>)+//sgio;
		$name =~ s/(\s|<br>|<\/p>)+$//sgio;
		$disc =~ s/^(\s|<br>|<p>)+//sgio;
		$disc =~ s/(\s|<br>|<\/p>)+$//sgio;
		$name =~ s/\cD/ /sgo;

		# print STDERR "DISC: $disc\n";
		if ($xml) {
			$disc = "<hd_link logicalPath=\"$disc\" isseealso=\"yes\">$name</hd_link>";
		} else {
			$name = "<p><hd_link posstarget=\"$disc\">$name</hd_link></p>";
			$disc = "";
		}
	    }
	    if ($xml) {
		$retval .= "<item><name>$name</name><value>$disc</value></item>";
	    } else {
		$retval .= "<dt>$name</dt><dd>$disc</dd>";
	    }
	}
	if ($xml) {
	    $retval .= "</list></listattribute>\n";
	} else {
	    if ($newTOC) {
		$retval .= "</dl></div></div></td></tr>\n";
	    } else {
		$retval .= "</dl></div>\n";
	    }
	    $retval .= $suffix;
	}
    }
    # print STDERR "END OF SORTED LIST\n";
    if ($newTOC) {
	if (!$first) { $retval .= "</table></div>\n"; }
    }
    # print STDERR "done\n";
    return $retval;
}

# /*!
#     @abstract
#         Add an attribute list.
#     @param name
#         The name of the list
#     @param attribute
#          A string in the form "term description..."
#          containing a term and description to be inserted
#          into the list named by name.
#  */
sub attributelist {
    my $self = shift;
    my $name = shift;
    my $attribute = shift;

    my %attlists = ();

    # cluck "Add attributelist MAPPING $name -> $attribute\n";

    if ($self->{ATTRIBUTELISTS}) {
        %attlists = %{$self->{ATTRIBUTELISTS}};
    }

    my @list = ();
    my $listref = $attlists{$name};
    if ($listref) {
	@list = @{$listref};
    }
    push(@list, filterHeaderDocTagContents($attribute));

    $attlists{$name}=\@list;
    $self->{ATTRIBUTELISTS} = \%attlists;
    # print STDERR "AL = $self->{ATTRIBUTELISTS}\n";

    # print STDERR $self->getAttributeLists()."\n";
}

# /*!
#     @abstract
#         Gets/sets the API owner for this object.
#     @param self
#         This object.
#     @param owner
#          The {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner} object
#          to set as this object's API owner.
#  */
sub apiOwner {
    my $self = shift;
    if (@_) {
	my $temp = shift;
	$self->{APIOWNER} = $temp;
    }
    return $self->{APIOWNER};
}

# use Devel::Peek;

# /*!
#     @abstract
#         Generates the API ref (apple_ref) for a function, data type, etc.
#     @param self
#         This object.
#     @param composite
#          Set to 1 for the composite page (if <code>classAsComposite</code> is
#          not 1), else 0.
#  */
sub apiref {
    my $self = shift;
    # print STDERR "IY0\n"; Dump($self);
    my $filename = $self->filename();
    my $linenum = $self->linenum();
    my $composite = shift;
    my $args = 0;
    my $type = "";
    my $apiowner = $self->apiOwner();
    # print STDERR "IY0a\n"; Dump($self);
    my $owningclass = ref($apiowner) || $self;
    my $paramSignature = "";
    # print STDERR "IY1\n"; Dump($self);

    if (@_) {
      $args = 1;
      $type = shift;
      if (@_) {
	$paramSignature = shift;
      }
    } else {
	my $uid = $self->apiuid();
	if ($uid =~ /\/\/.*?\/.*?\/(.*?)\//o) {
		$type = $1;
	}
    }

# print STDERR "DEBUG: SELF: $self NAME: ".$self->name()." FILENAME: $filename LINENUM: $linenum\n";
# print STDERR "DEBUG: COMPOSITE: $composite PARAMSIGNATURE: $paramSignature TYPE: $type\n";

    # Don't provide API refs for inherited data or functions.
    my $forceuid = "";
    if ($self->origClass() ne "") {
	$forceuid = $self->generateLinkUID($composite);
    }

    # we sanitize things now.
    # if ($paramSignature =~ /[ <>\s\n\r]/o) {
	# my $fullpath = $self->fullpath();
	# warn("$fullpath:$linenum:apiref: bad signature \"$paramSignature\".  Dropping ref.\n");
	# return "";
    # }

    # print STDERR "IY3\n"; Dump($self);
    my $uid = "";
    if ($args && !$forceuid) {
      # Do this first to assign a UID, even if we're doing the composite page.
      $uid = $self->apiuid($type, $paramSignature);
    } else {
      $uid = $self->apiuid();
    }
    # print STDERR "IY4\n"; Dump($self);

# print STDERR "COMPO: $composite CAC: ".$HeaderDoc::ClassAsComposite."\n";

    if ($composite && !$HeaderDoc::ClassAsComposite) {
	$uid = $self->compositePageUID();
    } elsif (!$composite && $HeaderDoc::ClassAsComposite) {
	# The composite page is the master, so give the individual
	# pages composite page UIDs.  These never get generated
	# anyway.
	$uid = $self->compositePageUID();
    }
    if ($forceuid) { $uid = $forceuid; }
    # print STDERR "IY5\n"; Dump($self);

    my $ret = "";
    if (length($uid)) {
	my $name = $self->name();
	if ($self->can("rawname")) {
		if (!$self->{DISCUSSION} || !$self->{NAMELINE_DISCUSSION}) {
			$name = $self->rawname();
		}
	}
	my $extendedname = $name;
	# print STDERR "NAME: ".$self->name()."\n";
	# print STDERR "RAWNAME: ".$self->rawname()."\n";
	if ($owningclass ne "HeaderDoc::Header" && $self->sublang() ne "C") {
		# Don't do this for COM interfaces and C pseudoclasses
		$extendedname = $apiowner->rawname() . "::" . $name;
	}
	# $extendedname =~ s/\s//sgo;
	$extendedname =~ s/<.*?>//sgo;
        $extendedname =~ s/;//sgo;
	my $uidstring = "";
	my $indexgroup = $self->indexgroup();
	if (length($uid)) { $uidstring = " uid=$uid; "; }
	if (length($indexgroup)) { $uidstring .= " indexgroup=$indexgroup; "; }

	# if ($type eq "") {
		# cluck("empty type field\n");
	# }

	my $fwshortname = "";
	if ($self->isFramework()) {
		$fwshortname = $self->filename();
		$fwshortname =~ s/\.hdoc$//so;
		$fwshortname = sanitize($fwshortname, 1);
		$fwshortname = "shortname=$fwshortname;";
	}
	$ret .= "<!-- headerDoc=$type; $uidstring $fwshortname name=$extendedname -->\n";

        # Don't add the actual anchor for a framework UID because it would
        # conflict with the page generated by gatherHeaderDoc.
	if (length($uid) && !$self->isFramework()) { $ret .= "<a name=\"$uid\"></a>\n"; }
    }
    # print STDERR "IY8\n"; Dump($self);
    $owningclass = undef;
    # print STDERR "IY9\n"; Dump($self);

    # print STDERR "APIREF: $ret\n";
    return $ret;
}

# /*!
#     @abstract
#         Sets the index group for a class or header.
#     @discussion
#         This allows grouping of headers and/or classes in the main TOC generated by
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}
#         It is unrelated to groupings of functions, etc. within a header.
#  */
sub indexgroup
{
    my $self = shift;
    if (@_) {
	my $group = shift;
	$group =~ s/^\s*//sg;
	$group =~ s/\s*$//sg;
	$group =~ s/;/\\;/sg;
	$group .= " ";
	$self->{INDEXGROUP} = $group;
    }

    my $ret = $self->{INDEXGROUP};

    if (!length($ret)) {
	my $apio = $self->apiOwner();
	if ($apio && ($apio != $self)) {
		return $apio->indexgroup();
	}
    }

    return $ret;
}

# /*!
#     @abstract
#         Generates a special UID for inherited content
#     @param self
#         This object.
#     @param composite
#         Set to 1 if generating for a composite page (if
#         <code>classAsComposite</code> is not 1), else 0.
#  */
sub generateLinkUID
{
    my $self = shift;
    my $composite = shift;

    if ($self->{LINKUID}) {
	# print STDERR "LINKUID WAS ".$self->{LINKUID}."\n";
	if ($composite) {
		return $self->compositePageUID();
	}
	return $self->{LINKUID};
    }

    my $classname = sanitize($self->apiOwner()->rawname(), 1);
    my $name = sanitize($self->rawname(), 1);
    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();    
    my $uniquenumber = $HeaderDoc::uniquenumber++;
    my $uid = "//$apiUIDPrefix/doc/inheritedContent/$classname/$name/$uniquenumber";

    $self->{LINKUID} = $uid;
    # registerUID($uid);

    if ($composite) {
	return $self->compositePageUID()
    }

    return $uid;
}

# /*!
#     @abstract
#         Returns the name of an API element for UID purposes.
#  */
sub apiuidname
{
    my $self = shift;
    my $class = ref($self) || $self;
    my $localDebug = 0;

    my $name = $self->mediumrarename();
    if (!($self->can("conflict")) || ($self->can("conflict") && !($self->conflict()))) {
	print STDERR "No conflict.\n" if ($localDebug);
	$name = $self->rawname();
	if ($class eq "HeaderDoc::ObjCCategory") {
		# Category names are in the form "ClassName(DelegateName)"
		if ($name =~ /\s*\w+\s*\(.+\).*/o) {
			$name =~ s/\s*(\w+)\s*\(\s*(\w+)\s*\).*/$1($2)/o;
		}
	}
	# Silently drop leading and trailing space
	$name =~ s/^\s*//so;
	$name =~ s/\s*$//so;
	# Don't silently drop spaces.
        # We sanitize things now.
	# $name =~ s/\s//sgo;
	# $name =~ s/<.*?>//sgo;
	# if ($name =~ /[ \(\)<>\s\n\r]/o) {
	    # if (!$HeaderDoc::ignore_apiuid_errors) {
		# my $fullpath = $self->fullpath();
		# warn("$fullpath:$linenum:apiref: bad name \"$name\".  Dropping ref.\n");
	    # }
	    # return "";
	# }
	print STDERR "Sanitized name: $name\n" if ($localDebug);
    } else {
	print STDERR "Conflict detected.\n" if ($localDebug);
	my $apiOwner = $self->apiOwner();
	my $apiOwnerClass = ref($apiOwner) || $apiOwner;
	if ($apiOwnerClass eq "HeaderDoc::CPPClass") {
		$name = $self->rawname();
	} else {
		$name =~ s/ //sgo;
	}
	# Silently drop leading and trailing space
	$name =~ s/^\s*//so;
	$name =~ s/\s*$//so;
	# Don't silently drop spaces.
        # We sanitize things now.
	# $name =~ s/\s//sgo;
	# $name =~ s/<.*?>//sgo;
	# if ($name =~ /[\s\n\r]/o) {
	    # if (!$HeaderDoc::ignore_apiuid_errors) {
		# my $fullpath = $self->fullpath();
		# warn("$fullpath:$linenum:apiref: bad name \"$name\".  Dropping ref.\n");
	    # }
	    # return "";
	# }
    }

    $name =~ s/\n//smgo;

    if ($name =~ /^operator\s+\w/) {
	$name =~ s/^operator\s+/operator_/;
    } else {
	$name =~ s/^operator\s+/operator/;
    }

    return $name;
}

# /*!
#     @abstract
#         Sets the apple_ref ID for a data type, function, etc.
#     @param obj
#         The object for which you want ot generate an API ref.
#     @discussion
#         The actual API ref eneration occurs in {@link apirefSetup}.
#  */
sub apiuid {
    my $self = shift;
    my $type = "AUTO";
    my $paramSignature_or_alt_define_name = "";
    my $filename = $self->filename();
    my $linenum = $self->linenum();

    my $localDebug = 0; # NOTE: localDebug is reset to 0 below.

    print STDERR "IN apiuid\n" if ($localDebug);

    if (@_) {
	$type = shift;
	if (@_) {
		$paramSignature_or_alt_define_name = shift;
	}
    } else {
	if ($self->{LINKUID}) {
		print STDERR "RETURNING CACHED LINKUID ".$self->{LINKUID}."\n" if ($localDebug);
		return $self->{LINKUID};
	}
	# if (!$self->{APIUID}) {
		# $self->apirefSetup(1);
	# }
	# if ($self->{APIUID}) {
		print STDERR "RETURNING CACHED APIUID ".$self->{APIUID}."\n" if ($localDebug);
		return $self->{APIUID};
	# }
    }
    if ($self->{REQUESTEDUID} && length($self->{REQUESTEDUID})) {
	$self->{APIUID} = $self->{REQUESTEDUID};

	print STDERR "RETURNING EXPLICITLY REQUESTED APIUID ".$self->{REQUESTEDUID}."\n" if ($localDebug);
	return $self->{REQUESTEDUID};
    }

    print STDERR "GENERATING NEW APIUID FOR $self (".$self->name.")\n" if ($localDebug);

    my $olduid = $self->{APIUID};
    if ($self->{LINKUID}) { $olduid = $self->{LINKUID}; }

    my $name = $self->apiuidname();
    $localDebug = 0;
    my $className; 
    my $lang = $self->sublang();
    my $class = ref($self) || $self;

    cluck("Call trace\n") if ($localDebug);


    my $parentClass = $self->apiOwner();

    if ($type eq "econst") {
	while (!$parentClass->isAPIOwner()) {
	    $parentClass = $parentClass->apiOwner();
	}
    }

    # print STDERR "OBJ: $self PC: $parentClass\n" if ($HeaderDoc::debugAllocations);

    my $parentClassType = ref($parentClass) || $parentClass;
    if ($parentClassType eq "HeaderDoc::Header") {
	# Generate requests with sublang always (so that, for
	# example, a c++ header can link to a class from within
	# a typedef declaration.

	# Generate anchors (except for class anchors) with lang
	# if the parent is a header, else sublang for stuff
	# within class braces so that you won't get name
	# resolution conflicts if something in a class has the
	# same name as a generic C entity, for example.

	if (!($class eq "HeaderDoc::CPPClass" || $class =~ /^HeaderDoc::ObjC/o)) {
		# print STDERR "LANG $lang\n";
	    if ($lang ne "IDL" && $lang ne "MIG" && $lang ne "javascript") {
		$lang = $self->lang();
	    }
	}
    }

    $lang = $self->apiRefLanguage($lang);

    # if ($lang eq "MIG") {
	# $lang = "mig";
    # } elsif ($lang eq "IDL") {
	# $lang = $HeaderDoc::idl_language;
    # }
    # if ($lang eq "C") { $lang = "c"; }
    # if ($lang eq "Csource") { $lang = "c"; }
    # if ($lang eq "occCat") { $lang = "occ"; }
    # if ($lang eq "intf") { $lang = "occ"; }

# print STDERR "SUBLANG: $lang\n";

    # my $lang = "c";
    # my $class = ref($HeaderDoc::APIOwner) || $HeaderDoc::APIOwner;

    # if ($class =~ /^HeaderDoc::CPPClass$/o) {
        # $lang = "cpp";
    # } elsif ($class =~ /^HeaderDoc::ObjC/o) {
        # $lang = "occ";
    # }

    print STDERR "LANG: $lang\n" if ($localDebug);
    # my $classHeaderObject = HeaderDoc::APIOwner->headerObject();
    # if (!$classHeaderObject) { }
    if ($parentClassType eq "HeaderDoc::Header") {
        # We're not in a class.  We used to give the file name here.

	if (!$HeaderDoc::headerObject) {
		die "headerObject undefined!\n";
	}

	# All static/my variables are file-scoped and shuld not cause
        # an API ref conflict with other file-scoped variables
        # with the same name.
	if ($self->parserState() && $self->parserState()->{isStatic}) {
        	$className = $HeaderDoc::headerObject->filename();
		if (!(length($className))) {
			die "Header Name empty!\n";
		}
		# $className .= "/";
	} else {
		$className = "";
	}
    } else {
        # We're in a class.  Give the class name.
	# cluck("PC: $parentClass\n");
	# $self->dbprint();
        $className = $parentClass->name();
	# if (length($name)) { $className .= "/"; }
    }
    $className =~ s/\s//sgo;
    $className =~ s/<.*?>//sgo;

# print STDERR "CN: $className\n";

    # Macros are not part of a class in any way.
    $class = ref($self) || $self;
    if ($class eq "HeaderDoc::PDefine") {
	$className = "";
	if ($paramSignature_or_alt_define_name) {
		$name = $paramSignature_or_alt_define_name;
		$paramSignature_or_alt_define_name = "";
	}
    }
    if ($class eq "HeaderDoc::Header") {
	# Headers are a "doc" reference type.
	$className = "";
	$lang = "doc";
	if ($self->isFramework()) {
		$type = "framework";
	} else {
		$type = "header";
	}
	$name = $self->filename();
	if ($self->can('isFramework') && $self->isFramework()) {
		$name =~ s/\.hdoc$//s;
	}
    }

    my $apio = $self->apiOwner();
    my $sublang = $self->sublang();
    if ($type eq "intfm" && ($sublang eq "c" || $sublang eq "C") && $apio =~ /HeaderDoc::CPPClass/) {
	$lang = "doc/com";
	$type = "intfm";
    }

    if ($self->appleRefIsDoc()) {
	$lang = "doc";
	$type = "title:$type";
	$name = $self->rawname_extended();
    }

    print STDERR "genRefSub: \"$lang\" \"$type\" \"$name\" \"$className\" \"$paramSignature_or_alt_define_name\"\n" if ($localDebug);

    my $uid = $self->genRefSub($lang, $type, $name, $className, $paramSignature_or_alt_define_name);

    if (length($name)) {
	unregisterUID($olduid, $name, $self);
	$uid = registerUID($uid, $name, $self); # This call resolves conflicts where needed....
    }

    print STDERR "APIUID SET TO $uid\n" if ($localDebug);
    $self->{APIUID} = $uid;

    return $uid;

    # my $ret .= "<a name=\"$uid\"></a>\n";
    # return $ret;
}

# /*!
#     @param value
#     @abstract
#         Sets or gets a state flag.
#     @discussion
#         The <code>APPLEREFISDOC</code> state flag controls whether to use a
#         language-specific or doc-specific apple_ref marker for a doc block.
#  */
sub appleRefIsDoc
{
    my $self = shift;
    if (@_) {
	my $value = shift;
	$self->{APPLEREFISDOC} = $value;
    }
	# print STDERR "ARID: ".$self->{APPLEREFISDOC}." for $self\n";
    return $self->{APPLEREFISDOC};
}

# /*!
#     @abstract
#         Constructs an API reference from its constituent parts.
#     @param self
#         This HeaderDoc API object.
#     @param lang
#         The programming language.
#     @param type
#         The symbol type.
#     @param name
#         The symbol name.
#     @param className
#         The class containing the symbol (with a trailing slash appended).
#         Pass an empty string if the symbol is not a class member.
#     @param paramSignature
#         The parameter signature for a function or method (prefixed
#         with a leading slash, with parentheses around the actual
#         signature.  (Optional.)
#  */
sub genRefSub($$$$)
{
    my $self = shift;
    my $orig_lang = shift;
    my $orig_type = shift;
    my $orig_name = shift;
    my $orig_className = shift;
    my $orig_paramSignature = "";
    if (@_) {
	$orig_paramSignature = shift;
    }
    my $owner_class = "";
    if (@_) {
	$owner_class = shift;
    }


    my $lang = sanitize($orig_lang);
    my $type = sanitize($orig_type);
    my $name = sanitize($orig_name, 1);
    my $className = sanitize($orig_className, 1);
    my $paramSignature = sanitize($orig_paramSignature);

    if (length($className) && length($name)) { $className .= "/"; }

    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();    
    my $localDebug = 0;

    $lang = $self->apiRefLanguage($lang);

    if ($lang eq "perl") {
	# You can declare arbitrary variables in Perl inside a
	# package that are actually outside the package with
	# this syntax, e.g. $otherPackage::variable = "blah"

	# Don't do this for classes; they're not scoped.
	# No need to filter out headers here because they have
	# "doc" as the language.

	# print "NAME: $name CN: $className\n";

	if ($type ne "cl") {
		if ($name =~ s/^(.+)\:\://s) {
			$className = "$1/";
		}
	}
	# print "NEW NAME: $name CN: $className\n";
    }

    my $uid;
    if (length($owner_class)) {
	$uid = "//$apiUIDPrefix/$lang/$type/$owner_class/$className$name$paramSignature";
    } else {
	$uid = "//$apiUIDPrefix/$lang/$type/$className$name$paramSignature";
    }
    return $uid;
}

# /*!
#     @abstract
#         Returns the language token that should appear in an
#         API reference.
#     @param self
#         The current object.
#     @param lang
#         The raw HeaderDoc (internal) language name.
#  */
sub apiRefLanguage
{
    my $self = shift;
    my $lang = shift;

    if ($lang eq "javascript") {
	$lang = "js";
    }
    if ($lang eq "csh") {
	$lang = "shell";
    }
    if ($lang eq "MIG") {
	$lang = "mig";
    } elsif ($lang eq "IDL") {
	$lang = $HeaderDoc::idl_language;
    }
    if ($lang eq "C") { $lang = "c"; }
    if ($lang eq "Csource") { $lang = "c"; }
    if ($lang eq "occCat") { $lang = "occ"; }
    if ($lang eq "intf") { $lang = "occ"; }

    return $lang;
}

# /*!
#     @abstract
#         Gets/sets the list of exceptions thrown by this
#         class/function.
#     @param self
#         The current object.
#     @param throws
#         The new value. (Optional.)
#  */
sub throws {
    my $self = shift;

    my $newTOC = $HeaderDoc::newTOC;
    if (!$self->isAPIOwner()) { $newTOC = 0; }

    if (@_) {
	my $new = shift;
	# $new =~ s/\n//smgo;
	$new =~ s/\n/ /smgo; # Replace line returns by spaces
	$new =~ s/\s+$//smgo; # Remove trailing spaces
	if ($newTOC) {
        	$self->{THROWS} .= "$new<br>\n";
	} else {
        	$self->{THROWS} .= "$new<br>\n";
	}
	$self->{XMLTHROWS} .= "<throw>$new</throw>\n";
	# print STDERR "Added $new to throw list.\n";
    }
    # print STDERR "dumping throw list.\n";
    if (length($self->{THROWS})) {
	if ($newTOC) {
    		return $self->{THROWS};
	} else {
    		return ("<p>\n" . $self->{THROWS} . "</p>");
	}
    } else {
	return "";
    }
}

# /*!
#     @abstract
#         Returns the list of exceptions thrown by this
#         class/function.
#     @param self
#         The current object.
#     @discussion
#         The value is set with {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/throws//() throws}.
#  */
sub XMLthrows {
    my $self = shift;
    my $string = $self->htmlToXML($self->{XMLTHROWS});

    my $ret;

    if (length($string)) {
	$ret = "<throwlist>\n$string</throwlist>\n";
    } else {
	$ret = "";
    }
    return $ret;
}

# /*!
#     @abstract
#         Gets/sets the abstract.
#     @param self
#         The current object.
#     @param throws
#         The new value. (Optional.)
#     @param isbrief
#         Use for compatibility the Doxygen <code>\@brief</code> tag.  Pass 1
#         for the <code>\@brief</code> behavior (abstract is limited to one paragraph
#         of content, so everything after a gap becomes part of the
#         discussion), 0 for the normal <code>\@abstract</code> behavior.
#  */
sub abstract {
    my $self = shift;

    my $localDebug = 0;

    my $isbrief = 0;

    if (@_) {
	my $abs = shift;

	print STDERR "Setting abstract for $self to \"$abs\"\n" if ($localDebug);;

	if (@_) {
		$isbrief = 1;
	}
	if ($isbrief) {
		my ($newabs, $newdisc) = split(/[\n\r][ \t]*[\n\r]/, $abs, 2);
		$abs = $newabs;
		$newdisc =~ s/^(\n|\r|< *br *\/? *>)*//si;
        	$self->discussion($newdisc);
	}
        $self->{ABSTRACT} = $self->linkfix(filterHeaderDocTagContents($abs));
    }

    my $ret = $self->{ABSTRACT};

    # print STDERR "RET IS \"$ret\"\n";

    # $ret =~ s/(\s*<p><\/p>\s*)*$//sg; # This should no longer be needed.
    # $ret =~ s/(\s*<br><br>\s*)*$//sg;

    # print STDERR "RET IS \"$ret\"\n";

    return $ret;
}

# /*! 
#     @abstract
#         Returns the abstract for XML use.
#     @param self
#         This object.
#     @discussion
#         The value is set with
# {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/abstract//() abstract}.
#  */
sub XMLabstract {
    my $self = shift;

    if (@_) {
        $self->{ABSTRACT} = shift;
    }
    return $self->htmlToXML($self->{ABSTRACT});
}

# /*!
#     @abstract
#         Returns the nameline discussion by itself.
#     @param self
#         This object.
#     @discussion
#         Much like {@link nameline_discussion} except thiat
#         this variant does not scrape out HeaderDoc markup,
#         HTML tags, etc.
#  */
sub raw_nameline_discussion {
	my $self = shift;
	return $self->{NAMELINE_DISCUSSION};
}

# /*!
#     @abstract
#         Returns the "raw" name.
#     @param self
#         This object.
#     @discussion
#         This function returns the name as taken from the
#         HeaderDoc comment.  If the nameline contains multiple
#         words and there are additional nonempty discussion
#         lines, the entire name line is treated as the
#         name, and the nameline discussion is appended to
#         the value returned by {@link mediumrarename} to
#         obtain the value that this function returns.
#
#         An explicit <code>\@discussion</code> tag forces the nameline discussion
#         to be treated as part of the name even if the contents of
#         the discussion tag are empty.
#
#         This may be a separate value from the main name
#         returned by {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/name//() name}
#         and {@link mediumrarename}.
#
#         If no "raw" name was set, returns the main name (equivalent to
#         {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/name//() name}.
#  */
sub rawname_extended {
	my $self = shift;
	my $localDebug = 0;
	my $n = $self->rawname();

	# Append the rest of the name line if necessary.
	if ($self->{DISCUSSION_SET}) {
		# print STDERR "DISCUSSION IS: ".$self->{DISCUSSION}."\n";
		# print STDERR "ISAPIO: ".$self->isAPIOwner()."\n";
		# print STDERR "ISFW: ".$self->isFramework()."\n";
		if ((!$HeaderDoc::ignore_apiowner_names) || (!$self->isAPIOwner()) || $self->isFramework()) {
			print STDERR "NAMELINE DISCUSSION for $self CONCATENATED (".$self->{NAMELINE_DISCUSSION}.")\n" if ($localDebug);
			print STDERR "ORIGINAL NAME WAS \"$n\"\n" if ($localDebug);
			if (length($self->{NAMELINE_DISCUSSION})) {
				$n .= " ".$self->{NAMELINE_DISCUSSION};
			}
		}
	}

	return $n;
}

# /*!
#     @abstract
#         Gets/sets the nameline discussion.
#     @param self
#         This object.
#     @param disc
#         The new nameline discusison to set. (Optional.)
#     @discussion
#         With old-stype headerdoc comments (e.g. <code>\@function</code>),
#         the name line (the first line) contains the name and
#         an optional discussion.  If the name line is not
#         the sole discussion, the remainder of the name line
#         is treated as part of the name.  Thus, this line
#         gets stored separately.
#
#         The content gets massively stripped by this function
#         under the assumption that it may get used as part
#         of a name.  You should generally call this version
#         in that context and call {@link raw_nameline_discussion}
#         for other cases.
#  */
sub nameline_discussion {
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
        $self->{NAMELINE_DISCUSSION} = shift;

	# cluck("in NL_DISC\n");
	print STDERR "nameline discussion set to ".$self->{NAMELINE_DISCUSSION}."\n" if ($localDebug);
    }
    return $self->htmlToXML(filterHeaderDocTagContents($self->{NAMELINE_DISCUSSION}));
}

# /*! @abstract
#         Returns the discussion without merging in the name line.
#     @param self
#         This object.
#  */
sub raw_discussion {
	my $self = shift;
	return $self->{DISCUSSION};
}

# /*! @abstract
#         Returns true if the discussion is set explicitly with an
#              <code>\@discussion</code> tag.
#     @param self
#         This object.
#     @discussion
#              An explicit <code>\@discussion</code> tag forces the nameline discussion
#              to be treated as part of the name even if the contents of
#              the discussion tag are empty.  This flag supports that.
#  */
sub discussion_set {
	my $self = shift;
	return $self->{DISCUSSION_SET};
}

# /*!
#     @abstract
#         Returns the discussion (without nameline discussion).
#     @param self
#         This object.
#     @discussion
#         See {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/name//() name}
#         for more info.
#  */
sub halfbaked_discussion {
	my $self = shift;
	return $self->discussion_sub(0, 0);
}

# /*! @abstract
#         Gets/sets the discussion value.
#     @param self
#         This object.
#     @param disc
#         The new value to set.  (Optional.)
#     @discussion
#         This function returns the discussion, including the
#         nameline discussion, if needed.
#  */
sub discussion {
    my $self = shift;
    my $discDebug = 0;

    if (@_) {
	my $olddisc = $self->{DISCUSSION};

	$self->{DISCUSSION_SET} = 1;

	print STDERR "DISCUSSION SET: $self : $olddisc -> \n" if ($discDebug);

        my $discussion = "";

	if ($olddisc ne "" && $discussion ne "") {
		# Warn if we have multiple discussions.
		# We'll be quiet if we're in a define block, as
		# This is just the natural course of things.
		# Clear the old value out first, though.
		if (!$self->inDefineBlock()) {
			my $fullpath = $self->fullpath();
			my $linenum = $self->linenum();

			warn("$fullpath:$linenum: warning: Multiple discussions found for ".$self->name()." ($self).  Merging.\n");
			# print STDERR "OLDDISC: \"$olddisc\"\n";
			# print STDERR "DISC: \"$discussion\"\n";

			$discussion = $olddisc."<br /><br />\n";;
		}
	}
	my $newdisc = $self->listfixup(shift);
        $discussion .= filterHeaderDocTagContents($newdisc);

	print STDERR "$discussion\n" if ($discDebug);

	# $discussion =~ s/<br>/\n/sgo;

        # $discussion =~ s/\n\n/<br>\n/go;
        $self->{DISCUSSION} = $self->linkfix($discussion);

	# warn("Set discussion to ".$self->{DISCUSSION}."\n");

	# Ensure that the discussion is not completely blank.
	if ($self->{DISCUSSION} eq "") {
		$self->{DISCUSSION} .= " ";
	}

	# print "\$self->{DISCUSSION} = ".$self->{DISCUSSION}."\n" if ($discDebug);
    }
    return $self->discussion_sub(1, $discDebug);
}

# /*! @abstract
#         Gets the discussion value (private function).
#     @param self
#         This object.
#     @param bake
#         Determines whether to bake the results.
#     @param discDebug
#         Set to 1 for debugging, else 0.
#     @discussion
#         If a standard discussion is set, this function
#         returns that.  If not, this returns the nameline
#         discussion.  If <code>code</code> is set, the
#         nameline discussion is wrapped in paragraph tags.
#  */
sub discussion_sub
{
    my $self = shift;
    my $bake = shift;
    my $discDebug = shift;

    # cluck("backtrace\n") if ($discDebug);
    print STDERR "OBJ is \"".$self."\"\n" if ($discDebug);
    print STDERR "NAME is \"".$self->{NAME}."\"\n" if ($discDebug);
    print STDERR "DISC WAS \"".$self->{DISCUSSION}."\"\n" if ($discDebug);
    print STDERR "NAMELINE DISC WAS \"".$self->{NAMELINE_DISCUSSION}."\"\n" if ($discDebug);

    # Return the real discussion if one exists.
    if ($self->{DISCUSSION}) {
	return $self->{DISCUSSION};
    } else {
	print STDERR "RETURNING NAMELINE DISC\n" if ($discDebug);
    }

    # Return the contents of the name line (e.g. @struct foo Discussion goes here.)
    # beginning after the first token if no discussion exists.
    if ($bake) {
	return "<p>".$self->{NAMELINE_DISCUSSION}."</p>";
    }
    return $self->{NAMELINE_DISCUSSION};
}

# /*!
#     @abstract
#         Merges newlines and carriage returns with preceding text, but only if nonsequential.
#     @discussion
#         For proper interpreting of implicit lists (without <code>ul</code> or <code>ol</code>
#         tags), it is necessary to split the input into lines of text, keeping the first
#         newline/carriage return attached to the previous line, but not later newlines or
#         carriage returns.
#     @param arrayref
#         A reference to the input array.
#     @result
#         Returns the new array.
#  */
sub splitmerge
{
    my $arrayref = shift;
    my @arr = @{$arrayref};
    my @ret = ();

    foreach my $item (@arr) {
	if ($item =~ /[\n\r]/) {
		my $temp = pop(@ret);
		if ($temp) {
			if ($temp =~ /[\r\n]$/s) {
				push(@ret, $temp);
			} else {
				$item = $temp.$item;
			}
		}
		push(@ret, $item);
	} elsif ($item) {
		push(@ret, $item);
	}
    }
    return @ret;
}

# /*!
#     @abstract
#         Converts numbered lists in comments into HTML ordered
#         list tags where possible.
#     @param self
#         This object.
#     @param olddiscussion
#         The input discussion.
#     @return
#         Returns the new discussion.
#  */
sub listfixup
{
    my $self = shift;
    my $olddiscussion = shift;
    my $discussion = "";

    my $numListDebug = 0;

    my $encoding = $self->encoding();


    # Note that HeaderDoc does not attempt to handle non-8-bit
    # character sets.

    my $bullet = "";

    if ($encoding = /iso-8859-\d+\s*$/i) {
	# Technically, this is a lie.  The ISO standards
	# don't specify any characters for this range.
	# That said, most software treats ISO-8859-1 like
	# Windows-1252 and calls 0x95 a bullet and the same
	# goes for the rest of the ISO character sets and
	# their Windows equivalents.

	$bullet = "\x95";
    } elsif ($encoding = /Windows-\d+/i) {
	$bullet = "\x95"; # ISO 8859-1
    } elsif ($encoding = /MacRoman/i) {
	$bullet = "\xA5";
    } elsif ($encoding = /UTF-8/i) {
	$bullet = "\x{2022}";
    }

    # I don't have time to actually write the bulleted list detection right now,
    # but this is where it will go eventually.  Also, it would be nice to allow
    # nesting, though this will require tab to space conversion (e.g. with the -w
    # flag).  That probably should happen anyway, and probably up a few levels
    # in the main text handling code).

    # print STDERR "ENC: $encoding\n";

    if ($HeaderDoc::dumb_as_dirt) {
	print STDERR "BASIC MODE: LIST FIXUP DISABLED\n" if ($numListDebug);
	return $olddiscussion;
    }

    print STDERR "processing dicussion for ".$self->name().".\n" if ($numListDebug);

    my @disclines = split(/([\n\r])/, $olddiscussion);

    @disclines = splitmerge(\@disclines);
    my $curpos = 0;
    my $seekpos = 0;
    my $nlines = scalar(@disclines);

    my $oldinList = 0;
    my $intextblock = 0;
    my $inpre = 0;

    if ($numListDebug) {
	print STDERR "BEGIN DISCUSSION\n";
	while ($curpos < $nlines) {
		my $line = $disclines[$curpos++];
		print STDERR "$line";
	}
	print STDERR "END DISCUSSION\n";
	$curpos = 0;
    }

    while ($curpos < $nlines) {
	my $line = $disclines[$curpos];
	if ($line =~ /\@textblock/) {
		$intextblock = 1;
		print STDERR "intextblock -> 1\n" if ($numListDebug);
	}
	if ($line =~ /\@\/textblock/) {
		$intextblock = 0;
		print STDERR "intextblock -> 0\n" if ($numListDebug);
	}
	if ($line =~ /<pre>/) {
		$inpre = 1;
		print STDERR "inpre -> 1\n" if ($numListDebug);
	}
	if ($line =~ /<\/pre>/) {
		$inpre = 0;
		print STDERR "inpre -> 0\n" if ($numListDebug);
	}
	if ($intextblock || $inpre) {
		$discussion .= $line;
	} else {
		print STDERR "LINE: \"$line\"\n" if ($numListDebug);
			print STDERR "TOP OLDINLIST: $oldinList\n" if ($numListDebug);
		if ($line =~ /^\s*((?:-)?\d+)[\)\.\:\s]/o) {
			# this might be the first entry in a list.
			print STDERR "MAYBELIST: $line\n" if ($numListDebug);
			my $inList = 1;
			my $foundblank = 0;
			my $basenum = $1;
			$seekpos = $curpos + 1;
			my $added = 0;
			if (($seekpos >= $nlines) && !$oldinList) {
				$discussion .= "$line";
				$added = 1;
			} else {
			    while (($seekpos < $nlines) && ($inList == 1)) {
				my $scanline = $disclines[$seekpos];
				print STDERR "INLIST: $inList, OLDINLIST: $oldinList\n" if ($numListDebug);
				if ($scanline =~ /^<\/p><p>\s*$/so || $scanline =~ /^\s*$/s) {
					# empty line
					$foundblank = 1;
					print STDERR "BLANKLINE\n" if ($numListDebug);
				} elsif ($scanline =~ /^\s*((?:-)?\d+)[\)\.\:\s]/o) {
					# line starting with a number
					$foundblank = 0;
					# print STDERR "D1 is $1\n";
					if ($1 != ($basenum + 1)) {
						# They're noncontiguous.  Not a list.
						print STDERR "NONCONTIG\n" if ($numListDebug);
						if (!$oldinList) {
							print STDERR "ADDED $line\n" if ($numListDebug);
							$discussion .= "$line";
							$added = 1;
						}
						$inList = 0;
					} else {
						# They're contiguous.  It's a list.
						print STDERR "CONTIG\n" if ($numListDebug);
						$inList = 2;
					}
				} else {
					# text.
					if ($foundblank && ($scanline =~ /\S+/o)) {
						# skipped a line and more text.
						# end the list here.
						print STDERR "LIST MAY END ON $scanline\n" if ($numListDebug);
						print STDERR "BASENUM IS $basenum\n" if ($numListDebug);
						$inList = 3;
					}
				}
				$seekpos++;
			    }
			}
			if ($oldinList) {
				# we're finishing an existing list.
				$line =~ s/^\s*((?:-)?\d+)[\)\.\:\s]//so;
				$basenum = $1;
				$discussion .= "</li><li>$line";
				print STDERR "LISTCONTINUES: $line\n" if ($numListDebug);
			} elsif ($inList == 3) {
				# this is a singleton.  Don't touch it.
				$discussion .= $line;
				print STDERR "SINGLETON: $line\n" if ($numListDebug);
			} elsif ($inList == 2) {
				# this is the first entry in a list
				$line =~ s/^\s*((?:-)?\d+)[\)\.\:\s]//so;
				$basenum = $1;
				$discussion .= "<ol start=\"$basenum\"><li>$line";
				print STDERR "FIRSTENTRY: $line\n" if ($numListDebug);
			} elsif (!$added) {
				$discussion .= $line;
			}
			if ($oldinList && !$inList) {
				$discussion .= "</li></ol>";
			}
			$oldinList = $inList;
		} elsif ($line =~ /^<\/p><p>\s*$/so || $line =~ /^\s*$/s) {
			if ($oldinList == 3 || $oldinList == 1) {
				# If 3, this was last entry in list before next
				# text.  If 1, this was last entry in list before
				# we ran out of lines.  In either case, it's a
				# blank line not followed by another numbered
				# line, so we're done.
	
				print STDERR "OUTERBLANKLINE\n" if ($numListDebug);
				$discussion .= "</li></ol>";
				$oldinList = 0;
			} else {
				 print STDERR "OIL: $oldinList\n" if ($numListDebug);
				$discussion .= "$line";
			}
		} else {
			# $oldinList = 0;
			print STDERR "TEXTLINE: \"$line\"\n" if ($numListDebug);
			$discussion .= $line;
		}
    	}
	$curpos++;
    }
    if ($oldinList) {
	$discussion .= "</li></ol>";
    }

    print STDERR "done processing dicussion for ".$self->name().".\n" if ($numListDebug);
    # $newdiscussion = $discussion;

    return $discussion;
}

# /*!
#     @abstract
#         Returns the discussion formatted for XML.
#     @param self
#         This object.
#     @param deprecated_discussion
#         The value to set. (Optional, do not use.)
#     @discussion
#         Do not set discussion with this function.  Use the
#  {@link //apple_ref/perl/instm/HeaderDoc::DocReference/discussion//() discussion}
#         function instead.
#  */
sub XMLdiscussion {
    my $self = shift;

    if (@_) {
        my $discussion = "";
        $discussion = shift;
        # $discussion =~ s/\n\n/<br>\n/go;
        $self->{DISCUSSION} = $discussion;
    }
    return $self->htmlToXML($self->{DISCUSSION});
}


# /*!
#    @abstract
#         Gets/sets the vestigial text declaration.
#    @param self
#         This object.
#    @param declaration
#         The new declaration to set. (Optional.)
#    @discussion
#        This is only relevant if the <code>-b</code> flag is used,
#        and maybe not even then.
#  */
sub declaration {
    my $self = shift;
    # my $dec = $self->declarationInHTML();
    # remove simple markup that we add to declarationInHTML
    # $dec =~s/<br>/\n/gio;
    # $dec =~s/<font .*?>/\n/gio;
    # $dec =~s/<\/font>/\n/gio;
    # $dec =~s/<(\/)?tt>//gio;
    # $dec =~s/<(\/)?b>//gio;
    # $dec =~s/<(\/)?pre>//gio;
    # $dec =~s/\&nbsp;//gio;
    # $dec =~s/\&lt;/</gio;
    # $dec =~s/\&gt;/>/gio;
    # $self->{DECLARATION} = $dec;  # don't really have to have this ivar
    if (@_) {
	$self->{DECLARATION} = shift;
    }
    return $self->{DECLARATION};
}

# /*! 
#     @abstract
#         Gets/sets the prvate declaration for a C++ method.
#     @param self
#         This object.
#     @param newpridec
#         The new value to set. (Optional.)
#     @discussion
#         The private declaration for a C++ method are the portion
#         of the declaration after the semicolon.  These define the
#         private internal variable names that correspond with the
#         public argument names.  (Why!?!?!?!)
#  */
sub privateDeclaration {
    my $self = shift;
    if (@_) {
	$self->{PRIVATEDECLARATION} = shift;
    }
    return $self->{PRIVATEDECLARATION};
}


# /*!
#     @abstract
#         Generate a cross-reference request in HTML style
#     @param keystring
#         string containing the keywords, e.g. <code>struct</code> or <code>enum</code>
#     @param namestring
#         string containing the type name itself
#     @param linktext
#         link text to generate
#     @param optional_expected_type
#         general genre of expected types
#     @discussion
#         This is used to simplify the code that rips apart the
#         resulting anchor when handling <code>see</code> or <code>seealso</code> tags.
#  */
sub genRefHTML($$$)
{
    my $self = shift;
    my $keystring = shift;
    my $name = shift;
    my $linktext = shift;
    my $optional_expected_type = "";

    my $of = $self->outputformat();
    $self->outputformat("html");

    my $result;
    if (@_) {
	$optional_expected_type = shift;
	$result = $self->genRef($keystring, $name, $linktext, $optional_expected_type);
    } else {
	$result = $self->genRef($keystring, $name, $linktext);
    }

    $self->outputformat($of);
    return $result;
}


# /*!
#     @abstract
#         Generate a cross-reference request (from a declaration)
#     @param keystring
#         string containing the keywords, e.g. <code>struct</code> or <code>enum</code>
#     @param namestring
#         string containing the type name itself
#     @param linktext
#         link text to generate
#     @param optional_expected_type
#         general genre of expected types
#     @param optional_return_only_ref
#         Pass 1 if you want the bare list of destinations.
#         If the symbol should not be linked, this mode
#         returns an empty string.
#
#         Pass 0 (or omit) to get a marked up anchor with
#         link text enclosed.  If the word should not be
#         linked, this mode returns the link text.
#  */
sub genRefFromDeclaration($$$$)
{
    my $self = shift;
    my $keystring = shift;
    my $name = shift;
    my $linktext = shift;
    my $optional_expected_type = "";
    if (@_) {
	$optional_expected_type = shift;
    }
    my $optional_return_only_ref = 0;
    if (@_) {
	$optional_return_only_ref = shift;
    }
    return $self->genRefCore($keystring, $name, $linktext, $optional_expected_type, $optional_return_only_ref, 1);
}

# /*!
#     @abstract
#         Generate a cross-reference request
#     @param keystring
#         string containing the keywords, e.g. <code>struct</code> or <code>enum</code>
#     @param namestring
#         string containing the type name itself
#     @param linktext
#         link text to generate
#     @param optional_expected_type
#         general genre of expected types
#     @param optional_return_only_ref
#         Pass 1 if you want the bare list of destinations.
#         If the symbol should not be linked, this mode
#         returns an empty string.
#
#         Pass 0 (or omit) to get a marked up anchor with
#         link text enclosed.  If the word should not be
#         linked, this mode returns the link text.
#  */
sub genRef($$$$)
{
    my $self = shift;
    my $keystring = shift;
    my $name = shift;
    my $linktext = shift;
    my $optional_expected_type = "";
    if (@_) {
	$optional_expected_type = shift;
    }
    my $optional_return_only_ref = 0;
    if (@_) {
	$optional_return_only_ref = shift;
    }
    return $self->genRefCore($keystring, $name, $linktext, $optional_expected_type, $optional_return_only_ref, 0);
}

# /*!
#     @abstract
#         Generate a cross-reference request
#     @param keystring
#         string containing the keywords, e.g. <code>struct</code> or <code>enum</code>
#     @param namestring
#         string containing the type name itself
#     @param linktext
#         link text to generate
#     @param expected_type
#         general genre of expected types
#     @param return_only_ref
#         Pass 1 if you want the bare list of destinations.
#         If the symbol should not be linked, this mode
#         returns an empty string.
#
#         Pass 0 (or omit) to get a marked up anchor with
#         link text enclosed.  If the word should not be
#         linked, this mode returns the link text.
#  */
sub genRefCore($$$$$$)
{
    my $self = shift;
    my $keystring = shift;
    my $name = shift;
    my $linktext = shift;
    my $expected_type = shift;
    my $return_only_ref = shift;
    my $fromDeclaration = shift;

    my $fullpath = $self->fullpath();
    my $linenum = $self->linenum();
    my $tail = "";
    my $xml = 0;
    my $localDebug = 0;

    print STDERR "NAME IS $name\n" if ($localDebug);

    if ($self->outputformat() eq "hdxml") { $xml = 1; }

    # Generate requests with sublang always (so that, for
    # example, a c++ header can link to a class from within
    # a typedef declaration.  Generate anchors with lang
    # if the parent is a header, else sublang for stuff
    # within class braces so that you won't get name
    # resolution conflicts if something in a class has the
    # same name as a generic C entity, for example.

    my $lang = $self->sublang();
    # my ($sotemplate, $eotemplate, $operator, $soc, $eoc, $ilc, $ilc_b, $sofunction,
	# $soprocedure, $sopreproc, $lbrace, $rbrace, $unionname, $structname,
	# $enumname,
	# $typedefname, $varname, $constname, $structisbrace, $macronamesref,
	# $classregexp, $classbraceregexp, $classclosebraceregexp,
	# $accessregexp, $requiredregexp, $propname, 
        # $objcdynamicname, $objcsynthesizename, $moduleregexp, $definename,
	# $functionisbrace, $classisbrace, $lbraceconditionalre, $lbraceunconditionalre, $assignmentwithcolon,
	# $labelregexp, $parmswithcurlybraces, $superclasseswithcurlybraces, $soconstructor) = parseTokens($self->lang(), $self->sublang());

    my %parseTokens = %{parseTokens($self->lang(), $self->sublang())};
    my $accessregexp = $parseTokens{accessregexp};

    if ($name =~ /^[\d\[\]]/o) {
	# Silently fail for [4] and similar.
	print STDERR "Silently fail[1]\n" if ($localDebug);
	if ($return_only_ref) { return ""; }
	return $linktext;
    }

    if (($name =~ /^[=|+-\/&^~!*]/o) || ($name =~ /^\s*\.\.\.\s*$/o)) {
	# Silently fail for operators
	# and varargs macros.

	print STDERR "Silently fail[2]\n" if ($localDebug);
	if ($return_only_ref) { return ""; }
	return $linktext;
    }
    # if (($name =~ /^\s*public:/o) || ($name =~ /^\s*private:/o) ||
	# ($name =~ /^\s*protected:/o)) {
    if (length($accessregexp) && ($name =~ /$accessregexp(:)?/)) {
	# Silently fail for these, too.

	print STDERR "Silently fail[3]\n" if ($localDebug);
	if ($return_only_ref) { return ""; }
	return $linktext;
    }

    if ($name =~ s/\)\s*$//o) {
	if ($linktext =~ s/\)\s*$//o) {
		$tail = ")";
	} else {
		warn("$fullpath:$linenum: warning: Parenthesis in ref name, not in link text\n");
		warn("name: $name) linktext: $linktext\n");
	}
    }

    # I haven't found any cases where this would trigger a warning
    # that don't already trigger a warning elsewhere.
    my $testing = 0;
    if ($testing && ($name =~ /&/o || $name =~ /\(/o || $name =~ /\)/o || $name =~ /.:(~:)./o || $name =~ /;/o || $name eq "::" || $name =~ /^::/o)) {
	my $classname = $self->name();
	my $class = ref($self) || $self;
	my $declaration = $self->declaration();
	if (($name eq "(") && $class eq "HeaderDoc::PDefine") {
		warn("$fullpath:$linenum: warning: bogus paren in #define\n");
	} elsif (($name eq "(") && $class eq "HeaderDoc::Function") {
		warn("$fullpath:$linenum: warning: bogus paren in function\n");
	} elsif ($class eq "HeaderDoc::Function") {
		warn("$fullpath:$linenum: warning: bogus paren in function\n");
	} else {
		warn("$fullpath:$linenum: warning: $fullpath $classname $class $keystring generates bad crossreference ($name).  Dumping trace.\n");
		# my $declaration = $self->declaration();
		# warn("BEGINDEC\n$declaration\nENDDEC\n");
		$self->printObject();
	}
    }

    if ($name =~ /^(.+)::(.+?)$/o) {
	my $classpart = $1;
	my $type = $2;
	if ($linktext !~ /::/o) {
		warn("$fullpath:$linenum: warning: Bogus link text generated for item containing class separator.  Ignoring.\n");
	}

	# print STDERR "CLASSPART: $classpart TYPE: $type\n";

	my $ret = $self->genRef("class", $classpart, $classpart);
	$ret .= "::";

	# This is where it gets ugly.  C++ allows use of struct,
	# enum, and other similar types without preceding them
	# with struct, enum, etc....

	# $classpart .= "/";

	# Classpart is never empty here, so don't bother checking.
        my $ref1 = $self->genRefSub($lang, "instm", $type, $classpart);
        my $ref2 = $self->genRefSub($lang, "clm", $type, $classpart);
        my $ref3 = $self->genRefSub($lang, "func", $type, "");
        my $ref4 = $self->genRefSub($lang, "ftmplt", $type, $classpart);
        my $ref5 = $self->genRefSub($lang, "defn", $type, "");
        my $ref6 = $self->genRefSub($lang, "macro", $type, "");
	# allow classes within classes for certain languages.
        my $ref7 = $self->genRefSub($lang, "cl", $type, $classpart);
        my $ref8 = $self->genRefSub($lang, "tdef", $type, "");
        my $ref9 = $self->genRefSub($lang, "tag", $type, "");
        my $ref10 = $self->genRefSub($lang, "econst", $type, "");
        my $ref11 = $self->genRefSub($lang, "struct", $type, "");
        my $ref12 = $self->genRefSub($lang, "data", $type, $classpart);
        my $ref13 = $self->genRefSub($lang, "clconst", $type, $classpart);
	my $ref14 = $self->genRefSub($lang, "intfm", $type, $classpart);
	my $ref99 = $self->genRefSub("doc/com", "intfm", $name, $classpart);

	my $lp = "$ref1 $ref2 $ref3 $ref4 $ref5 $ref6 $ref7 $ref8 $ref9 $ref10 $ref11 $ref12 $ref13 $ref14 $ref99";
	if ($return_only_ref) { return $lp; }
	if (!$xml) {
        	$ret .= "<!-- a logicalPath=\"$lp\" machineGenerated=\"true\" -->$type<!-- /a -->";
	} else {
        	$ret .= "<hd_link logicalPath=\"$lp\">$type</hd_link>";
	}

	print STDERR "Double-colon case\n" if ($localDebug);
	return $ret.$tail;
    }

    my $ret = "";
    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();    
    my $type = "";
    my $className = "";

    my $classNameImplicit = 0;
    my $apio = $self->apiOwner();
    my $apioclass = ref($apio) || $apio;
    if ($apioclass ne "HeaderDoc::Header") {
	$classNameImplicit = 1;
	if ($apio->can("className")) {  # to get the class name from Category objects
		$className = $apio->className();
	} else {
		$className = $apio->name();
	}
	# $className .= "/";
    }

    my $class_or_enum_check = " $keystring ";
    # if ($lang eq "pascal") { $class_or_enum_check =~ s/\s+var\s+/ /sgo; }
    # if ($lang eq "MIG") { $class_or_enum_check =~ s/\s+(in|out|inout)\s+/ /sgo; }
    # $class_or_enum_check =~ s/\s+const\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+static\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+virtual\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+auto\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+extern\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+__asm__\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+__asm\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+__inline__\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+__inline\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+inline\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+register\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+template\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+unsigned\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+signed\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+volatile\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+private\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+protected\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+public\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+synchronized\s+/ /sgo;
    # $class_or_enum_check =~ s/\s+transient\s+/ /sgo;

    my ($case_sensitive, $keywordhashref) = $self->keywords();
    my @keywords = keys %{$keywordhashref};
    foreach my $keyword (@keywords) {
	if ($case_sensitive) {
		$class_or_enum_check =~ s/(^|\s+)\Q$keyword\E(\s+|$)/ /sg;
	} else {
		$class_or_enum_check =~ s/(^|\s+)\Q$keyword\E(\s+|$)/ /sgi;
	}
    }

    $class_or_enum_check =~ s/\s*//smgo;

    if (length($class_or_enum_check)) {
	SWITCH: {
	    ($keystring =~ /type/o && $lang eq "pascal") && do { $type = "tdef"; last SWITCH; };
	    ($keystring =~ /type/o && $lang eq "MIG") && do { $type = "tdef"; last SWITCH; };
	    ($keystring =~ /record/o && $lang eq "pascal") && do { $type = "struct"; last SWITCH; };
	    ($keystring =~ /procedure/o && $lang eq "pascal") && do { $type = "*"; last SWITCH; };
	    ($keystring =~ /of/o && $lang eq "pascal") && do { $type = "*"; last SWITCH; };
	    ($keystring =~ /typedef/o) && do { $type = "tdef"; last SWITCH; };
	    (($keystring =~ /sub/o) && ($lang eq "perl")) && do { $type = "*"; last SWITCH; };
	    ($keystring =~ /function/o) && do { $type = "*"; last SWITCH; };
	    ($keystring =~ /typedef/o) && do { $type = "tdef"; last SWITCH; };
	    ($keystring =~ /struct/o) && do { $type = "tag"; last SWITCH; };
	    ($keystring =~ /union/o) && do { $type = "tag"; last SWITCH; };
	    ($keystring =~ /operator/o) && do { $type = "*"; last SWITCH; };
	    ($keystring =~ /enum/o) && do { $type = "tag"; last SWITCH; };
	    ($keystring =~ /protocol/o) && do { $type = "intf"; $classNameImplicit = 0; $className=$name; $name=""; last SWITCH; };
	    ($keystring =~ /class/o) && do { $type = "cl"; $classNameImplicit = 0; $className=$name; $name=""; last SWITCH; };
	    ($keystring =~ /#(define|ifdef|ifndef|if|endif|undef|elif|error|warning|pragma|include|import)/o) && do {
		    # Used to include || $keystring =~ /class/o
		    # defines and similar aren't followed by a type

		    print STDERR "Keyword case\n" if ($localDebug);
		    if ($return_only_ref) { return ""; }
		    return $linktext.$tail;
		};
	    {
		$type = "";
		my $name = $self->name();
		warn "$fullpath:$linenum: warning: keystring ($keystring) in $name type link markup\n";
		if ($return_only_ref) { return ""; }
		return $linktext.$tail;
	    }
	}
	if ($type eq "*") {
	    # warn "Function requested with genRef.  This should not happen.\n";
	    # This happens now, at least for operators.

	    my $lp = "";
	    if ($className ne "")  {
	    	$lp .= " ".$self->genRefSub($lang, "instm", $name, $className);
	    	$lp .= " ".$self->genRefSub($lang, "clm", $name, $className);
	    }
	    $lp .= " ".$self->genRefSub($lang, "func", $name, "");
	    $lp .= " ".$self->genRefSub($lang, "ftmplt", $name, $className);
	    $lp .= " ".$self->genRefSub($lang, "defn", $name, $className);
	    $lp .= " ".$self->genRefSub($lang, "macro", $name, $className);
	    $lp .= " ".$self->genRefSub("doc/com", "intfm", $name, $className);

	    $lp =~ s/^ //s;

	    print STDERR "Class or enum check case: Type is \"*\" case\n" if ($localDebug);
	    if ($return_only_ref) { return $lp; }
	    if (!$xml) {
	        return "<!-- a logicalPath=\"$lp\" machineGenerated=\"true\" -->$linktext<!-- /a -->".$tail;
	    } else {
	        return "<hd_link logicalPath=\"$lp\">$linktext</hd_link>".$tail;
	    }
	} else {
	    print STDERR "Class or enum check case: Type is not \"*\" case\n" if ($localDebug);
	    my $lp = $self->genRefSub($lang, $type, $className, $name);
	    if ($return_only_ref) { return $lp; }
	    if (!$xml) {
	        return "<!-- a logicalPath=\"" . $lp . "\" machineGenerated=\"true\" -->$linktext<!-- /a -->".$tail;
	    } else {
	        return "<hd_link logicalPath=\"" . $lp . "\">$linktext</hd_link>".$tail;
	    }
	}
    } else {
	# We could be looking for a class or a typedef.  Unless it's local, put in both
	# and let the link resolution software sort it out.  :-)

	my $typerefs = $self->genRefSub($lang, "cl", $name, "");
        # allow classes within classes for certain languages.
	$typerefs .= " ".$self->genRefSub($lang, "cl", $name, $className) if (($className ne "") && !$classNameImplicit);
        $typerefs .= " ".$self->genRefSub($lang, "tdef", $name, "");
        $typerefs .= " ".$self->genRefSub($lang, "tag", $name, "");
        $typerefs .= " ".$self->genRefSub($lang, "struct", $name, "");
        $typerefs .= " ".$self->genRefSub($lang, "intf", $name, "");


	my $varrefs =           $self->genRefSub($lang, "econst", $name, "");
        $varrefs .= " ".        $self->genRefSub($lang, "data", $name, $className);
	if ($classNameImplicit) {
        	$varrefs .= " ".$self->genRefSub($lang, "data", $name, "");
	}
        $varrefs .= " ".$self->genRefSub($lang, "clconst", $name, $className);

	my $functionrefs =   $self->genRefSub($lang, "instm", $name, $className);
        $functionrefs .= " ".$self->genRefSub($lang, "clm", $name, $className);
        $functionrefs .= " ".$self->genRefSub($lang, "intfcm", $name, $className);
        $functionrefs .= " ".$self->genRefSub($lang, "intfm", $name, $className);
        $functionrefs .= " ".$self->genRefSub($lang, "func", $name, "");
        $functionrefs .= " ".$self->genRefSub($lang, "ftmplt", $name, $className);
        $functionrefs .= " ".$self->genRefSub($lang, "defn", $name, "");
        $functionrefs .= " ".$self->genRefSub($lang, "macro", $name, "");

	my $docrefs = $self->genRefSub("doc/com", "intfm", $name, $className);
	my $anysymbol = $self->genRefSub("doc", "anysymbol", $name);

	my $masterref = "$typerefs $varrefs $functionrefs $docrefs $anysymbol";
	print STDERR "Default case (OET: $expected_type)" if ($localDebug);

	if (length($expected_type)) {
		SWITCH: {
			($expected_type eq "string") && do {
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			($expected_type eq "char") && do {
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			($expected_type eq "comment") && do {
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			($expected_type eq "preprocessor") && do {
					# We want to add links, but all we can
					# do is guess about the type.
					last SWITCH;
				};
			($expected_type eq "number") && do {
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			($expected_type eq "keyword") && do {
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			($expected_type eq "function") && do {
					$masterref = $functionrefs." ".$anysymbol;
					last SWITCH;
				};
			($expected_type eq "var") && do {
					# Variable name.
					if ($fromDeclaration) { $anysymbol = ""; }

					$masterref = $varrefs." ".$anysymbol;
					last SWITCH;
				};
			($expected_type eq "template") && do {
					# Could be any template parameter bit
					# (type or name).  Since we don't care
					# much if a parameter name happens to
					# something (ideally, it shouldn't),
					# we'll just assume we're getting a
					# type and be done with it.
					$masterref = $typerefs." ".$anysymbol;
					last SWITCH;
				};
			($expected_type eq "type") && do {
					$masterref = $typerefs." ".$anysymbol;
					last SWITCH;
				};
			($expected_type eq "param") && do {
					# parameter name.  Don't link.
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			($expected_type eq "ignore") && do {
					# hidden token.
					if ($return_only_ref) { return ""; }
					return $linktext.$tail;
				};
			{
				warn("$fullpath:$linenum: warning: Unknown reference class \"$expected_type\" in genRef\n");
			}
		}
	}
	print STDERR "Default case: No OET.  MR IS $masterref\n" if ($localDebug);

    $masterref =~ s/\s+/ /g;
	if ($return_only_ref) { return $masterref; }
	if ($xml) {
            return "<hd_link logicalPath=\"$masterref\">$linktext</hd_link>".$tail;
	} else {
            return "<!-- a logicalPath=\"$masterref\" machineGenerated=\"true\" -->$linktext<!-- /a -->".$tail;
	}

    # return "<!-- a logicalPath=\"$ref1 $ref2 $ref3\" -->$linktext<!-- /a -->".$tail;
    }

}

# /*!
#     @abstract
#         Returns all known keywords for the current language.
#     @param self
#         This object.
#     @result
#         The return value is an array (<code>$case_sensitive,
#         \%keywords</code>).
#
#         The first value is either 0 or 1 depending on whether the
#         current language uses case-sensitive token matching or not.
#
#         The second value is a reference to a keywords hash for the
#         current language.  The specific value is usually 1.
#         Other values are used to indicate that the token should be
#         handled in a non-standard way in certain places.
#
#         1.  most keywords.
#         2.  attributes and other things where the (...) afterwards
#             must be treated as part of the token.
#         3.  <code>extends</code> keyword.  Used for indicating that what follows
#             is stored as the <code>extends</code> info for a class.
#         4.  <code>implements</code> keyword.  Used for indicating that what follows
#             is stored as the <code>implements</code> info for a class.
#         5.  <code>throws</code> keywords.  Used for indicating that what follows
#             is stored as as an exception that this function throws.
#         6.  <code>__typeof__</code> keyword where the (...) afterwards must be
#             treated as part of the token; separate from #2 because
#             what follows is a type for code coloring purposes.
#         7.  <code>extern</code> keyword.  Use for detecting <code>extern "C"</code>.
#         8.  <code>static</code> and <code>my</code> keywords.  Used for
#             determining whether global variables are file-scoped.
#         9.  <code>case</code> (shell).  Changes parser parenthesis handling.
#         10. <code>esac</code> (shell).  Ends the <code>case</code> statement.
#  */
sub keywords
{
    my $self = shift;
    my $class = ref($self) || $self;
    # my $declaration = shift;
    # my $functionBlock = shift;
    # my $orig_declaration = $declaration;
    my $localDebug = 0;
    my $parmDebug = 0;
    my $lang = $self->lang();
    my $sublang = $self->sublang();
    # my $fullpath = $HeaderDoc::headerObject->fullpath();
    my $fullpath = $self->fullpath();
    my $linenum = $self->linenum();
    my $case_sensitive = 1;

    if (!$self->isAPIOwner()) {
	# $self->dbprint();
	my $apio = $self->apiOwner();
	# print STDERR "APIO: \"$apio\"\n";
	return $apio->keywords();
    }
    if ($self->{KEYWORDHASH}) { return ($self->{CASESENSITIVE}, $self->{KEYWORDHASH}); }

    print STDERR "keywords\n" if ($localDebug);

    # print STDERR "Color\n" if ($localDebug);
    # print STDERR "lang = $lang\n";

    # Note: these are not all of the keywords of each language.
    # This should, however, be all of the keywords that can occur
    # in a function or data type declaration (e.g. the sort
    # of material you'd find in a header).  If there are missing
    # keywords that meet that criterion, please file a bug.


    my %RubyKeywords = ( 
	"assert" => 1, 
	"break" => 1, 
	"while" => 1,
	"if" => 1,
	"for" => 1,
	"until" => 1,
	"break" => 1,
	"redo" => 1,
	"retry" => 1,
 	"nil" => 1,
	"true" => 1,
	"false" => 1,
	"class" => 1, 
	"module" => 1);
    my %CKeywords = ( 
	"assert" => 1, 
	"break" => 1, 
	"auto" => 1, "const" => 1, "enum" => 1, "extern" => 7, "inline" => 1,
	"__inline__" => 1, "__inline" => 1, "__asm" => 2, "__asm__" => 2,
        "__attribute__" => 2, "__typeof__" => 6,
	"register" => 1, "signed" => 1, "static" => 8, "struct" => 1, "typedef" => 1,
	"union" => 1, "unsigned" => 1, "volatile" => 1, "#define" => 1,
	"#ifdef" => 1, "#ifndef" => 1, "#if" => 1, "#endif" => 1,
	"#undef" => 1, "#elif" => 1, "#error" => 1, "#warning" => 1,
 	"#pragma" => 1, "#include" => 1, "#import" => 1 , "NULL" => 1,
	"true" => 1, "false" => 1);
    my %CppKeywords = (%CKeywords,
	("class" => 1, 
	"friend" => 1,
	"mutable" => 1,
	"namespace" => 1,
	"operator" => 1,
	"private" => 1,
	"protected" => 1,
	"public" => 1,
	"template" => 1,
	"virtual" => 1));
    my %ObjCKeywords = (%CKeywords,
	("\@class" => 1,
	"\@interface" => 1,
	"\@protocol" => 1,
	"\@property" => 1,
	"\@public" => 1,
	"\@private" => 1,
	"\@protected" => 1,
	"\@package" => 1,
	"\@synthesize" => 1,
	"\@dynamic" => 1,
	"\@optional" => 1,
	"\@required" => 1,
	"nil" => 1,
	"YES" => 1,
	"NO" => 1 ));
    my %phpKeywords = (%CKeywords, ("function" => 1));
    my %javascriptKeywords = (
	"abstract" => 1, 
	# "assert" => 1, 
	"break" => 1, 
	# "byte" => 1, 
	"case" => 1, 
	"catch" => 1, 
	# "char" => 1, 
	"class" => 1, 
	"const" => 1, 
	"continue" => 1, 
	"debugger" => 1, 
	"default" => 1, 
	"delete" => 1, 
	"do" => 1, 
	# "double" => 1, 
	"else" => 1,
	"enum" => 1,
	"export" => 1,
	"extends" => 3,
	"false" => 1,
	"final" => 1,
	"finally" => 1,
	# "float" => 1,
	"for" => 1,
	"function" => 1,
	"goto" => 1,
	"if" => 1,
	"implements" => 4,
	"import" => 1,
	"in" => 1,
	"instanceof" => 1,
	# "int" => 1,
	"interface" => 1,
	# "long" => 1,
	"native" => 1,
	"new" => 1,
	"null" => 1,
	"package" => 1,
	"private" => 1,
	"protected" => 1,
	"public" => 1,
	"return" => 1,
	# "short" => 1,
	"static" => 8,
	"super" => 1,
	"switch" => 1,
	"synchronized" => 1,
	"this" => 1,
	"throw" => 1,
	"throws" => 1,
	"transient" => 1,
	"true" => 1,
	"try" => 1,
	"typeof" => 1,
	"var" => 1,
	# "void" => 1,
	"volatile"  => 1,
	"while"  => 1,
	"with"  => 1);
    my %javaKeywords = (
	"abstract" => 1, 
	"assert" => 1, 
	"break" => 1, 
	"case" => 1, 
	"catch" => 1, 
	"class" => 1, 
	"const" => 1, 
	"continue" => 1, 
	"default" => 1, 
	"do" => 1, 
	"else" => 1,
	"enum" => 1,
	"extends" => 3,
	"false" => 1,
	"final" => 1,
	"finally" => 1,
	"for" => 1,
	"goto" => 1,
	"if" => 1,
	"implements" => 4,
	"import" => 1,
	"instanceof" => 1,
	"interface" => 1,
	"native" => 1,
	"new" => 1,
	"package" => 1,
	"private" => 1,
	"protected" => 1,
	"public" => 1,
	"return" => 1,
	"static" => 8,
	"strictfp" => 1,
	"super" => 1,
	"switch" => 1,
	"synchronized" => 1,
	"this" => 1,
	"throw" => 1,
	"throws" => 1,
	"transient" => 1,
	"true" => 1,
	"try" => 1,
	"volatile"  => 1,
	"while"  => 1);
    my %tclKeywords = ( "method" => 1, "constructor" => 1, "proc" => 1, "attribute" => 1 ); # Consider adding "regexp" command? # @@@ ADD "class" and fix bugs.
    my %perlKeywords = ( "sub"  => 1, "my" => 8, "next" => 1, "last" => 1,
	"package" => 1 );
    my %shellKeywords = ( "sub"  => 1, "alias" => 1,
		"set" => 1, "alias" => 1,
		"if" => 1, "fi" => 1,
		"case" => 9, "esac" => 10
	);
    my %cshKeywords = ( "set"  => 1, "setenv" => 1, "alias" => 1);
    my %pythonKeywords = ( "and" => 1, "assert" => 1, "break" => 1,
	"class" => 1, "continue" => 1, "def" => 1, "del" => 1,
	"elif" => 1, "else" => 1, "except" => 1, "exec" => 1,
	"finally" => 1, "for" => 1, "from" => 1, "global" => 1,
	"if" => 1, "import" => 1, "in" => 1, "is" => 1,
	"lambda" => 1, "not" => 1, "or" => 1, "pass" => 1,
	"print" => 1, "raise" => 1, "return" => 1, "try" => 1,
	"while" => 1, "yield" => 1
    );
    my %applescriptKeywords = ( "about" => 1, "above" => 1, "after" => 1,
	"against" => 1, "and" => 1, "apart from" => 1, "around" => 1,
	"as" => 1, "aside from" => 1, "at" => 1, "back" => 1, "before" => 1,
	"beginning" => 1, "behind" => 1, "below" => 1, "beneath" => 1,
	"beside" => 1, "between" => 1, "but" => 1, "by" => 1,
	"considering" => 1, "contain" => 1, "contains" => 1, "continue" => 1,
	"copy" => 1, "div" => 1, "does" => 1, "eighth" => 1, "else" => 1,
	"end" => 1, "equal" => 1, "equals" => 1, "error" => 1, "every" => 1,
	"exit" => 1, "false" => 1, "fifth" => 1, "first" => 1, "for" => 1,
	"fourth" => 1, "from" => 1, "front" => 1, "get" => 1, "given" => 1,
	"global" => 1, "if" => 1, "ignoring" => 1, "in" => 1,
	"instead of" => 1, "into" => 1, "is" => 1, "it" => 1, "its" => 1,
	"last" => 1, "local" => 1, "me" => 1, "middle" => 1, "mod" => 1,
	"my" => 1, "ninth" => 1, "not" => 1, "of" => 1, "on" => 1, "onto" => 1,
	"or" => 1, "out of" => 1, "over" => 1, "prop" => 1, "property" => 1,
	"put" => 1, "ref" => 1, "reference" => 1, "repeat" => 1, "return" => 1,
	"returning" => 1, "script" => 1, "second" => 1, "set" => 1,
	"seventh" => 1, "since" => 1, "sixth" => 1, "some" => 1, "tell" => 1,
	"tenth" => 1, "that" => 1, "the" => 1, "then" => 1, "third" => 1,
	"through" => 1, "thru" => 1, "timeout" => 1, "times" => 1, "to" => 1,
	"transaction" => 1, "true" => 1, "try" => 1, "until" => 1,
	"where" => 1, "while" => 1, "whose" => 1, "with" => 1, "without" => 1
    );
    my %pascalKeywords = (
	"absolute" => 1, "abstract" => 1, "all" => 1, "and" => 1, "and_then" => 1,
	"array" => 1, "asm" => 1, "begin" => 1, "bindable" => 1, "case" => 1, "class" => 1,
	"const" => 1, "constructor" => 1, "destructor" => 1, "div" => 1, "do" => 1,
	"downto" => 1, "else" => 1, "end" => 1, "export" => 1, "file" => 1, "for" => 1,
	"function" => 1, "goto" => 1, "if" => 1, "import" => 1, "implementation" => 1,
	"inherited" => 1, "in" => 1, "inline" => 1, "interface" => 1, "is" => 1, "label" => 1,
	"mod" => 1, "module" => 1, "nil" => 1, "not" => 1, "object" => 1, "of" => 1, "only" => 1,
	"operator" => 1, "or" => 1, "or_else" => 1, "otherwise" => 1, "packed" => 1, "pow" => 1,
	"procedure" => 1, "program" => 1, "property" => 1, "qualified" => 1, "record" => 1,
	"repeat" => 1, "restricted" => 1, "set" => 1, "shl" => 1, "shr" => 1, "then" => 1, "to" => 1,
	"type" => 1, "unit" => 1, "until" => 1, "uses" => 1, "value" => 1, "var" => 1, "view" => 1,
	"virtual" => 1, "while" => 1, "with" => 1, "xor"  => 1);
    my %IDLKeywords = (
	"abstract" => 1, "any" => 1, "attribute" => 1, "case" => 1,
# char
	"component" => 1, "const" => 1, "consumes" => 1, "context" => 1, "custom" => 1, "default" => 1,
# double
	"exception" => 1, "emits" => 1, "enum" => 1, "eventtype" => 1, "factory" => 1, "FALSE" => 1,
	"finder" => 1, "fixed" => 1,
# float
	"getraises" => 5, "getter" => 1, "home" => 1, "import" => 1, "in" => 1, "inout" => 1, "interface" => 1,
	"local" => 1, "long" => 1, "module" => 1, "multiple" => 1, "native" => 1, "Object" => 1,
	"octet" => 1, "oneway" => 1, "out" => 1, "primarykey" => 1, "private" => 1, "provides" => 1,
	"public" => 1, "publishes" => 1, "raises" => 5, "readonly" => 1, "setraises" => 5, "setter" => 1, "sequence" => 1,
# short
# string
	"struct" => 1, "supports" => 1, "switch" => 1, "TRUE" => 1, "truncatable" => 1, "typedef" => 1,
	"typeid" => 1, "typeprefix" => 1, "unsigned" => 1, "union" => 1, "uses" => 1, "ValueBase" => 1,
	"valuetype" => 1,
# void
# wchar
# wstring
	"#define" => 1,
	"#ifdef" => 1, "#ifndef" => 1, "#if" => 1, "#endif" => 1,
	"#undef" => 1, "#elif" => 1, "#error" => 1, "#warning" => 1,
 	"#pragma" => 1, "#include" => 1, "#import" => 1 );
    my %MIGKeywords = (
	"routine" => 1, "simpleroutine" => 1, "countinout" => 1, "inout" => 1, "in" => 1, "out" => 1,
	"subsystem" => 1, "skip" => 1, "#define" => 1,
	"#ifdef" => 1, "#ifndef" => 1, "#if" => 1, "#endif" => 1,
	"#undef" => 1, "#elif" =>1, "#error" => 1, "#warning" => 1,
 	"#pragma" => 1, "#include" => 1, "#import" => 1, "import" => 1, "simport" => 1, "type" => 1,
	"skip" => 1, "serverprefix" => 1, "serverdemux" => 1, "userprefix" => 1 );

    my $objC = 0;
    my %keywords = %CKeywords;
    # warn "Language is $lang, sublanguage is $sublang\n";

    if ($lang eq "applescript") {
	%keywords = %applescriptKeywords;
    }
    if ($lang eq "python") {
	%keywords = %pythonKeywords;
    }
    if ($lang eq "ruby") {
	%keywords = %RubyKeywords;
    }
    if ($lang eq "C") {
	SWITCH: {
	    ($sublang eq "cpp") && do { %keywords = %CppKeywords; last SWITCH; };
	    ($sublang eq "C") && do { last SWITCH; };
	    ($sublang =~ /^occ/o) && do { %keywords = %ObjCKeywords; $objC = 1; last SWITCH; }; #occ, occCat
	    ($sublang eq "intf") && do { %keywords = %ObjCKeywords; $objC = 1; last SWITCH; };
	    ($sublang eq "MIG") && do { %keywords = %MIGKeywords; last SWITCH; };
	    ($sublang eq "IDL") && do { %keywords = %IDLKeywords; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "Csource") {
	SWITCH: {
	    ($sublang eq "Csource") && do { last SWITCH; };
	    ($sublang eq "cpp") && do { %keywords = %CppKeywords; last SWITCH; };
	    ($sublang eq "C") && do { last SWITCH; };
	    ($sublang =~ /^occ/o) && do { %keywords = %ObjCKeywords; $objC = 1; last SWITCH; }; #occ, occCat
	    ($sublang eq "intf") && do { %keywords = %ObjCKeywords; $objC = 1; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "php") {
	SWITCH: {
	    ($sublang eq "php") && do { %keywords = %phpKeywords; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "java") {
	SWITCH: {
	    ($sublang eq "java") && do { %keywords = %javaKeywords; last SWITCH; };
	    ($sublang eq "javascript") && do { %keywords = %javascriptKeywords; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "tcl") {
	SWITCH: {
	    ($sublang eq "tcl") && do { %keywords = %tclKeywords; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "perl") {
	SWITCH: {
	    ($sublang eq "perl") && do { %keywords = %perlKeywords; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "shell") {
	SWITCH: {
	    ($sublang eq "csh") && do { %keywords = %cshKeywords; last SWITCH; };
	    ($sublang eq "shell") && do { %keywords = %shellKeywords; last SWITCH; };
	    warn "$fullpath:$linenum: warning: Unknown language ($lang:$sublang)\n";
	}
    }
    if ($lang eq "pascal") {
	%keywords = %pascalKeywords;
	$case_sensitive = 0;
    }
    if ($lang eq "C" && $sublang eq "MIG") {
	$case_sensitive = 0;
    }

    # foreach my $keyword (sory %keywords) {
	# print STDERR "keyword $keyword\n";
    # }

    $self->{KEYWORDHASH} = \%keywords;
    $self->{CASESENSITIVE} = $case_sensitive;

# print STDERR "KEYS\n";foreach my $key (keys %keywords) { print STDERR "KEY: $key\n"; }print STDERR "ENDKEYS\n";

    return ($case_sensitive, \%keywords);
}

# /*!
#     @abstract
#         Converts HTML to XHTML (fast version).
#     @param self
#         This object.
#     @param htmldata
#         The data to translate.
#     @param droppara
#         Unused.
#     @param debugname
#         A name to use to identify this block when printing debug info.
#     @discussion
#         This version calls into
#  {@link //apple_ref/perl/instm/HeaderDoc::Utilities/html2xhtml//() html2xhtml}
#         if the content contains tags.  Otherwise, it
#         returns the original string immediately.
#  */
sub htmlToXML
{
    my $self = shift;
    my $htmldata = shift;
    my $droppara = shift;
    my $debugname = shift;

    my $localDebug = 0;

    if ($htmldata !~ /[<>&]/o) {
	print STDERR "FASTPATH FOR $debugname\n" if ($localDebug);
	return $htmldata;
    }

    my $result = html2xhtml($htmldata, $self->encoding(), $debugname);

    print STDERR "FOR:\n$htmldata\nENDFOR\nRETURNING:\n$result\nENDRETURN\n" if ($localDebug);

    return $result;
}

# /*!
#     @abstract
#         Encodes text into HTML/XML entities.
#     @param self
#         This object.
#     @param textdata
#         The text to convert.
#  */
sub textToXML
{
    my $self = shift;
    my $textdata = shift;

    $textdata =~ s/&/&amp;/sgo;
    $textdata =~ s/</&lt;/sgo;
    $textdata =~ s/>/&gt;/sgo;

    return $textdata;
}

# /*!
#     @abstract
#         Prints the declaration with HTML or XML formatting.
#     @param self
#         This object.
#     @param declaration
#         The raw declaration. (Optional.)
#     @discussion
#         If you pass in something for <code>declaration</code>,
#         this function computes the declaration based on the
#         parse trees.  If you do not pass an argument for
#         <code>declaration</code>, this function returns the
#         cached value from the last call (which could be empty).
#  */
sub declarationInHTML {
    my $self = shift;
    my $class = ref($self) || $self;
    my $localDebug = 0;
    # my $lang = $self->lang();
    my $xml = 0;
    # my $priDec = wrap($self->privateDeclaration());
    if ($self->outputformat() eq "hdxml") { $xml = 1; }

    if (@_) {
	# @@@ DISABLE STYLES FOR DEBUGGING HERE @@@
	my $disable_styles = 0;
	if ($xml) {
		my $xmldec = shift;

		if (1 || $HeaderDoc::use_styles && !$disable_styles) {
			my $parseTree_ref = $self->parseTree();
			my $parseTree = ${$parseTree_ref};
			bless($parseTree, "HeaderDoc::ParseTree");
			if ($self->can("isBlock") && $self->isBlock()) {
				$xmldec = "";
				my @tree_refs = @{$self->parseTreeList()};

				foreach my $tree_ref (@tree_refs) {
					my $tree = ${$tree_ref};
					bless($tree,  "HeaderDoc::ParseTree");
					$xmldec .= $tree->xmlTree($self->preserve_spaces(), $self->hideContents())."\n";
				}

			} else {
				$xmldec = $parseTree->xmlTree($self->preserve_spaces(), $self->hideContents());
			}
			$self->{DECLARATIONINHTML} = $xmldec;
		} else {
        		$self->{DECLARATIONINHTML} = $self->textToXML($xmldec);
		}


		return $xmldec;
	}
		
	my $declaration = shift;

	if (1 || $HeaderDoc::use_styles && !$disable_styles) {
	  # print STDERR "I AM ".$self->name()." ($self)\n";
	  if ($self->can("isBlock") && $self->isBlock()) {
		# my $declaration = "";
		my @defines = $self->parsedParameters();

		## foreach my $define (@defines) {
			## # Force the declaration of each #define to get rebuilt.
			## $declaration .= $define->declarationInHTML();
			## $declaration .= "\n";
		## }
		$declaration = "";

		my @tree_refs = @{$self->parseTreeList()};
		foreach my $tree_ref (@tree_refs) {
			my $tree = ${$tree_ref};
			bless($tree,  "HeaderDoc::ParseTree");
			# print STDERR "Processing tree $tree\n";
			# print STDERR $tree->htmlTree();
			# print STDERR "\nEND TREE\n";
			# $tree->dbprint();
			$declaration .= $tree->htmlTree($self->preserve_spaces(), $self->hideContents())."\n";
		}
		# print STDERR "END PROCESSING.  DECLARATION IS:\n$declaration\nEND DECLARATION\n";
	  } else {
		my $parseTree_ref = $self->parseTree();
		my $parseTree = ${$parseTree_ref};
		bless($parseTree, "HeaderDoc::ParseTree");
		# print STDERR "PT: ".$parseTree."\n";
		# $parseTree->printTree();
		$declaration = $parseTree->htmlTree($self->preserve_spaces(), $self->hideContents());
		# print STDERR "HTMLTREE: $declaration\n";
	  }
	}

	# print STDERR "SET DECLARATION TO $declaration\n";
        $self->{DECLARATIONINHTML} = $declaration;
    }
    return $self->{DECLARATIONINHTML};
}

# /*!
#    @abstract
#         Gets/sets the parse tree associated with this object.
#    @param self
#         This object.
#    @param parsetree
#         A reference to the parse tree to set/add. (Optional.)
#    @discussion
#        If this is a block declaration, the parse tree is added to
#        its list of parse trees.
#  */
sub parseTree {
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
	my $parsetree = shift;
	if ($self->can("isBlock") && $self->isBlock()) {
		$self->addParseTree($parsetree);
	}
        $self->{PARSETREE} = $parsetree;

	my $class = ref($self) || $self;
	if ($self->lang eq "applescript" && $class eq "HeaderDoc::Function") {
		if (!$self->{AS_CLASS_SELF}) {
			$self->cloneAppleScriptFunctionContents();
		}
		if ($localDebug) {
			print STDERR "ADDING PARSE TREE FOR $self\n";
			bless($parsetree, "HeaderDoc::ParseTree");
			${$parsetree}->dbprint();
		}
	}
    }
    return $self->{PARSETREE};
}

# /*!
#    @abstract
#         Returns the array of parse trees associated with this object.
#    @param self
#         This object.
#   */
sub parseTreeList
{
    my $self = shift;
    my $localDebug = 0;

    if ($localDebug) {
      print STDERR "OBJ ".$self->name().":\n";
      foreach my $treeref (@{$self->{PARSETREELIST}}) {
	my $tree = ${$treeref};
	bless($tree, "HeaderDoc::ParseTree");
	print STDERR "PARSE TREE: $tree\n";
	$tree->dbprint();
      }
    }

    if ($self->{PARSETREELIST}) {
	return $self->{PARSETREELIST};
    }

    if (!$HeaderDoc::running_test) {
	die("No parse trees for object $self.\n".
	    "Name is ".$self->name().".  This usually\n".
	    "points to a headerdoc comment before a #if whose contents are not a\n".
	    "complete declaraction.  This is a fatal error.  Exiting.\n");
    }

    # If we get here, we're being lazily called from the test framework, so return
    # an empty list of parse trees.
    my @arr = ();

    return \@arr;
}

# /*!
#     @abstract
#         Adds a parse tree to the array of parse trees associated with this object.
#     @param self
#         This object.
#     @param tree
#         A reference to the parse tree object to add.
#  */
sub addParseTree
{
    my $self = shift;
    my $tree = shift;

    my $localDebug = 0;

    push(@{$self->{PARSETREELIST}}, $tree);

    if ($localDebug) {
      print STDERR "OBJ ".$self->name().":\n";
      foreach my $treeref (@{$self->{PARSETREELIST}}) {
	my $tree = ${$treeref};
	print STDERR "PARSE TREE: $tree\n";
	bless($tree, "HeaderDoc::ParseTree");
	$tree->dbprint();
      }
    }

}

# /*!
#     @abstract
#         Adds the main parse tree to the parse tree list if missing.
#     @param self
#         This object.
#  */
sub fixParseTrees
{
	my $self = shift;
	my $localDebug = 0;

	if (!$self->{PARSETREE}) {
		# Nothing to do.
		return;
	}

	my @trees = ();
	if ($self->{PARSETREELIST}) {
		@trees = @{$self->{PARSETREELIST}};
	}
	my $match = 0;
	my $searchtree = ${$self->{PARSETREE}};
	print STDERR "Looking for tree $searchtree\n" if ($localDebug);
	foreach my $treeref (@trees) {
		my $tree = ${$treeref};
		print STDERR "Comparing with $tree\n" if ($localDebug);
		if ($tree == $searchtree) { $match = 1; }
	}
	if (!$match) {
		print STDERR "Not found.  Adding\n" if ($localDebug);
		$self->addParseTree($self->{PARSETREE});
	} else {
		print STDERR "Found.  Not adding\n" if ($localDebug);
	}
}

# /*!
#     @abstract
#         Appends an availabiilty macro string to the original availability string
#         if it is missing.
#     @param self
#         This object.
#     @param orig
#         The original availability string.
#  */
sub availabilityAuto
{
    my $self = shift;
    my $orig = shift;

    my $localDebug = 0;

    my $fullpath = $self->fullpath();

    print STDERR "GENERATING AVAILABILITY FOR $self FP ".$self->fullpath()."\n" if ($localDebug);

    my $rangeref = $HeaderDoc::perHeaderRanges{$fullpath};

    if ($localDebug) {
	print STDERR "FULLPATH: $fullpath\n";

	foreach my $x (keys %HeaderDoc::perHeaderRanges) {
		print STDERR "PHR{$x} = ".$HeaderDoc::perHeaderRanges{$x}."\n";
	}
    }

    my @ranges = @{$rangeref};
    my $linenum = $self->linenum();

    my $string = "";

    print STDERR "IN AVAILABILITYAUTO (name is ".$self->name()."\n" if ($localDebug);
    foreach my $rangeref (@ranges) {
	print STDERR "RANGE $rangeref\n" if ($localDebug);
	my $range = ${$rangeref};
	bless($range, "HeaderDoc::LineRange");
	if ($range->inrange($linenum)) {
	    my $newbit = $range->text();
	    my @pieces = split(/\;/, $newbit);
	    foreach my $piece (@pieces) {
	      my $nvpiece = $piece; $nvpiece =~ s/10\..*$//s;
		# print STDERR "SEARCH $string $newbit";
	      my $found = -1;
	      if (($found = index(lc $orig, lc $nvpiece)) == -1) {
	        if (($found = index(lc $string, lc $nvpiece)) == -1) {
		    if (length($string)) {
			$string .= "  ";
		    }
		    $string .= $piece.".";
		}
	      }
	    }
	}
    }
    print STDERR "LEAVING AVAILABILITYAUTO (RETURN IS $string)\n" if ($localDebug);
    return $string;
}

# /*!
#     @abstract
#         Gets/sets the availability for this object.
#     @param self
#         This object.
#     @param availstring
#         The availability string from the HeaderDoc comment.
#  */
sub availability {
    my $self = shift;

    if (@_) {
        $self->{AVAILABILITY} = shift;
    }
    my $string = $self->{AVAILABILITY};
    my $add = $self->availabilityAuto($string);
    if (length($string) && length($add)) {
	$string .= "  ";
    }
    return $string.$add;
}

# /*!
#     @abstract
#         Gets/sets the programming language for this object.
#     @param self
#         This object.
#     @param lang
#         The new value. (Optional.)
#  */
sub lang {
    my $self = shift;

    if (@_) {
        $self->{LANG} = shift;
    }
    return $self->{LANG};
}

# /*!
#     @abstract
#         Gets/sets the programming language dialect for this object.
#     @param self
#         This object.
#     @param sublang
#         The new value. (Optional.)
#     @discussion
#         The dialect, sublang, represents a more specific language
#         than the main language in some cases.  For example, with
#         C-based languages, the language is <code>C</code>, but the sublang can
#         be <code>C</code> (standard C, translated to a lowercase
#         <code>c</code> in the actual API reference), <code>occ</code> (Objective-C),
#         <code>cpp</code> (C++), etc.
#  */
sub sublang {
    my $self = shift;

    if (@_) {
	my $sublang = shift;

	if ($sublang eq "occCat") { $sublang = "occ"; }
        $self->{SUBLANG} = $sublang;
    }
    return $self->{SUBLANG};
}

# /*!
#     @abstract
#         Gets/sets the last updated date for this object.
#     @param self
#         This object.
#     @param updated
#         The new value. (Optional.)
#  */
sub updated {
    my $self = shift;
    my $localdebug = 0;
    
    if (@_) {
	my $updated = shift;
        # $self->{UPDATED} = shift;
	my $month; my $day; my $year;

	$month = $day = $year = $updated;

	print STDERR "updated is $updated\n" if ($localdebug);
	if (!($updated =~ /\d\d\d\d-\d\d-\d\d/o )) {
	    if (!($updated =~ /\d\d-\d\d-\d\d\d\d/o )) {
		if (!($updated =~ /\d\d-\d\d-\d\d/o )) {
		    # my $fullpath = $HeaderDoc::headerObject->fullpath();
		    my $fullpath = $self->fullpath();
		    my $linenum = $self->linenum();
		    warn "$fullpath:$linenum: warning: Bogus date format: $updated.\n";
		    warn "$fullpath:$linenum: warning: Valid formats are MM-DD-YYYY, MM-DD-YY, and YYYY-MM-DD\n";
		    return $self->{UPDATED};
		} else {
		    $month =~ s/(\d\d)-\d\d-\d\d/$1/smog;
		    $day =~ s/\d\d-(\d\d)-\d\d/$1/smog;
		    $year =~ s/\d\d-\d\d-(\d\d)/$1/smog;

                    my $century;
                    $century = `date +%C`;
                    $century *= 100; 
                    $year += $century;
                    # $year += 2000;
                    print STDERR "YEAR: $year" if ($localdebug);
		}
	    } else {
		print STDERR "03-25-2003 case.\n" if ($localdebug);
		    $month =~ s/(\d\d)-\d\d-\d\d\d\d/$1/smog;
		    $day =~ s/\d\d-(\d\d)-\d\d\d\d/$1/smog;
		    $year =~ s/\d\d-\d\d-(\d\d\d\d)/$1/smog;
	    }
	} else {
		    $year =~ s/(\d\d\d\d)-\d\d-\d\d/$1/smog;
		    $month =~ s/\d\d\d\d-(\d\d)-\d\d/$1/smog;
		    $day =~ s/\d\d\d\d-\d\d-(\d\d)/$1/smog;
	}
	$month =~ s/\n//smog;
	$day =~ s/\n//smog;
	$year =~ s/\n//smog;
	$month =~ s/\s*//smog;
	$day =~ s/\s*//smog;
	$year =~ s/\s*//smog;

	# Check the validity of the modification date

	my $invalid = 0;
	my $mdays = 28;
	if ($month == 2) {
		if ($year % 4) {
			$mdays = 28;
		} elsif ($year % 100) {
			$mdays = 29;
		} elsif ($year % 400) {
			$mdays = 28;
		} else {
			$mdays = 29;
		}
	} else {
		my $bitcheck = (($month & 1) ^ (($month & 8) >> 3));
		if ($bitcheck) {
			$mdays = 31;
		} else {
			$mdays = 30;
		}
	}

	if ($month > 12 || $month < 1) { $invalid = 1; }
	if ($day > $mdays || $day < 1) { $invalid = 1; }
	if ($year < 1970) { $invalid = 1; }

	if ($invalid) {
		# my $fullpath = $HeaderDoc::headerObject->fullpath();
		my $fullpath = $self->fullpath();
		my $linenum = $self->linenum();
		warn "$fullpath:$linenum: warning: Invalid date (year = $year, month = $month, day = $day).\n";
		warn "$fullpath:$linenum: warning: Valid formats are MM-DD-YYYY, MM-DD-YY, and YYYY-MM-DD\n";
		return $self->{UPDATED};
	} else {
		$self->{UPDATED} = HeaderDoc::HeaderElement::strdate($month-1, $day, $year, $self->encoding());
		print STDERR "date set to ".$self->{UPDATED}."\n" if ($localdebug);
	}
    }
    return $self->{UPDATED};
}

# /*!
#     @abstract
#         Gets/sets the linkage state for this object.
#     @param self
#         This object.
#     @param linkagestate
#         The new value. (Optional.)
#  */
sub linkageState {
    my $self = shift;
    
    if (@_) {
        $self->{LINKAGESTATE} = shift;
    }
    return $self->{LINKAGESTATE};
}

# /*!
#     @abstract
#         Gets/sets the access control (public/private) for this object.
#     @param self
#         This object.
#     @param access
#         The new value. (Optional.)
#  */
sub accessControl {
    my $self = shift;
    
    if (@_) {
        $self->{ACCESSCONTROL} = shift;
    }
    return $self->{ACCESSCONTROL};
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
 
    print STDERR "------------------------------------\n";
    print STDERR "HeaderElement\n";
    print STDERR "name: $self->{NAME}\n";
    print STDERR "abstract: $self->{ABSTRACT}\n";
    print STDERR "declaration: $dec\n";
    print STDERR "declaration in HTML: $self->{DECLARATIONINHTML}\n";
    print STDERR "discussion: $self->{DISCUSSION}\n";
    print STDERR "linkageState: $self->{LINKAGESTATE}\n";
    print STDERR "accessControl: $self->{ACCESSCONTROL}\n\n";
    print STDERR "Tagged Parameters:\n";
    my $taggedParamArrayRef = $self->{TAGGEDPARAMETERS};
    if ($taggedParamArrayRef) {
	my $arrayLength = @{$taggedParamArrayRef};
	if ($arrayLength > 0) {
	    &printArray(@{$taggedParamArrayRef});
	}
	print STDERR "\n";
    }
    my $fieldArrayRef = $self->{CONSTANTS};
    if ($fieldArrayRef) {
        my $arrayLength = @{$fieldArrayRef};
        if ($arrayLength > 0) {
            &printArray(@{$fieldArrayRef});
        }
        print STDERR "\n";
    }
}

# /*!
#     @abstract
#         Retargets HTML links.
#     @param self
#         This object.
#     @param inpString
#         The string of HTML to fix.
#  */
sub linkfix {
    my $self = shift;
    my $inpString = shift;
    my @parts = split(/\</, $inpString);
    my $first = 1;
    my $outString = "";
    my $localDebug = 0;

    print STDERR "Parts:\n" if ($localDebug);
    foreach my $part (@parts) {
	print STDERR "$part\n" if ($localDebug);
	if ($first) {
		$outString .= $part;
		$first = 0;
	} else {
		if ($part =~ /^\s*A\s+/sio) {
			$part =~ /^(.*?>)/so;
			my $linkpart = $1;
			my $rest = $part;
			$rest =~ s/^\Q$linkpart\E//s;

			print STDERR "Found link.\nlinkpart: $linkpart\nrest: $rest\n" if ($localDebug);

			if ($linkpart =~ /target\=\".*\"/sio) {
			    print STDERR "link ok\n" if ($localDebug);
			    $outString .= "<$part";
			} else {
			    print STDERR "needs fix.\n" if ($localDebug);
			    $linkpart =~ s/\>$//so;
			    $outString .= "<$linkpart target=\"_top\">$rest";
			}
		} else {
			$outString .= "<$part";
		}
	}
    }

    return $outString;
}

# /*! @abstract
#         A function for converting numeric dates into strings.
#     @param month
#         Month in the range 0-11 (not 1-12).
#     @param day
#         Day of the month.
#     @param year
#         Year (four-digit).
#     @var format
#         A time format suitable for <code>strftime</code>.
#         Extracted from the HeaderDoc configuration file.
#         Also contains a compatibility hack for compatibility with
#         the old HeaderDoc date format codes.
#  */
sub strdate($$$$)
{
    my $month = shift;
    my $day = shift;
    my $year = shift;
    my $encoding = shift;
    my $format = $HeaderDoc::datefmt;
    if (!defined $format) {
	$format = "%B %d, %Y";
    }

    my $time_t = mktime(0, 0, 0, $day, $month, $year-1900);
    my ($sec,$min,$hour,$mday,$mon,$yr,$wday,$yday,$isdst) = localtime($time_t);
    my $time = strftime($format, $sec, $min, $hour,
	$mday, $mon, $yr, $wday, $yday, $isdst);

    my $current_encoding = getDefaultEncoding();

    # die("CURENC: ".$current_encoding);

    # cluck("TIME: $time ENC: $encoding");

    my $perltimestring = decode($current_encoding, $time);

    if ($encoding eq "macintosh") {
	return encode("mac_roman", $perltimestring);
    } else {
	return encode($encoding, $perltimestring);
    }

    return $time;

    # print STDERR "format $format\n";

    if ($format eq "") {
	return "$month/$day/$year";
    } else  {
	my $dateString = "";
	my $firstsep = "";
	if ($format =~ /^.(.)/o) {
	  $firstsep = $1;
	}
	my $secondsep = "";
	if ($format =~ /^...(.)./o) {
	  $secondsep = $1;
	}
	SWITCH: {
	  ($format =~ /^M/io) && do { $dateString .= "$month$firstsep" ; last SWITCH; };
	  ($format =~ /^D/io) && do { $dateString .= "$day$firstsep" ; last SWITCH; };
	  ($format =~ /^Y/io) && do { $dateString .= "$year$firstsep" ; last SWITCH; };
	  print STDERR "Unknown date format ($format) in config file[1]\n";
	  print STDERR "Assuming MDY\n";
	  return "$month/$day/$year";
	}
	SWITCH: {
	  ($format =~ /^..M/io) && do { $dateString .= "$month$secondsep" ; last SWITCH; };
	  ($format =~ /^..D/io) && do { $dateString .= "$day$secondsep" ; last SWITCH; };
	  ($format =~ /^..Y/io) && do { $dateString .= "$year$secondsep" ; last SWITCH; };
	  ($firstsep eq "") && do { last SWITCH; };
	  print STDERR "Unknown date format ($format) in config file[2]\n";
	  print STDERR "Assuming MDY\n";
	  return "$month/$day/$year";
	}
	SWITCH: {
	  ($format =~ /^....M/io) && do { $dateString .= "$month" ; last SWITCH; };
	  ($format =~ /^....D/io) && do { $dateString .= "$day" ; last SWITCH; };
	  ($format =~ /^....Y/io) && do { $dateString .= "$year" ; last SWITCH; };
	  ($secondsep eq "") && do { last SWITCH; };
	  print STDERR "Unknown date format ($format) in config file[3]\n";
	  print STDERR "Assuming MDY\n";
	  return "$month/$day/$year";
	}
	return $dateString;
    }
}

# /*!
#     @abstract
#         Sets the CSS for a particular style name.
#     @param self
#         This object.
#     @param name
#         The name of the style.
#     @param style
#         The CSS style data.
#  */
sub setStyle
{
    my $self = shift;
    my $name = shift;
    my $style = shift;

    $style =~ s/^\s*//sgo;
    $style =~ s/\s*$//sgo;

    if (length($style)) {
	$CSS_STYLES{$name} = $style;
	$HeaderDoc::use_styles = 1;
    }
}

# Note: the backslashes before the @ signs in the comment below are
# to prevent HeaderDoc from interpreting the tags.
# /*! 
#     @abstract
#         HTML/XML fixup code to insert superclass discussions
#     @param self
#         This object.
#     @param html
#         The block of (discussion) HTML to process.
#     @discussion
#       This code inserts the discussion from the superclass wherever
#       &lt;hd_ihd/> appears if possible (i.e. where <code>\@inheritDoc</code> (HeaderDoc)
#       or <code>{\@inheritDoc}</code> (JavaDoc) appears in the original input material.
#
#       For XML, &lt;hd_ihd> and &lt;/hd_ihd> tags surround the
#       inherited content.
#  */
sub fixup_inheritDoc
{
    my $self = shift;
    my $html = shift;
    my $newhtml = "";

    my @pieces = split(/</, $html);

    foreach my $piece (@pieces) {
	if ($piece =~ s/^hd_ihd\/>//so) {
		if ($self->outputformat() eq "hdxml") {
			$newhtml .= "<hd_ihd>";
		}
		$newhtml .= $self->inheritDoc();
		if ($self->outputformat() eq "hdxml") {
			$newhtml .= "</hd_ihd>";
		}
		$newhtml .= "$piece";
	} else {
		$newhtml .= "<$piece";
	}
    }
    $newhtml =~ s/^<//so;

    return $newhtml;
}

# /*!
#     @abstract
#         HTML/XML fixup code to insert values
#     @discussion
#       This code inserts values wherever &lt;hd_value/> appears (i.e. where
#       <code>\@value</code> (HeaderDoc) or <code>{\@value}</code> (JavaDoc) appears in the original
#       input material.
#  */
sub fixup_values
{
    my $self = shift;
    my $html = shift;
    my $newhtml = "";

    my @pieces = split(/</, $html);

    foreach my $piece (@pieces) {
	if ($piece =~ s/^hd_value\/>//so) {
		if ($self->outputformat() eq "hdxml") {
			$newhtml .= "<hd_value>";
		}
		$newhtml .= $self->value();
		if ($self->outputformat() eq "hdxml") {
			$newhtml .= "</hd_value>";
		}
		$newhtml .= "$piece";
	} else {
		$newhtml .= "<$piece";
	}
    }
    $newhtml =~ s/^<//so;

    return $newhtml;
}

# /*!
#     @abstract
#         Returns the CSS style data for the specified name.
#     @param self
#         This object.
#     @param name
#         The name of the style.
#  */
sub getStyle
{
    my $self = shift;
    my $name = shift;

   return $CSS_STYLES{$name};
}

# /*!
#     @abstract
#         Returns the complete CSS stylesheet for HeaderDoc content.
#     @param self
#         This object.
#     @param TOC
#         Set to 1 if you are generating styles for the left-side
#         TOC frame, else 0.
#  */
sub styleSheet
{
    my $self = shift;
    my $TOC = shift;
    my $css = "";
    my $stdstyles = 1;

# {
# print STDERR "style test\n";
# $self->setStyle("function", "background:#ffff80; color:#000080;");
# $self->setStyle("text", "background:#000000; color:#ffffff;");
# print STDERR "results:\n";
	# print STDERR "function: \"".$self->getStyle("function")."\"\n";
	# print STDERR "text: \"".$self->getStyle("text")."\"\n";
# }


    if ($TOC) {
	if (defined($HeaderDoc::externalTOCStyleSheets)) {
		$css .= $self->doExternalStyle($HeaderDoc::externalTOCStyleSheets);
		$stdstyles = 0;
	} elsif ($HeaderDoc::externalStyleSheets) {
		$css .= $self->doExternalStyle($HeaderDoc::externalStyleSheets);
		$stdstyles = 0;
	}
    } elsif ($HeaderDoc::externalStyleSheets) {
	$css .= $self->doExternalStyle($HeaderDoc::externalStyleSheets);
	$stdstyles = 0;
    }
    if ($HeaderDoc::suppressDefaultStyles) { $stdstyles = 0; }

    $css .= "<style type=\"text/css\">";
    $css .= "<!--";
    if ($TOC) {
	if (defined($HeaderDoc::tocStyleImports)) {
		my $tempstyle = $HeaderDoc::tocStyleImports;
		$tempstyle =~ s/{\@docroot}/\@\@docroot/sg;
		$css .= html_fixup_links($self, "$tempstyle ");
		$stdstyles = 0;
	} elsif ($HeaderDoc::styleImports) {
		my $tempstyle = $HeaderDoc::styleImports;
		$tempstyle =~ s/{\@docroot}/\@\@docroot/sg;
		$css .= html_fixup_links($self, "$tempstyle ");
		$stdstyles = 0;
	}
    } else {
	if ($HeaderDoc::styleImports) {
		my $tempstyle = $HeaderDoc::styleImports;
		$tempstyle =~ s/{\@docroot}/\@\@docroot/sg;
		$css .= html_fixup_links($self, "$tempstyle ");
		$stdstyles = 0;
	}
    }
    foreach my $stylename (sort strcasecmp keys %CSS_STYLES) {
	my $styletext = $CSS_STYLES{$stylename};
	$css .= ".$stylename {$styletext}";
    }

    if ($stdstyles) {
	# Most stuff is 10 pt.
	$css .= "body {border: 0px; margin: 0px;}";
	$css .= "div {font-size: 10pt; text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #000000;}";
	$css .= "td {font-size: 10pt; text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #000000;}";


	# TOC is 11 pt (except the subentries, which are 10pt.)

	if ($HeaderDoc::newTOC == 5) {
		$css .= "span.hd_tocAccessSpace { display: block; font-size: 1px; height: 3px; min-height: 3px; }";
		$css .= "span.hd_tocGroupSpace { display: block; font-size: 1px; height: 3px; min-height: 3px; }";
		$css .= "span.hd_tocGroup { display: block; font-weight: bold; font-size: 10pt; text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #000000; margin-left: 0px; padding-left: 40px; }"; # padding-left is greater of (toc_leadspace.margin + disclosure_triangle_td.margin + disclosure_padding.margin) or (tocSubEntryList.padding)

		$css .= "span.hd_tocGroup + span.hd_tocAccess { padding-top: 5px; }";

		$css .= "td.toc_contents_text {font-size: 11pt; text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #000000; }";
	}

	$css .= "li.tocSubEntry {font-size: 11pt; text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #000000;}";

	# Everything else is 10 pt.
	$css .= "p {font-size: 10pt; text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #000000;}";
	$css .= "a:link {text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #36c;}";
	$css .= "a:visited {text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #36c;}";
	$css .= "a:visited:hover {text-decoration: underline; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #36c;}";
	$css .= "a:active {text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #36c;}";
	$css .= "a:hover {text-decoration: underline; font-family: lucida grande, geneva, helvetica, arial, sans-serif; color: #36c;}";
	$css .= "h2.h2tight { margin-top: 0px; padding-top: 0px; }"; # bold
	if ($HeaderDoc::newTOC != 5) {
		$css .= ".hd_toc_box h4 { margin-bottom: 2px; padding-bottom: 0px; }";
		$css .= ".hd_toc_box h4 +h4 { margin-top: 2px; padding-top: 0px; }";
	}
	$css .= "h1 { margin-top: 13px; padding-top: 0px; }"; # bold
	$css .= "h4 {text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; font-size: tiny; font-weight: bold;}"; # bold
	$css .= "h5 {text-decoration: none; font-family: lucida grande, geneva, helvetica, arial, sans-serif; font-size: 10.1pt; font-weight: bold;}"; # bold
	$css .= "pre {text-decoration: none; font-family: Courier, Consolas, monospace; color: #666; font-size: 10pt;}"; # bold
	$css .= "pre a { font-family: Courier, Consolas, monospace; color: #666;font-size: 10pt;}"; # bold
	$css .= "pre a:link { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "pre a:visited { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "pre a:visited:hover { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "pre a:active { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "pre a:hover { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "code {text-decoration: none; font-family: Courier, Consolas, monospace; color: #666;font-size: 10pt;}"; # bold
	$css .= "code a { font-family: Courier, Consolas, monospace; color: #666;font-size: 10pt;}"; # bold
	$css .= "code a:link { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "code a:visited { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "code a:visited:hover { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "code a:active { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "code a:hover { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "tt {text-decoration: none; font-family: Courier, Consolas, monospace; color: #666;font-size: 10pt;}"; # bold
	$css .= "tt a { font-family: Courier, Consolas, monospace; color: #666;font-size: 10pt;}"; # bold
	$css .= "tt a:link { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "tt a:visited { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "tt a:visited:hover { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "tt a:active { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "tt a:hover { font-family: Courier, Consolas, monospace; color: #36c;font-size: 10pt;}"; # bold
	$css .= "body  {text-decoration: none; font-family: Courier, Consolas, monospace; color: #666;font-size: 10pt; padding-left: 0px; padding-top: 0px; margin-left: 0px; margin-top: 0px; border: none; }"; # bold
	$css .= "#hd_outermost_table { margin-left: 0px; border-spacing: 0px; margin-top: 0px; padding-left: 0px; padding-top: 0px; border: none; }";
	$css .= "#hd_outermost_table > tr { border-spacing: 0px; margin-left: 0px; margin-top: 0px; padding-left: 0px; padding-top: 0px; border: none; }";
	$css .= "#hd_outermost_table > tr > td { border-spacing: 0px; margin-left: 0px; margin-top: 0px; }";
	$css .= "#hd_outermost_table > tbody > tr { border-spacing: 0px; margin-left: 0px; margin-top: 0px; padding-left: 0px; padding-top: 0px; border: none; }";
	$css .= "#hd_outermost_table > tbody > tr > td { border-spacing: 0px; margin-left: 0px; margin-top: 0px; padding-top: 3px; }";

	$css .= ".afterName { display: none; }";
	$css .= ".list_indent { margin-left: 40px; }";

	$css .= ".declaration_indent { margin-left: 40px; margin-top: 0px; margin-bottom: 0px; padding-top: 0px; padding-bottom: 0px; min-height: 12px; vertical-align: middle; }";
	$css .= ".declaration_indent pre { margin-top: 20px; padding-top: 0px; margin-bottom: 20px; padding-bottom: 0px; }";
	$css .= ".gapBeforeFooter { display: none; }";
	$css .= "hr { height: 0px; min-height: 0px; border-top: none; border-left: none; border-right: none; border-bottom: 1px solid #909090;}";
	$css .= "hr.afterHeader { display: none }";

	$css .= ".param_group_indent { margin-left: 25px; }";
	$css .= ".param_indent { margin-left: 40px; margin-top: 0px; padding-top: 0px; }";
	$css .= ".param_indent dl { margin-top: 4px; padding-top: 0px; }";
	$css .= "dl dd > p:first-child { margin-top: 2px; padding-top: 0px; }";
	$css .= ".param_indent dl dd > p:first-child { margin-top: 2px; padding-top: 0px; }";
	$css .= ".group_indent { margin-left: 40px; }";
	$css .= ".group_desc_indent { margin-left: 20px; }";
	$css .= ".warning_indent { margin-left: 40px; }";
	$css .= ".important_indent { margin-left: 40px; }";
	$css .= ".note_indent { margin-left: 40px; }";

	$css .= "h3 {";
	$css .= "       color: #3C4C6C;";
	$css .= "}";

	$css .= ".tight {";
	$css .= "       margin-top: 2px; margin-bottom: 0px;";
	$css .= "       padding-top: 0px; padding-bottom: 0px;";
	$css .= "}";

	$css .= "h3 a {";
	$css .= "       color: #3C4C6C;";
	$css .= "	font-size: 16px;";
	$css .= "	font-style: normal;";
	$css .= "	font-variant: normal;";
	$css .= "	font-weight: bold;";
	$css .= "	height: 0px;";
	$css .= "	line-height: normal;";
	$css .= "}";

	if ($HeaderDoc::newTOC == 5) {
		$css .= ".hd_tocAccess { display: block; margin-left: 40px; font-style: italic; font-size: 10px; font-weight: normal; color: #303030; }"; # padding-left is greater of (toc_leadspace.margin + disclosure_triangle_td.margin + disclosure_padding.margin) or (tocSubEntryList.padding)
	} else {
		$css .= ".hd_tocAccess { display: block; margin-left: 25px; font-style: italic; font-size: 10px; font-weight: normal; color: #303030; margin-top: 3px; margin-bottom: 3px;}";
	}
	$css .= ".tocSubheading { margin-bottom: 4px; }";
    }

    if ($HeaderDoc::styleSheetExtras) {
	# $css .= $HeaderDoc::styleSheetExtras;
	my $tempstyle = $HeaderDoc::styleSheetExtras;
	$tempstyle =~ s/{\@docroot}/\@\@docroot/sg;
	$css .= html_fixup_links($self, "$tempstyle ");
    }

    $css .= "-->";
    $css .= "</style>";

    return $css;
}

# /*!
#     @abstract
#         Returns the documentation output for this object (in HTML).
#     @param self
#         This object.
#     @param composite
#         Pass 1 if generating a composite page and <code>classAsComposite</code>
#         is 0.  Otherwise, pass 0.
#  */
sub documentationBlock
{
    my $self = shift;
    my $composite = shift;
    my $contentString;
    my $name = $self->name();
    my $desc = $self->discussion();
    my $checkDisc = $self->halfbaked_discussion();
    my $throws = "";
    my $abstract = $self->abstract();
    my $availability = $self->availability();
    my $namespace = ""; if ($self->can("namespace")) { $namespace = $self->namespace(); }
    my $updated = $self->updated();
    my $declaration = "";
    my $result = "";
    my $localDebug = 0;
    # my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();
    my $fullpath = $self->fullpath();
    my $linenum = $self->linenum();
    my $list_attributes = $self->getAttributeLists($composite);
    my $short_attributes = $self->getAttributes(0);
    my $long_attributes = $self->getAttributes(1);
    my $class = ref($self) || $self;
    my $apio = $self->apiOwner();
    my $apioclass = ref($apio) || $apio;
    my $apiref = "";
    my $headlevel = "h3";

    my $newTOCinAPIOwner = $HeaderDoc::newTOC;
    my $showDiscussionHeading = 1;

    my $isAPIO = $self->isAPIOwner();

    if ($self->{HIDEDOC}) { return ""; }

    # print STDERR "$self (".$self->name().") ISINTERNAL: ".$self->isInternal()." DOIT: ".$HeaderDoc::document_internal."\n";

    if ($self->isInternal() && !$HeaderDoc::document_internal) { return ""; }

    my @embeddedClasses = ();
    my $class_self = undef;
    if ($self->lang eq "applescript" && $class eq "HeaderDoc::Function") {
	if (!$self->{ASCONTENTSPROCESSED}) {
		$class_self = $self->processAppleScriptFunctionContents();
		if ($class_self) {
			my @classes = $class_self->classes();
			foreach my $obj (@classes) {
				push(@embeddedClasses, $obj);
			}
		}
	}
    }

    # print STDERR "GOTHERE\n";

    # Only use this style for API Owners.
    if ($isAPIO) {
	$headlevel = "h1";
	if ($newTOCinAPIOwner) {
		$showDiscussionHeading = 0;
	}

	if (($checkDisc !~ /\S/) && ($abstract !~ /\S/)) {
		my $linenum = $self->linenum();
        	warn "$fullpath:$linenum: No header or class discussion/abstract found. Creating dummy file for default content page.\n";
		$abstract .= $HeaderDoc::defaultHeaderComment; # "Use the links in the table of contents to the left to access documentation.<br>\n";    
	}
    } else {
	$newTOCinAPIOwner = 0;
	$declaration = $self->declarationInHTML();
    }

# print STDERR "NAME: $name APIOCLASS: $apioclass APIUID: ".$self->apiuid()."\n";

    if ($self->can("result")) { $result = $self->result(); }
    if ($self->can("throws")) { $throws = $self->throws(); }

    if ($self->noRegisterUID()) {
	cluck("BT\n");
	die("Unexpected unregistered object being inserted into content.  Object is $self, name is ".$self->name().", header is ".$apio->name()."\n");
    }


    # $name =~ s/\s*//smgo;

    if ($isAPIO) {
	if ($self->htmlHeader() =~ /\S/) {
		$contentString .= "<hr class=\"afterHeader\">";
	}
    } else {
	$contentString .= "<hr class=\"betweenAPIEntries\">";
    }
    # my $uid = "//$apiUIDPrefix/c/func/$name";
       
    # registerUID($uid);
    # $contentString .= "<a name=\"$uid\"></a>\n"; # apple_ref marker

    my ($constantsref, $fieldsref, $paramsref, $fieldHeading, $func_or_method, $variablesref)=$self->apirefSetup();
    my @local_variables = @{$variablesref};
    my @constants = @{$constantsref};
    my @fields = @{$fieldsref};
    my @params = @{$paramsref};

    $apiref = $self->apiref($composite);

    my $divid = "docbox_".$self->apiuid();

    # if ($HeaderDoc::enable_custom_references) {
    	# $contentString .= "<div class=\"APIObject\" id=\"$divid\">\n";
    # }

    if (!$isAPIO) {
	$contentString .= $apiref;
    }

    if ($HeaderDoc::newTOC != 5) {
	$contentString .= "<table border=\"0\"  cellpadding=\"2\" cellspacing=\"2\" width=\"300\">";
	$contentString .= "<tr>";
	$contentString .= "<td valign=\"top\" height=\"12\" colspan=\"5\">";
    }
    my $urlname = sanitize($name, 1);
    $contentString .= "<$headlevel><a name=\"$urlname\">$name</a></$headlevel>\n";
    # if ($HeaderDoc::enable_custom_references && $HeaderDoc::newTOC && !$isAPIO) {
	# # Apple-style TOC.  Assume the JavaScript is there.
	# $contentString .= "<p class=\"addToCustomReference\"><a class=\"addToCustomReferenceLink\" href=\"#\" onclick=\"return addToCustomReference(this);\">Add to custom reference</a></p>\n";
	# $contentString .= "<p class=\"removeFromCustomReference\"><a class=\"removeFromCustomReferenceLink\" href=\"#\" onclick=\"return removeFromCustomReference(this);\">Remove from custom reference</a></p>\n";
    # }
    if ($HeaderDoc::newTOC != 5) {
	$contentString .= "</td>";
	$contentString .= "</tr></table>";
    }
    if (!$newTOCinAPIOwner) { $contentString .= "<hr class=\"afterName\">"; }
    my $attstring = ""; my $c = 0;
    if (length($short_attributes)) {
        $attstring .= $short_attributes;
	$c++;
    }
    if (length($list_attributes)) {
        $attstring .= $list_attributes;
	$c++;
    }
    # print STDERR "ATS: $attstring\n";
    if ($newTOCinAPIOwner) {
	if ($c == 2) {
		$attstring =~ s/<\/table><\/div>\s*<div.*?><table.*?>//s;
	}
	$attstring =~ s/<\/table><\/div>\s*$//s;
    }
    if (!$newTOCinAPIOwner) { $attstring .= "<dl>"; }
    if (length($throws)) {
	if ($newTOCinAPIOwner) {
		if (!$c) {
			$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
		}
		$attstring .= "<tr><td scope=\"row\"><b>Throws:</b></td><td><div style=\"margin-bottom:1px\"><div class=\"content_text\">$throws</div></div></td></tr>\n";
	} else {
        	$attstring .= "<dt><b>Throws</b></dt>\n<dd>$throws</dd>\n";
	}
	$c++;
    }
	my $includeList = "";
	if ($class eq "HeaderDoc::Header") {
	    my $includeref = $HeaderDoc::perHeaderIncludes{$fullpath};
	    if ($includeref) {
		my @includes = @{$includeref};

		my $first = 1;
		foreach my $include (@includes) {
			my $localDebug = 0;
			print STDERR "Included file: $include\n" if ($localDebug);

			if (!$first) {
				if ($newTOCinAPIOwner) {$includeList .= "<br>\n"; }
				else {$includeList .= ",\n"; }
			}
			my $xmlinc = $self->textToXML($include);

			my $includeguts = $include;
			$includeguts =~ s/[<\"](.*)[>\"]/$1/so;

			my $includefile = basename($includeguts);

			my $ref = $self->genRefSub("doc", "header", $includefile, "");

			$includeList .= "<!-- a logicalPath=\"$ref\" machineGenerated=\"true\" -->$xmlinc<!-- /a -->";
			$first = 0;
		}

	    }
	}
	if (length($includeList)) {
		if ($newTOCinAPIOwner) {
			if (!$c) {
				$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
			}
			$attstring .= "<tr><td scope=\"row\"><b>Includes:</b></td><td><div style=\"margin-bottom:1px\"><div class=\"content_text\">$includeList</div></div></td></tr>\n";
		} else {
			$attstring .= "<b>Includes</b> ";
			$attstring .= $includeList;
			$attstring .= "<br>\n";
		}
		$c++;
	}


    # if (length($abstract)) {
        # $contentString .= "<dt><i>Abstract:</i></dt>\n<dd>$abstract</dd>\n";
    # }
    if ($newTOCinAPIOwner) { 
	if ($c) { $attstring .= "</table></div>\n"; }

	# Otherwise we do this later.
	$contentString .= $attstring;
    } else {
	if ($attstring =~ /<dl>\s*$/s) {
		$attstring =~ s/<dl>\s*$//s;
	} else {
		$attstring .= "</dl>";
	}
    }

    if ($newTOCinAPIOwner) {
	$contentString .= "<h2>".$HeaderDoc::introductionName."</h2>\n";
    }

    my $uid = $self->apiuid();

    if (length($abstract)) {
	$showDiscussionHeading = 1;
        # $contentString .= "<dt><i>Abstract:</i></dt>\n<dd>$abstract</dd>\n";
	my $absstart = $self->headerDocMark("abstract", "start");
	my $absend = $self->headerDocMark("abstract", "end");
        $contentString .= "<p>$absstart<!-- begin abstract -->";
	if ($self->can("isFramework") && $self->isFramework()) {
		$contentString .= "<!-- headerDoc=frameworkabstract;uid=".$uid.";name=start -->\n";
	}
	$contentString .= "$abstract";
	if ($self->can("isFramework") && $self->isFramework()) {
		$contentString .= "<!-- headerDoc=frameworkabstract;uid=".$uid.";name=end -->\n";
	}
	$contentString .= "<!-- end abstract -->$absend</p>\n";
    }

    my $accessControl = "";
    if ($self->can("accessControl")) {
	$accessControl = $self->accessControl();
    }
    my $optionalOrRequired = "";
    if ($self->parserState && ($apioclass =~ /HeaderDoc::ObjCProtocol/)) {
	$optionalOrRequired = $self->parserState->{optionalOrRequired};
    }
    my $includeAccess = 0;
    if ($accessControl ne "") { $includeAccess = 1; }
    if ($self->can("isProperty") && $self->isProperty()) { $includeAccess = 0; }
    if ($self->class eq "HeaderDoc::Method") { $includeAccess = 0; }
    if ($self->class eq "HeaderDoc::PDefine") { $includeAccess = 0; }
    if ($self->lang eq "perl") { $includeAccess = 0; }

    if (!$isAPIO) {
	$contentString .= "<div class='declaration_indent'>\n";
	my $declstart = $self->headerDocMark("declaration", "start");
	my $declend = $self->headerDocMark("declaration", "end");
	if ($includeAccess) {
		$contentString .= "<pre><tt>$accessControl</tt>\n<br>$declaration</pre>\n";
	} elsif (length $optionalOrRequired) {
		$contentString .= "<pre><tt>$optionalOrRequired</tt>\n<br>$declaration</pre>\n";
	} else {
		$contentString .= "<pre>$declstart$declaration$declend</pre>\n";
	}
	$contentString .= "</div>\n";
    }

    my @parameters_or_fields = ();
    my @callbacks = ();
    foreach my $element (@params) {
	if ($element->isCallback()) {
		push(@callbacks, $element);
	} elsif (!$element->{ISDEFINE}) {
		push(@parameters_or_fields, $element);
	}
    }
    foreach my $element (@fields) {
	if ($element->isCallback()) {
		push(@callbacks, $element);
	} elsif (!$element->{ISDEFINE}) {
		push(@parameters_or_fields, $element);
	}
    }

    my @includedDefines = ();
    if ($self->{INCLUDED_DEFINES}) {
	@includedDefines = @{$self->{INCLUDED_DEFINES}};
    }
    my $arrayLength = @includedDefines;
    if (($arrayLength > 0)) {
        my $paramContentString;

	$showDiscussionHeading = 1;
        foreach my $element (@includedDefines) {

	# print "ELT IS $element\n";

	    if ($self->{HIDESINGLETONS}) {
		if ($element->{MAINOBJECT}) {
			$element = ${$element->{MAINOBJECT}};
			# print "ELEMENT NOW $element\n";
			bless($element, "HeaderDoc::HeaderElement");
			# print "ELEMENT NOW $element\n";
			bless($element, $element->class());
			# print "ELEMENT NOW $element\n";
			# print "ELEMENT NAME ".$element->{NAME}."\n";
		}
	    }
            my $fName = $element->name();
            my $fDesc = $element->discussion();
	    my $fType = "";
	    my $apiref = "";

	    if ($self->can("type")) { $fType = $element->type(); }

	    $apiref = $element->apiref($composite); # , $apiRefType);

            if (length ($fName) &&
		(($fType eq 'field') || ($fType eq 'constant') || ($fType eq 'funcPtr') ||
		 ($fType eq ''))) {
                    # $paramContentString .= "<tr><td align=\"center\"><code>$fName</code></td><td>$fDesc</td></tr>\n";
                    $paramContentString .= "<dt>$apiref<code>$fName</code></dt><dd>$fDesc</dd>\n";
            } elsif ($fType eq 'callback') {
		my @userDictArray = $element->userDictArray(); # contains elements that are hashes of param name to param doc
		my $paramString;
		foreach my $hashRef (@userDictArray) {
		    while (my ($param, $disc) = each %{$hashRef}) {
			$paramString .= "<dt><b><code>$param</code></b></dt>\n<dd>$disc</dd>\n";
		    }
    		    if (length($paramString)) {
			$paramString = "<dl>\n".$paramString."\n</dl>\n";
		    };
		}
		# $contentString .= "<tr><td><code>$fName</code></td><td>$fDesc<br>$paramString</td></tr>\n";
		$contentString .= "<dt><code>$fName</code></dt><dd>$fDesc<br>$paramString</dd>\n";
	    } else {
		# my $fullpath = $HeaderDoc::headerObject->name();
		my $classname = ref($self) || $self;
		$classname =~ s/^HeaderDoc:://o;
		if (!$HeaderDoc::ignore_apiuid_errors) {
			print STDERR "$fullpath:$linenum: warning: $classname ($name) field with name $fName has unknown type: $fType\n";
		}
	    }
        }
        if (length ($paramContentString)){
            $contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Included Defines</font></h5>\n";       
            $contentString .= "<div class='param_indent'>\n";
            # $contentString .= "<table border=\"1\"  width=\"90%\">\n";
            # $contentString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>\n";
            $contentString .= "<dl>\n";
            $contentString .= $paramContentString;
            # $contentString .= "</table>\n</div>\n";
            $contentString .= "</dl>\n";
	    $contentString .= "</div>\n";
        }
    }

    $arrayLength = @parameters_or_fields;
    if (($arrayLength > 0) && (length($fieldHeading))) {
        my $paramContentString;

	$showDiscussionHeading = 1;
        foreach my $element (@parameters_or_fields) {
            my $fName = $element->name();
            my $fDesc = $element->discussion();
	    my $fType = "";
	    my $apiref = "";

	    if ($self->can("type")) { $fType = $element->type(); }

	    $apiref = $element->apiref($composite); # , $apiRefType);

            if (length ($fName) &&
		(($fType eq 'field') || ($fType eq 'constant') || ($fType eq 'funcPtr') ||
		 ($fType eq ''))) {
                    # $paramContentString .= "<tr><td align=\"center\"><code>$fName</code></td><td>$fDesc</td></tr>\n";
                    $paramContentString .= "<dt>$apiref<code>$fName</code></dt><dd>$fDesc</dd>\n";
            } elsif ($fType eq 'callback') {
		my @userDictArray = $element->userDictArray(); # contains elements that are hashes of param name to param doc
		my $paramString;
		foreach my $hashRef (@userDictArray) {
		    while (my ($param, $disc) = each %{$hashRef}) {
			$paramString .= "<dt><b><code>$param</code></b></dt>\n<dd>$disc</dd>\n";
		    }
    		    if (length($paramString)) {
			$paramString = "<dl>\n".$paramString."\n</dl>\n";
		    };
		}
		# $contentString .= "<tr><td><code>$fName</code></td><td>$fDesc<br>$paramString</td></tr>\n";
		$contentString .= "<dt><code>$fName</code></dt><dd>$fDesc<br>$paramString</dd>\n";
	    } else {
		# my $fullpath = $HeaderDoc::headerObject->name();
		my $classname = ref($self) || $self;
		$classname =~ s/^HeaderDoc:://o;
		if (!$HeaderDoc::ignore_apiuid_errors) {
			print STDERR "$fullpath:$linenum: warning: $classname ($name) field with name $fName has unknown type: $fType\n";
		}
	    }
        }
        if (length ($paramContentString)){
            $contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">$fieldHeading</font></h5>\n";       
            $contentString .= "<div class='param_indent'>\n";
            # $contentString .= "<table border=\"1\"  width=\"90%\">\n";
            # $contentString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>\n";
            $contentString .= "<dl>\n";
            $contentString .= $paramContentString;
            # $contentString .= "</table>\n</div>\n";
            $contentString .= "</dl>\n";
	    $contentString .= "</div>\n";
        }
    }
    if (@embeddedClasses) {
	$showDiscussionHeading = 1;
	$contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Embedded Classes</font></h5>\n";
        $contentString .= "<div class='param_indent'>\n";
        $contentString .= "<dl>\n";
        # $contentString .= "<table border=\"1\"  width=\"90%\">\n";
        # $contentString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>\n";
        foreach my $element (@embeddedClasses) {
            my $cName = $element->name();

		# print STDERR "EMBEDDED CLASS: $cName\n";

            my $cDesc = $element->discussion();
            # my $uid = "//$apiUIDPrefix/c/econst/$cName";
            # registerUID($uid);
            my $uid = $element->apiuid(); # "econst");

	    my $safeName = $cName;
	    $safeName = &safeName(filename => $cName);

	    my $url = $class_self->{PARSEDPSEUDOCLASSNAME}.$pathSeparator."Classes".$pathSeparator.$safeName.$pathSeparator."index.html";

	    my $target = "doc";
	    my $classAsComposite = $HeaderDoc::ClassAsComposite;
	    # if ($class eq "HeaderDoc::Header") { $classAsComposite = 0; }

	    if ($composite && !$classAsComposite) { $classAsComposite = 1; $target = "_top"; }
	    if ($element->isAPIOwner()) {
		$target = "_top";
		$classAsComposite = 0;
	    }

	    if ($HeaderDoc::use_iframes) {
		$target = "_top";
	    }

            # $contentString .= "<tr><td align=\"center\"><a href=\"$url\" target=\"$target\"><code>$cName</code></a></td><td>$cDesc</td></tr>\n";
            $contentString .= "<dt><a href=\"$url\" target=\"$target\"><code>$cName</code></a></dt><dd>$cDesc</dd>\n";
        }
        # $contentString .= "</table>\n</div>\n";
        $contentString .= "</dl>\n</div>\n";
    }
    if (@constants) {
	$showDiscussionHeading = 1;
        $contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Constants</font></h5>\n";       
        $contentString .= "<div class='param_indent'>\n";
        $contentString .= "<dl>\n";
        # $contentString .= "<table border=\"1\"  width=\"90%\">\n";
        # $contentString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>\n";
        foreach my $element (@constants) {
            my $cName = $element->name();
            my $cDesc = $element->discussion();
            # my $uid = "//$apiUIDPrefix/c/econst/$cName";
            # registerUID($uid);
            my $uid = $element->apiuid(); # "econst");
            # $contentString .= "<tr><td align=\"center\"><a name=\"$uid\"><code>$cName</code></a></td><td>$cDesc</td></tr>\n";

	    if (!$apio->appleRefUsed($uid) && !$HeaderDoc::ignore_apiuid_errors) {
		# print STDERR "MARKING APIREF $uid used\n";
		$apio->appleRefUsed($uid, 1);
                $contentString .= "<dt><a name=\"$uid\"><code>$cName</code></a></dt><dd>$cDesc</dd>\n";
	    } else {
                $contentString .= "<dt><code>$cName</code></dt><dd>$cDesc</dd>\n";
	    }
        }
        # $contentString .= "</table>\n</div>\n";
        $contentString .= "</dl>\n</div>\n";
    }

    # print "IN $self LOCAL VARS: ".$#local_variables."\n";

    if (scalar(@callbacks)) {
	$showDiscussionHeading = 1;
        $contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Callbacks</font></h5>\n";
        $contentString .= "<div class='param_indent'>\n";
        # $contentString .= "<table border=\"1\"  width=\"90%\">\n";
        # $contentString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>\n";
        $contentString .= "<dl>";

	# foreach my $element (@callbacks) {
		# print STDERR "ETYPE: $element->{TYPE}\n";
	# }

        foreach my $element (@callbacks) {
            my $fName = $element->name();
            my $fDesc = $element->discussion();
            my $fType = $element->type();

            if (($fType eq 'field') || ($fType eq 'constant') || ($fType eq 'funcPtr')){
                # $contentString .= "<tr><td><code>$fName</code></td><td>$fDesc</td></tr>\n";
                $contentString .= "<dt><code>$fName</code></dt><dd>$fDesc</dd>\n";
            } elsif ($fType eq 'callback') {
                my @userDictArray = $element->userDictArray(); # contains elements that are hashes of param name to param doc
                my $paramString;
                foreach my $hashRef (@userDictArray) {
                    while (my ($param, $disc) = each %{$hashRef}) {
                        $paramString .= "<dt><b><code>$param</code></b></dt>\n<dd>$disc</dd>\n";
                    }
                    if (length($paramString)) {$paramString = "<dl>\n".$paramString."\n</dl>\n";};
                }
                # $contentString .= "<tr><td><code>$fName</code></td><td>$fDesc<br>$paramString</td></tr>\n";
                $contentString .= "<dt><code>$fName</code></dt><dd>$fDesc<br>$paramString</dd>\n";
            } else {
                my $fullpath = $HeaderDoc::headerObject->name();
		if (!$HeaderDoc::ignore_apiuid_errors) {
                	print STDERR "$fullpath:$linenum: warning: struct/typdef/union ($name) field with name $fName has unknown type: $fType\n";
			# $element->printObject();
		}
            }
        }

        # $contentString .= "</table>\n</div>\n";
        $contentString .= "</dl>\n</div>\n";
    }

    # if (length($desc)) {$contentString .= "<p>$desc</p>\n"; }
    # $contentString .= "<dl>"; # MOVED LOWER
    if (length($result)) { 
	$showDiscussionHeading = 1;
	$contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Return Value</font></h5><p><!-- begin return value -->";
        # $contentString .= "$func_or_method result</i></dt><dd>
	$contentString .= "$result\n";
	$contentString .= "<!-- end return value --></p>";
    }
    my $stripdesc = $checkDisc;
    $stripdesc =~ s/<br>/\n/sg;


    my $BD = "";
    if ($self->can("blockDiscussion")) {
	$BD = $self->blockDiscussion();
	$BD =~ s/<br>/\n/sg;
    }

    # warn("DESC IS $desc\n");
    # warn("stripdesc IS $stripdesc\n");
    # warn("BD IS $BD\n");

    if ($stripdesc =~ /\S/ || $BD =~ /\S/) {
	if ($showDiscussionHeading) {
		$contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Discussion</font></h5>\n";
	}
	my $discstart = $self->headerDocMark("discussion", "start");
	my $discend = $self->headerDocMark("discussion", "end");
	$contentString .= "<!-- begin discussion -->";
	if ($self->can("isFramework") && $self->isFramework()) {
		$contentString .= "<!-- headerDoc=frameworkdiscussion;uid=".$uid.";name=start -->\n";
	} else {
		$contentString .= $discstart;
	}
	$contentString .= $desc;
	if ($self->can("isFramework") && $self->isFramework()) {
		$contentString .= "<!-- headerDoc=frameworkdiscussion;uid=".$uid.";name=end -->\n";
	} else {
		$contentString .= $discend;
	}
	$contentString .= "<!-- end discussion -->\n";
    }

    # Local variables should be after the discussion.
    if (!$HeaderDoc::suppress_local_variables) {
	if (@local_variables) {
		$showDiscussionHeading = 1;
        	$contentString .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Local Variables</font></h5>\n";       
        	# $contentString .= "<table border=\"1\"  width=\"90%\">\n";
        	# $contentString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>\n";

		my @groups = ();
		my %groupshash = ();
        	foreach my $element (@local_variables) {
			my $group = $element->group();
			$group =~ s/[\r\n]/ /sg;
			$group =~ s/^\s*//s;
			$group =~ s/\s*$//s;
			if (!$group) { $group = " "; }
			if (!$groupshash{$group}) {
				push(@groups, $group);
				my @arr = ();
				$groupshash{$group} = \@arr;
			}
			my @arr = @{$groupshash{$group}};
			push(@arr, \$element);
			$groupshash{$group} = \@arr;
		}

        	foreach my $group (@groups) {
		    if ($group =~ /\S/) {
			$contentString .= "<div class='param_group_indent'>$group</div>\n";
	  	    }
		    $contentString .= "<div class='param_indent'>\n";
		    $contentString .= "<dl>\n";

		    # print STDERR "GROUP \"$group\"\n";
		    my @arr = @{$groupshash{$group}};
		    # print STDERR "COUNT: ".($#arr + 1)."\n";
		    foreach my $elementref (@arr) {
			my $element = ${$elementref};
			# print STDERR "ELEMENT: $element\n";

			my $cName = $element->name();
			my $cDesc = $element->discussion();

			# my $uid = "//$apiUIDPrefix/c/econst/$cName";
			# registerUID($uid);

			my $uid = $element->apiuid(); # "econst");

			# $contentString .= "<tr><td align=\"center\"><a name=\"$uid\"><code>$cName</code></a></td><td>$cDesc</td></tr>\n";

			if (!$apio->appleRefUsed($uid) && !$HeaderDoc::ignore_apiuid_errors) {
				# cluck("MARKING APIREF $uid used\n");
				$apio->appleRefUsed($uid, 1);
				$contentString .= "<dt><a name=\"$uid\"><code>$cName</code></a></dt><dd>$cDesc</dd>\n";
			} else {
				# cluck("Reused Apple Ref $uid\n");
				$contentString .= "<dt><code>$cName</code></dt><dd>$cDesc</dd>\n";
			}
		    }
		    $contentString .= "</dl>\n</div>\n";
		}
		# $contentString .= "</table>\n</div>\n";
	}
    }

    # if (length($desc)) {$contentString .= "<p>$desc</p>\n"; }
    if (!$newTOCinAPIOwner) {
	# Otherwise we do this earlier.
	$contentString .= $attstring;
    }

    if (length($long_attributes)) {
        $contentString .= $long_attributes;
    }

    my $late_attributes = "";
    if (length($namespace)) {
            $late_attributes .= "<dt><b>Namespace</b></dt><dd>$namespace</dd>\n";
    }
    if (length($availability)) {
        $late_attributes .= "<dt><b>Availability</b></dt><dd>$availability</dd>\n";
    }
    if (length($updated)) {
        $late_attributes .= "<dt><b>Updated:</b></dt><dd>$updated</dd>\n";
    }
    if (length($late_attributes)) {
	$contentString .= "<dl>".$late_attributes."</dl>\n";
    }
    # $contentString .= "<hr class=\"afterAttributes\">\n";

    # if ($HeaderDoc::enable_custom_references) {
	# $contentString .= "</div>\n"; # end APIObject div
    # }

    my $value_fixed_contentString = $self->fixup_values($contentString);

    return $value_fixed_contentString;    
}

# /*!
#     @abstract
#         Gets/sets the tagged parameters list for a function, etc.
#     @param self
#         This object
#     @param tplist
#         The new tagged parameters list to set. (Optional.)
#     @discussion
#         The tagged parameters list is an array of
#         {@link //apple_ref/perl/cl/HeaderDoc::MinorAPIElement MinorAPIElement}
#         objects that represent the parameters as tagged in the
#         HeaderDoc comment block.
#  */
sub taggedParameters {
    my $self = shift;
    if (@_) { 
        @{ $self->{TAGGEDPARAMETERS} } = @_;
    }
    ($self->{TAGGEDPARAMETERS}) ? return @{ $self->{TAGGEDPARAMETERS} } : return ();
}

# /*!
#     @abstract
#         Returns a UID suitable for a composite page (when
#         <code>classAsComposite</code> is 0).
#     @param self
#         This object.
#     @discussion
#         Returns UIDs that begin with //apple_ref/doc/compositePage/
#         (//apple_ref/doc/compositePage/c/func/myfuncname, for example).
#  */
sub compositePageUID {
    my $self = shift;

    my $uid = "";

    if ($self->can("compositePageAPIUID")) {
	$uid = $self->compositePageAPIUID();
    } else {
	my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();
	$uid = $self->apiuid();
	$uid =~ s/\/\/\Q$apiUIDPrefix\E\//\/\/$apiUIDPrefix\/doc\/compositePage\//s;
    }

    # registerUID($uid);
    return $uid;
}

# /*!
#     @abstract
#         Adds a tagged parameter to the array of tagged parameters
#         associated with a function, etc.
#     @param self
#         The (generally <code>Function</code>) object.
#     @param taggedParms
#         An array of tagged parameters to add.
#     @discussion
#         The tagged parameters list is an array of
#         {@link //apple_ref/perl/cl/HeaderDoc::MinorAPIElement MinorAPIElement}
#         objects that represent the parameters as tagged in the
#         HeaderDoc comment block.
#  */
sub addTaggedParameter {
    my $self = shift;
    if (@_) { 
        push (@{$self->{TAGGEDPARAMETERS}}, @_);
	my @arr = @{$self->{TAGGEDPARAMETERS}};
	# print "OBJ IS ".\$arr[scalar(@arr) - 1]."\n";
	# cluck("ADDED: ".\$arr[scalar(@arr) - 1]."\n");
	return \$arr[scalar(@arr) - 1];
    }
    return undef; # return @{ $self->{TAGGEDPARAMETERS} };
}

# sub parsedParameters
# {
    # # Override this in subclasses where relevant.
    # return ();
# }

# /*!
#     @abstract
#         Compares tagged parameters to parsed parameters (for validation)
#     @param self
#         This object.
#  */
sub taggedParsedCompare {
    my $self = shift;
    my @tagged = $self->taggedParameters();
    my @parsed = $self->parsedParameters();
    my $funcname = $self->name();
    my $fullpath = $self->fullpath();
    my $linenum = $self->linenum();
    my $tpcDebug = 0;
    my $struct = 0;
    my $strict = $HeaderDoc::force_parameter_tagging;
    my %taggednames = ();
    my %parsednames = ();

    if ($self->{TPCDONE}) { return; }
    if (!$HeaderDoc::ignore_apiuid_errors) {
	$self->{TPCDONE} = 1;
    }

    my @fields = ();
    if ($self->can("fields")) {
	$struct = 1;
	@fields = $self->fields();
    }

    my @constants = $self->constants();

    my $apiOwner = $self->isAPIOwner();

    if (!$self->suppressChildren()) {
      foreach my $myfield (@fields) { 
	# $taggednames{$myfield} = $myfield;
	my $nscomp = $myfield->name();
	$nscomp =~ s/\s*//sgo;
	$nscomp =~ s/^\**//sso;
	if (!length($nscomp)) {
		$nscomp = $myfield->type();
		$nscomp =~ s/\s*//sgo;
	}
	$taggednames{$nscomp}=$myfield;
	print STDERR "Mapped Field $nscomp -> $myfield\n" if ($tpcDebug);
      }
      if (!$apiOwner) {
	foreach my $myconstant (@constants) {
		my $nscomp = $myconstant->name();
		print STDERR "CONST: $nscomp\n" if ($tpcDebug);
		$nscomp =~ s/\s*//sgo;
		$nscomp =~ s/^\**//sso;
		if (!length($nscomp)) {
			$nscomp = $myconstant->type();
			$nscomp =~ s/\s*//sgo;
		}
		$taggednames{$nscomp}=$myconstant;
		print STDERR "COUNT: ".(keys %taggednames)."\n" if ($tpcDebug);
		print STDERR "Mapped Constant $nscomp -> $myconstant\n" if ($tpcDebug);
	}
      }
    }
    foreach my $mytaggedparm (@tagged) { 
		my $nscomp = $mytaggedparm->name();
		$nscomp =~ s/\s*//sgo;
		$nscomp =~ s/^\**//sso;
		if (!length($nscomp)) {
			$nscomp = $mytaggedparm->type();
			$nscomp =~ s/\s*//sgo;
		}
		$taggednames{$nscomp}=$mytaggedparm;
		print STDERR "Mapped Tagged Parm $nscomp -> $mytaggedparm\n" if ($tpcDebug);
    }

    if ($HeaderDoc::ignore_apiuid_errors) {
	# This avoids warnings generated by the need to
	# run documentationBlock once prior to the actual parse
	# to generate API references.
	if ($tpcDebug) { print STDERR "ignore_apiuid_errors set.  Skipping tagged/parsed comparison.\n"; }
	# return;
    }

    # if ($self->lang() ne "C") {
    if ($self->lang() eq "perl" || $self->lang() eq "shell") {
	if ($tpcDebug) { print STDERR "Can't parse Perl or shell script parameter names.\nSkipping tagged/parsed comparison.\n"; }
	return;
    }

    if ($tpcDebug) {
	print STDERR "Tagged Parms:\n" if ($tpcDebug);
	foreach my $obj (@tagged) {
		bless($obj, "HeaderDoc::HeaderElement");
		bless($obj, $obj->class());
		print STDERR "TYPE: \"" .$obj->type . "\"\nNAME: \"" . $obj->name() ."\"\n";
	}
    }

	print STDERR "Parsed Parms:\n" if ($tpcDebug);
	foreach my $obj (@parsed) {
		bless($obj, "HeaderDoc::HeaderElement");
		bless($obj, $obj->class());
		my $type = "";
		if ($obj->can("type")) { $type = $obj->type(); }
		print STDERR "TYPE:" .$type . "\nNAME:\"" . $obj->name()."\"\n" if ($tpcDebug);
		my $nscomp = $obj->name();
		$nscomp =~ s/\s*//sgo;
		$nscomp =~ s/^\**//sso;
		if (!length($nscomp)) {
			$nscomp = $type;
			$nscomp =~ s/\s*//sgo;
		}
		$parsednames{$nscomp}=$obj;
	}

    print STDERR "Checking Parameters and Stuff.\n" if ($tpcDebug);
    foreach my $taggedname (keys %taggednames) {
	    my $searchname = $taggedname;
	    my $tp = $taggednames{$taggedname};
	    if ($tp->type eq "funcPtr") {
		$searchname = $tp->name();
		$searchname =~ s/\s*//sgo;
	    }
	    my $searchnameb = $searchname;
	    $searchnameb =~ s/.*\.//s; # to allow tagging of subfields with the same name in a meaningful way.

	    print STDERR "TN: $taggedname\n" if ($tpcDebug);
	    print STDERR "SN: $searchname\n" if ($tpcDebug);
	    if (!$parsednames{$searchname} && !$parsednames{$searchnameb}) {
		my $apio = $tp->apiOwner();
		print STDERR "APIO: $apio SN: \"$searchname\"\n" if ($tpcDebug);
		my $tpname = $tp->type . " " . $tp->name();
		$tpname =~ s/^\s*//s;
		my $oldfud = $self->{PPFIXUPDONE};
		if (!$self->fixupParsedParameters($tp->name)) {
		    if (!$oldfud) {
			# Fixup may have changed things.
			my @newparsed = $self->parsedParameters();
			%parsednames = ();
			foreach my $obj (@newparsed) {
				bless($obj, "HeaderDoc::HeaderElement");
				bless($obj, $obj->class());
				print STDERR "TYPE:" .$obj->type . "\nNAME:" . $obj->name()."\n" if ($tpcDebug);
				my $nscomp = $obj->name();
				$nscomp =~ s/\s*//sgo;
				$nscomp =~ s/^\**//sso;
				if (!length($nscomp)) {
					$nscomp = $obj->type();
					$nscomp =~ s/\s*//sgo;
				}
				$parsednames{$nscomp}=$obj;
			}
		    }

    		    if (!$HeaderDoc::ignore_apiuid_errors) {
			warn("$fullpath:$linenum: warning: Parameter $tpname does not appear in $funcname declaration ($self).\n");
			print STDERR "---------------\n";
			print STDERR "Candidates are:\n";
			foreach my $ppiter (@parsed) {
				my $ppname = $ppiter->name();
				if (!length($ppname)) {
					$ppname = $ppiter->type();
				}
				print STDERR "   \"".$ppname."\"\n";
			}
			print STDERR "---------------\n";
		    }
		}
	    }
    }
    if ($strict) { #  && !$struct
	print STDERR "STRICT CHECK\n" if ($tpcDebug);
	foreach my $parsedname (keys %parsednames) {
		print STDERR "PN: $parsedname\n" if ($tpcDebug);
		if (!$taggednames{$parsedname}) {
			my $pp = $parsednames{$parsedname};
			my $ppname = $pp->type . " " . $pp->name();
    			if (!$HeaderDoc::ignore_apiuid_errors) {
			    warn("$fullpath:$linenum: warning: Parameter $ppname in $funcname declaration is not tagged.\n");
			} elsif ($tpcDebug) {
			    warn("Warning skipped\n");
			}
		}
	}
    }

}

# /*!
#     @abstract
#         Searches for a parameter in the parsed parameters list.
#         Also takes additional parsed parameters from enclosed
#         structures and adds them to the outer typedef object.
#     @param self
#         This object.
#     @param name
#         A name to search for in the original parsed parameters list.
#     @result
#         Returns 1 if the specified name was found in the original
#         parsed parameters list, else 0.
#  */
sub fixupParsedParameters
{
    my $self = shift;
    my $name = shift;

    # Only do this once per typedef.
    if ($self->{PPFIXUPDONE}) { return 0; }
    $self->{PPFIXUPDONE} = 1;

    my $retval = 0;
    my $simpleTDcontents = $self->typedefContents();

	if (length($simpleTDcontents)) {
		my $addDebug = 0;

		$simpleTDcontents =~ s/\s+/ /sgo;
		$simpleTDcontents =~ s/^\s*//so;
		$simpleTDcontents =~ s/\s*$//so;

		my $origref = $HeaderDoc::namerefs{$simpleTDcontents};
		if ($origref && ($origref != $self)) {
			print STDERR "Associating additional fields.\n" if ($addDebug);
			# print STDERR "ORIG: $origref\n";
			bless($origref, "HeaderDoc::HeaderElement");
			# print STDERR "ORIG: $origref\n";
			bless($origref, $origref->class());
			foreach my $origpp ($origref->parsedParameters()) {
				print STDERR "adding \"".$origpp->type()."\" \"".$origpp->name()."\" to $name\n" if ($addDebug);
				my $newpp = $origpp->clone();
				$newpp->hidden(1);
				$self->addParsedParameter($newpp);
				if ($newpp->name() eq $name) {
					$retval = 1;
				}
			}
		}
	}

    return $retval;
}

# /*!
#     @abstract
#         Gets/sets the parsed parameters list for a function, etc.
#     @param self
#         This object
#     @param pplist
#         The new parsed parameters list to set. (Optional.)
#     @discussion
#         The parsed parameters list is an array of
#         {@link //apple_ref/perl/cl/HeaderDoc::MinorAPIElement MinorAPIElement}
#         objects that represent the parameters as parsed from the
#         actual declaration.  Not all languages support parameter
#         name parsing.  (For example, Perl does not.)
#  */
sub parsedParameters {
    my $self = shift;
    if (@_) { 
        @{ $self->{PARSEDPARAMETERS} } = @_;
    }
    ($self->{PARSEDPARAMETERS}) ? return @{ $self->{PARSEDPARAMETERS} } : return ();
}

# /*!
#     @abstract
#         Adds a parsed parameter to the array of parsed parameters
#         associated with a function, etc.
#     @param self
#         The (generally <code>Function</code>) object.
#     @param parsedParam
#         An array of parsed parameters to add.
#     @discussion
#         The parsed parameters list is an array of
#         {@link //apple_ref/perl/cl/HeaderDoc::MinorAPIElement MinorAPIElement}
#         objects that represent the parameters as parsed from the
#         actual declaration.  Not all languages support parameter
#         name parsing.  (For example, Perl does not.)
#  */
sub addParsedParameter {
    my $self = shift;
    if (@_) { 
        push (@{$self->{PARSEDPARAMETERS}}, @_);
    }
    return @{ $self->{PARSEDPARAMETERS} };
}

# Drop the last parsed parameter.  Used for rollback support.
# /*!
#     @abstract
#         Deletes the last parsed parameter added to
#         this object.
#     @discussion
#         This is used when rolling things back while
#         handling a badly formed block declaration
#         (one that mixes functions and <code>#defines</code>, for
#         example).
#  */
sub dropParsedParameter {
    my $self = shift;
    my $last = pop(@{$self->{PARSEDPARAMETERS}});
    # print STDERR "DROPPED $last\n";
    # $last->dbprint();
    return $last;
}


# for subclass/superclass merging
# /*!
#     @abstract
#         Compares the parsed parameters of two methods.
#     @param self
#         This method object.
#     @param compareObj
#         The method to compare against.
#     @discussion
#         When merging methods in from the superclass, methods
#         that are overridden (methods with the same signature)
#         should not be included.  This code is intended to
#         perform that check.
#  */
sub parsedParamCompare {
    my $self = shift;
    my $compareObj = shift;
    my @comparelist = $compareObj->parsedParameters();
    my $name = $self->name();
    my $localDebug = 0;

    my @params = $self->parsedParameters();

    if (scalar(@params) != scalar(@comparelist)) { 
	print STDERR "parsedParamCompare: function $name arg count differs (".
		scalar(@params)." != ".  scalar(@comparelist) . ")\n" if ($localDebug);
	return 0;
    } # different number of args

    my $pos = 0;
    my $nparams = scalar(@params);
    while ($pos < $nparams) {
	my $compareparam = $comparelist[$pos];
	my $param = $params[$pos];
	if ($compareparam->type() ne $param->type()) {
	    print STDERR "parsedParamCompare: function $name no match for argument " .
		$param->name() . ".\n" if ($localDebug);
	    return 0;
	}
	$pos++;
    }

    print STDERR "parsedParamCompare: function $name matched.\n" if ($localDebug);
    return 1;
}

# /*!
#     @abstract
#         Gets/sets the return type for this object.
#     @param self
#         This object.
#     @param returntype
#         The new value. (Optional.)
#  */
sub returntype {
    my $self = shift;
    my $localDebug = 0;

    if (@_) { 
        $self->{RETURNTYPE} = shift;
	print STDERR "$self: SET RETURN TYPE TO ".$self->{RETURNTYPE}."\n" if ($localDebug);
    }

    print STDERR "$self: RETURNING RETURN TYPE ".$self->{RETURNTYPE}."\n" if ($localDebug);
    return $self->{RETURNTYPE};
}

# /*!
#     @abstract
#         Checks fr a tagged parameter matching a given name.
#     @param self
#         This object.
#     @param name
#         The parameter name to search for.
#     @result
#         Returns the parameter if it exists, else 0.
#  */
sub taggedParamMatching
{
    my $self = shift;
    my $name = shift;
    my $localDebug = 0;

    return $self->paramMatching($name, \@{$self->{TAGGEDPARAMETERS}});
}

# /*!
#     @abstract
#         Checks fr a parsed parameter matching a given name.
#     @param self
#         This object.
#     @param name
#         The parameter name to search for.
#     @result
#         Returns the parameter if it exists, else 0.
#  */
sub parsedParamMatching
{
    my $self = shift;
    my $name = shift;
    my $localDebug = 0;

    return $self->paramMatching($name, \@{$self->{PARSEDPARAMETERS}});
}

# /*!
#     @abstract
#         The guts of {@link taggedParamMatching} and {@link parsedParamMatching}.
#     @param self
#         This object.
#     @param name
#         The parameter name to search for.
#     @param arrayref
#         A reference to the array of parameters to search.
#     @result
#         Returns the parameter if it exists, else 0.
#  */
sub paramMatching
{
    my $self = shift;
    my $name = shift;
    my $arrayref = shift;
    my @array = @{$arrayref};
    my $localDebug = 0;

print STDERR "SA: ".scalar(@array)."\n" if ($localDebug);

# $HeaderDoc::count++;

    foreach my $param (@array) {
	my $reducedname = $name;
	my $reducedpname = $param->name;
	$reducedname =~ s/\W//sgo;
	$reducedpname =~ s/\W//sgo;
	print STDERR "comparing \"$reducedname\" to \"$reducedpname\"\n" if ($localDebug);
	if ($reducedname eq $reducedpname) {
		print STDERR "PARAM WAS $param\n" if ($localDebug);
		return $param;
	}
    }

    print STDERR "NO SUCH PARAM\n" if ($localDebug);
    return 0;
}

# /*!
#     @abstract
#         Returns the documentation output for this object (in XML).
#     @param self
#         This object.
#  */
sub XMLdocumentationBlock {
    my $self = shift;
    my $class = ref($self) || $self;
    my $compositePageString = "";
    my $fullpath = $self->fullpath();
    my $linenum = $self->linenum();

    my $name = $self->textToXML($self->name(), 1, "$fullpath:$linenum:Name");
    my $availability = $self->htmlToXML($self->availability(), 1, "$fullpath:$linenum:Availability");
    my $updated = $self->htmlToXML($self->updated(), 1, "$fullpath:$linenum:Updated");
    my $abstract = $self->htmlToXML($self->abstract(), 1, "$fullpath:$linenum:Abstract");
    my $discussion = $self->htmlToXML($self->discussion(), 0, "$fullpath:$linenum:Discussion");
    my $group = $self->htmlToXML($self->group(), 0, "$fullpath:$linenum:Group");
    my $apio = $self->apiOwner();
    my $apioclass = ref($apio) || $apio;
    my $contentString;

    my $localDebug = 0;
    
    my $type = "";
    my $isAPIOwner = $self->isAPIOwner();
    my $lang = $self->lang();
    my $sublang = $self->sublang();
    my $langstring = "";
    my $fieldType = "";
    my $fieldHeading = "";

    my $uid = "";
    my $fielduidtag = "";
    my $extra = "";

    my $accessControl = "";
    if ($self->can("accessControl")) {
        $accessControl = $self->accessControl();
    }
    if ($accessControl =~ /\S/) {
	$accessControl = " accessControl=\"$accessControl\"";
    } else {
	$accessControl = "";
    }

    my $optionalOrRequired = "";
    if ($self->parserState && ($apioclass =~ /HeaderDoc::ObjCProtocol/)) {
	$optionalOrRequired = $self->parserState->{optionalOrRequired};
	if (length $optionalOrRequired) {
		$optionalOrRequired = " optionalOrRequired=\"$optionalOrRequired\"";
	}
    }

    my @embeddedClasses = ();
    my $class_self = undef;
    if ($self->lang eq "applescript" && $class eq "HeaderDoc::Function") {
	if (!$self->{ASCONTENTSPROCESSED}) {
		$class_self = $self->processAppleScriptFunctionContents();
		# $class_self->dbprint();
		my @classes = $class_self->classes();
		foreach my $obj (@classes) {
			push(@embeddedClasses, $obj);
		}
	}
    }

    $langstring = $self->apiRefLanguage($sublang);

    # if ($sublang eq "cpp") {
	# $langstring = "cpp";
    # } elsif ($sublang eq "C") {
	# $langstring = "c";
    # } elsif ($lang eq "C") {
	# $langstring = "occ";
    # } else {
	# # java, javascript, et al
	# $langstring = "$sublang";
    # }

    my $defineinfo = "";

    my @includedDefines = ();
    if ($self->{INCLUDED_DEFINES}) {
	@includedDefines = @{$self->{INCLUDED_DEFINES}};
    }
    my @includedDefineUIDs = ();

    SWITCH: {
	($class eq "HeaderDoc::Constant") && do {
		$fieldType = "field"; # this should never be needed
		$fieldHeading = "fieldlist"; # this should never be needed
		$type = "constant";
		if ($apioclass eq "HeaderDoc::Header") {
			# global variable
			$uid = $self->apiuid("data");
		} else {
			# class constant
			$uid = $self->apiuid("clconst");
		}
		$isAPIOwner = 0;
		last SWITCH;
	    };
	($class eq "HeaderDoc::CPPClass") && do {
		$fieldType = "field";
		$fieldHeading = "template_fields";

		# set the type for uid purposes
		$type = "cl";
		if ($self->fields()) {
			$type = "tmplt";
		}
		$uid = $self->apiuid("$type");

		# set the type for xml tag purposes
		$type = "class";

		if ($self->isCOMInterface()) {
			$type = "com_interface";
		}
		$isAPIOwner = 1;
		last SWITCH;
	    };
	($class eq "HeaderDoc::Header") && do {
		$fieldType = "field";
		$fieldHeading = "fields";
		my $filename = $self->filename();
		my $fullpath = $self->fullpath();

		# set the type for uid purposes
		$type = "header";
		$uid = $self->apiuid("$type");

		# set the type for xml tag purposes
		$type = "header";
		$extra = " filename=\"$filename\" headerpath=\"$fullpath\"";

		if ($self->isFramework()) { $type = "framework"; }

		$isAPIOwner = 1;
		last SWITCH;
	    };
	($class eq "HeaderDoc::Enum") && do {
		$fieldType = "constant";
		$fieldHeading = "constantlist";
		$type = "enum";
		$uid = $self->apiuid("tag");
		$fielduidtag = "econst";
		$isAPIOwner = 0;
		last SWITCH;
	    };

	($class eq "HeaderDoc::Function") && do {
		$fieldType = "parameter";
		$fieldHeading = "parameterlist";

		if ($apioclass eq "HeaderDoc::Header") {
			$type = "func";
		} else {
			# if ($langstring eq "c") {
				# $type = "intfm";
			# } else {
				# $type = "clm";
			# }
			# $type = $apio->getMethodType($self->declaration)
			$type = $self->getMethodType();
		}
		# if ($self->isTemplate()) {
			# $type = "ftmplt";
		# }
		if ($apioclass eq "HeaderDoc::CPPClass") {
			my $paramSignature = $self->getParamSignature();

			if (length($paramSignature)) {
				$paramSignature = "/$paramSignature"; # @@@ SIGNATURE appended here
			}

			if ($self->sublang() eq "C") { $paramSignature = ""; }

			if ($self->isTemplate()) {
				my $apiref = $self->apiref(0, "ftmplt", "$paramSignature");
			} else {
				my $declarationRaw = $self->declaration();
				# my $methodType = $apio->getMethodType($declarationRaw);
				my $methodType = $self->getMethodType();
				my $apiref = $self->apiref(0, $methodType, "$paramSignature");
			}
			$uid = $self->apiuid();
		} else {
			$uid = $self->apiuid($type);
		}
		$type = "function";
		$isAPIOwner = 0;
		last SWITCH;
	    };
	($class eq "HeaderDoc::Method") && do {
		$fieldType = "parameter";
		$fieldHeading = "parameterlist";
		$type = "method";
		my $declarationRaw = $self->declaration();
		# my $methodType = $self->getMethodType($declarationRaw);
		my $methodType = $self->getMethodType();
		$uid = $self->apiuid($methodType);
		$extra = " type=\"$methodType\"";
		$isAPIOwner = 0;
		last SWITCH;
	    };
	($class eq "HeaderDoc::ObjCCategory") && do {
		$fieldType = "field";
		$fieldHeading = "template_fields";
		$type = "category";
		$uid = $self->apiuid("cat");
		$isAPIOwner = 1;
		last SWITCH;
	    };
	($class eq "HeaderDoc::ObjCClass") && do {
		$fieldType = "field";
		$fieldHeading = "template_fields";
		$type = "class";
		$uid = $self->apiuid("cl");
		$isAPIOwner = 1;
		last SWITCH;
	    };
	($class eq "HeaderDoc::ObjCContainer") && do {
		$fieldType = "field";
		$fieldHeading = "template_fields";
		$type = "class";
		$uid = $self->apiuid("cl");
		$isAPIOwner = 1;
		last SWITCH;
	    };
	($class eq "HeaderDoc::ObjCProtocol") && do {
		$fieldType = "field";
		$fieldHeading = "template_fields";
		$type = "protocol";
		$uid = $self->apiuid("intf");
		$isAPIOwner = 1;
		last SWITCH;
	    };
	($class eq "HeaderDoc::PDefine") && do {
		$fieldType = "parameter";
		$fieldHeading = "parameterlist";
		$type = "pdefine";
		$uid = $self->apiuid("macro");

		my $definetype = "";

		if ($self->isBlock()) {
			$definetype = "block";

			if (scalar(@includedDefines)) {
				foreach my $refobj (@includedDefines) {
					# $refobj->dbprint();
					my $defineref = $refobj->{MAINOBJECT};

					# Workaround for mixed blocks used in a
					# few I/O Kit bits where something is
					# defined as a #define in some cases
					# or as a function in others.  This is
					# totally a case of "punting".
					if (!$defineref) {
				        	@includedDefines = ();
						@includedDefineUIDs = @{$self->autoRelate()};
					}
				}
			} else {
				@includedDefines = ();
				@includedDefineUIDs = @{$self->autoRelate()};
			}
		} elsif ($self->isFunctionLikeMacro()) {
			$definetype = "function";
		} else {
			$definetype = "value";
		}
		$defineinfo = "definetype=\"$definetype\" ";

		if ($self->parseOnly()) {
			$defineinfo .= "parseOnly=\"true\" ";
		}
		$isAPIOwner = 0;
		last SWITCH;
	    };
	($class eq "HeaderDoc::Struct") && do {
		$fieldType = "field";
		$fieldHeading = "fieldlist";
		if ($self->isUnion()) {
			$type = "union";
		} else {
			$type = "struct";
		}
		$uid = $self->apiuid("tag");
		$isAPIOwner = 0;
		last SWITCH;
	    };
	($class eq "HeaderDoc::Typedef") && do {
		if ($self->isEnumList()) {
			$fieldType = "constant";
			$fieldHeading = "constantlist";
		} elsif ($self->isFunctionPointer()) {
			$fieldType = "parameter";
			$fieldHeading = "parameterlist";
		} else {
			$fieldType = "field";
			$fieldHeading = "fieldlist";
		}
		$type = "typedef";
		$uid = $self->apiuid("tdef");
		if ($self->isFunctionPointer()) {
			$extra = " type=\"funcPtr\"";
		} else {
			$extra = " type=\"simple\"";
		}
		$isAPIOwner = 0;
		last SWITCH;
	    };
	($class eq "HeaderDoc::Var" || $class eq "HeaderDoc::MinorAPIElement") && do {
		# The @var pseudo-variables in Perl are MinorAPIElement objects.
		# Treat them like any other variable to the extent that it is
		# possible to do so.

		$fieldType = "field";
		$fieldHeading = "fieldlist";

		if ($self->can('isFunctionPointer')) {
			if ($self->isFunctionPointer()) {
				$fieldType = "parameter";
				$fieldHeading = "parameterlist";
			}
		}
		$type = "variable";
		my $isProperty = $self->can('isProperty') ? $self->isProperty() : 0;
		my $typename = "data";
		if ($isProperty) {
				$type = "property";
				$typename = "instp";
		}
		$uid = $self->apiuid($typename);
		$isAPIOwner = 0;
		last SWITCH;
	    };
	{
		warn "UNKNOWN CLASS $self in XMLdocumentationBlock\n";
		warn "OBJECT: TYPE: $self NAME: ".$self->name()."\n";
		warn "APIO: TYPE: $apio NAME: ".$apio->name()."\n";
	};
    }

    my $indexgroup = $self->indexgroup();

    my $throws = $self->XMLthrows();
    $compositePageString .= "<$type id=\"$uid\" $defineinfo"."lang=\"$langstring\"$extra$accessControl$optionalOrRequired>"; # e.g. "<class type=\"C++\">";

    if (length($name)) {
	$compositePageString .= "<name>$name</name>\n";
    }

    if ($indexgroup =~ /\S/) { $compositePageString .= "<indexgroup>".textToXML($indexgroup)."</indexgroup>"; }

    if (length($abstract)) {
	$compositePageString .= "<abstract>$abstract</abstract>\n";
    }
    if (length($availability)) {
	$compositePageString .= "<availability>$availability</availability>\n";
    }
    if (length($updated)) {
	$compositePageString .= "<updated>$updated</updated>\n";
    }
    if (length($group)) {
	$compositePageString .= "<group>$group</group>\n";
    }
    my $value = "";
    if ($self->can('value')) {
	$value = $self->value();

	if (length($value) && ($value ne "UNKNOWN")) {
		# Always XML in this function, so do this every time.
		$value = $self->textToXML($value);

        	$compositePageString .= "<value>$value</value>\n";
	}
    }
    if (length($throws)) {
	$compositePageString .= "$throws\n";
    }

    my @params = ();
    my @origfields = ();
    if ($self->can("fields")) { @origfields = $self->fields(); }
    if ($self->can("taggedParameters")){
        print STDERR "setting params\n" if ($localDebug);
        @params = $self->taggedParameters();
        if ($self->can("parsedParameters")) {
            $self->taggedParsedCompare();
        }
    } elsif ($self->can("fields")) {
        if ($self->can("parsedParameters")) {
            $self->taggedParsedCompare();
        }
    } else {
        print STDERR "type $class has no taggedParameters function\n" if ($localDebug);
    }

    my @parsedparams = ();
    if ($self->can("parsedParameters")) {
	@parsedparams = $self->parsedParameters();
    }

    my @parameters_or_fields = ();
    my @callbacks = ();
    foreach my $element (@params) {
	if ($element->isCallback()) {
		push(@callbacks, $element);
	} elsif (!$element->{ISDEFINE}) {
		push(@parameters_or_fields, $element);
	}
    }
    foreach my $element (@origfields) {
        bless($element, "HeaderDoc::HeaderElement");
	bless($element, $element->class()); # MinorAPIElement");
        if ($element->can("hidden")) {
            if (!$element->hidden()) {
		if ($element->isCallback()) {
			push(@callbacks, $element);
		} elsif (!$element->{ISDEFINE}) {
			push(@parameters_or_fields, $element);
		}
	    }
	}
    }
    my @orig_local_variables = $self->variables();
    my @origconstants = $self->constants();
    my @local_variables = ();
    my @constants = ();
    # my @fields = ();
    # foreach my $copyfield (@origfields) {
        # bless($copyfield, "HeaderDoc::HeaderElement");
	# bless($copyfield, $copyfield->class()); # MinorAPIElement");
        # # print STDERR "FIELD: ".$copyfield->name."\n";
        # if ($copyfield->can("hidden")) {
            # if (!$copyfield->hidden()) {
                # push(@fields, $copyfield);
            # }
        # }
    # }
    foreach my $copylocal (@orig_local_variables) {
        bless($copylocal, "HeaderDoc::HeaderElement");
	bless($copylocal, $copylocal->class()); # MinorAPIElement");
        # print STDERR "CONST: ".$copylocal->name."\n";
        if ($copylocal->can("hidden")) {
            if (!$copylocal->hidden()) {
                push(@local_variables, $copylocal);
            }
        }
        # print STDERR "HIDDEN: ".$copylocal->hidden()."\n";
    }
    foreach my $copyconstant (@origconstants) {
        bless($copyconstant, "HeaderDoc::HeaderElement");
	bless($copyconstant, $copyconstant->class()); # MinorAPIElement");
        # print STDERR "CONST: ".$copyconstant->name."\n";
        if ($copyconstant->can("hidden")) {
            if (!$copyconstant->hidden()) {
                push(@constants, $copyconstant);
            }
        }
        # print STDERR "HIDDEN: ".$copyconstant->hidden()."\n";
    }

	# if (@parameters_or_fields) {
		# $contentString .= "<$fieldHeading>\n";
		# for my $field (@parameters_or_fields) {
			# my $name = $field->name();
			# my $desc = $field->discussion();
			# # print STDERR "field $name $desc\n";
			# $contentString .= "<$fieldType><name>$name</name><desc>$desc</desc></$fieldType>\n";
		# }
		# $contentString .= "</$fieldHeading>\n";
	# }

	# Insert declaration, fields, constants, etc.
	my $parseTree_ref = $self->parseTree();
	my $parseTree = undef;

	# Don't do anything for @var pseudo-variables in Perl, etc.
	if ($class ne "HeaderDoc::MinorAPIElement") {
		if (!$parseTree_ref) {
			if (!$parseTree_ref && !$self->isAPIOwner()) {
				warn "Missing parse tree for ".$self->name()."\n";
			}
		} else {
			$parseTree = ${$parseTree_ref};
		}
	}
	my $declaration = "";

	if ($parseTree) {
		# $declaration = $parseTree->xmlTree($self->preserve_spaces(), $self->hideContents());
		$declaration = $self->declarationInHTML();
	}

	if (@constants) {
		$compositePageString .= "<constantlist>\n";
                foreach my $field (@constants) {
                        my $name = $self->textToXML($field->name());
                        my $desc = $self->htmlToXML($field->discussion());
			my $fType = "";
			if ($field->can("type")) { $fType = $field->type(); }

			my $fielduidstring = "";
			if (length($fielduidtag)) {
				my $fielduid = $field->apiuid($fielduidtag);
				$fielduidstring = " id=\"$fielduid\"";
				if (!$apio->appleRefUsed($uid) && !$HeaderDoc::ignore_apiuid_errors) {
					# print STDERR "MARKING APIREF $uid used\n";
					$apio->appleRefUsed($uid, 1);
				} else {
					# already used or a "junk" run to obtain
					# uids for another purpose.  Drop the
					# uid in case it is already used
					$fielduidstring = "";
				}
			}

			if ($fType eq "callback") {
				my @userDictArray = $field->userDictArray(); # contains elements that are hashes of param name to param doc
				my $paramString;
				foreach my $hashRef (@userDictArray) {
					while (my ($param, $disc) = each %{$hashRef}) {
						$param = $self->textToXML($param);
						$disc = $self->htmlToXML($disc);
						$paramString .= "<parameter><name>$param</name><desc>$disc</desc></parameter>\n";
					}
					$compositePageString .= "<constant$fielduidstring><name>$name</name><desc>$desc</desc><callback_parameters>$paramString</callback_parameters></constant>\n";
				}
			} else {
				$compositePageString .= "<constant$fielduidstring><name>$name</name><desc>$desc</desc></constant>\n";
			}
		}
                $compositePageString .= "</constantlist>\n";
	}
	if (@embeddedClasses) {
		$contentString = $class_self->_getEmbeddedClassXMLDetailString(\@embeddedClasses);
		if (length($contentString)) {
			$compositePageString .= "<embeddedclasslist>\n";
			$compositePageString .= $contentString;
			$compositePageString .= "</embeddedclasslist>\n";
		}
	}
	if (@local_variables) {
		$compositePageString .= "<localvariablelist>\n";
                foreach my $field (@local_variables) {
                        my $name = $self->textToXML($field->name());
                        my $desc = $self->htmlToXML($field->discussion());
			my $fType = "";
			if ($field->can("type")) { $fType = $field->type(); }

			my $groupstring = "";
			my $groupraw = $field->group();
			if (length($groupraw)) {
				$groupraw =~ s/"/\"/sg;
				$groupstring = "<group>".textToXML($groupraw)."</group>";
			}

			my $fielduidstring = "";
			if (length($fielduidtag)) {
				my $fielduid = $field->apiuid($fielduidtag);
				$fielduidstring = " id=\"$fielduid\"";
				if (!$apio->appleRefUsed($uid) && !$HeaderDoc::ignore_apiuid_errors) {
					# print STDERR "MARKING APIREF $uid used\n";
					$apio->appleRefUsed($uid, 1);
				} else {
					# already used or a "junk" run to obtain
					# uids for another purpose.  Drop the
					# uid in case it is already used
					$fielduidstring = "";
				}
			}

			if ($fType eq "callback") {
				my @userDictArray = $field->userDictArray(); # contains elements that are hashes of param name to param doc
				my $paramString;
				foreach my $hashRef (@userDictArray) {
					while (my ($param, $disc) = each %{$hashRef}) {
						$param = $self->textToXML($param);
						$disc = $self->htmlToXML($disc);
						$paramString .= "<parameter><name>$param</name><desc>$disc</desc></parameter>\n";
					}
					$compositePageString .= "<localvariable$fielduidstring><name>$name</name><desc>$desc</desc><callback_parameters>$paramString</callback_parameters>$groupstring</localvariable>\n";
				}
			} else {
				$compositePageString .= "<localvariable$fielduidstring><name>$name</name><desc>$desc</desc></localvariable>\n";
			}
		}
                $compositePageString .= "</localvariablelist>\n";
	}

	if (@parameters_or_fields) {
		$compositePageString .= "<$fieldHeading>\n";
                foreach my $field (@parameters_or_fields) {
                        my $name = $self->textToXML($field->name());
                        my $desc = $self->htmlToXML($field->discussion());
			my $fType = "";
			if ($field->can("type")) { $fType = $field->type(); }

			if ($fType eq "callback") {
				my @userDictArray = $field->userDictArray(); # contains elements that are hashes of param name to param doc
				my $paramString;
				foreach my $hashRef (@userDictArray) {
					while (my ($param, $disc) = each %{$hashRef}) {
						$param = $self->textToXML($param);
						$disc = $self->htmlToXML($disc);
						$paramString .= "<parameter><name>$param</name><desc>$disc</desc></parameter>\n";
					}
					$compositePageString .= "<$fieldType><name>$name</name><desc>$desc</desc><callback_parameters>$paramString</callback_parameters></$fieldType>\n";
				}
			} else {
				$compositePageString .= "<$fieldType><name>$name</name><desc>$desc</desc></$fieldType>\n";
			}
		}
                $compositePageString .= "</$fieldHeading>\n";
	}

	if (@callbacks) {
		$compositePageString .= "<callbacks>\n";
                foreach my $field (@callbacks) {
                        my $name = $self->textToXML($field->name());
                        my $desc = $self->htmlToXML($field->discussion());
			my $fType = "";
			if ($field->can("type")) { $fType = $field->type(); }

			if ($fType eq "callback") {
				my @userDictArray = $field->userDictArray(); # contains elements that are hashes of param name to param doc
				my $paramString;
				foreach my $hashRef (@userDictArray) {
					while (my ($param, $disc) = each %{$hashRef}) {
						$param = $self->textToXML($param);
						$disc = $self->htmlToXML($disc);
						$paramString .= "<parameter><name>$param</name><desc>$disc</desc></parameter>\n";
					}
					$compositePageString .= "<$fieldType><name>$name</name><desc>$desc</desc><callback_parameters>$paramString</callback_parameters></$fieldType>\n";
				}
			} else {
				$compositePageString .= "<$fieldType><name>$name</name><desc>$desc</desc></$fieldType>\n";
			}
		}
                $compositePageString .= "</callbacks>\n";
	}

    if (scalar(@parsedparams) && (!$self->isBlock())) {
	# PDefine blocks use parsed parameters to store all of the defines
	# in a define block, so this would be bad.

        my $paramContentString;
        foreach my $element (@parsedparams) {
            my $pName = $self->textToXML($element->name());
	    # if (!$element->can("type")) {
		# cluck("ELEMENT TRACE: ".$element." (".$element->name().") in $self (".$self->name().") in ".$self->apiOwner()." (".$self->apiOwner()->name().")\n"); 
		# my $headerObj = $HeaderDoc::headerObject;
		# $headerObj->headerDump();
		# next;
	    # }
            my $pType = $self->textToXML($element->type());

            $pType =~ s/\s*$//so;
            if ($pName =~ s/^\s*(\*+)\s*//so) {
                $pType .= " $1";
            }

            $pType = $self->textToXML($pType);
            $pName = $self->textToXML($pName);

            if (length ($pName) || length($pType)) {
                $paramContentString .= "<parsedparameter><type>$pType</type><name>$pName</name></parsedparameter>\n";
            }
        }
        if (length ($paramContentString)){
            $compositePageString .= "<parsedparameterlist>\n";
            $compositePageString .= $paramContentString;
            $compositePageString .= "</parsedparameterlist>\n";
        }
    }

    my $returntype = $self->textToXML($self->returntype());
    my $result = "";
    if ($self->can('result')) { $result = html2xhtml($self->result(), $self->encoding()); }
    my $attlists = "";
    if ($self->can('getAttributeLists')) { $attlists = $self->getAttributeLists(0); }
    my $atts = "";
    if ($self->can('getAttributes')) { $atts = $self->getAttributes(); }

    if (length($atts)) {
        $compositePageString .= "<attributes>$atts</attributes>\n";
    }
    if (length($attlists)) {
        $compositePageString .= "<attributelists>$attlists</attributelists>\n";
    }

    my $idstring = "";
    if (scalar(@includedDefines)) {
	foreach my $refobj (@includedDefines) {

		# $refobj->dbprint();
		my $defineref = $refobj->{MAINOBJECT};

		if (!$defineref) { next; }

		my $define = ${$defineref};
		$idstring .= "<includeddefine>".$define->apiuid()."</includeddefine>\n";
		# $refobj->dbprint();
		# $define->dbprint();
		# die("Define: $define\n");
	}
    }
    if (scalar(@includedDefineUIDs)) {
	foreach my $idUID (@includedDefineUIDs) {
		$idstring .= "<includeddefine>".$idUID."</includeddefine>\n";
	}
    }
    if (length($idstring)) {
	$compositePageString .= "<includeddefines>\n$idstring\n</includeddefines>\n";
    }

    if ($class eq "HeaderDoc::Header") {
	my $includeref = $HeaderDoc::perHeaderIncludes{$fullpath};
	if ($includeref) {
		my @includes = @{$includeref};

		$compositePageString .= "<includes>\n";
		foreach my $include (@includes) {
			print STDERR "Included file: $include\n" if ($localDebug);

			my $xmlinc = $self->textToXML($include);
			# $compositePageString .= "<include>$xmlinc</include>\n";
			my $includeguts = $include;
			$includeguts =~ s/[<\"](.*)[>\"]/$1/so;

			my $includefile = basename($includeguts);

			my $ref = $self->genRefSub("doc", "header", $includefile, "");

			$compositePageString .= "<include><hd_link logicalPath=\"$ref\">$xmlinc</hd_link></include>\n";
		}
		$compositePageString .= "</includes>\n";
	}
    }
    if (length($returntype)) {
        $compositePageString .= "<returntype>$returntype</returntype>\n";
    }
    if (length($result)) {
        $compositePageString .= "<result>$result</result>\n";
    }


    if (length($declaration)) {
	$compositePageString .= "<declaration>$declaration</declaration>\n";
    }

    if (length($discussion)) {
	$compositePageString .= "<desc>$discussion</desc>\n";
    }

    my @autoRelated = @{$self->autoRelate()};
    if (scalar(@autoRelated)) {
	$compositePageString .= "<autorelated>\n";
	foreach my $autoRelatedItem (@autoRelated) {
		$compositePageString .= "<relateduid>$autoRelatedItem</relateduid>\n";
	}
        $compositePageString .= "</autorelated>\n";
    }

    # Quick debugging of discussion and abstract
    # print STDERR "OBJ $self\n";
    # print STDERR "    NAME: ".$self->name()."\n";
    # print STDERR "    DESC: ".$discussion."\n";
    # print STDERR "    ABS:  ".$abstract."\n";

    if ($isAPIOwner) {
	$compositePageString .= $self->groupDoc();

	$contentString = $self->_getFunctionXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<functions>$contentString</functions>\n";
	}

	$contentString= $self->_getMethodXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<methods>$contentString</methods>\n";
	}

	$contentString= $self->_getPropXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<properties>$contentString</properties>\n";
	}

	$contentString= $self->_getVarXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<globals>$contentString</globals>\n";
	}

	$contentString= $self->_getConstantXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<constants>$contentString</constants>\n";
	}

	$contentString= $self->_getTypedefXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<typedefs>$contentString</typedefs>";
	}

	$contentString= $self->_getStructXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<structs_and_unions>$contentString</structs_and_unions>";
	}

	$contentString= $self->_getEnumXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<enums>$contentString</enums>";
	}

	$contentString= $self->_getPDefineXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$compositePageString .= "<defines>$contentString</defines>";
	}  

	# @@@ Class generation code.  Important debug checkpoint.
	my $classContent = "";
	$contentString= $self->_getClassXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$classContent .= $contentString;
	}
	$contentString= $self->_getCategoryXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$classContent .= $contentString;
	}
	$contentString= $self->_getProtocolXMLDetailString();
	if (length($contentString)) {
		$contentString = $self->stripAppleRefs($contentString);
		$classContent .= $contentString;
	}
	if (length($classContent)) {
		$compositePageString .= "<classes>$classContent</classes>\n";
	}

    }

    if ($isAPIOwner) {
	my $copyrightOwner = $self->copyrightOwner;
	if ($class eq "HeaderDoc::Header") {
		my $headercopyright = $self->htmlToXML($self->headerCopyrightOwner());
		if ($headercopyright ne "") {
			$copyrightOwner = $headercopyright;
		}
    	}
        $compositePageString .= "<copyrightinfo>&#169; $copyrightOwner</copyrightinfo>\n" if (length($copyrightOwner));

	my $dateStamp = HeaderDoc::APIOwner::fix_date($self->encoding());
	$compositePageString .= "<timestamp>$dateStamp</timestamp>\n" if (length($dateStamp));
    }

    $compositePageString .= "</$type>"; # e.g. "</class>";
    return $compositePageString;
}


# /*!
#     @abstract
#         Gets/sets whether this object is a function pointer.
#     @param self
#         This object.
#     @param ifp
#         The new value. (Optional.)
#  */
sub isFunctionPointer {
    my $self = shift;

    if (@_) {
        $self->{ISFUNCPTR} = shift;
	# cluck($self->{NAME}." ($self) IFP SET TO ".$self->{ISFUNCPTR});
    }
    return $self->{ISFUNCPTR};
}

# /*!
#     @abstract
#         Adds a <code>#define</code> to the array of
#         <code>#define</code> macros associated with a
#         <code>defineblock</code> declaration.
#     @param self
#         The (generally {@link //apple_ref/perl/cl/HeaderDoc::PDefine PDefine}) object.
#     @param defines
#         An array of macros to add.
#  */
sub addToIncludedDefines {
    my $self = shift;
    my $obj = shift;

    if (!$self->{INCLUDED_DEFINES}) {
	my @x = ();
	$self->{INCLUDED_DEFINES} = \@x;
    }
    push(@{$self->{INCLUDED_DEFINES}}, $obj);

    my @arr = @{$self->{INCLUDED_DEFINES}};
    # print "OBJ IS ".\$arr[scalar(@arr) - 1]."\n";
    return \$arr[scalar(@arr) - 1];
}

# /*!
#     @abstract
#         Collects data for generating the API ref (apple_ref) for a function, data type, etc.
#     @discussion
#         See {@link apiref} for the actual generation.
#  */
sub apirefSetup
{
    my $self = shift;
    my $force = 0;

    my $localDebug = 0;

    if (@_) {
	$force = shift;
    }

# warn("APIRS ($self) $force BT\n");

    if ($self->noRegisterUID()) {
	print STDERR "SHORTCUT NOREGISTERUID: $self\n" if ($localDebug);
 	return ($self->{KEEPCONSTANTS},
		$self->{KEEPFIELDS}, $self->{KEEPPARAMS},
		$self->{FIELDHEADING}, $self->{FUNCORMETHOD}, $self->{KEEPVARIABLES});
    }

    my $subreftitle = 0;
    if ($self->appleRefIsDoc() == 1) {
	$subreftitle = 1;
    }
    # print STDERR "OBJ: $self NAME: ".$self->name()." SRT: $subreftitle\n";

    my $class = ref($self) || $self;
    my $apio = $self->apiOwner();
    my $apioclass = ref($apio) || $apio;

    my $declarationRaw = $self->declaration();

    my @orig_local_variables = $self->variables();
    my @origconstants = $self->constants();
    my @origfields = ();
    my @params = ();
    my $apiref = "";
    my $typename = "";
    my $fieldHeading = "";
    my $className = "";
    my $apiRefType = "";
    my $func_or_method = "";

    print "APIREFSETUP: IN $self LOCAL VARS: ".$#orig_local_variables."\n" if($localDebug);

    if ($self->can("taggedParameters")){ 
	print STDERR "setting params\n" if ($localDebug);
	@params = $self->taggedParameters();
	if ($self->can("parsedParameters")) {
	    $self->taggedParsedCompare();
	}
    } elsif ($self->can("fields")) {
	if ($self->can("parsedParameters")) {
	    $self->taggedParsedCompare();
	}
    } else {
	print STDERR "type $class has no taggedParameters function\n" if ($localDebug);
    }

    if (!$force && $self->{APIREFSETUPDONE}) {
	print STDERR "SHORTCUT: $self\n" if ($localDebug);
	return ($self->{KEEPCONSTANTS}, $self->{KEEPFIELDS}, $self->{KEEPPARAMS},
		$self->{FIELDHEADING}, $self->{FUNCORMETHOD}, $self->{KEEPVARIABLES});
    }
    if ($self->{APIREFSETUPDONE}) {
	if (dereferenceUIDObject($self->{APIUID}, $self)) {
		unregister_force_uid_clear($self->{APIUID});
	}
    }
	# print STDERR "REDO: $self\n";

    if ($self->can("fields")) { @origfields = $self->fields(); }

    # my @constants = @origconstants;
    # my @fields = @origfields;
    my @constants = ();
    my @local_variables = ();
    my @fields = ();

    if (!$self->suppressChildren()) {
      foreach my $copyfield (@origfields) {
        bless($copyfield, "HeaderDoc::HeaderElement");
	bless($copyfield, $copyfield->class()); # MinorAPIElement");
	print STDERR "FIELD: ".$copyfield->name."\n" if ($localDebug);
	if ($copyfield->can("hidden")) {
	    if (!$copyfield->hidden()) {
		push(@fields, $copyfield);
	    } else {
		print STDERR "HIDDEN\n" if ($localDebug);
	    }
	}
      }

      foreach my $copyconstant (@origconstants) {
	# print STDERR "CONSTANT IN SETUP\n";

        bless($copyconstant, "HeaderDoc::HeaderElement");
	bless($copyconstant, $copyconstant->class()); # MinorAPIElement");
	# print STDERR "CONST: ".$copyconstant->name."\n";
	if ($copyconstant->can("hidden")) {
	    if (!$copyconstant->hidden()) {
		push(@constants, $copyconstant);
	    }
	}
	# print STDERR "HIDDEN: ".$copyconstant->hidden()."\n";
      }
	# print STDERR "SELF WAS $self\n";
    } else {
	print STDERR "CHILDREN SUPPRESSED\n" if ($localDebug);
    }

    $typename = "internal_temporary_object";
    SWITCH: {
	($class eq "HeaderDoc::Function") && do {
			print STDERR "FUNCTION\n" if ($localDebug);
			$typename = $self->getMethodType();
			# if ($apioclass eq "HeaderDoc::Header") {
				# $typename = "func";
			# } else {
				# $typename = "clm";
				# if ($apio->can("getMethodType")) {
					# $typename = $apio->getMethodType($self->declaration);
				# }
			# }
			print STDERR "Function type: $typename\n" if ($localDebug);
			# if ($self->isTemplate()) {
				# $typename = "ftmplt";
			# }
			if ($apioclass eq "HeaderDoc::CPPClass") {
				my $paramSignature = $self->getParamSignature();

				print STDERR "paramSignature: $paramSignature\n" if ($localDebug);

				if (length($paramSignature)) {
					$paramSignature = "/$paramSignature"; # @@@SIGNATURE appended here
				}

				if ($self->sublang() eq "C") { $paramSignature = ""; }

				if ($self->isTemplate()) {
					$apiref = $self->apiref(0, "ftmplt", "$paramSignature");
				} else {
					my $declarationRaw = $self->declaration();
					# my $methodType = $apio->getMethodType($declarationRaw);
					my $methodType = $self->getMethodType();
					$apiref = $self->apiref(0, $methodType, "$paramSignature");
				}
			}
			$fieldHeading = "Parameters";
			$apiRefType = "";
			$func_or_method = "function";
			last SWITCH;
		};
	($class eq "HeaderDoc::Constant") && do {
			print STDERR "CONSTANT\n" if ($localDebug);
			if ($apioclass eq "HeaderDoc::Header") {
				$typename = "data";
			} else {
				$typename = "clconst";
			}
			$fieldHeading = "Fields";
			$apiRefType = "";
			last SWITCH;
		};
	($class eq "HeaderDoc::Enum") && do {
			print STDERR "ENUM\n" if ($localDebug);
			$typename = "tag";
			$fieldHeading = "Constants";
			# if ($self->masterEnum()) {
				$apiRefType = "econst";
			# } else {
				# $apiRefType = "";
			# }
			last SWITCH;
		};
	($class eq "HeaderDoc::PDefine") && do {
			print STDERR "PDEFINE\n" if ($localDebug);
			$typename = "macro";
			$fieldHeading = "Parameters";
			$apiRefType = "";
			last SWITCH;
		};
	($class eq "HeaderDoc::Method") && do {
			print STDERR "METHOD\n" if ($localDebug);
			# $typename = $self->getMethodType($declarationRaw);
			$typename = $self->getMethodType();
			$fieldHeading = "Parameters";
			$apiRefType = "";
			if ($apio->can("className")) {  # to get the class name from Category objects
				$className = $apio->className();
			} else {
				$className = $apio->name();
			}
			$func_or_method = "method";
			last SWITCH;
		};
	($class eq "HeaderDoc::Struct") && do {
			print STDERR "TAG\n" if ($localDebug);
			$typename = "tag";
			$fieldHeading = "Fields";
			$apiRefType = "";
			last SWITCH;
		};
	($class eq "HeaderDoc::Typedef") && do {
			print STDERR "TDEF\n" if ($localDebug);
			$typename = "tdef";

        		if ($self->isFunctionPointer()) {
				$fieldHeading = "Parameters";
				last SWITCH;
			}
        		if ($self->isEnumList()) {
				$fieldHeading = "Constants";
				last SWITCH;
			}
        		$fieldHeading = "Fields";

			$apiRefType = "";
			$func_or_method = "function";
			last SWITCH;
		};
	($class eq "HeaderDoc::Var" || ($class eq "HeaderDoc::MinorAPIElement" && $self->autodeclaration())) && do {
			print STDERR "VAR\n" if ($localDebug);
			my $isProperty = $self->can('isProperty') ? $self->isProperty() : 0;
			if ($isProperty) {
				$typename = "instp";
			} else {
				$typename = "data";
			}
			$fieldHeading = "Fields";
			if ($self->can('isFunctionPointer')) {
			    if ($self->isFunctionPointer()) {
				$fieldHeading = "Parameters";
			    }
			}
			$apiRefType = "";
			last SWITCH;
		};
    }
    if (!length($apiref)) {
	# cluck( "TYPE NAME: $typename CLASS: $class\n");
	$apiref = $self->apiref(0, $typename);
    }


    if (@constants) {
	foreach my $element (@constants) {
	    $element->appleRefIsDoc($subreftitle);
	    my $uid = $element->apiuid("econst");
	}
    }

    if (@params) {
      foreach my $element (@params) {
	if (length($apiRefType)) {
	# print STDERR "APIREFTYPE: $apiRefType\n";
	    $element->appleRefIsDoc($subreftitle);
	    $apiref = $element->apiref(0, $apiRefType);
	}
      }
    }

    # print STDERR "OLV: ".$#orig_local_variables."\n";
    foreach my $copylocal (@orig_local_variables) {
	bless($copylocal, "HeaderDoc::HeaderElement");
	bless($copylocal, $copylocal->class()); # MinorAPIElement");
	print STDERR "LOCAL VARIABLE: ".$copylocal->name."\n" if ($localDebug);

	if (length($apiRefType)) {
	# print STDERR "APIREFTYPE: $apiRefType\n";
	    $copylocal->appleRefIsDoc($subreftitle);
	    $apiref = $copylocal->apiref(0, $apiRefType);
	}
	if ($copylocal->can("hidden")) {
	    if (!$copylocal->hidden()) {
		push(@local_variables, $copylocal);
	    }
	}
	# print STDERR "HIDDEN: ".$copylocal->hidden()."\n";
    }

    $self->{KEEPVARIABLES} = \@local_variables;
    $self->{KEEPCONSTANTS} = \@constants;
    $self->{KEEPFIELDS} = \@fields;
    $self->{KEEPPARAMS} = \@params;
    $self->{FIELDHEADING} = $fieldHeading;
    $self->{FUNCORMETHOD} = $func_or_method;

    $self->{APIREFSETUPDONE} = 1;
    return (\@constants, \@fields, \@params, $fieldHeading, $func_or_method, \@local_variables);
}

# /*! @abstract
#         Returns HeaderDoc tag names and English names for a given HeaderDoc object.
#     @param self
#         This object.
#     @discussion
#         Returns an array with three members: the English name, a
#         regular expression to match the tag names that make sense
#         for this object, and (if applicable) the superclass field name.
#
#         For example, an instance of the
#         {@link //apple_ref/perl/cl/HeaderDoc::Function HeaderDoc::Function} class
#         returns an english name of <code>function or method</code>, and returns
#         a regular expression that matches either the function or
#         method HeaderDoc tags.  Because it cannot have a superclass,
#         it doesn't need to return anything for the third field.
#  */
sub tagNameRegexpAndSuperclassFieldNameForType
{
    my $self = shift;
    my $class = ref($self) || $self;

    my $tagname = "";
    my $tag_re = "";
    my $superclassfieldname = "Superclass";

    SWITCH: {
	($class =~ /HeaderDoc\:\:Constant/) && do {
		$tag_re = "const(?:ant)?|var";
		$tagname = "constant";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:Enum/) && do {
		$tag_re = "enum";
		$tagname = "enum";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:Function/) && do {
		$tag_re = "method|function";
		$tagname = "function or method";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:Method/) && do {
		$tag_re = "method";
		$tagname = "method";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:PDefine/) && do {
		$tag_re = "define(?:d)?|function";
		$tagname = "CPP macro";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:Struct/) && do {
		$tag_re = "struct|union";
                if ($self->isUnion()) { $tagname = "union"; }
		else { $tagname = "struct"; }
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:Typedef/) && do {
		$tag_re = "typedef|function|class";
		$tagname = "typedef";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:Var/) && do {
		if ($self->isProperty()) {
			$tag_re = "var|method|property|const(?:ant)?";
			$tagname = "variable";
		} else {
			$tag_re = "var|property|const(?:ant)?";
			$tagname = "variable";
		}
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:ObjCClass/) && do {
		$tag_re = "class|template";
		$tagname = "Objective-C class";
		$superclassfieldname = "Extends&nbsp;Class";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:ObjCCategory/) && do {
		$tag_re = "category|template";
		$tagname = "Objectice-C category";
		$superclassfieldname = "Extends&nbsp;Class";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:ObjCProtocol/) && do {
		$tag_re = "protocol|template";
		$tagname = "Objectice-C protocol";
                $superclassfieldname = "Extends&nbsp;Protocol";
		last SWITCH;
	};
	($class =~ /HeaderDoc\:\:CPPClass/) && do {
		$tag_re = "class|interface";
		$tagname = "class or interface";
		last SWITCH;
	};
	{
		print STDERR "Unknown type: $class\n";
	}
    };

    return ($tagname, $tag_re, $superclassfieldname);
}

# /*!
#     @abstract
#         Finds a tagged parameter by name.
#     @discussion
#         To improve Doxygen tag compatibility, HeaderDoc
#         concatenates multiple <code>\@param</code> tags for the
#         same parameter name.  This is part of that
#         support.
#  */
sub taggedParamFind
{
    my $self = shift;
    my $name = shift;

    foreach my $parm ($self->taggedParameters()) {
	if ($parm->name() eq $name) {
		return $parm;
	}
    }
    return undef;
}

# /*!
#     @abstract
#         Processes a HeaderDoc comment.
#     @param self
#         The APIOwner object.
#     @param fieldArrayRef
#         A reference to an array of fields.  This should be the result of calling
#         {@link //apple_ref/perl/instm/HeaderDoc::Utilities/stringToFields//()
#         HeaderDoc::Utilities::stringToFields} on the HeaderDoc comment.
#
#         This is essentially the result of calling split on the <code>\@</code> symbol
#         in the comment, but there is some subtlety involved, so don't do that.
#  */
sub processComment
{
    my($self) = shift;
    my $fieldArrayRef = shift;
    my @fields = @$fieldArrayRef;
    my $fullpath = $self->fullpath();
    my $linenuminblock = $self->linenuminblock();
    my $blockoffset = $self->blockoffset();
    my $linenum = $self->linenum();
    my $localDebug = 0;
    my $olddisc = $self->halfbaked_discussion();
    my $isProperty = $self->can('isProperty') ? $self->isProperty() : 0;

    my $vargroup = "";

    if ($localDebug) {
	printFields($fieldArrayRef);
	cluck("BT\n");
    }

    print STDERR "SELF IS $self\n" if ($localDebug);

    # cluck("Entering processComment for $self\n");
    # printFields(\@fields);

    my $lang = $self->lang();
    my $sublang = $self->sublang();

    my $lastField = scalar(@fields);

    # warn "processComment called on raw HeaderElement\n";
    my $class = ref($self) || $self;
    if ($class =~ /HeaderDoc::HeaderElement/) {
	return;
    }

    $self->{HASPROCESSEDCOMMENT} = 1;

    my ($tagname, $tag_re, $superclassfieldname) = $self->tagNameRegexpAndSuperclassFieldNameForType();

    my $seen_top_level_field = 0;
    my $first_field = 1;

    my $callbackObj = 0;
    foreach my $field (@fields) {
    	print STDERR "Comment field is |$field|\n" if ($localDebug);
	print STDERR "Seen top level field: $seen_top_level_field\n" if ($localDebug);
	my $fieldname = "";
	my $top_level_field = 0;
	if ($field =~ /^(\w+)(\s|$)/) {
		$fieldname = $1;
		# print STDERR "FIELDNAME: $fieldname\n";
		$top_level_field = validTag($fieldname, 1);

		if ($top_level_field && $seen_top_level_field && ($fieldname !~ /const(ant)?/) &&
		    ($fieldname !~ /var/) && (!$self->isBlock() || $fieldname ne "define") && $fieldname ne "name") {
			# We've seen more than one top level field.

			$field =~ s/^(\w+)(\s)//s;
			my $spc = $2;

			my $newtag = "field";
			if ($class =~ /HeaderDoc\:\:Enum/) {
				$newtag = "constant";
			} elsif ($class =~ /HeaderDoc\:\:Function/ ||
			         $class =~ /HeaderDoc\:\:Method/) {
				$newtag = "param";
			} elsif ($class =~ /HeaderDoc\:\:ObjCClass/ ||
				 $class =~ /HeaderDoc\:\:ObjCProtocol/ ||
				 $class =~ /HeaderDoc\:\:ObjCCategory/ ||
				 $class =~ /HeaderDoc\:\:ObjCContainer/ ||
				 $class =~ /HeaderDoc\:\:CPPClass/) {
				$newtag = "discussion";
			} elsif ($class =~ /HeaderDoc\:\:Typedef/) {
				if ($fieldname eq "function") {
					$newtag = "callback";
				} elsif ($fieldname =~ /define(d)?/ || $fieldname eq "var") {
					$newtag = "constant";
				}
			}
			$field = "$newtag$spc$field";
			$top_level_field = 0;

			warn "$fullpath:$linenum: Duplicate top level tag \"$fieldname\" detected\n".
				"in comment.  Maybe you meant \"$newtag\".\n";

			# warn "Thunked field to \"$field\"\n";
		} elsif ($top_level_field && $seen_top_level_field && ($fieldname eq "constant" || $fieldname eq "const")) {
			$top_level_field = 0;
		} elsif ($top_level_field && $seen_top_level_field && ($fieldname eq "var")) {
			$top_level_field = 0;
		}

		# Fix for another common mistake: people using @field for a class
		# member variable instead of @var or @const.
		if ($class =~ /HeaderDoc\:\:Var/ && !$isProperty) {
			if (!$seen_top_level_field && $fieldname eq "field") {
				if ($sublang !~ /^occ/o) {
					warn "Field \@$fieldname found in \@var declaration.\nYou probably meant \@var instead.\n" if (!$HeaderDoc::running_test);
					$field =~ s/^(\w+)(\s)//s;
					my $spc = $2;

					$field = "var$spc$field";
					$top_level_field = 1;
				}
			}
		}
	}
	# warn("FN: \"$fieldname\"\n");
	# print STDERR "TLF: $top_level_field, FN: \"$fieldname\"\n";
	# print STDERR "FIELD $field\n";
	SWITCH: {
            ($field =~ /^\/(\*|\/)\!/o && $first_field) && do {
                                my $copy = $field;
                                $copy =~ s/^\/(\*|\/)\!\s*//s;
                                if (length($copy)) {
                                        $self->discussion($copy);
					$seen_top_level_field = 1;
                                }
                        last SWITCH;
                        };

	    # (($lang eq "java") && ($field =~ /^\s*\/\*\*/o)) && do {
			# ignore opening /**
			# last SWITCH;
		# };

	    ($self->isAPIOwner() && $field =~ s/^alsoinclude\s+//sio) && do {
			$self->alsoInclude($field);
			last SWITCH;
		};
	    ($callbackObj) &&
		do {
			my $fallthrough = 0;
			my $cbName = $callbackObj->name();
                        print STDERR "In callback: field is '$field'\n" if ($localDebug);
                        
                        if ($field =~ s/^(param|field)\s+//sio) {
                            $field =~ s/^\s+|\s+$//go;
                            $field =~ /(\w*)\s*(.*)/so;

                            my $paramName = $1;
                            my $paramDesc = $2;
                            $callbackObj->addToUserDictArray({"$paramName" => "$paramDesc"});

			} elsif ($field =~ s/^internal\s+//sio) {
			    $callbackObj->isInternal(1);
                        } elsif ($field =~ s/^apiuid\s+//sio) {
			    $callbackObj->requestedUID($field);
                        } elsif ($field =~ s/^return(s)?\s+//sio) {
                            $field =~ s/^\s+|\s+$//go;
                            $callbackObj->addToUserDictArray({"Returns" => "$field"});
                        } elsif ($field =~ s/^result\s+//sio) {
                            $field =~ s/^\s+|\s+$//go;
                            $field =~ /(\w*)\s*(.*)/so;
                            $callbackObj->addToUserDictArray({"Result" => "$field"});
                        } else {
			    print STDERR "Adding callback field to typedef[1].  Callback name: $cbName.\n" if ($localDebug);
			    if ($callbackObj->{ISDEFINE}) {
				$self->addTaggedParameter($callbackObj);
			    } else {
				$self->addToFields($callbackObj);
			    }
                            $callbackObj = undef;
			    # next SWITCH;
			    $fallthrough = 1;
                        }

			if (!$fallthrough) {
				last SWITCH;
			}
                };

	    ($field =~ s/^internal\s+//sio) && do {
			$self->isInternal(1);
			last SWITCH;
		};
	    ($field =~ s/^apiuid\s+//sio) && do {
			$self->requestedUID($field);
			last SWITCH;
		};
	    ($field =~ s/^serial\s+//sio) && do {$self->attribute("Serial Field Info", $field, 1); last SWITCH;};
	    (($class =~ /HeaderDoc\:\:Function/ ||
                $class =~ /HeaderDoc\:\:Method/) && $field =~ s/^serialData\s+//io) && do {$self->attribute("Serial Data", $field, 1); last SWITCH;};
            ($field =~ s/^serialfield\s+//sio) && do {
                    if (!($field =~ s/(\S+)\s+(\S+)\s+//so)) {
                        warn "$fullpath:$linenum: warning: serialfield format wrong.\n";
                    } else {
                        my $name = $1;
                        my $type = $2;
                        my $description = "(no description)";
                        my $att = "$name<br>\nType: $type";
                        $field =~ s/^(<br>|\s)*//sgio;
                        if (length($field)) {
                                $att .= "<br>\nDescription: $field";
                        }
                        $self->attributelist("Serial Fields", $att,  1);
                    }
                    last SWITCH;
                };
            ($field =~ s/^unformatted(\s+|$)//sio) && do {
		$self->preserve_spaces(1);
		last SWITCH;
	    };

                        (!$self->isAPIOwner() && $field =~ s/^templatefield\s+//sio) && do {
                                        $self->attributelist("Template Field", $
field);
                                        last SWITCH;
                        };      


                                ($self->isAPIOwner() && $field =~ s/^templatefield(\s+)/$1/sio) && do {
                                        $field =~ s/^\s+|\s+$//go;
                                        $field =~ /(\w*)\s*(.*)/so;
                                        my $fName = $1;
                                        my $fDesc = $2;
                                        my $fObj = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang);
					$fObj->apiOwner($self);
                                        $fObj->linenuminblock($linenuminblock);
                                        $fObj->blockoffset($blockoffset);
                                        # $fObj->linenum($linenum);
                                        $fObj->apiOwner($self);
                                        $fObj->outputformat($self->outputformat);
                                        $fObj->name($fName);
                                        $fObj->discussion($fDesc);
                                        $self->addToFields($fObj);
# print STDERR "inserted field $fName : $fDesc";
                                        last SWITCH;
                                };

	    ($self->isAPIOwner() && $field =~ s/^super(class|)(\s+)/$2/sio) && do {
			$self->attribute($superclassfieldname, $field, 0);
			$self->explicitSuper(1);
			last SWITCH;
		};
	    ($self->isAPIOwner() && $field =~ s/^instancesize(\s+)/$1/sio) && do {$self->attribute("Instance Size", $field, 0); last SWITCH;};
	    ($field =~ s/^performance(\s+)/$1/sio) && do {$self->attribute("Performance", $field, 1); last SWITCH;};
	    # ($self->isAPIOwner() && $field =~ s/^subclass(\s+)/$1/sio) && do {$self->attributelist("Subclasses", $field); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^nestedclass(\s+)/$1/sio) && do {$self->attributelist("Nested Classes", $field); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^coclass(\s+)/$1/sio) && do {$self->attributelist("Co-Classes", $field); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^helper(class|)(\s+)/$2/sio) && do {$self->attributelist("Helper Classes", $field); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^helps(\s+)/$1/sio) && do {$self->attribute("Helps", $field, 0); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^classdesign(\s+)/$1/sio) && do {$self->attribute("Class Design", $field, 1); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^dependency(\s+)/$1/sio) && do {$self->attributelist("Dependencies", $field); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^ownership(\s+)/$1/sio) && do {$self->attribute("Ownership Model", $field, 1); last SWITCH;};
	    ($field =~ s/^security(\s+)/$1/sio) && do {$self->attribute("Security", $field, 1); last SWITCH;};
	    ($self->isAPIOwner() && $field =~ s/^whysubclass(\s+)/$1/sio) && do {$self->attribute("Reason to Subclass", $field, 1); last SWITCH;};
	    # ($self->isAPIOwner() && $field =~ s/^charset(\s+)/$1/sio) && do {$self->encoding($field); last SWITCH;};
	    # ($self->isAPIOwner() && $field =~ s/^encoding(\s+)/$1/sio) && do {$self->encoding($field); last SWITCH;};

	    (($self->isAPIOwner() || $class =~ /HeaderDoc\:\:Function/ ||
		$class =~ /HeaderDoc\:\:Method/ ||
		($class =~ /HeaderDoc\:\:Var/ && $isProperty)) &&
	     $field =~ s/^(throws|exception)(\s+)/$2/sio) && do {
			$self->throws($field);
			last SWITCH;
		};

	    ($field =~ s/^namespace(\s+)/$1/sio) && do {$self->namespace($field); last SWITCH;};

            ($self->isAPIOwner() && $field =~ s/^unsorted\s+//sio) && do {$self->unsorted(1); last SWITCH;};
            ($field =~ s/^abstract\s+//sio) && do {$self->abstract($field); last SWITCH;};
            ($field =~ s/^brief\s+//sio) && do {$self->abstract($field, 1); last SWITCH;};
            ($field =~ s/^(discussion|details|description)(\s+|$)//sio) && do {
			# print STDERR "DISCUSSION ON $self: $field\n";

			if ($class =~ /HeaderDoc\:\:PDefine/ && $self->inDefineBlock() && length($olddisc)) {
				# Silently drop these....
				### $self->{DISCUSSION} = "";
			}
			if (!length($field)) { $field = "\n"; }
			$self->discussion($field);
			last SWITCH;
		};
            ($field =~ s/^availability\s+//sio) && do {$self->availability($field); last SWITCH;};
            ($field =~ s/^since\s+//sio) && do {$self->availability($field); last SWITCH;};
            ($field =~ s/^author\s+//sio) && do {$self->attribute("Author", $field, 0); last SWITCH;};
            ($field =~ s/^group\s+//sio) && do {$self->group($field); last SWITCH;};
            ($field =~ s/^vargroup\s+//sio) && do {
			$field =~ s/[\n\r]/ /sg;
			$field =~ s/^\s*//sg;
			$field =~ s/\s*$//sg;
			$vargroup = $field;
			last SWITCH;
		};

	    ($class =~ /HeaderDoc\:\:PDefine/ && $self->isBlock() && $field =~ s/^hidesingletons(\s+)/$1/sio) && do {$self->{HIDESINGLETONS} = 1; last SWITCH;};
	    (($class =~ /HeaderDoc\:\:PDefine/ || $class =~ /HeaderDoc\:\:Function/ || $class =~ /HeaderDoc\:\:Method/) && $field =~ s/^hidecontents(\s+)/$1/sio) && do {$self->hideContents(1); last SWITCH;};
	    (($class =~ /HeaderDoc\:\:Function/ || $class =~ /HeaderDoc\:\:Method/) && $field =~ s/^(function|method)group\s+//sio) &&
		do {$self->group($field); last SWITCH;};


            ($class =~ /HeaderDoc\:\:PDefine/ && $field =~ s/^parseOnly(\s+|$)//sio) && do { $self->parseOnly(1); last SWITCH; };
            ($class =~ /HeaderDoc\:\:PDefine/ && $field =~ s/^noParse(\s+|$)//sio) && do { print STDERR "Parsing will be skipped.\n" if ($localDebug); $HeaderDoc::skipNextPDefine = 1; last SWITCH; };


            ($field =~ s/^indexgroup\s+//sio) && do {$self->indexgroup($field); last SWITCH;};
            ($field =~ s/^version\s+//sio) && do {$self->attribute("Version", $field, 0); last SWITCH;};
            ($field =~ s/^deprecated\s+//sio) && do {$self->attribute("Deprecated", $field, 0); last SWITCH;};
            ($field =~ s/^updated\s+//sio) && do {$self->updated($field); last SWITCH;};
	    ($field =~ s/^attribute\s+//sio) && do {
		    my ($attname, $attdisc, $namedisc) = &getAPINameAndDisc($field, $self->lang());
		    if (length($attname) && length($attdisc)) {
			$attdisc =~ s/^\s*//s;
			$attdisc =~ s/\s*$//s;
			$self->attribute($attname, $attdisc, 0);
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attribute\n";
		    }
		    last SWITCH;
		};
	    ($field =~ s/^attributelist\s+//sio) && do {
		    $field =~ s/^\s*//so;
		    $field =~ s/\s*$//so;
		    my ($name, $lines) = split(/\n/, $field, 2);
		    $name =~ s/^\s*//so;
		    $name =~ s/\s*$//so;
		    $lines =~ s/^\s*//so;
		    $lines =~ s/\s*$//so;
		    if (length($name) && length($lines)) {
			my @attlines = split(/\n/, $lines);
			foreach my $line (@attlines) {
			    $self->attributelist($name, $line);
			}
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attributelist\n";
		    }
		    last SWITCH;
		};
	    ($field =~ s/^attributeblock\s+//sio) && do {
		    my ($attname, $attdisc, $namedisc) = &getAPINameAndDisc($field, $self->lang());
		    if (length($attname) && length($attdisc)) {
			$self->attribute($attname, $attdisc, 1);
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attributeblock\n";
		    }
		    last SWITCH;
		};
	    ($field =~ /^see(also|)\s+/sio) &&
		do {
		    my $rest;

		    ($field, $rest) = splitOnPara($field);

		    $self->see($field);

		    if ($rest =~ /\S/s) {
			if ($class =~ /HeaderDoc\:\:PDefine/ && $self->inDefineBlock() && length($olddisc)) {
				# Silently drop these....
				### $self->{DISCUSSION} = "";
			}
			# if (!length($rest)) { $rest = "\n"; }
			$self->discussion($rest);
		    };
		    last SWITCH;
		};

            (($class =~ /HeaderDoc\:\:(?:Function|Method|CPPClass|ObjC(?:Container|Category|Class|Protocol))/) && $field =~ s/^var?\s+//sio) &&
		do {
                    $field =~ s/^\s+|\s+$//go;
#                   $field =~ /(\w*)\s*(.*)/so;

                    $field =~ /(\S*)\s*(.*)/so; # Let's accept any printable char for name, for pseudo enum values
                    my $cName = $1;
                    my $cDesc = $2;

		    # If we can split on a newline, do it.
                    if ($field =~ /^(.*?)\n(.*)$/so) {
                    	$cName = $1;
                    	$cDesc = $2;
		    }
                    my $cObj = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang);
		    $cObj->apiOwner($self);
                    $cObj->outputformat($self->outputformat);
                    $cObj->name($cName);
                    $cObj->fullpath($self->fullpath());
                    $cObj->group($vargroup);
                    $cObj->autodeclaration(1);
                    $cObj->abstract($cDesc);
                    # $cObj->discussion($cDesc);
                    $self->addVariable($cObj); 
		    $self->apirefSetup();
                    my $name = $self->name();
                    if ($name eq "") {
                        $name = "$cName";
                        $self->firstconstname($name);
                    }   
                    last SWITCH;
		};
            (($class =~ /HeaderDoc\:\:Enum/ || $class =~ /HeaderDoc\:\:Typedef/) && $field =~ s/^const(ant)?\s+//sio) &&
                do {
		    if ($self->can("isEnumList")) {
			$self->isEnumList(1);
		    }
                    $field =~ s/^\s+|\s+$//go;
#                   $field =~ /(\w*)\s*(.*)/so;
                    $field =~ /(\S*)\s*(.*)/so; # Let's accept any printable char for name, for pseudo enum values
                    my $cName = $1;
                    my $cDesc = $2;
                    my $cObj = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang);
		    $cObj->apiOwner($self);
                    $cObj->outputformat($self->outputformat);
                    $cObj->name($cName);
                    $cObj->discussion($cDesc);
                    $self->addConstant($cObj); 
                    my $name = $self->name();
                    if ($name eq "") {
                        $name = "$cName";
                        $self->firstconstname($name);
                    }   
                    last SWITCH;
                };

            (($class =~ /HeaderDoc\:\:Struct/ || $class =~ /HeaderDoc\:\:Typedef/) && $field =~ s/^callback\s+//sio) &&
                do {
                    $field =~ s/^\s+|\s+$//go;
                    $field =~ /(\w*)\s*(.*)/so;
                    my $cbName = $1;
                    my $cbDesc = $2;

		    if ($callbackObj && $callbackObj->{ISDEFINE}) {
			$self->addTaggedParameter($callbackObj);
		    } elsif ($callbackObj) {
			$self->addToFields($callbackObj);
		    }
                    $callbackObj = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang);
		    $callbackObj->apiOwner($self);
                    $callbackObj->outputformat($self->outputformat);
                    $callbackObj->name($cbName);
                    $callbackObj->discussion($cbDesc);
                    $callbackObj->type("callback");

		    # $self->addToFields($callbackObj);
                    # now get params and result that go with this callback
                    print STDERR "Found callback.  Callback name: $cbName.\n" if ($localDebug);
		    last SWITCH;
		};

            # param and result have to come last, since they should be handled differently, if part of a callback
            # which is inside a struct (as above).  Otherwise, these cases below handle the simple typedef'd callback
            # (i.e., a typedef'd function pointer without an enclosing struct.

	    (($class =~ /HeaderDoc\:\:Function/ || $class =~ /HeaderDoc\:\:Method/ || $class =~ /HeaderDoc\:\:Struct/ ||
	      $class =~ /HeaderDoc\:\:Typedef/ || $class =~ /HeaderDoc\:\:PDefine/ ||
	      $class =~ /HeaderDoc\:\:Var/) && $field =~ s/^(param|field)\s+//sio) &&
                        do {
				my $fieldname = $1;

				my $rest;

				# For better Doxygen compatibility, we should do this:
				# ($field, $rest) = splitOnPara($field);
				# but a lot of existing content assumes that @param doesn't stop
				# at the first whitespace, so we can't do that.

                                $field =~ s/^\s+|\s+$//go; # trim leading and trailing whitespace
                                # $field =~ /(\w*)\s*(.*)/so;
                                $field =~ /(\S*)\s*(.*)/so;
                                my $pName = $1;
                                my $pDesc = $2;

                                my $param = $self->taggedParamFind($pName);
				my $new = 0;

				if (!$param) { $param = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang); $new = 1;}
				$param->apiOwner($self);
                                $param->outputformat($self->outputformat);
                                $param->name($pName);

				if ($new) {
                                	$param->discussion($pDesc);
			                if (($class =~ /HeaderDoc\:\:Typedef/ || $class =~ /HeaderDoc\:\:Struct/) &&
					    $field =~ /^param\s+/) {
	                                        $param->type("funcPtr");
	                    	                $self->addToFields($param);
			                } else {
	                    	            $self->addTaggedParameter($param);
			                }
				} else {
                                	$param->discussion($param->discussion()."\n\n".$pDesc);
				}
				if ($class =~ /HeaderDoc\:\:Var/ && !$isProperty) {
					warn "Field \@$fieldname found in \@var declaration.\nYou should use \@property instead.\n" if (!$HeaderDoc::running_test);
				}

		    		if ($rest =~ /\S/s) {
					if ($class =~ /HeaderDoc\:\:PDefine/ && $self->inDefineBlock() && length($olddisc)) {
						# Silently drop these....
						### $self->{DISCUSSION} = "";
					}
					# if (!length($rest)) { $rest = "\n"; }
					$self->discussion($rest);
		    		};
                                last SWITCH;
                         };

	    (($class =~ /HeaderDoc\:\:Function/ || $class =~ /HeaderDoc\:\:Method/ ||
		$class =~ /HeaderDoc\:\:Typedef/ || $class =~ /HeaderDoc\:\:Struct/ ||
		$class =~ /HeaderDoc\:\:PDefine/ ||
		$class =~ /HeaderDoc\:\:Var/) && $field =~ s/^return(s)?\s+//sio) &&
		do {
			if ($class =~ /HeaderDoc\:\:Typedef/) {
				$self->isFunctionPointer(1);
			}
			if ($class =~ /HeaderDoc\:\:Var/ && !$isProperty) {
				warn "Field \@return found in \@var declaration.\nYou should use \@property instead.\n" if (!$HeaderDoc::running_test);
			}
			$self->result($field);
			last SWITCH;
		};
	    (($class =~ /HeaderDoc\:\:Function/ || $class =~ /HeaderDoc\:\:Method/ ||
		$class =~ /HeaderDoc\:\:Typedef/ || $class =~ /HeaderDoc\:\:Struct/ ||
		$class =~ /HeaderDoc\:\:PDefine/ ||
		$class =~ /HeaderDoc\:\:Var/) && $field =~ s/^result\s+//sio) &&
		do {
			if ($class =~ /HeaderDoc\:\:Typedef/) {
				$self->isFunctionPointer(1);
			}
			if ($class =~ /HeaderDoc\:\:Var/ && !$isProperty) {
				warn "Field \@result found in \@var declaration.\nYou should use \@property instead.\n" if (!$HeaderDoc::running_test);
			}
			$self->result($field);
			last SWITCH;
		};

                ($top_level_field == 1) &&
                        do {
                                my $keepname = 1;
				my $blockrequest = 0;
				my $isavmacro = 0;

				print STDERR "TLF: $field\n" if ($localDebug);

				my $pattern = "";

				if ($class =~ /HeaderDoc\:\:PDefine/ && $field =~ s/^(availabilitymacro)(\s+|$)/$2/sio) {
					$self->isAvailabilityMacro(1);
					$keepname = 1;
					$self->parseOnly(1);
					$isavmacro = 1;
				} elsif ($class =~ /HeaderDoc\:\:PDefine/ && $field =~ s/^(define(?:d)?block)(\s+)/$2/sio) {
					$keepname = 1;
					$self->isBlock(1);
					$blockrequest = 1;
				} elsif ($class =~ /HeaderDoc\:\:CPPClass/) {
					$pattern = ":|public|private|[()]";
					# print STDERR "PATTERN: $pattern\n";
				} elsif ($class =~ /HeaderDoc\:\:Method/) {
					$pattern = ":|[()]";
				} elsif ($class =~ /HeaderDoc\:\:Function/) {
					$pattern = "::|[()]";
				} elsif ($field =~ /category\s+/) {
					$pattern = "[():]";
				}

				# If we begin with the correct @whatever tag,
				# process it.  If the tag isn't what is
				# expected based on what was parsed from the
				# code (e.g. @function for a #define), throw
				# away the name and tag type.

                                if (!$blockrequest && $field =~ s/^($tag_re)(\s+|$)/$2/i) {
					print STDERR "tag_re[1]: tag matches\n" if ($localDebug);
                                        $keepname = 1;
                                } elsif (!$blockrequest && !$isavmacro) {
					print STDERR "tag_re[2] tag does NOT match\n" if ($localDebug);

					# Strip off the tag!
                                        $field =~ s/(\w+)(\s|$)/$2/sio;
                                        $keepname = 0;
				}

				my ($name, $abstract_or_disc, $namedisc) = getAPINameAndDisc($field, $self->lang(), $pattern);
				print STDERR "FIELD: $field\nNAME: $name AOD: $abstract_or_disc ND: $namedisc" if ($localDebug);
				if ($fieldname eq "name") {$self->{FORCENAME} = $name; print STDERR "FORCED NAME TO \"$name\"\n"};

				print STDERR "KEEPNAME: $keepname\n" if ($localDebug);

				if ($class =~ /HeaderDoc\:\:PDefine/ && $self->isBlock()) {
					print STDERR "ISBLOCK (BLOCKREQUEST=$blockrequest)\n" if ($localDebug);
					# my ($name, $abstract_or_disc, $namedisc) = getAPINameAndDisc($field, $self->lang());
					# In this case, we get a name and abstract.
					if ($blockrequest) {
						print STDERR "Added block name $name\n" if ($localDebug);
						if (length($abstract_or_disc)) {
							if ($namedisc) {
								$self->name($name." ".$abstract_or_disc);
								# $self->nameline_discussion($abstract_or_disc);
							} else {
								$self->name($name);
								$self->discussion($abstract_or_disc);
							}
						} else {
							$self->name($name);
						}
					} else {
						print STDERR "Added block member $name\n" if ($localDebug);

						if ($callbackObj && $callbackObj->{ISDEFINE}) {
							$self->addTaggedParameter($callbackObj);
						} elsif ($callbackObj) {
							$self->addToFields($callbackObj);
						}
						$callbackObj = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang);
						$callbackObj->apiOwner($self);
						$callbackObj->name($name);
						my $ref = $self->addToIncludedDefines($callbackObj);
						$callbackObj = ${$ref};
						bless($callbackObj, "HeaderDoc::HeaderElement");
						bless($callbackObj, $callbackObj->class());
						if (length($abstract_or_disc)) {
							if ($namedisc) {
								$callbackObj->nameline_discussion($abstract_or_disc);
							} else {
								$callbackObj->discussion($abstract_or_disc);
							}
						}
						$callbackObj->{ISDEFINE} = 1;
					}
				} else {
					if (length($name)) {
						# print STDERR "NOT BLOCK.  NAME IS \"$name\"\n";
						if ($keepname && (!$self->isAPIOwner() || !$HeaderDoc::ignore_apiowner_names)) {
							print STDERR "SET NAME TO $name\n" if ($localDebug);
                                			$self->name($name);
						}
					}
                                	if (length($abstract_or_disc)) {
                                        	if ($namedisc) {
                                                	$self->nameline_discussion($abstract_or_disc);
                                        	} else {
                                                	$self->discussion($abstract_or_disc);
                                        	}
                                	}

				}

                                last SWITCH;
                        };

	    # my $fullpath = $HeaderDoc::headerObject->fullpath();
            # warn "$fullpath:$linenum: warning: Unknown field in constant comment: $field\n";
		{
		    if (length($field)) {
			warn "$fullpath:$linenum: warning: Unknown field (\@$field) in $tagname comment (".$self->name().")\n";
			# cluck("Here\n");
		    }
		};

	}
	$first_field = 0;
	if ($top_level_field) { $seen_top_level_field = 1; }
    }

    if ($callbackObj) {
	if ($callbackObj->{ISDEFINE}) {
		$self->addTaggedParameter($callbackObj);
	} else {
		$self->addToFields($callbackObj);
	}
    }

    # print STDERR "CLASS: ".(ref($self) || $self)." NAME: ".$self->name()." LN: ".$self->linenum()." LNIB: ".$self->linenuminblock()." BO: ".$self->blockoffset()."\n";
    # $self->dbprint();

    return;
}

# /*!
#     @abstract
#         Gets/sets whether this object's contents should be hidden.
#     @param self
#         This object.
#     @param hidden
#         The new value. (Optional.)
#     @discussion
#         Function-like macros (with curly braces) are hidden
#         by default. The contents of other macros can be hidden by
#         adding the <code>\@hidecontents</code> tag to the comment.
#  */
sub hideContents
{
    my $self = shift;
    if (@_) {
	$self->{HIDECONTENTS} = shift;
    }
    return $self->{HIDECONTENTS};
}

# /*!
#     @abstract
#         Gets/sets whether this object is a member of a define block.
#     @param self
#         This object.
#     @param inblock
#         The new value.
#  */
sub inDefineBlock
{
    my $self = shift;
    if (@_) {
	$self->{INDEFINEBLOCK} = shift;
    }
    return $self->{INDEFINEBLOCK};
}

# /*!
#     @abstract
#         Compares two strings in a case-insensitive fashion.
#     @param a
#         The first string.
#     @param b
#         The second string.
#  */
sub strcasecmp($$)
{
    my $a = shift;
    my $b = shift;

    return (lc($a) cmp lc($b));
}

# /*!
#     @abstract
#         Unregisters this object.
#     @param self
#         This object.
#     @discussion
#         This function unregisters the descendents of this
#         object from the UID conflict detection code and marks
#         this object in such a way that its UID will never be
#         reregistered.
#
#         You should generally not call this unless you are about
#         to dispose of the object.
#  */
sub unregister
{
    my $self = shift;

    my @arr = ();
    my $localDebug = 0;

    my $group = $self->group();
    if ($group) {
	$self->apiOwner()->removeFromGroup($group, $self);
    }
    foreach my $tp ($self->taggedParameters()) {
	push(@arr, $tp);
    }
    foreach my $const ($self->constants()) {
	push(@arr, $const);
    }
    foreach my $variable ($self->variables()) {
	push(@arr, $variable);
    }
    if ($self->can("fields")) {
	foreach my $field ($self->fields()) {
		push(@arr, $field);
	}
    }
    foreach my $obj (@arr) {
	my $uid = $obj->apiuid();
	print STDERR "Unregistering UID $uid\n" if ($localDebug);
	unregisterUID($uid, $obj->name(), $obj);
	unregister_force_uid_clear($uid);
    }
    $self->noRegisterUID(1);
}

# /*!
#     @abstract
#         Gets/sets whether this object should be banned from UID registration.
#     @param self
#         The (generally {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}) object.
#     @param value
#         The value to set. (Optional.)
#  */
sub noRegisterUID
{
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
	my $val = shift;
	print STDERR "No register uid set to $val ($self).\n" if ($localDebug);
	$self->{NOREGISTERUID} = $val;
    }
    return $self->{NOREGISTERUID};
}

# /*!
#     @abstract
#         Wipes any cached API and/or link UIDs for this object.
#     @param self
#         This object.
#  */
sub wipeUIDCache
{
    my $self = shift;
    my $localDebug = 0;

    print STDERR "APIUID and LINKUID wiped ($self).\n" if ($localDebug);
    $self->{APIUID} = undef;
    $self->{LINKUID} = undef;
}

# /*!
#     @abstract
#         Gets/sets whether this object's children should be suppressed.
#     @param self
#         The (generally {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}) object.
#     @param value
#         The value to set. (Optional.)
#     @discussion
#         An object's children are generally suppressed for the outer typedef
#         linked to a separate struct or enum declaration, e.g. when the
#         <code>\@typedef</code> comment is followed by an enum declaration, followed by
#         the actual typedef.
#
#         When an object's children (parsed/tagged parameters, fields, etc.)
#         are suppressed, no UIDs are generated for the objects, and the
#         tagged/parsed parameter comparison does not occur.  Output from any
#         explicitly tagged parameters is still emitted, however.  The
#         reason for this is that the parsed parameters aren't really
#         associated with the typedef, so you'd get lots of warnings.
#  */
sub suppressChildren
{
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
	my $val = shift;
	cluck("Suppress children set to $val ($self).\n") if ($localDebug);
	$self->{SUPPRESSCHILDREN} = $val;
    }
    return $self->{SUPPRESSCHILDREN};
}

# /*!
#     @abstract
#         Returns the "Declared in" HTML string for a class.
#     @param self
#         This class object.
#  */
sub declaredIn
{
    my $self = shift;
    my $class = ref($self) || $self;
    my $apio = $self->apiOwner();

	# warn $self->name()."\n";
    if (!$apio) { return ""; }
    if ($apio->outputformat() eq "hdxml") {
	# blank for XML.
	return "";
    }

    # print STDERR "DI: $self APIO: $apio\n";

    if ($apio->{AS_FUNC_SELF}) {
	my $func_apio_ref = $apio->{AS_FUNC_SELF};
	if (!$func_apio_ref) {
		die("Bad AS_FUNC_SELF for $apio (".$apio->name().")\n");
	}
	my $func_apio = ${$func_apio_ref};
	bless($func_apio, "HeaderDoc::HeaderElement");
	bless($func_apio, $func_apio->class());

	# print STDERR "CLASS IN FUNC\n";
	my $name = $func_apio->name();
	my $apiref = $func_apio->apiuid();
	my $jumpTarget = $apiref;

	return "<a href=\"../../../index.html#$jumpTarget\" logicalPath=\"$apiref\" target=\"_top\" machineGenerated=\"true\">$name</a>";
    }

    if ($self->isAPIOwner()) {
	if ($class =~ /HeaderDoc::Header/) {
		# warn $self->name.": Header\n";
		return "";
	} else {
		my $name = $apio->name();
		my $apiref = $apio->apiuid();

		return "<a href=\"../../index.html\" logicalPath=\"$apiref\" target=\"_top\" machineGenerated=\"true\">$name</a>";
	}
    } else {
	my $name = $apio->name();
	my $apiref = $apio->apiuid();

	return "<!-- a logicalPath=\"$apiref\" target=\"_top\" machineGenerated=\"true\" -->$name<!-- /a -->";
    }

    return "";
}

# /*!
#     @abstract
#         Returns a custom HeaderDoc doc navigator comment for this object.
#     @param self
#         This object.
#     @param type
#         The type of the doc navigator comment.  Currently valid
#         values are <code>abstract</code>, <code>discussion</code> 
#         and <code>declaration</code>.
#     @param startend
#         The word <code>start</code> or <code>end</code>, depending
#         on whether you want a start or end doc navigator comment.
#  */
sub headerDocMark
{
    my $self = shift;
    my $type = shift;
    my $startend = shift;

    my $uid = $self->apiuid();

    return "<!-- headerDoc=$type;uid=".$uid.";name=$startend -->";
}

# /*!
#     @abstract
#         Returns a string of HTML <code>&lt;link&gt;</code> tags for
#         multiple external stylesheets.
#     @param self
#         This object.
#     @param liststring
#         A list of style sheets separated by spaces.
#     @discussion
#         Normally, the list comes from the HeaderDoc
#         config file.
#  */
sub doExternalStyle
{
    my $self = shift;
    my $liststring = shift;
    my @list = split(/\s/, $liststring);
    my $string = "";

    foreach my $styleSheet (@list) {
	$styleSheet =~ s/{\@docroot}/\@\@docroot/sg;
	$string .= "<link rel=\"stylesheet\" type=\"text/css\" href=\"$styleSheet\">\n";
    }

    if ($self->outputformat eq "hdxml") {
	return xml_fixup_links($self, $string);
    } else {
	return html_fixup_links($self, $string);
    }
}

# /*!
#     @abstract
#         Attempts to detach this object and destroy references to it to release memory.
#     @param self
#         This object.
# */
sub free
{
	my $self = shift;
	my $freechildrenraw = shift; # Set to 0.
	my $keepParseTreeAndState = shift;
	my $newParseTreeOwner = shift;

	## if ($keepParseTreeAndState) { $self->{FAILHARD} = 1;
		## printHash(%{$self});
		## print STDERR "PARSE TREES:\n"; foreach my $tree (@{$self->{PARSETREELIST}}) { print "    $tree\n"; }
		## print "    ".$self->{PARSETREE}."\n";
		## return; }

	print STDERR "NPTO: $newParseTreeOwner\n" if ($HeaderDoc::debugAllocations);

	my $parseTree_ref = $self->parseTree();

	cluck("FREEING $self\n") if ($HeaderDoc::debugAllocations);

	# printHash(%{$self}) if ($HeaderDoc::debugAllocations);

	if ($parseTree_ref) {
		my $parseTree = ${$parseTree_ref};
		bless($parseTree, "HeaderDoc::ParseTree");

		print "REMOVING FROM MAIN ".$parseTree."\n" if ($HeaderDoc::debugAllocations);
		# if ($self->isBlock() && $HeaderDoc::debugAllocations) {
			# print STDERR "Dumping parse tree for block\n";
			# $parseTree->dbprint(1);
		# }
		$parseTree->apiOwnerSub($self, $newParseTreeOwner || undef, 1);
		$parseTree->dbprint(1) if ($HeaderDoc::debugAllocations);
		if (!$keepParseTreeAndState) { $parseTree->dispose(); }
		$self->{PARSETREE} = undef;
	}
	if ($self->{PARSETREELIST}) {
		foreach my $treeref (@{$self->{PARSETREELIST}}) {
			print "REMOVING FROM PARSETREELIST ".${$treeref}."\n" if ($HeaderDoc::debugAllocations);
			${$treeref}->apiOwnerSub($self, $newParseTreeOwner || undef, 1);
			${$treeref}->dbprint(1) if ($HeaderDoc::debugAllocations);
			if (!$keepParseTreeAndState) { ${$treeref}->dispose(); }
		}
	}
	$self->{PARSETREELIST} = undef;
	if ($self->{PARSETREECLEANUP}) {
		foreach my $treeref (@{$self->{PARSETREECLEANUP}}) {
			print "REMOVING FROM CLEANUP ".${$treeref}."\n" if ($HeaderDoc::debugAllocations);
			${$treeref}->apiOwnerSub($self, $newParseTreeOwner || undef, 1);
			${$treeref}->dbprint(1) if ($HeaderDoc::debugAllocations);
			if (!$keepParseTreeAndState) { ${$treeref}->dispose(); }
		}
	}
	$self->{PARSETREECLEANUP} = undef;

	my $state = $self->{PARSERSTATE};
	if ($state && !$keepParseTreeAndState) { $state->free(); }
	$self->{PARSERSTATE} = undef;

	if (!$self->noRegisterUID()) {
		dereferenceUIDObject($self->apiuid(), $self);
	}

	$self->{APIOWNER} = undef;

	$self->{MASTERENUM} = undef;
	$self->{MAINOBJECT} = undef;

	if ($self->{NAMEREFS}) {
		my @arr = @{$self->{NAMEREFS}};

		foreach my $name (@arr) {
			$HeaderDoc::namerefs{$name} = undef;
		}
	}
	$self->{NAMEREFS} = undef;

	$self->setAPIOBackReferences( $self->{CONSTANTS}, 1, $newParseTreeOwner);
	$self->setAPIOBackReferences( $self->{FIELDS}, 1, $newParseTreeOwner);
	$self->setAPIOBackReferences( $self->{VARIABLES}, 1, $newParseTreeOwner);
	$self->setAPIOBackReferences( $self->{INCLUDED_DEFINES}, 1, $newParseTreeOwner);

	$self->setAPIOBackReferences( $self->{KEEPPARAMS}, 1, $newParseTreeOwner);
	$self->setAPIOBackReferences( $self->{KEEPVARIABLES}, 1, $newParseTreeOwner);
	$self->setAPIOBackReferences( $self->{KEEPFIELDS}, 1, $newParseTreeOwner);
	$self->setAPIOBackReferences( $self->{KEEPCONSTANTS}, 1, $newParseTreeOwner);

	my $class = ref($self) || $self;
	if ((!$self->isBlock()) || ($newParseTreeOwner)) {
		$self->setAPIOBackReferences( $self->{PARSEDPARAMETERS}, 1, $newParseTreeOwner);
	}
	$self->setAPIOBackReferences( $self->{TAGGEDPARAMETERS}, 1, $newParseTreeOwner);

	$self->{CONSTANTS} = undef;
	$self->{FIELDS} = undef;
	$self->{VARIABLES} = undef;
	$self->{INCLUDED_DEFINES} = undef;
	$self->{ATTRIBUTELISTS} = undef;
	$self->{SEEALSODUPCHECK} = undef;

	$self->{KEEPPARAMS} = undef;
	$self->{KEEPVARIABLES} = undef;
	$self->{KEEPFIELDS} = undef;
	$self->{KEEPCONSTANTS} = undef;
	$self->{PARSEDPARAMETERS} = undef;
	$self->{TAGGEDPARAMETERS} = undef;

	if ($HeaderDoc::debugAllocations) {
		print STDERR "Dumping hash $self\n";
		printHash(%{$self});

		print STDERR "DUMPING $self WITH DEBUG INFO\n";
		DumpWithOP($self);
		# Dump($self);
	}

	$self = ();
}

# /*!
#     @abstract
#         Helper called by Perl when this object gets freed.
#     @param self
#         This object.
# */
sub DESTROY
{
    my $self = shift;

    print STDERR "Destroying $self\n" if ($HeaderDoc::debugAllocations);
}

# /*!
#     @abstract
#         Prints a variable (e.g. an array) in detail for debugging purposes.
#     @param unknown_var
#         The variable to print.
#     @param leadspace
#         Leading space characters (or other text) to add to
#         each line of output.
#     @discussion
#         Called by {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/dbprint//() dbprint}.
#         Do not call directly.
# */
sub dbprint_expanded
{
    my $unknown_var = shift;
    my $leadspace = "";
    if ($_) {
	$leadspace = shift;
    }
    if ($unknown_var =~ "REF") { $unknown_var = ref($unknown_var); }

    my $retstring = $unknown_var;
    if (ref($unknown_var) eq "ARRAY") {
	print STDERR "REF IS ".ref($unknown_var)."\n";
	$retstring .= "\n".$leadspace."ARRAY ELEMENTS:\n";
	my $pos = 0;
	while ($pos < scalar(@{$unknown_var})) {
		$retstring .= $leadspace."     ".sprintf("%08d : ", $pos). dbprint_expanded(@{$unknown_var}[$pos], $leadspace."    ")."\n";
		$pos++;
	}
    } elsif (ref($unknown_var) ne "") {
	$retstring .= "\n".$leadspace."HASH ELEMENTS:\n";
	# print STDERR "REF IS ".ref($unknown_var)."\n";
	foreach my $elt (keys %{$unknown_var}) {
		if ($elt =~ "APIOWNER" || $elt =~ "MASTERENUM") { next; }
		$retstring .= $leadspace."     ".sprintf("%8s : ", $elt). dbprint_expanded($unknown_var->{$elt}, $leadspace."    ")."\n";
	}
    }

    return $retstring;;
}

# /*!
#     @abstract
#         Gets/sets whether this object is a block declaration.
#     @param self
#         This object.
#     @param value
#         The value to set. (Optional.)
#     @discussion
#         This should be set to a nonzero value for define blocks
#         and blocks of functions wrapped with <code>#if</code> blocks.
#  */
sub isBlock {
    my $self = shift;

    if (@_) {
	$self->{ISBLOCK} = shift;
	if ($self->{ISBLOCK}) {
		$self->fixParseTrees();
	}
    }

    return $self->{ISBLOCK};
}

# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         This object.
#     @param expanded
#         Pass 1 to expand arrays and other structure,
#         or 0 for normal output.
#  */
sub dbprint
{
    my $self = shift;
    my $expanded = shift;
    my @keys = keys %{$self};

    print STDERR "Dumping object $self...\n";
    foreach my $key (@keys) {
	if ($expanded) {
		print STDERR "$key => ".dbprint_expanded($self->{$key})."\n";
	} else {
		print STDERR "$key => ".$self->{$key}."\n";
	}
    }
    print STDERR "End dump of object $self.\n";
}

# /*!
#     @abstract
#         Gets/sets whether spaces in the declaration should be preserved.
#     @param self
#         This object.
#     @param value
#         The value to set. (Optional.)
#     @discussion
#         This is set high by the presence of an <code>\@unformatted</code> tag in
#         the HeaderDoc markup.
#  */
sub preserve_spaces
{
    my $self = shift;
    if (@_) {
	$self->{PRESERVESPACES} = shift;
    }

    if (!defined($self->{PRESERVESPACES})) {
	return 0;
    }
    return $self->{PRESERVESPACES};
}

#/*!
#    @abstract
#        Returns whether this is a framework object.
#    @discussion
#        This is overridden in {@link HeaderDoc::CPPClass}.
# */
sub isFramework
{
    return 0;
}

#/*!
#    @abstract
#        Returns this object's tag type for use in Doxygen-style tag files.
#    @param self
#        This object.
# */
sub getDoxyKind
{
    my $self = shift;
    my $class = ref($self) || $self;

    if ($self->isAPIOwner()) {
	if ($class =~ /HeaderDoc::Header/) {
		return "file";
	}
	return "class";
    }
    if ($class =~ /HeaderDoc::Function/ || $class =~ /HeaderDoc::Method/) {
	return "function";
    }
    if ($class =~ /HeaderDoc::Constant/) {
	return "variable";
    }
    if ($class =~ /HeaderDoc::Var/) {
	return "variable";
    }
    if ($class =~ /HeaderDoc::Struct/) {
	return "struct";
    }
    if ($class =~ /HeaderDoc::Typedef/) {
	return "typedef";
    }
    if ($class =~ /HeaderDoc::Union/) {
	return "union";
    }
    if ($class =~ /HeaderDoc::Enum/) {
	return "enumeration";
    }
    if ($class =~ /HeaderDoc::PDefine/) {
	return "define";
    }
    if ($class =~ /HeaderDoc::MinorAPIElement/) {
	my $parent = $self->apiOwner();
	my $parentclass = ref($parent) || $parent;

	if ($parentclass =~ /HeaderDoc::Enum/) {
		return "enumvalue";
	} else {
		return "variable";
	}
    }
}

# /*!
#     @abstract
#         Gets a Doxygen-style tag string for this object.
#     @param self
#         This object.
#     @param prespace
#         Leading whitespace to prepend to each line.
#  */
sub _getDoxyTagString
{
    my $self = shift;
    my $prespace = shift;

    my $class = ref($self) || $self;
    my $doxyTagString = "";
    my $kind = $self->getDoxyKind();

    my $accessControl = "";
    if ($self->can("accessControl")) {
        $accessControl = $self->accessControl();
    }
    if ($accessControl =~ /\S/) {
	$accessControl = " protection=\"$accessControl\"";
    } else {
	$accessControl = "";
    }

    $doxyTagString .= "$prespace<member kind=\"$kind\"$accessControl>\n";

    my $arglist = "";
    my $type = "";
    if ($class =~ /HeaderDoc::Function/ || $class =~ /HeaderDoc::Method/) {
	$type = $self->returntype();
	$type =~ s/^\s*//s;
	$type =~ s/\s*$//s;
	$type =~ s/\s*\.\s*/./s;

	$doxyTagString .= "$prespace  <type>$type</type>\n";
	my @args = $self->parsedParameters();
	my $comma = "";
	foreach my $obj (@args) {
		$arglist .= $comma;
		my $type .= $obj->type();
		if ($class =~ /HeaderDoc::Method/) {
			my $tagname = $obj->tagname();
			if ($tagname =~ /\S/) {
				$arglist .= "[$tagname] ";
			}
			$type =~ s/^\s*\(//s;
			$type =~ s/\)\s*$//s;
		}
		$arglist .= $self->textToXML($type);
		if ($arglist !~ /[ *]$/) {
			$arglist .= " ";
		}
		$arglist .= $obj->name();
		$comma = ",";
	}
	$arglist = "($arglist)";
    } elsif ($class =~ /HeaderDoc::Var/ || $class =~ /HeaderDoc::Constant/) {
	$type = $self->returntype();
	$type =~ s/^\s*//s;
	$type =~ s/\s*$//s;
	$type =~ s/\s*\.\s*/./s;
	$doxyTagString .= "$prespace  <type>".$self->textToXML($type)."</type>\n";
    }
    $doxyTagString .= "$prespace  <name>".$self->textToXML($self->rawname())."</name>\n";

    # No handling of superclass here because that's handled in APIOwner.pm.

    $doxyTagString .= "$prespace  <anchorfile></anchorfile>\n";
    $doxyTagString .= "$prespace  <anchor></anchor>\n";
    $doxyTagString .= "$prespace  <arglist>$arglist</arglist>\n";
    $doxyTagString .= "$prespace</member>\n";

    return $doxyTagString;
}

# /*!
#     @abstract
#         Sets an override API uid for the rare cases where they would
#         conflict by nature.
#     @discussion
#         This is triggered by the presence of an <code>\@apiuid</code> tag in the
#         HeaderDoc comment block (usually for a header file).
#  */
sub requestedUID
{
	my $self = shift;

	if (@_) {
            my $rquid = shift;

	    $rquid =~ s/^\s*//s;
	    $rquid =~ s/\s*$//sg;

	# print "RQUID: \"$rquid\"\n";
	    if ($rquid =~ /\s/) {
		warn($self->filename().":".$self->linenum().": WARNING: Ignoring illegal apple_ref markup (contains whitespace)\n");
		return $self->{REQUESTEDUID};
	    }

	    # Ideally, this should probably do something like this:
	    # if ($self->{REQUESTEDUID}) {
	    	# unregisterUID($self->{REQUESTEDUID}, $self->name(), $self);
	    # };
	    # if ($self->{APIUID}) {
	    	# $unregisterUID($self->{APIUID}, $self->name(), $self);
	    # };
            $self->{REQUESTEDUID} = $rquid;
	    registerUID($rquid, $self->rawname(), $self);
	}
	return $self->{REQUESTEDUID};
}

# /*!
#     @abstract
#         Prints a dump of function and <code>#define</code>
#         declarations in this header for debugging purposes.
#     @param self
#         This object.
#  */
sub headerDump
{
	my $self = shift;

		print "HEADER\n";
		print "  |\n";
		print "  +-- Functions\n";
		foreach my $obj ($self->functions()) {
		print "  |     +-- ".$obj->name()."\n";
		print "  |     |     +-- obj:     ".$obj."\n";
		print "  |     |     +-- isBlock: ".$obj->isBlock()."\n";
		}
		print "  |\n";
		print "  +-- #defines\n";
		foreach my $obj ($self->pDefines()) {
		print "  |     +-- ".$obj->name()."\n";
		print "  |     |     +-- obj:     ".$obj."\n";
		print "  |     |     +-- isBlock: ".$obj->isBlock()."\n";
		}
}


# /*!
#     @abstract
#         Returns the method type portion of the API reference for a
#               C++ method.
#     @param self
#         This <code>HeaderElement</code> object.
#  */
sub getMethodType
{
	my $self = shift;

	my $class = ref($self) || $self;
	my $apio = $self->apiOwner();
	my $apioclass = ref($apio) || $apio;

	# This probably won't ever really be encountered, but....
	if ($class =~ /HeaderDoc::PDefine/) {
		return "define";
	}

	if ($apioclass eq "HeaderDoc::Header") {
        	return "func";
	}

	my $typename = "instm";           

	if ($class =~ /HeaderDoc::Method/) {
        	# Objective-C
		if (!$self->parserState()) {
			cluck("We shouldn't hit this ($self).\n");
		}
		if ($self->parserState()->{occmethodtype} eq "+") {
			$self->setIsInstanceMethod("NO");
			if ($apioclass =~ /HeaderDoc::ObjCProtocol/) {
                                $typename = "intfcm";
                        } else {
				$typename = "clm";
			}
		} else {
			$self->setIsInstanceMethod("YES");
			if ($apioclass =~ /HeaderDoc::ObjCProtocol/) {
				$typename = "intfm";
			} else {
        			$typename = "instm";
			}
		}
	} else {
		if (($self->lang() ne "C") && ($self->lang() ne "Csource")) {
			return "instm";
		}
		if ($self->sublang() eq "C") {
			# COM interfaces, C pseudoclasses
			return "intfm";
		}
		if ($self->returntype() =~ /(^|\s)static(\s|$)/) {
			$typename = "clm";
		} else {
			$typename = "instm";
		}
	}

	if ($self->isTemplate()) {
        	$typename = "ftmplt";
	}

	return $typename;
}


# /*!
#     @abstract
#         Gets/sets the parser state.
#     @param self
#         This object.
#     @param newstate
#         The new value. (Optional.)
#     @discussion
#         Stores a clone of the parser state object for future
#         reference.  Rarely used, but important for Objective-C
#         method type identification.
#  */
sub parserState {
    my $self = shift;
    if (@_) {
	my $newstate = shift;

	# print STDERR "OBJ $self STATE $newstate\n";
	$self->{PARSERSTATE} = $newstate;
    }
    return $self->{PARSERSTATE};
}

# /*!
#     @abstract
#         Gets/sets the <code>ISINTERNAL</code> flag.
#  */
sub isInternal {
    my $self = shift;
    if (@_) {
	my $newval = shift;

	$self->{ISINTERNAL} = $newval;
    }
    return $self->{ISINTERNAL};
}

# /*! @abstract
#         Sets and returns the namespace of this class.
#     @param self
#         The {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner} object.
#     @param namespace
#         The namespace value to set.  (Optional)
#  */
sub namespace {
    my $self = shift;
    my $localDebug = 0;

    if (@_) { 
        $self->{NAMESPACE} = shift;
    }
    print STDERR "namespace ".$self->{NAMESPACE}."\n" if ($localDebug);
    return $self->{NAMESPACE};
}


# /*!
#     @abstract
#         Clears references to higher nodes in the object graph.
#     @param self
#         The {@link //apple_ref/perl/cl/HeaderDoc::APIOwner APIOwner}
#         object.  (Unused)
#     @param listref
#         A list of objects to modify.
#     @param freechildren
#         Pass 1 to call the
#         {@link //apple_ref/perl/instm/HeaderDoc::HeaderElement/free//() free}
#         method on this object's children, else 0.
#  */
sub setAPIOBackReferences
{
	my $self = shift;
	my $listref = shift;
	my $freechildren = shift;
	my $newowner = shift;

	if ($listref) {
		my @list = @{$listref};
		foreach my $item (@list) {
			$item->{APIOWNER} = $newowner;
			if ($freechildren && !$newowner) {
				$item->free();
			}
		}
	}
}

# /*!
#     @abstract
#         Adds a name to the {@link NAMEREFS} array.
#     @discussion
#         In {@link //apple_ref/doc/header/BlockParse.pm BlockParse.pm},
#         HeaderDoc adds each object into the associative array 
#         {@link HeaderDoc::namerefs}.
#         Because Perl's garbage collection is a joke, this reference must
#         be destroyed to free the object.
#  */
sub addToNameRefs
{
	my $self = shift;
	my $name = shift;

	my @arr = ();
	if ($self->{NAMEREFS}) {
		@arr = @{$self->{NAMEREFS}};
	}
	push(@arr, $name);
	$self->{NAMEREFS} = \@arr;
}


# /*!
#     @abstract
#         Adds a name to the {@link PARSETREECLEANUP} array.
#     @discussion
#         In {@link //apple_ref/doc/header/BlockParse.pm BlockParse.pm},
#         HeaderDoc sets the owner of a parse tree to an API object.
#         If that object goes away, that association needs to be
#         cleared.  This array keeps track of that.
#  */
sub addToCleanup
{
	my $self = shift;
	my $name = shift;

	my @arr = ();
	if ($self->{PARSETREECLEANUP}) {
		@arr = @{$self->{PARSETREECLEANUP}};
	}
	push(@arr, $name);
	$self->{PARSETREECLEANUP} = \@arr;
}

# /*!
#       @abstract
#           Returns the character set encoding of the enclosing
#           file.
#  */
sub encoding
{
	my $self = shift;
	return $self->apiOwner()->encoding();
}

# /*!
#     @abstract
#         Gets/sets the result (return values) text for functions,
#         Objective-C methods, function-like macros, structures
#         containing callbacks, type definitions containing callbacks,
#         and Objective-C properties.
#         etc.
#     @param self
#         The <code>Function</code> object.
#     @param resultstring
#         The string to set.  (Optional.)
#     @discussion
#         This comes from the <code>\@result</code>, <code>\@return</code>, or 
#         <code>\@returns</code> tag in the HeaderDoc comment.
#  */
sub result {
    my $self = shift;
    
    if (@_) {
        $self->{RESULT} = shift;
    }
    return filterHeaderDocTagContents($self->{RESULT});
}


# /*!
#     @abstract
#         Gets/sets type conversion history.
#     @discussion
#         In {@link blockParseOutside}, when you request a
#         specific type (e.g <code>\@function</code>), an object of that
#         type is generated.  If the resulting declaration
#         should be allowed to match against that type, a
#         conversion occurs, in which a new object of a
#         different type is created with the same contents.
#         
#         When a conversion occurs, this function records the
#         original requested type for later use.
#     @param self
#         The <code>HeaderElement</code> object.  This is
#         actually applied to the original (pre-conversion)
#         <code>HeaderElement</code> object, but since the
#         underlying keys are copied to the new object,
#         it "just works".
#     @param origtype
#         The new value to set.  (Optional.)
#  */
sub origType
{
    my $self = shift;
    
    if (@_) {
        my $origtype = shift;
        $self->{ORIGTYPE} = $origtype;
	# print STDERR "Set original type to $origtype\n";
    }
    return $self->{ORIGTYPE};
}


# /*!
#     @abstract
#         Maintains the list of auto-related references used for
#         mixed group handling.
#     @discussion
#         When you have a mixed block containing functions and
#         defines, the <code>INCLUDED_DEFINES</code> array ceases to be a
#         workable way to find out what is in that block.  This
#         function stores and retrieves an array containing
#         <b>only</b> the API references (UIDs) for machine-generated
#         "See Also" cross-references.
#  */
sub autoRelate
{
    my $self = shift;
    
    my @ar = ();
    if ($self->{AUTORELATE}) {
	@ar = @{$self->{AUTORELATE}};
    }

    if (@_) {
	my $newvalue = shift;
	my @parts = split(/\s+/, $newvalue);

	push(@ar, $parts[1]);
    }

    $self->{AUTORELATE} = \@ar;
    return $self->{AUTORELATE};
}

# /*!
#     @abstract
#         Stores a backup copy of the abstract and discussion
#         for later use or checks to see if one has been stored.
#     @param self
#         The <code>HeaderElement</code> object to modify.
#     @param set
#         If a second parameter is specified, a backup is made.
#     @result
#         Returns whether the discussion has been backed up or not.
#     @discussion
#         Used when parsing <code>\@defineblock</code> blocks to restore
#         the discussion and abstract of the block.
#  */
sub discussionLocked
{
    my $self = shift;

    if (@_) {
	$self->{DISCUSSIONLOCKED} = $self->{DISCUSSION};
	$self->{ABSTRACTLOCKED} = $self->{ABSTRACT};
	$self->{DISCUSSION_SETLOCKED} = $self->{DISCUSSION_SET};
    }
    return $self->{DISCUSSIONLOCKED} ? 1 : 0;
}

# /*!
#     @abstract
#         Restores a backup copy of the abstract and discussion
#         stored by {@link discussionLocked}.
#     @param self
#         The <code>HeaderElement</code> object to modify.
#     @discussion
#         Used when parsing <code>\@defineblock</code> blocks to restore
#         the discussion and abstract of the block.
#  */
sub unlockDiscussion
{
    my $self = shift;

    $self->{DISCUSSION} = $self->{DISCUSSIONLOCKED};
    $self->{ABSTRACT} = $self->{ABSTRACTLOCKED};
    $self->{DISCUSSION_SET} = $self->{DISCUSSION_SETLOCKED};
}

# /*!
#     @abstract
#         Wipes the discussion and abstract so that
#         defines in a <code>\@defineblock</code> can be
#         correctly parsed.
#     @param self
#         The <code>HeaderElement</code> object to modify.
#  */
sub prepareDiscussionForTemporary
{
    my $self = shift;

    $self->{DISCUSSION} = undef;
    $self->{ABSTRACT} = undef;
    $self->{DISCUSSION_SET} = undef;
}

# /*!
#     @abstract
#         Clones a function object for use as an API owner for any
#         enclosing scripts.
#  */
sub cloneAppleScriptFunctionContents
{
    my $self = shift;

    my $localDebug = 0;

    if ($localDebug) {
	print STDERR "Cloning $self for AppleScript function body parsing.\n";
	$self->dbprint();
    }

    my $class_self = HeaderDoc::CPPClass->new();
    $self->{AS_CLASS_SELF} = \$class_self;
    $class_self->{AS_FUNC_SELF} = \$self;

    my $orig_ptref = $self->{PARSETREE};
    bless($orig_ptref, "HeaderDoc::ParseTree");
    my $parseTree = ${$orig_ptref};

    $parseTree = $parseTree->ASFunctionBodyStart();

    my $tree = $parseTree->clone();
    $tree->parserState($self->{PARSERSTATE});

    # Don't copy the name here, because it hasn't been set yet, but copy
    # the parse tree, because otherwise it gets stomped.
    $class_self->{PARSETREE} = \$tree;
    $class_self->{PARSERSTATE} = $self->{PARSERSTATE};
    $class_self->{SUBLANG} = $self->{SUBLANG};
    $class_self->{APIOWNER} = $self->{APIOWNER};
    $class_self->{FILENAME} = $self->{FILENAME};
    $class_self->{FULLPATH} = $self->{FULLPATH};
    $class_self->{OUTPUTFORMAT} = $self->{OUTPUTFORMAT};

    print STDERR "NAME: ".$class_self->name()."\n" if ($localDebug);
    print STDERR "RAWNAME: ".$class_self->rawname()."\n" if ($localDebug);
    print STDERR "TREE: $tree\n" if ($localDebug);

    $tree->apiOwner($class_self);
}

# /*!
#     @abstract
#         Processes the cloned function/class object previously
#         created by the {@link cloneAppleScriptFunctionContents}
#         method.
#  */
sub processAppleScriptFunctionContents
{
    my $self = shift;
    my $localDebug = 0;

    print STDERR "IN processAppleScriptFunctionContents\n" if ($localDebug);
    $self->dbprint() if ($localDebug);

    # Grab the class object that contains the parsed contents of the function body.
    my $class_self_ref = $self->{AS_CLASS_SELF};
    if (!$class_self_ref) {
	die("Missing AS_CLASS_SELF for $self (".$self->name().")\n");
    }
    my $class_self = ${$class_self_ref};
    bless($class_self, "HeaderDoc::HeaderElement");
    bless($class_self, $class_self->class());

    # Copy the name and other info, now that it is known.
    $class_self->{NAME} = $self->{NAME};
    $class_self->{RAWNAME} = $self->{RAWNAME};
    $class_self->{FORCENAME} = $self->{FORCENAME};
    $class_self->{NAMEREFS} = $self->{NAMEREFS};
    $class_self->{LANG} = $self->{LANG};
    $class_self->{OUTPUTFORMAT} = $self->{OUTPUTFORMAT};

    # Determine the output mode.
    my $xml_output = 0;
    my $apiOwner = $self->apiOwner();
    if ($apiOwner->outputformat() eq "hdxml") { $xml_output = 1; }

    my $apioclass = ref($apiOwner) || $apiOwner;

    if ($apioclass =~ /HeaderDoc::Header/) {
	$class_self->{HEADEROBJECT} = $apiOwner;
    } else {
	$class_self->{HEADEROBJECT} = $apiOwner->{HEADEROBJECT};
    }


    print STDERR "OF: ".$apiOwner->outputformat()."\n" if ($localDebug);

    # Obtain the parse tree.
    my $ptref = $class_self->{PARSETREE};
    bless($ptref, "HeaderDoc::ParseTree");
    my $parseTree = ${$ptref};

    # Process the embedded tags and write out the contents.
    $parseTree->processEmbeddedTags($xml_output, $class_self);

    # print STDERR "PROCESSED ".$class_self->name()."\n";
    my @has_classes = $class_self->classes();
    # print STDERR "WRITING ".scalar(@has_classes)." CLASSES\n";
    if (!scalar(@has_classes)) {
	return undef;
    }

    # Compute the name of the directory where the contents should be written (in HTML mode)
    if (!$xml_output) {
	my $className = $class_self->name();
	# for now, always shorten long names since some files may be moved to a Mac for browsing
	if (1 || $isMacOS) {$className = &safeName(filename => $className);};
	$className = "parsedFunctionContents_$className";

	# my $classesDir = $self->apiOwner()->classesDir();

	# if (!$HeaderDoc::running_test) {
		# if (! -e $classesDir) {
			# unless (mkdir ("$classesDir", 0777)) {die ("Can't create output folder $classesDir. \n$!");};
		# }
	# }

	my $classRootDir = $self->apiOwner()->{OUTPUTDIR};
	$class_self->outputDir("$classRootDir$pathSeparator$className");
	$class_self->{PARSEDPSEUDOCLASSNAME} = $className;
    }

    # Write the output (in HTML mode)
    if (!$xml_output) {
	if ($class_self->classes()) {
		print STDERR "CLASSES\n" if ($localDebug);
		if (!$HeaderDoc::running_test) {
			$class_self->writeHeaderElements();
		}
	} else {
		print STDERR "NO CLASSES\n" if ($localDebug);
	}
    }
    $self->{ASCONTENTSPROCESSED} = 1;

    $parseTree->dbprint() if ($localDebug);

    return $class_self;
}


1;

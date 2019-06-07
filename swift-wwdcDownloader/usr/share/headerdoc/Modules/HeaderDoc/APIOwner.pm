#! /usr/bin/perl -w
#
# Class name: APIOwner
# Synopsis: Abstract superclass for Header and OO structures
#
# Last Updated: $Date: 2014/02/25 14:46:13 $
# 
# Method additions by SKoT McDonald <skot@tomandandy.com> Aug 2001 
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
#         <code>APIOwner</code> class package file.
#     @discussion
#         This file contains the <code>APIOwner</code> class, which is
#         the base class for any API construct that contains functions
#         or methods (e.g. headers, modules, classes, protocols,
#         categories, packages, etc.).
#
#         See the class documentation below for more details.
#     @indexgroup HeaderDoc API Objects
#  */

# /*!
#   @abstract
#     Intermediate API object base class for classes, headers, packages,
#     namespaces, and so on.
#
#   @discussion
#     The <code>APIOwner</code> class is the base class for API symbol
#     types that contain other symbols (not counting constants or fields
#     in structs, enums, and typedefs).
#
#     This class is a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}.  
#
#     This class is subclassed by
#     {@link //apple_ref/perl/cl/HeaderDoc::Header Header},
#     {@link //apple_ref/perl/cl/HeaderDoc::CPPClass CPPClass}
#     (classes in all languages except Objective-C), and
#     {@link //apple_ref/perl/cl/HeaderDoc::ObjCContainer ObjCContainer}
#     (which is, in turn, subclassed by
#     {@link //apple_ref/perl/cl/HeaderDoc::ObjCClass ObjCClass},
#     {@link //apple_ref/perl/cl/HeaderDoc::ObjCCategory ObjCCategory}, and 
#     {@link //apple_ref/perl/cl/HeaderDoc::ObjCProtocol ObjCProtocol}).
#
#     This API object type should never actually be emitted as output; only
#     its subclasses are relevant.
#
#     @var ALSOINCLUDE
#         Contains an array of names of functions to "also include" in
#         the documentation for this class/pseudoclass.  Mainly intended
#         for applying class-like behavior to procedural languages.
#     @var APPLEREFUSED
#         A reference to a hash containing API references that have been
#         emitted already in the context of this API owner.  This is
#         needed so that it can be reset if a class is re-emitted (after
#         category folding, for example).
#     @var CATEGORIES
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCCategory ObjCCategory}
#         objects within this class or header.
#     @var CATEGORIESDIR
#         The directory where output will be written for categories
#         within this header.  Set by {@link outputDir}.
#     @var CCLASS
#         Set to 1 for a C pseudoclass, else 0.
#     @var CLASSES
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::CPPClass CPPClass} or
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCClass ObjCClass}
#         objects within this class or header.
#     @var CLASSESDIR
#         The directory where output will be written for classes
#         within this header.  Set by {@link outputDir}.
#     @var CONSTANTSDIR
#         The directory where output will be written for constants
#         within this header.  Set by {@link outputDir}.
#     @var CURRENTCLASS
#         The last class added to this header (or class) object.
#         See {@link currentClass}.
#     @var DATATYPESDIR
#         The directory where output will be written for data types
#         within this header.  Set by {@link outputDir}.
#     @var ENCODING
#         The character encoding (guessed) for this header.
#     @var ENUMS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::Enum Enum}
#         objects within this class or header.
#     @var ENUMSDIR
#         The directory where output will be written for enumerations
#         within this header.  Set by {@link outputDir}.
#     @var EXPLICITSUPER
#         Set to 1 if the superclass is specified explicitly with
#         the <code>\@superclass</code> tag.  See {@link explicitSuper}.
#     @var EXPORTINGFORDB
#         Deprecated.
#     @var EXPORTSDIR
#         The directory where output will be written for database exports
#         from this header.  Set by {@link outputDir}.  Unused.
#     @var FUNCTIONGROUPSTATE
#         Used during embedded markup processing to keep track of the most
#         recent <code>\@functiongroup</code> or <code>\@methodgroup</code>
#         tag value.
#     @var FUNCTIONS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::Function Function}
#         objects within this class or header.
#     @var FUNCTIONSDIR
#         The directory where output will be written for functions
#         within this header.  Set by {@link outputDir}.
#     @var GROUPS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::Group Group}
#         objects within this class or header.
#     @var HEADEROBJECT
#         The {@link //apple_ref/perl/cl/HeaderDoc::Header Header}
#         object for the header that contains this class.  (For a
#         header, this points to itself.)  See {@link headerObject}.
#     @var ISFRAMEWORK
#         Set to 1 if this object resulted from an <code>\@framework</code>
#         tag, else 0.
#     @var ISMERGED
#         Set to 1 if this the superclass members have been merged
#         into this class (if applicable), else 0.  See {@link isMerged}.
#     @var ISMODULE
#         Set to 1 if this class is actually a module in IDL.  See {@link isModule}.
#     @var METHODS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::Method Method}
#         objects within this class or header.
#     @var METHODSDIR
#         The directory where output will be written for methods
#         within this header.  Set by {@link outputDir}.
#     @var OUTPUTDIR
#         The output directory for this header.  Set by {@link outputDir}.
#     @var PDEFINES
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::PDefine PDefine}
#         objects within this class or header.
#     @var PDEFINESDIR
#         The directory where output will be written for <code>#define</code>
#         macros within this header.  Set by {@link outputDir}.
#     @var PROPS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::Var Var} property
#         objects within this class or header.
#     @var PROPSDIR
#         The directory where output will be written for properties
#         within this header.  Set by {@link outputDir}.
#     @var PROTOCOLS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::ObjCProtocol ObjCProtocol}
#         objects within this class or header.
#     @var PROTOCOLSDIR
#         The directory where output will be written for protocols
#         within this header.  Set by {@link outputDir}.
#     @var STRUCTS
#         An array of 
#         {@link //apple_ref/perl/cl/HeaderDoc::Struct Struct}
#         objects within this class or header.
#     @var STRUCTSDIR
#         The directory where output will be written for structs
#         within this header.  Set by {@link outputDir}.
#     @var TOCTITLEPREFIX
#         The prefix that precedes the name of the header or file
#         in the left-side table of contents.  See {@link tocTitlePrefix}.
#     @var TYPEDEFS
#         An array of
#         {@link //apple_ref/perl/cl/HeaderDoc::Typedef Typedef}
#         objects within this class or header.
#     @var TYPEDEFSDIR
#         The directory where output will be written for typedefs
#         within this header.  Set by {@link outputDir}.
#     @var UNSORTED
#         Stores whether the TOC for this API owner object should be
#         displayed without sorting.  Use {@link unsorted} to access
#         this variable.
#     @var VARSDIR
#         The directory where output will be written for variables
#         within this header.  Set by {@link outputDir}.
#  */
package HeaderDoc::APIOwner;

BEGIN {
	foreach (qw(Mac::Files)) {
	    $MOD_AVAIL{$_} = eval "use $_; 1";
    }
}
use HeaderDoc::HeaderElement;
use HeaderDoc::Group;
use HeaderDoc::Utilities qw(findRelativePath safeName getAPINameAndDisc printArray printHash resolveLink sanitize dereferenceUIDObject validTag objName byLinkage byAccessControl objGroup linkageAndObjName byMethodType html_fixup_links xml_fixup_links calcDepth);
use HeaderDoc::BlockParse qw(blockParseOutside);
use File::Basename;
use Cwd;
use Carp qw(cluck);

use strict;
use vars qw(@ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::APIOwner::VERSION = '$Revision: 1393368373 $';

my $addToDebug = 0;

# Inheritance
@ISA = qw(HeaderDoc::HeaderElement);
################ Portability ###################################
my $isMacOS;
my $pathSeparator;
if ($^O =~ /MacOS/io) {
	$pathSeparator = ":";
	$isMacOS = 1;
} else {
	$pathSeparator = "/";
	$isMacOS = 0;
}
################ General Constants ###################################
my $debugging = 0;
my $theTime = time();
my ($sec, $min, $hour, $dom, $moy, $year, @rest);
($sec, $min, $hour, $dom, $moy, $year, @rest) = localtime($theTime);
# $moy++;
$year += 1900;
my $dateStamp = HeaderDoc::HeaderElement::strdate($moy, $dom, $year, "UTF-8");
######################################################################



# class variables and accessors
{
    my $_copyrightOwner;
    my $_defaultFrameName;
    my $_compositePageName;
    my $_htmlHeader;
    my $_htmlFooter;
    my $_apiUIDPrefix;
    # my $_headerObject;
    
    # /*! @abstract
    #         Gets/sets the copyright owner for the header,
    #         specified by the <code>\@copyright</code> field.
    #     @param class
    #         The <code>APIOwner</code> class object.
    #     @param _copyrightOwner
    #         The new owner. (Optional)
    #  */
    sub copyrightOwner {    
        my $class = shift;
        if (@_) {
            $_copyrightOwner = shift;
        }
        return $_copyrightOwner;
    }

    # /*! @abstract
    #         Gets/sets the value of the <code>defaultFrameName</code>
    #         field in the HeaderDoc config file.
    #     @param class
    #         The <code>APIOwner</code> class object.
    #     @param _defaultFrameName
    #         The new filename. (Optional)
    #  */
    sub defaultFrameName {    
        my $class = shift;
        if (@_) {
            $_defaultFrameName = shift;
        }
        return $_defaultFrameName;
    }

    # /*!
    #   @abstract
    #     Gets/sets the filename that should be used for the composite page.
    #
    #   @discussion
    #     In the default mode (iframe output), this returns the default
    #     frame name.
    #
    #     This returns the value of the <code>compositePageName</code>
    #     field in the HeaderDoc config file if iframe output
    #     is disabled.
    #     @param class
    #         The <code>APIOwner</code> class object.
    #     @param _compositePageName
    #         The new filename. (Optional)
    #  */
    sub compositePageName {    
        my $class = shift;
        if (@_) {
            $_compositePageName = shift;
        }
	if ($HeaderDoc::use_iframes) {
	    return $class->defaultFrameName(); # index.html
	}
        return $_compositePageName;
    }

    # /*! @abstract
    #         Gets/sets the value of the <code>htmlHeader</code>
    #         field in the HeaderDoc config file.
    #     @param self
    #         The <code>APIOwner</code> class object.
    #     @param _htmlHeader
    #         The new HTML header bits. (Optional)
    #  */
    sub htmlHeader {
        my $self = shift;

        if (@_) {
            $_htmlHeader = shift;
	    $_htmlHeader =~ s/{\@docroot}/\@\@docroot/sg;
        }

	if ($self eq "HeaderDoc::APIOwner") { return $_htmlHeader; }

	if ($self->outputformat eq "hdxml") {
		return xml_fixup_links($self, $_htmlHeader);
	} else {
		return html_fixup_links($self, $_htmlHeader);
	}
    }

    # /*! @abstract
    #         Gets/sets the value of the <code>htmlFooter</code>
    #         field in the HeaderDoc config file.
    #     @param self
    #         The <code>APIOwner</code> class object.
    #     @param _htmlFooter
    #         The new HTML footer bits. (Optional)
    #  */
    sub htmlFooter {
        my $self = shift;

        if (@_) {
            $_htmlFooter = shift;
	    $_htmlFooter =~ s/{\@docroot}/\@\@docroot/sg;
        }

	if ($self eq "HeaderDoc::APIOwner") { return $_htmlFooter; }

	if ($self->outputformat eq "hdxml") {
		return xml_fixup_links($self, $_htmlFooter);
	} else {
		return html_fixup_links($self, $_htmlFooter);
	}
    }

    # /*! @abstract
    #         Gets/sets the value of the <code>apiUIDPrefix</code>
    #         field in the HeaderDoc config file.
    #     @param class
    #         The <code>APIOwner</code> class object.
    #     @param _apiUIDPrefix
    #         The new prefix. (Optional)
    #  */
    sub apiUIDPrefix {    
        my $class = shift;
        if (@_) {
            $_apiUIDPrefix = shift;
        }
        return $_apiUIDPrefix;
    }
}

# /*!
#     @abstract
#         Gets/sets the header containing a class, category, protocol, etc.
#     @discussion
#         Returns a reference to the header associated with a class, category, protocol,
#         or other API-owning structure.  For a header, returns a reference to itself.
#     @param class
#         The <code>APIOwner</code> class object.
#     @param headerObject
#         The new object. (Optional)
#  */
sub headerObject {
	my $class = shift;

	if (@_) {
            $class->{HEADEROBJECT} = shift;
	}
	return $class->{HEADEROBJECT};
}

# /*!
#     @abstract
#         Updates the dateStamp global variable.
#  */
sub fix_date($)
{
    my $encoding = shift;
    $dateStamp = HeaderDoc::HeaderElement::strdate($moy, $dom, $year, $encoding);

    # print STDERR "fixed date stamp.\n";
    return $dateStamp;
}

# /*!
#     @abstract
#         Initializes an instance of an <code>APIOwner</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;

    $self->SUPER::_initialize();
    
    # $self->{OUTPUTDIR} = undef;
    $self->{CONSTANTS} = ();
    $self->{FUNCTIONS} = ();
    $self->{METHODS} = ();
    $self->{TYPEDEFS} = ();
    $self->{STRUCTS} = ();
    $self->{VARS} = ();
    $self->{PDEFINES} = ();
    $self->{ENUMS} = ();
    # $self->{CONSTANTSDIR} = undef;
    # $self->{DATATYPESDIR} = undef;
    # $self->{STRUCTSDIR} = undef;
    # $self->{VARSDIR} = undef;
    # $self->{PROPSDIR} = undef;
    # $self->{FUNCTIONSDIR} = undef;
    # $self->{METHODSDIR} = undef;
    # $self->{PDEFINESDIR} = undef;
    # $self->{ENUMSDIR} = undef;
    # $self->{EXPORTSDIR} = undef;
    # $self->{EXPORTINGFORDB} = 0;
    $self->{TOCTITLEPREFIX} = 'GENERIC_OWNER:';
    # $self->{HEADEROBJECT} = undef;
    $self->{NAMESPACE} = "";
    $self->{UPDATED} = "";
    $self->{EXPLICITSUPER} = 0;
    $self->{CLASSES} = ();
    $self->{ISFRAMEWORK} = 0;
    $self->{ISMERGED} = 0;
    $self->{CCLASS} = 0;
    $self->{HEADEROBJECT} = 0;
    # $self->{ENCODING} = undef;
    $self->{CLASS} = "HeaderDoc::APIOwner";
    my %groups = ();
    $self->{GROUPS} = \%groups;
} 

# /*!
#     @abstract
#         Duplicates this <code>APIOwner</code> object into another one.
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
	$clone = HeaderDoc::APIOwner->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    }

    $self->SUPER::clone($clone);

    # now clone stuff specific to API owner

    $clone->{OUTPUTDIR} = $self->{OUTPUTDIR};
    $clone->{CONSTANTS} = ();
    if ($self->{CONSTANTS}) {
        my @params = @{$self->{CONSTANTS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{CONSTANTS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{FUNCTIONS} = ();
    if ($self->{FUNCTIONS}) {
        my @params = @{$self->{FUNCTIONS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{FUNCTIONS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{METHODS} = ();
    if ($self->{METHODS}) {
        my @params = @{$self->{METHODS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{METHODS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{TYPEDEFS} = ();
    if ($self->{TYPEDEFS}) {
        my @params = @{$self->{TYPEDEFS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{TYPEDEFS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{STRUCTS} = ();
    if ($self->{STRUCTS}) {
        my @params = @{$self->{STRUCTS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{STRUCTS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{VARS} = ();
    if ($self->{VARS}) {
        my @params = @{$self->{VARS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{VARS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{PDEFINES} = ();
    if ($self->{PDEFINES}) {
        my @params = @{$self->{PDEFINES}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{PDEFINES}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }
    $clone->{ENUMS} = ();
    if ($self->{ENUMS}) {
        my @params = @{$self->{ENUMS}};
        foreach my $param (@params) {
            my $cloneparam = $param->clone();
            push(@{$clone->{ENUMS}}, $cloneparam);
            $cloneparam->apiOwner($clone);
	}
    }

    $clone->{CONSTANTSDIR} = $self->{CONSTANTSDIR};
    $clone->{DATATYPESDIR} = $self->{DATATYPESDIR};
    $clone->{STRUCTSDIR} = $self->{STRUCTSDIR};
    $clone->{VARSDIR} = $self->{VARSDIR};
    $clone->{PROPSDIR} = $self->{PROPSDIR};
    $clone->{FUNCTIONSDIR} = $self->{FUNCTIONSDIR};
    $clone->{METHODSDIR} = $self->{METHODSDIR};
    $clone->{PDEFINESDIR} = $self->{PDEFINESDIR};
    $clone->{ENUMSDIR} = $self->{ENUMSDIR};
    $clone->{EXPORTSDIR} = $self->{EXPORTSDIR};
    $clone->{EXPORTINGFORDB} = $self->{EXPORTINGFORDB};
    $clone->{TOCTITLEPREFIX} = $self->{TOCTITLEPREFIX};
    $clone->{HEADEROBJECT} = $self->{HEADEROBJECT};
    $clone->{NAMESPACE} = $self->{NAMESPACE};
    $clone->{UPDATED} = $self->{UPDATED};
    $clone->{EXPLICITSUPER} = $self->{EXPLICITSUPER};
    $clone->{CLASSES} = $self->{CLASSES};
    $clone->{ISFRAMEWORK} = $self->{ISFRAMEWORK};
    $clone->{ISMERGED} = $self->{ISMERGED};
    $clone->{CCLASS} = $self->{CCLASS};
    $clone->{ENCODING} = $self->{ENCODING};
    $clone->{HEADEROBJECT} = $self->{HEADEROBJECT} = 0;

    return $clone;
}


# /*! @abstract
#         Indicates whether the class is a C pseudoclass.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub CClass
{
    my $self = shift;
    if (@_) {
	$self->{CCLASS} = shift;
    }
    return $self->{CCLASS};
}


# /*!
#     @abstract
#         Returns the class type for the block parser.
#     @discussion
#         Returns the class type in a form that the block parser
#         needs when handling the enclosed elements.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub classType
{
    my $self = shift;
    my $type = $self->{CLASS};

    if ($type =~ /CPPClass/) {
	if ($self->CClass()) { return "C"; }
	return $self->sublang();
    } elsif ($type =~ /ObjCProtocol/) {
	return "intf";
    } elsif ($type =~ /ObjCCategory/) {
	return "occCat";
    } elsif ($type =~ /ObjCClass/) {
	return "occ";
    } else {
	warn "Couldn't determine my own class type....\n";
    }
}


# /*!
#     @abstract
#         Returns whether the class is a COM interface.
#     @discussion
#         Returns 1 if the class is a COM interface (a C pseudoclass
#         marked with the <code>\@interface</code> tag).  Overridden in the <code>CPPClass</code>
#         class.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub isCOMInterface
{
    return 0;
}


# /*!
#     @abstract
#         Returns whether an object is an <code>APIOwner</code> (or subclass thereof).
#     @discussion
#         Overrides the <code>isAPIOwner</code> method in the HeaderElement class.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub isAPIOwner
{
    return 1;
}


# /*!
#     @abstract
#         Get/set whether superclass was specified in comment
#     @discussion
#         If the superclass is explicitly specified in the markup
#         with an <code>\@superclass</code> tag, it means that the user wants
#         to include the functions, data types, etc. from the
#         superclass in the subclass's documentation where possible.
#     @param self
#         The <code>APIOwner</code> object.
#     @param value
#         The value to set. (Optional)
#  */
sub explicitSuper
{
    my $self = shift;
    if (@_) {
	my $value = shift;
	$self->{EXPLICITSUPER} = $value;
    }
    return $self->{EXPLICITSUPER};
}

# /*!
#     @abstract
#         Get/set whether this class has had its superclass's members
#         merged in yet (if applicable)
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub isMerged
{
    my $self = shift;

    if (@_) {
	my $value = shift;
	$self->{ISMERGED} = $value;
    }

    return $self->{ISMERGED};
}

# /*!
#     @abstract
#         Get/set whether this file contains framework documentation
#     @discussion
#         This function returns true if the <code>APIOwner</code> object is a
#         Header object and the underlying file is a .hdoc file
#         containing an <code>\@framework</code> tag.
#     @param self
#         The <code>APIOwner</code> object.
#     @param value
#         The value to set. (Optional)
#  */
sub isFramework
{
    my $self = shift;

    if (@_) {
	my $value = shift;
	$self->{ISFRAMEWORK} = $value;
    }

    return $self->{ISFRAMEWORK};
}

# /*!
#     @abstract
#         Gets/sets whether this class is a real class or a module
#     @param self
#         The <code>APIOwner</code> object.
#     @param value
#         The value to set. (Optional)
#  */
sub isModule
{
    my $self = shift;

    if (@_) {
	my $value = shift;
	$self->{ISMODULE} = $value;
	$self->noRegisterUID($value);
    }

    return $self->{ISMODULE};
}

# /*!
#     @abstract
#         Gets/sets the array of classes within this header (or
#         enclosing class).
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The array value to set. (Optional)
#  */
sub classes
{
    my $self = shift;
    if (@_) {
        @{ $self->{CLASSES} } = @_;
    }
    ($self->{CLASSES}) ? return @{ $self->{CLASSES} } : return ();
}

# /*! 
#   @abstract
#     Returns whether the header contains a class with a given name.
#   @discussion
#     Used by the BlockParse code to check to see if a header contains
#     a particular class.  This is so that C++ methods outside the
#     class braces (in a .cpp file) can be merged into the class.
#
#     This could probably be replaced by a global symbol lookup for
#     the class object now.
#   @param name
#     The class name to look for.
#  */
sub findClass {
    my $self = shift;
    my $name = shift;

    foreach my $class (@{ $self->{CLASSES} }) {
	if ($class->name() eq $name) {
		return $class;
	}
    }
    return undef;
}

# /*! @abstract
#         Gets/sets the path to the directory where protocol output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Protocols.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub protocolsDir {
    my $self = shift;

    if (@_) {
        $self->{PROTOCOLSDIR} = shift;
    }
    return $self->{PROTOCOLSDIR};
}

# /*! @abstract
#         Gets/sets the array of protocols that are enclosed in this header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The array value to set. (Optional)
#  */
sub protocols {
    my $self = shift;
    
    if (@_) {
        @{ $self->{PROTOCOLS} } = @_;
    }
    ($self->{PROTOCOLS}) ? return @{ $self->{PROTOCOLS} } : return ();
}

# /*! @abstract
#         Adds a protocol associated with this header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The {@link //apple_ref/perl/cl/HeaderDoc::ObjCProtocol HeaderDoc::ObjCProtocol}
#         objects to add.
#  */
sub addToProtocols {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO PROTOCOLS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{PROTOCOLS} }, $item);
        }
    }
    return @{ $self->{PROTOCOLS} };
}

# /*! @abstract
#         Gets/sets the path to the directory where category output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Categories.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub categoriesDir {
    my $self = shift;

    if (@_) {
        $self->{CATEGORIESDIR} = shift;
    }
    return $self->{CATEGORIESDIR};
}

# /*! @abstract
#         Gets/sets the array of categories that are enclosed in this header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The array value to set. (Optional)
#  */
sub categories {
    my $self = shift;

    if (@_) {
        @{ $self->{CATEGORIES} } = @_;
    }
    ($self->{CATEGORIES}) ? return @{ $self->{CATEGORIES} } : return ();
}

# /*! @abstract
#         Adds a category associated with this header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The {@link //apple_ref/perl/cl/HeaderDoc::ObjCCategory HeaderDoc::ObjCCategory} objects to add.
#  */
sub addToCategories {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO CATEGORIES\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{CATEGORIES} }, $item);
        }
    }
    return @{ $self->{CATEGORIES} };
}

# /*!
#   @abstract
#     Removes a maximum of one category per invocation.
#   @discussion
#     A category gets removed if the higher level code successfully finds
#     the associated class and adds the category methods to it.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The category to remove. (Optional)
#  */
sub removeFromCategories {
    my $self = shift;
    my $objToRemove = shift;
    my $nameOfObjToRemove = $objToRemove->name();
    my @tempArray;
    my @categories = $self->categories();
    my $localDebug = 0;
    
    if (!@categories) {return;};

	foreach my $obj (@categories) {
	    if (ref($obj) eq "HeaderDoc::ObjCCategory") { 
			my $fullName = $obj->name();
			if ($fullName ne $nameOfObjToRemove) {
				push (@tempArray, $obj);
			} else {
				print STDERR "Removing $fullName from Header object.\n" if ($localDebug);
			}
		}
	}
	# we set it directly since the accessor will not allow us to set an empty array
	@{ $self->{CATEGORIES} } = @tempArray;
}

### # /*!
### #     @abstract
###           Returns protocols within this header
### #  */
### sub protocols
### {
###     return ();
### }
### 
### # /*!
### #     @abstract
### #         Returns categories within this header
### #  */
### sub categories
### {
###     return ();
### }

# /*!
#     @abstract
#         Adds a class to class list
#     @discussion
#         Both headers and classes can contain classes (in
#         some languages).  This function is used for both cases.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The {@link //apple_ref/perl/cl/HeaderDoc::CPPClass HeaderDoc::CPPClass} objects to add.
#  */
sub addToClasses {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    # print STDERR "FOR OBJECT $self, ADDING TO CLASSES: $item\n";
	    # print STDERR "ref(\$item): ".ref($item)."\n";
	    if ($addToDebug) { print STDERR "ADDED $item TO CLASSES\n"; }
            $self->currentClass($item);
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{CLASSES} }, $item);
        }
    }
    return @{ $self->{CLASSES} };
}

# /*! @abstract
#         Gets/sets the last class added to this header (or class) object.
#     @param self
#         The <code>APIOwner</code> object.
#     @param class
#         The array value to set. (Optional)
#     @discussion
#         Used for debugging purposes when dbprint() is called on
#         the header object during processing.
#  */
sub currentClass {
    my $self = shift;

    if (@_) {
        @{ $self->{CURRENTCLASS} } = @_;
    }
    return @{ $self->{CURRENTCLASS} };
}


# /*! @abstract
#         Gets/sets the current output directory.
#     @discussion
#         This function returns the output directory (usually specified
#         by <code>-o</code> on the command line).
#     @param self
#         The <code>APIOwner</code> object.
#     @param directory
#         The new default output directory. (Optional)
#  */
sub outputDir {
    my $self = shift;

    if (@_) {
        my $rootOutputDir = shift;
	if (!$self->use_stdout() && !$HeaderDoc::running_test) {
		if (-e $rootOutputDir) {
			if (! -d $rootOutputDir) {
			    die "Error: $rootOutputDir is not a directory. Exiting.\n\t$!\n";
			} elsif (! -w $rootOutputDir) {
			    die "Error: Output directory $rootOutputDir is not writable (in APIOwner). Exiting.\n$!\n";
			}
		} else {
			unless (mkdir ("$rootOutputDir", 0777)) {
			    die ("Error: Can't create output folder $rootOutputDir.\n$!\n");
			}
		}
	}
        $self->{OUTPUTDIR} = $rootOutputDir;
	$self->constantsDir("$rootOutputDir$pathSeparator"."Constants");
	$self->datatypesDir("$rootOutputDir$pathSeparator"."DataTypes");
	$self->structsDir("$rootOutputDir$pathSeparator"."Structs");
	$self->functionsDir("$rootOutputDir$pathSeparator"."Functions");
	$self->methodsDir("$rootOutputDir$pathSeparator"."Methods");
	$self->varsDir("$rootOutputDir$pathSeparator"."Vars");
	$self->propsDir("$rootOutputDir$pathSeparator"."Properties");
	$self->pDefinesDir("$rootOutputDir$pathSeparator"."PDefines");
	$self->enumsDir("$rootOutputDir$pathSeparator"."Enums");
	$self->classesDir("$rootOutputDir$pathSeparator"."Classes");
	$self->classesDir("$rootOutputDir$pathSeparator"."Classes");
	$self->protocolsDir("$rootOutputDir$pathSeparator"."Protocols");
	$self->categoriesDir("$rootOutputDir$pathSeparator"."Categories");
    }
    return $self->{OUTPUTDIR};
}

# /*!
#     @abstract
#         Gets/sets the prefix for the title line in the left-side TOC.
#     @discussion
#         Returns <code>Header:</code>, <code>Class:</code>, etc. (with a
#         trailing space), depending on the type of object it is called on.
#         This string is emitted before the name of the header, class, etc.
#         in the table of contents (left column).
#
#         This value is set by the <code>_initialize</code> routine in
#         each subclass.
#     @param self
#         The <code>APIOwner</code> object.
#     @param directory
#         The value to set. (Optional)
# */
sub tocTitlePrefix {
    my $self = shift;

    if (@_) {
        $self->{TOCTITLEPREFIX} = shift;
    }
    return $self->{TOCTITLEPREFIX};
}

# /*! @abstract
#         Gets/sets the path to the directory where constant output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Constants.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub constantsDir {
    my $self = shift;

    if (@_) {
        $self->{CONSTANTSDIR} = shift;
    }
    return $self->{CONSTANTSDIR};
}


# /*! @abstract
#         Gets/sets the path to the directory where data type output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/DataTypes.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub datatypesDir {
    my $self = shift;

    if (@_) {
        $self->{DATATYPESDIR} = shift;
    }
    return $self->{DATATYPESDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where struct output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Structs.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub structsDir {
    my $self = shift;

    if (@_) {
        $self->{STRUCTSDIR} = shift;
    }
    return $self->{STRUCTSDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where variable output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Vars.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub varsDir {
    my $self = shift;

    if (@_) {
        $self->{VARSDIR} = shift;
    }
    return $self->{VARSDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where property output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Properties.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub propsDir {
    my $self = shift;

    if (@_) {
        $self->{PROPSDIR} = shift;
    }
    return $self->{PROPSDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where <code>#define</code>
#         output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/PDefines.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSES
#         The value to set. (Optional)
#  */
sub pDefinesDir {
    my $self = shift;

    if (@_) {
        $self->{PDEFINESDIR} = shift;
    }
    return $self->{PDEFINESDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where class output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Classes.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CLASSESDIR
#         The value to set. (Optional)
#  */
sub classesDir {
    my $self = shift;

    if (@_) {
        $self->{CLASSESDIR} = shift;
    }
    return $self->{CLASSESDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where enum output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Enums.
#     @param self
#         The <code>APIOwner</code> object.
#     @param ENUMSDIR
#         The value to set. (Optional)
#  */
sub enumsDir {
    my $self = shift;

    if (@_) {
        $self->{ENUMSDIR} = shift;
    }
    return $self->{ENUMSDIR};
}


# /*! @abstract
#         Gets/sets the path to the directory where function output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Functions.
#     @param self
#         The <code>APIOwner</code> object.
#     @param FUNCTIONSDIR
#         The value to set. (Optional)
#  */
sub functionsDir {
    my $self = shift;

    if (@_) {
        $self->{FUNCTIONSDIR} = shift;
    }
    return $self->{FUNCTIONSDIR};
}

# /*! @abstract
#         Gets/sets the path to the directory where method output should be written.
#     @discussion
#         This always contains [output_directory]/[this_header_directory]/Methods.
#     @param self
#         The <code>APIOwner</code> object.
#     @param METHODSDIR
#         The value to set. (Optional)
#  */
sub methodsDir {
    my $self = shift;

    if (@_) {
        $self->{METHODSDIR} = shift;
    }
    return $self->{METHODSDIR};
}

# /*!
#     @abstract
#         Private function for an Apple-specific output format.
#     @discussion
#         Converts an array into JSON notation.
#     @param optional_bits
#         A reference to the array to emit.
#  */
sub arrayToJSON
{
	my $optional_bits = shift;
	my @bits = @{$optional_bits};
	my $retstring = "";

	foreach my $bit (@bits) {
		my $class = ref($bit) || $bit;
		if ($class =~ /HASH/) {
			$retstring .= "{\n".keysToJSON($bit)."},\n";
		} else {
			$retstring .= "\"$bit\",\n";
		}
	}
	$retstring =~ s/,\n$//s;
	return $retstring;
}

# /*!
#     @abstract
#         Private function for an Apple-specific output format.
#     @discussion
#         Converts a key in an associative array into a JSON key.
#         When you call this, the surrounding JSON array should
#         already be open.
#     @param optional_bits
#         A reference to an array full of keys to emit.
#  */
sub keysToJSON
{
	my $optional_bits = shift;
	my %bits = %{$optional_bits};
	my $retstring = "";

	foreach my $key (keys %bits) {
		my $val = $bits{$key};
		my $class = ref($val) || $val;
		# print "CLASS: $class\n";

		if ($val eq "false") {
			$retstring .= "\"$key\":false,\n";
		} elsif ($val eq "true") {
			$retstring .= "\"$key\":true,\n";
		} elsif ($class =~ /ARRAY/) {
			$retstring .= "\"$key\": [\n".arrayToJSON($val)."\n],\n";
		} elsif ($class =~ /HASH/) {
			$retstring .= "\"$key\": {\n".keysToJSON($val)."\n},\n";
		} else {
			$retstring .= "\"$key\":\"$val\",\n";
		}
	}
	$retstring =~ s/,\n$//s;
	return $retstring;
}

# /*!
#     @abstract
#         Private function for an Apple-specific output format.
#     @discussion
#         Generates a JSON-style table of contents.
#     @param href
#         The section or book link href.
#     @param title
#         The section or book title.
#     @param mode
#         Mode value.  0 means open and close with no contents.
#         1 means open and leave open.  2 means close and add a
#         trailing comma.  3 means close without trailing comma.
#     @param pos
#         Value for the closedAt key.  Useful for debugging
#         this code.
#     @param optional_bits
#         Additional keys to add at the top level of the TOC.
#  */
sub tocJSON
{
	my $href = shift;
	my $title = shift;
	my $mode = shift;
	my $pos = shift;
	my $optional_bits = shift;

	$title =~ s/[\n\r]+/ /sg;

	my $retstring = "";

	my $debugMode = 1;

        if ($title eq "") { $title = "[Uncategorized]"; }

	# cluck("MODE: $mode HREF $href TITLE $title\n");

	my $aref = $href;
	if ($aref =~ /#\/\//) {
		$aref =~ s/^.*#//s;
	} else {
		$aref = "";
	}


	if ($mode == 2 || $mode == 3) {
		# Close contents.

		my $comma = ",";
		if ($mode == 3) { $comma = ""; }

		$retstring .= "]\n";
		$retstring .= ",\"closedAt\":\"$pos\"\n" if ($debugMode);
		$retstring .= "}$comma\n";
	}
	if ($mode == 0 || $mode == 1) {
		# Open it.
		$retstring .= "{\n";
		$retstring .= "\"insertedAt\":\"$pos\",\n" if ($debugMode);
		$retstring .= "\"href\":\"$href\",\n";
		$retstring .= "\"aref\":\"$aref\",\n";
		$retstring .= "\"title\":\"".striptitle($title)."\",\n";
		if ($optional_bits) {
			$retstring .= keysToJSON($optional_bits).",\n";
		}
		$retstring .= "\"sections\": [\n";
	}
	if ($mode == 0) {
		# Close it.
		$retstring .= tocJSON($href, $title, 2, $pos, undef);
	}
	return $retstring;
}

# /*! 
#      @abstract
#         Returns the left-side TOC for the Classes box.
#      @discussion
#      This generates everything under the Classes section of the left-side
#      TOC.
#
#      This is similar to {@link tocStringSub} except that the actual URLs are
#      generated differently because of the HTML structure being linked to.
#  */
sub tocStringSubForClasses
{
    my $self = shift;
    my $head = shift;
    my $groupref = shift;
    my $objref = shift;
    my $compositePageName = shift;
    my $baseref = shift;
    my $composite = shift;
    my $ignore_access = shift;
    my $tag = shift;
    my $newTOC = shift;

    if (!($self->langSupportsAccess())) {
	$ignore_access = 1;
    }

    my $localDebug = 0;
    my $class = ref($self) || $self;
    my @groups = @{$groupref};
    my @objs = @{$objref};

    my $tocString = "";
    my $jumpLabel = "";
    if ($tag && $tag ne "") {
	$jumpLabel = "#HeaderDoc_$tag";
    }

	    my $firstgroup = 1;
		my $preface = "&nbsp;&nbsp;";
		my $entrypreface = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @objs;
		    } else {
			@tempobjs = @objs;
		    }
		    foreach my $obj (@tempobjs) {
			if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid(); # sanitize($name);
			my $safename = &safeName(filename => $name);

			my $class_baseref = $baseref;
			$class_baseref =~ s/{}/\Q$safename\E/g;

	        	if ($self->outputformat eq "hdxml") {
	        	    $tocString .= "XMLFIX<nobr>$entrypreface<a href=\"$class_baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
		        } elsif ($self->outputformat eq "html") {
			    if ($newTOC == 3) {
				$tocString .= tocJSON("$class_baseref#$urlname", $name, 0, "tocStringSubForClasses", undef);
			    } elsif ($newTOC) {
				$tocString .= tocSubEntry("$class_baseref#$urlname", "doc", $name);
			    } elsif ($HeaderDoc::use_iframes) {
	        		$tocString .= "<nobr>$entrypreface<a href=\"$class_baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    } else {
	        		$tocString .= "<nobr>$entrypreface<a href=\"$class_baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    }
			} else {
			}
		    }


    # return $tocString;
    return tocWrapSubEntries("<!-- from class -->".$tocString);
}


# /*! 
#      @abstract
#         Returns the left-side TOC HTML for a set of data types, functions, methods, etc.
#      @discussion
#      This function takes an array of objects and generates the left-side TOC entries for those
#      objects wrapped in appropriate HTML structures.
#
#      This is similar to {@link tocStringSubForClasses} except that
#      the actual URL is generated differently because of the HTML structure.
#  */
sub tocStringSub {
    my $self = shift;
    my $head = shift;
    my $groupref = shift;
    my $objref = shift;
    my $compositePageName = shift;
    my $baseref = shift;
    my $composite = shift;
    my $ignore_access = shift;
    my $tag = shift;
    my $newTOC = shift;

    if (!($self->langSupportsAccess())) {
	$ignore_access = 1;
    }

    my $localDebug = 0;
    my $class = ref($self) || $self;
    my @groups = @{$groupref};
    my @objs = @{$objref};

    my $tocString = "";
    my $jumpLabel = "";
    if ($tag && $tag ne "") {
	$jumpLabel = "#HeaderDoc_$tag";
    }

	    my $tempurl = "";
	    if ($composite) {
	        $tempurl = "$compositePageName$jumpLabel";
	    } else {
	       	$tempurl = "$baseref$jumpLabel";
	    }
	    if ($newTOC) {
		$tocString .= $self->tocHeading($tempurl, $head, "doc");
	    } elsif ($HeaderDoc::use_iframes) {
	       	$tocString .= "<h4><a href=\"$tempurl\" target=\"_top\">$head</a></h4>\n";
	    } else {
	       	$tocString .= "<h4><a href=\"$tempurl\" target=\"doc\">$head</a></h4>\n";
	    }

	    my $firstgroup = 1;
	    foreach my $group (@groups) {
		my $firstaccess = 1;
	        my $done_one = 0;
		print STDERR "Sorting group $group\n" if ($localDebug);

		my @groupobjs = ();
		my @tempobjs = ();
		my @cdobjs = ();
		if (!$self->unsorted()) {
			@tempobjs = sort objName @objs;
		} else {
			@tempobjs = @objs;
		}
		foreach my $obj (@tempobjs) {
		    if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
		    if ($obj->group() eq $group) {
			$done_one = 1;
			if (!!$self->unsorted() || !$obj->constructor_or_destructor()) {
			    push(@groupobjs, $obj);
			} else {
			    push(@cdobjs, $obj);
			}
		    }
		}
		if (!$done_one) {
		    # empty group
		    next;
		}
		my $preface = "&nbsp;&nbsp;";
		my $entrypreface = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
		# if ($done_one) { $tocString .= "&nbsp;<br>" }
		if (!length($group) && ($newTOC != 3)) {
			# $entrypreface = $preface;
		} else {
			if ($newTOC) {
				$tocString .= tocGroup($group, $firstgroup);
			} else {
				$tocString .= "$preface<font size=\"-1\"><i>$group:</i></font><br>";
			}
		}

		my @Cs;
		my @publics;
		my @protecteds;
		my @privates;

              if (!$self->unsorted()) {
                        @tempobjs = sort byAccessControl @groupobjs;
              } else {
                        @tempobjs = @groupobjs;
              }
	      foreach my $obj (@tempobjs) {
		if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
	        my $access = $obj->accessControl();

		$firstgroup = 0;
# print STDERR "ACCESS: $access\n";
	        
	        if ($access =~ /public/o || $ignore_access){
	            push (@publics, $obj);
	        } elsif ($access =~ /protected/o){
	            push (@protecteds, $obj);
	        } elsif ($access =~ /private/o){
	            push (@privates, $obj);
		} elsif ($access eq "") {
		    push (@Cs, $obj);
	        } else {
		    # assume public (e.g. C)
		    push (@publics, $obj);
		}
	      }
	      if (@cdobjs) {
		    $tocString .= "\n";
		    my $tocStringLocal = "";
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @cdobjs;
		    } else {
			@tempobjs = @cdobjs;
		    }
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid(); # sanitize($name);
	        	if ($self->outputformat eq "hdxml") {
	        	    $tocStringLocal .= "XMLFIX<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
		        } elsif ($self->outputformat eq "html") {
			    if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			    } elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    } else {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			    }
			} else {
			}
		    }
		    $tocString .= tocWrapSubEntries("<!-- cdobj -->".$tocStringLocal);
	        }
	      if (@Cs) {
		    $tocString .= "\n";
		    my $tocStringLocal = "";
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @Cs;
		    } else {
			@tempobjs = @Cs;
		    }
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid(); # sanitize($name);
	        	if ($self->outputformat eq "hdxml") {
	        	    $tocStringLocal .= "XMLFIX<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
		        } elsif ($self->outputformat eq "html") {
			    if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			    } elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    } else {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			    }
			} else {
			}
		    }
		    $tocString .= tocWrapSubEntries("<!-- C -->".$tocStringLocal);
	        }
	      if (@publics) {
		if ($class eq "HeaderDoc::Header" || $ignore_access) {
		    if ($newTOC != 3) { $tocString .= "\n"; }
	        } elsif ($self->outputformat eq "hdxml") {
	            $tocString .= "XMLFIX<h5>Public</h5>\n";
	        } elsif ($self->outputformat eq "html") {
		    if ($newTOC) {
	        	$tocString .= $self->tocAccess("Public", $firstaccess);
		    } else {
	        	$tocString .= "<h5 class='hd_tocAccess'>Public</h5>\n";
		    }
		} else {
		}
		$firstaccess = 0;
		my $tocStringLocal = "";
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @publics;
		    } else {
			@tempobjs = @publics;
		    }
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid(); # sanitize($name);
			# if ($urlname eq "") {
				# cluck("Empty urlname!  Object was $obj\n");
			# }
	        	if ($self->outputformat eq "hdxml") {
	        	    $tocStringLocal .= "XMLFIX<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
		        } elsif ($self->outputformat eq "html") {
			    if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			    } elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    } else {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			    }
			} else {
			}
	        }
		$tocString .= tocWrapSubEntries("<!-- public -->".$tocStringLocal);
		if ($newTOC) {
			if (!($class eq "HeaderDoc::Header" || $ignore_access)) {
	        		$tocString .= $self->tocAccessEnd();
			}
		}
	      }
	      if (@protecteds) {
		my $tocStringLocal = "";
		if ($class eq "HeaderDoc::Header" || $ignore_access) {
		    $tocString .= "\n";
	        } elsif ($self->outputformat eq "hdxml") {
	            $tocString .= "XMLFIX<h5>Protected</h5>\n";
	        } elsif ($self->outputformat eq "html") {
		    if ($newTOC) {
	        	$tocString .= $self->tocAccess("Protected", $firstaccess);
		    } else {
	        	$tocString .= "<h5 class='hd_tocAccess'>Protected</h5>\n";
		    }
		} else {
		}
		$firstaccess = 0;
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @protecteds;
		    } else {
			@tempobjs = @protecteds;
		    }
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid(); # sanitize($name);
		        if ($self->outputformat eq "hdxml") {
	        	    $tocStringLocal .= "XMLFIX<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
		        } elsif ($self->outputformat eq "html") {
			    if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			    } elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    } else {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			    }
			} else {
			}
	        }

		$tocString .= tocWrapSubEntries("<!-- protected -->".$tocStringLocal);
		if ($newTOC) {
	        	$tocString .= $self->tocAccessEnd();
		}
	      }
	      if (@privates) {
		if ($class eq "HeaderDoc::Header" || $ignore_access) {
		    $tocString .= "\n";
	        } elsif ($self->outputformat eq "hdxml") {
	            $tocString .= "XMLFIX<h5>Private</h5>\n";
	        } elsif ($self->outputformat eq "html") {
		    if ($newTOC) {
	        	$tocString .= $self->tocAccess("Protected", $firstaccess);
		    } else {
	        	$tocString .= "<h5 class='hd_tocAccess'>Private</h5>\n";
		    }
		} else {
		}
		$firstaccess = 0;
		my $tocStringLocal = "";
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @privates;
		    } else {
			@tempobjs = @privates;
		    }
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid(); # sanitize($name);
	        	if ($self->outputformat eq "hdxml") {
	        	    $tocStringLocal .= "XMLFIX<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
		        } elsif ($self->outputformat eq "html") {
			    if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			    } elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			    } else {
	        		$tocStringLocal .= "<nobr>$entrypreface<a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			    }
			} else {
			}
	        }
		$tocString .= tocWrapSubEntries("<!-- private -->".$tocStringLocal);
		if ($newTOC) {
	        	$tocString .= $self->tocAccessEnd();
		}
	      }
	      # if (!($group eq "")) {
		# $tocString .= "</dd></dl><p>\n";
	      # }
	     $tocString .= $self->tocGroupEnd();
	 }
    if ($newTOC) {
	$tocString .= $self->tocHeadingEnd();
    }

    return $tocString;
}

# /*! @abstract
#         Checks for $name in $array referenced by $arrayref.
#     @param name
#         The name to search for.
#     @param arrayref
#         A reference to the array to search in.
#  */
sub inarray
{
    my $name = shift;
    my $arrayref = shift;

    my @array = @{$arrayref};

    foreach my $arrname (@array) {
	if ($name eq $arrname) { return 1; }
    }

    return 0;
}

# /*! @abstract
#         Generates the HTML for the left-side TOC.
#     @param newTOC
#         Specifies Apple-style TOC (requires external JavaScript and CSS bits).
#     @param arrayref
#         A reference to the array to search in.
#  */
sub tocString {
    my $self = shift;
    my $newTOC = shift;

    if ($self->outputformat() eq "functions") { return ""; }

    my $contentFrameName = $self->filename();
    my @classes = $self->classes();     
    my @protocols = $self->protocols();
    my @categories = $self->categories();
    my $class = ref($self) || $self;

    $contentFrameName =~ s/(.*)\.h/$1/o; 
    $contentFrameName = &safeName(filename => $contentFrameName);  
    $contentFrameName = $contentFrameName . ".html";

    my $composite = $HeaderDoc::ClassAsComposite;

    my $compositePageName = HeaderDoc::APIOwner->compositePageName(); 
    my $defaultFrameName = HeaderDoc::APIOwner->defaultFrameName(); 

    my @funcs = $self->functions();
    my @methods = $self->methods();
    my @constants = $self->constants();
    my @typedefs = $self->typedefs();
    my @structs = $self->structs();
    my @enums = $self->enums();
    my @ALLpDefines = $self->pDefines();
    my @vars = $self->vars();
    my $tocString = "";

    my @properties = $self->props();

    my $baseref = $contentFrameName;
    if ($composite)  {
	$baseref = $compositePageName;
    }

    $tocString .= "<!-- headerDoc TOC style: $newTOC -->\n";

    if ($newTOC) {
	# $tocString .= "<h4><br><nobr><a href=\"$baseref#top\" target=\"doc\">".$HeaderDoc::introductionName."</a></nobr></h4>\n";
	$tocString .= $self->tocEntry("$baseref#top", $HeaderDoc::introductionName);
    } elsif ($HeaderDoc::use_iframes) {
	$tocString .= "<h4><br><nobr><a href=\"$baseref#top\" target=\"_top\">".$HeaderDoc::introductionName."</a></nobr></h4>\n";
    } else {
	$tocString .= "<h4><br><nobr><a href=\"$baseref#top\" target=\"doc\">".$HeaderDoc::introductionName."</a></nobr></h4>\n";
    }

    my @groups = ("");
    my $localDebug = 0;

    my @pDefines = ();
    foreach my $define (@ALLpDefines) {
	if ($define->isInternal() && !$HeaderDoc::document_internal) { next; }

	if (!$define->parseOnly()) {
		push(@pDefines, $define);
	}
    }

    my @objs = ( @funcs, @methods, @constants, @typedefs, @structs, @enums,
	@pDefines, @vars, @properties );
    if (!$self->unsorted()) { @objs = sort objGroup @objs; }
    foreach my $obj (@objs) {

	$obj->apirefSetup(); # Perl ivars haven't been set up yet.

	if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }

	# warn "obj is $obj\n";
	my $group = $obj->group();
	if (!inarray($group, \@groups)) {
		push (@groups, $group);
		if ($localDebug) {
		    print STDERR "Added $group\n";
		    print STDERR "List is:";
		    foreach my $printgroup (@groups) {
			print STDERR " $printgroup";
		    }
		    print STDERR "\n";
		}
	}
    }

    # output list of functions as TOC
    if (@funcs) {
	    my $funchead = "Functions";
	    if ($class ne "HeaderDoc::Header") {
		$funchead = "Member Functions";
	    }
	    my $baseref = "Functions/Functions.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($funchead, \@groups, \@funcs,
		$compositePageName, $baseref, $composite, 0, "functions", $newTOC);
    }
    if (@methods) {
	    # $tocString .= "<h4>Methods</h4>\n";
	    my $baseref = "Methods/Methods.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    if ($newTOC) {
		$tocString .= $self->tocHeading("$baseref#HeaderDoc_methods", "Methods", "doc");
	    } elsif ($HeaderDoc::use_iframes) {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_methods\" target=\"_top\">Methods</a></h4>\n";
	    } else {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_methods\" target=\"doc\">Methods</a></h4>\n";
	    }

	    my $firstgroup = 1;
	    foreach my $group (@groups) {
	        my $done_one = 0;
		my $firstaccess = 1;
		print STDERR "Sorting group $group\n" if ($localDebug);

		my @groupmeths = ();
		my @tempobjs = ();
		if (!$self->unsorted()) {
			@tempobjs = sort objName @methods;
		} else {
			@tempobjs = @methods;
		}
		foreach my $obj (@tempobjs) {
		    if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
		    if ($obj->group() eq $group) {
			$done_one = 1;
			push(@groupmeths, $obj);
		    }
		}
		if (!$done_one) {
		    # empty group
		    next;
		}
		if ($newTOC == 3 || (!($group eq ""))) {
			# if ($done_one) { $tocString .= "&nbsp;<br>" }
			if ($newTOC) {
				$tocString .= tocGroup($group, $firstgroup);
			} else {
				$tocString .= "<dl><dt>&nbsp;&nbsp;<font size=\"-1\"><i>$group:</i><br></font></dt><dd>";
			}
		}

		my @classMethods;
		my @instanceMethods;

	      foreach my $obj (sort byMethodType @groupmeths) {
		if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
	        my $type = $obj->isInstanceMethod();
		$firstgroup = 0;
	        
	        if ($type =~ /NO/o){
	            push (@classMethods, $obj);
	        } elsif ($type =~ /YES/o){
	            push (@instanceMethods, $obj);
	        } else {
		    # assume instanceMethod
		    push (@instanceMethods, $obj);
		}
	      }
	      if (@classMethods) {
		if ($class eq "HeaderDoc::Header") {
		    $tocString .= "\n";
	        } elsif ($self->outputformat eq "html") {
		    if ($newTOC) {
	        	$tocString .= $self->tocAccess("Class Methods", $firstaccess);
		    } else {
	        	$tocString .= "<h5 class='hd_tocAccess'>Class Methods</h5>\n";
		    }
		} else {
		}
		$firstaccess = 0;
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @classMethods;
		    } else {
			@tempobjs = @classMethods;
		    }
		    my $tocStringLocal = "";
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid();
			if (length($name) > 30) {
				$name =~ s/:/:\&zwj;/g;
			}

			if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			} elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"-1\">+</font><a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			} else {
	        		$tocStringLocal .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"-1\">+</font><a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			}
	            }
		if ($newTOC) {
	        	$tocString .= $self->tocAccessEnd();
		}
		$tocString .= tocWrapSubEntries("<!-- class method -->".$tocStringLocal);
	      }
	      if (@instanceMethods) {
		if ($class eq "HeaderDoc::Header") {
		    $tocString .= "\n";
	        } elsif ($self->outputformat eq "html") {
		    if ($newTOC) {
	        	$tocString .= $self->tocAccess("Instance Methods", $firstaccess);
		    } else {
	        	$tocString .= "<h5 class='hd_tocAccess'>Instance Methods</h5>\n";
		    }
		} else {
		}
		$firstaccess = 0;
		    my @tempobjs = ();
		    if (!$self->unsorted()) {
			@tempobjs = sort objName @instanceMethods;
		    } else {
			@tempobjs = @instanceMethods;
		    }
		    my $tocStringLocal = "";
		    foreach my $obj (@tempobjs) {
	        	my $name = $obj->name();
			my $urlname = $obj->apiuid();

			if (length($name) > 30) {
				$name =~ s/:/:\&zwj;/g;
			}

			$baseref = "Methods/Methods.html";
			if ($composite) {
				$baseref = $compositePageName;
			}
			if ($newTOC) {
				$tocStringLocal .= tocSubEntry("$baseref#$urlname", "doc", $name);
			} elsif ($HeaderDoc::use_iframes) {
	        		$tocStringLocal .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"-1\">-</font><a href=\"$baseref#$urlname\" target=\"_top\">$name</a></nobr><br>\n";
			} else {
	        		$tocStringLocal .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=\"-1\">-</font><a href=\"$baseref#$urlname\" target=\"doc\">$name</a></nobr><br>\n";
			}
	        }
		$tocString .= tocWrapSubEntries("<!-- instance method -->".$tocStringLocal);
		if ($newTOC) {
	        	$tocString .= $self->tocAccessEnd();
		}
	      }
	      if (!($group eq "")) {
			if ($newTOC) {
				# $tocString .= tocGroupEnd($group);
			} else {
				$tocString .= "</dd></dl><p>\n";
			}
	      }
	}
	$tocString .= $self->tocGroupEnd();
	if ($newTOC) {
		$tocString .= $self->tocHeadingEnd();
	}
    }
    if (@typedefs) {
	    my $head = "Defined Types\n";
	    my $baseref = "DataTypes/DataTypes.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($head, \@groups, \@typedefs,
		$compositePageName, $baseref, $composite, 1, "datatypes", $newTOC);
    }
    if (@structs) {
	    my $head = "Structs&nbsp;and&nbsp;Unions\n";
	    my $baseref = "Structs/Structs.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($head, \@groups, \@structs,
		$compositePageName, $baseref, $composite, 1, "structs", $newTOC);
    }
    if (@constants) {
	    my $head = "Constants\n";
	    my $baseref = "Constants/Constants.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($head, \@groups, \@constants,
		$compositePageName, $baseref, $composite, 1, "constants", $newTOC);
	}
    if (@enums) {
	    my $head = "Enumerations\n";
	    my $baseref = "Enums/Enums.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($head, \@groups, \@enums,
		$compositePageName, $baseref, $composite, 1, "enums", $newTOC);
	}
    if (@pDefines) {
	    my $head = "#defines\n";
	    my $baseref = "PDefines/PDefines.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($head, \@groups, \@pDefines,
		$compositePageName, $baseref, $composite, 1, "defines", $newTOC);
	}
    if (@classes) {
	my @realclasses = ();
	my @comints = ();
	foreach my $obj (@classes) {
	    if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
	    if ($obj->isCOMInterface()) {
		push(@comints, $obj);
	    } else {
		push(@realclasses, $obj);
	    }
	}
	if (@realclasses) {
	    @classes = @realclasses;
	    if ($newTOC) {
		$tocString .= $self->tocHeading("$baseref#HeaderDoc_classes", "Classes", "doc");
	    } elsif ($HeaderDoc::use_iframes) {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_classes\" target=\"_top\">Classes</a></h4>\n";
	    } else {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_classes\" target=\"doc\">Classes</a></h4>\n";
	    }
	    $tocString .= $self->tocStringSubForClasses("", \@groups, \@classes,
		$compositePageName, "Classes/{}/$defaultFrameName", $composite, 1, "", $newTOC);
	    $tocString .= $self->tocHeadingEnd() if ($newTOC);
	}
	if (@comints) {
	    @classes = @comints;
	    if ($newTOC) {
		$tocString .= $self->tocHeading("$baseref#HeaderDoc_cominterfaces", "C Pseudoclasses", "doc");
	    } elsif ($HeaderDoc::use_iframes) {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_comints\" target=\"_top\">C Pseudoclasses</a></h4>\n";
	    } else {
		# $tocString .= "<h4>C Pseudoclasses</h4>\n";
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_comints\" target=\"doc\">C Pseudoclasses</a></h4>\n";
	    }
	    my @tempobjs = ();
	    if (!$self->unsorted()) {
		@tempobjs = sort objName @classes;
	    } else {
		@tempobjs = @classes;
	    }
	    $tocString .= $self->tocStringSubForClasses("", \@groups, \@comints,
		$compositePageName, "Classes/{}/$defaultFrameName", $composite, 1, "", $newTOC);
	    $tocString .= $self->tocHeadingEnd() if ($newTOC);
	}
    }
    if (@protocols) {
	    if ($newTOC) {
		$tocString .= $self->tocHeading("$baseref#HeaderDoc_protocols", "Protocols", "doc");
	    } elsif ($HeaderDoc::use_iframes) {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_protocols\" target=\"_top\">Protocols</a></h4>\n";
	    } else {
		# $tocString .= "<h4>Protocols</h4>\n";
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_protocols\" target=\"doc\">Protocols</a></h4>\n";
	    }
	    $tocString .= $self->tocStringSubForClasses("", \@groups, \@protocols,
		$compositePageName, "Protocols/{}/$defaultFrameName", $composite, 1, "", $newTOC);
	    $tocString .= $self->tocHeadingEnd() if ($newTOC);
    }
    if (@categories) {
	    if ($newTOC) {
		$tocString .= $self->tocHeading("$baseref#HeaderDoc_categories", "Categories", "doc");
	    } elsif ($HeaderDoc::use_iframes) {
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_categories\" target=\"_top\">Categories</a></h4>\n";
	    } else {
		# $tocString .= "<h4>Categories</h4>\n";
		$tocString .= "<h4><a href=\"$baseref#HeaderDoc_categories\" target=\"doc\">Categories</a></h4>\n";
	    }
	    $tocString .= $self->tocStringSubForClasses("", \@groups, \@categories,
		$compositePageName, "Categories/{}/$defaultFrameName", $composite, 1, "", $newTOC);
	    $tocString .= $self->tocHeadingEnd() if ($newTOC);
    }
    if (@properties) {
	    my $propname = "Properties";
	    my $baseref = "Properties/Properties.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($propname, \@groups, \@properties,
		$compositePageName, $baseref, $composite, 1, "props", $newTOC);
    }
    if (@vars) {
	    my $globalname = "Globals";
	    if ($class ne "HeaderDoc::Header") {
		$globalname = "Member Data";
	    }
	    my $baseref = "Vars/Vars.html";
	    if ($composite) {
		$baseref = $compositePageName;
	    }
	    $tocString .= $self->tocStringSub($globalname, \@groups, \@vars,
		$compositePageName, $baseref, $composite, 0, "vars", $newTOC);
    }
    if ($class ne "HeaderDoc::Header") {
	if ($newTOC) {
		$tocString .= $self->tocSeparator("Other Reference", $newTOC);
		$tocString .= $self->tocEntry("../../$defaultFrameName", "Header", "_top");
	} else {
		$tocString .= "<br><h4>Other Reference</h4><hr class=\"TOCSeparator\">\n";
		$tocString .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"../../$defaultFrameName\" target=\"_top\">Header</a></nobr><br>\n";
	}
	$tocString .= "<!-- HeaderDoc TOC framework link begin -->\n";
	$tocString .= "<!-- HeaderDoc TOC framework link end -->\n";
    } else {
	$tocString .= "<!-- HeaderDoc TOC framework link block begin -->\n";
	$tocString .= "<!-- HeaderDoc TOC framework link block end -->\n";
    }
    if (!$composite) {
	if ($newTOC) {
		$tocString .= $self->tocEntry("$compositePageName", "[Printable HTML Page]", "_blank");
	} else {
		if ($HeaderDoc::use_iframes) {
			$tocString .= "<br><hr class=\"TOCSeparator\"><a href=\"$compositePageName?hidetoc\" target=\"_blank\">[Printable HTML Page]</a>\n";
		} else {
			$tocString .= "<br><hr class=\"TOCSeparator\"><a href=\"$compositePageName\" target=\"_blank\">[Printable HTML Page]</a>\n";
		}
	}
    }
    if ($newTOC != 3) {
	my $availability = $self->availability();
	my $updated = $self->updated();
	if (length($availability)) {
		$tocString .= "<p><i>Availability: $availability</i><p>";
	}
	if (length($updated)) {
		$tocString .= "<p><i>Updated: $updated</i><p>";
	}
    }
    return $tocString;
}

# /*!
#     @abstract
#         Returns a TOC separator block.
#  */
sub tocSeparator
{
    my $self = shift;
    my $string = shift;
    my $newTOC = shift;

    my $tocString = "";

    if ($newTOC == 5) {
	$tocString .= "<hr class=\"tocSeparator\">\n";
	$tocString .= "<h4 class=\"tocSubheading\">Other Reference</h4>\n";
    }

    return $tocString;
}

# /*!
#     @abstract
#         Returns the HTML for a TOC section heading.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocHeading
{
    my $self = shift;
    my $url = shift;
    my $name = shift;
    my $target = shift;

    my $string = "";

    if ($HeaderDoc::use_iframes && $target eq "_top" || $target eq "doc") {
	$target = "_top";
    }

    if ($HeaderDoc::newTOC == 3) {
	return tocJSON($url, $name, 1, "tocHeading", undef);
    } elsif ($HeaderDoc::newTOC == 2) {
	$string = "<li class=\"section children\"><span class=\"sectionName\">";
	if ($target ne "") {
		$string .= "<a href=\"$url\" target=\"$target\">$name</a>\n";
	} else {
		$string .= "<a href=\"#\">$name</a>\n";
	}
	$string .= "</span>\n<ul class=\"collapsible\" style=\"display:none;\">\n";
	# print "HERE FOR $name. Returning $string\n";
	return $string;
    }

    my $opentriangle = "<img src=\"/Resources/Images/top_level_open.gif\" open=\"/Resources/Images/top_level_open.gif\" closed=\"/Resources/Images/top_level_closed.gif\" border=\"0\" alt=\"\" />";

    my $usethis = "";
    my $opentriangle_class = "";
    if ($HeaderDoc::newTOC == 5) {
	# $opentriangle = "&#x25BC;"; # open
	$opentriangle = "&#x25B7;"; # closed
	$opentriangle_class = "closed_disclosure_triangle";
	$usethis = "this";
    }

    $string .= "<div toc=\"section\">\n";

    my $style1 = "";
    my $style2 = "";
    my $style3 = "";
    my $style4 = "";
    my $style5 = "";
    if ($HeaderDoc::newTOC != 5) {
	$style1 = "width=\"5\" style='min-width: 5px; min-height: 1px;'";
	$style2 = "style=\"margin-left: 5px; margin-right: 5px; padding-top: 4px;\"";
	$style3 = "style=\"color: #000000; font-size: 12px; text-decoration: none\" toc=\"section_link\"";
	$style4 = "width=\"10\" style='min-width: 6px; min-height: 1px;'";
	$style5 = "style=\"padding-right: 5px; padding-top: 3px; padding-bottom: 3px;\"";
    }

    $string .= "<table class=\"hd_toc_heading_table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">";
    if ($HeaderDoc::newTOC != 5) {
	$string .= "<tr><td width=\"10\" scope=\"row\"></td><td width=\"20\"></td><td width=\"20\"></td><td width=\"20\"></td><td width=\"20\"></td><td width=\"99%\"></td></tr>\n";
    }
    $string .= "<tr><td class=\"toc_leadspace\" $style1></td><td class=\"disclosure_triangle_td\" valign=\"top\" align=\"left\" $style2><a $style3 href=\"#\" class=\"$opentriangle_class\" onclick=\"disclosure_triangle($usethis)\">$opentriangle</a></td><td class=\"disclosure_padding\" $style4></td><td valign=\"top\" colspan=\"4\" class=\"toc_contents_text\" toc=\"section_link\" $style5>\n";

    if ($target ne "") {
	$string .= "<a href=\"$url\" target=$target>$name</a></td></tr>\n";
    } else {
	$string .= "<a href=\"#\">$name</a></td></tr>\n";
    }
    $string .= "</table>\n";

    my $display = "";
    if ($HeaderDoc::newTOC == 5) { $display = " class=\"collapsible\" "; }

    $string .= "<div toc=\"collapsible\"$display>\n";

    return $string;
}

# /*! @abstract
#         Returns the closing HTML tags to end a TOC section.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocHeadingEnd
{
    my $self = shift;

    if ($HeaderDoc::newTOC == 3) {
	return tocJSON("","", 2, "tocHeadingEnd", undef);
    } elsif ($HeaderDoc::newTOC == 2) {
	return "</ul></li>\n";
    }

    my $string = "";
    $string .= "</div></div>\n";

    return $string;
}

# /*! @abstract
#         Returns the HTML for a top-level entry in the left-side TOC.
#     @discussion
#         In practice, this is used for the Overview section link and the
#         link back to the enclosing header from a class.
#  */
sub tocEntry
{
	my $self = shift;
	my $url = shift;
	my $name = shift;
	my $target = "doc";

	if (@_) { $target = shift; }

	if ($HeaderDoc::use_iframes && $target eq "_top" || $target eq "doc") {
		$target = "_top";
	}

	if ($HeaderDoc::newTOC == 3) {
		return tocJSON($url, $name, 0, "tocEntry", undef);
	} elsif ($HeaderDoc::newTOC == 2) {
		return "<li class=\"section\"><span class=\"sectionName\"><div><a href=\"$url\" target=\"$target\">$name</a></div></span></li>\n";
	}

	my $tocString = "";
	$tocString .= "<div>\n";

	$tocString .= "<table class=\"hd_toc_entry_table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";

	my $style1 = ""; my $style2 = ""; my $style3 = ""; my $width1 = "";
	if ($HeaderDoc::newTOC != 5) {
		$tocString .= "<tr><td width=\"10\" scope=\"row\"></td><td width=\"20\"></td><td width=\"20\"></td><td width=\"20\"></td><td width=\"20\"></td><td width=\"99%\"></td></tr>\n";
		$style1 = "width=\"10\" style='min-width: 10px; min-height: 1px;'";
		$style2 = "width=\"10\" style='min-width: 10px; min-height: 1px;'";
		$style3 = "style=\"padding-right: 5px; padding-top: 3px; padding-bottom: 3px;\"";
		$width1 = "width=\"10\"";
	}

	$tocString .= "<tr><td class=\"toc_leadspace\" $style1></td><td class=\"disclosure_triangle_td\" $style2></td><td class=\"disclosure_padding\" $width1></td><td valign=\"top\" colspan=\"3\" class=\"toc_contents_text\" $style3 toc=\"section_link\"><a href=\"$url\" target=\"$target\">$name</a></td></tr>\n";
	# $tocString .= "</tr>\n";
	$tocString .= "</table>\n";
	$tocString .= "</div>\n";

	return $tocString;
}

# /*! @abstract
#         Returns the HTML for the end of a
#         {@link //apple_ref/perl/cl/HeaderDoc::Group Group}
#         label in the left-side TOC.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocGroupEnd
{
	my $group = shift;
	my $tocString = "";

	if ($HeaderDoc::newTOC == 3) {
		return tocJSON("", "", 2, "tocGroupEnd", undef);
	}
	return "";
}

# /*! @abstract
#         Returns the HTML for a
#         {@link //apple_ref/perl/cl/HeaderDoc::Group Group}
#         label in the left-side TOC.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocGroup
{
	my $group = shift;
	my $firstgroup = shift;
	my $tocString = "";


	if (!$firstgroup) { $tocString .= "<span class='hd_tocGroupSpace'>&nbsp;<br></span>\n"; }

	my $preface = "&nbsp;&nbsp;";
	# $tocString .= "$preface<font size=\"-1\"><i>$group:</i></font><br>";
	$tocString .= "<span class=\"hd_tocGroup\">$group</span>\n";

	if ($HeaderDoc::newTOC == 3) {
		my $url = "index.html#";
		return tocJSON($url, $group, 1, "tocGroup", undef);
	} elsif ($HeaderDoc::newTOC == 2) {
		$tocString = "<li class=\"section\">$tocString</li>\n";
	}

	return $tocString;
}

# /*!
#     @abstract
#         Returns whether access control is supported by the current programming language.
#     @result
#         Returns <code>1</code> if the programming language for this object supports
#         access control, else <code>0</code>.
#  */
sub langSupportsAccess
{
	my $self = shift;
	my $lang = $self->lang();

	if ($lang eq "perl" || $lang eq "php" || $lang eq "tcl") { return 0; }

	return 1;
}

# /*! @abstract
#         Returns the HTML for an access heading (e.g. public, private) in the left-side TOC.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocAccess
{
	my $self = shift;
	my $access = shift;
	my $firstaccess = shift;
	my $tocString = "";

# print STDERR "TOCACCESS\n";

	my $lang = $self->lang();
	if (!($self->langSupportsAccess())) { return ""; }

	if (!$firstaccess) { $tocString .= "<span class='hd_tocAccessSpace'>&nbsp;<br></span>\n"; }
	# $tocString .= "&nbsp;&nbsp;&nbsp;&nbsp;<b>$access</b><br>\n";
	$tocString .= "<span class=\"hd_tocAccess\">$access</span>\n";

	if ($HeaderDoc::newTOC == 3) {
		my $url = "index.html#";
		return tocJSON($url, $access, 1, "tocAccess", undef);
	} elsif ($HeaderDoc::newTOC == 2) {
		$tocString = "<li class=\"entry_2\">$tocString</li>\n";
	}
	return $tocString;
}

# /*! @abstract
#         Returns the HTML for closing an access group (e.g. public, private) in the left-side TOC.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocAccessEnd
{
	my $self = shift;
	my $access = shift;
	my $tocString = "";

# print STDERR "TOCACCESSEND\n";

	my $lang = $self->lang();
	if ($lang eq "perl" || $lang eq "php" || $lang eq "tcl") { return ""; }

	if ($HeaderDoc::newTOC == 3) {
		my $url = "";
		return tocJSON($url, $access, 2, "tocAccessEnd", undef);
	}
	# $tocString .= "</dd></dl>\n";

	return $tocString;
}

# /*! @abstract
#         Returns an entry for a single symbol in the left-side TOC.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocSubEntry
{
	my $url = shift;
	my $target = shift;
	my $name = shift;
	my $tocString = "";

	if ($HeaderDoc::use_iframes && $target eq "_top" || $target eq "doc") {
		$target = "_top";
	}

	# FOR NOW --DAG
	my $entrypreface = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	# $tocString .= "<nobr>$entrypreface<a href=\"$url\" target=\"$target\">$name</a></nobr><br>\n";

	if ($HeaderDoc::newTOC == 3) {
		return tocJSON($url, $name, 0, "tocSubEntry", undef);
	} elsif ($HeaderDoc::newTOC == 2) {
		$tocString .= "<li class=\"entry_2\"><a href=\"$url\" target=\"$target\">$name</a></li>\n";
	} else {
		$tocString .= "<li class=\"tocSubEntry\"><a href=\"$url\" target=\"$target\">$name</a></li>\n";
	}

	return $tocString;
}

# /*! @abstract
#         Returns the structure for a grouping of symbols in the left-side TOC.
#     @discussion
#         Part of the new-style TOC code.
#  */
sub tocWrapSubEntries
{
	my $input = shift;

	# die("NT: ".$HeaderDoc::newTOC."\n");
	if (($HeaderDoc::newTOC == 5) && ($input)) {
		return "<ul class=\"tocSubEntryList\">$input</ul>";
	} else {
		return $input;
	}
}


# /*! @abstract
#         Gets/sets the array of enums that are enclosed in this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param ENUMS
#         The array value to set. (Optional)
#  */
sub enums {
    my $self = shift;

    if (@_) {
        @{ $self->{ENUMS} } = @_;
    }
    ($self->{ENUMS}) ? return @{ $self->{ENUMS} } : return ();
}

# /*! @abstract
#         Adds an enum associated with this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param ENUMS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Enum HeaderDoc::Enum} objects to add.
#  */
sub addToEnums {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO ENUMS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{ENUMS} }, $item);
        }
    }
    return @{ $self->{ENUMS} };
}

# /*! @abstract
#         Gets/sets the array of <code>#define</code> entries that are
#         enclosed in this header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param PDEFINES
#         The array value to set. (Optional)
#  */
sub pDefines {
    my $self = shift;

    if (@_) {
        @{ $self->{PDEFINES} } = @_;
    }
    ($self->{PDEFINES}) ? return @{ $self->{PDEFINES} } : return ();
}

# /*! @abstract
#         Adds a <code>#define</code> macro associated with this header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param PDEFINES
#         The {@link //apple_ref/perl/cl/HeaderDoc::PDefine HeaderDoc::PDefine} objects to add.
#  */
sub addToPDefines {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO PDEFINES\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{PDEFINES} }, $item);
        }
    }
    return @{ $self->{PDEFINES} };
}

# /*! @abstract
#         Gets/sets the array of constants that are enclosed in this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CONSTANTS
#         The array value to set. (Optional)
#  */
sub constants {
    my $self = shift;

    if (@_) {
        @{ $self->{CONSTANTS} } = @_;
    }
    ($self->{CONSTANTS}) ? return @{ $self->{CONSTANTS} } : return ();
}

# /*! @abstract
#         Adds a constant associated with this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param CONSTANTS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Constant HeaderDoc::Constant} objects to add.
#  */
sub addToConstants {
    my $self = shift;
    
    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO CONSTANTS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{CONSTANTS} }, $item);
        }
    }
    return @{ $self->{CONSTANTS} };
}

# /*! @abstract
#         Gets/sets the array of functions that are enclosed in this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param FUNCTIONS
#         The array value to set. (Optional)
#  */
sub functions {
    my $self = shift;

    if (@_) {
        @{ $self->{FUNCTIONS} } = @_;
    }
    ($self->{FUNCTIONS}) ? return @{ $self->{FUNCTIONS} } : return ();
}

# /*! @abstract
#         Adds a function associated with this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param FUNCTIONS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Function HeaderDoc::Function} objects to add.
#  */
sub addToFunctions {
    my $self = shift;
    my $localDebug = 0;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO FUNCTIONS\n"; }
	    # cluck("ADDING FUNCTION $item TO $self\n");
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
	    foreach my $compare (@{ $self->{FUNCTIONS} }) {
		my $name1 = $item->name();
		my $name2 = $compare->name();
		# print STDERR "ITEM: $item COMPARE: $compare\n";
		if ($item->name() eq $compare->name() && $item != $compare) {
			my $oldconflict = ($item->conflict() && $compare->conflict());
			$item->conflict(1);
			$compare->conflict(1);
			my $prevignore = $HeaderDoc::ignore_apiuid_errors;
			$HeaderDoc::ignore_apiuid_errors = 1;
			my $junk = $item->apirefSetup(1);
			$junk = $compare->apirefSetup(1);
			$HeaderDoc::ignore_apiuid_errors = $prevignore;
			print STDERR "$name1 = $name2\n" if ($localDebug);

			if (!$oldconflict) {
			  my $apio = $self; # ->apiOwner();
			  my $apioclass = ref($apio) || $apio;
			  if ($apioclass ne "HeaderDoc::CPPClass") {
			    if ($apioclass !~ /HeaderDoc::ObjC/o) {
				warn "----------------------------------------------------------------------------\n";
				warn "Conflicting declarations for function/method ($name1) outside a\n"."class (apioclass=$apioclass).  This is probably not what\n"."you want.  This warning is usually caused by failing to include a\n"."HeaderDoc comment for the enclosing class or by using the wrong name\n"."with an old-style HeaderDoc tag such as \@function.\n";
				warn "----------------------------------------------------------------------------\n";
				# $apio->dbprint();
			    }
			  }
			}
		} elsif ($item == $compare) {
			# warn "Attempt to reregister object\n";
			return;
		}
	    }
            push (@{ $self->{FUNCTIONS} }, $item);
        }
    }
    return @{ $self->{FUNCTIONS} };
}

# /*!
#   @abstract
#     Removes a maximum of one function per invocation.
#   @discussion
#     A function gets removed if it gets merged into a C
#     pseudoclass by an <code>\@alsoInclude</code> directive.
#     @param self
#         The <code>APIOwner</code> object.
#     @param obj
#         The function object to remove.
#  */
sub removeFromFunctions
{
    my $self = shift;
    my $obj = shift;
    $self->removeObject("FUNCTIONS", $obj);
}

# /*!
#   @abstract
#     Removes a maximum of one <code>#define</code> macro per invocation.
#   @discussion
#     A <code>#define</code> gets removed if it gets merged into a C
#     pseudoclass by an <code>\@alsoInclude</code> directive.
#     @param self
#         The <code>APIOwner</code> object.
#     @param obj
#         The <code>#define</code> object to remove.
#  */
sub removeFromPDefines
{
    my $self = shift;
    my $obj = shift;
    $self->removeObject("PDEFINES", $obj);
}

# /*!
#   @abstract
#     Removes a maximum of one object per invocation.
#   @discussion
#     Used by {@link removeFromFunctions} and {@link removeFromPDefines}.
#   @param self
#     The <code>APIOwner</code> object.
#   @param obj
#     The object to remove.
#  */
sub removeObject
{
    my $self = shift;
    my $key = shift;
    my $objectToRemove = shift;
    my @orig = @{$self->{$key}};
    my @new = ();

    my $found = 0;
    foreach my $obj (@orig) {
	if ($obj == $objectToRemove) {
		$found = 1;
	} else {
		push(@new, $obj);
	}
    }
    if ($found) {
	$self->{$key} = \@new;
    } else {
	warn "Could not remove ".$objectToRemove->name()." from ".$self->name()."\n";
    }
}

# /*! @abstract
#         Gets/sets the array of Objective-C methods that are
#         enclosed in this class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param METHODS
#         The array value to set. (Optional)
#  */
sub methods {
    my $self = shift;

    if (@_) {
        @{ $self->{METHODS} } = @_;
    }
    ($self->{METHODS}) ? return @{ $self->{METHODS} } : return ();
}

# /*! @abstract
#         Adds an Objective-C method associated with this class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param METHODS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Method HeaderDoc::Method} objects to add.
#  */
sub addToMethods {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO METHODS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
	    foreach my $compare (@{ $self->{METHODS} }) {
		if ($item->name() eq $compare->name()) {
			$item->conflict(1);
			$compare->conflict(1);
		}
	    }
            push (@{ $self->{METHODS} }, $item);
	    # warn("addToMethods: ".$item->rawname()."\n");
        }
    }
    return @{ $self->{METHODS} };
}

# /*! @abstract
#         Gets/sets the array of typedefs that are enclosed in this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param TYPEDEFS
#         The array value to set. (Optional)
#  */
sub typedefs {
    my $self = shift;

    if (@_) {
        @{ $self->{TYPEDEFS} } = @_;
    }
    ($self->{TYPEDEFS}) ? return @{ $self->{TYPEDEFS} } : return ();
}

# /*! @abstract
#         Adds a typedef associated with this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param TYPEDEFS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Typedef HeaderDoc::Typedef} objects to add.
#  */
sub addToTypedefs {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO TYPEDEFS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{TYPEDEFS} }, $item);
	# print STDERR "added ".$item->name()." to $self.\n";
        }
    }
    return @{ $self->{TYPEDEFS} };
}

# /*! @abstract
#         Gets/sets the array of structs that are enclosed in this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param STRUCTS
#         The array value to set. (Optional)
#  */
sub structs {
    my $self = shift;

    if (@_) {
        @{ $self->{STRUCTS} } = @_;
    }
    ($self->{STRUCTS}) ? return @{ $self->{STRUCTS} } : return ();
}

# /*! @abstract
#         Adds a struct associated with this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param STRUCTS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Struct HeaderDoc::Struct} objects to add.
#  */
sub addToStructs {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO STRUCTS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{STRUCTS} }, $item);
        }
    }
    return @{ $self->{STRUCTS} };
}

# /*! @abstract
#         Gets/sets the array of properties that are enclosed in this class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param PROPS
#         The array value to set. (Optional)
#  */
sub props {
    my $self = shift;

    if (@_) {
        @{ $self->{PROPS} } = @_;
    }
    ($self->{PROPS}) ? return @{ $self->{PROPS} } : return ();
}

# /*! @abstract
#         Adds a property associated with this class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param PROPS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Var HeaderDoc::Var} objects
#         (with isProperty set to 1) to add.
#  */
sub addToProps {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO PROPS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{PROPS} }, $item);
        }
    }
    return @{ $self->{PROPS} };
}

# /*! @abstract
#         Gets/sets the array of variables that are enclosed in this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param VARS
#         The array value to set. (Optional)
#  */
sub vars {
    my $self = shift;

    if (@_) {
        @{ $self->{VARS} } = @_;
    }
    ($self->{VARS}) ? return @{ $self->{VARS} } : return ();
}

# /*! @abstract
#         Adds a variable associated with this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param VARS
#         The {@link //apple_ref/perl/cl/HeaderDoc::Var HeaderDoc::Var} objects
#         (with isProperty set to 0) to add.
#  */
sub addToVars {
    my $self = shift;

    if (@_) {
        foreach my $item (@_) {
	    if ($addToDebug) { print STDERR "ADDED $item TO VARS\n"; }
	    if (!$item->{INSERTED}) { $item->{INSERTED} = 42; }
            push (@{ $self->{VARS} }, $item);
        }
    }
    return @{ $self->{VARS} };
}

# /*! @abstract
#         Gets/sets the array of fields that are associated with a
#         C pseudoclass.
#     @param self
#         The <code>APIOwner</code> object.
#     @param VARS
#         The array value to set. (Optional)
#  */
sub fields {
    my $self = shift;
    if (@_) { 
        @{ $self->{FIELDS} } = @_;
    }
    ($self->{FIELDS}) ? return @{ $self->{FIELDS} } : return ();
}

# /*! @abstract
#         Sets and returns the availability of this class.
#     @param self
#         The <code>APIOwner</code> object.
#     @param availability
#         The availability value to set.  (Optional)
#  */
sub availability {
    my $self = shift;

    if (@_) {
        $self->{AVAILABILITY} = shift;
    }
    return $self->{AVAILABILITY};
}

# /*! @abstract
#         Sets and returns the last updated date for this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param availability
#         The availability value to set.  (Optional)
#  */
sub updated {
    my $self = shift;
    my $localDebug = 0;
    
    if (@_) {
	my $updated = shift;
        # $self->{UPDATED} = shift;
	my $month; my $day; my $year;

	$month = $day = $year = $updated;

	print STDERR "updated is $updated\n" if ($localDebug);
	if (!($updated =~ /\d\d\d\d-\d\d-\d\d/o )) {
	    if (!($updated =~ /\d\d-\d\d-\d\d\d\d/o )) {
		if (!($updated =~ /\d\d-\d\d-\d\d/o )) {
		    # my $filename = $HeaderDoc::headerObject->filename();
		    my $fullpath = $self->fullpath();
		    my $linenum = $self->linenum();
		    print STDERR "$fullpath:$linenum: warning: Bogus date format: $updated. Valid formats are MM-DD-YYYY, MM-DD-YY, and YYYY-MM-DD\n";
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
		    print STDERR "YEAR: $year" if ($localDebug);
		}
	    } else {
		print STDERR "03-25-2003 case.\n" if ($localDebug);
		    $month =~ s/(\d\d)-\d\d-\d\d\d\d/$1/smog;
		    $day =~ s/\d\d-(\d\d)-\d\d\d\d/$1/smog;
		    $year =~ s/\d\d-\d\d-(\d\d\d\d)/$1/smog;
	    }
	} else {
		    $year =~ s/(\d\d\d\d)-\d\d-\d\d/$1/smog;
		    $month =~ s/\d\d\d\d-(\d\d)-\d\d/$1/smog;
		    $day =~ s/\d\d\d\d-\d\d-(\d\d)/$1/smog;
	}
	$month =~ s/\n*//smog;
	$day =~ s/\n*//smog;
	$year =~ s/\n*//smog;
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
		# my $filename = $HeaderDoc::headerObject->filename();
		my $fullpath = $self->fullpath();
		my $linenum = $self->linenum();
		print STDERR "$fullpath:$linenum: warning: Invalid date (year = $year, month = $month, day = $day). Valid formats are MM-DD-YYYY, MM-DD-YY, and YYYY-MM-DD\n";
		return $self->{UPDATED};
	} else {
		$self->{UPDATED} =HeaderDoc::HeaderElement::strdate($month-1, $day, $year, $self->encoding());
	}
    }
    return $self->{UPDATED};
}


##################################################################

# # /*!
# #     @abstract
# #         Deprecated.
# #     @discussion
# #         Creates a book.xml metadata file.  No longer used.
# #     @param self
# #         The <code>APIOwner</code> object.
# #  */
# sub createMetaFile {
    # my $self = shift;
    # my $outDir = $self->outputDir();
    # my $outputFile = "$outDir$pathSeparator"."book.xml";
    # my $text = $self->metaFileText();
# 
    # open(OUTFILE, ">$outputFile") || die "Can't write $outputFile. \n$!\n";
    # if ($isMacOS) {MacPerl::SetFileInfo('MSIE', 'TEXT', "$outputFile");};
    # print OUTFILE "$text";
    # close OUTFILE;
# }

# use Devel::Peek;

# /*!
#     @abstract
#         Creates the index.html frameset file for a class or header.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub createFramesetFile {
    my $self = shift;
    # print STDERR "I0\n"; Dump($self);
    my $docNavigatorComment = $self->docNavigatorComment();
    # print STDERR "I1\n"; Dump($self);
    my $class = ref($self);
    my $defaultFrameName = $class->defaultFrameName();
    # print STDERR "I2\n"; Dump($self);

    if ($HeaderDoc::use_iframes) {
	return;
    }

    my $jsnav = 1;
    my $newTOC = $HeaderDoc::newTOC;
    my $cols = "190,100%";
    my $frameatts = "";
    my $bordercolor = "";
    my $framesetatts = "";
    if ($newTOC) {
	$cols = "210, *";
	$bordercolor = "bordercolor=\"#999999\"";
	$frameatts = "border=\"0\" frameborder=\"0\"";
	$framesetatts = "frameborder=\"NO\" border=\"0\""; #  frameborder=\"0\"";
    }
	
    # print STDERR "I5\n";
    # Dump($self);

    my $HTMLmeta = "";
    # if ($class eq "HeaderDoc::Header") {
	$HTMLmeta = $self->HTMLmeta();
    # }
    # if ($self->outputformat() eq "html") {
	# $HTMLmeta .= $self->styleSheet(0);
    # }

    my $filename = $self->filename();
    my $name = $self->name();
    my $title = $filename;
    if (!length($name)) {
	$name = "$filename";
    } else {
	$title = "$name ($filename)";
    }

    my $outDir = $self->outputDir();
    
    my $outputFile = "$outDir$pathSeparator$defaultFrameName";    
    my $rootFileName = $self->filename();
    $rootFileName =~ s/(.*)\.h/$1/o; 
    $rootFileName = &safeName(filename => $rootFileName);
    my $compositePageName = $self->compositePageName();

    my $composite = $HeaderDoc::ClassAsComposite;
    # if ($class eq "HeaderDoc::Header") {
	# $composite = 0;
    # }

    my $script = "";

    if ($jsnav) {
	$script .= "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";

	$script .= "origURL = parent.document.URL;\n";
	$script .= "contentURL = origURL.substring(origURL.indexOf('?')+1, origURL.length);\n";

	$script .= "if (contentURL.length == origURL.length) {\n";
	$script .= "	jumpPos = origURL.substring(origURL.indexOf('#')+1, origURL.length);\n";
	if ($composite) {
       		$script .= "	contentURL = '$compositePageName';\n";
	} else {
       		$script .= "	contentURL = '$rootFileName.html';\n";
	}
	$script .= "	if (jumpPos.length != origURL.length) {\n";
	$script .= "		contentURL += '#' + jumpPos;\n";
	$script .= "	}\n";
	$script .= "	// document.write('contentURL: ' + contentURL + '<br>\\n');\n";
	$script .= "	// document.write('Length: ' + contentURL.length + '<br>\\n');\n";
	# $script .= "	alert('contentURL = '+contentURL);\n";
	$script .= "}\n";

	$script .= "document.write('<frameset id=\"frameset\" cols=\"$cols\" $framesetatts><frame src=\"toc.html\" name=\"nav\" $bordercolor $frameatts><frame src=\"' + contentURL + '\" name=\"doc\" $frameatts><\\/frameset>');\n";

	$script .= "--></script>\n";
    }

    open(OUTFILE, ">$outputFile") || die "Can't write $outputFile. \n$!\n";
    if ($isMacOS) {MacPerl::SetFileInfo('MSIE', 'TEXT', "$outputFile");};
	print OUTFILE "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\"\n    \"http://www.w3.org/TR/1999/REC-html401-19991224/frameset.dtd\">\n";
    print OUTFILE "<html><head>\n    <title>Documentation for $title</title>\n$HTMLmeta\n	<meta name=\"generator\" content=\"HeaderDoc\" />\n<meta name=\"xcode-display\" content=\"render\" />\n$script"."</head>\n";
		print OUTFILE "<meta name=\"ROBOTS\" content=\"NOINDEX\" />\n";

    print OUTFILE "<body bgcolor=\"#e6e6e6\">\n";
    if ($jsnav) {
	print OUTFILE "<noscript>\n";
    }

    print OUTFILE "<frameset cols=\"$cols\" $framesetatts>\n";
    print OUTFILE "<frame src=\"toc.html\" name=\"toc\" $bordercolor $frameatts>\n";
    if ($composite) {
	print OUTFILE "<frame src=\"$compositePageName\" name=\"doc\" $frameatts>\n";
    } else {
	print OUTFILE "<frame src=\"$rootFileName.html\" name=\"doc\" $frameatts>\n";
    }
    print OUTFILE "</frameset>\n";
    print OUTFILE "<noframes>\n";
    print OUTFILE "<h2>This document set is best viewed in a browser that supports frames. To access the TOC, <a href=\"toc.html\">Click here</a></h2>\n";
    print OUTFILE "</noframes>\n";

    if ($jsnav) {
	print OUTFILE "</noscript>\n";
    }
    print OUTFILE "</body>\n";

    print OUTFILE "$docNavigatorComment\n";
    print OUTFILE "</html>\n";
    close OUTFILE;
}

# /*!
#     @abstract
#         Returns a comment marker for
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}.
#     @discussion
#         Overridden by subclasses to return an HTML comment that identifies the 
#         index file (Header vs. Class, name, and so on).  The
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc} tool
#         uses this information to create a master TOC for the generated doc.
#     @param self
#         The <code>APIOwner</code> object.
# */
sub docNavigatorComment {
    return "";
}

# /*!
#     @abstract
#         Creates the table of contents file (toc.html) for a class or header.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub createTOCFile {
    my $self = shift;
    my $rootDir = $self->outputDir();
    my $tocTitlePrefix = $self->tocTitlePrefix();
    my $outputFileName = "toc.html";    

    my $depthFile = "$rootDir$pathSeparator$outputFileName";
    calcDepth($depthFile);

    my $newTOC = $HeaderDoc::newTOC;
    if ($newTOC == 3) {
	$outputFileName = "book.js";    
    }

    my $outputFile = "$rootDir$pathSeparator$outputFileName";    
    my $fileString = $self->tocString($newTOC);


    my $filename = $self->filename();
    my $name = $self->name();
    my $title = $filename;
    if (!length($name)) {
	$name = "$filename";
    } elsif ($name eq $filename) {
	$name = "$filename";
    } else {
	$title = "$name ($filename)";
    }

    my $HTMLmeta = "";
    # if ($class eq "HeaderDoc::Header") {
	$HTMLmeta = $self->HTMLmeta();
    # }
    # if ($self->outputformat() eq "html") {
	# $HTMLmeta .= $self->styleSheet(0);
    # }

	open(OUTFILE, ">$outputFile") || die "Can't write $outputFile.\n$!\n";
    if ($isMacOS) {MacPerl::SetFileInfo('MSIE', 'TEXT', "$outputFile");};

	if ($newTOC != 3) {
		print OUTFILE "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n    \"http://www.w3.org/TR/1998/REC-html40-19980424/loose.dtd\">\n";
	} 

	if ($newTOC == 3) {
		my @related = ();
		my %info = (
			"technology" => "",
			"topic" => "",
			"subtopic" => "",
			"layer" => "",
			"framework" => "",
			# "PDF" => {"href" => ""}, # DO NOT INSERT THIS!
			"companionFiles" => "",
			"needsAdditionalLinksSeparator" => "false",
			"relatedBooks" => \@related

		);
		print OUTFILE tocJSON("", "$tocTitlePrefix $name", 1, "Top", \%info);

		print OUTFILE $fileString;

		print OUTFILE tocJSON("", "", 3, "Top", undef);
	} elsif ($newTOC == 2) {
		print OUTFILE "<head><meta name=\"ROBOTS\" content=\"NOINDEX\" /></head>\n";
		print OUTFILE "<meta name=\"generator\" content=\"HeaderDoc\" />";
		print OUTFILE "<h1 id=\"book_title\">$tocTitlePrefix $name</h1>\n";
		print OUTFILE $fileString;
	} elsif ($newTOC && $newTOC != 5) {
		print OUTFILE "<html>";

		print OUTFILE "<head>\n";
		print OUTFILE "<meta name=\"ROBOTS\" content=\"NOINDEX\" />\n";
		print OUTFILE "<meta name=\"xcode-display\" content=\"render\" />\n";
		# if ($HeaderDoc::enable_custom_references) {
			# print OUTFILE "<script language=\"JavaScript\" src=\"/Resources/JavaScript/customReference.js\" type=\"text/javascript\"></script>\n";
		# }
		print OUTFILE "<script language=\"JavaScript\" src=\"/Resources/JavaScript/toc.js\" type=\"text/javascript\"></script>\n";
		print OUTFILE "<script language=\"JavaScript\" src=\"/Resources/JavaScript/page.js\" type=\"text/javascript\"></script>\n";
		print OUTFILE "<title>Documentation for $title</title>\n$HTMLmeta\n	<meta name=\"generator\" content=\"HeaderDoc\" />\n";
		print OUTFILE $self->styleSheet(1);
		print OUTFILE "</head>\n";
		if ($HeaderDoc::use_iframes) {
			print OUTFILE "<body bgcolor=\"#ffffff\" link=\"#000099\" vlink=\"#660066\"\n";
			print OUTFILE "style=\"margin: 0; border-left: 10px solid white; border-right: 5px solid white;\n";
			print OUTFILE "border-top: 10px solid white\" onload=\"initialize_toc();\">\n";
		} else {
			print OUTFILE "<body bgcolor=\"#ffffff\" link=\"#000099\" vlink=\"#660066\"\n";
			print OUTFILE "leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\"\n"; 
			print OUTFILE "marginheight=\"0\" style=\"border-left: 10px solid white; border-right: 5px solid white;\n";
			print OUTFILE "border-top: 10px solid white\" onload=\"initialize_toc();\">\n";
		}

		print OUTFILE "<div id=\"toc\">\n";


		# Replaced with table.
		# print OUTFILE "<div id=\"toc_staticbox\" style=\"display: table;\">\n";
		print OUTFILE "<table class=\"tocTable\" width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td scope=\"row\">\n";

		print OUTFILE "<h2>$tocTitlePrefix $name</h2>\n";
		print OUTFILE "<div id=\"toc_PDFbottomborder\"></div>\n";
		print OUTFILE $fileString;

		# Replaced with table.
		# print OUTFILE "</div>\n";
		print OUTFILE "</td></tr></table>\n";

		print OUTFILE "</div><p>&nbsp;<p>\n";
		print OUTFILE "</body></html>\n";
	} else {
		print OUTFILE "<html>";

		print OUTFILE "<head>\n";
		print OUTFILE "<meta name=\"ROBOTS\" content=\"NOINDEX\" />\n";
		print OUTFILE "<title>Documentation for $title</title>\n$HTMLmeta\n	<meta name=\"generator\" content=\"HeaderDoc\" />\n<meta name=\"xcode-display\" content=\"render\" />\n";
		print OUTFILE $self->styleSheet(1);
		print OUTFILE "</head>\n";
		print OUTFILE "<body bgcolor=\"#edf2f6\" link=\"#000099\" vlink=\"#660066\"\n";
		print OUTFILE "leftmargin=\"0\" topmargin=\"0\" marginwidth=\"0\"\n"; 
		print OUTFILE "marginheight=\"0\">\n";

		print OUTFILE "<table class=\"headerdoc_content_table\" width=\"100%\" cellpadding=0 cellspacing=0 border=0>";
		print OUTFILE "<tr id=\"colorbox\" height=51 width=\"100%\" bgcolor=\"#466C9B\"><td width=\"100%\">&nbsp;</td></tr>";
		print OUTFILE "<tr><td class=\"hd_toc_box\">";
		if ($newTOC != "5") { print OUTFILE "<br>"; }
		# print OUTFILE "</table><br>";

		print OUTFILE "<table class=\"hd_toc_table\" border=\"0\" cellpadding=\"0\" cellspacing=\"2\" width=\"148\">\n";
		print OUTFILE "<tr><td class=\"toc_leadspace\"></td><td colspan=\"2\"><font size=\"5\" color=\"#330066\"><b>$tocTitlePrefix</b></font></td></tr>\n";
		print OUTFILE "<tr><td class=\"toc_leadspace\">&nbsp;</td><td class=\"disclosure_triangle_td\">&nbsp;</td><td class=\"toc_contents_text\"><b><font size=\"+1\">$name</font></b></td></tr>\n";
		print OUTFILE "<tr><td></td><td colspan=\"2\">\n";
		print OUTFILE $fileString;
		print OUTFILE "</td></tr>\n";
		print OUTFILE "</table><p>&nbsp;<p>\n";
		print OUTFILE "</td></tr></table>\n";
		print OUTFILE "</body></html>\n";
	}
	close OUTFILE;

    if ($newTOC == 3) {
	$HeaderDoc::newTOC = 2;
	$self->createTOCFile();
	$HeaderDoc::newTOC = 3;
    }
}

# /*!
#     @abstract
#         Generates the content HTML file (right-side frame).
#     @discussion
#         In "class as composite" mode, this function does not
#         get called.  Instead, {@link writeHeaderElementsToCompositePage}
#         is used.
#
#         Otherwise, this function just writes the introduction
#         for the header or class itself, and the other
#         right-side content is written later by a call to
#         {@link writeHeaderElements}.
#     @param self
#         The <code>APIOwner</code> object.
# */
sub createContentFile {

    my $self = shift;
    my $class = ref($self);
    my $copyrightOwner = $class->copyrightOwner();
    my $filename = $self->filename();
    my $name = $self->name();
    my $title = $filename;
    my $throws = $self->throws();
    if (!length($name)) {
	$name = "$filename";
    } else {
	$title = "$name ($filename)";
    }
    my $short_attributes = $self->getAttributes(0);
    my $long_attributes = $self->getAttributes(1);
    my $list_attributes = $self->getAttributeLists(0);

    my $newTOC = $HeaderDoc::newTOC;

    # print STDERR "newTOC: $newTOC\n";

    my $rootFileName = $self->filename();
    my $fullpath = $self->fullpath();

    if ($class eq "HeaderDoc::Header") {
	my $headercopyright = $self->headerCopyrightOwner();
	if (!($headercopyright eq "")) {
	    $copyrightOwner = $headercopyright;
	}
    }

    my $HTMLmeta = "";
    # if ($class eq "HeaderDoc::Header") {
	$HTMLmeta = $self->HTMLmeta();
    # }
    # if ($self->outputformat() eq "html") {
	# $HTMLmeta .= $self->styleSheet(0);
    # }

    my $fileString = "";

    $rootFileName =~ s/(.*)\.h/$1/o; 
    # for now, always shorten long names since some files may be moved to a Mac for browsing
    if (1 || $isMacOS) {$rootFileName = &safeName(filename => $rootFileName);};
    my $outputFileName = "$rootFileName.html";    
    my $rootDir = $self->outputDir();
    my $outputFile = "$rootDir$pathSeparator$outputFileName";    
    calcDepth($outputFile);

   	open (OUTFILE, ">$outputFile") || die "Can't write header-wide content page $outputFile. \n$!\n";
    if ($isMacOS) {MacPerl::SetFileInfo('MSIE', 'TEXT', "$outputFile");};


    my $headerDiscussion = $self->discussion();    
    my $checkDisc = $self->halfbaked_discussion();
    my $headerAbstract = $self->abstract();  
    if (($checkDisc !~ /\S/) && ($headerAbstract !~ /\S/)) {
	my $linenum = $self->linenum();
        warn "$fullpath:$linenum: No header or class discussion/abstract found. Creating dummy file for default content page.\n";
	$headerAbstract .= $HeaderDoc::defaultHeaderComment; # "Use the links in the table of contents to the left to access documentation.<br>\n";    
    }
	$fileString .= "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n    \"http://www.w3.org/TR/1998/REC-html40-19980424/loose.dtd\">\n";
	$fileString .= "<html><HEAD>\n    <title>API Documentation</title>\n	$HTMLmeta <meta name=\"generator\" content=\"HeaderDoc\" />\n<meta name=\"xcode-display\" content=\"render\" />\n";
	$fileString .= $self->styleSheet(0);
	$fileString .= "</HEAD>\n<BODY bgcolor=\"#ffffff\">\n";
	if ($HeaderDoc::insert_header) {
		$fileString .= "<!-- start of header -->\n";
		$fileString .= $self->htmlHeader()."\n";
		$fileString .= "<!-- end of header -->\n";
	}
	$fileString .= "<a name=\"top\"></a>\n";
	$fileString .= "<H1>$name</H1><hr class=\"afterClassOrHeaderHeading\">\n";

	my $namespace = $self->namespace();
	my $availability = $self->availability();
	my $updated = $self->updated();
	my $includeList = "";
	if ($class eq "HeaderDoc::Header") {
	    my $includeref = $HeaderDoc::perHeaderIncludes{$filename};
	    if ($includeref) {
		my @includes = @{$includeref};

		my $first = 1;
		foreach my $include (@includes) {
			my $localDebug = 0;
			print STDERR "Included file: $include\n" if ($localDebug);

			if (!$first) {
				if ($newTOC) { $includeList .= "<br>\n"; }
				else { $includeList .= ",\n"; }
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
 	if (length($updated) || length($namespace) || length($availability) || length($includeList)) {
	    $fileString .= "<p></p>\n";
	}

	my $attstring = ""; my $c = 0;
	if (length($namespace)) {
		if ($newTOC) {
			if (!$c) {
				$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
			}
			$attstring .= "<tr><td scope=\"row\"><b>Namespace:</b></td><td><div class=\"spec_sheet_namespace spec_sheet_line\" style=\"margin-bottom:1px\"><div class=\"content_text\">$namespace</div></div></td></tr>\n";
		} else {
			$attstring .= "<b>Namespace:</b> $namespace<br>\n";
		}
		$c++;
	}
	if (length($availability)) {      
		if ($newTOC) {
			if (!$c) {
				$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
			}
			$attstring .= "<tr><td scope=\"row\"><b>Availability:</b></td><td><div class=\"spec_sheet_availability spec_sheet_line\" style=\"margin-bottom:1px\"><div class=\"content_text\">$availability</div></div></td></tr>\n";
		} else {
			$attstring .= "<b>Availability:</b> $availability<br>\n";
		}
		$c++;
	}
	if (length($updated)) {      
		if ($newTOC) {
			if (!$c) {
				$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
			}
			$attstring .= "<tr><td scope=\"row\"><b>Updated:</b></td><td><div class=\"spec_sheet_updated spec_sheet_line\" style=\"margin-bottom:1px\"><div class=\"content_text\">$updated</div></div></td></tr>\n";
		} else {
			$attstring .= "<b>Updated:</b> $updated<br>\n";
		}
		$c++;
	}
	if (length($includeList)) {
		if ($newTOC) {
			if (!$c) {
				$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
			}
			$attstring .= "<tr><td scope=\"row\"><b>Includes:</b></td><td><div class=\"spec_sheet_includes spec_sheet_line\" style=\"margin-bottom:1px\"><div class=\"content_text\">$includeList</div></div></td></tr>\n";
		} else {
			$attstring .= "<b>Includes:</b> ";
			$attstring .= $includeList;
			$attstring .= "<br>\n";
		}
		$c++;
	}

	my $tempstring; my $oldc = $c;
	if (length($short_attributes)) {
	        $tempstring .= "$short_attributes"; $c++;
	}
	if (length($list_attributes)) {
	        $tempstring .= "$list_attributes"; $c++;
	}
	if ($newTOC) {
		# print STDERR "HERE (oldC=$oldc)\n";
		if ($c == 2) {
			$tempstring =~ s/<\/table><\/div>\s*<div.*?><table.*?>//s;
		}
		if ($oldc) { $tempstring =~ s/^\s*<div.*?><table.*?>//s; }
		$tempstring =~ s/<\/table><\/div>\s*$//s;
	}
	$attstring .= $tempstring;
	if (!$newTOC) { $attstring .= "<dl>"; }
	if (length($throws)) {
		if ($newTOC) {
			if (!$c) {
				$attstring .= "<div class=\"spec_sheet_info_box\"><table cellspacing=\"0\" class=\"specbox\">\n";
			}
			$attstring .= "<tr><td scope=\"row\"><b>Throws:</b></td><td><div class=\"spec_sheet_throws spec_sheet_line\" style=\"margin-bottom:1px\"><div class=\"content_text\">$throws</div></div></td></tr>\n";
		} else {
			$attstring .= "<dt><i>Throws:</i></dt>\n<dd>$throws</dd>\n";
		}
		$c++;
	}
	# if (length($abstract)) {
		# $fileString .= "<dt><i>Abstract:</i></dt>\n<dd>$abstract</dd>\n";
	# }
	if ($newTOC) {
		if ($c) { $attstring .= "</table></div>\n"; }

		# Otherwise we do this later.
		$fileString .= $attstring;
	} else {
		$attstring .= "</dl>";
	}
	my $uid = $self->apiuid();

	if (length($headerAbstract)) {
	    # $fileString .= "<b>Abstract: </b>$headerAbstract<hr class=\"afterAbstract\"><br>\n";    
	    if ($self->can("isFramework") && $self->isFramework()) {
		$fileString .= "<!-- headerDoc=frameworkabstract;uid=".$uid.";name=start -->\n";
	    }
	    $fileString .= "$headerAbstract\n";    
	    if ($self->can("isFramework") && $self->isFramework()) {
		$fileString .= "<!-- headerDoc=frameworkabstract;uid=".$uid.";name=end -->\n";
	    }
	    $fileString .= "<br>\n";    
	}

	if (!$newTOC) {
		# Otherwise we do this earlier.
		$fileString .= $attstring;
	}
 	if (length($updated) || length($availability) || length($namespace) || length($headerAbstract) || length($short_attributes) || length($list_attributes) || length($includeList)) {
	    $fileString .= "<p></p>\n";
	    $fileString .= "<hr class=\"afterAttributes\"><br>\n";
	}

	my $discstart = $self->headerDocMark("discussion", "start");
	my $discend = $self->headerDocMark("discussion", "end");

	if ($self->can("isFramework") && $self->isFramework()) {
		$fileString .= "<!-- headerDoc=frameworkdiscussion;uid=".$uid.";name=start -->\n";
	} else {
		$fileString .= $discstart;
	}
	$fileString .= "$headerDiscussion\n";
	if ($self->can("isFramework") && $self->isFramework()) {
		$fileString .= "<!-- headerDoc=frameworkdiscussion;uid=".$uid.";name=end -->\n";
	} else {
		$fileString .= $discend;
	}
	$fileString .= "<br><br>\n";

	if (length($long_attributes)) {
	        $fileString .= "$long_attributes";
	}

	my @fields = $self->fields();
	if (@fields) {
		$fileString .= "<hr class=\"beforeTemplateParameters\"><h5 class='hd_templateparms'>Template Parameters</h5>";
		# print STDERR "\nGOT fields.\n";
		# $fileString .= "<table width=\"90%\" border=1>";
		# $fileString .= "<thead><tr><th>Name</th><th>Description</th></tr></thead>";
		$fileString .= "<dl>";
		for my $field (@fields) {
			my $name = $field->name();
			my $desc = $field->discussion();
			# print STDERR "field $name $desc\n";
			# $fileString .= "<tr><td><tt>$name</tt></td><td>$desc</td></tr>";
			$fileString .= "<dt><tt>$name</tt></dt><dd>$desc</dd>";
		}
		# $fileString .= "</table>\n";
		$fileString .= "</dl>\n";
	}
	$fileString .= "<hr class=\"beforeGroups\"><br><center>";
	$fileString .= $self->groupDoc("<h2 class=\"h2tight\" >Groups</h2>");
	if ($HeaderDoc::insert_header) {
		$fileString .= "<!-- start of footer -->\n";
		$fileString .= $self->htmlFooter()."\n";
		$fileString .= "<!-- end of footer -->\n";
	}
	$fileString .= "<hr class=\"afterFooter\">";
	$fileString .= "&#169; $copyrightOwner " if (length($copyrightOwner));
	my $filedate = $self->updated();
	if (length($filedate)) {
	    $fileString .= "Last Updated: $filedate\n";
	} else {
	    $fileString .= "Last Updated: $dateStamp\n";
	}
	$fileString .= "<br>";
	$fileString .= "<font size=\"-1\">HTML documentation generated by <a href=\"http://www.opensource.apple.com/projects\" target=\"_blank\">HeaderDoc</a></font>\n";    
	$fileString .= "</center>\n";
	$fileString .= "</body>\n</html>\n";

	print OUTFILE $self->fixup_inheritDoc(html_fixup_links($self, $fileString));

	close OUTFILE;
}

# /*!
#     @abstract
#         Writes a list of functions to standard output.
#     @discussion
#         The format of this list is subject to change
#         without notice.
#     @param self
#         The <code>APIOwner</code> object.
# */
sub writeFunctionListToStdOut {
    my $self = shift;

    my @functions = $self->functions();
    my @classes = $self->classes();
    my @protocols = $self->protocols();
    my @categories = $self->categories();

    foreach my $function (@functions) {
	print "FUNCTION: ".$function->name()."\n";
	# my $tree = ${$function->parseTree()};
	# print STDERR "PT: $tree\n";
	# bless($tree, "HeaderDoc::ParseTree");
	# $tree->dbprint();
	# $function->dbprint();
	my @lines = split(/\n/, $function->functionContents());
	foreach my $line (@lines) {
		print "\t$line\n"; # guarantee each line is indented for easy splitting in shell scripts later.
	}
    }
    foreach my $class (@classes) {
	$class->writeFunctionListToStdOut();
    }
    foreach my $protocol (@protocols) {
	$protocol->writeFunctionListToStdOut();
    }
    foreach my $category (@categories) {
	$category->writeFunctionListToStdOut();
    }

    return;
}

# /*! 
#     @abstract
#         Recursively ensures that the {@link apirefSetup} method has been called 
#         on everything that might get emitted later.
#  */
sub setupAPIReferences {

    my $self = shift;

    my @functions = $self->functions();
    my @methods = $self->methods();
    my @constants = $self->constants();
    my @typedefs = $self->typedefs();
    my @structs = $self->structs();
    my @vars = $self->vars();
    my @local_vars = ();
    if ($self->can("variables")) { @local_vars = $self->variables(); }
    my @enums = $self->enums();
    my @pDefines = $self->pDefines();
    my @classes = $self->classes();
    my @categories = $self->categories();
    my @protocols = $self->protocols();
    my @properties = $self->props();

    # pre-process everything to make sure we don't have any unregistered
    # api refs.
    my $prevignore = $HeaderDoc::ignore_apiuid_errors;
    $HeaderDoc::ignore_apiuid_errors = 1;

    my $junk = "";
    if (@functions) { foreach my $obj (@functions) { $junk = $obj->apirefSetup();}}
    if (@methods) { foreach my $obj (@methods) { $junk = $obj->apirefSetup();}}
    if (@constants) { foreach my $obj (@constants) { $junk = $obj->apirefSetup();}}
    if (@typedefs) { foreach my $obj (@typedefs) { $junk = $obj->apirefSetup();}}
    if (@structs) { foreach my $obj (@structs) { $junk = $obj->apirefSetup();}}
    if (@local_vars) { foreach my $obj (@local_vars) { $junk = $obj->apirefSetup();}}
    if (@vars) { foreach my $obj (@vars) { $junk = $obj->apirefSetup();}}
    if (@enums) { foreach my $obj (@enums) { $junk = $obj->apirefSetup();}}
    if (@pDefines) { foreach my $obj (@pDefines) { $junk = $obj->apirefSetup();}}
    if (@classes) { foreach my $obj (@classes) { $junk = $obj->apirefSetup(); $junk = $obj->docNavigatorComment(); $obj->setupAPIReferences(); }}
    if (@categories) { foreach my $obj (@categories) { $junk = $obj->apirefSetup(); $junk = $obj->docNavigatorComment(); $obj->setupAPIReferences(); }}
    if (@protocols) { foreach my $obj (@protocols) { $junk = $obj->apirefSetup(); $junk = $obj->docNavigatorComment(); $obj->setupAPIReferences(); }}
    if (@properties) { foreach my $obj (@properties) { $junk = $obj->apirefSetup();}}
    $HeaderDoc::ignore_apiuid_errors = $prevignore;
}

# /*!
#     @abstract
#         Writes the right-side content.
#     @discussion
#         In "class as composite" mode, this function's
#         purpose is handled by {@link writeHeaderElementsToCompositePage},
#         so it does not get called.
#
#         Otherwise, this function writes all of the
#         right-side content frames (e.g. Methods/Methods.html)
#         except for the introduction (which is written
#         by {@link writeHeaderElements}).
#     @param self
#         The <code>APIOwner</code> object.
# */
sub writeHeaderElements {
    my $self = shift;
    my $rootOutputDir = $self->outputDir();
    my $functionsDir = $self->functionsDir();
    my $methodsDir = $self->methodsDir();
    my $dataTypesDir = $self->datatypesDir();
    my $structsDir = $self->structsDir();
    my $constantsDir = $self->constantsDir();
    my $varsDir = $self->varsDir();
    my $propsDir = $self->propsDir();
    my $enumsDir = $self->enumsDir();
    my $pDefinesDir = $self->pDefinesDir();
    my $classesDir = $self->classesDir();
    my $protocolsDir = $self->protocolsDir();
    my $categoriesDir = $self->categoriesDir();

	if (! -e $rootOutputDir) {
		unless (mkdir ("$rootOutputDir", 0777)) {die ("Can't create output folder $rootOutputDir. \n$!");};
    }

    my $junk = "";
    my @functions = $self->functions();
    my @methods = $self->methods();
    my @constants = $self->constants();
    my @typedefs = $self->typedefs();
    my @structs = $self->structs();
    my @vars = $self->vars();
    my @local_vars = ();
    if ($self->can("variables")) { @local_vars = $self->variables(); }
    my @enums = $self->enums();
    my @pDefines = $self->pDefines();
    my @classes = $self->classes();
    my @properties = $self->props();

    # Check point.
    # if (1) {
	# print STDERR "CLASS LIST FOR $self (".$self->name().")\n";
	# foreach my $class (@classes) {
		# print STDERR "CLASS: $class (".$class->name().")\n";
	# }
    # }


    if (!$HeaderDoc::ClassAsComposite) {
    
        if ($self->functions()) {
		if (! -e $functionsDir) {
			unless (mkdir ("$functionsDir", 0777)) {die ("Can't create output folder $functionsDir. \n$!");};
	    }
	    $self->writeFunctions();
        }
        if ($self->methods()) {
		if (! -e $methodsDir) {
			unless (mkdir ("$methodsDir", 0777)) {die ("Can't create output folder $methodsDir. \n$!");};
	    }
	    $self->writeMethods();
        }
    
        if ($self->constants()) {
		if (! -e $constantsDir) {
			unless (mkdir ("$constantsDir", 0777)) {die ("Can't create output folder $constantsDir. \n$!");};
	    }
	    $self->writeConstants();
        }
    
        if ($self->typedefs()) {
		if (! -e $dataTypesDir) {
			unless (mkdir ("$dataTypesDir", 0777)) {die ("Can't create output folder $dataTypesDir. \n$!");};
	    }
	    $self->writeTypedefs();
        }
    
        if ($self->structs()) {
		if (! -e $structsDir) {
			unless (mkdir ("$structsDir", 0777)) {die ("Can't create output folder $structsDir. \n$!");};
	    }
	    $self->writeStructs();
        }
        if ($self->props()) {
		if (! -e $propsDir) {
			unless (mkdir ("$propsDir", 0777)) {die ("Can't create output folder $propsDir. \n$!");};
	    }
	    $self->writeProps();
        }
        if ($self->vars()) {
		if (! -e $varsDir) {
			unless (mkdir ("$varsDir", 0777)) {die ("Can't create output folder $varsDir. \n$!");};
	    }
	    $self->writeVars();
        }
        if ($self->enums()) {
		if (! -e $enumsDir) {
			unless (mkdir ("$enumsDir", 0777)) {die ("Can't create output folder $enumsDir. \n$!");};
	    }
	    $self->writeEnums();
        }

        if ($self->pDefines()) {
		if (! -e $pDefinesDir) {
			unless (mkdir ("$pDefinesDir", 0777)) {die ("Can't create output folder $pDefinesDir. \n$!");};
	    }
	    $self->writePDefines();
        }
    }

    # Always do this to create directories for nested classes.
    if ($self->classes()) {
		if (! -e $classesDir) {
			unless (mkdir ("$classesDir", 0777)) {die ("Can't create output folder $classesDir. \n$!");};
	    }
	    $self->writeClasses();
    }
    if ($self->protocols()) {
		if (! -e $protocolsDir) {
			unless (mkdir ("$protocolsDir", 0777)) {die ("Can't create output folder $protocolsDir. \n$!\n");};
	    }
	    $self->writeProtocols();
    }
    if ($self->categories()) {
		if (! -e $categoriesDir) {
			unless (mkdir ("$categoriesDir", 0777)) {die ("Can't create output folder $categoriesDir. \n$!\n");};
	    }
	    $self->writeCategories();
    }
}

# /*!
#     @abstract
#         Writes a Doxygen-style tag file.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         This function does not write the final tag file.
#         Instead, it writes a partial tag file that
#         represents the contents of a single header.
#         At the end of processing, HeaderDoc combines
#         these into a single tag file.
#  */
sub writeHeaderElementsToDoxyFile
{
    # Write a Doxygen-style tag file.

    my $self = shift;

    my $prespace = "";

    my $class = ref($self);
    my $doxyFilename = "doxytags.doxytagtemp";
    my $rootOutputDir = $self->outputDir();
    my $name = $self->name();

    my $doxyFileString = "<tagfile>\n".$self->_getDoxyTagString($prespace."  ")."</tagfile>\n";
    my $outputFile = $rootOutputDir.$pathSeparator.$doxyFilename;

	if (! -e $rootOutputDir) {
		unless (mkdir ("$rootOutputDir", 0777)) {die ("Can't create output folder $rootOutputDir. $!");};
    }

    if ($self->use_stdout()) {
	open(OUTFILE, ">&STDOUT");
    } else {
	open(OUTFILE, ">$outputFile") || die "Can't write $outputFile.\n";
    }
    print OUTFILE $doxyFileString;
    close OUTFILE;
}

# /*!
#     @abstract
#         Returns a Doxygen-style tagfile string.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElementsToDoxyFile}.
#  */
sub _getDoxyTagString {
    my $self = shift;
    my $prespace = shift;

    my $name = $self->name();
    my $doxykind = $self->getDoxyKind();
    my $doxyFileString = "$prespace<compound kind=\"$doxykind\">\n";

    $doxyFileString .= "$prespace<name>".$self->textToXML($self->rawname())."</name>\n";
    if ($doxykind eq "file") {
	$doxyFileString .= "$prespace<path>".$self->textToXML($self->fullpath())."</path>\n";
    }
    if ($self->checkShortLongAttributes("Superclass")) {
	my $inherits = $self->textToXML($self->checkShortLongAttributes("Superclass"));
	$inherits =~ s/\cA/,/sg;
	$inherits =~ s/\s+/ /sg;
	$inherits =~ s/^\s*//sg;
	$inherits =~ s/\s*$//sg;
	$doxyFileString .= "$prespace  <inherits>".$inherits."</inherits>\n";
    }
    if ($self->checkShortLongAttributes("Implements&nbsp;Class")) {
	$doxyFileString .= "$prespace  <implements>".$self->textToXML($self->checkShortLongAttributes("Extends&nbsp;Class"))."</implements>\n";
    }
    if ($self->checkShortLongAttributes("Extends&nbsp;Class")) {
	$doxyFileString .= "$prespace  <extendsClass>".$self->textToXML($self->checkShortLongAttributes("Extends&nbsp;Class"))."</extendsClass>\n";
    }
    if ($self->checkShortLongAttributes("Extends&nbsp;Protocol")) {
	$doxyFileString .= "$prespace  <extendsProtocol>".$self->textToXML($self->checkShortLongAttributes("Extends&nbsp;Class"))."</extendsProtocol>\n";
    }

    my @objects = $self->classes();
    foreach my $obj (@objects) {
	# print "CLASS: $obj\n";
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }

    @objects = $self->protocols();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }

    @objects = $self->categories();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }

    @objects = $self->functions();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }

    @objects = $self->methods();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }
    
    @objects = $self->constants();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }
    
    @objects = $self->typedefs();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }
    
    @objects = $self->structs();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }
    
    @objects = $self->props();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }

    @objects = $self->vars();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }
    
    @objects = $self->enums();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }
    
    @objects = $self->pDefines();
    foreach my $obj (@objects) {
	$doxyFileString .= $obj->_getDoxyTagString($prespace."  ");
    }

    $doxyFileString .= "$prespace</compound>\n";
    return $doxyFileString;
}


# /*!
#     @abstract
#         Writes a series of manual pages for a header's functions.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         This function requires the xmlman binaries to be
#         installed in /usr/bin.
#  */
sub writeHeaderElementsToManPage {
    my $self = shift;
    my $class = ref($self);
    my $compositePageName = $self->filename();
    my $localDebug = 0;

    # $compositePageName =~ s/\.(h|i)$//o;
    $compositePageName .= ".mxml";
    my $rootOutputDir = $self->outputDir();
    my $tempOutputDir = $rootOutputDir."/mantemp";
    my $XMLPageString = $self->_getXMLPageString();
    my $section = $HeaderDoc::man_section;

    mkdir($tempOutputDir, 0777);

    my $cwd = cwd();
    chdir($tempOutputDir);

    # print STDERR "SECTION: \"$section\"\n";

    open(OUTFILE, "|/usr/bin/hdxml2manxml -M $section");
    print OUTFILE $XMLPageString;
    print STDERR "WROTE: $XMLPageString\n" if ($localDebug);
    close(OUTFILE);

    my @files = <*.mxml>;

    foreach my $file (@files) {
	system("/usr/bin/xml2man \"$file\"");
	unlink($file);
    }

    chdir($cwd);

    @files = <${tempOutputDir}/*>;
    foreach my $file (@files) {
	my $filename = basename($file);
	print STDERR "RENAMING $file to $rootOutputDir/$filename\n" if ($localDebug);
	rename($file, "$rootOutputDir/$filename");
    }
    rmdir("$tempOutputDir");

}

# /*!
#     @abstract
#         Writes output to an XML file.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub writeHeaderElementsToXMLPage { # All API in a single XML page
    my $self = shift;
    my $class = ref($self);
    my $compositePageName = $self->filename();
    # $compositePageName =~ s/\.(h|i)$//o;
    $compositePageName .= ".xml";
    my $rootOutputDir = $self->outputDir();
    my $name = $self->textToXML($self->name());
    my $XMLPageString = $self->_getXMLPageString();
    my $outputFile = $rootOutputDir.$pathSeparator.$compositePageName;
# print STDERR "cpn = $compositePageName\n";
    
    if (!$self->use_stdout()) {
	if (! -e $rootOutputDir) {
		unless (mkdir ("$rootOutputDir", 0777)) {die ("Can't create output folder $rootOutputDir. $!");};
	}
    }
    $self->_createXMLOutputFile($outputFile, xml_fixup_links($self, $XMLPageString), "$name");
}

# /*!
#     @abstract
#         Writes output to the composite page.
#     @discussion
#         In "class as composite" mode, this function supersedes
#         the function {@link createContentFile}.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub writeHeaderElementsToCompositePage { # All API in a single HTML page -- for printing
    my $self = shift;
    my $class = ref($self);
    my $compositePageName = $class->compositePageName();
    my $rootOutputDir = $self->outputDir();
    my $name = $self->name();
    my $compositePageString = $self->_getCompositePageString();
    # $compositePageString = $self->stripAppleRefs($compositePageString);
    my $outputFile = $rootOutputDir.$pathSeparator.$compositePageName;

# print STDERR "OUTFILE: $outputFile\n";

	if (! -e $rootOutputDir) {
		unless (mkdir ("$rootOutputDir", 0777)) {die ("Can't create output folder $rootOutputDir. $!");};
    }

# print STDERR "PRE: $compositePageString\n";

    my $processed_string = html_fixup_links($self, $compositePageString);

# print STDERR "DUMP: $processed_string\n";

    $self->_createHTMLOutputFile($outputFile, $processed_string, "$name", 1);
}

# /*!
#     @abstract
#         Writes the protocols in a header object to a composite page.
#     @param self
#         The <code>Header</code> object.
# */
sub writeProtocols {
    my $self = shift;
    my @protocolObjs = $self->protocols();
    my $protocolsRootDir = $self->protocolsDir();
        
    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @protocolObjs;
    } else {
	@tempobjs = @protocolObjs;
    }
    foreach my $obj (@tempobjs) {
        my $protocolName = $obj->name();
        # for now, always shorten long names since some files may be moved to a Mac for browsing
        if (1 || $isMacOS) {$protocolName = &safeName(filename => $protocolName);};
        $obj->outputDir("$protocolsRootDir$pathSeparator$protocolName");
        $obj->createFramesetFile();
        $obj->createContentFile() if (!$HeaderDoc::ClassAsComposite);
	$obj->writeHeaderElementsToCompositePage();
        $obj->createTOCFile();
        $obj->writeHeaderElements();
    }
}

# /*!
#     @abstract
#         Writes the categories in a header object to a composite page.
#     @param self
#         The <code>Header</code> object.
# */
sub writeCategories {
    my $self = shift;
    my @categoryObjs = $self->categories();
    my $categoriesRootDir = $self->categoriesDir();
        
    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @categoryObjs;
    } else {
	@tempobjs = @categoryObjs;
    }
    foreach my $obj (@tempobjs) {
        my $categoryName = $obj->name();
        # for now, always shorten long names since some files may be moved to a Mac for browsing
        if (1 || $isMacOS) {$categoryName = &safeName(filename => $categoryName);};
        $obj->outputDir("$categoriesRootDir$pathSeparator$categoryName");
        $obj->createFramesetFile();
        $obj->createContentFile() if (!$HeaderDoc::ClassAsComposite);
	$obj->writeHeaderElementsToCompositePage();
        $obj->createTOCFile();
        $obj->writeHeaderElements(); 
    }
}

# /*!
#     @abstract
#         Generates output string for storing in an XML file.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         This function is called by {@link writeHeaderElementsToXMLPage}.
#  */
sub _getXMLPageString {
    my $self = shift;
    my $name = $self->name();
    my $compositePageString;
    my $contentString;

    return $self->XMLdocumentationBlock(0);
    
}

# /*!
#     @abstract
#         Generates output string for storing in the composite page.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         This function is called by {@link writeHeaderElementsToCompositePage}.
#  */
sub _getCompositePageString { 
    my $self = shift;
    my $name = $self->name();
    my $compositePageString;
    my $list_attributes = $self->getAttributeLists(1);
    my $short_attributes = $self->getAttributes(0);
    my $long_attributes = $self->getAttributes(1);

    if (!$HeaderDoc::use_iframes) {
	$compositePageString .= $self->compositePageAPIRef();
    }

    $compositePageString .= $self->documentationBlock();
    
    my $firstsection = 1;

    my $classEmbeddedTOC = $self->_getClassEmbeddedTOC(1);
    my $groupDocString = $self->groupDoc("<h2 class=\"h2tight\" >Groups</h2>");
    my $functionDocString = $self->_getFunctionDetailString(1);
    my $methodDocString = $self->_getMethodDetailString(1);
    my $constantDocString = $self->_getConstantDetailString(1);
    my $typedefDocString = $self->_getTypedefDetailString(1);
    my $structDocString = $self->_getStructDetailString(1);
    my $propDocString = $self->_getPropDetailString(1);
    my $varDocString = $self->_getVarDetailString(1);
    my $enumDocString = $self->_getEnumDetailString(1);
    my $defineDocString = $self->_getPDefineDetailString(1);

    my $onlyClasses = 1;
    if ($groupDocString || $functionDocString || $methodDocString ||
        $constantDocString || $typedefDocString || $structDocString ||
        $propDocString || $varDocString || $enumDocString ||
        $defineDocString) {
		$onlyClasses = 0;
    }

    if ((!$onlyClasses) || $classEmbeddedTOC) {
	# Leave out this if there are no classes and no other API elements.
	$compositePageString .= "<hr class=\"afterClassOrHeaderInfo\"><br>";
    }

    if (length($classEmbeddedTOC)) {
	$compositePageString .= $classEmbeddedTOC;
	if (!$onlyClasses) {
		# Classes are special because they contain no documentation
		# inline other than the links and abstracts.  Thus,
		# the trailing <hr> tag is only needed if the header
		# contains other API symbols.
		$compositePageString .= "<hr class=\"afterClassEmbeddedTOC\"><br>";
	}
    }

    if (length($groupDocString)) {
	    $compositePageString .= $groupDocString;

	    # Do NOT do this.  There is already an afterGroupHeading marker.
	    # if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    # $firstsection = 0;
    }

    if (length($functionDocString)) {
	    # $compositePageString .= "<h2 class=\"h2tight\" >Functions</h2>\n";
		# $functionDocString = $self->stripAppleRefs($functionDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $functionDocString;
    }

    if (length($methodDocString)) {
	    # $compositePageString .= "<h2 class=\"h2tight\" >Methods</h2>\n";
		# $methodDocString = $self->stripAppleRefs($methodDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $methodDocString;
    }
    
    if (length($constantDocString)) {
	    # $compositePageString .= "<h2 class=\"h2tight\" >Constants</h2>\n";
		# $constantDocString = $self->stripAppleRefs($constantDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $constantDocString;
    }
    
    if (length($typedefDocString)) {
	    # $compositePageString .= "<h2 class=\"h2tight\" >Typedefs</h2>\n";
		# $typedefDocString = $self->stripAppleRefs($typedefDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $typedefDocString;
    }
    
    if (length($structDocString)) {
	    # $compositePageString .= "<h2 class=\"h2tight\" >Structs&nbsp;and&nbsp;Unions</h2>\n";
		# $structDocString = $self->stripAppleRefs($structDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $structDocString;
    }
    
    if (length($propDocString)) {
	    my $class = ref($self) || $self;
	    # my $globalname = "Properties";
	    # my $baseref = "Properties/Properties.html";
	    # $compositePageString .= "<h2 class=\"h2tight\" >$globalname</h2>\n";
		# $propDocString = $self->stripAppleRefs($propDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $propDocString;
    }

    if (length($varDocString)) {
	    my $class = ref($self) || $self;
	    # my $globalname = "Globals";
	    # if ($class ne "HeaderDoc::Header") {
		# $globalname = "Member Data";
	    # }
	    # my $baseref = "Vars/Vars.html";
	    # $compositePageString .= "<h2 class=\"h2tight\" >$globalname</h2>\n";
		# $varDocString = $self->stripAppleRefs($varDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $varDocString;
    }
    
    if (length($enumDocString)) {
            # $compositePageString .= "<h2 class=\"h2tight\" >Enumerations</h2>\n";
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
            $compositePageString .= $enumDocString;
    }
    
    if (length($defineDocString)) {
	    # $compositePageString .= "<h2 class=\"h2tight\" >#defines</h2>\n";
		# $defineDocString = $self->stripAppleRefs($defineDocString);
	    if (!$firstsection) { $compositePageString .= "<hr class=\"betweenSections\">\n"; }
	    $firstsection = 0;
	    $compositePageString .= $defineDocString;
    }
    return $compositePageString;
}

# /*!
#     @abstract
#         Strips apple_ref markup from the composite page output.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         An apple_ref marker is a named anchor that uniquely identifies
#         each API symbol.  For example, an Objective-C class named Foo
#         would have the anchor &lt;a name="//apple_ref/occ/cl/Foo">&lt;/a>.
#         This markup is already in the primary documentation pages, so
#         the duplicates must be removed from the composite pages.  See
#         the {@linkplain //apple_ref/doc/uid/TP40001215-CH347
#         Symbol Markers for HTML-Based Documentation} in
#         {@linkdoc //apple_ref/doc/uid/TP40001215 HeaderDoc User Guide}
#         to learn more about apple_ref markup.
#  */
sub stripAppleRefs {
    my $self = shift;
    my $string = shift;
    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();

	$string =~ s|<a\s+name\s*=\s*\"//\Q$apiUIDPrefix\E/[^"]+?\">(.*?)<\s*/a\s*>|$1|g;
	return $string;
}

# /*!
#     @abstract
#         Returns an apple_ref marker for a header/class composite page.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub compositePageAPIRef
{
    my $self = shift;
    my $name = $self->name();

    my $uid = $self->compositePageAPIUID();
    my $apiref = "<a name=\"$uid\" title=\"$name\"></a>\n";

    return $apiref;
}

# /*!
#     @abstract
#         Returns an apple_ref UID for a header/class composite page.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link compositePageAPIRef}.
#  */
sub compositePageAPIUID
{
    my $self = shift;
    my $class = ref($self) || $self;
    my $apiUIDPrefix = HeaderDoc::APIOwner->apiUIDPrefix();
    my $type = "header";

    SWITCH : {
	($class eq "HeaderDoc::CPPClass") && do {
		$type = "class";
	    };
	($class eq "HeaderDoc::ObjCCategory") && do {
		$type = "class";
	    };
	($class eq "HeaderDoc::ObjCClass") && do {
		$type = "class";
	    };
	($class eq "HeaderDoc::ObjCContainer") && do {
		$type = "class";
	    };
	($class eq "HeaderDoc::ObjCProtocol") && do {
		$type = "protocol";
	    };
    }
    my $shortname = $self->name();
    if ($class eq "HeaderDoc::Header") {
	$shortname = $self->filename();
	$shortname =~ s/\.hdoc$//so;
    }
    $shortname = sanitize($shortname, 1);
    if ($self->isFramework()) { $type = "framework"; }
    # print "TYPE: $type\n";

    my $apiuid = "//$apiUIDPrefix/doc/$type/$shortname";

    my $requested = $self->requestedUID();
    if ($requested) { return $requested; };

    return $apiuid;
}

# /*!
#     @abstract
#         Writes the right-side content for functions in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeFunctions {
    my $self = shift;
    my $functionFile = $self->functionsDir().$pathSeparator."Functions.html";
    my $class = ref($self) || $self;

    my $funchead = "Functions";
    if ($class ne "HeaderDoc::Header") {
	$funchead = "Member Functions";
    }

    $self->_createHTMLOutputFile($functionFile, $self->_getFunctionDetailString(0), $funchead, 0);
}

# /*!
#     @abstract
#         Returns the right-side content for functions in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeFunctions}.
#  */
sub _getFunctionDetailString {
    my $self = shift;
    my $composite = shift;
    my @funcObjs = $self->functions();
    my $contentString = "";
    my $class = ref($self) || $self;

    my $funchead = "Functions";
    if ($class ne "HeaderDoc::Header") {
	$funchead = "Member Functions";
    }


    # $contentString .= $self->_getFunctionEmbeddedTOC($composite);
    $contentString .= $self->_getDetailString(\@funcObjs, $composite, "functions", $funchead);
    return $contentString;

    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @funcObjs;
    # } else {
	# @tempobjs = @funcObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for functions in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getFunctionXMLDetailString {
    my $self = shift;
    my @funcObjs = $self->functions();
    my $contentString = "";

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @funcObjs;
    } else {
	@tempobjs = @funcObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for classes in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getEmbeddedClassXMLDetailString {
    my $self = shift;
    my $classObjsRef = shift;
    my @classObjs = @{$classObjsRef};
    my $contentString = "";

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @classObjs;
    } else {
	@tempobjs = @classObjs;
    }
    foreach my $obj (@tempobjs) {
	# print STDERR "outputting class ".$obj->name.".";
	my $documentationBlock = $obj->XMLdocumentationBlock();
	$contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for classes in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getClassXMLDetailString {
    my $self = shift;
    my @classObjs = $self->classes();
    my $contentString = "";

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @classObjs;
    } else {
	@tempobjs = @classObjs;
    }
    foreach my $obj (@tempobjs) {
	# print STDERR "outputting class ".$obj->name.".";
	my $documentationBlock = $obj->XMLdocumentationBlock();
	$contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for categories in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getCategoryXMLDetailString {
    my $self = shift;
    my @classObjs = $self->categories();
    my $contentString = "";

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @classObjs;
    } else {
	@tempobjs = @classObjs;
    }
    foreach my $obj (@tempobjs) {
	# print STDERR "outputting category ".$obj->name.".";
	my $documentationBlock = $obj->XMLdocumentationBlock();
	$contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for protocols in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getProtocolXMLDetailString {
    my $self = shift;
    my @classObjs = $self->protocols();
    my $contentString = "";

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @classObjs;
    } else {
	@tempobjs = @classObjs;
    }
    foreach my $obj (@tempobjs) {
	# print STDERR "outputting protocol ".$obj->name.".";
	my $documentationBlock = $obj->XMLdocumentationBlock();
	$contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for methods in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeMethods {
    my $self = shift;
    my $methodFile = $self->methodsDir().$pathSeparator."Methods.html";
    $self->_createHTMLOutputFile($methodFile, $self->_getMethodDetailString(0), "Methods", 0);
}

# /*!
#     @abstract
#         Returns an embedded mini-TOC.
#     @param self
#         The <code>APIOwner</code> object.
#     @param listref
#         A reference to a list of objects.
#     @param typeFile
#         The raw type name (e.g. Functions, Methods).  Used for generating
#         the filename for links.
#     @param tag
#         The tag type name (e.g. function).  Used for generating the jump
#         link to the heading.
#     @param displaytype
#         The human-readable name of the type.  Used in headings.
#     @param compositePage
#         Pass 1 if this is being generated for a composite page, else 0.
#     @param includeObjectName
#         Pass 1 if the object name is a path component, else 0.
#         In effect, pass 1 for classes and similar, 0 for normal data types,
#         functions, variables, etc.
#     @discussion
#         This function generates the embedded mini-TOC
#         that appears at the top of various sections
#         in the right-side content.
#  */
sub _getEmbeddedTOC
{
    my $self = shift;
    my $listref = shift;
    my $typeFile = shift;
    my $tag = shift;
    my $displaytype = shift;
    my $compositePage = shift;
    my $includeObjectName = shift;

# print STDERR "TYPEFILE: $typeFile\n";

    my $group_mode = 0;
    if (@_) {
	$group_mode = shift;
    }
    my $localDebug = 0;

    print STDERR "CPAGE: $compositePage\n" if ($localDebug);

    my @objlist = @{ $listref };
    my $eTOCString = "";
    my $class = ref($self) || $self;
    my $compositePageName = $self->compositePageName();

    my $processed_tag = $tag;
    $processed_tag =~ s/\s//sg;
    $processed_tag = lc($processed_tag);
    if (!$group_mode) {
	$eTOCString .= "<a name=\"HeaderDoc_$processed_tag\"></a>\n";
    }
    if ($includeObjectName) {
	$eTOCString .= "<h2 class=\"h2tight\">$displaytype</h2>\n";
    }

    print STDERR "My class is $class\n" if ($localDebug);

    if (!scalar(@objlist)) {
	print STDERR "empty objlist\n" if ($localDebug);
	return "";
    }
    # if (!($#objlist)) {
	# print STDERR "empty objlist\n" if ($localDebug);
	# return "";
    # }

    $eTOCString .= "<dl>\n";
    foreach my $obj (@objlist) {
	if ($obj->isInternal() && !$HeaderDoc::document_internal) { next; }
	# print STDERR "@objlist\n";
	# print STDERR "OBJ: $obj\n";
	my $name = $obj->name();
	my $abstract = $obj->abstract();
	my $url = "";

	my $target = "doc";
	my $composite = $HeaderDoc::ClassAsComposite;
	# if ($class eq "HeaderDoc::Header") { $composite = 0; }

	if ($compositePage && !$composite) { $composite = 1; $target = "_top"; }
	if ($obj->isAPIOwner()) {
		$target = "_top";
		$composite = 0;
	}

	if ($HeaderDoc::use_iframes) {
		$target = "_top";
	}

	my $safeName = $name;
	$safeName = &safeName(filename => $name);

	my $urlname = $obj->apiuid(); # sanitize($name);
	if ($composite && !$HeaderDoc::ClassAsComposite) {
		$urlname = $obj->compositePageUID();
	}

# print STDERR "ION: $includeObjectName TF: $typeFile\n";

	if (($includeObjectName == 1) && $composite) {
	    $url = "$typeFile/$safeName/$compositePageName#$urlname";
	} elsif ($includeObjectName == 1) {
	    $url = "$typeFile/$safeName/index.html#$urlname";
	} elsif ($composite) {
	    $url = "$compositePageName#$urlname"
	} else {
	    $url = "$typeFile#$urlname"
	}

	my $parentclass = $obj->origClass();
	if (length($parentclass)) { $parentclass .= "::"; }
	if ($self->CClass()) {
		# Don't do this for pseudo-classes.
		$parentclass = "";
	}
	my $objclass = ref($obj) || $obj;
	if ($obj =~ /HeaderDoc::Method/) {
		if ($obj->isInstanceMethod() eq "YES") {
			$parentclass = "-";
		} else {
			$parentclass = "+";
		}
		# print STDERR "OCC: IIM: ".$obj->isInstanceMethod()."\n";
	}

	$eTOCString .= "<dt><tt>";
	if (!$group_mode) {
		$eTOCString .= "<a href=\"$url\" target=\"$target\">$parentclass$name</a>";
	} else {
		$eTOCString .= "<!-- a logicalPath=\"".$obj->apiuid()."\" target=\"$target\" machineGenerated=\"true\" -->$parentclass$name<!-- /a -->";
	}
	$eTOCString .= "</tt></dt>\n";
	$eTOCString .= "<dd>$abstract</dd>\n";
    }
    $eTOCString .= "</dl>\n";

print STDERR "etoc: $eTOCString\n" if ($localDebug);

    return $eTOCString;
}

# /*!
#     @abstract
#         Returns the embedded mini-TOC for classes.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         This function generates the embedded mini-TOC
#         that appears at the top of the Classes section
#         in the right-side content.
#
#         This function is a wrapper for {@link _getEmbeddedTOC}
#         that generates separate embedded TOCs for classes,
#         categories, protocols, and COM interfaces.
#  */
sub _getClassEmbeddedTOC
{
    my $self = shift;
    my $composite = shift;
    my @possclasses = $self->classes();
    my @protocols = $self->protocols();
    my @categories = $self->categories();
    my $localDebug = 0;

    my $retval = "";

    print STDERR "getClassEmbeddedTOC: processing ".$self->name()."\n" if ($localDebug);

    my @classes = ();
    my @comints = ();

    foreach my $class (@possclasses) {
	if ($class->isCOMInterface()) {
	    push(@comints, $class);
	} else  {
	    push(@classes, $class);
	}
    }

    if (scalar(@classes)) {
	print STDERR "getClassEmbeddedTOC: classes found.\n" if ($localDebug);
	my @tempobjs = ();
	if (!$self->unsorted()) {
		@tempobjs = sort objName @classes;
	} else {
		@tempobjs = @classes;
	}
	if ($localDebug) {
		foreach my $item(@tempobjs) {
			print STDERR "TO: $item : ".$item->name()."\n";
		}
	}
	$retval .= $self->_getEmbeddedTOC(\@tempobjs, "Classes", "classes", "Classes", $composite, 1);
    }
    if (scalar(@comints)) {
	print STDERR "getClassEmbeddedTOC: comints found.\n" if ($localDebug);
	my @tempobjs = ();
	if (!$self->unsorted()) {
		@tempobjs = sort objName @comints;
	} else {
		@tempobjs = @comints;
	}
	if ($localDebug) {
		foreach my $item(@tempobjs) {
			print STDERR "TO: $item : ".$item->name()."\n";
		}
	}
	$retval .= $self->_getEmbeddedTOC(\@tempobjs, "Classes", "classes", "C Pseudoclasses", $composite, 1);
    }
    if (scalar(@protocols)) {
	print STDERR "getClassEmbeddedTOC: protocols found.\n" if ($localDebug);
	my @tempobjs = ();
	if (!$self->unsorted()) {
		@tempobjs = sort objName @protocols;
	} else {
		@tempobjs = @protocols;
	}
	if ($localDebug) {
		foreach my $item(@tempobjs) {
			print STDERR "TO: $item : ".$item->name()."\n";
		}
	}
	$retval .= $self->_getEmbeddedTOC(\@tempobjs, "Protocols", "protocols", "Protocols", $composite, 1);
    }
    if (scalar(@categories)) {
	print STDERR "getClassEmbeddedTOC: categories found.\n" if ($localDebug);
	my @tempobjs = ();
	if (!$self->unsorted()) {
		@tempobjs = sort objName @categories;
	} else {
		@tempobjs = @categories;
	}
	if ($localDebug) {
		foreach my $item(@tempobjs) {
			print STDERR "TO: $item : ".$item->name()."\n";
		}
	}
	$retval .= $self->_getEmbeddedTOC(\@tempobjs, "Categories", "categories", "Categories", $composite, 1);
    }

    print STDERR "eClassTOC = $retval\n" if ($localDebug);

   return $retval;
}


# /*!
#     @abstract
#         Returns the right-side content for methods in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeMethods}.
#  */
sub _getMethodDetailString {
    my $self = shift;
    my $composite = shift;
    my @methObjs = $self->methods();
    my $contentString = "";
    my $localDebug = 0;

    # $contentString .= $self->_getMethodEmbeddedTOC($composite);
    $contentString .= $self->_getDetailString(\@methObjs, $composite, "methods", "Methods");
    return $contentString;

    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @methObjs;
    # } else {
	# @tempobjs = @methObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for methods in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getMethodXMLDetailString {
    my $self = shift;
    my @methObjs = $self->methods();
    my $contentString = "";

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @methObjs;
    } else {
	@tempobjs = @methObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for constants in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeConstants {
    my $self = shift;
    my $constantsFile = $self->constantsDir().$pathSeparator."Constants.html";
    $self->_createHTMLOutputFile($constantsFile, $self->_getConstantDetailString(0), "Constants", 0);
}

# /*!
#     @abstract
#         Returns the right-side content for constants in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeConstants}.
#  */
sub _getConstantDetailString {
    my $self = shift;
    my $composite = shift;
    my @constantObjs = $self->constants();
    my $contentString;

    return $self->_getDetailString(\@constantObjs, $composite, "constants", "Constants");

    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @constantObjs;
    # } else {
	# @tempobjs = @constantObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for constants in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getConstantXMLDetailString {
    my $self = shift;
    my @constantObjs = $self->constants();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @constantObjs;
    } else {
	@tempobjs = @constantObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for typdefs in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeTypedefs {
    my $self = shift;
    my $typedefsFile = $self->datatypesDir().$pathSeparator."DataTypes.html";
    $self->_createHTMLOutputFile($typedefsFile, $self->_getTypedefDetailString(0), "Defined Types", 0);
}

# /*!
#     @abstract
#         Returns the right-side content for typedefs in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeTypedefs}.
#  */
sub _getTypedefDetailString {
    my $self = shift;
    my $composite = shift;
    my @typedefObjs = $self->typedefs();
    my $contentString;

    return $self->_getDetailString(\@typedefObjs, $composite, "DataTypes", "Typedefs");

    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @typedefObjs;
    # } else {
	# @tempobjs = @typedefObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for typedefs in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getTypedefXMLDetailString {
    my $self = shift;
    my @typedefObjs = $self->typedefs();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @typedefObjs;
    } else {
	@tempobjs = @typedefObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for structs in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeStructs {
    my $self = shift;
    my $structsFile = $self->structsDir().$pathSeparator."Structs.html";
    $self->_createHTMLOutputFile($structsFile, $self->_getStructDetailString(0), "Structs", 0);
}

# /*!
#     @abstract
#         Returns the right-side content for structs in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeStructs}.
#  */
sub _getStructDetailString {
    my $self = shift;
    my $composite = shift;
    my @structObjs = $self->structs();
    my $contentString;

    return $self->_getDetailString(\@structObjs, $composite, "structs", "Structs&nbsp;and&nbsp;Unions");

    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @structObjs;
    # } else {
	# @tempobjs = @structObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for structs in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getStructXMLDetailString {
    my $self = shift;
    my @structObjs = $self->structs();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @structObjs;
    } else {
	@tempobjs = @structObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for variables in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeVars {
    my $self = shift;
    my $class = ref($self) || $self;
    my $globalname = "Globals";
    if ($class ne "HeaderDoc::Header") {
	$globalname = "Member Data";
    }
    my $varsFile = $self->varsDir().$pathSeparator."Vars.html";
    $self->_createHTMLOutputFile($varsFile, $self->_getVarDetailString(0), "$globalname", 0);
}

# /*!
#     @abstract
#         Writes the right-side content for properties in this class.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeProps {
    my $self = shift;
    my $propsFile = $self->propsDir().$pathSeparator."Properties.html";
    $self->_createHTMLOutputFile($propsFile, $self->_getPropDetailString(0), "Properties", 0);
}

# /*!
#     @abstract
#         Returns the right-side content for properties in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeProps}.
#  */
sub _getPropDetailString {
    my $self = shift;
    my $composite = shift;
    my @propObjs = $self->props();

    return $self->_getDetailString(\@propObjs, $composite, "props", "Properties");
}

# /*!
#     @abstract
#         Returns the right-side content for variables in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeVars}.
#  */
sub _getVarDetailString {
    my $self = shift;
    my $composite = shift;
    my @varObjs = $self->vars();

    my $globalname = "Globals";

    my $class = ref($self) || $self;
    if ($class ne "HeaderDoc::Header") {
	$globalname = "Member Data";
    }
    return $self->_getDetailString(\@varObjs, $composite, "vars", $globalname);

    # my $contentString;
    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @varObjs;
    # } else {
	# @tempobjs = @varObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for properties in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getPropXMLDetailString {
    my $self = shift;
    my @propObjs = $self->props();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @propObjs;
    } else {
	@tempobjs = @propObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for variables in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getVarXMLDetailString {
    my $self = shift;
    my @varObjs = $self->vars();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @varObjs;
    } else {
	@tempobjs = @varObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for enums in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeEnums {
    my $self = shift;
    my $enumsFile = $self->enumsDir().$pathSeparator."Enums.html";
    $self->_createHTMLOutputFile($enumsFile, $self->_getEnumDetailString(0), "Enumerations", 0);
}

# /*!
#     @abstract
#         Returns the right-side content for enums in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writeEnums}.
#  */
sub _getEnumDetailString {
    my $self = shift;
    my $composite = shift;
    my @enumObjs = $self->enums();
    my $contentString;

    return $self->_getDetailString(\@enumObjs, $composite, "enums", "Enumerated Types");

    # my @tempobjs = ();
    # if (!$self->unsorted()) {
	# @tempobjs = sort objName @enumObjs;
    # } else {
	# @tempobjs = @enumObjs;
    # }
    # foreach my $obj (@tempobjs) {
        # my $documentationBlock = $obj->documentationBlock($composite);
        # $contentString .= $documentationBlock;
    # }
    # return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for enums in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getEnumXMLDetailString {
    my $self = shift;
    my @enumObjs = $self->enums();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @enumObjs;
    } else {
	@tempobjs = @enumObjs;
    }
    foreach my $obj (@tempobjs) {
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}

# /*!
#     @abstract
#         Writes the right-side content for <code>#define</code> macros in
#         this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writePDefines {
    my $self = shift;
    my $pDefinesFile = $self->pDefinesDir().$pathSeparator."PDefines.html";
    $self->_createHTMLOutputFile($pDefinesFile, $self->_getPDefineDetailString(0), "#defines", 0);
}

# /*!
#     @abstract
#         Returns the right-side content for <code>#define</code> macros in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getCompositePageString} and {@link writePDefines}.
#  */
sub _getPDefineDetailString {
    my $self = shift;
    my $composite = shift;
    my @ALLpDefineObjs = $self->pDefines();
    my $contentString;

    my @pDefineObjs = ();
    foreach my $define (@ALLpDefineObjs) {
	if (!$define->parseOnly()) {
		push(@pDefineObjs, $define);
	}
    }
    return $self->_getDetailString(\@pDefineObjs, $composite, "PDefines", "Macro Definitions");
}

# /*!
#     @abstract
#         Returns the right-side content for an array of objects.
#     @param self
#         The <code>APIOwner</code> object.
#     @param arrayref
#         A reference to the array of objects.
#     @param composite
#         Pass 1 if this is being generated for a composite page, else 0.
#     @param type
#         The raw name of the type (e.g. Enums, Functions).  Used to generate
#         the filename for linking purposes.
#     @param displaytype
#         The human-readable name of the type.  Used in headings.
#  */
sub _getDetailString
{
    my $self = shift;
    my $arrayref = shift;
    my $composite = shift;
    my $type = shift;
    my $displaytype = shift;
    my @objs = @{$arrayref};
    my $contentString = "";

    my $count = @objs;

    if (!$count) { return ""; }

    my @tempobjs;
    if (!$self->unsorted()) {
	@tempobjs = sort objName @objs;
    } else {
	@tempobjs = @objs;
    }

    # print STDERR "TYPE: $type DISPLAYTYPE: $displaytype\n";
    $contentString .= $self->_getEmbeddedTOC(\@tempobjs, ucfirst($type).".html", $type, $displaytype, $composite, 2);

    my %groups = ( "" => "" );
    if ($HeaderDoc::groupright) {
	foreach my $obj (@objs) {
		my $group = $obj->group();
		if (length($group)) {
			# print STDERR "GROUP $group\n";
			$groups{$group} = $group;
		}
	}
    }

    foreach my $group (keys %groups) {
	# print STDERR "PRINTGROUP: $group\n";
	if ($HeaderDoc::groupright) {
		my $show = 1;
		my $tempgroup = $group;
		if (!length($group)) { $tempgroup = "Untagged"; $show = 0; }
		$contentString .= "<a name=\"".$type."_group_".$tempgroup."\"></a>\n";
		$contentString .= "<h2 class=\"h2tight\"><i>$tempgroup $displaytype</i></h2>\n";
		$contentString .= "<div class='group_indent'>\n";
	}
	my @tempobjs = ();
	if (!$self->unsorted()) {
		@tempobjs = sort objName @objs;
	} else {
		@tempobjs = @objs;
	}
	foreach my $obj (@tempobjs) {
		if (!$HeaderDoc::groupright || ($obj->group() eq $group)) {
			my $documentationBlock = $obj->documentationBlock($composite);
			$contentString .= $documentationBlock;
		# } else {
			# print STDERR "NOMATCH: ".$obj->group()." != ".$group.".\n";
		}
	}
	if ($HeaderDoc::groupright) {
		$contentString .= "</div>\n";
	}
    }
    return $contentString;
}

# /*!
#     @abstract
#         Returns the XML content string for <code>#define</code> macros in this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link _getXMLPageString}.
#  */
sub _getPDefineXMLDetailString {
    my $self = shift;
    my @pDefineObjs = $self->pDefines();
    my $contentString;

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @pDefineObjs;
    } else {
	@tempobjs = @pDefineObjs;
    }
    foreach my $obj (@tempobjs) {
	# print STDERR "OBJ: $obj: ".$obj->isBlock()."\n";
        my $documentationBlock = $obj->XMLdocumentationBlock();
        $contentString .= $documentationBlock;
    }
    return $contentString;
}


# /*!
#     @abstract
#         Writes the right-side content for classes in this header (or class).
#     @param self
#         The <code>APIOwner</code> object.
#     @discussion
#         Called by {@link writeHeaderElements}.
#  */
sub writeClasses {
    my $self = shift;
    my @classObjs = $self->classes();
    my $classRootDir = $self->classesDir();

    my @tempobjs = ();
    if (!$self->unsorted()) {
	@tempobjs = sort objName @classObjs;
    } else {
	@tempobjs = @classObjs;
    }
    foreach my $obj (@tempobjs) {
        my $className = $obj->name();
        # for now, always shorten long names since some files may be moved to a Mac for browsing
        if (1 || $isMacOS) {$className = &safeName(filename => $className);};

	my $classclass = ref($obj) || $obj;
	if ($classclass eq "HeaderDoc::CPPClass") {
		# Don't do this for Objective-C.  Methods aren't
		# like functions.
		$obj->fixupTypeRequests();
	}
        $obj->outputDir("$classRootDir$pathSeparator$className");
        $obj->createFramesetFile();
        $obj->createTOCFile();
        $obj->writeHeaderElements();
	$obj->writeHeaderElementsToCompositePage();
        $obj->createContentFile() if (!$HeaderDoc::ClassAsComposite);
    }
}


# /*!
#     @abstract
#         Creates a file for XML output.
#     @param self
#         The <code>APIOwner</code> object.
#     @param outputFile
#         The output filename.
#     @param orig_fileString
#         The data to write to the file.
#     @param heading
#         The source or header filename.
#  */
sub _createXMLOutputFile {
    my $self = shift;
    my $class = ref($self);
    # my $copyrightOwner = $self->htmlToXML($class->copyrightOwner());
    my $outputFile = shift;    
    my $orig_fileString = shift;    
    my $heading = shift;
    my $fullpath = $self->fullpath();

    # if ($class eq "HeaderDoc::Header") {
	# my $headercopyright = $self->htmlToXML($self->headerCopyrightOwner());
	# if (!($headercopyright eq "")) {
	    # $copyrightOwner = $headercopyright;
	# }
    # }

    my $HTMLmeta = "";
    # if ($class eq "HeaderDoc::Header") {
	$HTMLmeta = $self->HTMLmeta();
    # }

        calcDepth($outputFile);
	my $fileString = $self->xml_fixup_links($orig_fileString);

	if ($self->use_stdout()) {
		open(OUTFILE, ">&STDOUT");
	} else {
		open(OUTFILE, ">$outputFile") || die "Can't write $outputFile.\n";
	}


    if ($^O =~ /MacOS/io) {MacPerl::SetFileInfo('MSIE', 'TEXT', "$outputFile");};
	my $encoding = $self->encoding();

	# For some reason, some XML parser libraries (Perl's) can't
	# handle "utf8".  (Libxml thinks it's just fine.)
	if ($encoding eq "utf8") { $encoding = "UTF-8"; }

	print OUTFILE "<?xml version=\"1.0\" encoding=\"$encoding\"?>\n";

	my $doctype = "header";
	if ($self->isFramework()) {
		$doctype = "framework";
	}

	# print OUTFILE "<!DOCTYPE $doctype PUBLIC \"-//Apple Computer//DTD HEADERDOC 1.6//EN\" \"http://www.apple.com/DTDs/HeaderDoc-1.6.dtd\">\n";
	print OUTFILE "<!DOCTYPE $doctype PUBLIC \"-//Apple Computer//DTD HEADERDOC 1.6//EN\" \"/System/Library/DTDs/HeaderDoc-1.6.dtd\">\n";
	# print OUTFILE "<header filename=\"$heading\" headerpath=\"$fullpath\" headerclass=\"\">";
	# print OUTFILE "<name>$heading</name>\n";

	# Need to get the C++ Class Abstract and Discussion....
	# my $headerDiscussion = $self->discussion();   
	# my $headerAbstract = $self->abstract(); 

	# print OUTFILE "<abstract>$headerAbstract</abstract>\n";
	# print OUTFILE "<discussion>$headerDiscussion</discussion>\n";

	print OUTFILE $fileString;
	# print OUTFILE "<copyrightinfo>&#169; $copyrightOwner</copyrightinfo>" if (length($copyrightOwner));
	# print OUTFILE "<timestamp>$dateStamp</timestamp>\n";
	# print OUTFILE "</header>";
	close OUTFILE;
}

# /*!
#     @abstract
#         Creates a file for HTML output.
#     @param self
#         The <code>APIOwner</code> object.
#     @param outputFile
#         The output filename.
#     @param orig_fileString
#         The data to write to the file.
#     @param heading
#         The source or header filename.
#     @param includeDocNavComment
#         Specifies whether to include a doc navigator
#         comment in iframe output mode.
# */
sub _createHTMLOutputFile {
    my $self = shift;
    my $class = ref($self);
    my $copyrightOwner = $class->copyrightOwner();
    my $outputFile = shift;    
    my $orig_fileString = shift;    
    my $heading = shift;
    my $includeDocNavComment = shift;

    my $newTOC = $HeaderDoc::newTOC;

    if ($class eq "HeaderDoc::Header") {
	my $headercopyright = $self->headerCopyrightOwner();
	if (!($headercopyright eq "")) {
	    $copyrightOwner = $headercopyright;
	}
    }

    my $HTMLmeta = "";
    # if ($class eq "HeaderDoc::Header") {
	$HTMLmeta = $self->HTMLmeta();
    # }

        calcDepth($outputFile);
	my $fileString = html_fixup_links($self, $orig_fileString);

	open(OUTFILE, ">$outputFile") || die "Can't write $outputFile.\n";
    if ($^O =~ /MacOS/io) {MacPerl::SetFileInfo('MSIE', 'TEXT', "$outputFile");};
	print OUTFILE "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n    \"http://www.w3.org/TR/1998/REC-html40-19980424/loose.dtd\">\n";
	print OUTFILE "<html>";

	print OUTFILE "<head>\n    <title>$heading</title>\n	$HTMLmeta <meta name=\"generator\" content=\"HeaderDoc\" />\n<meta name=\"xcode-display\" content=\"render\" />\n";

	if ($HeaderDoc::use_iframes || $HeaderDoc::newTOC == 5) {
	    if (!$HeaderDoc::suppressDefaultStyles) {
		print OUTFILE $self->styleSheet(1);
		print OUTFILE "<style><!--\n";
		if ($HeaderDoc::newTOC == 5) {
			print OUTFILE "body {\n";
			print OUTFILE "    padding: 0px;\n";
			print OUTFILE "    margin: 0px;\n";
			print OUTFILE "    border: 0px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".toc_contents_text {\n";
			# print OUTFILE "    white-space: nowrap;\n";
			print OUTFILE "    padding-left: 1em;\n";
			print OUTFILE "    text-indent: -1em;\n";
			print OUTFILE "}\n";
			print OUTFILE "\n";
			print OUTFILE "ul.tocSubEntryList li.tocSubEntry {\n";
			print OUTFILE "    list-style: none;\n";
			print OUTFILE "}\n";
			print OUTFILE "\n";
			print OUTFILE "#colorbox {\n";
			print OUTFILE "		display: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".spec_sheet_line {\n";
			print OUTFILE "		margin-bottom: 1px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".collapsible {\n";
			print OUTFILE "		display: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".toc_leadspace {\n";
			print OUTFILE "		width: 10; min-width: 10;\n";
			print OUTFILE "}\n";
			print OUTFILE ".disclosure_triangle_td {\n";
			print OUTFILE "		width: 14; min-width: 14;\n";
			print OUTFILE "		font-size: 10px;\n";
			print OUTFILE "		vertical-align: middle;\n";
			print OUTFILE "}\n";
			print OUTFILE ".specbox td {\n";
			print OUTFILE "		font-size: 13px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".specbox td a {\n";
			print OUTFILE "		font-size: 13px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".specbox td code {\n";
			print OUTFILE "		font-size: 13px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".specbox td tt {\n";
			print OUTFILE "		font-size: 13px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".specbox td pre {\n";
			print OUTFILE "		font-size: 13px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".specbox a {\n";
			print OUTFILE "		font-size: 12px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".disclosure_triangle_td a {\n";
			print OUTFILE "		text-decoration: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".disclosure_triangle_td a:link {\n";
			print OUTFILE "		text-decoration: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".disclosure_triangle_td a:active {\n";
			print OUTFILE "		text-decoration: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".disclosure_triangle_td a:visited:hover {\n";
			print OUTFILE "		text-decoration: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".disclosure_triangle_td a:hover {\n";
			print OUTFILE "		text-decoration: none;\n";
			print OUTFILE "}\n";
			print OUTFILE ".hd_toc_box {\n";
			print OUTFILE "		padding-top: 10px;\n";
			print OUTFILE "		padding-right: 15px;\n";
			print OUTFILE "}";
			print OUTFILE ".tocSeparator {\n";
			print OUTFILE "		margin-top: 15px;\n";
			print OUTFILE "		padding-bottom: 0px;\n";
			print OUTFILE "		margin-bottom: 0px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".tocSubEntryList {\n";
			print OUTFILE "		margin-left: 0px;\n";
			print OUTFILE "		padding-left: 40px;\n";
			print OUTFILE "		padding-top: 0px;\n";
			print OUTFILE "		margin-top: 2px;\n";
			print OUTFILE "		padding-bottom: 0px;\n";
			print OUTFILE "		margin-bottom: 8px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".hd_toc_heading_table {\n";
			print OUTFILE "		margin-top: 2px;\n";
			print OUTFILE "		margin-bottom: 2px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".hd_toc_entry_table {\n";
			print OUTFILE "		margin-top: 2px;\n";
			print OUTFILE "		margin-bottom: 2px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".tocSubEntry {\n";
			print OUTFILE "		margin-left: 0px;\n";
			print OUTFILE "		padding-left: 0px;\n";
			print OUTFILE "		margin-top: 0px;\n";
			print OUTFILE "		margin-bottom: 1px;\n";
			print OUTFILE "}\n";
			print OUTFILE ".tocSubEntry a {\n";
			print OUTFILE "		font-size: 10pt;\n";
			print OUTFILE "}\n";
			print OUTFILE ".tocSubheading {\n";
			print OUTFILE "		padding-left: 14px;\n"; # width of .disclosure_triangle_td
			print OUTFILE "		margin-left: 0px;\n";
			print OUTFILE "		margin-top: 5px;\n";
			print OUTFILE "		padding-top: 0px;\n";
			print OUTFILE "		font-size: 16px;\n";
			print OUTFILE "		color: #808080;\n";
			print OUTFILE "}\n";
			print OUTFILE "\n";
			print OUTFILE "#hd_outermost_table { margin-left: 0px; border-spacing: 0px; margin-top: 0px; padding-left: 0px; padding-top: 0px; border: none; }\n";
			print OUTFILE "#hd_outermost_table > tr { border-spacing: 0px; margin-left: 0px; margin-top: 0px; padding-left: 0px; padding-top: 0px; border: none; }\n";
			print OUTFILE "#hd_outermost_table > tr > td { border-spacing: 0px; margin-left: 0px; margin-top: 0px; }\n";
			print OUTFILE "#hd_outermost_table > tbody > tr { border-spacing: 0px; margin-left: 0px; margin-top: 0px; padding-left: 0px; padding-top: 0px; border: none; }\n";
			print OUTFILE "#hd_outermost_table > tbody > tr > td { border-spacing: 0px; margin-left: 0px; margin-top: 0px; padding-top: 3px; }\n";
			print OUTFILE "\n";
		}
		print OUTFILE "#tocMenu {\n";
		if ($HeaderDoc::newTOC == 5) {
			print OUTFILE "		border-right: 1px solid #c0c0c0;\n";
			print OUTFILE "		background-color: #f4f4ff;\n";
		} else {
			print OUTFILE "		display: block;\n";
			print OUTFILE "		position:fixed;\n";
			print OUTFILE "		background:transparent;\n";
		}
		print OUTFILE "		top:0px;\n";
		print OUTFILE "		left:0px;\n";
		print OUTFILE "		width:230px;\n";
		# if ($HeaderDoc::newTOC != 5) {
			print OUTFILE "		height:100%;\n";
		# }
		print OUTFILE "}\n";
		if ($HeaderDoc::newTOC == 5) {
			print OUTFILE "#bodyContents {\n";
			# print OUTFILE "		float: right;\n"; # Old div layout that proved unworkable
			print OUTFILE "		width: auto;\n";
			# print OUTFILE "         position: absolute; top: 0px;\n";
			print OUTFILE "		padding-left: 15px;\n";
			print OUTFILE "}\n";
		} else {
			print OUTFILE "#bodyText {\n";
			print OUTFILE "		top: 0px;\n";
			print OUTFILE "		margin-left: 230px;\n";
			print OUTFILE "}\n";
		}
		print OUTFILE "--></style>\n";


		if ($HeaderDoc::newTOC == 5) {
			print OUTFILE "<style id=\"disable_before_iOS_5\"><!--\n";
			print OUTFILE "#tocMenu {\n";
			print OUTFILE "		position: fixed;\n";
			print OUTFILE "		height: 100%;\n";
			print OUTFILE "		overflow: auto;\n";
			print OUTFILE "}\n";
			print OUTFILE "#bodyContents {\n";
			# print OUTFILE "		float: right;\n"; # Old div layout that proved unworkable
			print OUTFILE "		width: auto;\n";
			# print OUTFILE "         position: absolute; top: 0px;\n";
			print OUTFILE "		left: 235px;\n";
			print OUTFILE "		right: 0;\n";
			print OUTFILE "		padding-left: 15px;\n";
			print OUTFILE "		position: fixed;\n";
			print OUTFILE "		height: 100%;\n";
			print OUTFILE "		overflow-y: scroll;\n";
			print OUTFILE "}\n";
			print OUTFILE "--></style>\n";
		}
	    }
	    if (!$HeaderDoc::suppressDefaultJavaScript) {
		if ($HeaderDoc::newTOC == 5) {
			print OUTFILE "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
			print OUTFILE "    if (navigator.platform && (navigator.platform.match(/iPad/) || navigator.platform.match(/iPhone/) || navigator.platform.match(/iPod/))) {\n";
			print OUTFILE "        if (navigator.userAgent.match(/OS 1(_\\d)+/) ||\n";
			print OUTFILE "            navigator.userAgent.match(/OS 2(_\\d)+/) ||\n";
			print OUTFILE "            navigator.userAgent.match(/OS 3(_\\d)+/) ||\n";
			print OUTFILE "            navigator.userAgent.match(/OS 4(_\\d)+/)) {\n";
			print OUTFILE "                /* Earlier iOS versions require different scrolling gestures with position: fixed. */\n";
			print OUTFILE "                var del_style_elt = document.getElementById(\"disable_before_iOS_5\");\n";
			print OUTFILE "                if (del_style_elt) del_style_elt.parentNode.removeChild(del_style_elt);\n";
			print OUTFILE "        }\n";
			print OUTFILE "    }\n";
			print OUTFILE "// --></script>\n";
		}

		if ($newTOC && $newTOC != 5) {
			# if (!$HeaderDoc::use_iframes) { print OUTFILE "<script language=\"JavaScript\" src=\"/Resources/JavaScript/toc.js\" type=\"text/javascript\"></script>\n"; }
			print OUTFILE "<meta id=\"toc-file\" name=\"toc-file\" content=\"toc.html\" />\n";
			# if ($HeaderDoc::enable_custom_references) {
				# print OUTFILE "<script language=\"JavaScript\" src=\"/Resources/JavaScript/customReference.js\" type=\"text/javascript\"></script>\n";
			# }

			if ($newTOC == 2 || $newTOC == 3) {
				my $squoname = $self->name();
				$squoname =~ s/'/'+"'"+'/sg;

				if ($newTOC == 3) {
					print OUTFILE "<meta name='book-json' content='book.js' id='book-json'>\n";
					print OUTFILE "<meta id='book-resource-type' name='book-resource-type' content='Reference'>\n";
					print OUTFILE "<meta id='book-root' name='book-root' content='./'/>\n";
				}

				print OUTFILE "    <script id='prototype_js' type=\"text/javascript\" src=\"/Resources/JavaScript/lib/prototype.js\"></script>\n";
				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/lib/scriptaculous.js?load=effects\"></script>\n";
				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/lib/event_mixins.js\"></script>\n";
				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/lib/browserdetect.js\"></script>\n";
				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/lib/ac_media.js\"></script>\n";

				if ($newTOC == 2) {
					print OUTFILE "    <script language=\"JavaScript\" src=\"/Resources/JavaScript/page.js\" type=\"text/javascript\"></script>\n";
				}

				print OUTFILE "    <script type=\"text/javascript\">\n";
				if ($newTOC == 2 || $newTOC == 3) {
					print OUTFILE "function getResourcesPath_HD() {\n";
					print OUTFILE "        var uri = document.getElementById('prototype_js').getAttribute('src');\n";
					print OUTFILE "        uri = uri.substr(0, uri.indexOf('/JavaScript/'));\n";
					print OUTFILE "        return uri;\n";
					print OUTFILE "}\n";
					print OUTFILE "        var Book={\n";
					print OUTFILE "            isReference: true,\n";
					print OUTFILE "            language: document.getElementsByTagName('html')[0].getAttribute('xml:lang'),\n";
					print OUTFILE "            resourcesURI: getResourcesPath_HD(),\n";
					print OUTFILE "            tocURI: './toc.html',\n";
					print OUTFILE "            bookTitle: '".$squoname."',\n";
					print OUTFILE "            indexTitle: '".$squoname."',\n";
					print OUTFILE "            indexURI: './index.html',\n";
					print OUTFILE "            nextPage: '',\n";
					print OUTFILE "            previousPage: ''\n";
					print OUTFILE "        };\n";
					print OUTFILE "\n";
				}
				if ($newTOC == 2 || $newTOC == 3) {
					print OUTFILE "function delete_styles()\n";
					print OUTFILE "{\n";
					print OUTFILE "        var elt = document.getElementById('breadcrumbsrc');\n";
					print OUTFILE "        var elt_b = document.getElementById('breadcrumbs');\n";
					print OUTFILE "        if (elt && elt_b) {\n";
					print OUTFILE "            elt_b.innerHTML = elt.innerHTML;\n";
					print OUTFILE "        }\n";
					print OUTFILE "\n";
					print OUTFILE "        if (!document.styleSheets) { return; }\n";
					print OUTFILE "        for (var i=0; i<document.styleSheets.length; i++) {\n";
					print OUTFILE "            var stylesheet = document.styleSheets[i];\n";
					print OUTFILE "            if (stylesheet.href && stylesheet.href.indexOf('static.css') != -1) {\n";
					print OUTFILE "                stylesheet.disabled = 1;\n";
					print OUTFILE "            }\n";
					print OUTFILE "        }\n";
					print OUTFILE "}\n";
				}
				if ($newTOC == 3) {
					print OUTFILE "        var Page={\n";
					print OUTFILE "            type: \"Reference\",\n";
					print OUTFILE "            language: document.getElementsByTagName('html')[0].getAttribute('xml:lang'),\n";
					# print OUTFILE "            resourcesURI: '/Resources',\n";
					print OUTFILE "            resourcesURI: getResourcesPath_HD(),\n";
					print OUTFILE "            tocURI: './book.js',\n";
					print OUTFILE "            indexTitle: '$squoname',\n";
					print OUTFILE "            indexURI: './index.html',\n";
					print OUTFILE "            nextPage: '',\n";
					print OUTFILE "            previousPage: '',\n";
					print OUTFILE "            root : \$('INDEX') ? \$('INDEX').href.slice(0, \$('INDEX').href.lastIndexOf('/')) + '/': \"\"\n";
	
					print OUTFILE "        };\n";
				}
				print OUTFILE "    </script>\n";

				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/devpubs.js\"></script>\n";
				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/header_toc.js\"></script>\n";
				print OUTFILE "    <script type=\"text/javascript\" src=\"/Resources/JavaScript/pedia.js\"></script>\n";
			}
		} else {
			print OUTFILE "<script language=\"JavaScript\" type=\"text/javascript\"><!--\n";
			if ($HeaderDoc::newTOC == 5) {
				print OUTFILE "function getNewHTTPObject()\n";
				print OUTFILE "{\n";
				print OUTFILE "        var xmlhttp;\n";
				print OUTFILE "\n";
				print OUTFILE "        /** Special IE only code ... */\n";
				print OUTFILE "        /*\@cc_on\n";
				print OUTFILE "          \@if (\@_jscript_version >= 5)\n";
				print OUTFILE "              try\n";
				print OUTFILE "              {\n";
				print OUTFILE "                  xmlhttp = new ActiveXObject('Msxml2.XMLHTTP');\n";
				print OUTFILE "              }\n";
				print OUTFILE "              catch (e)\n";
				print OUTFILE "              {\n";
				print OUTFILE "                  try\n";
				print OUTFILE "                  {\n";
				print OUTFILE "                      xmlhttp = new ActiveXObject('Microsoft.XMLHTTP');\n";
				print OUTFILE "                  }\n";
				print OUTFILE "                  catch (E)\n";
				print OUTFILE "                  {\n";
				print OUTFILE "                      xmlhttp = false;\n";
				print OUTFILE "                  }\n";
				print OUTFILE "             }\n";
				print OUTFILE "          \@else\n";
				print OUTFILE "             xmlhttp = false;\n";
				print OUTFILE "        \@end \@*/\n";
				print OUTFILE "\n";
				print OUTFILE "        /** Every other browser on the planet */\n";
				print OUTFILE "        if (!xmlhttp && typeof XMLHttpRequest != 'undefined')\n";
				print OUTFILE "        {\n";
				print OUTFILE "            try\n";
				print OUTFILE "            {\n";
				print OUTFILE "                xmlhttp = new XMLHttpRequest();\n";
				print OUTFILE "            }\n";
				print OUTFILE "            catch (e)\n";
				print OUTFILE "            {\n";
				print OUTFILE "                xmlhttp = false;\n";
				print OUTFILE "            }\n";
				print OUTFILE "        }\n";
				print OUTFILE "\n";
				print OUTFILE "        return xmlhttp;\n";
				print OUTFILE "}\n";
			}
			print OUTFILE "\n";
			print OUTFILE "function hidetoc() {\n";
			
			if ($HeaderDoc::newTOC == 5) {
				print OUTFILE "	var toc = document.getElementById('tocMenu');\n";
				print OUTFILE "	var src = toc.getAttribute('src');\n";
				print OUTFILE "	var xhr = getNewHTTPObject();\n";
				print OUTFILE "	xhr.open('GET', src, true);\n";
				print OUTFILE "	xhr.onreadystatechange = function() {\n";
				print OUTFILE "		if(xhr.readyState == 4) {\n";
				print OUTFILE "			var toc = document.getElementById('tocMenu');\n";
				print OUTFILE "			toc.innerHTML = xhr.responseText;\n";
				# print OUTFILE "		} else {\n";
				# print OUTFILE "			alert('RS: '+xhr.readyState+' STATUS: '+xhr.status);\n";
				print OUTFILE "		}\n";
				print OUTFILE "	}\n";
				print OUTFILE "	xhr.send(null);\n";
			}
			print OUTFILE "	var origURL = parent.document.URL;\n";
			print OUTFILE "	var contentURL = origURL.substring(origURL.indexOf('?')+1, origURL.length);\n";
			print OUTFILE "	if (contentURL.length == origURL.length) {\n";
			print OUTFILE "		jumpPos = origURL.substring(origURL.indexOf('#')+1, origURL.length);\n";
			print OUTFILE "	}\n";
			print OUTFILE "	if (contentURL == \"hidetoc\") {\n";
			if ($HeaderDoc::newTOC == 5) {
				print OUTFILE "		var body = document.getElementById('bodyContents');\n";
			} else {
				print OUTFILE "		var body = document.getElementById('bodyText');\n";
			}
			print OUTFILE "		if (toc && body) {\n";
			print OUTFILE "			toc.style.display = 'none';\n";
			print OUTFILE "			body.style.marginLeft = '0px';\n";
			print OUTFILE "		}\n";
			print OUTFILE "	}\n";
			print OUTFILE "}\n";
			print OUTFILE "\n";
			print OUTFILE "function disclosure_triangle(elt) {\n";
			print OUTFILE "   var linkelt = elt;\n";
			print OUTFILE "   while (elt && elt.tagName != 'TABLE') { elt = elt.parentNode;}\n";
			# print OUTFILE "   alert('Currently, elt is: '+elt);\n";
			print OUTFILE "   if (!elt) { return; }\n";
			print OUTFILE "   while (elt && elt.tagName != 'DIV') { elt = elt.nextSibling;}\n";
			# print OUTFILE "   alert('Currently, elt is: '+elt);\n";
			print OUTFILE "   if (!elt) { return; }\n";
			print OUTFILE "   if (parseInt(linkelt.getAttribute('state'))) {\n";
			# print OUTFILE "      alert('closing');\n";
			print OUTFILE "      // It's open.  Close it\n";
			print OUTFILE "      linkelt.innerHTML = '&#x25B7;';\n";
			print OUTFILE "      linkelt.setAttribute('state', 0);\n";
			print OUTFILE "      linkelt.setAttribute('class', 'closed_disclosure_triangle');\n";
			print OUTFILE "      elt.style.display = 'none';\n";
			print OUTFILE "   } else {\n";
			# print OUTFILE "      alert('opening');\n";
			print OUTFILE "      // It's closed.  Open it\n";
			print OUTFILE "      linkelt.innerHTML = '&#x25BC;';\n";
			print OUTFILE "      linkelt.setAttribute('state', 1);\n";
			print OUTFILE "      linkelt.setAttribute('class', 'open_disclosure_triangle');\n";
			print OUTFILE "      elt.style.display = 'block';\n";
			print OUTFILE "   }\n";
			print OUTFILE "}\n";

			print OUTFILE "--></script>\n";
		}
	    }
	}

	print OUTFILE $self->styleSheet(0);
	
	my $onload = "";
	if ($HeaderDoc::use_iframes) {
		if ($newTOC == 1) {
			$onload = "onload=\"initialize_page();\"";
		} elsif ((!$newTOC) || $newTOC == 5) {
			$onload = "onload=\"hidetoc();\"";
		}
	}
        my $style = "";
	if ($HeaderDoc::newTOC == 2 || $HeaderDoc::newTOC == 3) {
		$style = "class=\"hasjs\"";
		$onload = "onload=\"delete_styles();\"";
	}
	print OUTFILE "</head><body bgcolor=\"#ffffff\" $onload $style>\n";
	if ($HeaderDoc::use_iframes && $includeDocNavComment) {
		# print OUTFILE "</div>\n";

		my $docNavigatorComment = $self->docNavigatorComment();
		print OUTFILE $docNavigatorComment;
	}

	my $tocString = "";

	if ($newTOC == 2 || $newTOC == 3) {
		$tocString = $self->tocString($newTOC);

		# When modifying this variable, remember to quote any dollar signs.
		# Also add nextLink and previousLink, e.g.
                # <button id="previousPage" title="Previous"><a id='previousLink' name='bogus_prev'></a></button>
                # <button id="nextPage" title='Next'><a id='nextLink' name='bogus_next'></a></button>

		my $heading = "";

if ($newTOC == 2) {
	$heading .= <<FOO
  <div id="adcHeader" class="hideOnPrint hideInXcode">
        <script src="http://devimages.apple.com/assets/scripts/browserdetect.js" type="text/javascript" charset="utf-8"></script>
<script src="http://devimages.apple.com/assets/scripts/apple_core.js" type="text/javascript" charset="utf-8"></script>
<script src="http://devimages.apple.com/assets/scripts/search_decorator.js" type="text/javascript" charset="utf-8"></script>
<script src="http://devimages.apple.com/assets/scripts/adc_core.js" type="text/javascript" charset="utf-8"></script>
		<div style='height:36px; background-image: url(\"/Resources/includes/header_sm_mid.png\");'>
		<a href='/mac/library/navigation/index.html'><img src='/Resources/includes/mac_header_sm_left.png' alt="Mac OS X Reference Library" height='36' width='264' style='border:none'></a>
		<a href='/'><img src='/Resources/includes/developer_header_sm.png' alt="Apple Developer Connection" height='36' width='179' style='position:absolute; right:60px; border:none'></a>
		<img id='adc_search' src='/Resources/includes/header_sm_search.png' alt="spyglass button" height='36' width='60' style='position:absolute; right:0px; border:none' />
</div>
FOO
;
} else {
	$heading .= <<FOO
  <div id="adcHeader" class="hideOnPrint hideInXcode" tabindex="1">
  <!--#include virtual="/Resources/includes/reflib_persistent_header"-->
</div>
FOO
;
}

$heading .= <<FOO
<form id='search_menu' method='get' action='/mac/search/search.php' accept-charset='utf-8' style='display: none; background-image: url("/Resources/includes/search_panel.png"); height:45px; width:220px; position:absolute; top: 35px; right: 0px; z-index: 100000;-webkit-box-shadow: rgba(0, 0, 0, .25) -4px 4px 4px; padding: 14px'>
    <input type="hidden" name="simp" value="1"/>
    <input type="hidden" name="num"  value="10"/>
    <input type="hidden" name="site" value="mac"/>
    <label>Search Mac Reference Library</label>
    <label for='gh-adcsearch'>
    <input class='adcsearch prettysearch' type='search'  id='gh-adcsearch' name='q' accesskey='s' results='5' /></label>
</form>
FOO
;

if ($newTOC == 2) {
	$heading .= <<FOO
<script type='text/javascript'>
    var Search = {
        openMenu: function (event) {
            event.stop();
            if (\$('search_menu').style.display === 'block') {
                Search.closeMenu(event);
            } else {
                \$('adc_search').src = '/Resources/includes/sm_search_active.png';
                \$('search_menu').style.display = 'block';
                \$('gh-adcsearch').focus();
            }
        },
        closeMenu: function (event) {
            if (!event.element().descendantOf('search_menu')){
                \$('adc_search').src = '/Resources/includes/header_sm_search.png';
                \$('search_menu').style.display = 'none';
            }
        }
    };
    \$('adc_search').observe('click', Search.openMenu);
    document.observe('click', Search.closeMenu);
</script>
FOO
;
}

my $titleLink = "../../index.html";

my $class = ref($self);
if ($class eq "HeaderDoc::Header") {
	$titleLink = "../index.html";
}

$heading .= <<FOO
    <div id="header">
        <div id="title"><a id="titleLink" href="$titleLink"><h1></h1></a><span id="file_links"></span></div>
        <ul id="headerButtons" class="hideOnPrint">
            <li id="toc_button" style="display:none"><button id="table_of_contents" class="open">Table of Contents</button></li>
            <li id="jumpto_button" style="display:none"><select id="jumpTo"><option value="top">Jump To...</option></select>
            </li>
                <li id="page_buttons" style="display:none">
                <button id="previousPage" title="Previous"><a id='previousLink' name='bogus_prev'></a></button>
                <button id="nextPage" title='Next'><a id='nextLink' name='bogus_next'></a></button>
            </li>
        </ul>
    </div>
    <div id="tocContainer" class="isShowingTOC"><ul id="toc"></ul></div>
    <div id="contents" class="isShowingTOC">
FOO
;
		print OUTFILE "$heading";

	} elsif ($newTOC == 5) {
		print OUTFILE "<table id=\"hd_outermost_table\" height=\"100%\" width=\"100%\"><tr><td valign='top' id='tocMenu' src='toc.html'></td>\n";
	} elsif ($HeaderDoc::use_iframes) {

		if ($newTOC) {
			print OUTFILE "<noscript>\n";
		}
		print OUTFILE "<div id='tocMenu'>\n";
		print OUTFILE "<iframe id='toc_content' name='toc_content' SRC='toc.html' width='210' height='100%' align='left' frameborder='0'>This document set is best viewed in a browser that supports iFrames.</iframe>\n";
		print OUTFILE "</div>\n";
		if ($newTOC) {
			print OUTFILE "</noscript>\n";
		}
		print OUTFILE "<div id='bodyText'>\n";
	}
	if ($HeaderDoc::insert_header && ($newTOC != 2)) {
		print OUTFILE "<!-- start of header -->\n";
		print OUTFILE $self->htmlHeader()."\n";
		print OUTFILE "<!-- end of header -->\n";
	}
	if ($newTOC == 5) {
		print OUTFILE "<td id='bodyContents' valign='top'>\n";
	} else {
		print OUTFILE "<div id='bodyContents'>\n";
	}
	print OUTFILE "<a name=\"top\"></a>\n";
	# print OUTFILE "<h1><font face=\"Geneva,Arial,Helvtica\">$heading</font></h1><br>\n";
	print OUTFILE $fileString;
	print OUTFILE "<p class=\"gapBeforeFooter\">&nbsp;</p>";
	if ($HeaderDoc::insert_header) {
		print OUTFILE "<!-- start of footer -->\n";
		print OUTFILE $self->htmlFooter()."\n";
		print OUTFILE "<!-- end of footer -->\n";
	}

	print OUTFILE "<hr class=\"afterFooter\">";
	print OUTFILE "<div class=\"hd_copyright_and_timestamp\">\n";
	if (length($copyrightOwner)) {
		print OUTFILE "<p class=\"hd_copyright\">";
		print OUTFILE "&#169; $copyrightOwner ";
		print OUTFILE "</p>";
	}
	# print OUTFILE "Last Updated: $dateStamp\n";
	my $filedate = $self->updated();
	print OUTFILE "<p class=\"hd_timestamp\">";
	if (length($filedate)) {
	    print OUTFILE "Last Updated: $filedate\n";
	} else {
	    print OUTFILE "Last Updated: $dateStamp\n";
	}
	print OUTFILE "</p>";
	print OUTFILE "</div>\n"; # hd_copyright_and_timestamp

	if ($newTOC == 5) {
		print OUTFILE "</td></tr></table>\n"; # bodyContents
	} else {
		print OUTFILE "</div>\n"; # bodyContents
	}
	if ($newTOC == 2) {
		print OUTFILE "</div>\n"; # contents
	}
	if ($HeaderDoc::use_iframes && ($newTOC != 5)) {
		print OUTFILE "</div>\n";
	}
	print OUTFILE "</body></html>\n";
	close OUTFILE;
}


##################### Debugging ####################################

# /*!
#     @abstract
#         Prints this object for debugging purposes.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "------------------------------------\n";
    print STDERR "APIOwner\n";
    print STDERR "outputDir: $self->{OUTPUTDIR}\n";
    print STDERR "constantsDir: $self->{CONSTANTSDIR}\n";
    print STDERR "datatypesDir: $self->{DATATYPESDIR}\n";
    print STDERR "functionsDir: $self->{FUNCTIONSDIR}\n";
    print STDERprint STDERR "methodsDir: $self->{METHODSDIR}\n";
    print STDERR "typedefsDir: $self->{TYPEDEFSDIR}\n";
    print STDERR "constants:\n";
    &printArray(@{$self->{CONSTANTS}});
    print STDERR "functions:\n";
    &printArray(@{$self->{FUNCTIONS}});
    print STDERR "methods:\n";
    &printArray(@{$self->{METHODS}});
    print STDERR "typedefs:\n";
    &printArray(@{$self->{TYPEDEFS}});
    print STDERR "structs:\n";
    &printArray(@{$self->{STRUCTS}});
    print STDERR "Inherits from:\n";
    $self->SUPER::printObject();
}

# /*!
#     @abstract
#         Processes a HeaderDoc comment for a class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param fieldArrayRef
#         A reference to an array of fields.  This should be the result of calling
#         {@link //apple_ref/perl/instm/HeaderDoc::Utilities/stringToFields//()
#         HeaderDoc::Utilities::stringToFields} on the HeaderDoc comment.
#
#         This is essentially the result of calling split on the <code>\@</code>
#         symbol in the comment, but there is some subtlety involved, so don't
#         do that.
#     @param embedded
#         Pass 1 when processing comments for embedded markup (e.g. a method
#         inside a class).  Otherwise, pass 0.
#     @param parseTree
#         The {@link //apple_ref/perl/cl/HeaderDoc::ParseTree HeaderDoc::ParseTree}
#         class instance associated with the class or header.
#     @param soc
#         Start of comment marker (from {@link //apple_ref/perl/instm/HeaderDoc::Utilities/parseTokens//() parseTokens}).
#     @param ilc
#         Start of single-line comment marker (from {@link //apple_ref/perl/instm/HeaderDoc::Utilities/parseTokens//() parseTokens}).
#     @param ilc_b
#         Start of single-line comment marker #2 (from {@link //apple_ref/perl/instm/HeaderDoc::Utilities/parseTokens//() parseTokens}).
#  */
sub processComment
{
	my $self = shift;
	my $fieldArrayRef = shift;
	my $embedded = shift;
	my $parseTree = shift;
	my $soc = shift;
	my $ilc = shift;
	my $ilc_b = shift;
	my $commentTree = shift;
	my $hashtreecur = shift;
	my $hashtreeroot = shift;

	my $localDebug = 0;

	my $headerObj = $self->apiOwner();
	my $apiOwner = $self;

	my $outputdirtemp = "";
	my $outputdirtempbase = "";

	my $hofirst = 1;
	my $curobj = $headerObj;
	if ($headerObj !~ /HeaderDoc::Header/) {
		my $name = $curobj->name();
		my $safename = &safeName(filename => $name);
		$outputdirtemp = "Classes".$pathSeparator.$safename.$pathSeparator.$outputdirtemp;
		if ($hofirst) {
			$hofirst = 0;
		} else {
			$outputdirtempbase = "Classes".$pathSeparator.$safename.$pathSeparator.$outputdirtempbase;
		}
		$curobj = $curobj->apiOwner();
	}
	# warn "HOFIRST: $hofirst\n";
	# warn "ODTB: $outputdirtempbase\n";
	if (!$hofirst) {
		# warn "CREATING SUBS: ".$outputdirtempbase.$pathSeparator."Classes\n";
		my $name = $headerObj->name();
		my $safename = &safeName(filename => $name);
		mkdir( $self->outputDir().$pathSeparator.$outputdirtempbase.$pathSeparator."Classes", 0777);
		mkdir( $self->outputDir().$pathSeparator.$outputdirtempbase.$pathSeparator."Classes".$pathSeparator.$safename, 0777);
	}

	$outputdirtemp = $self->outputDir().$pathSeparator.$outputdirtemp;

	# warn "MY OUTPUT DIR: \"".$self->outputDir()."\"\n";
	# warn "SETTING OUTPUT DIR TO $outputdirtemp\n";

	if ($self->outputDir()) {
		# This gets overwritten anyway, and it causes
		# bugs if / isn't writable.
		$apiOwner->outputDir($outputdirtemp);
	}

	if ($localDebug) {
		print STDERR "PROCESSCOMMENT\n";
		print STDERR "SELF: $self\nFAR: $fieldArrayRef\nEMBEDDED: $embedded\nPTP: $parseTree\nSOC: $soc\nILC: $ilc\nILC_B: $ilc_b";
		print STDERR "COMMENT RESEMBLES THE FOLLOWING:\n";
		foreach my $field (@{$fieldArrayRef}) {
			print STDERR "\@$field\n";
		}
		print STDERR "EOCOMMENT\n";
	}

	# my $rootOutputDir = shift;
	# my $fieldArrayRef = shift;
	my @fields = @$fieldArrayRef;
	# my $classType = shift;
	my $fullpath = $apiOwner->fullpath();

	my $lang = $self->lang();
	my $sublang = $self->sublang();
	my $linenum = $self->linenum();
	my $linenuminblock = $self->linenuminblock();

	# WARNING: Line numbers of embedded stuff are approximate by nature.
	# If storing of that information during parsing fails, line numbers
	# will be seriously off.
	my $blockOffset = $self->linenum(); # $self->blockoffset();

	if ($embedded) {

		my $embedDebug = 0 || $localDebug;
		my $localDebug = $embedDebug;
		# We're processing contents of a class.  These get handled differently.

		if ($self =~ /HeaderDoc::APIOwner/) {
			# silently return.
			return (0, $hashtreecur, $hashtreeroot);
		}

		if ($parseTree) {
			print STDERR "GOT PT: SODEC WAS $parseTree (".$parseTree->token().")\n" if ($localDebug);


				print STDERR "EMBEDDED DECLARATION:\n" if ($localDebug);
				$parseTree->printTree() if ($localDebug);
				print STDERR "EODEC\n" if ($localDebug);

				my $s = $parseTree->parserState();
				if ($s) {
					print STDERR "PARSERSTATE EOTREE: $s->{lastTreeNode}\n" if ($localDebug);
				}
			$parseTree->dbprint() if ($localDebug);
		}

		my $keyfield = $fields[0];
		if (!length($keyfield) || $keyfield =~ /^\s+$/) { $keyfield = $fields[1]; }

		my $inFunction = my $inClass = my $inMethod = my $inTypedef = my $inUnion = my $inStruct = my $inConstant = my $inVar = my $inPDefine = my $inEnum = my $inUnknown = my $inInterface = 0;

		$localDebug = 0;
		my $classType = $self->classType();
		my $lang = $self->lang();
		my $sublang = $self->sublang();

		my $first_field = 1;

		SWITCH: {
			($keyfield =~ /^\/(\*|\/)\!\s*/) && do {
				# if ($first_field) {
					# my $copy = $keyfield;
					# $copy =~ s/^\/\*\!\s*//s;
					# if (length($copy)) {
						# $self->discussion($copy);
					# }
				# }
				my $short = $keyfield;
				# $short =~ s/^\/\*\!\s*//s;
                                $short =~ s/^\/(\*|\/)\!\s*//s;
				if (length($short)) {
					$inUnknown = 1;
					print STDERR "nested inUnknown\n" if ($localDebug);
					last SWITCH;
				}
				$keyfield = $fields[1];
			}; # ignore opening /*!
			($keyfield =~ /^template\s+/) && do {
				$inFunction = 1;
				print STDERR "nested template\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^class\s+/) && do {
				$inClass = 1;
				print STDERR "nested class\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^interface\s+/) && do {
				# $inInterface = 1;
				print STDERR "nested interface\n" if ($localDebug);
				warn("$fullpath:$linenum: warning: Interface not supported here.  Assuming class.\n"); # @@@ Change if we ever need to support nested interfaces.
				# return (0, $hashtreecur, $hashtreeroot);
				$inClass = 1;
				last SWITCH;
			    };
			($keyfield =~ /^protocol\s+/) && do {
				# $inProtocol = 1;
				print STDERR "nested protocol\n" if ($localDebug);
				warn("$fullpath:$linenum: warning: Protocol not supported here.  Assuming class.\n"); # @@@ Change if we ever need to support nested protocols.
				# return (0, $hashtreecur, $hashtreeroot);
				$inClass = 1;
				last SWITCH;
			    };
			($keyfield =~ /^category\s+/) && do {
				print STDERR "nested category\n" if ($localDebug);
				warn("$fullpath:$linenum: warning: Category not supported here.  Assuming class.\n"); # @@@ Change if we ever need to support nested categories.
				# return (0, $hashtreecur, $hashtreeroot);
				$inClass = 1;
				last SWITCH;
			    };
			($keyfield =~ /^language\s+/) && do {
				print STDERR "nested language\n" if ($localDebug);
				warn("$fullpath:$linenum: warning: \@language is deprecated.\n");
				return (0, $hashtreecur, $hashtreeroot);
				last SWITCH;
			    };
			($keyfield =~ /^(function|method)group\s+/) && do {
				print STDERR "nested function/methodgroup\n" if ($localDebug);
				# my $group = $keyfield;
				# $group =~ s/^(function|method)group\s+//s;
				# $group =~ s/\s*\*\/\s*$//s;
				# $self->{FUNCTIONGROUPSTATE} = $group;

				# warn("Function Groups not supported in classes yet!\n");

				my $group = HeaderDoc::Group->new("LANG" => $lang, "SUBLANG" => $sublang);
				$group->fullpath($self->fullpath);
				$group->filename($self->filename());
				$group->linenuminblock($linenuminblock);
				$group->blockoffset($blockOffset);

				$group->apiOwner($apiOwner);
				$group = $group->processComment(\@fields);

				print STDERR "group name is ".$group->name()."\n" if ($debugging);
				$apiOwner->addGroup($group, 0); #(, $desc);

				$self->{FUNCTIONGROUPSTATE} = $group->name();
				return (0, $hashtreecur, $hashtreeroot);
			    };
			($keyfield =~ /^group\s+/) && do {
				# $inGroup = 1;
				print STDERR "nested group\n" if ($localDebug);
				# warn("Groups not supported in classes yet!\n");
				my $group = $keyfield;
				$group =~ s/^group\s+//s;
				$group =~ s/\s*\*\/\s*$//s;
				$HeaderDoc::globalGroup = $group;
				return (0, $hashtreecur, $hashtreeroot);
			    };
			($keyfield =~ /^indexgroup\s+/) && do {
				# $inGroup = 1;
				print STDERR "nested indexgroup\n" if ($localDebug);
				# warn("Groups not supported in classes yet!\n");
				my $group = $keyfield;
				$group =~ s/^indexgroup\s+//s;
				$group =~ s/\s*\*\/\s*$//s;
				$self->indexgroup($group);
				return (0, $hashtreecur, $hashtreeroot);
			    };
			($keyfield =~ /^(function)\s+/) && do {
				$inFunction = 1;
				print STDERR "nested function $keyfield\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^method\s+/) && do {
				$inMethod = 1;
				print STDERR "nested method\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^(typedef|callback)\s+/) && do {
				$inTypedef = 1;
				print STDERR "nested typedef\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^union\s+/) && do {
				$inUnion = 1;
				print STDERR "nested union\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^struct\s+/) && do {
				$inStruct = 1;
				print STDERR "nested struct\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^const(ant)?\s+/) && do {
				$inConstant = 1;
				print STDERR "nested constant\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^var\s+/) && do {
				$inVar = 1;
				print STDERR "nested var\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^define(d)?block\s+/) && do {
				$inPDefine = 2;
				print STDERR "nested defineblock\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^define(d)?\s+/) && do {
				$inPDefine = 1;
				print STDERR "nested define\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^enum\s+/) && do {
				$inEnum = 1;
				print STDERR "nested enum\n" if ($localDebug);
				last SWITCH;
			    };
			($keyfield =~ /^serial(Data|Field|)\s+/) && do {
				warn("$fullpath:$linenum: warning: serialData not supported here.\n"); # @@@ Change if we ever need to support this option in a nested context.
				return (0, $hashtreecur, $hashtreeroot);
			    };
			($keyfield eq "") && do {
				$inUnknown = 1;
				print STDERR "nested inUnknown[???]\n" if ($localDebug);
				last SWITCH;
			};
			    if (!validTag($keyfield)) {
				warn("$fullpath:$linenum: warning: UNKNOWN FIELD[EMBEDDED]: \"$keyfield\".\n");
				return (0, $hashtreecur, $hashtreeroot);
			    } else {
				$inUnknown = 1;
				print STDERR "nested inUnknown[???]\n" if ($localDebug);
			    }
		}
		$first_field = 0;

	# print STDERR "INUNKNOWN: $inUnknown\n";

		my $categoryObjectsref = undef;
		my $classObjectsref = \@{$self->{CLASSES}};

		# @@@ FIXME DAG
		my $cppAccessControlState = "protected:";

		if ($sublang eq "IDL") {
			$cppAccessControlState = "public:"; # IDLs have no notion of protection, typically.
		}

		my $fieldsref = \@fields;
		my $filename = $self->filename;

		my $functionGroup = $self->{FUNCTIONGROUPSTATE} || "";

		my $headerObject = $self;
		my $inputCounter = 1;

		my @fakelines = ( "This is a test.", "BOGUSFOOBOGUSFOOBOGUS", "This is only a test.");
		my $inputlinesref = \@fakelines;
		my $nlines = 42;
		my $preAtPart = "";

		# Get any discussion that precedes the first @ sign.
                                if ($inUnknown == 1) {
                                        if ($fields[0] =~ s/^\s*\/(\*|\/)!\s*(\w.*?)\@/\/\*! \@/sio) {
                                                $preAtPart = $1;
                                        } elsif ($fields[0] !~ /^\s*\/(\*|\/)!\s*.*\@/o) {
                                                $preAtPart = $fields[0];
                                                $preAtPart =~ s/^\s*\/(\*|\/)!\s*//sio;
						if ($1 eq "*") {
                                                	$preAtPart =~ s/\s*\*\/\s*$//sio;
						}
                                                $fields[0] = "/*! "; # Don't add end of commend marker here.
                                        }
                                        print STDERR "preAtPart: \"$preAtPart\"\n" if ($localDebug);
                                        print STDERR "fields[0]: \"$fields[0]\"\n" if ($localDebug);
                                }

		my $xml_output = 0;
		if ($self->outputformat() eq "hdxml") { $xml_output = 1; }

		$localDebug = 0;
		my $hangDebug = 0;
		my $parmDebug = 0;
		my $blockDebug = 0;

		my $subparse = 1;
		if ($self->can("isCOMInterface") && $self->isCOMInterface()) {
			# warn "COMINT\n";
			$subparse = 2;
		}
		my $subparseTree = $parseTree;

		my $nodec = 0;

		my $oldcur = $HeaderDoc::currentClass;
		$HeaderDoc::currentClass = $self;

		# print STDERR "BO: $blockOffset\n";

		# my $currentModule = "";
		my $ps = $self->parserState();
		# if ($ps) {
			# $currentModule = $ps->{MODULE};
		# }

		my ($inputCounterToss, $cppAccessControlStateToss, $classTypeToss, $classObjectRefToss, $catObjectRefToss, $blockOffsetToss, $numcurlybraces, $foundmatch, $newlang, $newsublang, $hashtreecur, $hashtreeroot) = blockParseOutside($apiOwner, $inFunction, $inUnknown,
			$inTypedef, $inStruct, $inEnum, $inUnion,
			$inConstant, $inVar, $inMethod, $inPDefine,
			$inClass, $inInterface, $blockOffset, $categoryObjectsref,
			$classObjectsref, $classType, $cppAccessControlState,
			$fieldsref, $fullpath, $functionGroup,
			$headerObject, $inputCounter, $inputlinesref,
			$lang, $nlines, $preAtPart, $xml_output, $localDebug,
			$hangDebug, $parmDebug, $blockDebug, $subparse,
			$subparseTree, $nodec, $HeaderDoc::allow_multi, $commentTree, $sublang, $hashtreecur, $hashtreeroot);

		$HeaderDoc::currentClass = $oldcur;

		# print STDERR "NAME: ".$self->name()." LN: ".$self->linenum()." LNIB: ".$self->linenuminblock()." BO: ".$self->blockoffset()."\n";

		return ($numcurlybraces, $hashtreecur, $hashtreeroot);
	}

	return $self->SUPER::processComment($fieldArrayRef);

	# Old NOT EMBEDDED code from here down.

	my $class = ref($self) || $self;
	my $superclassfieldname = "Superclass";
	if ($class =~ /HeaderDoc::ObjCCategory/) {
		$superclassfieldname = "Extends&nbsp;Class";
	} elsif ($class =~ /HeaderDoc::ObjCProtocol/) {
		$superclassfieldname = "Extends&nbsp;Protocol";
	}
	my $first_field = 1;
	foreach my $field (@fields) {
		my $fieldname = "";
		my $top_level_field = 0;
		if ($field =~ /^(\w+)(\s|$)/) {
			$fieldname = $1;
			# print STDERR "FIELDNAME: $fieldname\n";
			$top_level_field = validTag($fieldname, 1);
		}
		# print STDERR "TLF: $top_level_field, FN: \"$fieldname\"\n";
		SWITCH: {
			($field =~ /^\/(\*|\/)\!/o && $first_field) && do {
				my $copy = $field;
				$copy =~ s/^\/(\*|\/)\!\s*//s;
				if (length($copy)) {
					$self->discussion($copy);
				}
				last SWITCH;
				};
			# (($lang eq "java") && ($field =~ /^\s*\/\*\*/o)) && do {last SWITCH;}; # ignore opening /**
			# ($field =~ /^see(also|)(\s+)/i) &&
				# do {
					# $apiOwner->see($field);
					# last SWITCH;
				# };
			## ($field =~ s/^protocol(\s+)/$1/io) && 
				## do {
					## my ($name, $disc, $namedisc);
					## my $fullpath = $apiOwner->fullpath();
					## ($name, $disc, $namedisc) = &getAPINameAndDisc($field, $lang); 
					## $apiOwner->name($name);
					## $apiOwner->filename($filename);
					## $apiOwner->fullpath($fullpath);
					## if (length($disc)) {
						## if ($namedisc) {
							## $apiOwner->nameline_discussion($disc);
						## } else {
							## $apiOwner->discussion($disc);
						## }
					## }
					## last SWITCH;
				## };
			## ($field =~ s/^category(\s+)/$1/io) && 
				## do {
					## my ($name, $disc, $namedisc);
					## my $fullpath = $apiOwner->fullpath();
					## ($name, $disc, $namedisc) = &getAPINameAndDisc($field, $lang, "/[():]"); 
					## $apiOwner->name($name);
					## $apiOwner->filename($filename);
					## $apiOwner->fullpath($fullpath);
					## if (length($disc)) {
						## if ($namedisc) {
							## $apiOwner->nameline_discussion($disc);
						## } else {
							## $apiOwner->discussion($disc);
						## }
					## }
					## last SWITCH;
				## };
            			($field =~ s/^templatefield(\s+)/$1/io) && do {     
                                	$field =~ s/^\s+|\s+$//go;
                    			$field =~ /(\w*)\s*(.*)/so;
                    			my $fName = $1;
                    			my $fDesc = $2;
                    			my $fObj = HeaderDoc::MinorAPIElement->new("LANG" => $lang, "SUBLANG" => $sublang);
					$fObj->linenuminblock($linenuminblock);
					$fObj->blockoffset($blockOffset);
					$fObj->linenum($linenum);
					$fObj->apiOwner($apiOwner);
                    			$fObj->outputformat($apiOwner->outputformat);
                    			$fObj->name($fName);
                    			$fObj->discussion($fDesc);
                    			$apiOwner->addToFields($fObj);
# print STDERR "inserted field $fName : $fDesc";
                                	last SWITCH;
                        	};
			($field =~ s/^super(class|)(\s+)/$2/io) && do { $apiOwner->attribute($superclassfieldname, $field, 0); $apiOwner->explicitSuper(1); last SWITCH; };
			($field =~ s/^(throws|exception)(\s+)/$2/io) && do {$apiOwner->throws($field); last SWITCH;};
			($field =~ s/^abstract(\s+)/$1/io) && do {$apiOwner->abstract($field); last SWITCH;};
			($field =~ s/^brief(\s+)/$1/io) && do {$apiOwner->abstract($field, 1); last SWITCH;};
			($field =~ s/^details(\s+|$)/$1/io) && do {$apiOwner->discussion($field); last SWITCH;};
			($field =~ s/^discussion(\s+|$)/$1/io) && do {$apiOwner->discussion($field); last SWITCH;};
			($field =~ s/^availability(\s+)/$1/io) && do {$apiOwner->availability($field); last SWITCH;};
			($field =~ s/^since(\s+)/$1/io) && do {$apiOwner->availability($field); last SWITCH;};
            		($field =~ s/^author(\s+)/$1/io) && do {$apiOwner->attribute("Author", $field, 0); last SWITCH;};
			($field =~ s/^version(\s+)/$1/io) && do {$apiOwner->attribute("Version", $field, 0); last SWITCH;};
            		($field =~ s/^deprecated(\s+)/$1/io) && do {$apiOwner->attribute("Deprecated", $field, 0); last SWITCH;};
            		($field =~ s/^version(\s+)/$1/io) && do {$apiOwner->attribute("Version", $field, 0); last SWITCH;};
			($field =~ s/^updated(\s+)/$1/io) && do {$apiOwner->updated($field); last SWITCH;};
	    ($field =~ s/^attribute(\s+)/$1/io) && do {
		    my ($attname, $attdisc, $namedisc) = &getAPINameAndDisc($field, $lang);
		    if (length($attname) && length($attdisc)) {
			$apiOwner->attribute($attname, $attdisc, 0);
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attribute\n";
		    }
		    last SWITCH;
		};
	    ($field =~ s/^attributelist(\s+)/$1/io) && do {
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
			    $apiOwner->attributelist($name, $line);
			}
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attributelist\n";
		    }
		    last SWITCH;
		};
	    ($field =~ s/^attributeblock(\s+)/$1/io) && do {
		    my ($attname, $attdisc, $namedisc) = &getAPINameAndDisc($field, $lang);
		    if (length($attname) && length($attdisc)) {
			$apiOwner->attribute($attname, $attdisc, 1);
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attributeblock\n";
		    }
		    last SWITCH;
		};
			($field =~ s/^namespace(\s+)/$1/io) && do {$apiOwner->namespace($field); last SWITCH;};
			($field =~ s/^instancesize(\s+)/$1/io) && do {$apiOwner->attribute("Instance Size", $field, 0); last SWITCH;};
			($field =~ s/^performance(\s+)/$1/io) && do {$apiOwner->attribute("Performance", $field, 1); last SWITCH;};
			# ($field =~ s/^subclass(\s+)/$1/io) && do {$apiOwner->attributelist("Subclasses", $field); last SWITCH;};
			($field =~ s/^nestedclass(\s+)/$1/io) && do {$apiOwner->attributelist("Nested Classes", $field); last SWITCH;};
			($field =~ s/^coclass(\s+)/$1/io) && do {$apiOwner->attributelist("Co-Classes", $field); last SWITCH;};
			($field =~ s/^helper(class|)(\s+)/$2/io) && do {$apiOwner->attributelist("Helper Classes", $field); last SWITCH;};
			($field =~ s/^helps(\s+)/$1/io) && do {$apiOwner->attribute("Helps", $field, 0); last SWITCH;};
			($field =~ s/^classdesign(\s+)/$1/io) && do {$apiOwner->attribute("Class Design", $field, 1); last SWITCH;};
			($field =~ s/^dependency(\s+)/$1/io) && do {$apiOwner->attributelist("Dependencies", $field); last SWITCH;};
			($field =~ s/^ownership(\s+)/$1/io) && do {$apiOwner->attribute("Ownership Model", $field, 1); last SWITCH;};
			($field =~ s/^security(\s+)/$1/io) && do {$apiOwner->attribute("Security", $field, 1); last SWITCH;};
			($field =~ s/^whysubclass(\s+)/$1/io) && do {$apiOwner->attribute("Reason to Subclass", $field, 1); last SWITCH;};
			# ($field =~ s/^charset(\s+)/$1/io) && do {$apiOwner->encoding($field); last SWITCH;};
			# ($field =~ s/^encoding(\s+)/$1/io) && do {$apiOwner->encoding($field); last SWITCH;};
			# print STDERR "Unknown field in class comment: $field\n";
			($top_level_field == 1) &&
				do {
					my $keepname = 1;
					my $pattern = "";
 					if ($field =~ s/^(class|interface|category|protocol|template)(\s+)/$2/io) {
						if ($1 eq "category") {
							$pattern = "[()]";
						} elsif ($1 eq "class") {
							$pattern = ":";
						}
						$keepname = 1;
					} else {
						$field =~ s/(\w+)(\s|$)/$2/io;
						$keepname = 0;
					}
					my ($name, $disc, $namedisc);
					my $filename = $HeaderDoc::headerObject->filename();
					my $fullpath = $HeaderDoc::headerObject->fullpath();
					# print STDERR "CLASSNAMEANDDISC:\n";
					($name, $disc, $namedisc) = &getAPINameAndDisc($field, $lang, $pattern);
					my $classID = ref($apiOwner);
					if ($keepname) { $apiOwner->name($name); }
					$apiOwner->filename($filename);
					$apiOwner->fullpath($fullpath);
					if (length($disc)) {
						if ($namedisc) {
							$apiOwner->nameline_discussion($disc);
						} else {
							$apiOwner->discussion($disc);
						}
					}
                	last SWITCH;
            	};
			warn "$fullpath:$linenum: warning: Unknown field (\@$field) in class comment (".$apiOwner->name().")[2]\n";
		}
		$first_field = 0;
	}
	return $apiOwner;
}

# /*! @abstract
#         Gets/sets the encoding information for this class or header.
#     @param self
#         The <code>APIOwner</code> object.
#     @param encoding
#         The value to set. (Optional)
#  */
sub encoding
{
    my $self = shift;
    my $apio = $self->apiOwner();

    if (@_) {
	my $encoding = shift;
	$encoding =~ s/^\s*//sg;
	$encoding =~ s/\s*$//sg;

	# Cowardly refuse a too-simple encoding.
	if ($encoding eq "ascii") { $encoding = "UTF-8"; }

	$self->{ENCODING} = $encoding;

	# warn("SET ENCODING TO $encoding\n");

	HeaderDoc::APIOwner::fix_date($encoding);
    }

    if ($self->{ENCODING}) {
	return $self->{ENCODING};
    } elsif ($apio && ($apio != $self)) {
	return $apio->encoding();
    } else {
	return "UTF-8";
    }
}

# /*!
#     @abstract
#         Returns a string containing HTML meta tags for this header or class.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub HTMLmeta
{
    my $self = shift;
    my $apio = $self->apiOwner();

    if ($apio && ($apio != $self)) {
	return $apio->HTMLmeta();
    }
    # Header.pm overrides this.  We should never reach this.
    return "";
}

# Moved to HeaderElement exclusively.
# sub discussion
# {
    # my $self = shift;
	# print STDERR "WARNING: APIO DISCUSSION CHANGED\n";
    # $self->SUPER::discussion(@_);
# }

# /*!
#     @abstract
#         Prints information about this object for debugging purposes.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub dbprint
{
	my $self = shift;
	print STDERR "NAME: ".$self->name()."\n";
}

# /*!
#     @abstract
#         Attempts to dispose of memory associated with this object.
#     @param self
#         The <code>APIOwner</code> object.
#     @param freechildrenraw
#         Set to 0 to unlink all grandchildren of this node.  Set to 1
#         to unlink all grandchildren of this node except for children
#         of classes.  Set to 2 to unlink this node by itself.
#  */
sub free
{
    my $self = shift;
    my $freechildrenraw = shift;
    my $keepParseTreeAndState = shift;
    my $newParseTreeOwner = shift;

    my $freeclasses = 1;
    my $freechildren = 1;
    if ($freechildrenraw == 2) {
	$freechildren = 0;
	$freeclasses = 0;
	print STDERR "FREEING $self\n" if ($HeaderDoc::debugAllocations);
    } elsif ($freechildrenraw) {
	# don't free the classes.
	$freeclasses = 0;
	print STDERR "FREEING $self and children (except classes).\n" if ($HeaderDoc::debugAllocations);
    } else {
	print STDERR "FREEING $self and children.\n" if ($HeaderDoc::debugAllocations);
    }

    $self->setAPIOBackReferences( $self->{CONSTANTS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{FUNCTIONS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{METHODS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{TYPEDEFS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{STRUCTS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{VARS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{PDEFINES}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{ENUMS}, $freechildren, $newParseTreeOwner);
    $self->setAPIOBackReferences( $self->{CLASSES}, $freeclasses, $newParseTreeOwner);

    $self->{CONSTANTS} = undef;
    $self->{FUNCTIONS} = undef;
    $self->{METHODS} = undef;
    $self->{TYPEDEFS} = undef;
    $self->{STRUCTS} = undef;
    $self->{VARS} = undef;
    $self->{PDEFINES} = undef;
    $self->{ENUMS} = undef;
    $self->{CLASSES} = undef;
    $self->{HEADEROBJECT} = undef;
    $self->{APIOWNER} = undef;
    $self->{GROUPS} = undef;
    $self->{KEYWORDHASH} = undef;

    if (!$self->noRegisterUID()) {
	dereferenceUIDObject($self->apiuid(), $self);
    }

    $self->SUPER::free($freechildrenraw, $keepParseTreeAndState, $newParseTreeOwner);

    # printHash(%{$self});
}

# /*!
#     @abstract
#         Removes an object from a group.
#     @param self
#         The <code>APIOwner</code> object that owns the object.
#     @param groupname
#         The name of the group.
#     @param object
#         The object to remove.
#     @discussion
#         This function looks up a group by name and manipulates the
#         associated {@link //apple_ref/perl/cl/HeaderDoc::Group Group}
#         object transparently.
#  */
sub removeFromGroup()
{
	my $self = shift;
	my $groupname = shift;
	my $object = shift;

	my $localDebug = 0;

	$object->clearGroup();

	if ($addToDebug) { print STDERR "REMOVED $object FROM GROUP\n"; }
	if ($object =~ /HeaderDoc::HeaderElement/) { return; }
	print STDERR "Removed object $object from group $groupname\n" if ($localDebug);

	my %groups = %{$self->{GROUPS}};

	my $group = $groups{$groupname};

	if (!$group) {
		$group = HeaderDoc::Group->new("LANG" => $self->lang(), "SUBLANG" => $self->sublang());
		$group->fullpath($self->fullpath);
		$group->filename($self->filename());
		$group->linenuminblock($self->linenuminblock());
		$group->blockoffset($self->blockoffset());
	}
	my @array = ();
	if ($group->{MEMBEROBJECTS}) {
		@array = @{$group->{MEMBEROBJECTS}};
	}
	# print "ADDING $object\n";
	my @newarray = ();
	my $found = 0;
	foreach my $item (@array) {
		if ($item != $object) {
			push(@newarray, $object);
		} else {
			$found = 1;
		}
	}
	if (!$found) {
		warn("NOT FOUND.  GROUP REMOVAL FAILED.  FILE A BUG.\n");
		cluck("backtrace follows:\n");
		warn("OBJ: $object NAME: ".$object->name()."\n");
		warn("APIO: $self NAME: ".$self->name()."\n");
	} else {
		warn("FOUND.\n") if ($localDebug);
	}
	$group->{MEMBEROBJECTS} = \@newarray;

	$groups{$groupname} = $group;
	$self->{GROUPS} = \%groups;
}

# /*!
#     @abstract
#         Adds an object to a group.
#     @param self
#         The <code>APIOwner</code> object that owns the object.
#     @param groupname
#         The name of the group.
#     @param object
#         The object to remove.
#     @discussion
#         This function looks up a group by name and manipulates the
#         associated {@link //apple_ref/perl/cl/HeaderDoc::Group Group}
#         object transparently.
#  */
sub addToGroup()
{
	my $self = shift;
	my $groupname = shift;
	my $object = shift;

	my $localDebug = 0;

	if ($addToDebug) { print STDERR "ADDED $object TO GROUP $groupname\n"; }
	if ($object =~ /HeaderDoc::HeaderElement/) { return; }
	print STDERR "Added object $object to group $groupname\n" if ($localDebug);

	my %groups = %{$self->{GROUPS}};

	my $group = $groups{$groupname};

	my $lang = $self->lang();
	my $sublang = $self->sublang();

	if ($lang eq "C" || $lang eq "Csource") {
		if ($sublang eq "cpp" || $sublang eq "occ") {
			$sublang = "C";
		}
	}

	if (!$group) {
		$group = HeaderDoc::Group->new("LANG" => $self->lang(), "SUBLANG" => $self->sublang());
		$group->fullpath($self->fullpath);
		$group->filename($self->filename());
		$group->linenuminblock($self->linenuminblock());
		$group->blockoffset($self->blockoffset());
	}
	my @array = ();
	if ($group->{MEMBEROBJECTS}) {
		@array = @{$group->{MEMBEROBJECTS}};
	}
	# print "ADDING $object\n";
	foreach my $obj (@array) {
		if ($obj == $object) { return; }
	}
	push(@array, $object);
	$group->{MEMBEROBJECTS} = \@array;

	$groups{$groupname} = $group;
	$self->{GROUPS} = \%groups;
}

# /*!
#     @abstract
#         Adds a group to an <code>APIOwner</code> object.
#     @param self
#         The <code>APIOwner</code> object.
#     @param group
#         The {@link //apple_ref/perl/cl/HeaderDoc::Group Group} object.
#  */
sub addGroup()
{
	my $self = shift;
	my $group = shift;

	my %groups = %{$self->{GROUPS}};

	my $groupname = $group->name();

	# print "GROUP $groupname added\n";

	$groups{$groupname} = $group;

	$self->{GROUPS} = \%groups;

	return $group;
}

# /*!
#     @abstract
#         Searches for a group associated with an <code>APIOwner</code> object.
#     @param self
#         The <code>APIOwner</code> object.
#     @param name
#         The name to look for.
#     @returns
#         Returns the {@link //apple_ref/perl/cl/HeaderDoc::Group Group} object found.
#  */
sub findGroup
{
	my $self = shift;
	my $groupname = shift;

	my %groups = %{$self->{GROUPS}};

	return $groups{$groupname};
}

# /*!
#     @abstract
#         Returns the documentation block for groups.
#     @param self
#         The <code>APIOwner</code> object.
#     @param title
#         A title string for the heading above this documentation block.
#  */
sub groupDoc()
{
	my $self = shift;
	my $title = shift;
	my $string = "";
	my %groups = %{$self->{GROUPS}};

	my $xml = 0;
	if (!$title) {
		$xml = 1;
	}

	my $localDebug = 0;

	if (scalar(keys %groups)) {
		my $first = 1;
		foreach my $group (keys %groups) {
			my $group = $groups{$group};
			my $groupname = $group->name();
			if ($groupname ne "") {
				if ($first) { $first = 0; }
				elsif (!$xml) { $string .= "<p>&nbsp;</p>\n"; }

				my $abs = $group->abstract();
				my $desc = $group->discussion();
				if ($xml) {
					$string .= "<groupinfo>\n";
					$string .= "<name>".$self->textToXML($groupname)."</name>\n";
					if ($abs =~ /\S/) {
						$string .= "<abstract>".$self->htmlToXML($abs)."</abstract>";
					}
					if ($desc =~ /\S/) {
						$string .= "<desc>".$self->htmlToXML($desc)."</desc>";
					}
					$string .= "</groupinfo>\n";
				} else {
					$string .= "<h3>$groupname</h3>\n<div class='group_desc_indent'>\n";
					if ($abs =~ /\S/) {
						$string .= "<p>$abs</p>";

						if ($desc =~ /\S/) {
							$string .= "<h5 class=\"tight\"><font face=\"Lucida Grande,Helvetica,Arial\">Discussion</font></h5>\n";

						}
					}
					if ($desc =~ /\S/) {
						$string .= "<p>$desc</p>";
					}
					$string .= "</div>\n";
				}

				if ($group->{MEMBEROBJECTS} && !$xml) {
					my @array = @{$group->{MEMBEROBJECTS}};
					if (scalar(@array)) {
						$string .= "<h4>Group members:</h4>\n<div class='group_indent'>\n";
						print STDERR "getClassEmbeddedTOC: group members found.\n" if ($localDebug);
						my @tempobjs = ();
						if (!$self->unsorted()) {
							@tempobjs = sort objName @array;
						} else {
							@tempobjs = @array;
						}
						my @newtempobjs = ();
						foreach my $item (@tempobjs) {
							if ($item->{INSERTED}) {
								push(@newtempobjs, $item);
							}
						}
						if ($localDebug) {
							foreach my $item(@newtempobjs) {
								print STDERR "TO: $item : ".$item->name()."\n";
							}
						}
						my $composite = 0;
						$string .= $self->_getEmbeddedTOC(\@newtempobjs, "Group Members", "groups", "Group Members", $composite, 0, 1);
						$string .= "</div>\n";
    					}
				}
			}
		}
	}

	# Don't display the heading unless there is content below it.
	if ($string =~ /\S/) {
		if ($xml) {
			$string = "<groups>\n".$string."</groups>\n";
		} else {
			$string = "<a name='HeaderDoc_groups'>$title</a>\n\n".$string;
			$string .= "<hr class=\"afterGroupHeading\">";
		}
	}

	return $string;
}

# /*!
#     @abstract
#         Destroys any class objects associated with modules (which are
#         not really classes, but can most easily be parsed as such).
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub reparentModuleMembers
{
	my $self = shift;
	my $localDebug = 0;

	if ($self->isModule()) {
		my $apiOwner = $self->apiOwner();
		print STDERR "$self IS module\n" if ($localDebug);

		my @objs = $self->classes();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			if ($obj->reparentModuleMembers()) {
				print STDERR "ADDING OBJ: $obj\n" if ($localDebug);
				$apiOwner->addToClasses(($obj));
			} else {
				print STDERR "Failed reparent check\n" if ($localDebug);
			}
		}
		@objs = $self->protocols();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToProtocols($obj);
		}
		@objs = $self->categories();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToCategories($obj);
		}
		@objs = $self->functions();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToFunctions($obj);
		}
		@objs = $self->methods();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToMethods($obj);
		}
		@objs = $self->constants();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToConstants($obj);
		}
		@objs = $self->typedefs();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToTypedefs($obj);
		}
		@objs = $self->structs();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToStructs($obj);
		}
		@objs = $self->enums();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToEnums($obj);
		}
		@objs = $self->pDefines();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToPDefines($obj);
		}
		@objs = $self->vars();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToVars($obj);
		}
		@objs = $self->props();
		foreach my $obj (@objs) {
			print STDERR "Reparenting $obj (".$obj->name().") as child of $apiOwner\n" if ($localDebug);
			$obj->apiOwner($apiOwner);
			if (!$obj->indexgroup()) {
				$obj->indexgroup($self->name());
			}
			$obj->attribute("Module", $self->name(), 0);
			$apiOwner->addToProps($obj);
		}
		return 0;
	} else {
		print STDERR "$self is NOT module\n" if ($localDebug);
		my @classes = $self->classes();
		$self->{CLASSES} = ();
		my $apiOwner = $self->apiOwner();
		foreach my $class (@classes) {
			print STDERR "Checking $class (".$class->name().")\n" if ($localDebug);
			if (!$class->isModule()) {
				print STDERR "Keeping $class (".$class->name().")\n" if ($localDebug);
				$self->addToClasses(($class));
			} else {
				print STDERR "Dropping $class (".$class->name().")\n" if ($localDebug);
				$class->reparentModuleMembers();
			}
		}
		if ($localDebug) {
			my @cltemp = $self->classes();
			print STDERR "Dumping list for $self (".$self->name().")\n";
			foreach my $class (@cltemp) {
				print STDERR "CLASS $class (".$class->name().")\n";
			}
			print STDERR "End dump\n";
		}
	}
	return 1;
}

# /*!
#     @abstract
#         Gets/appends to the "also include" array.
#     @param self
#         This object.
#     @param newarray
#         The new array to set. (Optional.)
#     @discussion
#         This is used with C pseudoclasses to tell the
#         parser to also include certain function
#         declarations as members.
#   */
sub alsoInclude
{
    my $self = shift;
    if (@_) {
	my $value = shift;
	if (!$self->{ALSOINCLUDE}) {
		my @temp = ($value);
		$self->{ALSOINCLUDE} = \@temp;
	} else {
		push(@{$self->{ALSOINCLUDE}}, $value);
	}
    }
    return $self->{ALSOINCLUDE};
}

# /*!
#     @abstract
#         Gets/sets whether TOC content for an API owner should be
#         sorted or not.
#     @param self
#         The API owner object.
#     @param value
#         Optional.  If passed in, the new value.
#     @returns
#         Returns the current value (after changing it, if necessary).
#     @discussion
#         Legal values are 0 (sorted) and 1 (unsorted).
#  */
sub unsorted {
    my $self = shift;
    if (@_) {
	my $newval = shift;

	$self->{UNSORTED} = $newval;
    }
    return $self->{UNSORTED};
}

# /*!
#     @abstract
#         Strips out nasty bits from titles.
#  */
sub striptitle {
    my $data = shift;

    $data =~ s/&nbsp;/ /sg;
    # $data =~ s/&nbsp;/\xA0/sg; # Sadly, doesn't work.
    # $data =~ s/&nbsp;/\x{00A0}/sg; # Sadly, doesn't work.
    $data =~ s/&amp;/&/sg;

    return $data;
}


# /*!
#     @abstract
#         Turns <code>\@function</code> <code>#define</code> macros
#         into functions.
#     @discussion
#         Fixes the case where the author requests <code>\@function</code>
#         treatment for a <code>#define</code> declaration.  This is used
#         only for HTML output paths.  For XML, function and
#         value <code>#define</code> macros have different attribute values that
#         you can screen for on a global basis, if desired.
#  */
sub fixupTypeRequests
{
    my $self = shift;
    my @objs = $self->pDefines();
    my @newobjs = ();

    foreach my $obj (@objs) {
	# print STDERR "CHECKING $obj.  OT=".$obj->origType()."\n";
	if ($obj->origType() eq "function") {
		$self->addToFunctions($obj);
	} else {
		push(@newobjs, $obj);
	}
    }

    $self->{PDEFINES} = \@newobjs;
}


# /*!
#     @abstract
#         Marks an API reference ID as having been emitted already.
#     @param self
#         The API owner object.
#     @param uid
#         The user ID to query or set.
#     @param used
#         Normally, you would pass 1 when setting.  If you just
#         want to query the value, do not pass this argument.
#  */
sub appleRefUsed
{
    my $self = shift;
    my $uid = shift;

    my %map = ();

    if ($self->{APPLEREFUSED}) {
	%map = %{$self->{APPLEREFUSED}};
    }

    my $retval = $map{$uid};

    if (@_) {
	# print STDERR "SETTING USED FOR $uid ON $self\n";
	$map{$uid} = 1;
	$self->{APPLEREFUSED} = \%map;
    }

    return $retval;
}

# /*!
#     @abstract
#         Clears the API reference hash used by {@link appleRefUsed}.
#     @discussion
#         This is called when an API owner object needs to be
#         emitted again (e.g. when a category's methods are folded
#         into a class in another header).
#  */
sub resetAppleRefUsed
{
    my $self = shift;

    # print STDERR "RESETTING USED ON $self\n";
    delete $self->{APPLEREFUSED};
}

1;


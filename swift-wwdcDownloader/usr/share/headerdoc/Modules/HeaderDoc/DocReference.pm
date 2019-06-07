#! /usr/bin/perl -w
#
# Class name: 	DocReference
# Synopsis: 	Used by gatherHeaderDoc.pl to hold references to doc 
#		for individual headers and classes
# Last Updated: $Date: 2011/03/18 16:07:18 $
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
#         <code>DocReference</code> class package file.
#     @discussion
#         This file contains the <code>DocReference</code> class, a
#         simple data structure used to hold references to documents in
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}.
#
#         See the class documentation below for more information.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*! @abstract
#         Describes the properties of an API or document reference
#         (apple_ref).
#     @discussion
#         A data structure used for holding references to documents in
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}.
#
#         Each object contains the name of a header, class, or API symbol,
#         along with its path, its unique identifier (API refeference) and
#         bits of related information like the symbol's abstract,
#         discussion, and declaration (where available).
#     @var OUTPUTFORMAT
#         Unused.
#     @var UID
#         The API reference (UID) for this doc reference,
#         e.g. //apple_ref/c/func/foo.
#
#         See the
#  {@linkdoc //apple_ref/doc/uid/TP40001215 HeaderDoc User Guide}
#         for more information about API symbol markers.
#     @var NAME
#         The "long name" (name specified in a tag such as
#         <code>\@header</code>, <code>\@function</code>, etc.
#     @var SHORTNAME
#         The "short name" (code symbol name or raw
#         filename) for this doc reference.
#     @var GROUP
#         The index group for this doc reference.
#         (From the <code>\@indexgroup</code> tag.)
#     @var TYPE
#         The type part of the UID (e.g. <code>cl</code> for class).
#
#         See the
#  {@linkdoc //apple_ref/doc/uid/TP40001215 HeaderDoc User Guide}
#         for more information about API symbol markers.
#     @var PATH
#         The filesystem path to the file containing this
#         doc reference.
#     @var LANGUAGE
#         The language part of the UID for this doc reference.
#     @var DECLARATION
#         The declaration (code) associated with this doc
#         reference.
#     @var ABSTRACT
#         The <code>\@abstract</code> associated with this doc reference.
#     @var DISCUSSION
#         The <code>\@discussion</code> associated with this doc reference.
#     @var PUSHED
#         Set to 1 when the doc reference has already been
#         added to the doc reference array so that it doesn't
#         get added multiple times when the discussion and
#         abstract are located.
#     @var MANSRC
#         Holds information about which set of manual pages a
#         man page came from.  Access this variable with the
#         {@link mansrc} function.
#  */
package HeaderDoc::DocReference;

use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::DocReference::VERSION = '$Revision: 1300489638 $';

################ General Constants ###################################
my $debugging = 0;

my %docRefUIDCache = ();
my %docRefUIDFileCache = ();
my %docRefNameToUIDCache = ();

# /*!
#     @abstract
#         Creates a new <code>DocReference</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::DocReference->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param;
    my $self = {};
    
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
#         Initializes an instance of a <code>DocReference</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->{OUTPUTFORMAT} = undef;
    $self->{UID} = undef;
    $self->{NAME} = undef;
    $self->{GROUP} = " ";
    $self->{TYPE} = undef; # Header, CPPClass, etc
    $self->{PATH} = undef;
    $self->{LANGUAGE} = "";
}

# /*!
#     @abstract
#         Gets/sets the path associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param path
#         The path to set.  (Optional.)
#  */
sub path {
    my $self = shift;

    if (@_) {
        $self->{PATH} = shift;
    }
    return $self->{PATH};
}


# /*!
#     @abstract
#         Gets/sets the language associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param language
#         The language to set.  (Optional.)
#  */
sub language {
    my $self = shift;

    if (@_) {
        $self->{LANGUAGE} = shift;
    }
    return $self->{LANGUAGE};
}


# /*!
#     @abstract
#         Returns whether this doc reference has a "doc" API reference.
#     @param self
#         The <code>DocReference</code> object.
#  */
sub isDoc {
    my $self = shift;

    if ($self->language() eq "doc") { return 1; }
    return 0;
}


# /*!
#     @abstract
#         Gets/sets the output format for this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param outputformat
#         The output format value to set.  (Optional.)
#  */
sub outputformat {
    my $self = shift;

    if (@_) {
        $self->{OUTPUTFORMAT} = shift;
    }
    return $self->{OUTPUTFORMAT};
}


# /*!
#     @abstract
#         Gets/sets the discussion associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param discussion
#         The discussion to set.  (Optional.)
#  */
sub discussion {
    my $self = shift;

    if (@_) {
        $self->{DISCUSSION} = shift;
    }
    return $self->{DISCUSSION} || "";
}


# /*!
#     @abstract
#         Quotes a string for passing to <code>grep</code>.
#     @param string
#         The string to quote.
#  */
sub quoteForGrep
{
    my $string = shift;
    $string =~ s/([]\\\/[])/\\$1/sg;
    $string =~ s/'/'"'"'/sg;
    $string =~ s/^(\^)/\\$1/sg;
    $string =~ s/(\$)$/\\$1/sg;

    return $string;
}


# /*!
#     @abstract
#         Quotes a string for passing to <code>whatis</code>.
#     @param string
#         The string to quote.
#  */
sub quoteForWhatIs
{
    my $string = shift;

    return quoteForGrep($string);

    # Note: The whatis command currently uses grep and does
    # not quote the arguments.  If that ever changes,
    # this function should the code below instead.

    # $string =~ s/'/'"'"'/sg;
    # $string =~ s/^(\^)/\\$1/sg;
    # $string =~ s/(\$)$/\\$1/sg;

    # return $string;
}

my %manpageAbstracts = ();

# /*!
#     @abstract
#         Gets/sets the abstract associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param abstract
#         The abstract to set.  (Optional.)
#     @discussion
#         For manual pages, this goes out and requests the abstract
#         using <code>whois</code>.
#  */
sub abstract {
    my $self = shift;

    if (@_) {
        $self->{ABSTRACT} = shift;
    }
    my $ret = $self->{ABSTRACT} || "";

    if ($HeaderDoc::useWhatIs && (!length($ret))) {

	if ($manpageAbstracts{$self->{PATH}}) {
		return $manpageAbstracts{$self->{PATH}};
	}

	my $temp = $/;
	$/ = undef;

	# print "NAME: ".$self->name()."\nMPNAME: ".$self->mpname()."\n";

	my $mpn = quoteForGrep($self->mpname());
	if ($mpn) {
		# print $self->uid()." is a man page\n";
		# print "/usr/bin/whatis '".quoteForWhatIs($self->name())."' | grep -v \"nothing appropriate\" | grep '$mpn' |";
		open(WI, "/usr/bin/whatis '".quoteForWhatIs($self->name())."' | grep -v \"nothing appropriate\" | grep '$mpn' |") || die("Could not run /usr/bin/whatis\n");
	} else {
		# print $self->uid()." is NOT a man page\n";
		# print "/usr/bin/whatis '".quoteForWhatIs($self->name())."' | grep -v \"nothing appropriate\" | grep '".quoteForGrep($self->name())."([23]' |\n";
		open(WI, "/usr/bin/whatis '".quoteForWhatIs($self->name())."' | grep -v \"nothing appropriate\" | grep '".quoteForGrep($self->name())."([23]' |") || die("Could not run /usr/bin/whatis\n");
	}
	$ret = <WI>;
	$ret = getCorrectWhoIsInfo($ret, $self->name());
	$/ = $temp;
	# print "RAW: $ret\n";
	$ret =~ s/.*?- //s;
	# print "RAW: $ret\n";
	$ret =~ s/[\n\r]//s;
	# print "RAW: $ret\n";
	$ret =~ s/^[-\x{2014}\x{2013}[:space:]]*//s; # Nuke any leading hyphens,
	                                             # dashes, or whitespace.
	# print "RAW: $ret\n";
	$manpageAbstracts{$self->{PATH}} = $ret;
    }
	
    return $ret;
}

# /*!
#     @abstract
#         Splits up the results from whois, prioritizing single entries over
#         collective ones and earlier collective results over later ones.
#  */
sub getCorrectWhoIsInfo
{
	my $line = shift;
	my $name = shift;

	my @parts = split(/\n/, $line);
	my $result = "";
	my $altresult = "";
	my $inResult = 0;

	foreach my $part (@parts) {
		# print STDERR "PART: $part\n";
		if ($part =~ /^\s*$name\([^)]*\)\s*-/) {
			$result = $part;
		} elsif ($part =~ /(^|\s)$name\(.*\).*-/) {
			if (!$altresult) { $altresult = $part; }
		}
	}

	# print STDERR "RESULT: \"$result\"\n";
	# print STDERR "ALTRESULT: \"$altresult\"\n";
	if ($result) { return $result; }
	return $altresult;
}


# /*!
#     @abstract
#         Gets/sets the discussion associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param discussion
#         The discussion to set.  (Optional.)
#  */
sub declaration {
    my $self = shift;

    if (@_) {
        $self->{DECLARATION} = shift;
    }
    if ($self->{DECLARATION}) {
    	return $self->{DECLARATION};
    } else {
	if ($HeaderDoc::useWhatIs) {
		my $refsfile = $self->{PATH}.".decs";
		if (-f $refsfile) {
			open(REFSFILE, "<$refsfile");
			my $temp = $/;
			$/ = undef;

			my $data = <REFSFILE>;
			close(REFSFILE);
			$/ = $temp;

			my $uid = $self->uid();

# print "SEARCH: $uid\n";
# print "DATA: $data\n";
			$data =~ s/(^|.*\n)\Q$uid\E\n//s;

# print "POSTDATA: $data\n";

			if ($data !~ /^X/) {
				# print "NOT FOUND\n";
				return "";
			}

			$data =~ s/\n[^X].*$//s;

# print "RAWDEC:\n$data\n";

			$data =~ s/^X//s;
			$data =~ s/\nX/\n/sg;

# print "FINALDATA:\n$data\n";
			return $data;
		}
	}
	return "";
    	# return $self->{NAME};
    }

}


# /*!
#     @abstract
#         Gets/sets the uid associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param uid
#         The uid to set.  (Optional.)
#     @discussion
#         If called repeatedly, any non-doc apple_ref will stick with
#         higher precedence than any doc apple_ref.
#     @returns
#         Returns any existing doc reference object for the
#         specified doc ID from the current file.
#  */
sub uid {
    my $self = shift;

    if (@_) {
	my $uid = shift;
	my $file = shift;

	if ($uid =~ /\/\/[^\/]+\/c\/([^\/]+)\/([^\/]+)/) {
		my $type = $1;
		my $name = $2;

		# print STDERR "MAPPING $name to $uid\n";
		$docRefNameToUIDCache{$name} = $uid;
	} else {
		# print STDERR "BAD UID $uid\n";
	}

       	$self->{UID} = $uid;

	my %temphash = ();
	if ($docRefUIDFileCache{$uid}) {
		%temphash = %{$docRefUIDFileCache{$uid}};
	}
	if ($temphash{$file}) {
		# print STDERR "$uid/$file FOUND IN HASH\n";
		return $temphash{$file};
	# } else {
		# print STDERR "$uid/$file NOT FOUND IN HASH\n";
	}

	$temphash{$file} = $self;
	$docRefUIDFileCache{$uid} = \%temphash;

	# Fill up the non-per-file hash for man pages, too.
	$docRefUIDCache{$uid} = $self;
	return $self;
    }
    return $self->{UID};
}

# /*!
#     @abstract
#         Returns whether a UID has been seen.
#  */
sub isInCache {
    my $self = shift;
    my $uid = shift;

    if ($docRefUIDCache{$uid}) {
	return $docRefUIDCache{$uid};
    }

    return undef;
}


# /*!
#     @abstract
#         Gets/sets the name associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param name
#         The name to set.  (Optional.)
#  */
sub name {
    my $self = shift;

    if (@_) {
	if (!$self->{NAME}) {
        	$self->{NAME} = shift;
		# if ($self->uid() !~ /\/\/[^\/]+\/doc\/man\//) {
			# $docRefNameToUIDCache{$self->{NAME}} = $self->uid();
		# }
	}
    }
    return $self->{NAME};
}


# /*!
#     @abstract
#         Sets the man page name associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @discussion
#         For doc references of man pages, this returns the name in
#         the standard man page format, e.g. name(number).
#         For non-man-page references, this returns an empty string.
#  */
sub mpname {
    my $self = shift;
    my $uid = $self->uid();
    my @uidparts = split(/\//, $uid);

    if ($uidparts[3] ne "doc") {
	# warn("NOT: 3 is \"".$uidparts[3]."\" ($uid)\n");
	return "";
    }
    if ($uidparts[4] ne "man") {
	# warn("NOT: 4 is \"".$uidparts[4]."\" ($uid)\n");
	return "";
    }

    return $uidparts[6]."(".$uidparts[5].")";
}

# /*!
#     @abstract
#         Gets/sets the group associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param group
#         The group to set.  (Optional.)
#  */
sub group {
    my $self = shift;

    if (@_) {
	my $newgroupname = shift;
	if (!length($newgroupname)) { $newgroupname = " "; }
        $self->{GROUP} = $newgroupname;
    }
    return $self->{GROUP};
}


# /*!
#     @abstract
#         Gets/sets the short name associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param shortname
#         The short name to set.  (Optional.)
#     @discussion
#         The short name refers to the name of a framework (without the
#         trailing ".framework" or any other path parts).
#  */
sub shortname {
    my $self = shift;

    if (@_) {
        $self->{SHORTNAME} = shift;
    }
    return $self->{SHORTNAME};
}


# /*!
#     @abstract
#         Gets/sets the mansrc value associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param type
#         The mansrc value to set.  (Optional.)
#     @discussion
#         The mansrc value refers to the part of a doc navigator comment after
#         the "mansrc=" part.  It is used to hold information about which
#         set of man pages a man page came from (e.g. base, server, etc.).
#  */
sub mansrc {
    my $self = shift;

    if (@_) {
        $self->{MANSRC} = shift;
    }
    return $self->{MANSRC};
}


# /*!
#     @abstract
#         Gets/sets the type associated with this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param type
#         The type to set.  (Optional.)
#     @discussion
#         The type refers to the part of a doc navigator comment after
#         the "headerDoc=" part.
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
#         Gets/sets the "pushed" state for this doc reference.
#     @param self
#         The <code>DocReference</code> object.
#     @param pushed
#         The pushed state to set.  (Optional.)
#     @discussion
#         The pushed state refers to whether the doc reference has
#         already been pushed into the array of doc references in
#         {@link //apple_ref/doc/header/gatherHeaderDoc.pl gatherHeaderDoc}
#         or not.  This is needed because subsequent discussions and
#         abstracts get folded back into the same doc reference, and you
#         don't want to end up pushing it twice.
#  */
sub pushed {
    my $self = shift;

    if (@_) {
        $self->{PUSHED} = shift;
    }
    return $self->{PUSHED};
}

# /*!
#     @abstract
#         Prints a DocReference object for debugging purposes.
#     @param self
#         The object to initialize.
#  */
sub dbprint {
    my $self = shift;
    $self->printObject();
}

# /*!
#     @abstract
#  */
sub seealso {
    my $self = shift;

    my @returnrefs = ();
    my $relatedfile = $self->{PATH}.".xrefs";
    if (-f $relatedfile) {
	open(RELATEDFILE, "<$relatedfile");
	my $temp = $/;
	$/ = undef;

	my $data = <RELATEDFILE>;
	close(RELATEDFILE);
	$/ = $temp;

	my @arr = split(/\n/, $data);
	my %refs = ();

	foreach my $ref (@arr) {
		$refs{$ref} = $ref;
	}

	foreach my $ref (keys %refs) {
		if ($self->isInCache($ref)) {
			# print STDERR "RELATED REF: $ref\n";
			if ($ref =~ /\/\/[^\/]+\/doc\/man\//) {
				push(@returnrefs, translateManRef($ref));
			} else {
				push(@returnrefs, $ref);
			}
		} else {
			# print STDERR "NOT FOUND RELATED REF: $ref\n";
		}
	}
    }
    return @returnrefs;
}

# /*!
#     @abstract
#         Alias to <code>dbprint</code>.
#     @param self
#         The object to initialize.
#  */
sub printObject {
    my $self = shift;
 
    print STDERR "----- DocReference Object ------\n";
    print STDERR "uid:  $self->{UID}\n";
    print STDERR "name: $self->{NAME}\n";
    print STDERR "type: $self->{TYPE}\n";
    print STDERR "path: $self->{PATH}\n";
    print STDERR "language: $self->{LANGUAGE}\n";
    print STDERR "abstract: ".($self->{ABSTRACT} || "")."\n";
    print STDERR "discussion: ".($self->{DISCUSSION} || "")."\n";
    print STDERR "declaration: ".($self->{DECLARATION} || "")."\n";
    print STDERR "\n";
}

# /*!
#     @abstract
#         Maps a man page doc reference to a C reference.
#     @param ref
#         The input doc reference.
#     @discussion
#         Uses the <code>docRefNameToUIDCache</code> cache, which is populated
#         in {@link uid}.
#  */
sub translateManRef
{
    my $ref = shift;

    if ($ref =~ /\/\/[^\/]+\/doc\/man\/([^\/]+)\/(.*?)$/) {
	my $section = $1;
	my $name = $2;

	# print STDERR "NAME: $name REF: $ref\n";

	if (($section =~ /^3/) && ($docRefNameToUIDCache{$name})) {
		# print STDERR "TRANSLATE: $ref -> ".$docRefNameToUIDCache{$name}."\n";
		return $docRefNameToUIDCache{$name};
	}
    }

    # print STDERR "TRANSLATE FAILED: $ref\n";
    return $ref;
}

# /*!
#     @abstract
#         Prevents C API reference symbols from showing up in man page output.
#  */
sub hidden
{
    my $self = shift;

    if (@_) {
        $self->{HIDDEN} = shift;
    }
    return $self->{HIDDEN};
}

1;

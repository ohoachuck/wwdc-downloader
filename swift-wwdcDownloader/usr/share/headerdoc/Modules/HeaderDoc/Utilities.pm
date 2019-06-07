#! /usr/bin/perl -w
# Utilities.pm
# 
# Common subroutines
# Last Updated: $Date: 2014/02/26 10:58:03 $
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
#         <code>Utilities</code> package file.
#     @discussion
#         This header contains the <code>Utilities</code> package.
#
#         For details, see the package documentation below.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Miscellaneous support functions.
#     @discussion
#         The most important of the functions in this package
#         is {@link parseTokens}.  It is used to provide a number
#         of special tokens used the parsing process.
#         Other functions 
#  */
package HeaderDoc::Utilities;
use strict;
use vars qw(@ISA @EXPORT $VERSION);
use Carp qw(cluck);
use IPC::Open2;
use IO::Handle;
# use HeaderDoc::MacroFilter qw(filterFileString);

use Cwd;
use Encode;
use Encode::Guess;
use Encode qw(encode decode);

use HTML::Entities qw(encode_entities);

use Exporter;
foreach (qw(Mac::Files Mac::MoreFiles)) {
    eval "use $_";
}

my $depth = 0;

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::Utilities::VERSION = '$Revision: 1393441083 $';
@ISA = qw(Exporter);
@EXPORT = qw(findRelativePath safeName safeNameNoCollide linesFromFile makeAbsolutePath
             printHash printArray fileNameFromPath folderPathForFile 
             updateHashFromConfigFiles getHashFromConfigFile getVarNameAndDisc
             getAPINameAndDisc doxyTagFilter
             registerUID resolveLink parseTokens isKeyword html2xhtml
             resolveLinks stringToFields sanitize warnHDComment
             classTypeFromFieldAndBPinfo casecmp unregisterUID
	     unregister_force_uid_clear dereferenceUIDObject validTag emptyHDok
	     addAvailabilityMacro complexAvailabilityToArray
	     filterHeaderDocComment filterHeaderDocTagContents processTopLevel
	     processHeaderComment getLineArrays objectForUID
	     loadHashes saveHashes getAbsPath allow_everything
	     getAvailabilityMacros printFields stripTags
	     objName byLinkage byAccessControl objGroup linkageAndObjName
	     byMethodType getLangAndSubLangFromFilename splitOnPara
	     peek dumpCaches getDefaultEncoding stripLeading
	     fixXHTMLAttributes html_fixup_links xml_fixup_links
	     calcDepth isStandardAvailability);

my %uid_list_by_uid = ();
my %uid_list = ();
my %uid_conflict = ();
my %uid_candidates = ();
my $xmllintversion = "";
my $xmllint = "/usr/bin/xmllint";

my %objid_hash;

########## Portability ##############################
my $pathSeparator;
my $isMacOS;
BEGIN {
	if ($^O =~ /MacOS/io) {
		$pathSeparator = ":";
		$isMacOS = 1;
	} else {
		$pathSeparator = "/";
		$isMacOS = 0;
	}
}

$xmllint = "/usr/bin/xmllint";

if ( ! -x $xmllint ) {
	if ( -x "/usr/local/bin/xmllint" ) {
		$xmllint = "/usr/local/bin/xmllint";
	} elsif (-x "/sw/bin/xmllint" ) {
		$xmllint = "/sw/bin/xmllint";
	} elsif (-x "/opt/local/bin/xmllint" ) {
		$xmllint = "/sw/bin/xmllint";
	}
}

open(XMLLINTPIPE, "$xmllint --version 2>&1 |");
$xmllintversion = <XMLLINTPIPE>;
close(XMLLINTPIPE);
# print STDERR "STRING \"$xmllintversion\".\n";
$xmllintversion =~ s/\n.*//sg;
$xmllintversion =~ s/.*?(\d+)/$1/s;
if ($xmllintversion eq "20607") {
	warn "Old LibXML2 version.  XML Output may not work correctly.\n";
}

########## Name length constants ##############################
my $macFileLengthLimit;
BEGIN {
	if ($isMacOS) {
		$macFileLengthLimit = 31;
	} else {
		$macFileLengthLimit = 255;
	}
}
my $longestExtension = 5;
###############################################################

# /*! @group Path Functions
#     @abstract
#         Functions for working with paths.
#  */


# /*!
#     @abstract
#         Finds the relative path to a file from another file.
#     @param fromMe
#         The path of the file where the link itself will be
#         written.
#     @param toMe
#         The path of the file the link will point to.
#  */
sub findRelativePath {
    my ($fromMe, $toMe) = @_;
    if ($fromMe eq $toMe) {return "";}; # link to same file
	my @fromMeParts = split (/$pathSeparator/, $fromMe);
	my @toMeParts = split (/$pathSeparator/, $toMe);
	
	# find number of identical parts
	my $i = 0;
	# figure out why perl complain of uninitialized var in while loop
	my $oldWarningLevel = $^W;
	{
	    $^W = 0;
		while ($fromMeParts[$i] eq $toMeParts[$i]) { $i++;};
	}
	$^W = $oldWarningLevel;
	
	@fromMeParts = splice (@fromMeParts, $i);
	@toMeParts = splice (@toMeParts, $i);
    my $numFromMeParts = @fromMeParts; #number of unique elements left in fromMeParts
  	my $relPart = "../" x ($numFromMeParts - 1);
	my $relPath = $relPart.join("/", @toMeParts);
	return $relPath;
}

# set up default values for safeName and safeNameNoCollide
# /*!
#     @abstract
#         Default values for {@link safeName}.
#  */
my %safeNameDefaults  = (filename => "", fileLengthLimit =>"$macFileLengthLimit", longestExtension => "$longestExtension");

# /*!
#     @abstract
#         Otains a safe filename from a header or class name.
#     @param args
#         A hash of arguments.  The default arguments are in
#         {@link safeNameDefaults}.  Normally, you override
#         only the filename argument, e.g.
#
#         <code>my $safename = &safeName(filename => $name);</code>
#  */
sub safeName {
    my %args = (%safeNameDefaults, @_);
    my ($filename) = $args{"filename"};
    my $returnedName="";
    my $safeLimit;
    my $partLength;
    my $nameLength;

    $safeLimit = ($args{"fileLengthLimit"} - $args{"longestExtension"});
    $partLength = int (($safeLimit/2)-1);

    $filename =~ tr/a-zA-Z0-9./_/cs; # ensure name is entirely alphanumeric
    $nameLength = ($filename =~ tr/a-zA-Z0-9._//);

    #check for length problems
    if ( $nameLength > $safeLimit) {
        my $safeName =  $filename;
        $safeName =~ s/^(.{$partLength}).*(.{$partLength})$/$1_$2/;
        $returnedName = $safeName;       
    } else {
        $returnedName = $filename;       
    }
    return $returnedName;
    
}


my %dispensedSafeNames;

# /*!
#     @abstract
#         Otains a safe filename from a header or class name,
#         modifying the results as needed to guarantee uniqueness
#         (even on case-insensitive volumes).
#     @param args
#         A hash of arguments.  The default arguments are in
#         {@link safeNameDefaults}.  Normally, you override
#         only the filename argument, e.g.
#
#         <code>my $safename = &safeNameNoCollide(filename => $name);</code>
#  */
sub safeNameNoCollide {
    my %args = (%safeNameDefaults, @_);
    
    my ($filename) = $args{"filename"};
    my $returnedName="";
    my $safeLimit;
    my $partLength;
    my $nameLength;
    my $localDebug = 0;
    
    $filename =~ tr/a-zA-Z0-9./_/cs; # ensure name is entirely alphanumeric
    # check if name would collide case insensitively
    if (exists $dispensedSafeNames{lc($filename)}) {
        while (exists $dispensedSafeNames{lc($filename)}) {
            # increment numeric part of name
            $filename =~ /(\D+)(\d*)((\.\w*)*)/o;
            my $rootTextPart = $1;
            my $rootNumPart = $2;
            my $extension = $4;
            if (defined $rootNumPart) {
                $rootNumPart++;
            } else {
                $rootNumPart = 2
            }
            if (!$extension){$extension = '';};
            $filename = $rootTextPart.$rootNumPart.$extension;
        }
    }
    $returnedName = $filename;       

    # check for length problems
    $safeLimit = ($args{"fileLengthLimit"} - $args{"longestExtension"});
    $partLength = int (($safeLimit/2)-1);
    $nameLength = length($filename);
    if ($nameLength > $safeLimit) {
        my $safeName =  $filename;
        $safeName =~ s/^(.{$partLength}).*(.{$partLength})$/$1_$2/;
        if (exists $dispensedSafeNames{lc($safeName)}) {
            my $i = 1;
	        while (exists $dispensedSafeNames{lc($safeName)}) {
	            $safeName =~ s/^(.{$partLength}).*(.{$partLength})$/$1$i$2/;
	            $i++;
	        }
	    }
        my $lcSafename = lc($safeName);
        print STDERR "\t $lcSafename\n" if ($localDebug);
        $returnedName = $safeName;       
    } else {
        $returnedName = $filename;       
    }
    $dispensedSafeNames{lc($returnedName)}++;
    return $returnedName;    
}

# /*!
#     @abstract
#         Converts a relative path to an absolute path.
#     @param relPath
#         A relative path.
#     @param args
#         The path of the file that the relative path is
#         relative to.
#     @discussion
#         This is basically the inverse of {@link findRelativePath}.
#  */
sub makeAbsolutePath {
   my $relPath = shift;
   my $relTo = shift;
   if ($relPath !~ /^\//o) { # doesn't start with a slash
       $relPath = $relTo."/".$relPath;
   }
   return $relPath;
}

# /*! @group Documentation Block Functions
#     @abstract
#         Functions for working with parts of documentation blocks.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Returns a reasonable, prioritized guess of the
#         encoding for a block of data.
#  */
sub guess_prioritized_encoding
{
	my $text = shift;
	my $filePath = shift; # For debugging
	my $encDebug = shift; # For debugging

	my $decoder = guess_encoding($text, qw/iso-8859-1 UTF-8/);

if ($text !~ /\S/) { return undef; };

print STDERR "FILEPATH $filePath DECODER: $decoder\n" if ($encDebug);
print "TEXT: $text\n" if ($encDebug);

	if ($decoder =~ /utf8/ && $decoder =~ /iso-8859-1/) {
		# Doesn't matter which we pick.  Guess UTF-8.
		print STDERR "Could be UTF-8 or ISO-8859-1.  Going with UTF-8.\n" if ($encDebug);
		$decoder = guess_encoding($text);
	}

	print STDERR "POINT 2\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/Windows-1252/);
	}

	print STDERR "POINT 3\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/euc-jp shiftjis 7bit-jis/);
	}
	print STDERR "POINT 4\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/euc-jp shiftjis 7bit-jis/);
	}
	print STDERR "POINT 5\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-2/);
	}
	print STDERR "POINT 6\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-3/);
	}
	print STDERR "POINT 7\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-4/);
	}
	print STDERR "POINT 8\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-5/);
	}
	print STDERR "POINT 9\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-6/);
	}
	print STDERR "POINT 10\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-7/);
	}
	print STDERR "POINT 11\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-8/);
	}
	print STDERR "POINT 12\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-9/);
	}
	print STDERR "POINT 13\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-10/);
	}
	print STDERR "POINT 14\n" if ($encDebug);
	if (!ref($decoder)) {
		$decoder = guess_encoding($text, qw/iso-8859-11/);
	}
	print STDERR "POINT 15\n" if ($encDebug);
	# if (!ref($decoder)) {
		# $decoder = guess_encoding($text, qw/iso-8859-12/);
	# }
	# print STDERR "POINT 16\n" if ($encDebug);
	# if (!ref($decoder)) {
		# $decoder = guess_encoding($text, qw/iso-8859-13/);
	# }
	# print STDERR "POINT 17\n" if ($encDebug);
	# if (!ref($decoder)) {
		# $decoder = guess_encoding($text, qw/iso-8859-14/);
	# }
	# print STDERR "POINT 18\n" if ($encDebug);
	# if (!ref($decoder)) {
		# $decoder = guess_encoding($text, qw/iso-8859-15/);
	# }
	print STDERR "POINT 19\n" if ($encDebug);

	# if (!ref($decoder)) {
		# $decoder = guess_encoding($text, qw/UTF-8 Windows-1252 euc-jp shiftjis 7bit-jis iso-8859-1 iso-8859-2 iso-8859-3 iso-8859-4 iso-8859-5 iso-8859-6 iso-8859-7 iso-8859-8 iso-8859-9 iso-8859-10 iso-8859-11 iso-8859-12 iso-8859-13 iso-8859-14 iso-8859-15/);
	# }
	ref($decoder) or die "Can't guess encoding: $decoder"; # trap error this way

	print STDERR "ENC is ".$decoder->name."\n" if ($encDebug);

	return $decoder;
}

# /*!
#     @abstract
#         Gets an API name and discussion from a top-level tag,
#         e.g. <code>\@function myFunctionName</code>.
#     @param line
#         The contents of the tag (with the actual tag stripped off
#         the front).
#     @param joinpattern
#         The contents of a regular expression.  If nonempty, this
#         expression determines a list of tokens which are considered
#         to automatically get merged with the name if they appear before
#         or after a space that would otherwise terminate the name.  This
#         allows a space prior to a leading parenthesis in a category name,
#         for example.  This join pattern is passed on to {@link smartsplit}.
#  */
sub getAPINameAndDisc {
    my $line = shift;
    my $lang = shift; # $HeaderDoc::lang;
    my $joinpattern = shift;

    my ($name, $disc, $operator);
    my $localDebug = 0;

    # If we start with a newline (e.g.
    #     @function
    #       discussion...
    # treat it like JavaDoc and let the block parser
    # pick up a name.
    print STDERR "LINE: $line\n" if ($localDebug);
    if ($line =~ /^\s*\n\s*/o) {
	print STDERR "returning discussion only.\n" if ($localDebug);
	$line =~ s/^\s+//o;
	return ("", "$line", 0);
    }
    my $nameline = 0;
    # otherwise, get rid of leading space
    $line =~ s/^\s+//o;

    # If we have something like
    #
    #    @define this that
    #     Description here
    #
    # we split on the newline, else split on the first
    # whitespace.
    if ($line =~ /\S+.*\n.*\S+/o) {
	$nameline = 0;
	($name, $disc) = split (/\n/, $line, 2);
    } else {
	$nameline = 1;
	($name, $disc) = smartsplit($line, $joinpattern, $lang);
    }

	# print STDERR "NAME: $name DISC: $disc\n";
    # ensure that if the discussion is empty, we return an empty
    # string....
    $disc =~ s/\s*$//o;
    
    if ($name =~ /operator/o) {  # this is for operator overloading in C++
        ($operator, $name, $disc) = split (/\s/, $line, 3);
        $name = $operator." ".$name;
    }
    print STDERR "name is $name, disc is $disc, nameline is $nameline" if ($localDebug);
    return ($name, $disc, $nameline);
}

# /*!
#     @abstract
#         Attempts to intelligently split the leading line
#         in a declaration.
#     @param line
#         The line to split.
#     @param pattern
#         A pattern containing tokens that should cause the
#         following token to be concatenated onto the first
#         one even if there are spaces between them.
#     @discussion
#         For example, if someone mistakenly
#         writes <code>\@function class :: function</code>,
#         this function attempts to do the right thing.
#  */
sub smartsplit
{
    my $line = shift;
    my $pattern = shift;
    my $lang = shift;

    my $localDebug = 0;

    print STDERR "LINE: $line\n" if ($localDebug);
    print STDERR "PATTERN: $pattern\n" if ($localDebug);

    # my $lang = $HeaderDoc::lang;

    # The easy case.
    if (!$pattern || $pattern eq "") {
	return split (/\s/, $line, 2);
    }

    # The hard case.
    my @parts = split(/(\s+|$pattern)/, $line);

    my $leading = 1;
    my $lastspace = "";
    my $name = "";
    my $desc = "";
    my @matchstack = ();
    foreach my $part (@parts) {
	if ($part eq "") { next; }
	print STDERR "PART: $part\n" if ($localDebug);
	if ($desc eq "") {
		print STDERR "Working on name.\n" if ($localDebug);
		if ($part =~ /\s/) {
			if ($leading) {
				print STDERR "Clear leading (space).\n" if ($localDebug);
				$name .= $part;
				$leading = 0;
			} else {
				print STDERR "Set lastspace.\n" if ($localDebug);
				$lastspace = $part;
			}
		} else {
			if ($leading) {
				print STDERR "Clear leading (text).\n" if ($localDebug);
				$leading = 0;
				$name .= $part;
			} else {
				if ($part =~ /($pattern)/) {
					print STDERR "Appending to name (pattern match).\n" if ($localDebug);
					$name .= $lastspace.$part;
					$lastspace = "";
					$leading = 1;

					my $isbrace = HeaderDoc::BlockParse::bracematching($part, $lang);
					# print STDERR "IB: \"$isbrace\"\n" if ($localDebug);
					if ($isbrace ne "") {
						print STDERR "Adding to match stack\n" if ($localDebug);
						push(@matchstack, $part);
					} elsif ($part eq HeaderDoc::BlockParse::peekmatch(\@matchstack, $lang)) {
						print STDERR "Popping from match stack\n" if ($localDebug);
						pop(@matchstack);
					}
				} elsif (scalar(@matchstack)) {
					print STDERR "Stack not empty.  Appending to name\n" if ($localDebug);
					$name .= $lastspace.$part;
					$lastspace = "";
					$leading = 1;
				} elsif ($lastspace eq "") {
					print STDERR "Appending to name.\n" if ($localDebug);
					$name .= $part;
				} else {
					print STDERR "Starting description.\n" if ($localDebug);
					$desc = $part;
				}
			}
		}
	} else {
		$desc .= $part;
	}
    }

    $name =~ s/^\s*//s;

    print STDERR "Returning NAME: $name DESC: $desc\n" if ($localDebug);

    return ($name, $desc);
}

# /*! @group Configuration Functions
#     @abstract
#         Functions for working with config files.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Reads HeaderDoc config files and uses the keys
#         to update a hash table.
#     @param configHashRef
#         The configuration hash to update.
#     @param fileArrayRef
#         An array of files in the order that they should
#         be read.  Later values overwrites earlier values.
#  */
sub updateHashFromConfigFiles {
    my $configHashRef = shift;
    my $fileArrayRef = shift;
    
    foreach my $file (@{$fileArrayRef}) {
    	my %hash = &getHashFromConfigFile($file);
    	%{$configHashRef} = (%{$configHashRef}, %hash); # updates configHash from hash
    }
    return %{$configHashRef};
}


# /*!
#     @abstract
#         Reads a single HeaderDoc config file and returns
#         a hash table of its values.
#     @param configHashRef
#         The configuration hash to update.
#     @param fileArrayRef
#         An array of files in the order that they should
#         be read.  Later values overwrites earlier values.
#  */
sub getHashFromConfigFile {
    my $configFile = shift;
    my %hash;
    my $localDebug = 0;
    my @lines;
    
    if ((-e $configFile) && (-f $configFile)) {
    	print STDERR "reading $configFile\n" if ($localDebug);
		open(INFILE, "<$configFile") || die "Can't open $configFile.\n";
		@lines = <INFILE>;
		close INFILE;
    } else {
        print STDERR "No configuration file found at $configFile\n" if ($localDebug);
        return;
    }
    
	foreach my $line (@lines) {
	    if ($line =~/^#/o) {next;};
	    chomp $line;
	    my ($key, $value) = split (/\s*=>\s*/, $line);
	    if ((defined($key)) && (length($key))){
			print STDERR "    $key => $value\n" if ($localDebug);
		    $hash{$key} = $value;
		}
	}
	undef @lines;
	return %hash;
}

# /*! @group File Functions
#     @abstract
#         Functions for working with files
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Reads a file and stores the lines in an array (with newlines).
#     @param filePath
#         The file to read.
#     @return
#         Returns the encoding and a reference to an array of lines.
#  */
sub linesFromFile {
	my $filePath = shift;
	my $useFilter = 0;
	if (@_) {
		$useFilter = shift;
	}
	my $oldRecSep;
	my $fileString;

	# print STDERR "FILTER: $useFilter\n";
	
	$oldRecSep = $/;
	undef $/;    # read in files as strings
	if (!open(INFILE, "<$filePath")) {
		$HeaderDoc::exitstatus = -1;
		warn "Can't open $filePath: $!\n";
		return ();
	}
	$fileString = <INFILE>;
	close INFILE;
	$/ = $oldRecSep;

	if ($HeaderDoc::enable_macro_filter && $useFilter) {
		$fileString = HeaderDoc::MacroFilter::filterFileString($fileString);
	}

	my $encDebug = 0;

	print STDERR "POINT 1\n" if ($encDebug);

	my $decoder = guess_prioritized_encoding($fileString, $filePath, $encDebug);
	my $encoding = "";
	if ($decoder) {
		$encoding = $decoder->name;
	} else {
		$encoding = "ascii";
	}

	# my $utf8 = $decoder->decode($fileString);
	# $fileString = $utf8;

	$fileString =~ s/\015\012/\n/go;
	$fileString =~ s/\r\n/\n/go;
	$fileString =~ s/\n\r/\n/go;
	$fileString =~ s/\r/\n/go;
	my @lineArray = split (/\n/, $fileString);
	
	# put the newline back on the end of each element of the array
	# we can't use split (/(\n)/, $fileString); because that adds the 
	# newlines as new elements in the array.

	my @retarr = map($_."\n", @lineArray);
	return ($encoding, \@retarr);
}

# /*! @group API Reference Functions
#     @abstract
#         Functions related to API references.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Returns the API reference that most closely matches the
#         context provided by <code>fromObj</code>.
#     @param fromObj
#         The object you're linking from (empty if not known).
#     @param arrayref
#         A reference to an array containing the candidate API references
#         to check.
#     @result
#         Returns the array <code>($value, $bogus)</code> containing the
#         best value and a flag to indicate whether the conflict is
#         solely caused by a function parameter or local variable
#         that is local to a different function.
#  */
sub chooseBestAPIRef
{
	my $fromObj = shift;
	my $arrayref = shift;
	my @arr = @{$arrayref};

	my $localDebug = 0;

	my $bogus = 0;

	if ($fromObj) {
		my $headerName = "";
		my $className = "";
		my $targetLang = $fromObj->lang();
		my $targetSubLang = $fromObj->sublang();
		my $apiOwner = $fromObj->apiOwner();
		my $name = $fromObj->apiuidname();

		if ($fromObj->isAPIOwner()) {
			my $class = ref($fromObj) || $fromObj;
			if ($class !~ /HeaderDoc::Header/) {
				$className = $fromObj->name();
			}
		} else {
			my $class = ref($apiOwner) || $apiOwner;
			if ($class !~ /HeaderDoc::Header/) {
				$className = $apiOwner->name();
			}
		}
		my $class = ref($apiOwner) || $apiOwner;
		my $headerObj = undef;
		if ($class =~ /HeaderDoc::Header/) {
			$headerObj = $apiOwner;
		} else {
			$headerObj = $apiOwner->headerObject();
		}

		$headerName = $headerObj->filename();

		$className =~ s/\s//sgo;
		$className =~ s/<.*?>//sgo;

		$headerName =~ s/\s//sgo;
		$headerName =~ s/<.*?>//sgo;

		my @newarr = ();
		# First, look for the one in the current function or declaration.
		foreach my $ref (@arr) {
			if ($ref =~ /^\/\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)(\/|$)/) {
				my $apple_ref_part = $1;
				my $language_part = $2;
				my $reftype_part = $3;
				my $class_part = $4;
				my $owning_symbol_part = $5;
				my $symbol_part = $6;

				print STDERR "POINT A: REF: $ref reftype_part: $reftype_part\n" if ($localDebug);

				if ($reftype_part =~ /(functionparam|methodparam|defineparam|enumconstant|functionvar|methodvar|definevar|structfield|typedeffield)/) {
					if (($class_part eq $className) && ($owning_symbol_part eq $name)) {
						print STDERR "CLASSMATCH OWNERMATCH (($class_part eq $className) && ($owning_symbol_part eq $name))\n" if ($localDebug);

						return ($ref, $bogus);
					}
				} else {
					push(@newarr, $ref);
				}
			} elsif ($ref =~ /^\/\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)(\/|$)/) {
				my $apple_ref_part = $1;
				my $language_part = $2;
				my $reftype_part = $3;
				my $owning_symbol_part = $4;
				my $symbol_part = $5;

				print STDERR "POINT B: REF: $ref reftype_part: $reftype_part\n" if ($localDebug);

				if ($reftype_part =~ /(functionparam|methodparam|defineparam|enumconstant|functionvar|methodvar|definevar|structfield|typedeffield)/) {
					if (($owning_symbol_part eq $name) && ($className eq "")) {
						print STDERR "OWNERMATCH ($owning_symbol_part eq $name)\n" if ($localDebug);
						return ($ref, $bogus);
					}
				} else {
					push(@newarr, $ref);
				}
			} else {
				push(@newarr, $ref);
			}
		}

		@arr = @newarr;

		if ($localDebug) {
			print STDERR "BOGOSITY CHECK: scalar(\@newarr) is ".scalar(@newarr)."\n";
			foreach my $item (@newarr) {
				print STDERR "BOGOSITY CHECK: $item\n";
			}
		}

		if (scalar(@newarr) == 1) { $bogus = 1; }

		# Next, look for the one in the current class.
		foreach my $ref (@arr) {
			print STDERR "PASS 1.  CHECKING REF: $ref\n" if ($localDebug);
			if ($ref =~ /^\/\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)(\/|$)/) {
				my $apple_ref_part = $1;
				my $language_part = $2;
				my $reftype_part = $3;
				my $class_part = $4;
				my $symbol_part = $5;

				print STDERR "LANGUAGE PART $language_part TARGET: $targetLang OR $targetSubLang\n" if ($localDebug);
				print STDERR "CLASS PART: $class_part TARGET: $className\n" if ($localDebug);

				if ($language_part eq $targetLang || $language_part eq $targetSubLang) {
					if ($class_part eq $className) { return ($ref, $bogus); }
				}
			}
		}

		# Next, look for a static variable/function in the current header.
		foreach my $ref (@arr) {
			print STDERR "PASS 2.  CHECKING REF: $ref\n" if ($localDebug);
			if ($ref =~ /^\/\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)\/([^\/]+)(\/|$)/) {
				my $apple_ref_part = $1;
				my $language_part = $2;
				my $reftype_part = $3;
				my $class_part = $4;
				my $symbol_part = $5;

				print STDERR "LANGUAGE PART $language_part TARGET: $targetLang OR $targetSubLang\n" if ($localDebug);
				print STDERR "HEADER PART: $class_part TARGET: $headerName\n" if ($localDebug);

				if ($language_part eq $targetLang || $language_part eq $targetSubLang) {
					if ($class_part eq $headerName) { return ($ref, $bogus); }
				}
			}
		}

		# Next, look for any variable/function in the current header.
		foreach my $ref (@arr) {
			print STDERR "PASS 3.  CHECKING REF: $ref\n" if ($localDebug);
			my $toObj = objectForUID($ref);
			if ($toObj && ($toObj ne "3")) {
				# If it is 3, that probably means it is in
                                # another header that this one doesn't
                                # depend on.

				# print STDERR "TOOBJ: $toObj FROMOBJ: $fromObj\n";

				bless($toObj, "HeaderDoc::HeaderElement");
				bless($toObj, $toObj->class());

				# print STDERR "POST TOOBJ: $toObj FROMOBJ: $fromObj\n";

				print STDERR "FOR UID $ref, got object.\n" if ($localDebug);
				print STDERR "FILENAME: ".$toObj->filename()." TARGET: ".$fromObj->filename()."\n" if ($localDebug);

				if ($toObj->filename() eq $fromObj->filename()) {

					return ($ref, $bogus);
				}
			} elsif (!$toObj) {
				warn("No object found for UID $ref\n");
			}
		}
	}

	return ($arr[0], $bogus);
}

# /*!
#     @abstract
#         Looks up a symbol name and returns a matching API reference
#         if available.
#     @discussion
#         This function supports the use of the <code>\@link</code> tag to
#         link to functions and types within a single file.  If you specify
#         something like <code>\@link foo .... \@/link</code>, This code gets
#         called.  If you specify an API ref instead of a bare symbol
#         name, you should not even get here.
#
#         Known issues:
#
#         Not all APIs are registered here.  It would be nice to be
#         able to link to classes.
#
#         This uses the first UID by default.  It should be using
#         the <b>nearest</b> UID instead (e.g. a method within
#         the current class).
#   */
sub resolveLink
{
    my $fromObj = shift;
    my $symbol = shift;
    my $linkedword = "linked";
    if (@_) {
	$linkedword = shift;
    }
    my $ret = "";
    my $fullpath = $HeaderDoc::headerObject->fullpath();

    $symbol =~ s/\s*\(\s*\)\s*$//;
    my $uid = $uid_list{$symbol};
	if ($uid && length($uid)) {
	    $ret = $uid;
	    if ($uid_conflict{$symbol}) {
		my @candidates = @{$uid_candidates{$symbol}};
		my $conflict_is_bogus;
		($uid, $conflict_is_bogus) = chooseBestAPIRef($fromObj, $uid_candidates{$symbol});
		$ret = $uid;
		# foreach my $x (@candidates) { print STDERR "CANDIDATE $x\n"; }

		if (!$conflict_is_bogus) {
			warn "$fullpath:0: warning: multiple matches found for symbol \"$symbol\"!!! Only the nearest matching symbol will be $linkedword. Replace the symbol with a specific api ref tag (e.g. apple_ref) in header file to fix this conflict.\n\nCandidates are:\n\t".join("\n\t", @candidates)."\n\nDefault is:\n\t$uid\n";
		}
	    }
	}
    if ($ret eq "") {
        # If symbol is in an external API, resolution will be done
        # by resolveLinks, later; don't issue any warning yet.        
        if ($symbol !~ /^\/\//){
		warn "$fullpath:0: warning: no symbol matching \"$symbol\" found.  If this symbol is not in this file or class, you need to specify it with an api ref tag (e.g. apple_ref).\n";
		$ret = $fromObj->genRef("", $symbol, $symbol, "", 1);
        } else {
		$ret = $symbol; # If $symbol is a uid, keep it as is
	}
    # } else {
	# warn "RET IS \"$ret\"\n"
    }
    return $ret;
}

# /*!
#     @abstract
#         Registers a name for lookup with {@link resolveLink} and
#         a UID for UID conflict detection and avoidance.
#     @param uid
#         The unique ID (API reference) to register).
#     @param name
#         The symbol name to register.
#     @param object
#         The object matching this registration (a subclass of
#         {@link //apple_ref/perl/cl/HeaderDoc::HeaderElement HeaderElement}).
#  */
sub registerUID($$$)
{
    # This is now classless.
    # my $self = shift;
    my $uid = shift;
    my $name = shift;
    my $object = shift;
    my $localDebug = 0;

    cluck("registerUID: $name\n") if ($localDebug);

    if ($HeaderDoc::ignore_apiuid_errors == 2) { return; }
    if ($object->noRegisterUID()) { return; }

    my $objtype = ref($object) || $object;

    # Silently ignore objects that are going away anyway.
    if ($objtype =~ /HeaderDoc::HeaderElement/) { return; }
    if ($objtype =~ /HeaderDoc::APIOwner/) { return; }
    if ($uid =~ /^\/\/[^\/]+\/[^\/]+\/internal_temporary_object$/ || $uid =~ /^\/\/[^\/]+\/[^\/]+\/internal_temporary_object\/.*$/) { return; }

	# print STDERR "UID WAS $uid\n";

    print STDERR "OBJECT: $object\n" if ($localDebug);
    print STDERR "New UID registered: $object -> $uid.\n" if ($localDebug);
    cluck("New UID registered: $object -> $uid.  Backtrace follows\n") if ($localDebug);

    if ($uid_list_by_uid{$uid} != undef) {
    	if ($uid_list_by_uid{$uid} != $object) {
	    if ($uid_list_by_uid{$uid} eq "3") {
		# Same UID, new object.  (I think this is probably
		# the right thing to do here.)
		$uid_list_by_uid{$uid} = $object;
	    } else {
		# If we match, keep quiet.  This is normal.
		# Otherwise, resolve the duplicate apple_ref
		# below.

		my $oldobj = $uid_list_by_uid{$uid};

		# print STDERR "OLDOBJ: $oldobj\n";

		bless($oldobj, "HeaderDoc::HeaderElement");
		bless($oldobj, $oldobj->{CLASS});
		my $line_1 = $oldobj->linenum();
		my $filename_1 = $oldobj->filename();
		my $line_2 = $object->linenum();
		my $filename_2 = $object->filename();

		# my $objid = "" . $object;
		# $objid =~ s/^.*\(//s;
		# $objid =~ s/\).*$//s;
		# my $objid = sanitize($object->apiOwner()->name(), 1)."_".$HeaderDoc::perHeaderObjectID++;
		my $objname = sanitize($uid, 1);
		my $objid = $objid_hash{$objname};
		if (!$objid) {
			$objid = 0;
		}
		$objid_hash{$objname} = $objid + 1;
		# print STDERR "NEXT for \"$objname\" WILL BE ".$objid_hash{$objname}."\n";
		my $newuid = $uid . "_DONTLINK_$objid";
		if ($uid_list_by_uid{$newuid} == undef) {
		    my $quiet = 0;
		    if ($HeaderDoc::running_test) { $quiet = 1; }
		    # Avoid warning about methods before the return type
		    # has been set.
		    if ($object->can("returntype")) {
			if ($object->returntype() == undef) {
			    if ($objtype =~ /HeaderDoc::Method/) { $quiet = 1; }
			    if ($objtype =~ /HeaderDoc::Function/) {
				my $apio = $object->apiOwner();
				my $apioname = ref($apio) || $apio;
				if ($apioname !~ /HeaderDoc::Header/) { $quiet = 1; }
			    }
			}
		    }
		    if (!$quiet) {
			if ($newuid=~/^\/\/[^\/]+\/doc\/title:(.*?)\//) {
				warn("$filename_2:$line_2: Warning: same name used for more than one comment (base apple_ref type was $1)\n");
				warn("    UID changed from $uid to $newuid\n");
				warn("    The conflicting declaration appeared at $filename_1:$line_1\n");
			} else {
				warn("Warning: UID $uid shared by multiple objects.  Disambiguating: new uid is $newuid\n");
			}
			if ($localDebug) { cluck("Backtrace follows\n"); }
		    }
		}
		$uid = $newuid;
		$uid_list_by_uid{$uid} = $object;
	    }
	}
    } else {
	$uid_list_by_uid{$uid} = $object;
    }


    print STDERR "registered UID $uid\n" if ($localDebug);
    # my $name = $uid;
    # $name =~ s/.*\///so;

    my $old_uid = $uid_list{$name};
    if ($old_uid && length($old_uid) && $old_uid ne $uid) {
	print STDERR "OU: $old_uid NU: $uid\n" if ($localDebug);
	$uid_conflict{$name} = 1;
	if (!$uid_candidates{$name}) {
		my @arr = ();
		push(@arr, $old_uid);
		$uid_candidates{$name} = \@arr;
	}
	my @arr = @{$uid_candidates{$name}};
	push(@arr, $uid);
	$uid_candidates{$name} = \@arr;
    }
    $uid_list{$name} = $uid;
    # push(@uid_list, $uid);

    return $uid;
}

# /*!
#     @abstract
#         Looks up a HeaderDoc object based on its UID (API
#         reference).
#     @param uid
#         The UID to look up.
#  */
sub objectForUID
{
    my $uid = shift;
    return $uid_list_by_uid{$uid};
}

# /*!
#     @abstract
#         Unregisters a UID-to-object mapping. 
#     @param uid
#         The UID to unregister.
#     @param object
#         The object to unregister.
#     @discussion
#         If the object is not registered with this UID,
#         this call fails silently.
#  */
sub dereferenceUIDObject
{
    my $uid = shift;
    my $object = shift;

    if ( $uid_list_by_uid{$uid} == $object) {
	$uid_list_by_uid{$uid} = undef;
	$uid_list_by_uid{$uid} = 3;
	return 1;
	# print STDERR "Releasing object reference\n";
    # } else {
	# warn("Call to dereferenceUIDObject for non-matching object\n");
    }
    return 0;
}

# /*!
#     @abstract
#         Unregisters a name-to-UID mapping.
#     @param uid
#         The UID to unregister.
#     @param name
#         The name to unregister.
#     @discussion
#         If the name is not registered with this UID,
#         this call fails silently.
#  */
sub unregisterUID
{
    my $uid = shift;
    my $name = shift;
    # my $object = undef;
    # if (@_) { $object = shift; }

    if ($HeaderDoc::ignore_apiuid_errors == 2) { return 0; }

    my $old_uid = $uid_list{$name};
    my $ret = 1;

    if ($uid_list{$name} eq $uid) {
	$uid_list{$name} = undef;
    } else {
	# warn("Attempt to unregister UID with wrong name: ".$uid_list{$name}." != $uid.\n");
	$ret = 0;
    }
    # if ($uid_list_by_uid{$uid} == $object) {
	# $uid_list_by_uid{$uid} = undef;
    # }

    return 0;
}

# /*!
#     @abstract
#         Destroys a UID-to-object mapping without checking
#         for an object match.
#     @param uid
#         The UID to forcibly unregister.
#  */
sub unregister_force_uid_clear
{
    my $uid = shift;
    $uid_list_by_uid{$uid} = undef;
}

############### Debugging Routines ########################

# /*! @group Debugging Functions
#     @abstract
#         Functions for debugging purposes.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Prints an ordered array.
#     @param theArray
#         The array to print.
#  */
sub printArray {
    my (@theArray) = @_;
    my ($i, $length);
    $i = 0;
    $length = @theArray;
    
    print STDERR "Printing contents of array:\n";
    while ($i < $length) {
	print STDERR  "Element $i ---> |$theArray[$i++]|\n";
    }
    print STDERR "\n\n";
}

# /*!
#     @abstract
#         Prints a hash table.
#     @param theHash
#         The hash to print.
#  */
sub printHash {
    my (%theHash) = @_;
    print STDERR "Printing contents of hash:\n";
    foreach my $keyword (keys(%theHash)) {
	print STDERR "$keyword => $theHash{$keyword}\n";
    }
    print STDERR "-----------------------------------\n\n";
}

# /*! @group Parser helpers
#     @abstract
#         Functions related to parsing code.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Returns a set of parse tokens for the specified
#         language and dialect.
#     @param lang
#         The current programming language.
#     @param sublang
#         The dialect of the programming language (e.g.
#         <code>cpp</code> for C++).
#
#     @vargroup Returned data structure fields
#     @var sotemplate
#         Start of template (usually <code>&lt;</code>).
#     @var eotemplate
#         End of template (usually <code>&gt;</code>).
#     @var soc
#         Start of multi-line comment.
#     @var eoc
#         End of multi-line comment.
#     @var ilc
#         Single-line comment.
#     @var ilc_b
#         Second single-line comment.  Used in PHP where
#         a single-line comment can start with either the
#         C++-style two slashes (//) or the shell-style
#         hash mark (#).
#     @var soconstructor
#         Start of a constructor.  In some languages like
#         TCL, there's a token for that.
#     @var sofunction
#         Token that marks the star of a function declaration.  For example,
#         in Perl, this is <code>sub</code>.
#     @var soprocedure
#         Token that marks the start of a procedure declaration in languages
#         that have separate functions and procedures.  For example, in Pascal, this
#         is <code>procedure</code>.
#     @var operator
#         The <code>operator</code> keyword in C++.
#     @var sopreproc
#         Start of a preprocessor macro (in languages
#         that support it).
#     @var lbrace
#         The primary left brace character.
#     @var lbraceunconditionalre
#         A regular expression containing other patterns that
#         are always considered left braces.  Currently used
#         for for/if in Python and Ruby, and tell in AppleScript.
#     @var lbraceconditionalre
#         In Ruby/Python, a set of tokens that are treated as
#         left braces unless they are immediately after a
#         right brace.  Basically, this handles
#         begin/while/until when used at the end of a line
#         in Ruby/Python.
#     @var rbrace
#         The primary right brace token.
#     @var enumname
#         The keyword <code>enum</code> or equivalent in languages that
#         support this and have such a token.
#     @var unionname
#         The keyword <code>union</code> or equivalent in languages that
#         support this and have such a token.
#     @var structname
#         The keyword <code>struct</code> or equivalent in languages that
#         support this and have such a token.
#     @var typedefname
#         The keyword <code>typedef</code> or equivalent in languages that
#         support this and have such a token.
#     @var varname
#         The keyword <code>var</code> or equivalent in languages that
#         require a keyword before a variable declaration.
#     @var constname
#         The keyword <code>const</code> or equivalent in languages that
#         have such a concept.
#     @var functionisbrace
#         Set to 1 if a function declaration is treated as an
#         open brace.
#     @var classisbrace
#         Set to 1 if a class declaration is treated as an
#         open brace.  (This is <b>not</b> used for ObjC clases;
#         they are special.)
#     @var functionisapiowner
#         Set to 1 if a function can usefully contain classes and other
#         API elements.
#     @var structisbrace
#         Set to 1 if a struct declaration is treated as an
#         open brace.
#     @var macronames
#         A reference to a hash table whose keys are the names
#         of C preprocessor parser tokens (including the
#         leading # character).
#     @var classregexp
#         A regular expression containing any tokens that
#         should be treated as the start of a class.
#     @var classbraceregexp
#         A regular expression containing any tokens from
#         <code>classregexp</code> that should also be
#         treated as a brace (e.g. <code>\@interface</code> in
#         Objective-C).
#     @var classclosebraceregexp
#         A regular expression containing any tokens that
#         both end a class declaration and should be
#         treated as a close brace (e.g. <code>\@end</code> in
#         Objective-C).
#     @var accessregexp
#         A regular expression containing access control
#         tokens (e.g. public, private, protected).
#     @var requiredregexp
#         A regular expression for the Objective-C
#         <code>\@required</code> and <code>\@optional</code>
#         keywords.  Empty for other languages.
#     @var propname
#         A string containing the Objective-C <code>\@required</code>
#         and <code>\@optional</code> keywords.  Empty
#         for other languages.
#     @var objcdynamicname
#         Unused for now.
#     @var objcsynthesizename
#         Unused for now.
#     @var moduleregexp
#         A regular expression containing tokens that should
#         be treated as the start of a module declaration.
#     @var assignmentwithcolon
#         Used for AppleScript.  Indicates that a colon is
#         an assignment statement in this language.
#     @var labelregexp
#         A regular expression for Applescript labels.
#     @var parmswithcurlybraces
#         Indicates that function parameters are wrapped by
#         curly braces in this language (TCL) instead of
#         parentheses.
#     @var superclasseswithcurlybraces
#         Indicates that superclass names are wrapped by
#         curly braces in this language (TCL).
#     @var definename
#         This is broken out so that we can abuse CPP in IDL
#         processing for cpp_quote without actually allowing
#         <code>#define</code> macros to be parsed from the code.  This is
#         only used for code parsing, NOT for interpreting
#         the actual <code>#define</code> macros themselves!
#     @var regexpfirstcharpattern
#         A regular expression that matches any symbol that is a
#         legal start token for a regular expression.  In Perl,
#         there are a lot of these.  In Ruby and JavaScript, only
#         slash (/) is allowed.  In Tcl, only a left curly brace
#         is allowed (because other regular expressions are just
#         strings).
#     @var regexpcharpattern
#         A regular expression containing a list of tokens that
#         are special in regular expressions.  In general, only
#         start tokens are listed, with the exception of the close
#         curly brace.  This should probably be the same for every
#         language that supports regular expressions.
#     @var regexppattern
#         A list of special Perl commands that are immediately
#         followed by a regular expression (e.g. tr).
#     @var singleregexppattern
#         A list of special Perl commands that are immediately
#         followed by a one-part regular expression (e.g. qq).
#         This is a strict subset of {@link regexppattern}.
#     @var regexpAllowedAfter
#         A list of symbols that a regular expression can
#         follow.  This prevents other uses of certain common
#         symbol (e.g. /) from incorrectly triggering the start
#         of regular expression parsing.
#     @var regexpAllowedAtStartOfLine
#         Set to 1 in languages where regular expressions are
#         first-class objects (Ruby) and thus can legally appear
#         as the first symbol on a line in addition to places that
#         can be detected based on the previous symbol.
#     @var TCLregexpcommand
#         Set to "regexp" in Tcl.  This is a regular expression
#         that matches a list of commands in scripting languages
#         that can take an unquoted (non-string) regular expression.
#     @var rbracetakesargument
#         Normally zero.  Set to 1 if a right brace marker
#         (e.g. <code>end</code>) is followed by another token
#         (e.g. <code>tell</code>) that tells what type of block
#         it closes.
#  */
sub parseTokens
{
    my $lang = shift;
    my $sublang = shift;

    my $localDebug = 0;

    my %parseTokens = ();
    $parseTokens{sotemplate} = "";
    $parseTokens{eotemplate} = "";
    $parseTokens{soc} = "";
    $parseTokens{eoc} = "";
    $parseTokens{ilc} = "";
    $parseTokens{ilc_b} = "";
    $parseTokens{soconstructor} = "";
    $parseTokens{sofunction} = "";
    $parseTokens{soprocedure} = "";
    $parseTokens{operator} = "";
    $parseTokens{sopreproc} = "";
    $parseTokens{lbrace} = "";
    $parseTokens{lbraceunconditionalre} = "";
    $parseTokens{lbraceconditionalre} = "";
    $parseTokens{rbrace} = "";
    $parseTokens{enumname} = "enum";
    $parseTokens{unionname} = "union";
    $parseTokens{structname} = "struct";
    $parseTokens{typedefname} = "typedef";
    $parseTokens{varname} = "";
    $parseTokens{constname} = "";
    $parseTokens{functionisbrace} = 0;
    $parseTokens{classisbrace} = 0;
    $parseTokens{structisbrace} = 0;
    my %macronames = ();
    $parseTokens{classregexp} = "";
    $parseTokens{classbraceregexp} = "";
    $parseTokens{classclosebraceregexp} = "";
    $parseTokens{accessregexp} = "";
    $parseTokens{requiredregexp} = "";
    $parseTokens{propname} = "";
    $parseTokens{objcdynamicname} = "";
    $parseTokens{objcsynthesizename} = "";
    $parseTokens{moduleregexp} = "";
    $parseTokens{assignmentwithcolon} = 0;
    $parseTokens{labelregexp} = "";
    $parseTokens{parmswithcurlybraces} = 0;
    $parseTokens{superclasseswithcurlybraces} = 0;
    $parseTokens{definename} = "";	# Breaking this out so that we can abuse CPP
				# in IDL processing for cpp_quote without
				# actually allowing #define macros to be
				# parsed from the code.  This is only used for
				# code parsing, NOT for interpreting the
				# actual #define macros themselves!

    my $langDebug = 0;

    print STDERR "PARSETOKENS FOR lang: $lang sublang: $sublang\n" if ($localDebug);

    # IMPORTANT NOTE: ilc_b should NEVER be set in the absence of ilc.  Code in
    # prefilterCommentCheck (headerDoc2HTML.pl) depends on this.

    if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
	print STDERR "Language is Perl or Shell script.\n" if ($langDebug);
	if ($lang eq "perl") {
		$parseTokens{sotemplate} = "<";
		$parseTokens{eotemplate} = ">";
	}else {
		$parseTokens{sotemplate} = "";
		$parseTokens{eotemplate} = "";
	}
	$parseTokens{sopreproc} = "";
	$parseTokens{soc} = "";
	$parseTokens{eoc} = "";
	$parseTokens{ilc} = "#";
	if ($lang eq "perl") { $parseTokens{sofunction} = "sub"; }
	elsif ($lang eq "tcl") {
		$parseTokens{soconstructor} = "constructor";
		$parseTokens{sofunction} = "method";
		$parseTokens{soprocedure} = "proc";
	}
	else { $parseTokens{sofunction} = "function"; }
	$parseTokens{lbrace} = "{";
	$parseTokens{rbrace} = "}";
	$parseTokens{enumname} = "";
	$parseTokens{unionname} = "";
	$parseTokens{structname} = "";
	$parseTokens{typedefname} = "";
	$parseTokens{varname} = "";
	if ($lang eq "perl") {
		$parseTokens{classregexp} = "^(package)\$";

		# Do not do this:
		# $parseTokens{classbraceregexp} = "^(package)\$";
	}
	if ($lang eq "tcl") {
		# Function parameters and superclasses are wrapped by
		# curly braces in TCL.
		$parseTokens{parmswithcurlybraces} = 1;
		$parseTokens{superclasseswithcurlybraces} = 1;
		$parseTokens{classregexp} = "^(class)\$";
		$parseTokens{varname} = "attribute";
	}
	if ($lang eq "shell" && $sublang eq "csh") {
		# A variable that starts with "set" will "just work",
		# but a variable that starts with "setenv" has no
		# equals sign, so it needs help.
		$parseTokens{varname} = "setenv";
	}
	$parseTokens{constname} = "";
	$parseTokens{structisbrace} = 0;

	if ($lang eq "perl") {
		$parseTokens{regexpAllowedAfter} = '(\~|\(|\=|\,)';

		$parseTokens{regexpcharpattern} = "[[|{}#(/'\"<`]";
		# "}" vi bug workaround for previous line

		# If it appears not after a ~, tr, etc., only allow slash.
		$parseTokens{regexpfirstcharpattern} = "[/]";
		# "}" vi bug workaround for previous line

		$parseTokens{regexppattern} = "qq|qr|qx|qw|q|m|s|tr|y";
		$parseTokens{singleregexppattern} = "qq|qr|qx|qw|q|m";

	} elsif ($lang eq "tcl") {
		# Syntax: regexp [-foo [-bar ..]] {expression goes here} ...
		$parseTokens{TCLregexpcommand} = "regexp";

		$parseTokens{regexpfirstcharpattern} = "[{]";
		# "}" vi bug workaround for previous line

		$parseTokens{regexpcharpattern} = "[[|{}#(/'\"<`]";
		# "}" vi bug workaround for previous line
	}
    } elsif ($lang eq "pascal") {
	print STDERR "Language is Pascal.\n" if ($langDebug);
	$parseTokens{sotemplate} = "";
	$parseTokens{eotemplate} = "";
	$parseTokens{sopreproc} = "#"; # Some pascal implementations allow #include
	$parseTokens{soc} = "{";
	$parseTokens{eoc} = "}";
	$parseTokens{ilc} = "";
	$parseTokens{sofunction} = "function";
	$parseTokens{soprocedure} = "procedure";
	$parseTokens{lbrace} = "begin";
	$parseTokens{rbrace} = "end";
	$parseTokens{enumname} = "";
	$parseTokens{unionname} = "";
	$parseTokens{structname} = "record";
	$parseTokens{typedefname} = "type";
	$parseTokens{varname} = "var";
	$parseTokens{constname} = "const";
	$parseTokens{structisbrace} = 1;
    } elsif ($lang eq "python") {
	$parseTokens{classregexp} = "^(class|module)\$";
	$parseTokens{moduleregexp} = "^(module)\$";
	$parseTokens{ilc} = "#";
	$parseTokens{soc} = "\"\"\"";
	$parseTokens{eoc} = "\"\"\"";

	$parseTokens{lbrace} = "";

	# These are always treated as a left brace.
	$parseTokens{lbraceunconditionalre} = "^(for|if)";

	# If these occur anywhere but immediately after an rbrace on the same line, treat them as an lbrace.
	$parseTokens{lbraceconditionalre} = "^(begin|while|until)";

	$parseTokens{rbrace} = "end";

	$parseTokens{sofunction} = "def";
	$parseTokens{structisbrace} = 0;
	$parseTokens{functionisbrace} = 1;
	$parseTokens{classisbrace} = 1;
    } elsif ($lang eq "ruby") {
	$parseTokens{classregexp} = "^(class|module)\$";
	$parseTokens{moduleregexp} = "^(module)\$";
	$parseTokens{ilc} = "#";
	$parseTokens{soc} = "=begin";
	$parseTokens{eoc} = "=end";

	$parseTokens{lbrace} = "";

	# These are always treated as a left brace.
	$parseTokens{lbraceunconditionalre} = "^(for|if)";

	# If these occur anywhere but immediately after an rbrace on the same line, treat them as an lbrace.
	$parseTokens{lbraceconditionalre} = "^(begin|while|until)";

	$parseTokens{rbrace} = "end";

	# if ($lang eq "C" || $lang eq "java") {
		# $parseTokens{enumname} = "enum";
	# }
	# if ($lang eq "C") {
		# $parseTokens{unionname} = "union";
		# $parseTokens{structname} = "struct";
	# }
	$parseTokens{sofunction} = "def";
	$parseTokens{structisbrace} = 0;
	$parseTokens{functionisbrace} = 1;
	$parseTokens{classisbrace} = 1;

	$parseTokens{regexpAllowedAfter} = '(\~|\(|\=|\,|if|elsif|while|unless|until|when)';
	$parseTokens{regexpAllowedAtStartOfLine} = 1;

	$parseTokens{regexpfirstcharpattern} = "[/]";
	# "}" vi bug workaround for previous line
	$parseTokens{regexpcharpattern} = "[[|{}#(/'\"<`]";
	# "}" vi bug workaround for previous line

    } elsif ($lang eq "applescript") {
	# Applescript
	$parseTokens{classregexp} = "^(script)\$";
	# $parseTokens{moduleregexp} = "^(namespace)\$";
	# if ($lang eq "C") {
		# $parseTokens{typedefname} = "typedef";
	# }
	# $parseTokens{operator} = "operator";
	# $parseTokens{sopreproc} = "#";
	$parseTokens{soc} = "(*";
	$parseTokens{eoc} = "*)";
	$parseTokens{ilc} = "--";
	$parseTokens{ilc_b} = "#";
	# $parseTokens{lbrace} = "{";

	# These always start a block ending in "end"
	# $parseTokens{lbraceunconditionalre} = "^(repeat|try)\$";

	# These might, if they aren't followed by the corresponding simple token.
	$parseTokens{lbraceprecursor} = "^(if|tell)\$";
	$parseTokens{lbraceprecursorre} = "^(then|to)\$";
	# If this is followed by an "if", ignore the "if".
	$parseTokens{lbracepreventerre} = "^(else)\$";
	# These do if they're after a newline.
	$parseTokens{lbraceconditionalre} = "^(considering|ignoring|repeat|tell|try|using|with)\$";

	# $parseTokens{rbrace} = "end";
	$parseTokens{rbraceconditionalre} = "^(end)\$";
	$parseTokens{rbracetakesargument} = 1;
	$parseTokens{varname} = "property";
	# $parseTokens{constname} = "const";
	$parseTokens{structisbrace} = 0;
	$parseTokens{functionisapiowner} = 1;
	$parseTokens{functionisbrace} = 1;
	$parseTokens{classisbrace} = 1;
	$parseTokens{assignmentwithcolon} = 1;
	$parseTokens{labelregexp} = "^(about|above|against|apart from|around|aside from|at|below|beneath|beside|between|by|for|from|instead of|into|on|onto|out of|over|since|thru|through|under)\$";


	$parseTokens{sofunction} = "on";
	$parseTokens{soprocedure} = "to";
    } else {
	# C and derivatives, plus PHP and Java(script)
	$parseTokens{classregexp} = "^(class|namespace)\$";
	$parseTokens{moduleregexp} = "^(namespace)\$";
	if ($lang eq "C" || $lang eq "Csource") {
		$parseTokens{typedefname} = "typedef";
	}
	if (($lang eq "C" && $sublang ne "php" && $sublang ne "IDL" && $sublang ne "MIG") || $lang =~ /Csource/) {
		print STDERR "Language is C or variant.\n" if ($langDebug);
		# if ($sublang eq "cpp" || $sublang eq "C" || $sublang eq "Csource") {
			$parseTokens{sotemplate} = "<";
			$parseTokens{eotemplate} = ">";
			$parseTokens{accessregexp} = "^(public|private|protected)\$";
		# }
		$parseTokens{operator} = "operator";
		$parseTokens{sopreproc} = "#";
		if ($sublang eq "occ") {
			# @@@ Note: if C++ ever adopts package, add a question mark to this regexp.
			$parseTokens{accessregexp} = "^(\@?public|\@?private|\@?protected|\@package)\$";
			$parseTokens{requiredregexp} = "^(\@optional|\@required)\$";
			$parseTokens{propname} = "\@property";
		}
	} elsif ($sublang eq "IDL") {
		print STDERR "Language is IDL.\n" if ($langDebug);
		$parseTokens{sopreproc} = "#";
	} elsif ($sublang eq "MIG") {
		print STDERR "Language is MIG.\n" if ($langDebug);
		$parseTokens{sopreproc} = "#";
		$parseTokens{typedefname} = "type";
	} else {
		print STDERR "Language is Unknown.\n" if ($langDebug);
	}
	# warn("SL: $sublang\n");
	if (($lang eq "C" || $lang eq "Csource") && $sublang ne "php" && $sublang ne "IDL") { # if ($sublang eq "occ" || $sublang eq "C")
		$parseTokens{classregexp} = "^(class|\@class|\@interface|\@protocol|\@implementation|namespace)\$";
		$parseTokens{classbraceregexp} = "^(\@interface|\@protocol|\@implementation)\$";
		$parseTokens{classclosebraceregexp} = "^(\@end)\$";
	}
	if ($lang eq "C" && $sublang eq "IDL") {
		$parseTokens{classregexp} = "^(module|interface)\$";
		$parseTokens{classbraceregexp} = "";
		$parseTokens{classclosebraceregexp} = "";
		$parseTokens{sotemplate} = "["; # Okay, so not strictly speaking a template, but we don't
		$parseTokens{eotemplate} = "]"; # care about what is in brackets.
		$parseTokens{moduleregexp} = "^(module)\$";
	}
	if ($lang eq "java" && $sublang eq "java") {
		$parseTokens{classregexp} = "^(class|interface|namespace)\$";
		$parseTokens{accessregexp} = "^(public|private|protected|package)\$";
	} elsif ($sublang eq "php") {
		$parseTokens{accessregexp} = "^(public|private|protected)\$";
		$parseTokens{ilc_b} = "#";
	}
	if ($lang eq "java" && $sublang eq "javascript") {
		$parseTokens{regexpAllowedAfter} = '(\(|\=|\,)';

		$parseTokens{regexpcharpattern} = "[[|{}#(/'\"<`]";
		# "}" vi bug workaround for previous line
		$parseTokens{regexpfirstcharpattern} = '[/]';
		# "}" vi bug workaround for previous line

	}

	$parseTokens{soc} = "/*";
	$parseTokens{eoc} = "*/";
	$parseTokens{ilc} = "//";
	$parseTokens{lbrace} = "{";
	$parseTokens{rbrace} = "}";
	if ($lang eq "C" || $lang eq "Csource" || $lang eq "java") {
		$parseTokens{enumname} = "enum";
	}
	if ($lang eq "C" || $lang eq "Csource") {
		$parseTokens{unionname} = "union";
		$parseTokens{structname} = "struct";
	}
	$parseTokens{varname} = "";
	$parseTokens{constname} = "const";
	$parseTokens{structisbrace} = 0;
	# DO NOT DO THIS, no matter how tempting it may seem.
	# sofunction and soprocedure are only for functions/procedures
	# that do not follow the form '<type information> <name> ( <args> );'.
	# MIG does, so don't do this.
	# if ($sublang eq "MIG") {
		# $parseTokens{sofunction} = "routine";
		# $parseTokens{soprocedure} = "simpleroutine";
	# };
	if ($sublang ne "php" && $sublang ne "IDL") {
		# @macronames = ( "#if", "#ifdef", "#ifndef", "#endif", "#else", "#elif", "#error", "#warning", "#pragma", "#import", "#include", "#define" );
		%macronames = ( "#if" => 1, "#ifdef" => 1, "#ifndef" => 1, "#endif" => 1, "#else" => 1, "#undef" => 1, "#elif" =>1, "#error" => 1, "#warning" => 1, "#pragma" => 1, "#import" => 1, "#include" => 1, "#define"  => 1);
		$parseTokens{definename} = "#define";
	} elsif ($sublang eq "IDL") {
		%macronames = ( "#if" => 1, "#ifdef" => 1, "#ifndef" => 1, "#endif" => 1, "#else" => 1, "#undef" => 1, "#elif" =>1, "#error" => 1, "#warning" => 1, "#pragma" => 1, "#import" => 1, "#include" => 1, "#define"  => 1, "import" => 1 );
		$parseTokens{definename} = "#define";
	}
    }

    # $HeaderDoc::soc = $parseTokens{soc};
    # $HeaderDoc::ilc = $parseTokens{ilc};
    # $HeaderDoc::eoc = $parseTokens{eoc};
    # $HeaderDoc::socquot = $parseTokens{soc};
    # $HeaderDoc::socquot =~ s/(\W)/\\$1/sg;
    # $HeaderDoc::eocquot = $parseTokens{eoc};
    # $HeaderDoc::eocquot =~ s/(\W)/\\$1/sg;
    # $HeaderDoc::ilcquot = $parseTokens{ilc};
    # $HeaderDoc::ilcquot =~ s/(\W)/\\$1/sg;
    # $HeaderDoc::ilcbquot = $parseTokens{ilc_b};
    # $HeaderDoc::ilcbquot =~ s/(\W)/\\$1/sg;

    $parseTokens{macronames} = \%macronames;

    return \%parseTokens;

    # return ($parseTokens{sotemplate}, $parseTokens{eotemplate}, $parseTokens{operator}, $parseTokens{soc}, $parseTokens{eoc}, $parseTokens{ilc}, $parseTokens{ilc_b}, $parseTokens{sofunction},
	# $parseTokens{soprocedure}, $parseTokens{sopreproc}, $parseTokens{lbrace}, $parseTokens{rbrace}, $parseTokens{unionname}, $parseTokens{structname},
	# $parseTokens{enumname},
	# $parseTokens{typedefname}, $parseTokens{varname}, $parseTokens{constname}, $parseTokens{structisbrace}, \%macronames,
	# $parseTokens{classregexp}, $parseTokens{classbraceregexp}, $parseTokens{classclosebraceregexp}, $parseTokens{accessregexp},
	# $parseTokens{requiredregexp}, $parseTokens{propname}, $parseTokens{objcdynamicname}, $parseTokens{objcsynthesizename}, $parseTokens{moduleregexp}, $parseTokens{definename},
	# $parseTokens{functionisbrace}, $parseTokens{classisbrace}, $parseTokens{lbraceconditionalre}, $parseTokens{lbraceunconditionalre}, $parseTokens{assignmentwithcolon},
	# $parseTokens{labelregexp}, $parseTokens{parmswithcurlybraces}, $parseTokens{superclasseswithcurlybraces},
	# $parseTokens{soconstructor});
}

# /*!
#     @abstract
#         Returns whether a token is a keyword.
#     @param keywordref
#         A reference to the keyword hash returned by {@link keywords}.
#     @param case_sensitive
#         A boolean value (0/1) indicating whether the current language
#         uses case-sensitive token matching.  Use the value returned
#         by {@link keywords}.
#  */
sub isKeyword
{
    my $token = shift;
    my $keywordref = shift;
    my $case_sensitive = shift;
    my %keywords = %{$keywordref};
    my $localDebug = 0;

    # if ($token =~ /^\#/o) { $localDebug = 1; }

    print STDERR "isKeyWord: TOKEN: \"$token\"\n" if ($localDebug);
    print STDERR "#keywords: ".scalar(keys %keywords)."\n" if ($localDebug);
    if ($localDebug) {
	foreach my $keyword (keys %keywords) {
		print STDERR "isKeyWord: keyword_list: $keyword\n" if ($localDebug);
	}
    }

    if ($case_sensitive) {
	if ($keywords{$token}) {
	    print STDERR "MATCH\n" if ($localDebug);
	    return $keywords{$token};
	}
    } else {
      foreach my $keyword (keys %keywords) {
	print STDERR "isKeyWord: keyword: $keyword\n" if ($localDebug);
	if ($token =~ /^\Q$keyword\E$/i) {
		print STDERR "MATCH\n" if ($localDebug);
		return $keywords{$keyword};
	}
      }
    }
    return 0;
}


# use FileHandle;
# use IPC::Open2;
# use Fcntl;

# /*! @group XML Helpers
#     @abstract
#         Functions used in XML output.
#     @discussion
#         
#  */

# /*! 
#     @abstract
#         Converts a string of HTML to XHTML using xmllint (slow).
#     @param html
#         The string of HTML to convert.
#     @param debugname
#         An arbitrary name for this block of HTML (e.g.
#         <code>function MyFunc abstract</code>) to distinguish it from other
#         blocks in the output spew when debugging is enabled.
#  */
sub html2xhtml
{
    my $html = shift;
    my $encoding = shift;
    my $debugname = shift;
    my $localDebug = 0;

    # print STDERR "FAST PATH: ".$HeaderDoc::ignore_apiuid_errors."\n";

    local $/;
    my $xmlout = "--xmlout";
    if ($xmllintversion eq "20607") {
	$xmlout = "";
    }

# print STDERR "xmllint version is $xmllintversion\n";
# print STDERR "xmllint is $xmllint\n";

    if (! -x $xmllint) {
	print STDERR "Error: xmllint is not installed.  Please install it and try again.\n";
	return $html;
    }

    warn "PREOPEN\n" if ($localDebug);
    my $pid = open2( \*fromLint, \*toLint, "$xmllint --html $xmlout --recover --nowarning - 2> /dev/null");
    warn "ONE\n" if ($localDebug);

    toLint->autoflush();
    my $str = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=$encoding'></head><body>$html</body></html>\n";
    print toLint $str;
    toLint->flush();

    # print STDERR "TOLINT: $str\n";

    warn "TWO\n" if ($localDebug);

    close toLint;

    my $xhtml = <fromLint>;
    warn "TWO-A\n" if ($localDebug);

    close fromLint;
    warn "THREE\n" if ($localDebug);

    my $old_xhtml = $xhtml;

    warn "FOUR\n" if ($localDebug);
    $xhtml =~ s/^\s*<!DOCTYPE .*?>//so;
    $xhtml =~ s/^\s*<\?xml.*?\?>\s*//so;
    $xhtml =~ s/^\s*<!.*?>\s*//so;
    $xhtml =~ s/^\s*<html>//so;
    $xhtml =~ s/<\/html>\s*$//so;
    $xhtml =~ s/^\s*<head>.*<\/head>\s*//s;
    if ($xhtml =~ /^\s*<body\/>\s*/o) {
	$xhtml = "";
    } else {
	$xhtml =~ s/^\s*<body>//so;
	$xhtml =~ s/<\/body>\s*$//so;
    }

    # Why, oh why does xmllint refuse to turn off translation for this
    # particular entity?  According to the man page, I should have to
    # specify --noent to get the behavior I'm getting....
    #
    # Never mind.  This is a good thing.  &nbsp; isn't a base XML entity.

    # my $nbsprep = chr(0xc2).chr(0xa0);

    # my $nbspalt = "&#160;";
    # my $perlnbspstring = decode("iso-8859-1", $nbspalt);

    # $nbspalt = encode($encoding, $perlnbspstring);

    # $xhtml =~ s/\Q$nbsprep\E/&nbsp;/sg;
    # $xhtml =~ s/&nbsp;/$nbspalt/sg;

    # Do we want to translate &quot; back to a double-quote mark?  I don't
    # know why xmllint wants to turn this into an entity....
    # $xhtml =~ s/&quot;/"/sgo;


    # And why doesn't xmllint work correctly with self-closing HTML
    # tags?
    my @selfClosingTags = ( "br", "hr", "link", "area", "base",
	"basefont", "input", "img", "meta");

    for my $tag (@selfClosingTags) {
	$xhtml =~ s/<\Q$tag\E>/<$tag \/>/sg;
	$xhtml =~ s/<\/\Q$tag\E>//sg;
	$xhtml =~ s/<\Q$tag\E\s[^>]*>/<$tag \/>/sg;
	$xhtml =~ s/<\/\Q$tag\E\s[^>]*>//sg;
    }

    # Attempt to get the length of the text itself (approximately)
    my $htmllengthcheck = $html;
    my $xhtmllengthcheck = $xhtml;
    $htmllengthcheck =~ s/\s//sgo;
    $xhtmllengthcheck =~ s/\s//sgo;
    $htmllengthcheck =~ s/<.*?>//sgo;
    $xhtmllengthcheck =~ s/<.*?>//sgo;
    $htmllengthcheck =~ s/\&.*?;//sgo;
    $xhtmllengthcheck =~ s/\&.*?;//sgo;

    my $pos = 32;
    while ($pos < 38) {
	$htmllengthcheck = unescape_legal($htmllengthcheck, $pos);
	$pos++;
    }
    # 39 is &
    $pos = 50;
    while ($pos < 60) {
	$htmllengthcheck = unescape_legal($htmllengthcheck, $pos);
	$pos++;
    }
    # 60 is <
    $htmllengthcheck = unescape_legal($htmllengthcheck, 61); # =
    # 62 is >
    while ($pos < 127) {
	$htmllengthcheck = unescape_legal($htmllengthcheck, $pos);
	$pos++;
    }
    # 127 is DEL

    $htmllengthcheck =~ s/\&#39;/'/sg;
    $xhtmllengthcheck =~ s/\&#39;/'/sg;
    $htmllengthcheck =~ s/\&#39;/'/sg;
    $xhtmllengthcheck =~ s/\&#39;/'/sg;

    $htmllengthcheck =~ s/&.*?;//sg;
    $xhtmllengthcheck =~ s/&.*?;//sg;
    $htmllengthcheck =~  s/[<>]//sg;   # These commonly cause bogus warnings.
    $xhtmllengthcheck =~ s/[<>]//sg;   # These commonly cause bogus warnings.
    $htmllengthcheck =~  s/[^!-~]//sg; # Eliminate nbsp bits, etc.
    $xhtmllengthcheck =~ s/[^!-~]//sg; # Eliminate nbsp bits, etc.

    $htmllengthcheck =~ s/&//sg;       # For bad HTML.

    if (length($xhtmllengthcheck) < length($htmllengthcheck)) {
	warn "DEBUGNAME: $debugname\n" if ($localDebug);
	warn "$debugname: XML to HTML translation failed.\n";
	warn "XHTML was truncated (".length($xhtmllengthcheck)." < ".length($htmllengthcheck).").\n";
	warn "BEGIN HTML:\n$html\nEND HTML\nBEGIN XHTML:\n$xhtml\nEND XHTML\n";
	# warn "BEGIN OLD XHTML:\n$old_xhtml\nEND OLD XHTML\n";
	print STDERR "A: \"$htmllengthcheck\"\nB: \"$xhtmllengthcheck\"\n";
    }

    print STDERR "FROM HTML: $html\n" if ($localDebug);
    print STDERR "GOT RAW XHTML: $old_xhtml\n" if ($localDebug);
    print STDERR "RETURNING XHTML (oldlen = ".length($html)."): $xhtml\n" if ($localDebug);

    my $retval = waitpid($pid, 0);
    my $exitstatus = $?;

    if ($exitstatus) {
	warn "DEBUGNAME: $debugname\n" if ($localDebug);
	warn "$debugname:XML to HTML translation failed.\n";
	warn "Error was $exitstatus\n";
    }


    return $xhtml;
}

# /*!
#     @abstract
#         Unescapes a legal character to avoid bogus length check warnings.
#  */
sub unescape_legal
{
    my $string = shift;
    my $value = shift;

    my $hexvalue = sprintf("%x", $value);

    my $character = chr($value);

    $string =~ s/&#$value;/$character/g;
    $string =~ s/&#x$hexvalue;/$character/g;

    return $string;
}


# /*! @group API Reference Functions */

# /*!
#     @abstract
#         Runs resolveLinks on a directory of files.
#     @param path
#         The path of a directory containing files to link together.
#     @param xreflist
#         A (regrettably space-delimited) list of external
#         cross-reference files.  (Optional.)
#     @param xreflist
#         A space-delimited list of API reference prefixes
#         (in addition to the default <code>apple_ref</code>).
#  */
sub resolveLinks($$$)
{
    my $path = shift;

    if (@_) {
        my $externalXRefFiles = shift;
	if (length($externalXRefFiles)) {
		my @files = split(/\s/s, $externalXRefFiles);
		foreach my $file (@files) {
			$path .= " -s \"$file\"";
		}
	}
    }
    if (@_) {
        my $externalAPIRefs = shift;
	if (length($externalAPIRefs)) {
		my @refs = split(/\s/s, $externalAPIRefs);
		foreach my $ref (@refs) {
			$path .= " -r \"$ref\"";
		}
	}
    }
    
    my $resolverpath = "/usr/bin/resolveLinks";
    if ( ! -x $resolverpath) {
	$resolverpath = "/usr/local/bin/resolveLinks";
    }
    if ( ! -x $resolverpath) {
	$resolverpath = "/opt/local/bin/resolveLinks";
    }
    if ( ! -x $resolverpath) {
	$resolverpath = "/sw/bin/resolveLinks";
    }
    if ( ! -x $resolverpath) {
		$resolverpath = $HeaderDoc::modulesPath."../../../../bin/resolveLinks";
		# print "RP: $resolverpath\n";
    }
    if ( ! -x $resolverpath) {
		$resolverpath = $HeaderDoc::modulesPath."bin/resolveLinks";
		warn("You are probably using an old resolveLinks.\n");
    }

    $path =~ s/"/\\"/sg;
    print STDERR "EXECUTING $resolverpath \"$path\"\n";
    my $retval = system($resolverpath." \"$path\"");

    if ($retval == -1) {
	warn "error: resolveLinks not installed.  Please check your installation.\n";
    } elsif ($retval) {
	warn "error: resolveLinks failed ($retval).  Please check your installation.\n";
    }
}


# /*! @group Documentation Block Functions */

# /*! @abstract
#         Checks a HeaderDoc tag for validity in a given context.
#     @param field
#         The tag name.
#     @param level
#         Default 0.
#
#         <ul>
#             <li>0 &mdash; Include both top-level (e.g. <code>\@function</code>)
#                 and second-level (e.g. <code>\@abstract</code>) HeaderDoc tags.
#             <li>1 &mdash; Include only top-level (e.g. <code>\@function</code>)
#                 HeaderDoc tags.
#             <li>2 &mdash; Include only second-level (e.g. <code>\@abstract</code>)
#                 HeaderDoc tags.
#         </ul>
#     @result
#         Returns 1 if a tag is valid, -1 if a tag should be
#         replaced with another string, or 0 if a tag is not valid.
#  */
sub validTag
{
    my $field = shift;
    my $include_first_tier = 1;
    my $include_second_tier = 1;
    if (@_) {
	my $level = shift;
	if ($level == 0) {
		$include_first_tier = 1;
		$include_second_tier = 1;
	} elsif ($level == 1) {
		$include_first_tier = 1;
		$include_second_tier = 0;
	} elsif ($level == 2) {
		$include_first_tier = 0;
		$include_second_tier = 1;
	}
	# print STDERR "DEBUG: field $field level: $level first: $include_first_tier second: $include_second_tier\n";
    # } else {
	# print STDERR "NO SECOND ARG\n";
    }


    SWITCH: {
            ($field =~ s/^\/\*\!//so) && do { return ($include_first_tier || $include_second_tier); };
            ($field =~ s/^\/\/\!//so) && do { return ($include_first_tier || $include_second_tier); };
            ($field =~ s/^abstract(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^alsoinclude(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^apiuid(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^attribute(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^attributeblock(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^attributelist(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^author(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^availability(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^availabilitymacro(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^brief(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^callback(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^category(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^CFBundleIdentifier(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^charset(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^coclass(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^class(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^classdesign(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^compilerflag(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^const(ant)?(\s+|$)//sio) && do { return ($include_first_tier || $include_second_tier); };
            ($field =~ s/^copyright(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^define(d)?(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^define(d)?block(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^\/define(d)?block(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^dependency(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^deprecated(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^description(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^details(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^discussion(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^encoding(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^enum(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^exception(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^field(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^file(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^flag(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^framework(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^frameworkuid(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^frameworkpath(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^frameworkcopyright(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^function(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^functiongroup(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^group(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^<\/hd_link>//sio) && do { return $include_second_tier; };	# note: opening tag not needed.
									# This is not a real tag.  It
									# is automatically inserted to
									# replace @/link, however,
									# and thus may appear at the
									# start of a parsed field in
									# some parts of the code.
            ($field =~ s/^header(\s+|$)//sio) && do { return $include_first_tier; }; 
            ($field =~ s/^headerpath(\s+|$)//sio) && do { return $include_second_tier; }; # for @framework
            ($field =~ s/^helper(class)?(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^helps(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^hidesingletons(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^hidecontents(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^ignore(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^ignorefuncmacro(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^important(\s+|$)//sio) && do { return -$include_second_tier; }; 
            ($field =~ s/^indexgroup(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^instancesize(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^interface(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^internal(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^language(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^link(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^\/link//sio) && do { return $include_second_tier; };
            ($field =~ s/^meta(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^method(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^methodgroup(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^name(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^namespace(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^note(\s+|$)//sio) && do { return -$include_second_tier; }; 
            ($field =~ s/^noParse(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^ownership(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^param(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^parseOnly(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^preprocinfo(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^performance(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^property(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^protocol(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^related(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^result(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^return(s)?(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^security(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^see(also|)(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^serial(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^serialData(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^serialfield(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^since(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^struct(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^super(class|)(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^template(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^templatefield(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^throws(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^typedef(\s+|$)//sio) && do { return $include_first_tier; };
	    ($field =~ s/^union(\s+|$)//sio) && do { return $include_first_tier; };
            ($field =~ s/^unformatted(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^unsorted(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^updated(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^var(\s+|$)//sio) && do { return $include_first_tier; }; 
            ($field =~ s/^vargroup(\s+|$)//sio) && do { return $include_second_tier; }; 
            ($field =~ s/^version(\s+|$)//sio) && do { return $include_second_tier; };
            ($field =~ s/^warning(\s+|$)//sio) && do { return -$include_second_tier; }; 
            ($field =~ s/^whyinclude(\s+|$)//sio) && do { return $include_second_tier; };
                {                       # print STDERR "NOTFOUND: \"$field\"\n";
					if (length($field)) {
						return 0;
					}
					return 1;
                };
         
        }
}

# /*!
#     @abstract
#         Replaces the <code>\@warning</code> and <code>\@important</code> tags
#         with appropriate HTML markup.
#  */
sub replaceTag($$$)
{
	my $fieldsref = shift;
	my $iter = shift;
	my $xml_mode = shift;

	my $localDebug = 0;

	my @fields = @{$fieldsref};

	my $tag = $fields[$iter];

	my $dropfield = 0;
	my $previousfield = $iter - 1;
	if ($iter) {
		$dropfield = 1;
	} else {
		$previousfield = $iter;
	}

	my $xmlkey = "";
	my $title = "";
	my $body = "";

	my $text;
	my $rest;
	my $more_after; # If true, there's more content after this.

	if ($tag =~ s/^warning(\s|$)//si) {
		$tag =~ s/^\s*//sg;
		($text, $rest, $more_after) = splitOnPara($tag);

		$xmlkey = "hd_warning_internal";
		$body = $text;
	} elsif ($tag =~ s/^important(\s|$)//si) {
		$tag =~ s/^\s*//sg;
		($text, $rest, $more_after) = splitOnPara($tag);

		$xmlkey = "hd_important_internal";
		$body = $text;
	} elsif ($tag =~ s/^note(\s|$)//si) {
		my $notitle = 0;
		if ($1 =~ /[\n\r]/ || $tag =~ /^\s*[\n\r]+/) {
			$notitle = 1;
		}

		$tag =~ s/^\s*//sg;
		($text, $rest, $more_after) = splitOnPara($tag);

		if ($notitle) {
			$body = $text;
		} else {
			($title, $body) = split(/[\n\r]+/, $text, 2);
		}

		# print STDERR "TITLE: \"$title\"\n";
		if ($title !~ /\S/) {
			$title = "Note";
		}
		$xmlkey = "hd_note_internal";
	} else {
		warn "Could not replace unknown tag \"$tag\"\n";
		return ($fieldsref, 0, "");
	}

	# Now that we have this in $tag, wipe it from the array.
	$fields[$iter] = "";

	my $append = "";
	my $tail = "";

	$append = "<$xmlkey><note_title>$title</note_title><p>".$body;
	$tail = "</p></$xmlkey>\n$rest";

	if ($localDebug) {
		print STDERR "CONVERSION:\n";
		print STDERR "    XMLKEY: $xmlkey\n";
		# print STDERR "    HTMLKEY: $htmlkey\n";
		# print STDERR "    CSSINDENTCLASS: $cssindentclass\n";
		print STDERR "    TEXT: $text\n";
		print STDERR "    TITLE: $title\n";
		print STDERR "    BODY: $body\n";

		print STDERR "APPEND: $append\n";
		print STDERR "TAIL: $tail\n";
		print STDERR "ITER: $iter\n";
	}

	if ($more_after) {
		# We got a paragraph break.  Append the closing bits immediately.

		print STDERR "DONE.  ADDING $tail TO APPEND\n" if ($localDebug);

		$append .= $tail;
	} else {
		# No paragraph break.  Figure out where to append the closing tags.
		if ($iter == $#fields) {
			# This is the last part.  Append it immediately.
			$append .= $tail;

			print STDERR "LASTFIELD.  ADDING $tail TO APPEND\n" if ($localDebug);
		} else {
			my $origiter = $iter;

			$iter++;
			while (1) {
				my $nextfield = $fields[$iter];
				# print STDERR "NEXTFIELD: $nextfield\n";
				if (validTag($nextfield)) {
					if ($nextfield !~ /^(link|linkdoc|linkplain|docroot|value|inheritDoc|\/link)/) {
						# Insert before any other type of field.

						last;
					}
				} elsif ($nextfield !~ /\n\n/) {
					# Insert into this field.
					$iter++; last;
				}
				$iter++;
				if ($iter > $#fields) { last; } # Break at the one after the last field.
			}

			print STDERR "Adding $tail before node ".$fields[$iter]."\n" if ($localDebug);

			$iter--;

			if ($iter == $origiter) {
				# Immediately encountered a tag that can't be part of the
				# note/important/warning box.  Append the close tag immediately.
				$append .= $tail;
			} else {
				print STDERR "IN NODE $iter: ".$fields[$iter]."\n" if ($localDebug);

				($text, $rest, $more_after) = splitOnPara($fields[$iter]);

				print STDERR "TEXT: $text\nREST: $rest\nDONE: $more_after\n" if ($localDebug);

				$fields[$iter] = $text.$tail.$rest;

				print STDERR "MODIFYING FIELD WITH $tail\n" if ($localDebug);
				print STDERR "NOW: ".$fields[$iter]."\n" if ($localDebug);
			}
		}
	}

	return (\@fields, 2, $append);
}

# /*!
#     @abstract
#         Splits a string containing a HeaderDoc comment into
#         an array of fields with the leading <code>\@</code> stripped.
#         The first of these field is the leading discussion
#         (if applicable).
#  */
sub stringToFields($$$$$$)
{
	my $line = shift;
	my $fullpath = shift;
	my $linenum = shift;
	my $xmlmode = shift;
	my $lang = shift; # Unused, but worth having if needed.
	my $sublang = shift; # Unused, but worth having if needed.

	my $localDebug = 0;

	print STDERR "LINE WAS: \"$line\"\n" if ($localDebug);



	my @fields = split(/\@/s, $line);
	my @newfields = ();
	my $lastappend = "";
	my $in_textblock = 0;
	my $in_link = 0;
	my $lastlinkfield = "";

	my $keepfield = "";
	foreach my $field (@fields) {
		if ($field =~ /\\$/s) {
			$field =~ s/\\$//s;
			if ($keepfield ne "") {
				$keepfield .= "@".$field;
			} else {
				$keepfield = $field;
			}
		} elsif ($keepfield ne "") {
			$field = $keepfield."@".$field;
			$keepfield = "";
			push(@newfields, $field);
		} else {
			push(@newfields, $field);
		}
	}
	@fields = @newfields;
	@newfields = ();

	for (my $iter = 0; $iter <= $#fields; $iter++) {
	# foreach my $rawfield (@fields) {
	  my $rawfield = $fields[$iter];

	  my $field = filterHTMLLinks($rawfield);

	  my $dropfield = 0;
	  print STDERR "processing $field\n" if ($localDebug);
	  if ($in_textblock) {
	    if ($field =~ /^\/textblock/so) {
		print STDERR "out of textblock\n" if ($localDebug);
		if ($in_textblock == 1) {
		    my $cleanfield = $field;
		    $cleanfield =~ s/^\/textblock//sio;
		    $lastappend .= $cleanfield;
		    push(@newfields, $lastappend);
		    print STDERR "pushed \"$lastappend\"\n" if ($localDebug);
		    $lastappend = "";
		}
		$in_textblock = 0;
	    } else {
		# clean up text block
		$field =~ s/\</\&lt\;/sgo;
		$field =~ s/\>/\&gt\;/sgo;
		$lastappend .= "\@$field";
		print STDERR "new field is \"$lastappend\"\n" if ($localDebug);
	    }
	  } else {
	    # if ($field =~ /value/so) { warn "field was $field\n"; }
	    if ($field =~ s/^value/<hd_value\/>/sio) {
		$lastappend = pop(@newfields);
	    }
	    if ($field =~ s/^inheritDoc/<hd_ihd\/>/sio) {
		$lastappend = pop(@newfields);
	    }
	    # if ($field =~ /value/so) { warn "field now $field\n"; }
	    if ($field =~ s/^\/link/<\/hd_link>/sio) {
		# warn "FIELD WAS \"$field\"\n";
		if ($field =~ /^<\/hd_link>\s+[,.!?]/s) { $field =~ s/^<\/hd_link>\s+/<\/hd_link>/s; }
		# warn "FIELD NOW \"$field\"\n";
		if ($in_link) {
			$in_link = 0;
		} else {
			# drop this field on the floor.
			my $lastfield = pop(@newfields);
			$field =~ s/^<\/hd_link>//s;
			push(@newfields, $lastfield.$field);
			$field = "";
			$dropfield = 1;
		}
	    }
	    my $valid = validTag($field);
	    # Do field substitutions up front.
	    if ($valid == -1) {
		my ($fieldsref, $newdrop, $append) = replaceTag(\@fields, $iter, $xmlmode);
		@fields = @{$fieldsref};
		$dropfield = $newdrop;

		# $field = replaceTag($field, $xmlmode);
		# print STDERR "REPLACEMENT IS $field\n";
		if ($append) {
		    my $prev = pop(@newfields);
		    if (!$prev) { $prev = ""; }
		    push(@newfields, $prev.$append);
		    $dropfield = 2;
		}
	    }
	    if ($field =~ s/^link\s+//sio) {
		$lastlinkfield = $field;
		$in_link = 1;
		my $target = "";
		my $lastfield;

		if ($lastappend eq "") {
		    $lastfield = pop(@newfields);
		} else {
		    $lastfield = "";
		}
		# print STDERR "lastfield is $lastfield";
		$lastappend .= $lastfield; 
		if ($field =~ /^(\S*?)\s/so) {
		    $target = $1;
		} else {
		    # print STDERR "$fullpath:$linenum:MISSING TARGET FOR LINK!\n";
		    $target = $field;
		}
		my $localDebug = 0;
		print STDERR "target $target\n" if ($localDebug);
		$field =~ s/^\Q$target\E//sg;
		$field =~ s/\\$/\@/so;
		print STDERR "name $field\n" if ($localDebug);

		# Work around the infamous star-slash (eoc) problem.
		$target =~ s/\\\//\//g;

		if ($field !~ /\S/) { $field = nameFromAPIRef($target); }

		$lastappend .= "<hd_link posstarget=\"$target\">";
		$lastappend .= "$field";
	    } elsif ($field =~ /^textblock\s/sio) {
		if ($lastappend eq "") {
		    $in_textblock = 1;
		    print STDERR "in textblock\n" if ($localDebug);
		    $lastappend = pop(@newfields);
		} else {
		    $in_textblock = 2;
		    print STDERR "in textblock (continuation)\n" if ($localDebug);
		}
		$field =~ s/^textblock(?:[ \t]+|([\n\r]))/$1/sio;
		# clean up text block
		$field =~ s/\</\&lt\;/sgo;
		$field =~ s/\>/\&gt\;/sgo;
		$lastappend .= "$field";
		print STDERR "in textblock.\nLASTAPPEND:\n$lastappend\nENDLASTAPPEND\n" if ($localDebug);
	    } elsif ($dropfield) {
		if ($dropfield == 1) {
			warn "$fullpath:$linenum:Unexpected \@/link tag found in HeaderDoc comment.\n";
		}
	    } elsif (!$valid) {
		my $fieldword = $field;
		my $lastfield = "";

		if ($lastappend == "") {
			$lastfield = pop(@newfields);
		} else {
			$lastfield = "";
		}
		$lastappend .= $lastfield; 

		# $fieldword =~ s/^\s*//sg; # Don't do this.  @ followed by space is an error.
		$fieldword =~ s/\s.*$//sg;
		warn "$fullpath:$linenum:Unknown field type \@".$fieldword." in HeaderDoc comment.\n";
		if ($localDebug) {
			cluck("Backtrace follows.\n");
		}
		$lastappend .= "\@".$field;

		if ($field !~ s/\\$/\@/so) {
			push(@newfields, $lastappend);
			$lastappend = "";
		}
	    } elsif ($field =~ s/\\$/\@/so) {
		$lastappend .= $field;
	    } elsif ($lastappend eq "") {
		push(@newfields, $field);
	    } else {
		$lastappend .= $field;
		push(@newfields, $lastappend);	
		$lastappend = "";
	    }
	  }
	}
	if (!($lastappend eq "")) {
	    push(@newfields, $lastappend);
	}
	if ($in_link) {
		warn "$fullpath:$linenum: warning: Unterminated \@link tag (starting field was: $lastlinkfield)\n";
	}
	if ($in_textblock) {
		warn "$fullpath:$linenum: warning: Unterminated \@textblock tag\n";
	}
	@fields = @newfields;

	if ($localDebug) {
		print STDERR "FIELDS:\n";
		for my $field (@fields) {
			print STDERR "FIELD:\n$field\n";
		}
	}

	return \@fields;
}

# /*! @group HTML helpers
#     @abstract
#         Functions used in HTML output.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Sanitizes a string for use in a URL
#     @param string
#         The string to sanitize.
#     @param isname
#         Is this the name of a function or type?  If so,
#         be a little looser to conform with the apple_ref
#         spec (even though the result does technically
#         violate the HTML spec).  (Optional; default 0.)
#  */
sub sanitize
{
    my $string = shift;
    my $isname = 0;
    if (@_) {
	$isname = shift;
    }
    my $isoperator = 0;
    if ($isname) {
	if ($string =~ /operator/) { $isoperator = 1; }
    }

    my $newstring = "";
    my $prepart = "";
    my $postpart = "";

if ($string =~ /^\w*$/o) { return $string; }

    if ($string =~ s/^\///so) {
	$prepart = "/";
    }
    if ((!$isname) || (!$isoperator)) {
	if ($string =~ s/\/$//so) {
		$postpart = "/";
	}
    }

    my @parts = split(/(\W|\s)/, $string);

    foreach my $part (@parts) {
	if (!length($part)) {
		next;
	} elsif ($part =~ /\w/o) {
		$newstring .= $part;
	} elsif ($part =~ /\s/o) {
		# drop spaces.
		# $newstring .= $part;
	} elsif ($part =~ /[\~\:\,\.\-\_\+\!\*\(\)]/o) {
		# We used to exclude '$' as well, but this
		# confused libxml2's HTML parser.
		$newstring .= $part;
	} elsif ((!$isname) && $part =~ /\//o) {
		# Don't allow slashes through in a name, because otherwise
		# "operator /" adds a bogus empty part to the apple_ref.
		$newstring .= $part;
	} else {
		if (!$isname || ($isoperator && $part =~ /[\=\|\/\&\%\^\!\<\>]/)) {
			# $newstring .= "%".ord($part);
			my $val = ord($part);
			my $valstring = uc(sprintf("%02x", $val));
			$newstring .= "\%$valstring";
		}
	}
    }

    return $prepart.$newstring.$postpart;
}

# /*! @group Documentation Block Functions */

# /*!
#     @abstract
#         Returns whether a HeaderDoc comment containing a given
#         top-level tag can legally be nested inside a documented declaration.
#     @discussion
#         Most calls to <code>warnHDComment</code> from
#         {@link //apple_ref/doc/header/headerDoc2HTML.pl headerDoc2HTML.pl}
#         or {@link blockParseOutside} should always result in an error
#         (since they occur only outside the context of a declaration.
#
#         The exception is test point 12, which can cause false
#         positives for <code>\@defineblock</code> blocks.  For this reason,
#         there is an explicit check to ignore defines inside such a block.
#  */
sub nestignore
{
    my $tag = shift;
    my $dectype = shift;

# print STDERR "DT: $dectype TG: $tag\n";

    # Allow defines in a define block.
    if ($dectype =~ /defineblock/o && ($tag =~ /^\@define/o || $tag =~ /^\s*[^\s\@]/)) {
	# print STDERR "SETTING NODEC TO 1 (DECTYPE IS $dectype)\n";
	# $HeaderDoc::nodec = 1;
	return 1;
    }


    return 0;
}

# /*!
#     @abstract
#         Prints a warning when a HeaderDoc command appears in a
#         place where it is not expected.
#     @param teststring
#         string to be checked for headerdoc markup
#     @param linenum
#         line number
#     @param dectype
#         declaration type
#     @param dp
#         debug point string
#     @result
#         Returns 0 if this HeaerDoc comment is legal.
#
#         Returns 1 if this HeaerDoc comment is not legal.
#
#         Returns 2 if this HeaerDoc comment is an <code>\@define</code>
#         inside an <code>\@defineblock</code> tag.
#  */
sub warnHDComment
{
    my $linearrayref = shift;
    my $blocklinenum = shift;
    my $blockoffset = shift;
    my $lang = shift;
    my $dectype = shift;
    my $dp = shift;
    my $parseTokensRef = shift;
    my $optional_lastComment = shift;

    my $fullpath = $HeaderDoc::headerObject->fullpath();
    my $localDebug = 2; # Set to 2 so I wouldn't keep turning this off.
    my $rawLocalDebug = 0;
    my $maybeblock = 0;

print STDERR "DT: $dectype\n" if ($rawLocalDebug);

    if ($dectype =~ /blockMode:\#define/) {
	# print STDERR "DEFBLOCK?\n";
	$maybeblock = 1;
    }
    # if ($dectype =~ /blockMode:#define/ && ($tag =~ /^\@define/i || $tag !~ /^\@/)) {
	# return 2;
    # }

    my $line = ${$linearrayref}[$blocklinenum];
    my $linenum = $blocklinenum + $blockoffset;

	print STDERR "LINE WAS $line\n" if ($rawLocalDebug);

    my $isshell = 0;

    my %parseTokens = %{$parseTokensRef};

    my $soc = $parseTokens{soc}; # $HeaderDoc::soc;
    my $ilc = $parseTokens{ilc}; # $HeaderDoc::ilc;
    # my $socquot = $HeaderDoc::socquot;
    # my $ilcquot = $HeaderDoc::ilcquot;
    my $indefineblock = 0;

    if ($optional_lastComment =~ /\s*\/\*\!\s*\@define(d)?block\s+/s) {
	print STDERR "INBLOCK\n" if ($rawLocalDebug);
	$indefineblock = 1;
	$dectype = "defineblock";
    } else {
	print STDERR "optional_lastComment: $optional_lastComment\n" if ($rawLocalDebug);
    }

    if (($lang eq "shell") || ($lang eq "perl") || ($lang eq "tcl")) {
	$isshell = 1;
    }

    my $debugString = "";
    if ($localDebug) { $debugString = " [debug point $dp]"; }

    if ((!$isshell && $line =~ /\Q$soc\E\!(.*)$/s) || ($isshell && $line =~ /\Q$ilc\E\s*\/\*\!(.*)$/s)) {
	my $rest = $1;

	$rest =~ s/^\s*//so;
	$rest =~ s/\s*$//so;

	while (!length($rest) && ($blocklinenum < scalar(@{$linearrayref}))) {
		$blocklinenum++;
		$rest = ${$linearrayref}[$blocklinenum];
		$rest =~ s/^\s*//so;
		$rest =~ s/\s*$//so;
	}

	print STDERR "REST: $rest\nDECTYPE: $dectype\n" if ($rawLocalDebug);

	if ($rest =~ /^\@/o) {
		 if (nestignore($rest, $dectype)) {
			print STDERR "NEST IGNORE[1]\n" if ($rawLocalDebug);
			return 0;
		}
	} else {
		print STDERR "Nested headerdoc markup with no tag.\n" if ($rawLocalDebug);
		 if (nestignore($rest, $dectype)) {
			print STDERR "NEST IGNORE[2]\n" if ($rawLocalDebug);
			return 0;
		}
	}

	if ($maybeblock) {
		print STDERR "CHECKING FOR END OF DEFINE BLOCK.  REST IS \"$rest\"\n" if ($rawLocalDebug);
		if ($rest =~ /^\s*\@define(d?)\s+/) {
			print STDERR "DEFINE\n" if ($rawLocalDebug);
			return 2;
		}
		if ($rest =~ /^\s*[^\@\s]/) {
			print STDERR "OTHER\n" if ($rawLocalDebug);
			return 2;
		}
	}
	if (!$HeaderDoc::ignore_apiuid_errors) {
		warn("$fullpath:$linenum: warning: Unexpected headerdoc markup found in $dectype declaration$debugString.  Output may be broken.\n");
	}
	print STDERR "RETURNING 1\n" if ($rawLocalDebug);
	return 1;
    }
#print STDERR "OK\n";
    print STDERR "RETURNING 0\n" if ($rawLocalDebug);
    return 0;
}

# sub get_super {
    # my $classType = shift;
    # my $dec = shift;
    # my $super = "";
    # my $localDebug = 0;
# 
    # print STDERR "GS: $dec EGS\n" if ($localDebug);
# 
    # $dec =~ s/\n/ /smgo;
# 
    # if ($classType =~ /^occ/o) {
	# if ($dec !~ s/^\s*\@interface\s*//so) {
	    # if ($dec !~ s/^\s*\@protocol\s*//so) {
	    	# $dec =~ s/^\s*\@class\s*//so;
	    # }
	# }
	# if ($dec =~ /(\w+)\s*\(\s*(\w+)\s*\)/o) {
	    # $super = $1; # delegate is $2
        # } elsif (!($dec =~ s/.*?://so)) {
	    # $super = "";
	# } else {
	    # $dec =~ s/\(.*//sgo;
	    # $dec =~ s/\{.*//sgo;
	    # $super = $dec;
	# }
    # } elsif ($classType =~ /^cpp$/o) {
	# $dec =~ s/^\s*\class\s*//so;
        # if (!($dec =~ s/.*?://so)) {
	    # $super = "";
	# } else {
	    # $dec =~ s/\(.*//sgo;
	    # $dec =~ s/\{.*//sgo;
	    # $dec =~ s/^\s*//sgo;
	    # $dec =~ s/^public//go;
	    # $dec =~ s/^private//go;
	    # $dec =~ s/^protected//go;
	    # $dec =~ s/^virtual//go;
	    # $super = $dec;
	# }
    # }
# 
    # $super =~ s/^\s*//o;
    # $super =~ s/\s.*//o;
# 
    # print STDERR "$super is super\n" if ($localDebug);
    # return $super;
# }

# Note: backslashes before comments in the list below
# are so that HeaderDoc doesn't interpret them as tags.
# /*!
#      @abstract
#         Returns the API reference type for a class based on
#         block parser info and the HeaderDoc comment.
#      @discussion
#         <code>classTypeFromFieldAndBPinfo</code> takes the type requested
#         in the headerdoc comment (or <code>auto</code> if none requested), the
#         type returned by the block parser, and the declaration (or the
#         first few bytes thereof) and determines what HeaderDoc object
#         should be created.
# 
# <pre>
#      Matching list:
#        HD                    CODE                    Use
#        \@interface            ----                    same as \@class (usually C COM Interface)
#        \@class                \@class                  ObjCCategory (gross)
#                                                      /|\ should be ObjCClass?
#        \@class                class                   CPPClass
#        \@class                typedef struct          CPPClass
#        \@class                \@interface              ObjCClass
#        \@category             \@interface              ObjCCategory
#        \@protocol             \@protocol               ObjCProtocol
#        auto                  \@interface name : ...   ObjCClass
#        auto                  \@interface name(...)    ObjCCategory
#        auto                  \@protocol               ObjCProtocol
#        auto                  class                   CPPClass
#        auto                  namespace               CPPClass
#        auto                  module                  CPPClass
#        auto                  package                 CPPClass
# </pre>
#  */
sub classTypeFromFieldAndBPinfo
{
	my $classKeyword = shift;
	my $classBPtype = shift;
	my $classBPdeclaration = shift;
	my $fullpath = shift;
	my $linenum = shift;
	my $sublang = shift;

	my $deccopy = $classBPdeclaration;
	$deccopy =~ s/[\n\r]/ /s;
	$deccopy =~ s/\{.*$//sg;
	$deccopy =~ s/\).*$//sg;
	$deccopy =~ s/;.*$//sg;

	# print STDERR "DC: $deccopy\n";
	# print STDERR "CBPT: $classBPtype\n";

	SWITCH: {
		($classBPtype =~ /^\@protocol/) && do { return "intf"; };
		($classKeyword =~ /category/) && do { return "occCat"; };
		# ($classBPtype =~ /^\@class/) && do { return "occCat"; };
		($classBPtype =~ /^\@class/) && do { return "occ"; };
		($classBPtype =~ /^\@interface/) && do {
				if ($classKeyword =~ /class/) {
					return "occ";
				} elsif ($deccopy =~ /\:/s) {
					# print STDERR "CLASS: $deccopy\n";
					return "occ";
				} elsif ($deccopy =~ /\(/s) {
					# print STDERR "CATEGORY: $deccopy\n";
					return "occCat";
				} else {
					last SWITCH;
				}
			};
		($classKeyword =~ /class/) && do { return $sublang; };
		($classBPtype =~ /typedef/) && do { return "C"; };
		($classBPtype =~ /struct/) && do { return "C"; };
		($classBPtype =~ /class/) && do { return $sublang; };
		($classBPtype =~ /script/) && do { return $sublang; };
		($classBPtype =~ /interface/) && do { return $sublang; };
		($classBPtype =~ /implementation/) && do { return $sublang; };
		($classBPtype =~ /module/) && do { return $sublang; };
		($classBPtype =~ /namespace/) && do { return $sublang; };
		($classBPtype =~ /package/) && do { return $sublang; };
	}
	warn "$fullpath:$linenum: warning: Unable to determine class type.\n";
	warn "KW: $classKeyword\n";
	warn "BPT: $classBPtype\n";
	warn "DEC: $deccopy\n";
	return "cpp";
}

# /*! @group String Functions
#     @abstract
#         Functions for working with strings.
#     @discussion
#         
#  */


# /*!
#     @abstract
#         Returns whether two strings match and are non-empty.
#     @param a
#         The first string.
#     @param b
#         The second string.
#     @param case
#         If 1, perform case-sensitive comparison; if 0,
#         perform a case-insensitive comparison.
#  */
sub casecmp
{
    my $a = shift;
    my $b = shift;
    my $case = shift;

    if (!$case) {
	$a = lc($a);
	$b = lc($b);
    }
    if (($a eq $b) && ($a ne "") && ($b ne "")) { return 1; }

    return 0;
}

# /*! @group Documentation Block Functions */

# /*!
#     @abstract
#         Returns whether a HeaderDoc comment requires a declaration
#         after it or not.
#     @param line
#         The line (beginning with a HeaderDoc token) to check.
#     @result
#         Returns 2 if a declaration cannot follow.
#
#         Returns 1 if a declaration is optional (empty is OK).
#
#         Returns 0 if a declaration is mandatory.
#  */
sub emptyHDok
{
    my $line = shift;
    my $okay = 0;

    SWITCH: {
	($line =~ /\@param(\s|$)/o) && do { $okay = 1; };
	($line =~ /\@name(\s|$)/o) && do { $okay = 1; };
	($line =~ /\@(function|method|)group(\s|$)/o) && do { $okay = 2; };
	($line =~ /\@language(\s|$)/o) && do { $okay = 1; };
	($line =~ /\@file(\s|$)/o) && do { $okay = 1; };
	($line =~ /\@header(\s|$)/o) && do { $okay = 1; };
	($line =~ /\@framework(\s|$)/o) && do { $okay = 1; };
	($line =~ /\@\/define(d)?block(\s|$)/o) && do { $okay = 2; };
	($line =~ /\@lineref(\s|$)/o) && do { $okay = 1; };
    }
    return $okay;
}

# /*! @group Availability Macro Functions
#     @abstract
#         Functions for working with availability macros.
#     @discussion
#         
#  */

# /*!
#     @abstract
#         Adds a new availability macro.
#     @param token
#         The availability macri token to add.
#     @param description
#         A text description to use in content if this token is
#         encountered in a declaration.
#  */
sub addAvailabilityMacro($$;$)
{
    my $token = shift;
    my $description = shift;
    my $has_args = 0;
    if (@_) {
	$has_args = shift || 0;
    }

    my $localDebug = 0;

    if (length($token) && length($description)) {
	print STDERR "AVTOKEN: \"$token\"\nDESC: $description\nHAS ARGS: $has_args\n" if ($localDebug);
	# push(@HeaderDoc::ignorePrefixes, $token);
	$HeaderDoc::availability_defs{$token} = $description;
	$HeaderDoc::availability_has_args{$token} = $has_args;
	HeaderDoc::BlockParse::cpp_remove($token);
    }
}

# /*!
#     @abstract
#         Interprets an availability macro string within a
#         <code>__OSX_AVAILABLE_STARTING</code> or
#         <code>__OSX_AVAILABLE_BUT_DEPRECATED</code> macro instance.
#     @param string
#         The string to interpret.
#  */
sub complexAvailabilityTokenToOSAndVersion($)
{
    my $string = shift;

    my $os = "";
    if ($string =~ s/^__IPHONE_//) {
	$os = "iOS";
    } elsif ($string =~ s/^__MAC_//) {
	$os = "Mac OS X";
    } else {
	warn "Unknown OS in availability string \"$string\".  Giving up.\n";
	# cluck("bt\n");
	return "";
    }

    my $version = $string;
    $version =~ s/_/\./g;
    return ($os, $version);
}

# /*!
#     @abstract
#         Takes a new-style ("Magic") availability macro and
#         returns a series of availability strings to match it.
#     @param token
#         The initial token of the availability macro.
#     @param availstring
#         The remaining tokens in the availability macro as a string.
#     @discussion
#         This is used for the new-style complex availability
#         macros.  These can be identified by either the word
#         <code>Magic</code> in the Availability.list file or by the
#         presence of parenthesized arguments in the macro's
#         actual usage.
#  */
sub complexAvailabilityToArray($$)
{
    my $token = shift;
    my $availstring = shift;
    my @returnarray = ();

    $availstring =~ s/\s*//sg;
    my @availparts = split(/,/, $availstring);

    # Translate simplified macros into their larger counterparts.
    if ($token eq "NS_AVAILABLE" || $token eq "CF_AVAILABLE" || $token eq "NS_CLASS_AVAILABLE") {
	$token = "__OSX_AVAILABLE_STARTING";
	$availparts[0] = "__MAC_".$availparts[0];
	$availparts[1] = "__IPHONE_".$availparts[1];
    } elsif ($token eq "NS_AVAILABLE_MAC" || $token eq "CF_AVAILABLE_MAC") {
	$token = "__OSX_AVAILABLE_STARTING";
	$availparts[0] = "__MAC_".$availparts[0];
	$availparts[1] = "__IPHONE_NA";
    } elsif ($token eq "NS_AVAILABLE_IPHONE" || $token eq "CF_AVAILABLE_IPHONE" ||
             $token eq "NS_AVAILABLE_IOS" || $token eq "CF_AVAILABLE_IOS") {
	$token = "__OSX_AVAILABLE_STARTING";
	$availparts[0] = "__MAC_NA";
	$availparts[1] = "__IPHONE_".$availstring;
    } elsif ($token eq "NS_DEPRECATED" || $token eq "CF_DEPRECATED") {
	$token = "__OSX_AVAILABLE_BUT_DEPRECATED";
	$availparts[0] = "__MAC_".$availparts[0];
	$availparts[1] = "__MAC_".$availparts[1];
	$availparts[2] = "__IPHONE_".$availparts[2];
	$availparts[3] = "__IPHONE_".$availparts[3];
    } elsif ($token eq "NS_DEPRECATED_MAC" || $token eq "CF_DEPRECATED_MAC") {
	$token = "__OSX_AVAILABLE_BUT_DEPRECATED";
	$availparts[0] = "__MAC_".$availparts[0];
	$availparts[1] = "__MAC_".$availparts[1];
	$availparts[2] = "__IPHONE_NA";
	$availparts[3] = "__IPHONE_NA";
    } elsif ($token eq "NS_DEPRECATED_IPHONE" || $token eq "CF_DEPRECATED_IPHONE" ||
             $token eq "NS_DEPRECATED_IOS" || $token eq "CF_DEPRECATED_IOS") {
	my $iphone_avail = $availparts[0];
	my $iphone_dep = $availparts[1];

	$token = "__OSX_AVAILABLE_BUT_DEPRECATED";
	$availparts[0] = "__MAC_NA";
	$availparts[1] = "__MAC_NA";
	$availparts[2] = "__IPHONE_".$iphone_avail;
	$availparts[3] = "__IPHONE_".$iphone_dep;
    }

    if ($token eq "__OSX_AVAILABLE_STARTING") {
	my $macstarttoken = $availparts[0];
	my $iphonestarttoken = $availparts[1];
	my ($macstartos, $macstartversion) = complexAvailabilityTokenToOSAndVersion($macstarttoken);
	my ($iphonestartos, $iphonestartversion) = complexAvailabilityTokenToOSAndVersion($iphonestarttoken);

	if ($macstartversion eq "NA") {
		push(@returnarray, "Not available in $macstartos.");
	} else {
		push(@returnarray, "Available in $macstartos v$macstartversion.");
	}
	if ($iphonestartversion eq "NA") {
		push(@returnarray, "Not available in $iphonestartos.");
	} else {
		push(@returnarray, "Available in $iphonestartos v$iphonestartversion.");
	}
    } elsif ($token eq "__OSX_AVAILABLE_BUT_DEPRECATED") {
	my $macstarttoken = $availparts[0];
	my $macdeptoken = $availparts[1];
	my $iphonestarttoken = $availparts[2];
	my $iphonedeptoken = $availparts[3];

	my ($macstartos, $macstartversion) = complexAvailabilityTokenToOSAndVersion($macstarttoken);
	my ($iphonestartos, $iphonestartversion) = complexAvailabilityTokenToOSAndVersion($iphonestarttoken);
	my ($macdepos, $macdepversion) = complexAvailabilityTokenToOSAndVersion($macdeptoken);
	my ($iphonedepos, $iphonedepversion) = complexAvailabilityTokenToOSAndVersion($iphonedeptoken);

	if ($macstartversion eq "NA") {
		push(@returnarray, "Not available in $macstartos.");
	} elsif ($macdepversion eq "NA") {
		push(@returnarray, "Available in $macstartos v$macstartversion.");
	} else {
		if ($macstartversion eq $macdepversion) {
			push(@returnarray, "Introduced in $macstartos v$macstartversion, and deprecated in $macstartos v$macdepversion.");
		} else {
			push(@returnarray, "Introduced in $macstartos v$macstartversion, but later deprecated in $macstartos v$macdepversion.");
		}
	}
	if ($iphonestartversion eq "NA") {
		push(@returnarray, "Not available in $iphonestartos.");
	} elsif ($iphonedepversion eq "NA") {
		push(@returnarray, "Available in $iphonestartos v$iphonestartversion.");
	} else {
		if ($iphonestartversion eq $iphonedepversion) {
			push(@returnarray, "Introduced in $iphonestartos v$iphonestartversion, and deprecated in $iphonestartos v$iphonedepversion.");
		} else {
			push(@returnarray, "Introduced in $iphonestartos v$iphonestartversion, but later deprecated in $iphonestartos v$iphonedepversion.");
		}
	}
    } else {
	warn "Unknown complex availability token \"$token\".  Giving up.\n";
	return \@returnarray;
    }
    return \@returnarray;
}

# /*! @group Documentation Block Functions */

# /*! @abstract
#         Gets the tag name from a tag.
#     @param rawtag
#         The entire tag.
#  */
sub getJustTheTag
{
    my $rawtag = shift;

    my $tag = lc($rawtag);
    $tag =~ s/^<\s*//s;
    $tag =~ s/>.*$//s;
    $tag =~ s/\s+.*$//s;

    return $tag;
}

# /*!
#     @abstract
#         Creates an obect with info about the current HTML tag context.
#     @param tag
#         The HTML tag.
#     @param synthesized
#         Pass 1 if this was added automatically, 0 otherwise.
#  */
sub newHTMLTagContext
{
    my $tag = shift;
    my $synthesized = shift;

    my $obj = ();

    $obj->{tag} = getJustTheTag($tag);
    $obj->{synthesized} = $synthesized;

    return $obj;
}

# /*!
#     @abstract
#         Returns whether a closing tag matches the top of the stack.
#     @param arrayref
#         A reference to the tag stack array.
#     @param tag
#         The closing tag to check.
#     @discussion
#         If the top node in the stack matches, returns 1.
#
#         If the top node was added implicitly, returns 1.
#
#         If the top node should go away because the top node
#         is one that can be auto-closed, returns 1.
#
#         Otherwise returns 0.
#  */
sub canMatchTag
{
    my $arrayref = shift;
    my $tag = shift;
    my @arr = @{$arrayref};
    my @copy = @arr;

    my $top = pop(@copy);

    my $localDebug = 0;

    $tag =~ s/^\///s;
    print STDERR "MATCHING TAG IS $tag\n" if ($localDebug);

    while ($top) {
	print STDERR "TOP IS ".$top->{tag}.", ".$top->{synthesized}."\n" if ($localDebug);

	if ($top->{tag} eq $tag) {
		print STDERR "RETURNING 1\n" if ($localDebug);
		return 1;
	}
	if (!$top->{synthesized}) {
		# Treat a p or li tag as auto-closing.
		if ($tag eq "div" && $top->{tag} eq "p") {
			print STDERR "Auto-closing paragraph in div.\n" if ($localDebug);
		} elsif ($tag eq "ul" || $tag eq "ol" && $top->{tag} eq "li") {
			print STDERR "Auto-closing li in ul or ol.\n" if ($localDebug);
		} else {
			print STDERR "RETURNING 0\n" if ($localDebug);
			return 0;
		}
	}
	$top = pop(@copy);
    }

    return 0;
}

# /*!
#     @abstract
#         Converts legal HTML (but illegal XML) attributes to
#         legal XML attributes.
#     @param orig_attributes
#         A string containing the original attributes (without
#         the trailing right angle bracket).
#     @returns
#         A string containing the attributes formatted for XML
#         output, with any unquoted values quoted, with any
#         empty attributes assigned a value (adds =""), and
#         with spaces between attributes if missing.
#     @discussion
#         This function attempts to return proper XML from even
#         severely damaged HTML input, but in some cases, even
#         this code must punt and drop the remaining attributes.
#  */
sub fixXHTMLAttributes
{
    my $orig_attributes = shift;

    my $localDebug = 0;

    # Although xmllint --html --xmlout does a good job at
    # sanitizing tags, it does a lousy job of sanitizing
    # attributes.  Thus, we do it on the way in.

    # Note: this does not absolutely gurantee valid XML.  If the
    # first character in the attribute is not in the set of legal
    # characters that are allowed in an attribute name, this
    # code does not attempt to fix it.

    my @parts = split(/([^:A-Z_a-z\xC0-\xD6\xD8-\xF6\xF8-\x{2FF}\x{370}-\x{37D}\x{37F}-\x{1FFF}\x{200C}-\x{200D}\x{2070}-\x{218F}\x{2C00}-\x{2FEF}\x{3001}-\x{D7FF}\x{F900}-\x{FDCF}\x{FDF0}-\x{FFFD}\x{10000}-\x{EFFFF}.0-9\xB7\x{0300}-\x{036F}\x{203F}-\x{2040}-])/, $orig_attributes);
    my $insquo = 0; my $indquo = 0;
    my $attpending = 0; my $attributes = "";
    my $droprest = 0; my $needspace = "";

    foreach my $part (@parts) {
	print STDERR "PART: $part\n" if ($localDebug);
	if ($indquo) {
		print STDERR "INDQUO\n" if ($localDebug);
		if ($part eq "\"") {
			print STDERR "INDQUO -> 0\n" if ($localDebug);
			$indquo = 0;
			$needspace = " ";
		}
	} elsif ($insquo) {
		print STDERR "INDQUO\n" if ($localDebug);
		if ($part eq "'") {
			print STDERR "INSQUO -> 0\n" if ($localDebug);
			$insquo = 0;
			$needspace = " ";
		}
	} elsif ($part eq "'") {
		print STDERR "INSQUO -> 1\n" if ($localDebug);
		$insquo = 1; $attpending = 0;
	} elsif ($part eq "\"") {
		print STDERR "INDQUO -> 1\n" if ($localDebug);
		$indquo = 1; $attpending = 0;
	} elsif ($attpending) {
		print STDERR "ATTPENDING\n" if ($localDebug);
		if ($part eq "=") {
			print STDERR "ATTPENDING -> 2\n" if ($localDebug);
			$attpending = 2;
		} elsif ($part =~ /\w/) {
			print STDERR "ATTPENDING, WORD\n" if ($localDebug);
			if ($attpending == 1) {
				print STDERR "ATTPENDING == 1, WORD\n" if ($localDebug);
				$part = "=\"\" ".$part;
			} else {
				print STDERR "ATTPENDING == 2, WORD\n" if ($localDebug);
				$part = "\"$part\" ";
				$attpending = 0;
			}
		}
	} elsif ($part =~ /\w/) {
		$part = $needspace.$part;
		$needspace = "";
		print STDERR "ATTPENDING -> 1\n" if ($localDebug);
		$attpending = 1;
	} elsif ($part =~ /\s/) {
		$needspace = "";
	} elsif ($part eq "=") {
		$part = "";
		warn("WARNING: Invalid HTML (attribute list is broken.)  Errant text was:\n$orig_attributes\n") if (!$HeaderDoc::running_test);
		warn("Truncating to $attributes\n") if (!$HeaderDoc::running_test);

		return $attributes;
	}
	print STDERR "APPENDING $part\n" if ($localDebug);
	if (!$droprest) {
		$attributes .= $part;
	}
    }
    if ($attpending == 1) {
	print STDERR "ATTPENDING == 1 AT END\n" if ($localDebug);
	$attributes .= "=\"\"";
    } elsif ($attpending == 2) {
	print STDERR "ATTPENDING == 2 AT END\n" if ($localDebug);
	$attributes .= "\"\"";
    };

    if ($attributes ne $orig_attributes) {
	warn("WARNING: Changed non-XHTML attributes from \"$orig_attributes\" to \"$attributes\"\n") if (!$HeaderDoc::running_test);
    }

    return $attributes;
}

# /*!
#     @abstract
#         Interprets the contents of tags like <code>\@discussion</code>.
#     @param tagcontents
#         The string to process.
#     @discussion
#         Process the contents of a tag, e.g. <code>\@discussion</code>.  The argument
#         should contain just the text to be processed, not the tag itself
#         or any end-of-comment marker.
#  */
sub filterHeaderDocTagContents
{
    my $origtagcontents = shift;

    my $filterTagsDebug = 0;

    my %custom_tags = ();
    if ($HeaderDoc::custom_tags) {
	%custom_tags = %{$HeaderDoc::custom_tags};
    }

    my %recommended_tags = (
	"a" => 1,
	"abbr" => 1,
	"acronym" => 1,
	"address" => 1,
	"b" => 1,
	"bdo" => 1,
	"big" => 1,
	"blockquote" => 1,
	"br" => 1,
	"caption" => 1,
	"center" => 1,
	"cite" => 1,
	"code" => 1,
	"dd" => 1,
	"dfn" => 1,
	"dl" => 1,
	"dt" => 1,
	"em" => 1,
	"font" => 1,
	"i" => 1,
	"img" => 1,
	"kbd" => 1,
	"li" => 1,
	"ol" => 1,
	"p" => 1,
	"pre" => 1,
	"q" => 1,
	"s" => 1,      # same as strike
	"samp" => 1,
	"small" => 1,
	"strike" => 1,
	"strong" => 1,
	"sub" => 1,
	"sup" => 1,
	"table" => 1,
	"tbody" => 1,
	"td" => 1,
	"tfoot" => 1,
	"th" => 1,
	"thead" => 1,
	"tr" => 1,
	"tt" => 1,
	"u" => 1,
	"ul" => 1,
	"var" => 1,

	"hd_warning_internal" => 1,   # Used for @warning.
	"hd_important_internal" => 1, # Used for @important
	"hd_note_internal" => 1       # Used for @note
    );

    my %discouraged_tags = (
	"applet" => 1,   # Applets usually aren't appropriate in reference docs.
	"area" => 1,     # Adding destination anchors is discouraged.
	"base" => 1,     # Can interfere with links.
	"basefont" => 1, # Can interfere with other styles on the page.
	"button" => 1,   # Forms and UI should not be in an API reference.
	"col" => 1,      # Would wreck the layout.
	"colgroup" => 1, # Would wreck the layout.
	"del" => 1,      # Why would you use this tag?
	"dir" => 1,      # Deprecated.
	"fieldset" => 1,
	"form" => 1,
	"h1" => 1,       # This would create layout confusion.
	"h2" => 1,       # This would create layout confusion.
	"h3" => 1,       # This would create layout confusion.
	"h4" => 1,       # This would create layout confusion.
	"h5" => 1,       # This would create layout confusion.
	"h6" => 1,       # This would create layout confusion.
	"hr" => 1,       # would cause layout problems.
	"input" => 1,
	"ins" => 1,
	"label" => 1,
	"legend" => 1,
	"link" => 1,     # There are supported HeaderDoc tags for this.
	"map" => 1,      # Adding destination anchors is discouraged.
	"menu" => 1,     # Deprecated.
	"meta" => 1,     # There are supported HeaderDoc tags for this.
	"noscript" => 1,
	"object" => 1,
	"optgroup" => 1,
	"option" => 1,
	"param" => 1,    # Discouraged because object is discouraged.
	"script" => 1,
	"select" => 1,
	"textarea" => 1
     );

    my %illegal_tags = (
	"body" => 1,     # Illegal inside another body tag.
	"frame" => 1,
	"frameset" => 1,
	"head" => 1,
	"html" => 1,      # This would be illegal HTML.
	"iframe" => 1,    # This is just a bad idea.
	"noframes" => 1,  # This would massively break the layout in frames output mode.
	"style" => 1,     # There are supported tags for doing this.
	"title" => 1      # HeaderDoc needs to be in charge of titles.
    );

    if ($HeaderDoc::ExtraAppleWarnings) {
	# Apple uses XML output now, so arbirary CSS can't be handled.
	$illegal_tags{"span"} = 1;
	$illegal_tags{"div"} = 1;
    } else {
	$recommended_tags{"span"} = 1;
	$recommended_tags{"div"} = 1;
    }

    # Nuke illegal tags, warn about discouraged tags.

    my @htmltags = split(/(<)/, $origtagcontents);

    my $tagcontents = "";
    my $first = 1;
    foreach my $htmltag (@htmltags) {
	if ($first) {
		$tagcontents .= $htmltag; $first = 0;
	} elsif ($htmltag eq "<") {
		$tagcontents .= $htmltag;
	} else {
		my @parts;
		my $tagname = "";
		my $attributes = "";
		my $rest = "";

		my $close = "";
		if ($htmltag =~ s/^\///s) { $close = "/"; }

		if ($htmltag =~ />/) {
			@parts = split(/>/, $htmltag, 2);
			($tagname, $attributes) = split(/\s/, $parts[0], 2);
			$rest = $parts[1];
		} else {

			@parts = split(/\W/, $htmltag, 2);
			$tagname = $parts[0];
			$rest = $parts[1];
			print STDERR "TAGNAME $tagname REST $rest\n" if ($filterTagsDebug);
			if (length($tagname)) {
				warn("WARNING: Tag $close$htmltag not properly closed.  Guessing.\n") if (!$HeaderDoc::running_test);
			} else {
				# It's not valid anyway.  Might as well
				# not warn twice, and might as well give
				# the tag "name" in the other warning instead
				# of it being empty.
				$tagname = $htmltag;
				$rest = "";
			}
		}

		# warn("ATTS: $attributes\n");

		if ($tagname eq "hd_link") {
			# No reason to modify this.  To be safe,
			# don't touch it at all (including attribues).
			# It's not a real tag, and won't be passed on
			# in the output anyway.

			$tagcontents .= $close.$htmltag;
		} elsif ($tagname eq "!--") {
			# Likewise.
			$tagcontents .= $close.$htmltag;
		} elsif ($tagname eq "note_title") {
			# Likewise.
			$tagcontents .= $close.$htmltag;
		} elsif ($recommended_tags{lc($tagname)} || $custom_tags{lc($tagname)}) {
			print STDERR "Recommented tag $tagname\n" if ($filterTagsDebug);
			$attributes = fixXHTMLAttributes($attributes);
			if (length($attributes)) { $attributes = " $attributes"; }

			if ($tagname =~ s/\/$//s) {
				$attributes = " /".$attributes;
			}
			$tagcontents .= $close.$tagname.$attributes.">".$rest;
		} elsif ($discouraged_tags{lc($tagname)}) {
			warn("WARNING: Tag $tagname is not recommended.\n") if (!$HeaderDoc::running_test);
			$attributes = fixXHTMLAttributes($attributes);
			if (length($attributes)) { $attributes = " $attributes"; }

			if ($tagname =~ s/\/$//s) {
				$attributes = " /".$attributes;
			}
			$tagcontents .= $close.$tagname.$attributes.">".$rest;
		} elsif ($illegal_tags{lc($tagname)}) {
			warn("WARNING: Tag $tagname is illegal and has been dropped.\n") if (!$HeaderDoc::running_test);

			$tagcontents =~ s/<$//s;
			$tagcontents .= $rest;
		} else {
			warn("WARNING: Tag $tagname is not a valid HTML tag and has been converted to text.\n") if (!$HeaderDoc::running_test);
			$tagcontents =~ s/<$//s;
			$tagcontents .= encode_entities("<".$htmltag);
		}
	}
    }

    print STDERR "PRE:\n$origtagcontents\n\nPOST:\n$tagcontents\n\n" if ($filterTagsDebug);

    # Create paragraph tags and ensure text is wrapped consistently.

    my $opentags = '<\s*p[^>]*>|<\s*h[1-6][^>]*>|<\s*ul[^>]*>|<\s*ol[^>]*>|<\s*pre[^>]*>|<\s*dl[^>]*>|<\s*hd_(?:warning|important|note)[^>]*>|<\s*div[^>]*>|<\s*noscript[^>]*>|<\s*blockquote[^>]*>|<\s*form[^>]*>|<\s*hr[^>]*>|<\s*table[^>]*>|<\s*fieldset[^>]*>|<\s*address[^>]*>|<\s*li[^>]*>';
    my $closetags = '<\s*\/p\s*>|<\s*\/h[1-6]\s*>|<\s*\/ul\s*>|<\s*\/ol\s*>|<\s*\/pre\s*>|<\s*\/dl\s*>|<\s*\/hd_(?:warning|important|note)\s*>|<\s*\/div\s*>|<\s*\/noscript\s*>|<\s*\/blockquote\s*>|<\s*\/form\s*>|<\s*\/hr\s*>|<\s*\/table\s*>|<\s*\/fieldset\s*>|<\s*\/address\s*>|<\s*\/li\s*>';

    my @parts = split(/($opentags|$closetags|\n)/sio, $tagcontents);

    my $localDebug = 0;

    my $output = "";

    my @ibestack = ();
    my @tagstack = ();
    my $root = newHTMLTagContext("body", 0);
    push(@tagstack, $root);

    my $line_is_empty = 0;
    foreach my $part (@parts) {
	my $stacktop = peek(\@tagstack);
	$stacktop = $stacktop->{tag};

	print STDERR "TOP OF TAG STACK: ".$stacktop."\n" if ($localDebug);

	my $tag = getJustTheTag($part);
	if ($part ne "") {
		print STDERR "FHDTC PART: $part\n" if ($localDebug);
		if ($part =~ /\n/) {
			if ($line_is_empty) {
				print STDERR "NEWLINE: EMPTYLINE\n" if ($localDebug);
				# Emit paragraph break.  Two newlines in a row.
				if ($stacktop eq "p") {
					print STDERR "INSERT PARA\n" if ($localDebug);
					$output .= "</p>";
					pop(@tagstack);
					$stacktop = peek(\@tagstack);
					$stacktop = $stacktop->{tag};
				}
				$line_is_empty = 0;
			} else {
				print STDERR "NEWLINE\n" if ($localDebug);
				$line_is_empty = 1;
			}
			$output .= $part;
		} elsif ($part =~ /$opentags/sio) {
			print STDERR "OPENTAG\n" if ($localDebug);
			while ($stacktop eq "p") {
				print STDERR "CLOSING PARA\n" if ($localDebug);
				$output .= "</p>\n"; # close unclosed paragraphs.
				pop(@tagstack);
				$stacktop = peek(\@tagstack);
				$stacktop = $stacktop->{tag};
			}
			$line_is_empty = 0;
			if ($tag eq "li" && $stacktop eq "li") {
				print STDERR "BLOCK IS LI TAG WITH IMPLICIT CLOSE OF PRIOR TAG\n" if ($localDebug);
				# Close it ant do nothing to the stack.  It will be right
				# again momentarily.
				$output .= "</li>";
			} elsif ($tag eq "li" && $stacktop ne "ul" && $stacktop ne "ol") {
				print STDERR "BLOCK IS LI OUTSIDE A LIST\n" if ($localDebug);

				$output .= "<ul>";
				push(@tagstack, newHTMLTagContext("ul", 1));

				push(@tagstack, newHTMLTagContext($part, 0));
				$stacktop = peek(\@tagstack);
				$stacktop = $stacktop->{tag};
			} elsif ($tag eq "p") {
				print STDERR "BLOCK IS OPEN PARA\n" if ($localDebug);
				push(@tagstack, newHTMLTagContext("p", 0));
				$stacktop = peek(\@tagstack);
				$stacktop = $stacktop->{tag};
			} else {
				print STDERR "BLOCK IS NOT OPEN PARA\n" if ($localDebug);
				push(@tagstack, newHTMLTagContext($part, 0));
				$stacktop = peek(\@tagstack);
				$stacktop = $stacktop->{tag};
			}
			$output .= $part;
		} elsif ($part =~ /$closetags/sio) {
			print STDERR "CLOSETAG\n" if ($localDebug);
			$line_is_empty = 0;

			print STDERR "STACKTOP A: $stacktop\n" if ($localDebug);
			if (canMatchTag(\@tagstack, $tag)) {

				my $open = $tag;
				$open =~ s/^\///s;

				print STDERR "STACKTOP B: $stacktop CMP $open\n" if ($localDebug);

				while ($stacktop ne $open) {
					$output .= "</$stacktop>";
					pop(@tagstack);
					$stacktop = peek(\@tagstack);
					$stacktop = $stacktop->{tag};
					print STDERR "STACKTOP C: $stacktop\n" if ($localDebug);
				}

				pop(@tagstack);
				$stacktop = peek(\@tagstack);
				$stacktop = $stacktop->{tag};
			}
			$output .= $part;
		} elsif ((canMatchTag(\@tagstack, "body") || canMatchTag(\@tagstack, "li") || canMatchTag(\@tagstack, "div")) && $stacktop ne "p" && $part =~ /\S/) {

			while ($stacktop ne "body" && $stacktop ne "li" && $stacktop ne "div") {
				$output .= "</$stacktop>";
				pop(@tagstack);
				$stacktop = peek(\@tagstack);
				$stacktop = $stacktop->{tag};
				print STDERR "STACKTOP D: $stacktop\n" if ($localDebug);
			}

			print STDERR "OPENING IMPLICIT PARA\n" if ($localDebug);
			$output .= "<p>";
			$line_is_empty = 0;
			push(@tagstack, newHTMLTagContext("p", 1));
			$stacktop = peek(\@tagstack);
			$stacktop = $stacktop->{tag};
			$output .= $part;
		} else {
			print STDERR "NORMAL TEXT\n" if ($localDebug);
			$line_is_empty = 0;
			$output .= $part;
		}
	}
    }

    if (0) {
	print STDERR "IN filterHeaderDocTagContents:\n";
	print STDERR "PRE:\n$tagcontents\nENDPRE\n";
	print STDERR "POST:\n$output\nENDPOST\n";
    }

    return $output;
}

# /*!
#     @abstract
#         Processes a comment block, stripping off leading '*' and
#         whitespace.
#     @param headerDocCommentLinesArrayRef
#         A reference to an array of lines containing the
#         HeaderDoc comment to process.
#     @param lang
#         The programming language for this comment.
#     @param sublang
#         The language variant for this comment (e.g. <code>cpp</code> for C++).
#     @param inputCounter
#         The line at which this comment block began.
#  */
sub filterHeaderDocComment
{
    my $headerDocCommentLinesArrayRef = shift;
    my $lang = shift;
    my $sublang = shift;
    my $inputCounter = shift;

    # my ($sotemplate, $eotemplate, $operator, $soc, $eoc, $ilc, $ilc_b, $sofunction,
        # $soprocedure, $sopreproc, $lbrace, $rbrace, $unionname, $structname,
        # $enumname,
        # $typedefname, $varname, $constname, $structisbrace, $macronamesref,
        # $classregexp, $classbraceregexp, $classclosebraceregexp, $accessregexp,
        # $requiredregexp, $propname, $objcdynamicname, $objcsynthesizename, $moduleregexp, $definename,
	# $functionisbrace, $classisbrace, $lbraceconditionalre, $lbraceunconditionalre, $assignmentwithcolon,
	# $labelregexp, $parmswithcurlybraces, $superclasseswithcurlybraces,
	# $soconstructor) = 
    my %parseTokens = %{parseTokens($lang, $sublang)};

    my $fullpath = $HeaderDoc::headerObject->fullpath();

    my @headerDocCommentLinesArray = @{$headerDocCommentLinesArrayRef};
    my $returnComment = "";

    my $localDebug = 0;
    my $liteDebug = 0;
    my $commentDumpDebug = 0;

    my $linenum = 0;
    my $curtextblockstarred = 1;
    my @textblock_starred_array = ();
    my $outerstarred = 1;
    my $textblock_number = 0;

    # Perl and shell HeaderDoc comments star with # /*! and end with # ... */
    # This is mainly to avoid conflicting with the shell magic #!.
    if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
	$parseTokens{soc} = "/*";
	$parseTokens{eoc} = "*/";
	$parseTokens{ilc} = "";
    }

    my $eoc = $parseTokens{eoc}; # used in regexp repeatedly.  Need a var.

    my $paranoidstate = 0;
    foreach my $lineref (@headerDocCommentLinesArray) {
	my %lineentry = %{$lineref};
	my $in_textblock = $lineentry{INTEXTBLOCK};
	my $in_pre = $lineentry{INPRE};
	my $leaving_textblock = $lineentry{LEAVINGTEXTBLOCK};
	my $leaving_pre = $lineentry{LEAVINGPRE};
	my $line = $lineentry{LINE};

	# This gets stripped out on the way into the function.  Don't do it twice.
	# if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
		# $line =~ s/^\s*\#//o;
	# }

	print STDERR "PREPASS LINE: \"$line\"\n" if ($localDebug || $liteDebug);
	# print STDERR "CMP $linenum CMP ".$#headerDocCommentLinesArray."\n";

	if (!$linenum) {
		print STDERR "PREPASS SKIP\n" if ($localDebug);
		$linenum++;
	} else {
		if ($in_textblock) {
			print STDERR "PREPASS IN TEXTBLOCK\n" if ($localDebug);
			if ($line !~ /^\s*\*/) {
				print STDERR "CURRENT TEXT BLOCK NOT STARRED\n" if ($localDebug);
				$curtextblockstarred = 0;
			}
		} elsif ($leaving_textblock) {
			print STDERR "PREPASS LEAVING TEXTBLOCK #".$textblock_number." (STARRED = $curtextblockstarred)\n" if ($localDebug);
			$textblock_starred_array[$textblock_number++] = $curtextblockstarred;
			$curtextblockstarred = 1;
		} else {
			print STDERR "PREPASS NORMAL LINE\n" if ($localDebug);
			if ($line !~ /^\s*\*/) {
				print STDERR "PREPASS OUTER NOT STARRED\n" if ($localDebug);
				$outerstarred = 0;
				# last; # bad idea.  Need to handle textblocks still.
			} else {
				if ($line !~ /^\s*\Q$eoc\E/) {
					print STDERR "PARANOID STATE -> 1\n" if ($localDebug);
					$paranoidstate = 1;
				} else {
					print STDERR "EOC\n" if ($localDebug);
				}
			}
		}
		$linenum++;
	}
    }
    # $HeaderDoc::enableParanoidWarnings = 1;
    print STDERR "OUTERSTARRED: $outerstarred\n" if ($localDebug);
    if ($paranoidstate && !$outerstarred && !$HeaderDoc::running_test) {
	warn("$fullpath:$inputCounter: Partially starred comment.\n");
	warn("$fullpath:$inputCounter: Comment follows:\n");
	foreach my $lineref (@headerDocCommentLinesArray) {
		my %lineentry = %{$lineref};
		my $line = $lineentry{LINE};
		warn($line);
	}
	warn("$fullpath:$inputCounter: End of comment.\n");
    }

    # print STDERR "ENDCOUNT: ".$#headerDocCommentLinesArray."\n";


    my $starslash = 0;
    my $lastlineref = pop(@headerDocCommentLinesArray);
    my %lastline = %{$lastlineref};
    my $lastlinetext = $lastline{LINE};

    # This gets stripped out on the way into the function.  Don't do it twice.
    # if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
	# $lastlinetext =~ s/^\s*\#//o;
    # }
    print STDERR "LLT: $lastlinetext\n" if ($localDebug);
    my $origlastlinetext = $lastlinetext;
    if ($lastlinetext =~ s/\Q$eoc\E\s*\\?\s*.*$//s) {
	if ($origlastlinetext !~ s/\Q$eoc\E\s*\\?\s*$//s) {
		# if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
			# $origlastlinetext = "#".$origlastlinetext;
		# }
		warn("$fullpath:$inputCounter: Line contains content after the end of comment marker.  If this tag is not in a structure, class, union, or enumeration, this may not work correctly.  (If it is, ignore this warning.)\nLast line was: $origlastlinetext\n");
	}
	# if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
		# $lastline{LINE} = "#".$lastlinetext;
	# } else {
		$lastline{LINE} = $lastlinetext;
	# }
	print STDERR "FOUND */\n" if ($localDebug);

	# If we just have */ on a line by itself, don't push it.  Otherwise, we would
	# get a bogus <BR><BR> at the end of the comment.
	if ($lastlinetext !~ /\S/) {
		print STDERR "LL dropped because it is empty: $lastlinetext\n" if ($localDebug);
		$starslash = 1;
	} else {
		print STDERR "LL retained (nonempty): $lastlinetext\n" if ($localDebug);
		push(@headerDocCommentLinesArray, $lastlineref);
	}
    } else {
	print STDERR "NO EOC ($eoc)\n";
	print STDERR "LL: $lastlinetext\n" if ($localDebug);
	push(@headerDocCommentLinesArray, $lastlineref);
    }
    $lastlineref = \%lastline;

    $textblock_number = 0;
    my $old_in_textblock = 0;
    foreach my $lineref (@headerDocCommentLinesArray) {
	my %lineentry = %{$lineref};
	my $in_textblock = $lineentry{INTEXTBLOCK};
	my $in_pre = $lineentry{INPRE};
	my $line = $lineentry{LINE};
	my $leaving_textblock = $lineentry{LEAVINGTEXTBLOCK};
	my $leaving_pre = $lineentry{LEAVINGPRE};

	# if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
		# $line =~ s/^\s*\#//o;
	# }

	print STDERR "FILTER LINE: $line\n" if ($localDebug);
	print STDERR "IT: $in_textblock IP: $in_pre LT: $leaving_textblock LP: $leaving_pre\n" if ($localDebug);

	if ($in_textblock && $old_in_textblock) {
		# In textblock (not first line)
		if ($outerstarred) {
			my $tbstarred = $textblock_starred_array[$textblock_number];
			if ($tbstarred) {
				$line =~ s/^\s*[*]//so;
			}
		}
	} else {
		# Either not in a textblock or in the first line of a textblock

		if ($outerstarred) {
			my $tbstarred = $textblock_starred_array[$textblock_number];
 			if (!$leaving_textblock || $tbstarred) {
				$line =~ s/^\s*[*]//so;
			}
		}
		if (!$in_pre && !$leaving_pre && !$leaving_textblock) {
			$line =~ s/^[ \t]*//o; # remove leading whitespace

			# The following modification is done in
			# filterHeaderDocTagContents now.
			# if ($line !~ /\S/) {
				# $line = "</p><p>\n";
			# } 
		}
		$old_in_textblock = $in_textblock;
	}
	if ($leaving_textblock) {
		$textblock_number++;
	}
	# if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
		# $line = "#".$line;
	# }

	$returnComment .= $line;
    }

    if ($starslash) {
	# if ($lang eq "perl" || $lang eq "shell" || $lang eq "tcl") {
		# $returnComment .= "#";
	# }
	$returnComment .= $eoc;
    }

if (0) { # Previous code worked like this:
    foreach my $lineref (@headerDocCommentLinesArray) {
	my %lineentry = %{$lineref};
	my $in_textblock = $lineentry{INTEXTBLOCK};
	my $in_pre = $lineentry{INPRE};
	my $line = $lineentry{LINE};
	# print STDERR "LINE: $line\n";
	$line =~ s/^\s*[*]\s+(\S.*)/$1/o; # remove asterisks that precede text
	if (!$in_textblock && !$in_pre) {
		$line =~ s/^[ \t]*//o; # remove leading whitespace
		if ($line !~ /\S/) {
			$line = "<br><br>\n";
		} 
		$line =~ s/^\s*[*]\s*$/<br><br>\n/o; # replace sole asterisk with paragraph divider
	      } else {
		$line =~ s/^\s*[*]\s*$/\n/o; # replace sole asterisk with empty line
	}
	$returnComment .= $line;
    }
}

    print STDERR "RESULTING COMMENT:\n$returnComment\nEOCOMMENT\n" if ($localDebug || $commentDumpDebug || $liteDebug);

    return $returnComment;
}

# /*!
#     @abstract
#         The top-level HeaderDoc comment processing code.
#     @discussion
#         Processes a HeaderDoc comment looking for top-level
#         (e.g. <code>\@function</code>) HeaderDoc tags.
#
#         This code was moved from the main
#         {@link //apple_ref/doc/header/headerDoc2HTML.pl headerDoc2HTML.pl}
#         tool so that it could be used as part of the test suite.
#
#     @param inHeader
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@header</code> tag.
#
#     @param inClass
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@class</code> tag.
#         
#     @param inInterface
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@interface</code> tag.
#         
#     @param inCPPHeader
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@language</code> tag
#         with a value of <code>c++</code>.
#         
#     @param inOCCHeader
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@language</code> tag
#         with a value of <code>objc</code>.
#         
#     @param inPerlScript
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@language</code> tag
#         with a value of <code>perl</code>.
#         
#     @param inShellScript
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@language</code> tag
#         with a value of <code>shell</code>.
#         
#     @param inPHPScript
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@language</code> tag
#         with a value of <code>php</code>.
#         
#     @param inJavaSource
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is
#         an <code>\@language</code> tag with a value of <code>java</code>
#         or <code>javascript</code>.
#         
#     @param inFunctionGroup
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@functiongroup</code> tag.
#         
#     @param inGroup
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@group</code> tag.
#         
#     @param inFunction
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@function</code> tag.
#         
#     @param inPDefine
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@define</code> tag, 2 if it contains an <code>\@defineblock</code> or
#         <code>\@definedblock</code> tag, or 0 if it contains neither.
#         
#     @param inTypedef
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@typedef</code> tag.
#         
#     @param inUnion
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@union</code> tag.
#         
#     @param inStruct
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@struct</code> tag.
#         
#     @param inConstant
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@constant</code> tag.
#         
#     @param inVar
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@var</code> tag.
#         
#     @param inEnum
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@enum</code> tag.
#         
#     @param inMethod
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@method</code> tag.
#         
#     @param inAvailabilityMacro
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag in this comment is an
#         <code>\@availabilitymacro</code> tag.
#         
#     @param inUnknown
#         Typically 0 at this point.  The returned version of this
#         value contains 1 if the top-level tag is absent.
#         
#     @param classType
#         The class type of the class that this comment is inside.
#         Used to determine handling of the <code>\@method</code> tag.
#         
#     @param line
#         The HeaderDoc comment block.
#
#     @param inputCounter
#         The line number of this line within the current
#         {@link //apple_ref/perl/cl/HeaderDoc::LineRange LineRange}
#         block.
#
#     @param blockOffset
#         The line number of the first line within the current
#         {@link //apple_ref/perl/cl/HeaderDoc::LineRange LineRange}
#         block relative to the start of the file.
#
#     @param fullpath
#         The full path of the file being parsed.
#
#     @param linenumdebug
#         Enables/disables printing debug information related to
#        line numbering.
#
#     @param localDebug
#         Enables/disables debugging.
#  */
sub processTopLevel
{
	my ($inHeader, $inClass, $inInterface, $inCPPHeader, $inOCCHeader, $inPerlScript, $inShellScript, $inPHPScript, $inJavaSource, $inFunctionGroup, $inGroup, $inFunction, $inPDefine, $inTypedef, $inUnion, $inStruct, $inConstant, $inVar, $inEnum, $inMethod, $inAvailabilityMacro, $inUnknown, $classType, $line, $inputCounter, $blockOffset, $fullpath, $linenumdebug, $localDebug) = @_;

	$localDebug = $localDebug || 0;

	if ($localDebug) {
		my $token = $line;
		$token =~ s/\s*(\/\*|\/\/)\!//s;
		$token =~ s/^\s*//s;
		$token =~ s/\s.*$//s;
		print STDERR "TOKEN: $token\n";
	}

	$line =~ s/^\s*//s;

				SWITCH: { # determine which type of comment we're in
					($line =~ /^\/\*!\s+\@file\s*/io) && do {$inHeader = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@header\s*/io) && do {$inHeader = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@framework\s*/io) && do {$inHeader = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@template\s*/io) && do {$inClass = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@interface\s*/io) && do {$inClass = 1; $inInterface = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@class\s*/io) && do {$inClass = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@protocol\s*/io) && do {$inClass = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@category\s*/io) && do {$inClass = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*c\+\+\s*/io) && do {$inCPPHeader = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*objc\s*/io) && do {$inOCCHeader = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*perl\s*/io) && do {$inPerlScript = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*shell\s*/io) && do {$inShellScript = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*php\s*/io) && do {$inPHPScript = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*java\s*/io) && do {$inJavaSource = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@language\s+.*javascript\s*/io) && do {$inJavaSource = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@functiongroup\s*/io) && do {$inFunctionGroup = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@group\s*/io) && do {$inGroup = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@name\s*/io) && do {$inGroup = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@function\s*/io) && do {$inFunction = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@availabilitymacro(\s+)/io) && do { $inAvailabilityMacro = 1; $inPDefine = 1; last SWITCH;};
					($line =~ /^\/\*!\s+\@methodgroup\s*/io) && do {$inFunctionGroup = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@method\s*/io) && do {
						    if ($classType eq "occ" ||
							$classType eq "intf" ||
							$classType eq "occCat") {
							    $inMethod = 1;last SWITCH;
						    } else {
							    $inFunction = 1;last SWITCH;
						    }
					};
					($line =~ /^\/\*!\s+\@typedef\s*/io) && do {$inTypedef = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@union\s*/io) && do {$inUnion = 1;$inStruct = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@struct\s*/io) && do {$inStruct = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@const(ant)?\s*/io) && do {$inConstant = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@var\s*/io) && do {$inVar = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@property\s*/io) && do {$inUnknown = 1;last SWITCH;};
					## ($line =~ /^\/\*!\s+\@internal\s*/io) && do {
						## # silently drop declaration.
						## last SWITCH;
					## };
					($line =~ /^\/\*!\s+\@define(d)?block\s*/io) && do {
							print STDERR "IN DEFINE BLOCK\n" if ($localDebug);
							$inPDefine = 2;
							last SWITCH;
						};
					($line =~ /^\/\*!\s+\@\/define(d)?block\s*/io) && do {
							print STDERR "OUT OF DEFINE BLOCK\n" if ($localDebug);
							$inPDefine = 0;
							last SWITCH;
						};
					($line =~ /^\/\*!\s+\@define(d)?\s*/io) && do {$inPDefine = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@lineref\s+(\d+)/io) && do {
						$blockOffset = $1 - $inputCounter;
						$inputCounter--;
						print STDERR "DECREMENTED INPUTCOUNTER [M4]\n" if ($HeaderDoc::inputCounterDebug);
						print STDERR "BLOCKOFFSET SET TO $blockOffset\n" if ($linenumdebug);
						last SWITCH;
					};
					($line =~ /^\/\*!\s+\@enum\s*/io) && do {$inEnum = 1;last SWITCH;};
					($line =~ /^\/\*!\s+\@serial(Data|Field|)\s+/io) && do {$inUnknown = 2;last SWITCH;};
					($line =~ /^\/\*!\s*[^\@\s]/io) && do {$inUnknown = 1;last SWITCH;};
					my $linenum = $inputCounter - 1 + $blockOffset;
					print STDERR "CHECKING VALIDFIELD FOR \"$line\".\n" if ($localDebug);;
					if (!validTag($line)) {
						warn "$fullpath:$linenum: warning: HeaderDoc comment is not of known type. Comment text is:\n";
						print STDERR "    $line\n";
					}
					$inUnknown = 1;
				} # end of SWITCH block

	return ($inHeader, $inClass, $inInterface, $inCPPHeader, $inOCCHeader, $inPerlScript, $inShellScript, $inPHPScript, $inJavaSource, $inFunctionGroup, $inGroup, $inFunction, $inPDefine, $inTypedef, $inUnion, $inStruct, $inConstant, $inVar, $inEnum, $inMethod, $inAvailabilityMacro, $inUnknown, $classType, $line, $inputCounter, $blockOffset, $fullpath, $linenumdebug, $localDebug);
}

# /*!
#     @abstract
#         Processes a comment for a header (<code>\@header</code> tag).
#     @param apiOwner
#         The Header object.
#     @param rootOutputDir
#         The output directory where this header's content should be
#         written.
#     @param fieldArrayRef
#         An array of fields in this comment.
#     @param lang
#         The programming language for this header.
#     @param debugging
#         Set to 1 to enable additional debug output.
#     @param reprocess_input
#         Usually 0 on entry.  Set to 1 by return if this comment
#         includes tags that would require rereading and reprocessing
#         the entire header (e.g. ignoring certain tokens).  Passed
#         by reference.
#  */ 
sub processHeaderComment {
    my $apiOwner = shift;
    my $rootOutputDir = shift;
    my $fieldArrayRef = shift;
    my $debugging = shift;
    my $reprocess_input_ref = shift;
    my $lang = shift;
    my $sublang = shift;

    my $reprocess_input = ${$reprocess_input_ref};
    my @fields = @$fieldArrayRef;
    my $linenum = $apiOwner->linenum();
    my $fullpath = $apiOwner->fullpath();
    my $localDebug = 0;

	foreach my $field (@fields) {
	    print STDERR "header field: |$field|\n" if ($localDebug);
		SWITCH: {
			($field =~ /^\/\*\!/o)&& do {last SWITCH;}; # ignore opening /*!
			(($lang eq "java") && ($field =~ /^\s*\/\*\*/o)) && do {last SWITCH;}; # ignore opening /**
			($field =~ /^see(also|)\s+/o) &&
				do {
					$apiOwner->see($field);
					last SWITCH;
				};
			 ($field =~ /^frameworkcopyright\s+/sio) && 
			    do {
				my $copy = $field;
				$copy =~ s/frameworkcopyright\s+//s;
				$copy =~ s/^\s+//sg;
				$copy =~ s/\s+$//sg;
				$apiOwner->attribute("Requested Copyright", $copy, 0, 1);
				# warn "FRAMEWORK COPYRIGHT: $copy\n";
				last SWITCH;
			    };
			 ($field =~ /^internal\s+/sio) && do {
				$apiOwner->isInternal(1);
				last SWITCH;
			    };
			 ($field =~ /^apiuid\s+/sio) && 
			    do {
				my $uid = $field;
				$uid =~ s/apiuid\s+//s;
				$apiOwner->requestedUID($uid);
				# warn "REQUESTED UID: $uid\n";
				last SWITCH;
			    };
			 ($field =~ /^frameworkuid\s+/sio) && 
			    do {
				my $uid = $field;
				$uid =~ s/frameworkuid\s+//s;
				$uid =~ s/\s+//sg;
				$apiOwner->attribute("Requested UID", $uid, 0, 1);
				# warn "FRAMEWORK UID: $uid\n";
				last SWITCH;
			    };
			 ($field =~ /^frameworkpath\s+/sio) && 
			    do {
				my $path = $field;
				$path =~ s/frameworkpath\s+//s;
				$path =~ s/\s+//sg;
				$path =~ s/\/$//sg;
				$apiOwner->attribute("Framework Path", $path, 0);
				# warn "FRAMEWORK PATH: $path\n";
				last SWITCH;
			    };
			 ($field =~ /^headerpath\s+/sio) && 
			    do {
				my $path = $field;
				$path =~ s/headerpath\s+//s;
				$path =~ s/\s+//sg;
				$path =~ s/\/$//sg;
				$apiOwner->attribute("Path To Headers", $path, 0);
				# warn "HEADER DIRECTORY PATH: $path\n";
				last SWITCH;
			    };
			(($field =~ /^header\s+/sio) ||
			 ($field =~ /^file\s+/sio) ||
			 ($field =~ /^framework\s+/sio)) && 
			    do {
			 	if ($field =~ s/^framework//sio) {
					$apiOwner->isFramework(1);
				} else {
					$field =~ s/^(header|file)//o;
				}
				
				my ($name, $disc, $is_nameline_disc);
				($name, $disc, $is_nameline_disc) = &getAPINameAndDisc($field, $lang); 
				# my $longname = $name; #." (".$apiOwner->name().")";
				# print STDERR "NAME: $name\n";
				# print STDERR "API-IF: ".$apiOwner->isFramework()."\n";
				if (length($name) && ((!$HeaderDoc::ignore_apiowner_names) || $apiOwner->isFramework())) {
					print STDERR "Setting header name to $name\n" if ($debugging);
					$apiOwner->name($name);
				}
				print STDERR "Discussion is:\n" if ($debugging);
				print STDERR "$disc\n" if ($debugging);
				if (length($disc)) {
					if ($is_nameline_disc) {
						$apiOwner->nameline_discussion($disc);
					} else {
						$apiOwner->discussion($disc);
					}
				}
				last SWITCH;
			};
	    ($field =~ s/^dependency(\s+)/$1/sio) && do {$apiOwner->attributelist("Dependencies", $field); last SWITCH;};

            ($field =~ s/^availability\s+//sio) && do {$apiOwner->availability($field); last SWITCH;};
	    ($field =~ s/^since\s+//sio) && do {$apiOwner->availability($field); last SWITCH;};
            ($field =~ s/^author\s+//sio) && do {$apiOwner->attribute("Author", $field, 0); last SWITCH;};
	    ($field =~ s/^version\s+//sio) && do {$apiOwner->attribute("Version", $field, 0); last SWITCH;};
            ($field =~ s/^deprecated\s+//sio) && do {$apiOwner->attribute("Deprecated", $field, 0); last SWITCH;};
            ($field =~ s/^version\s+//sio) && do {$apiOwner->attribute("Version", $field, 0); last SWITCH;};
	    ($field =~ s/^performance(\s+)/$1/sio) && do {$apiOwner->attribute("Performance", $field, 1); last SWITCH;};
	    ($field =~ s/^attribute\s+//sio) && do {
		    my ($attname, $attdisc, $is_nameline_disc) = &getAPINameAndDisc($field, $lang);
		    if (length($attname) && length($attdisc)) {
			$apiOwner->attribute($attname, $attdisc, 0);
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attribute\n";
		    }
		    last SWITCH;
		};
	    ($field =~ s/^indexgroup(\s+)/$1/sio) && do {$apiOwner->indexgroup($field); last SWITCH;};
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
			    $apiOwner->attributelist($name, $line);
			}
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attributelist\n";
		    }
		    last SWITCH;
		};
	    ($field =~ s/^attributeblock\s+//sio) && do {
		    my ($attname, $attdisc, $is_nameline_disc) = &getAPINameAndDisc($field, $lang);
		    if (length($attname) && length($attdisc)) {
			$apiOwner->attribute($attname, $attdisc, 1);
		    } else {
			warn "$fullpath:$linenum: warning: Missing name/discussion for attributeblock\n";
		    }
		    last SWITCH;
		};
            ($field =~ s/^updated\s+//sio) && do {$apiOwner->updated($field); last SWITCH;};
            ($field =~ s/^unsorted\s+//sio) && do {$apiOwner->unsorted(1); last SWITCH;};
            ($field =~ s/^abstract\s+//sio) && do {$apiOwner->abstract($field); last SWITCH;};
            ($field =~ s/^brief\s+//sio) && do {$apiOwner->abstract($field, 1); last SWITCH;};
            ($field =~ s/^description(\s+|$)//sio) && do {$apiOwner->discussion($field); last SWITCH;};
            ($field =~ s/^details(\s+|$)//sio) && do {$apiOwner->discussion($field); last SWITCH;};
            ($field =~ s/^discussion(\s+|$)//sio) && do {$apiOwner->discussion($field); last SWITCH;};
            ($field =~ s/^copyright\s+//sio) && do { $apiOwner->headerCopyrightOwner($field); last SWITCH;};
            ($field =~ s/^meta\s+//sio) && do {$apiOwner->HTMLmeta($field); last SWITCH;};
	    ($field =~ s/^language\s+//sio) && do {
		SWITCH {
		    ($field =~ /^\s*applescript\s*$/sio) && do { $sublang = "applescript"; last SWITCH; };
		    ($field =~ /^\s*c\s*$/sio) && do { $sublang = "C"; last SWITCH; };
		    ($field =~ /^\s*c\+\+\s*$/sio) && do { $sublang = "cpp"; last SWITCH; };
		    ($field =~ /^\s*csh\s*$/sio) && do { $sublang = "csh"; last SWITCH; };
		    ($field =~ /^\s*java\s*$/sio) && do { $sublang = "java"; last SWITCH; };
		    ($field =~ /^\s*javascript\s*$/sio) && do { $sublang = "javascript"; last SWITCH; };
		    ($field =~ /^\s*objc\s*$/sio) && do { $sublang = "occ"; last SWITCH; };
		    ($field =~ /^\s*pascal\s*$/sio) && do { $sublang = "pascal"; last SWITCH; };
		    ($field =~ /^\s*perl\s*$/sio) && do { $sublang = "perl"; last SWITCH; };
		    ($field =~ /^\s*php\s*$/sio) && do { $sublang = "php"; last SWITCH; };
		    ($field =~ /^\s*python\s*$/sio) && do { $sublang = "python"; last SWITCH; };
		    ($field =~ /^\s*ruby\s*$/sio) && do { $sublang = "ruby"; last SWITCH; };
		    ($field =~ /^\s*shell\s*$/sio) && do { $sublang = "shell"; last SWITCH; };
		    ($field =~ /^\s*tcl\s*$/sio) && do { $sublang = "tcl"; last SWITCH; };
			{
				warn("$fullpath:$linenum: warning: Unknown language $field in header comment\n");
			};
		};
	    };
            ($field =~ s/^CFBundleIdentifier\s+//sio) && do {$apiOwner->attribute("CFBundleIdentifier", $field, 0); last SWITCH;};
            ($field =~ s/^related\s+//sio) && do {$apiOwner->attributelist("Related Headers", $field); last SWITCH;};
	    ($field =~ s/^security(\s+)/$1/sio) && do {$apiOwner->attribute("Security", $field, 1); last SWITCH;};
            ($field =~ s/^(compiler|)flag\s+//sio) && do {$apiOwner->attributelist("Compiler Flags", $field); last SWITCH;};
            ($field =~ s/^preprocinfo\s+//sio) && do {$apiOwner->attribute("Preprocessor Behavior", $field, 1); last SWITCH;};
	    ($field =~ s/^whyinclude\s+//sio) && do {$apiOwner->attribute("Reason to Include", $field, 1); last SWITCH;};
            ($field =~ s/^ignorefuncmacro\s+//sio) && do { $field =~ s/\n//smgo; $field =~ s/<br\s*\/?>//sgo; $field =~ s/^\s*//sgo; $field =~ s/\s*$//sgo;
		$HeaderDoc::perHeaderIgnoreFuncMacros{$field} = $field;
		if (!($reprocess_input)) {$reprocess_input = 1;} print STDERR "ignoring $field" if ($localDebug); last SWITCH;};
	    ($field =~ s/^namespace(\s+)/$1/sio) && do {$apiOwner->namespace($field); last SWITCH;};
	    ($field =~ s/^charset(\s+)/$1/sio) && do {$apiOwner->encoding($field); last SWITCH;};
	    ($field =~ s/^encoding(\s+)/$1/sio) && do {$apiOwner->encoding($field); last SWITCH;};
            ($field =~ s/^ignore\s+//sio) && do { $field =~ s/\n//smgo; $field =~ s/<br\s*\/?>//sgo;$field =~ s/^\s*//sgo; $field =~ s/\s*$//sgo;
		# push(@HeaderDoc::perHeaderIgnorePrefixes, $field);
		$HeaderDoc::perHeaderIgnorePrefixes{$field} = $field;
		if (!($reprocess_input)) {$reprocess_input = 1;} print STDERR "ignoring $field" if ($localDebug); last SWITCH;};

            # warn("$fullpath:$linenum: warning: Unknown field in header comment: $field\n");
	    warn("$fullpath:$linenum: warning: Unknown field (\@$field) in header comment.\n");
		}
	}

	return ($lang, $sublang);
}

# /*! @group File Functions */

# /*!
#     @abstract
#         Returns the base filename, the language, and the initial
#         language dialect based on a filename.
#     @param filename
#         The filename.
#     @result
#         Returns ($rootFileName, $lang, $sublang).
#  */
sub getLangAndSubLangFromFilename
{
    my $filename = shift;
    my $rootFileName;
    my $lang = "";
    my $sublang = "";

    ($rootFileName = $filename) =~ s/\.(cpp|c|C|h|m|M|i|hdoc|php|php\d|class|pas|p|java|j|jav|jsp|js|jscript|html|shtml|dhtml|htm|shtm|dhtm|pl|pm|bsh|csh|ksh|sh|defs|idl|conf|rb|rbx|rhtml|ruby|py|pyw|applescript|scpt|tcl)$/_$1/;
    if ($filename =~ /\.(php|php\d|class)$/) {
	$lang = "php";
	$sublang = "php";
    } elsif ($filename =~ /\.c$/) {
	# treat a C program similar to PHP, since it could contain k&r-style declarations
	$lang = "Csource";
	$sublang = "Csource";
    } elsif ($filename =~ /\.(C|cpp)$/) {
	# Don't allow K&R C declarations in C++ source code.
	# Set C++ flags from the very beginning.
	$lang = "C";
	$sublang = "cpp";
    } elsif ($filename =~ /\.(m|M)$/) {
	# Don't allow K&R C declarations in ObjC source code.
	# Set C++ flags from the very beginning.
	$lang = "C";
	$sublang = "occ";
    } elsif ($filename =~ /\.(s|d|)htm(l?)$/i) {
	$lang = "java";
	$sublang = "javascript";
    } elsif ($filename =~ /\.j(s|sp|script)$/i) {
	$lang = "java";
	$sublang = "javascript";
    } elsif ($filename =~ /\.j(ava|av|)$/i) {
	$lang = "java";
	$sublang = "java";
    } elsif ($filename =~ /\.p(as|)$/i) {
	$lang = "pascal";
	$sublang = "pascal";
    } elsif ($filename =~ /\.p(l|m)$/i) {
	$lang = "perl";
	$sublang = "perl";
    } elsif ($filename =~ /\.(c|b|k|)sh$/i ||
             $filename =~ /\.conf$/i) {
	$lang = "shell";
	if ($filename =~ /\.csh$/i) {
		$sublang = "csh";
	} else {
		$sublang = "shell";
	}
    } else {
	$lang = "C";
	$sublang = "C";
    }

    if ($filename =~ /\.(rb|rbx|rhtml|ruby)$/o) { 
	$lang = "ruby";
	$sublang = "ruby";
    }

    if ($filename =~ /\.(applescript|scpt)$/o) { 
	$lang = "applescript";
	$sublang = "applescript";
    }

    if ($filename =~ /\.(tcl)$/o) { 
	$lang = "tcl";
	$sublang = "tcl";
    }

    if ($filename =~ /\.(py|pyw)$/o) { 
	$lang = "python";
	$sublang = "python";
    }

    if ($filename =~ /\.idl$/o) { 
	$lang = "C";
	$sublang = "IDL";
    }

    if ($filename =~ /\.defs$/o) { 
	$lang = "C";
	$sublang = "MIG";
    }

    $HeaderDoc::lang = $lang;
    $HeaderDoc::sublang = $sublang;

    return ($rootFileName, $lang, $sublang);
}

# /*!
#     @abstract
#         Splits the input files into multiple text blocks
#     @param rawLineArrayRef
#         A reference to an array of lines.
#     @param lang
#         The current programming language.
#     @param sublamg
#         The current programming language dialect (e.g. <code>cpp</code> for
#         C++).
#     @discussion
#         This function does heavy text manipuation and is
#         the prime suspect in cases of missing text in comments, odd
#         spacing problems, and so on.
#   */
sub getLineArrays {

    my $classDebug = 0;
    my $localDebug = 0;
    my $blockDebug = 0;
    my $dumpOnly = 0;
    my $rawLineArrayRef = shift;
    my @arrayOfLineArrays = ();
    my @generalHeaderLines = ();
    my @classStack = ();

    my $lang = shift;
    my $sublang = shift;

    my $inputCounter = 0;
    my $lastArrayIndex = @{$rawLineArrayRef};
    my $line = "";
    my $className = "";
    my $classType = "";
    my $isshell = 0;

    if ($lang eq "shell" || $lang eq "perl" || $lang eq "tcl") {
	$isshell = 1;
    }
    # my ($sotemplate, $eotemplate, $operator, $soc, $eoc, $ilc, $ilc_b, $sofunction,
	# $soprocedure, $sopreproc, $lbrace, $rbrace, $unionname, $structname,
	# $enumname,
	# $typedefname, $varname, $constname, $structisbrace, $macronamesref,
	# $classregexp, $classbraceregexp, $classclosebraceregexp, $accessregexp,
	# $requiredregexp, $propname, $objcdynamicname, $objcsynthesizename, $moduleregexp, $definename,
	# $functionisbrace, $classisbrace, $lbraceconditionalre, $lbraceunconditionalre, $assignmentwithcolon,
	# $labelregexp, $parmswithcurlybraces, $superclasseswithcurlybraces,
	# $soconstructor) = parseTokens($lang, $sublang);
    my %parseTokens = %{parseTokens($lang, $sublang)};

    # my $socquot = $HeaderDoc::socquot;
    # my $eocquot = $HeaderDoc::eocquot;
    # my $ilcquot = $HeaderDoc::ilcquot;

    my $soc = $parseTokens{soc};
    my $ilc = $parseTokens{ilc};
    # my $ilc_b = $parseTokens{ilc_b};
    my $eoc = $parseTokens{eoc};

    if ($isshell) {
	$eoc = "*/";
	# $eocquot = $eoc;
	# $eocquot =~ s/(\W)/\\$1/sg;
    }

    while ($inputCounter <= $lastArrayIndex) {
        $line = ${$rawLineArrayRef}[$inputCounter];

	# inputCounter should always point to the current line being processed

        # we're entering a headerdoc comment--look ahead for @class tag
	my $startline = $inputCounter;

	print STDERR "MYLINE: \"$line\"\n" if ($localDebug);

	print STDERR "SOC: $soc\n" if ($localDebug);
	print STDERR "EOC: $eoc\n" if ($localDebug);
	print STDERR "ISSHELL: $isshell\n" if ($localDebug);

		# No reason to support ilc_b here.  It is used for # comment starts in PHP, but is not
		# supported for HeaderDoc comments to avoid collisions with the #!/usr/bin/perl shell magic.
		if (($isshell && $line =~ /^\s*\Q$ilc\E\s*\/\*\!(.*)$/s) ||
		    (!$isshell && 
		      (($line =~ /^\s*\Q$soc\E\!/s) ||
		       (($lang eq "java" || $HeaderDoc::parse_javadoc) &&
			($line =~ /^\s*\Q$soc\E\*[^*]/s)))))  {  # entering headerDoc comment
			print STDERR "inHDComment\n" if ($localDebug);
			my $headerDocComment = "";
			my @headerDocCommentLinesArray = ();
			print STDERR "RESET headerDocCommentLinesArray\n" if ($localDebug);
			{
				local $^W = 0;  # turn off warnings since -w is overly sensitive here
				my $in_textblock = 0; my $in_pre = 0;
				my $leaving_textblock = 0; my $leaving_pre = 0;
				my $nextclosecurlybrace = "";
				while (($line !~ /\Q$eoc\E/s) && ($inputCounter <= $lastArrayIndex)) {
				    # print "POINTA: $line\n";
				    if ($nextclosecurlybrace) {
					$line =~ s/}/$nextclosecurlybrace/s;
					$nextclosecurlybrace = "";
				    }
				    if ($line =~ s/\{\s*\@linkdoc\s*([^}]*)$/<i>\@link $1/s) {
					$nextclosecurlybrace="\@/link</i>";
				    } elsif ($line =~ s/\{\s*\@linkplain\s*([^}]*)$/\@link $1/s) {
					$nextclosecurlybrace="\@/link";
				    } elsif ($line =~ s/\{\s*\@link\s*([^}]*)$/<code>\@link $1/s) {
					$nextclosecurlybrace = "\@/link</code>";
				    } elsif ($line =~ s/\{\s*\@docroot\s*([^}]*)$/\\\@\\\@docroot $1/sgio) {
					$nextclosecurlybrace = "";
				    } elsif ($line =~ s/\{\@value\s*([^}]*)$/\@value $1/sgio) {
					$nextclosecurlybrace = "";
				    } elsif ($line =~ s/\{\@inheritDoc\s*([^}]*)$/\@inheritDoc $1/s) {
					$nextclosecurlybrace = "";
				    }
				    if ($isshell) {
					# print STDERR "PREPHASE LINE $line\n";
					$line =~ s/^[ \t]*#//s;
					# print STDERR "NOW $line\n";
				    }
				    # print "LINKLINE: $line\n";
				    # if ($lang eq "java" || $HeaderDoc::parse_javadoc) {
					### $line =~ s/\@ref\s+(\w+)\s*(\(\))?/<code>\@link $1\@\/link<\/code>/sgio;
					### $line =~ s/\{\s*\@linkdoc\s+(.*?)\}/<i>\@link $1\@\/link<\/i>/sgio;
					### $line =~ s/\{\s*\@linkplain\s+(.*?)\}/\@link $1\@\/link/sgio;
					### $line =~ s/\{\s*\@link\s+(.*?)\}/<code>\@link $1\@\/link<\/code>/sgio;
					### $line =~ s/\{\s*\@docroot\s*\}/\\\@\\\@docroot/sgio;
					### # if ($line =~ /value/o) { warn "line was: $line\n"; }
					### $line =~ s/\{\@value\}/\@value/sgio;
					### $line =~ s/\{\@inheritDoc\}/\@inheritDoc/sgio;
					$line = doxyTagFilter($line);
					# if ($line =~ /value/o) { warn "line now: $line\n"; }
				    # }
				    $line =~ s/([^\\])\@docroot/$1\\\@\\\@docroot/sgi;
				    my $templine = $line;
				    # print STDERR "HERE: $templine\n";

				    $leaving_textblock = 0; $leaving_pre = 0;
				    while ($templine =~ s/\@textblock//sio) { $in_textblock++; }
				    while ($templine =~ s/\@\/textblock//sio) { $in_textblock--; $leaving_textblock = 1;}
				    while ($templine =~ s/<pre>//sio) { $in_pre++; }
				    while ($templine =~ s/<\/pre>//sio) { $in_pre--; $leaving_pre = 1; }

				    # $headerDocComment .= $line;
				    my %lineentry = ();
				    $lineentry{INTEXTBLOCK} = $in_textblock;
				    $lineentry{INPRE} = $in_pre;
				    $lineentry{LEAVINGTEXTBLOCK} = $leaving_textblock;
				    $lineentry{LEAVINGPRE} = $leaving_pre;
				    $lineentry{LINE} = $line;

				    my $ref = \%lineentry;

				    print STDERR "PUSH[1] $line ($ref)\n" if ($localDebug);

				    push(@headerDocCommentLinesArray, $ref);

				    # warnHDComment($rawLineArrayRef, $inputCounter, 0, $lang, "HeaderDoc comment", "32", \%parseTokens);
			            $line = ${$rawLineArrayRef}[++$inputCounter];
				    warnHDComment($rawLineArrayRef, $inputCounter, 0, $lang, "HeaderDoc comment", "33", \%parseTokens);
				}
				if ($isshell) {
				    # $line =~ s/^\s*#//s;
				    $line =~ s/^[ \t]*#//s;
				}
				# print "LINKLINE2: $line\n";
				### $line =~ s/\{\s*\@linkdoc\s+(.*?)\}/<i>\@link $1\@\/link<\/i>/sgio;
				### $line =~ s/\{\s*\@linkplain\s+(.*?)\}/\@link $1\@\/link/sgio;
				### $line =~ s/\{\s*\@link\s+(.*?)\}/<code>\@link $1\@\/link<\/code>/sgio;
				### # $line =~ s/\{\s*\@docroot\s*\}/\\\@\\\@docroot/sgio;
				### # if ($line =~ /value/so) { warn "line was: $line\n"; }
				### $line =~ s/\{\@value\}/\@value/sgio;
				### $line =~ s/\{\@inheritDoc\}/\@inheritDoc/sgio;
				### $line =~ s/\{\s*\@docroot\s*\}/\\\@\\\@docroot/sgo;
				$line = doxyTagFilter($line);

				my %lineentry = ();
				$lineentry{INTEXTBLOCK} = $in_textblock;
				$lineentry{INPRE} = $in_pre;
				$lineentry{LINE} = $line;
				print STDERR "PUSH[2] $line\n" if ($localDebug);

				push(@headerDocCommentLinesArray, \%lineentry);
				# $headerDocComment .= $line ;

				# warnHDComment($rawLineArrayRef, $inputCounter, 0, $lang, "HeaderDoc comment", "34", \%parseTokens);
				$line = ${$rawLineArrayRef}[++$inputCounter];

				if (0) {
					print STDERR "\n\nCOMMENT DUMP:\n";
					for my $lineToPrintRef (@headerDocCommentLinesArray) {
						my %lineToPrint = %{$lineToPrintRef};
						print STDERR "LINE: ".$lineToPrint{LINE}."\n";
					}
					print STDERR "END COMMENT DUMP\n\n\n";
				}
				$headerDocComment = filterHeaderDocComment(\@headerDocCommentLinesArray, $lang, $sublang, $inputCounter);
				# print STDERR "HDC: $headerDocComment\n";
				my $hasTrailingContent = 0;
				if ($line =~ /\Q$eoc\E.*\S/s) {
					$hasTrailingContent = 1;
				}
				# print STDERR "HDC: $headerDocComment\n";

				# A HeaderDoc comment block immediately
				# after another one can be legal after some
				# tag types (e.g. @language, @header).
				# We'll postpone this check until the
				# actual parsing.
				# 
				if ((!emptyHDok($headerDocComment)) && (!$hasTrailingContent)) {
					my $emptyDebug = 0;
					warn "curline is $line" if ($emptyDebug);
					print STDERR "HEADERDOC COMMENT WAS $headerDocComment\n" if ($localDebug);
					warnHDComment($rawLineArrayRef, $inputCounter, 0, $lang, "HeaderDoc comment", "35", \%parseTokens, $headerDocComment);
				}
			} # Unimportant block.
			if ($localDebug) { print STDERR "first line after $headerDocComment is $line\n"; }

			if ($isshell) {
				$headerDocComment = "#".$headerDocComment;
				if ($headerDocComment =~ s/(\r\n|\n\r|\n|\r)/$1#/sg) {
					$headerDocComment =~ s/(\r\n|\n\r|\n|\r)#$/$1/sg;
				}
			}
			push(@generalHeaderLines, $headerDocComment);
			$inputCounter--;
			print STDERR "DECREMENTED INPUTCOUNTER [M10]\n" if ($HeaderDoc::inputCounterDebug);
		} else {
			push (@generalHeaderLines, $line); print STDERR "PUSHED $line\n" if ($blockDebug);
		}
		$inputCounter++;
		print STDERR "INCREMENTED INPUTCOUNTER [M11]\n" if ($HeaderDoc::inputCounterDebug);
	     }

	if ($localDebug || $dumpOnly) {
		print STDERR "DUMPING LINES.\n";
		for my $line (@generalHeaderLines) {
			print STDERR "$line";
		}
		print STDERR "DONE DUMPING LINES.\n";
	}

	push (@arrayOfLineArrays, \@generalHeaderLines);
	return @arrayOfLineArrays;
}

# /*! @group Test Helpers
#     @abstract
#         Functions used by the test framework.
#     @discussion
#         
#  */


my %uid_list_by_uid_0 = ();
my %uid_list_by_uid_1 = ();
my %uid_list_0 = ();
my %uid_list_1 = ();
my %uid_conflict_0 = ();
my %uid_conflict_1 = ();
my %uid_candidates_0 = ();
my %uid_candidates_1 = ();
my %objid_hash_0 = ();
my %objid_hash_1 = ();

# /*!
#     @abstract
#         Backs up the hashes in a temporary variable.
#     @param alldecs
#         Pass 1 when testing alldecs, 0 otherwise.
#     @discussion
#         Used during the test process so that we can
#         store this information and retrieve it after
#         the tests are run.
#  */
sub savehashes
{
	my $alldecs = shift;

	if ($alldecs) {
		%uid_list_by_uid_0 = %uid_list_by_uid;
		%uid_list_0 = %uid_list;
		%uid_conflict_0 = %uid_conflict;
		%uid_candidates_0 = %uid_candidates;
		%objid_hash_0 = %objid_hash;
	} else {
		%uid_list_by_uid_1 = %uid_list_by_uid;
		%uid_list_1 = %uid_list;
		%uid_conflict_1 = %uid_conflict;
		%uid_candidates_1 = %uid_candidates;
		%objid_hash_1 = %objid_hash;
	}
}

# /*!
#     @abstract
#         Restores the hashes backed up with {@link savehashes}.
#     @param alldecs
#         Pass 1 when testing alldecs, 0 otherwise.
#     @discussion
#         Used during the test process so that we can
#         store this information and retrieve it after
#         the tests are run.
#  */
sub loadhashes
{
	my $alldecs = shift;

	if ($alldecs) {
		%uid_list_by_uid = %uid_list_by_uid_0;
		%uid_list = %uid_list_0;
		%uid_conflict = %uid_conflict_0;
		%uid_candidates = %uid_candidates_0;
		%objid_hash = %objid_hash_0;
	} else {
		%uid_list_by_uid = %uid_list_by_uid_1;
		%uid_list = %uid_list_1;
		%uid_conflict = %uid_conflict_1;
		%uid_candidates = %uid_candidates_1;
		%objid_hash = %objid_hash_1;
	}
}

# /*! @group Path Functions */

# /*!
#     @abstract
#         Converts a current-directory-relative path to an absolute path.
#     @param filename
#         The original path.
#  */
sub getAbsPath
{
	my $filename = shift;
	if ($filename =~ /^\Q$pathSeparator\E/) {
		return $filename;
	}
	return cwd().$pathSeparator.$filename;
}

# /*! @group Parser helpers */

# /*!
#     @abstract
#         Returns whether the curent language allows the <code>-E</code>
#         (allow everything) flag.
#     @param lang
#         The current programming language.
#     @param sublang
#         The current programming language variant (e.g.
#         <code>cpp</code> for C++).
#  */
sub allow_everything
{
	my $lang = shift;
	my $sublang = shift;

	if ($lang eq "C") {
		# sublang :
		# C, occ, cpp,
		# php, IDL, MIG

		return 1;
	} elsif ($lang =~ /Csource/) {

		return 1;
	} elsif ($lang eq "java") {
		if ($sublang ne "javascript") {
			return 1;
		}
	} elsif ($lang eq "pascal") {
		return 1; # Maybe
	} elsif ($lang eq "perl") {
		return 1; # Maybe
	} elsif ($lang eq "tcl") {
		if ($HeaderDoc::running_test) { return 1; }
		return 0; # Maybe
	}

	return 0;
}

# /*! @group HTML helpers */

# /*!
#     @abstract
#         Converts non-UTF-8 encoded data to UTF-8.
#     @param string
#         The string to convert.
#  */
sub reencodeInUTF8
{
	my $string = shift;
	my $srcencoding = shift;

	my $decoded = decode($srcencoding, $string);
	return encode("utf8", $decoded);
}

# /*! @group Availability Macro Functions */

# /*!
#     @abstract
#         Get availability macro information from a file.
#     @param filename
#         The filename to read macros from.  This file normally lives
#         in the HeaderDoc modules directory.
#     @param quiet
#         Set to 1 to suppress normal output.
#  */
sub getAvailabilityMacros
{
    my $filename = shift;
    my $quiet = shift;

    print STDERR "Reading availability macros from \"$filename\".\n" if (!$quiet);

    my @availabilitylist = ();

    if (-f $filename) {
	my ($encoding, $arrayref) = linesFromFile($filename);
	@availabilitylist = @{$arrayref}
    } else {
	warn "Can't open $filename for availability macros\n";
    }

    foreach my $line (@availabilitylist) {
	my ($token, $description, $has_args) = split(/\t/, $line, 3);
	# print STDERR "TOKEN: $token DESC: $description HA: $has_args\n";
	# print STDERR "Adding avail for $line\n";
	addAvailabilityMacro($token, $description, $has_args);
    }
}

# /*!
#     @abstract Returns whether the availability macro is one of the
#               standard OS-version-based macros.
#  */
sub isStandardAvailability
{
    my $token = shift;

    # e.g. AVAILABLE_MAC_OS_X_VERSION_10_7_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_8
    # becomes "Introduced in Mac OS X v10.7, but later deprecated in Mac OS X v10.8."
    if ($token =~ /AVAILABLE_MAC_OS_X_VERSION_(\d+)_(\d+)_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_(\d+)_(\d+)/) {
	my ($majorintro, $minorintro, $majordep, $minordep) = ($1, $2, $3, $4);
	return "Introduced in Mac OS X v$majorintro.$minorintro, but later deprecated in Mac OS X v$majordep.$minordep."
    }

    # e.g. AVAILABLE_MAC_OS_X_VERSION_10_8_AND_LATER
    # becomes "Introduced in Mac OS X v10.8."
    if ($token =~ /AVAILABLE_MAC_OS_X_VERSION_(\d+)_(\d+)_AND_LATER/) {
	my ($major, $minor) = ($1, $2);
	return "Introduced in Mac OS X v$major.$minor.";
    }

    # e.g. DEPRECATED_IN_MAC_OS_X_VERSION_10_8_AND_LATER
    # becomes "Deprecated in Mac OS X v10.8."
    if ($token =~ /DEPRECATED_IN_MAC_OS_X_VERSION_(\d+)_(\d+)_AND_LATER/) {
	my ($major, $minor) = ($1, $2);
	return "Deprecated in Mac OS X v$major.$minor.";
    }

    return "";
}

# /*! @group Debugging Functions */

# /*!
#     @abstract
#         Prints a reference to an array of fields for debugging.
#     @param fieldref
#         The array reference.
#  */
sub printFields
{
	my $fieldref = shift;
	my @fields = @{$fieldref};

	my $first = 1;
	print STDERR "FIELDS:\n";
	foreach my $field (@fields) {
		if ($first) { print STDERR "FIELD: $field\n"; $first = 0; }
		else        { print STDERR "FIELD: \@$field\n"; }
	}
	print STDERR "END OF FIELDS\n";
}

# /*! @group XML Helpers */

# /*!
#     @abstract
#         Strips HTML tags from a block of HTML.
#     @param html
#         The source HTML.
#  */
sub stripTags
{
	my $html = shift;

# return $html;

	eval {
		require HTML::FormatText;
	};
	if ($@) {
		die("Using the -d flag requires the HTML::FormatText module.\nTo install it, type:\n    sudo cpan HTML::FormatText\n");
	}
	eval {
		require HTML::TreeBuilder;
	};
	if ($@) {
		die("Using the -d flag requires the HTML::TreeBuilder module.\nTo install it, type:\n    sudo cpan HTML::TreeBuilder\n");
	}

	# Must append newline or else TreeBuilder loses the last word
	# when fed plain text.  Ewww.
	my $tree = HTML::TreeBuilder->new->parse($html."\n");
	my $formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);
	my $text = $formatter->format($tree);
	$text =~ s/^[\n\r]*//s;
	$text =~ s/[\n\r]*$//s;

	$text =~ s/&/&amp;/g;
	$text =~ s/</&lt;/g;
	$text =~ s/>/&gt;/g;

# Check to see if the content is valid UTF-8.  If so, return it.
# If not, assume iso-8859-1 and translate it.

	my $decoder = guess_prioritized_encoding($text, "tag stripping");

	if ((!$decoder) || $decoder =~ /utf8/) {
		return $text;
	}

	# print "OLDHTML: $html\nNEWTEXT: $text\n";
	return reencodeInUTF8($text, $decoder->name);
}

################## Sorting Functions ###################################

# /*! @group Sorting Functions
#     @abstract
#         Functions for sorting objects.
#     @discussion
#         
#  */

# /*! @abstract
#         Sort helper for sorting by name.
#     @param obj1
#         The first object to compare.
#     @param obj2
#         The second object to compare.
#  */
sub objName($$) { # used for sorting
   my $obj1 = shift;
   my $obj2 = shift;
   return (lc($obj1->name()) cmp lc($obj2->name()));
}

# /*! @abstract
#         Sort helper for sorting by linkage state (unused).
#     @param obj1
#         The first object to compare.
#     @param obj2
#         The second object to compare.
#  */
sub byLinkage($$) { # used for sorting
    my $obj1 = shift;
    my $obj2 = shift;
    return (lc($obj1->linkageState()) cmp lc($obj2->linkageState()));
}

# /*! @abstract
#         Sort helper for sorting by access control (public/private).
#     @param obj1
#         The first object to compare.
#     @param obj2
#         The second object to compare.
#  */
sub byAccessControl($$) { # used for sorting
    my $obj1 = shift;
    my $obj2 = shift;
    return (lc($obj1->accessControl()) cmp lc($obj2->accessControl()));
}

# /*! @abstract
#         Sort helper for sorting by group.
#     @param obj1
#         The first object to compare.
#     @param obj2
#         The second object to compare.
#  */
sub objGroup($$) { # used for sorting
    my $obj1 = shift;
    my $obj2 = shift;

    return (lc($obj1->group()) cmp lc($obj2->group()));
}

# /*! @abstract
#         Sort helper for sorting by linkage state (unused) and object name.
#     @param obj1
#         The first object to compare.
#     @param obj2
#         The second object to compare.
#  */
sub linkageAndObjName($$) { # used for sorting
   my $obj1 = shift;
   my $obj2 = shift;
   my $linkAndName1 = $obj1->linkageState() . $obj1->name();
   my $linkAndName2 = $obj2->linkageState() . $obj2->name();
   if ($HeaderDoc::sort_entries) {
        return (lc($linkAndName1) cmp lc($linkAndName2));
   } else {
        return byLinkage($obj1, $obj2);
   }
}

# /*!
#     @abstract
#         Sort helper for sorting objects by method type.
#     @param obj1
#         Object 1.
#     @param obj2
#         Object 2.
#  */
sub byMethodType($$) { # used for sorting
   my $obj1 = shift;
   my $obj2 = shift;
   if ($HeaderDoc::sort_entries) {
	return (lc($obj1->isInstanceMethod()) cmp lc($obj2->isInstanceMethod()));
   } else {
	return (1 cmp 2);
   }
}

# /*! 
#     @abstract
#         Splits a string on the first paragraph (blank line).
#     @param string
#         The string to split.
#     @result
#         Returns the first part, the rest, and whether the split was successful (1) or not (0).
#  */
sub splitOnPara
{
    my $string = shift;

    if ($string =~ /\n\n/) {
	my ($fieldpart, $rest) = split(/\n\n/, $string, 2);
	return ($fieldpart, $rest, 1);
    }

    return ($string, "", 0);
}

# /*!
#     @abstract
#         Returns the top entry in a stack array without removing it
#         from the stack.
#     @param ref
#         A reference to the stack array.
#     @discussion
#         This is a trivial function that returns a look at the top of a stack.
#         This seems like it should be part of the language.  If there is an
#         equivalent, this should be dropped.
# */
sub peek
{
	my $ref = shift;
	my @stack = @{$ref};
	my $tos = pop(@stack);
	push(@stack, $tos);

	return $tos;
}

# /*!
#     @abstract
#         Prints UID caches for debugging purposes.
#  */
sub dumpCaches
{

    print STDERR "DUMPING uid_list_by_uid:\n";
    foreach my $key (keys %uid_list_by_uid) {
	print STDERR "    $key => ".$uid_list_by_uid{$key}."\n";
    }

    print STDERR "DUMPING uid_list:\n";
    foreach my $key (keys %uid_list) {
	print STDERR "    $key => ".$uid_list{$key}."\n";
    }

    print STDERR "DUMPING uid_conflict:\n";
    foreach my $key (keys %uid_conflict) {
	print STDERR "    $key => ".$uid_conflict{$key}."\n";
    }

    print STDERR "DUMPING uid_candidates:\n";
    foreach my $key (keys %uid_candidates) {
	print STDERR "    $key => \n";
	my @values = @{$uid_candidates{$key}};
	foreach my $value (@values) {
		print STDERR "        ".$value."\n";
	}
    }
}

# /*!
#     @abstract
#         Returns the default encoding from your environment.
#     @discussion
#         Used to determine the encoding of time and date stamps
#         returned by calls to POSIX strtime and friends.
#  */
sub getDefaultEncoding
{
    my $current_encoding = $ENV{"LC_ALL"};
    if (!$current_encoding) {
	$current_encoding = $ENV{"LC_TIME"};
    }
    if (!$current_encoding) {
	$current_encoding = $ENV{"LANG"};
    }

    if ($current_encoding && ($current_encoding =~ /\./)) {
	$current_encoding =~ s/^.*\.//g;
    } else {
	# The OS doesn't provide an encoding.  Guess.

	warn("No default encoding.  Guessing.  If date formats are wrong, try\nspecifying an appropriate value in the LANG environment variable.\n");

	$current_encoding = "ISO8859-1";
    }

    return $current_encoding;
}

# /*!
#     @abstract
#         Replaces errant &lt;link&gt; tags with <code>\@link</code> tags.
#     @discussion
#         We ran into a nasty bug where somebody put in &lt;link&lt;
#         and &lt;/link&lt; instead of <code>\@link</code>.  For some reason,
#         xmllint --html --xmlout fails to close the tag properly
#         (as with other normally-unclosed HTML tags like &lt;hr&gr;)
#         which results in broken XML (not to mention that this wasn't
#         the desired behavior).  This function fixes that problem.
#
#         Note that xmllint is no longer trusted for tag fixing, but
#         this code does no harm, so it was not removed.  The right
#         way to include style sheets in HeaderDoc HTML is through
#         configuration files, not by embedding the HTML in a
#         HeaderDoc comment.
#  */
sub filterHTMLLinks
{
    my $field = shift;

    my @tags = split(/(<)/, $field);
    my $first = 1;
    my $newfield = "";

    my $inlink = 0;
    foreach my $tag (@tags) {
	if ($first) {
		$first = 0;
		$newfield = $tag;
	} else {
		if ($tag =~ /^link(?:\s[^>]*)?>(.*)$/) {
			my $origtarget = $1;
			$origtarget =~ s/^\s*//;
			$origtarget =~ s/\s*$//;
			if ($inlink) {
				warn("Nested <link> tag found.  Closing.\n");
				$newfield .= "</hd_link>";
			}
			my $target = nameFromAPIRef($origtarget);
			$tag =~ s/link.*?>/hd_link posstarget="$target">/s;
			$inlink = 1;
		} elsif ($tag =~ /^\/link(\s|\>)/) {
			$tag =~ s/\/link.*?>/\/hd_link>/s;
			$inlink = 0;
		}
		$newfield .= $tag;
	}
    }
    if ($inlink) {
	warn("Unterminated <link> found.  Closing.\n");
	$newfield .= "}";
    }

    if ($field ne $newfield) {
	warn("WARNING: The syntax <link>...</link> is not supported HeaderDoc Markup.\nInstead, use {\@link ... }\n\n");
    }

    return $newfield;
}

# /*!
#     @abstract
#         Used for stripping the leading '#' off the beginning of every line.
#     @discussion
#         This could probably be done with a couple of regular expressions, but
#         the filter code is tricky enough without making it even less readable.
# */
sub stripLeading
{
    my $string = shift;
    my $token = shift;

    # print STDERR "stripLeading: $string\n";
    # print STDERR "token: $token\n";

    my @lines = split(/(\r\n|\n\r|\n|\r)/, $string);

    my $result = "";
    foreach my $line (@lines) {
	$line =~ s/^*\Q$token\E//s;
	$result .= $line;
    }

    # print STDERR "RESULT: $result\n";
    return $result;
}

# /*!
#     @abstract
#         Takes an API reference marker and returns the
#         name in a suitable form.
#     @discussion
#         If HeaderDoc::nameFromAPIRefReturnsOnlyName is set,
#         returns the name by itself.  Otherwise, the format
#         depends on the language of the API symbol.
#
#         For example, if the API reference is of type "cpp",
#         this function returns className::methodName for
#         methods within a class.
#
#         Note: for now, the above is a lie.  It just
#         returns the name.
#  */
sub nameFromAPIRef
{
    my $name = shift;

    if ($name !~ /^\/\//) { return $name; }

    my @parts = split(/\//, $name);

    my $symbol_lang = $parts[3];
    my $symbol_type = $parts[4];
    my $field1 = $parts[5]; # First field after symbol type.
    my $field2 = $parts[6];
    my $field3 = $parts[7];
    my $field4 = $parts[8];
    my $field5 = $parts[9];
    my $field6 = $parts[10];

    # C++ scoped functions with prototype
    if (($symbol_type eq "func") && $field2) {
	return $field1;
    }
    # Function templates
    if ($symbol_type eq "ftmplt") {
	if ($field3) {
		# There must be a class.
		return nameAndClass($field1, $field2, $symbol_lang);
	}
	# No class.
	return $field1;
    }

    # Class and instance methods are special.
    if ($symbol_type eq "instm") {
	return nameAndClass($field1, $field2, $symbol_lang);
    }
    if ($symbol_type eq "intfm") {
	return nameAndClass($field1, $field2, $symbol_lang);
    }
    if ($symbol_type eq "intfcm") {
	return nameAndClass($field1, $field2, $symbol_lang);
    }
    if ($symbol_type eq "intfp") {
	return nameAndClass($field1, $field2, $symbol_lang);
    }
    if ($symbol_type eq "instp") {
	return nameAndClass($field1, $field2, $symbol_lang);
    }

    # Otherwise return the last nonempty field.
    if ($field6) {
	return $field6;
    }
    if ($field5) {
	return $field5;
    }
    if ($field4) {
	return $field4;
    }
    if ($field3) {
	return $field3;
    }
    if ($field2) {
	return $field2;
    }

    return $field1;
}

# /*!
#     @abstract
#         Generates a "name" for a symbol based on the
#         symbol name and class name.
#
#     @discussion
#         Depending on the values of <code>$lang</code> and
#         {@link HeaderDoc::nameFromAPIRefReturnsOnlyName},
#         this function returns either the object's name,
#         <code>className::objectName</code>, or
#         <code>[ className objectName ]</code>.
#  */
sub nameAndClass($$$$)
{
    my $classname = shift;
    my $methodname = shift;
    my $lang = shift;

    if (!$lang) { return $methodname; }

    my $baremode = $HeaderDoc::nameFromAPIRefReturnsOnlyName;

    if ($lang eq "occ") {
	if ($baremode == 1 || $baremode == 3) { return $methodname; }
	return "[ ".$classname." ".$methodname." ]";
    } else {
	if ($baremode == 2 || $baremode == 3) { return $methodname; }
	return $classname."::".$methodname;
    }

}

# /*!
#     @abstract
#         Converts <code>\@link</code> tags in a string into appropriate link requests.
#     @param self
#         The <code>APIOwner</code> object.
#     @param string
#         The input string.
#     @param mode
#         Pass 0 for HTML, 1 for XML.
#  */
sub fixup_links
{
    my $self = shift;
    my $string = shift;
    my $mode = shift;
    my $ret = "";
    my $localDebug = 0;

    my $linkprefix = "";
    my $count = $depth;
    while ($count) {
	$linkprefix .= "../";
	$count--;
    }
    $linkprefix =~ s/\/$//o;
    $string =~ s/\@\@docroot/$linkprefix/sgo;

    my @elements = split(/</, $string);
    push(@elements, "");
    my $first = 1;
    my $element = "";
    my $movespace = "";
    my $in_link = 0;

    my $in_warning_et_al = "";

    foreach my $nextelt (@elements) {
	if ($first) { $first = 0; $element = $nextelt; next; }

	# print "ELEMENT: $element\n";
	# print "NEXTELT: $nextelt\n";

	if ($nextelt =~ /^\/hd_link>/s) {
		$element =~ s/(\s*)$//s;
		$movespace = $1;
	}
	if ($element =~ /^hd_warning_internal>/o) {
		$in_warning_et_al .= "<".$element;

	} elsif ($element =~ s/^\/hd_warning_internal>//o) {
		$ret .= warningFixup($self, "WARNING:", "warning_indent", $mode, $in_warning_et_al);
		$in_warning_et_al = "";

	} elsif ($element =~ /^hd_important_internal>/o) {
		$in_warning_et_al .= "<".$element;

	} elsif ($element =~ s/^\/hd_important_internal>//o) {
		$ret .= warningFixup($self, "Important:", "important_indent", $mode, $in_warning_et_al);
		$in_warning_et_al = "";

	} elsif ($element =~ /^hd_note_internal>/o) {
		$in_warning_et_al .= "<".$element;

	} elsif ($element =~ s/^\/hd_note_internal>//o) {
		$ret .= warningFixup($self, "Note:", "note_indent", $mode, $in_warning_et_al);
		$in_warning_et_al = "";

	} elsif ($in_warning_et_al) {
	    $in_warning_et_al .= "<".$element;
	} elsif ($element =~ /^hd_link posstarget=\"(.*?)\">/o) {
	    $in_link = 1;
	    # print STDERR "found.\n";
	    my $oldtarget = $1;
	    my $newtarget = $oldtarget;
	    my $prefix = $self->apiUIDPrefix();

	    if (!($oldtarget =~ /\/\//)) {
		warn("link needs to be resolved.\n") if ($localDebug);
		warn("target is $oldtarget\n") if ($localDebug);
		$newtarget = resolveLink($self, $oldtarget);
		warn("new target is $newtarget\n") if ($localDebug);
	    }

	    # print STDERR "element is $element\n";
	    $element =~ s/^hd_link.*?>\s?//o;
	    print STDERR "link name is $element\n" if ($localDebug);
	    if ($mode) {
		if ($newtarget =~ /logicalPath=\".*\"/o) {
			$ret .= "<hd_link $newtarget>";
		} else {
			$ret .= "<hd_link logicalPath=\"$newtarget\">";
		}
		$ret .= $element;
		# $ret .= "</hd_link>";
	    } else {
		# if ($newtarget eq $oldtarget) {
		    $ret .= "<!-- a logicalPath=\"$newtarget\" -->";
		    $ret .= $element;
		    # $ret .= "<!-- /a -->";
		# } else {
		    # if ($toplevel) {
			# $ret .= "<a href=\"CompositePage.html#$newtarget\">";
		    # } else {
			# $ret .= "<a href=\"../CompositePage.html#$newtarget\">";
		    # }
		    # $ret .= $element;
		    # $ret .= "</a>\n";
		# }
	    }
	} elsif ($element =~ s/^\/hd_link>//o) {
		$in_link = 0;
		# print "LEAVING LINK\n";
		if ($nextelt =~ /^\s*[.,?!]/) {
			$movespace = "";
		}
		if ($mode) {
		    $ret .= "</hd_link>$movespace";
		} else {
		    $ret .= "<!-- /a -->$movespace";
		}
		$ret .= $element;
	} else {
		$ret .= "<$element";
	}
	$element = $nextelt;
    }
    $ret =~ s/^<//o;

    if ($in_warning_et_al) {
	warn("Error: unterminated warning, important, or note box.  Please file a bug.\n");
	$ret .= $in_warning_et_al;
    }

    return $ret;
}

# /*!
#     @abstract
#         Converts the internal form for \@note, \@warning,
#         and \@important tags into final form (HTML or XML).
#  */
sub warningFixup
{
    my $self = shift;
    my $htmlkey = shift;
    my $cssindentclass = shift;
    my $xml_mode = shift;
    my $contents = shift;

    my $localDebug = 0;

    print STDERR "INITIAL CONTENTS: $contents\n" if ($localDebug);

    $contents =~ s/^\s*<\s*(.*?)\s*>//s;

    my $xmlkey = $1;

    $xmlkey =~ s/_internal$//s;

    $contents =~ s/^\s*<note_title>(.*?)<\/note_title>//s;

    my $title = $1;
    my $append = "";
    my $tail = "";

    print STDERR "    HTMLKEY:  $htmlkey\n" if ($localDebug);
    print STDERR "    CSSCLASS: $cssindentclass\n" if ($localDebug);
    print STDERR "    XMLKEY:   $xmlkey\n" if ($localDebug);
    print STDERR "    TITLE:    $title\n" if ($localDebug);
    print STDERR "    CONTENTS: $contents\n" if ($localDebug);

    if ($title) {
	if ($xml_mode) {
		$append = "<$xmlkey><title>$title</title>";
		$tail = "</$xmlkey>\n";
	} else {
		$append = "<p><b>$title:</b><br /></p><div class='$cssindentclass'>";
		$tail = "</div>\n";
	}
    } else {
	if ($xml_mode) {
		$append = "<$xmlkey>";
		$tail = "</$xmlkey>\n";
	} else {
		$append = "<p><b>$htmlkey</b><br /></p><div class='$cssindentclass'>";
		$tail = "</div>\n";
	}
    }

    my $updatedcontents = fixup_links($self, $contents, $xml_mode);

    print STDERR "CONTENTS: $contents\n" if ($localDebug);
    print STDERR "UPDATED CONTENTS: $updatedcontents\n" if ($localDebug);

    return $append.$updatedcontents.$tail;
}

# /*!
#     @abstract
#         Converts <code>\@link</code> tags in a string into
#         appropriate link requests in HTML.
#     @param self
#         The <code>APIOwner</code> object.
#     @param string
#         The input string.
#     @discussion
#         Calls {@link fixup_links} to do the actual work.
#  */
sub html_fixup_links
{
    my $self = shift;
    my $string = shift;
    my $resolver_output = fixup_links($self, $string, 0);

    return $resolver_output;
}

# /*!
#     @abstract
#         Converts <code>\@link</code> tags in a string into
#         appropriate link requests in XML.
#     @param self
#         The <code>APIOwner</code> object.
#     @param string
#         The input string.
#     @discussion
#         Calls {@link fixup_links} to do the actual work.
#  */
sub xml_fixup_links
{
    my $self = shift;
    my $string = shift;
    my $resolver_output = fixup_links($self, $string, 1);

    return $resolver_output;
}

# /*! @abstract
#         Updates global <code>$depth</code> variable.
#     @discussion
#         The depth variable is used for creating links to outside resources.
#     @param self
#         The <code>APIOwner</code> object.
#  */
sub calcDepth
{
    my $filename = shift;
    my $base = $HeaderDoc::headerObject->outputDir();
    my $origfilename = $filename;
    my $localDebug = 0;

    $filename =~ s/^\Q$base//;

    my @parts = split(/\//, $filename);

    # Modify global depth.
    $depth = (scalar @parts)-1;

    warn("Filename: $origfilename; Depth: $depth\n") if ($localDebug);

    return $depth;
}

# /*! @abstract
#         Performs conversion of certain Doxygen and JavaDoc tags.
#  */
sub doxyTagFilter
{
    my $line = shift;

    $line =~ s/\@ref\s+(\w+)\s*(\(\))?/<code>\@link $1\@\/link<\/code>/sgio;
    $line =~ s/\{\s*\@linkdoc\s+(.*?)\}/<i>\@link $1\@\/link<\/i>/sgio;
    $line =~ s/\{\s*\@linkplain\s+(.*?)\}/\@link $1\@\/link/sgio;
    $line =~ s/\{\s*\@link\s+(.*?)\}/<code>\@link $1\@\/link<\/code>/sgio;
    # $line =~ s/\{\s*\@docroot\s*\}/\\\@\\\@docroot/sgio;
    # if ($line =~ /value/so) { warn "line was: $line\n"; }
    $line =~ s/\{\@value\}/\@value/sgio;
    $line =~ s/\{\@inheritDoc\}/\@inheritDoc/sgio;
    $line =~ s/\{\s*\@docroot\s*\}/\\\@\\\@docroot/sgo;

    return $line;
}


1;

__END__


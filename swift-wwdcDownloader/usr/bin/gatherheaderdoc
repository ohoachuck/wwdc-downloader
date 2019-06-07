#! /usr/bin/perl -w
#
# Script name: gatherHeaderDoc
# Synopsis: 	Finds all HeaderDoc generated docs in an input
#		folder and creates a top-level HTML page to them
#
# Last Updated: $Date: 2012/10/11 16:16:46 $
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
# $Revision: 1349997406 $
######################################################################

# /*!
#     @header
#         The <code>gatherHeaderDoc.pl</code> tool (<code>gatherheaderdoc</code>
#         when installed) gathers up a folder full of HTML output from
#         <code>headerDoc2HTML.pl</code> (<code>headerdoc2html</code>)
#         and generates a master table of contents.
#
#         This document provides API-level documentation
#         on the tool's internals.  For user documentation, see
#         {@linkdoc //apple_ref/doc/uid/TP40001215 HeaderDoc User Guide}.
#     @indexgroup HeaderDoc Tools
#  */

# /*! @abstract
#         Usually a slash (/); in MacPerl, a colon(:).
#  */
my $pathSeparator;
# /*! @abstract
#         A 1 if MacPerl, else 0.
#  */
my $isMacOS;
# /*! @abstract
#         Path to the Perl modules in the source directory.
#  */
my $uninstalledModulesPath;
# /*! @abstract
#         Path to the Perl modules in the developer tools package.
#  */
my $devtoolsModulesPath;
# /*! @abstract
#         Indicates that an internal link resolution tool was found.
#  */
my $has_resolver;

# /* */
sub resolveLinks($$$);


# /*!
#     @abstract
#         Storage for the <code>groupHierLimit</code> config file field.
#  */
$HeaderDoc::groupHierLimit = undef;

# /*!
#     @abstract
#         Storage for the <code>groupHierSubgroupLimit</code> config file field.
#  */
$HeaderDoc::groupHierSubgroupLimit = undef;

BEGIN {
	use FindBin qw ($Bin);

    if ($^O =~ /MacOS/i) {
		$pathSeparator = ":";
		$isMacOS = 1;
		#$Bin seems to return a colon after the path on certain versions of MacPerl
		#if it's there we take it out. If not, leave it be
		#WD-rpw 05/09/02
		($uninstalledModulesPath = $FindBin::Bin) =~ s/([^:]*):$/$1/;
    } else {
		$pathSeparator = "/";
		$isMacOS = 0;
    }
    $uninstalledModulesPath = "$FindBin::Bin"."$pathSeparator"."Modules";
    $devtoolsModulesPath = "$FindBin::Bin"."$pathSeparator".".."."$pathSeparator"."share"."$pathSeparator"."headerdoc"."$pathSeparator"."Modules";

    $HeaderDoc::use_styles = 0;
}

use strict;
# use Cwd;
use File::Basename;
use File::Find;
use File::Copy;
# use Carp qw(cluck);
use lib $uninstalledModulesPath;
use lib $devtoolsModulesPath;
use POSIX;

# /*! @abstract
#         Set if you pass the -d flag.
#  */
my $generateDocSet = 0;
# /*! @abstract
#         Set if you pass the -n flag with the -d flag.
#  */
my $skipTOC = 0;
# /*! @abstract
#         Set if -N flag is set (disable link resolution).
#  */
my $noResolve = 0;
# /*! @abstract
#         Set if you pass the -w flag.
#  */
$HeaderDoc::useWhatIs = 0;

$has_resolver = 1;
eval "use HeaderDoc::LinkResolver qw (resolveLinks); 1" || do { $has_resolver = 0; };
# print STDERR "HR: $has_resolver\n";
if ($has_resolver) {
	print STDERR "LinkResolver will be used to resolve cross-references.\n";
}

# Modules specific to gatherHeaderDoc
use HeaderDoc::DocReference;
use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash updateHashFromConfigFiles getHashFromConfigFile resolveLinks sanitize stripTags getDefaultEncoding);
$HeaderDoc::modulesPath = $INC{'HeaderDoc/Utilities.pm'};
$HeaderDoc::modulesPath =~ s/Utilities.pm$//s;
# print STDERR "MP: ".$HeaderDoc::modulesPath."\n";

# /*! @abstract
#         Always 1.
#  */
my $debugging = 1;

######################################## Design Overview ###################################
# - We scan input directory for frameset files (index.html, by default).
# - For each frameset file, we look for a special HTML comment (left by HeaderDoc)
#   that tell us the name of the header/class and the type (header or cppclass). 
# - We create a DocReference object to store this info, and also the path to the
#   frameset file.
# - We run through array of DocRef objs and create a master TOC based on the info
# - Finally, we visit each TOC file in each frameset and add a "[Top]" link
#   back to the master TOC.  [This is fragile in the current implementation, since
#   we find TOCs based on searching for a file called "toc.html" in the frameset dir.]
# 

########################## Get command line arguments and flags #######################

# /*! @abstract
#         An array of HeaderDoc-generated files.
#  */
my @inputFiles;

# /*! @abstract
#         An array of all HTML files.
#  */
my @contentFiles;

# /*! @abstract
#         The diretory for input.
#  */
my $inputDir;

# /*! @abstract
#         Storage for the <code>externalXRefFiles</code> config
#     file field.
#  */
my $externalXRefFiles = "";

# /*! @abstract
#         Storage for the contents of the "target=..." attribute
#	for generated links.
#     @discussion
#	Set by the <code>-t</code> flag on the command line.
#  */
my $linktarget = "";

use Getopt::Std;

# /*! @abstract
#         Storage for getopt().
#  */
my %options = ();

# /*! @abstract
#         Per-output-file letter link status variable.
#
#     @discussion
#         Used for determining whether to put in an anchor
#         for jumping to the first two letters of a given symbol.
#         (Only inserted the first time those two letters appear
#         in a given .)
#  */
my %letters_linked = ();

# /*! @abstract
#         Per-group letter link status variable.
#
#     @discussion
#         Used for determining whether to put in an anchor
#         for jumping to the first two letters of a given symbol.
#         (Only inserted the first time those two letters appear
#         in a given .)
#  */
my %group_letters_linked = ();

getopts("Nc:dnwt:x:",\%options);

# The options are handled after processing config file so they can
# override behavior.  However, we need to handle the options first
# before checking for input file names (which we should do first
# to avoid wasting a lot of time before telling the user he/she
# did something wrong).

# /*! @abstract
#         The main TOC file (e.g. index.html).
#  */
my $masterTOCFileName = "";

# my $bookxmlname = "";

if (($#ARGV == 0 || $#ARGV == 1 || $#ARGV == 2) && (-d $ARGV[0])) {
    $inputDir = $ARGV[0];

	if ($#ARGV) {
		$masterTOCFileName = $ARGV[1];
	}
	# if ($#ARGV > 1) {
		# $bookxmlname = $ARGV[2];
	# }

} else {
    die "You must specify a single input directory for processing.\n";
}

########################## Setup from Configuration File #######################
my $localConfigFileName = "headerDoc2HTML.config";
my $preferencesConfigFileName = "com.apple.headerDoc2HTML.config";
my $homeDir;
my $usersPreferencesPath;
my $systemPreferencesPath;
#added WD-rpw 07/30/01 to support running on MacPerl
#modified WD-rpw 07/01/02 to support the MacPerl 5.8.0
if ($^O =~ /MacOS/i) {
	eval {
		require "FindFolder.pl";
		$homeDir = MacPerl::FindFolder("D");	#D = Desktop. Arbitrary place to put things
		$usersPreferencesPath = MacPerl::FindFolder("P");	#P = Preferences
	};
	if ($@) {
		import Mac::Files;
		$homeDir = Mac::Files::FindFolder(kOnSystemDisk(), kDesktopFolderType());
		$usersPreferencesPath = Mac::Files::FindFolder(kOnSystemDisk(), kPreferencesFolderType());
	}
	$systemPreferencesPath = $usersPreferencesPath;
} else {
	$homeDir = (getpwuid($<))[7];
	$usersPreferencesPath = $homeDir.$pathSeparator."Library".$pathSeparator."Preferences";
	$systemPreferencesPath = "/Library/Preferences";
}
my $usrPreferencesPath = "/usr/share/headerdoc/conf";
my $devtoolsPreferencesPath = "$FindBin::Bin"."$pathSeparator".".."."$pathSeparator"."share"."$pathSeparator"."headerdoc"."$pathSeparator"."conf";

my $CWD = getcwd();
my @configFiles = ($devtoolsPreferencesPath.$pathSeparator.$preferencesConfigFileName, $systemPreferencesPath.$pathSeparator.$preferencesConfigFileName, $usersPreferencesPath.$pathSeparator.$preferencesConfigFileName, $Bin.$pathSeparator.$localConfigFileName, $CWD.$pathSeparator.$localConfigFileName);

# ($Bin.$pathSeparator.$localConfigFileName, $usersPreferencesPath.$pathSeparator.$preferencesConfigFileName);

# default configuration, which will be modified by assignments found in config files.
# The default values listed in this hash must be the same as those in the identical 
# hash in headerDoc2HTML--so that links between the frameset and the masterTOC work.
my %config = (
    defaultFrameName => "index.html", 
    masterTOCName => "MasterTOC.html",
    groupHierLimit => 0,
    groupHierSubgroupLimit => 0
);

if ($options{c}) {
	@configFiles = ( $options{c} );
}

%config = &updateHashFromConfigFiles(\%config,\@configFiles);

my $framesetFileName;
my @TOCTemplateList = ();
my @TOCNames = ();
my $framework = "";
my $frameworknestlevel = -1;
my $frameworkShortName = "";
my $frameworkpath = "";
my $headerpath = "";
my $frameworkrelated = "";
my $frameworkUID = "";
my $frameworkCopyrightString = "";

my $landingPageUID = "";
my $landingPageFrameworkUID = "";
my $stripDotH = 0;
my $gather_functions = 0;
my $gather_types = 0;
my $gather_properties = 0;
my $gather_globals_and_constants = 0;
my $gather_man_pages = 0;
my $apiUIDPrefix = "apple_ref";
my $compositePageName = "CompositePage.html";
my $classAsComposite = 0;
my $externalAPIUIDPrefixes = "";
my %usedInTemplate = ();

# /*!
#     @abstract
#         Controls whether to add the [Top] link above the TOC
#         when in frame-style or iframe-style TOC mode.
#     @discussion
#         This value is set based on the <code>addTopLink</code>
#         line in the configuration file, or 1 by default.
#  */
$HeaderDoc::addTopLink = 1;
if (defined $config{"addTopLink"}) {
	$HeaderDoc::addTopLink = $config{"addTopLink"};
}
if (defined $config{"dateFormat"}) {
    $HeaderDoc::datefmt = $config{"dateFormat"};
    if ($HeaderDoc::datefmt !~ /\S/) {
	$HeaderDoc::datefmt = "%B %d, %Y";
    }
} else {
    $HeaderDoc::datefmt = "%B %d, %Y";
}


use HeaderDoc::APIOwner;

my $tocEncoding = getDefaultEncoding();

# Backwards compatibility with 8.7+patches.  May be removed after 8.8.
if (defined ($config{"tocTemplateEncoding"}) && length($config{"tocTemplateEncoding"})) {
	warn("The configuration key tocTemplateEncoding is deprecated.\nUse TOCTemplateEncoding instead.");
	$tocEncoding = $config{"tocTemplateEncoding"}
}

if (defined ($config{"TOCTemplateEncoding"}) && length($config{"TOCTemplateEncoding"})) {
	$tocEncoding = $config{"TOCTemplateEncoding"}
}

HeaderDoc::APIOwner::fix_date($tocEncoding);

my ($sec,$min,$hour,$mday,$mon,$yr,$wday,$yday,$isdst) = localtime(time());
my $yearStamp = strftime("%Y", $sec, $min, $hour,
	$mday, $mon, $yr, $wday, $yday, $isdst);
my $dateStamp = HeaderDoc::HeaderElement::strdate($mon, $mday, $yr + 1900, $tocEncoding);

# die("DS: $dateStamp\n");

if (defined $config{"styleImports"}) {
    $HeaderDoc::styleImports = $config{"styleImports"};
    $HeaderDoc::styleImports =~ s/[\n\r]/ /sgo;
    $HeaderDoc::use_styles = 1;
}

if (defined $config{"groupHierLimit"}) {
    $HeaderDoc::groupHierLimit = $config{"groupHierLimit"};
}
if (defined $config{"groupHierSubgroupLimit"}) {
    $HeaderDoc::groupHierSubgroupLimit = $config{"groupHierSubgroupLimit"};
}

if (defined $config{"tocStyleImports"}) {
    $HeaderDoc::tocStyleImports = $config{"tocStyleImports"};
    $HeaderDoc::tocStyleImports =~ s/[\n\r]/ /sgo;
    $HeaderDoc::use_styles = 1;
}

if (defined $config{"textStyle"}) {
	HeaderDoc::APIOwner->setStyle("text", $config{"textStyle"});
}

if (defined $config{"copyrightOwner"}) {
	# /*!
	#     @abstract
	#         The copyright owner (from the config file).
	#  */
	$HeaderDoc::copyrightOwner = $config{"copyrightOwner"};
}

if (defined $config{"commentStyle"}) {
	HeaderDoc::APIOwner->setStyle("comment", $config{"commentStyle"});
}

if (defined $config{"preprocessorStyle"}) {
	HeaderDoc::APIOwner->setStyle("preprocessor", $config{"preprocessorStyle"});
}

if (defined $config{"funcNameStyle"}) {
	HeaderDoc::APIOwner->setStyle("function", $config{"funcNameStyle"});
}

if (defined $config{"stringStyle"}) {
	HeaderDoc::APIOwner->setStyle("string", $config{"stringStyle"});
}

if (defined $config{"charStyle"}) {
	HeaderDoc::APIOwner->setStyle("char", $config{"charStyle"});
}

if (defined $config{"numberStyle"}) {
	HeaderDoc::APIOwner->setStyle("number", $config{"numberStyle"});
}

if (defined $config{"keywordStyle"}) {
	HeaderDoc::APIOwner->setStyle("keyword", $config{"keywordStyle"});
}

if (defined $config{"typeStyle"}) {
	HeaderDoc::APIOwner->setStyle("type", $config{"typeStyle"});
}

if (defined $config{"paramStyle"}) {
	HeaderDoc::APIOwner->setStyle("param", $config{"paramStyle"});
}

if (defined $config{"varStyle"}) {
	HeaderDoc::APIOwner->setStyle("var", $config{"varStyle"});
}

if (defined $config{"templateStyle"}) {
	HeaderDoc::APIOwner->setStyle("template", $config{"templateStyle"});
}

if (defined $config{"externalXRefFiles"}) {
	$externalXRefFiles = $config{"externalXRefFiles"};
}

if (defined $config{"externalAPIUIDPrefixes"}) {
	$externalAPIUIDPrefixes = $config{"externalAPIUIDPrefixes"};
}

if (defined $config{"defaultFrameName"}) {
	$framesetFileName = $config{"defaultFrameName"};
} 

if (defined $config{"apiUIDPrefix"}) {
    $apiUIDPrefix = $config{"apiUIDPrefix"};
}

if (defined $config{"compositePageName"}) {
	$compositePageName = $config{"compositePageName"};
}

if (defined $config{"classAsComposite"}) {
	$classAsComposite = $config{"classAsComposite"};
	$classAsComposite =~ s/\s*//;
} else {
	$classAsComposite = 0;
}

if (defined $config{"masterTOCName"} && $masterTOCFileName eq "") {
	$masterTOCFileName = $config{"masterTOCName"};
} 
if (defined $config{"stripDotH"}) {
	$stripDotH = $config{"stripDotH"};
} 


# /*!
#     @abstract
#         The background color for the built-in (default) template.
#  */
$GHD::bgcolor = "#ffffff";

my $TOCTemplateFile = "HEADERDOC_DEFAULT_INTERNAL_TEMPLATE";
if (defined $config{"TOCTemplateFile"}) {
	$TOCTemplateFile = $config{"TOCTemplateFile"};
}

my $oldRecSep = $/;
undef $/; # read in files as strings

my @filelist = split(/\s/, $TOCTemplateFile);
foreach my $file (@filelist) {
	my %used = ();

	my $TOCTemplate = "";
	my $found = 0;
	my $foundpath = "";

	if ($file eq "HEADERDOC_DEFAULT_INTERNAL_TEMPLATE") {
		$found = 1;
		$foundpath = "n/a";
		$TOCTemplate = default_template();
	} else {
		print STDERR "Searching for $file\n";
		my @templateFiles = ($devtoolsPreferencesPath.$pathSeparator.$file, $usrPreferencesPath.$pathSeparator.$file, $systemPreferencesPath.$pathSeparator.$file, $usersPreferencesPath.$pathSeparator.$file, $Bin.$pathSeparator.$file, $file);

		foreach my $filename (@templateFiles) {
			if (open(TOCFILE, "<$filename")) {
				$TOCTemplate = <TOCFILE>;
				close(TOCFILE);
				$found = 1;
				$foundpath = $filename;
			}
		}
		if (!$found) {
			die("Template file $file not found.\n");
		} else {
			print STDERR "Found at $foundpath\n";
		}
	}
	push(@TOCTemplateList, $TOCTemplate);
	push(@TOCNames, basename($file));

	if ($TOCTemplate =~ /\$\$\s*typelist/) {
		$gather_types = 1;
		$used{type} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*proplist/) {
		$gather_properties = 1;
		$used{prop} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*datalist/) {
		$gather_globals_and_constants = 1;
		$used{data} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*functionlist/) {
		$gather_functions = 1;
		$used{function} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*manpagelist/) {
		$gather_man_pages = 1;
		$used{manpage} = 1;
	}

	if ($TOCTemplate =~ /\$\$\s*headerlist/) {
		$used{header} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*macrolist/) {
		$used{macro} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*protocollist/) {
		$used{protocol} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*categorylist/) {
		$used{category} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*classlist/) {
		$used{class} = 1;
	}
	if ($TOCTemplate =~ /\$\$\s*comintlist/) {
		$used{comint} = 1;
	}
	$usedInTemplate{$TOCTemplate} = \%used;
}
$/ = $oldRecSep;

my $useBreadcrumbs = 0;

if (defined $config{"useBreadcrumbs"}) {
	$useBreadcrumbs = $config{"useBreadcrumbs"};
}


########################## Handle command line flags #######################
if ($options{w}) {
    $HeaderDoc::useWhatIs = 1;
}
if ($options{d}) {
    $generateDocSet = 1;
    if ($options{n}) {
	$skipTOC = 1;
    }
}
if ($options{N}) {
    $noResolve = 1;
}
if ($options{x}) {
    $externalXRefFiles = $options{x};
}

if ($options{t}) {
    $linktarget = " target=\"".$options{t}."\"";
}

########################## Input Folder and Files #######################

	if ($^O =~ /MacOS/i) {
		find(\&getFiles, $inputDir);
		$inputDir =~ s/([^:]*):$/$1/;	#WD-rpw 07/01/02
	} else {
		$inputDir =~ s|(.*)/$|$1|; # get rid of trailing slash, if any
		if ($inputDir !~ /^\//) { # not absolute path -- !!! should check for ~
			my $cwd = getcwd();
			$inputDir = $cwd.$pathSeparator.$inputDir;
		}
		&find({wanted => \&getFiles, follow => 1}, $inputDir);
	}
unless (@inputFiles) { print STDERR "No valid input files specified. \n\n"; exit(-1)};


# print STDERR "GatherFunc: $gather_functions\n";
# print STDERR "TT: $TOCTemplate\n";


# /*! @abstract
#         Returns a list of the HTML files in the input directory.
#  */
sub getFiles {
    my $filePath = $File::Find::name;
    my $fileName = $_;
    my $localDebug = 0;
    my $basePath = dirname($filePath);
    my $dirName = basename($basePath);
    
    print STDERR "$fileName ($filePath): " if ($localDebug);
    if ($fileName =~ /$framesetFileName/) {
	print STDERR "HTML frameset\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($dirName =~ /^(man|cat)[\w\d]+$/ && $gather_man_pages) {
	print STDERR "Man Page\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /Constants\.html$/ && $gather_globals_and_constants && !$classAsComposite) {
	print STDERR "Constants\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /Vars\.html$/ && $gather_globals_and_constants && !$classAsComposite) {
	print STDERR "Vars\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /DataTypes\.html$/ && $gather_types && !$classAsComposite) {
	print STDERR "DataTypes\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /Structs\.html$/ && $gather_types && !$classAsComposite) {
	print STDERR "Structs\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /Enums\.html$/ && $gather_types && !$classAsComposite) {
	print STDERR "Enums\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /Methods\.html$/ && $gather_functions && !$classAsComposite) {
	print STDERR "Methods\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /Functions\.html$/ && $gather_functions && !$classAsComposite) {
	print STDERR "Functions\n" if ($localDebug);
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName =~ /doc\.html$/ && !$classAsComposite) {
	print STDERR "Framework Documentation\n" if ($localDebug);
	# Framework (maybe)
        push(@inputFiles, $filePath);
        push(@contentFiles, $filePath);
    } elsif ($fileName !~ /toc\.html$/) {
	print STDERR "Other Content\n" if ($localDebug);
	# Don't push the TOCs.
	if ($classAsComposite && $fileName =~ /\Q$compositePageName\E$/) {
        	push(@inputFiles, $filePath);
	}
        push(@contentFiles, $filePath);
    } else {
	print STDERR "toc.\n" if ($localDebug);
    }
}
########################## Find HeaderDoc Comments #######################
my @fileRefSets;
my @headerFramesetRefs;
my @propFramesetRefs;
my @dataFramesetRefs;
my @macroFramesetRefs;
my @typeFramesetRefs;
my @comintFramesetRefs;
my @classFramesetRefs;
my @manpageFramesetRefs;
my @categoryFramesetRefs;
my @protocolFramesetRefs;
my @functionRefs;

my $frameworkabstract = "";
my $frameworkdiscussion = "";

$oldRecSep = $/;
undef $/; # read in files as strings

my $localDebug = 0;

my %groups = ();

$groups{" "}="";

$| = 1;
print STDERR "Processing...";
foreach my $file (@inputFiles) {
  my @perFileDocRefs = ();
  if (-f $file) {
    open (INFILE, "<$file") || die "Can't open $file: $!\n";
    my $fileString = <INFILE>;
    close INFILE;
    my $fileStringCopy = $fileString;
    while ($fileStringCopy =~ s/<\!--\s+(headerDoc\s*=.*?)-->(.*)/$2/s) {
        my $fullComment = $1;
	my $tail = $2;
	my $inDiscussion = 0;
	my $inFrameworkDiscussion = 0;
	my $inFrameworkAbstract = 0;
	my $inAbstract = 0;
	my $inDeclaration = 0;
	my $inPath = 0;
	my $inHeaderPath = 0;
	my $inRelated = 0;
	my $inFWUID = 0;
	my $inFWCopyright = 0;
        my @stockpairs = split(/;/, $fullComment);
	my @pairs = ();
	my $discussion = "";
	my $abstract = "";
	my $declaration = "";

	my $temp = "";
	# print STDERR "FC: $fullComment\n";
	foreach my $stockpair (@stockpairs) {
		if (length($temp)) {
			$temp .= $stockpair;
			if ($temp !~ /\\$/) {
				push(@pairs, $temp);
				$temp = "";
			}
		} else {
			if ($stockpair =~ /\\$/) {
				$temp = $stockpair;
				$temp =~ s/\\$/;/s;
			} else {
				push(@pairs, $stockpair);
				$temp = "";
			}
		}
	}

        my $docRef = HeaderDoc::DocReference->new();
        $docRef->path($file);
	# print STDERR "PATH: $file\n";
	print STDERR ".";
        foreach my $pair (@pairs) {
            my ($key, $value) = split(/=/, $pair, 2);
            $key =~ s/^\s+|\s+$//;
            $value =~ s/^\s+|\s+$//;
	# print STDERR "KEY: $key VALUE: $value\n";
            SWITCH: {
		($key =~ /indexgroup/) && do
		    {
			my $group = $value;
			$group =~ s/^\s*//sg;
			$group =~ s/\s*$//sg;
			$group =~ s/\\;/;/sg;
			$docRef->group($group);
			$groups{$group}=1;
			# print STDERR "SAW $group\n";
		    };
                ($key =~ /headerDoc/) && 
                    do {
                        $docRef->type($value);
			if ($value =~ /discussion/) {
				$inDiscussion = 1;
			}
			if ($value =~ /frameworkdiscussion/) {
			    if (rightframework($file)) {
				$inFrameworkDiscussion = 1;
			    }
			}
			if ($value =~ /declaration/) {
				$inDeclaration = 1;
			}
			if ($value =~ /abstract/) {
				$inAbstract = 1;
			}
			if ($value =~ /frameworkabstract/) {
			    if (rightframework($file)) {
				$inFrameworkAbstract = 1;
			    }
			}
			if ($value =~ /frameworkpath/) {
			    if (rightframework($file)) {
				$inPath = 1;
			    }
			}
			if ($value =~ /headerpath/) {
			    if (rightframework($file)) {
				$inHeaderPath = 1;
			    }
			}
			if ($value =~ /frameworkrelated/) {
			    if (rightframework($file)) {
				$inRelated = 1;
			    }
			}
			if ($value =~ /frameworkuid/) {
				# print STDERR "FWUID DETECTED ($value)\n";
				if (rightframework($file)) {
					$inFWUID = 1;
					# print STDERR "RIGHT FILE\n";
					# $frameworkUID = $value;
					# $frameworkUID =~ s/^\s*//sg;
					# $frameworkUID =~ s/\s*$//sg;
				}
		    	};
			if ($value =~ /frameworkcopyright/) {
				# print STDERR "FWCopyright DETECTED ($value)\n";
				if (rightframework($file)) {
					$inFWCopyright = 1;
					# print STDERR "RIGHT FILE\n";
					# $frameworkUID = $value;
					# $frameworkUID =~ s/^\s*//sg;
					# $frameworkUID =~ s/\s*$//sg;
				}
		    	};
                        last SWITCH;
                    };
		($key =~ /shortname/) &&
		    do {
			$docRef->shortname($value);
			last SWITCH;
		    };
                ($key =~ /uid/) &&
		    do {
			# print STDERR "DOCREF: $docRef NOW ";
			my $newDocRef = $docRef->uid($value, $file);
			if ($newDocRef->path() eq $file) {
				$docRef = $newDocRef;
			# } else {
				# die("DRPATH != NEWDRPATH\nCACHE: ".$newDocRef->path()."\nPROCESSING: $file\n");
			}
			# print STDERR "$docRef\n";
		    };
		($key =~ /mansrc/) &&
		    do {
			# print STDERR "MAN SOURCE: \"$value\"\n";
			$docRef->mansrc($value);
		    };
                ($key =~ /name/) && 
                    do {
                        $docRef->name($value);
			if ($inFrameworkDiscussion && $value =~ /start/) {
				$frameworkdiscussion = $tail;
				$frameworkdiscussion =~ s/<!--\s+headerDoc\s*.*//sg;
				$docRef->discussion($frameworkdiscussion);
				# print STDERR "Discussion: $frameworkdiscussion\n";
			} elsif ($inFrameworkDiscussion && $value =~ /end/) {
				$inFrameworkDiscussion = 0;
			}
			if ($inDiscussion && $value =~ /start/) {
				$discussion = $tail;
				$discussion =~ s/<!--\s+headerDoc\s*.*//sg;
				$docRef->discussion($discussion);
				# print STDERR "Discussion: $discussion\n";
			} elsif ($inDiscussion && $value =~ /end/) {
				$inDiscussion = 0;
			}
			if ($inFrameworkAbstract && $value =~ /start/) {
				$frameworkabstract = $tail;
				$frameworkabstract =~ s/<!--\s+headerDoc\s*.*//sg;
				$docRef->abstract($frameworkabstract);
				# print STDERR "Abstract: $frameworkabstract\n";
			} elsif ($inFrameworkAbstract && $value =~ /end/) {
				$inFrameworkAbstract = 0;
			}
			if ($inAbstract && $value =~ /start/) {
				$abstract = $tail;
				$abstract =~ s/<!--\s+headerDoc\s*.*//sg;
				$docRef->abstract($abstract);
				# print STDERR "Abstract: $abstract\n";
			} elsif ($inAbstract && $value =~ /end/) {
				$inAbstract = 0;
			}
			if ($inDeclaration && $value =~ /start/) {
				$declaration = $tail;
				$declaration =~ s/<!--\s+headerDoc\s*.*//sg;
				$docRef->declaration($declaration);
				print STDERR "SETTING DEC TO \"$declaration\" FOR $docRef\n" if ($localDebug);
				# print STDERR "Declaration: $declaration\n";
			} elsif ($inDeclaration && $value =~ /end/) {
				$inDeclaration = 0;
			}
			if ($inRelated && $value =~ /start/) {
				$frameworkrelated = $tail;
				$frameworkrelated =~ s/<!--\s+headerDoc\s*.*//sg;
				$frameworkrelated =~ s/^\s*//sg;
				$frameworkrelated =~ s/\s*$//sg;
				# print STDERR "Related Docs: $frameworkrelated\n";
			} elsif ($inRelated && $value =~ /end/) {
				$inRelated = 0;
			}
			if ($inFWUID && $value =~ /start/) {
				$frameworkUID = $tail;

				# Strip off the closing marker and what follows.
				$frameworkUID =~ s/<!--\s+headerDoc\s*.*//sg;
				$frameworkUID =~ s/^\s*//sg;
				$frameworkUID =~ s/\s*$//sg;
				# print STDERR "Got UID: $frameworkUID\n";

				if ($frameworkUID =~ /\S/) {
					$landingPageFrameworkUID = "//$apiUIDPrefix/doc/uid/$frameworkUID";
				}
			} elsif ($inFWUID && $value =~ /end/) {
				$inFWUID = 0;
			}
			if ($inFWCopyright && $value =~ /start/) {
				$frameworkCopyrightString = $tail;

				# Strip off the closing marker and what follows.
				$frameworkCopyrightString =~ s/<!--\s+headerDoc\s*.*//sg;
				$frameworkCopyrightString =~ s/^\s*//sg;
				$frameworkCopyrightString =~ s/\s*$//sg;
				# print STDERR "Got CopyrightString: $frameworkCopyrightString\n";
			} elsif ($inFWCopyright && $value =~ /end/) {
				$inFWCopyright = 0;
			}
			if ($inHeaderPath && $value =~ /start/) {
				$headerpath = $tail;
				$headerpath =~ s/<!--\s+headerDoc\s*.*//sg;
				$headerpath =~ s/^\s*//sg;
				$headerpath =~ s/\s*$//sg;
				# print STDERR "Abstract: $frameworkabstract\n";
			} elsif ($inHeaderPath && $value =~ /end/) {
				$inHeaderPath = 0;
			}
			if ($inPath && $value =~ /start/) {
				$frameworkpath = $tail;
				$frameworkpath =~ s/<!--\s+headerDoc\s*.*//sg;
				$frameworkpath =~ s/^\s*//sg;
				$frameworkpath =~ s/\s*$//sg;
				# print STDERR "Abstract: $frameworkabstract\n";
			} elsif ($inPath && $value =~ /end/) {
				$inPath = 0;
			}
                        last SWITCH;
                    };
            }
        }
        my $tmpType = $docRef->type();
	my $isTitle = 0;
	if ($tmpType =~ /^title:(.*)$/s) {
		$tmpType = $1;
		$isTitle = 1; # for future use.
	}
	if (!$docRef->uid()) {
		print STDERR "REF UID BLANK FOR : ".$docRef->name()." in file $file\n";
	}
        if ($tmpType eq "Header") {
            if (!$docRef->pushed()) { push (@headerFramesetRefs, $docRef); }
        } elsif ($tmpType eq "instp"){
            if (!$docRef->pushed()) { push (@propFramesetRefs, $docRef); }
        } elsif ($tmpType eq "clconst"){
            if (!$docRef->pushed()) { push (@dataFramesetRefs, $docRef); }
        } elsif ($tmpType eq "data"){
            if (!$docRef->pushed()) { push (@dataFramesetRefs, $docRef); }
        } elsif ($tmpType eq "tag"){
            if (!$docRef->pushed()) { push (@typeFramesetRefs, $docRef); }
        } elsif ($tmpType eq "tdef"){
            if (!$docRef->pushed()) { push (@typeFramesetRefs, $docRef); }
        } elsif ($tmpType eq "com"){
            if (!$docRef->pushed()) { push (@comintFramesetRefs, $docRef); }
        } elsif ($tmpType eq "cl"){
            if (!$docRef->pushed()) { push (@classFramesetRefs, $docRef); }
        } elsif ($tmpType eq "man"){
            if (!$docRef->pushed()) { push (@manpageFramesetRefs, $docRef); }
        } elsif ($tmpType eq "intf"){
            if (!$docRef->pushed()) { push (@protocolFramesetRefs, $docRef); }
        } elsif ($tmpType eq "macro"){
            if (!$docRef->pushed()) { push (@macroFramesetRefs, $docRef); }
        } elsif ($tmpType eq "functionparam"){
		print "Silently ignoring symbol of type $tmpType\n" if ($localDebug);
        } elsif ($tmpType eq "enumconstant"){
		print "Silently ignoring symbol of type $tmpType\n" if ($localDebug);
        } elsif ($tmpType eq "methodparam"){
		print "Silently ignoring symbol of type $tmpType\n" if ($localDebug);
        } elsif ($tmpType eq "defineparam"){
		print "Silently ignoring symbol of type $tmpType\n" if ($localDebug);
        } elsif ($tmpType eq "structfield"){
		print "Silently ignoring symbol of type $tmpType\n" if ($localDebug);
        } elsif ($tmpType eq "typedeffield"){
		print "Silently ignoring symbol of type $tmpType\n" if ($localDebug);
        } elsif ($tmpType eq "cat"){
            if (!$docRef->pushed()) { push (@categoryFramesetRefs, $docRef); }
	} elsif ($tmpType eq "func" || $tmpType eq "instm" ||
	         $tmpType eq "intfm" || $tmpType eq "clm" ||
	         $tmpType eq "ftmplt") {
		if (!$isTitle) {
			if (!$docRef->pushed()) { push (@functionRefs, $docRef); }
		}
	} elsif ($tmpType eq "Framework" || $tmpType eq "framework") {
	    if (rightframework($file)) {
		$framework = $docRef->name();
		$frameworkShortName = $docRef->shortname();
		$landingPageUID = "//$apiUIDPrefix/doc/framework/$frameworkShortName";
		# print STDERR "FWUID IS \"$frameworkUID\"\n";
		if ($frameworkUID =~ /\S/) {
			$landingPageFrameworkUID = "//$apiUIDPrefix/doc/uid/$frameworkUID";
		}
	    }
	} elsif ($tmpType eq "frameworkdiscussion" ||
	         $tmpType eq "frameworkabstract" ||
	         $tmpType eq "frameworkuid" ||
	         $tmpType eq "frameworkcopyright" ||
	         $tmpType eq "frameworkpath" ||
	         $tmpType eq "headerpath" ||
		 $tmpType eq "frameworkrelated") {
	    if ($localDebug) {
		print STDERR "Discussion: $frameworkdiscussion\n";
		print STDERR "Abstract: $frameworkabstract\n";
		print STDERR "UID: $frameworkUID\n";
		print STDERR "Copyright: $frameworkCopyrightString\n";
		print STDERR "Framework Path: $frameworkpath\n";
		print STDERR "Header Path: $frameworkpath\n";
		print STDERR "Related: $frameworkrelated\n";
	    }
	} elsif ($tmpType eq "abstract") {
		print STDERR "Ignored abstract\n" if ($localDebug);
	} elsif ($tmpType eq "discussion") {
		print STDERR "Ignored discussion\n" if ($localDebug);
	} elsif ($tmpType eq "inheritedContent") {
		print STDERR "Inherited content: ".$docRef->name()."\n" if ($localDebug);
        } elsif ($tmpType eq "econst") {
		print STDERR "Embedded constant: ".$docRef->name()."\n" if ($localDebug);
		if (!$docRef->pushed()) { push (@dataFramesetRefs, $docRef); }
        } else {
            my $tmpName = $docRef->name();
            my $tmpPath = $docRef->path();
            my $tmpUID = $docRef->uid();
            print STDERR "Unknown type '$tmpType' for document with name '$tmpName', path '$tmpPath', UID '$tmpUID'\n";
        }
	if ($docRef->uid() && !$docRef->pushed()) {
		print STDERR "PUSHED ".$docRef->uid()." with name ".$docRef->name()."\n" if ($localDebug);
		push(@perFileDocRefs, $docRef);
	}
	$docRef->pushed(1);
	# warn("DOCREF UID AT END: ".$docRef->uid()." FOR PATH: ".$docRef->path()." WHILE PROCESSING $file\n");
    }
  }
  my $docRef = HeaderDoc::DocReference->new();
  $docRef->name($file);
  $docRef->path($file);
  # This next line is counterintuitive, but this doc object is not
  # stored in the same place as others, so the group function is
  # reused differently.
  $docRef->group( \@perFileDocRefs );
  push(@fileRefSets, $docRef);
}
$/ = $oldRecSep;
print STDERR "\ndone.\n";
$| = 0;

# foreach my $key (groupsort(keys(%groups))) {
	# print STDERR "GROUPNAME: $key\n";
# }

if (scalar(@manpageFramesetRefs)) {
	my %mplatest = ();
	my %mpversions = ();
	my %reftype = ();
	my @newmanpageFramesetRefs = ();
	my $currentOS = $ENV{"OS_VERSION"}; # must be filled in externally.
	my $currentXcode = $ENV{"XCODE_VERSION"}; # must be filled in externally.

	my $localDebug = 0;

	foreach my $page (@manpageFramesetRefs) {
		my $ref = $page->uid();
		$ref =~ s/^"//;
		$ref =~ s/"$//;
		print STDERR "REF IS: $ref\n" if ($localDebug);
		if ($ref =~ /\/\/apple_ref\/doc\/man\/(.*?)\/(.*)/) {
			my $longname = "$2.$1";
			$mplatest{$longname} = $currentOS;
			$mpversions{$longname} .= ""; # " ".$currentOS;
		} elsif ($ref =~ /\/\/apple_ref\/doc\/legacyOS\/(.*?)\/man\/(.*?)\/(.*)/) {
			my $longname = "$3.$2";
			my $version = $1;
			if ($version =~ /Xcode/i) {
				print STDERR "$longname: DEVTOOLS\n" if ($localDebug);
				$reftype{$longname}=1;
			} else {
				print STDERR "$longname: MOSX\n" if ($localDebug);
				$reftype{$longname}=0; # Mac OS X
			}
			$mpversions{$longname} .= " $version";
			if ((!$mplatest{$longname}) || (($mplatest{$longname} ne $currentOS) && ($mplatest{$longname} lt $version))) {
				# Newer version than the last one found.
				$mplatest{$longname} = $version;
			}
		}
	}
	foreach my $page (@manpageFramesetRefs) {
		my $ref = $page->uid();
		$ref =~ s/^"//;
		$ref =~ s/"$//;
		if ($ref =~ /\/\/apple_ref\/doc\/legacyOS\/(.*?)\/man\/(.*?)\/(.*)/) {
			my $osvers = $1;
			my $section = $2;
			my $name = $3;
			my $longname = "$name.$section";

			if (($mplatest{$longname} ne $currentOS) && ($osvers eq $mplatest{$longname})) {
				print STDERR "Pushing man page anyway because ".$mplatest{$longname}." ne ".$currentOS." && $osvers eq ".$mplatest{$longname}."\n" if ($localDebug);
				print STDERR "    UID: $ref OSVERS: $osvers SECTION: $2 NAME: $name LONGNAME: $longname\n" if ($localDebug);
				push(@newmanpageFramesetRefs, $page);
			}
		} else {
			my $ref = $page->uid();
			$ref =~ s/^"//;
			$ref =~ s/"$//;

			print STDERR "Pushing base man page ".$page->uid()."\n" if ($localDebug);
			if ($ref !~ /\/\/apple_ref\/doc\//) {
				$page->hidden(1);
			}
			push(@newmanpageFramesetRefs, $page);
		}
	}
	@manpageFramesetRefs = @newmanpageFramesetRefs;

	foreach my $mpkey (keys(%mpversions)) {
		my $outputDir = $inputDir;

		print STDERR "MPL: ".$mplatest{$mpkey}."\n" if ($localDebug);
		if ($mplatest{$mpkey} eq $currentOS) {
			print STDERR "MPL: CURRENTOS\n" if ($localDebug);
			if ($reftype{$mpkey}) {
				$mpversions{$mpkey} .= " Xcode-".$currentXcode;
			} else {
				$mpversions{$mpkey} .= " ".$currentOS;
			}
		}

		my $vs = $mpversions{$mpkey};
		$vs =~ s/^ //;
		my @versions = sort(split(/ /, $vs));

		my $versiondir = $outputDir.$pathSeparator."versionlists";
		my $versionfile = $versiondir.$pathSeparator.$mpkey.".versions.js";

		if ( ! -d $versiondir ) {
			mkdir($versiondir) || die("Could not create directory for version files.\n");
		}
		open(OUTFILE, ">$versionfile") || die("Could not write version files.\n");
		print OUTFILE "var jsMPVersionsList = new Array();\n";
		foreach my $version (@versions) {
			print STDERR "CHECK: $version eq $currentXcode\n" if ($localDebug);
			if (($version eq $currentOS) || ($version eq "Xcode-".$currentXcode)) {
				print OUTFILE "jsMPVersionsList[\"$version\"] = { isCurrent: 1, isJSMPVersion: 1 };\n";
			} else {
				print OUTFILE "jsMPVersionsList[\"$version\"] = { isCurrent: 0, isJSMPVersion: 1 };\n";
			}
		}
		print OUTFILE "\n";
		close(OUTFILE); 

		if ($localDebug) {
			print STDERR "FILE $mpkey\n";
			print STDERR "VERSIONS:\n";
			foreach my $version (@versions) {
				print STDERR "\t$version\n";
			}
			print STDERR "\n";
		}
	}
}

# create master TOC if we have any framesets
if (scalar(@headerFramesetRefs) + scalar(@comintFramesetRefs) + scalar(@classFramesetRefs) + scalar(@manpageFramesetRefs) + scalar(@protocolFramesetRefs) + scalar(@categoryFramesetRefs) + scalar(@functionRefs)) {
    if (!$skipTOC) {
	print STDERR "Generating TOCs.\n";
        &printMasterTOC();
        &addTopLinkToFramesetTOCs();
    } else {
	print STDERR "Not generating landing pages because -n flag specified.\n";
    }
    if ($generateDocSet) {
	print STDERR "Generating DocSet files suitable for use with docsetutil.\n";
	generateDocSetFile($inputDir);
    }
    if (!$noResolve) {
        if ($has_resolver) {
	    LinkResolver::resolveLinks($inputDir); # Apple internal resolver.
        } else {
	    resolveLinks($inputDir, $externalXRefFiles, $externalAPIUIDPrefixes);
        }
    } else {
	print STDERR "Not running resolveLinks because -N flag specified.\n";
    }
    # if (length($bookxmlname)) {
	# generate_book_xml("$inputDir/$bookxmlname");
    # }
} else {
    print STDERR "gatherHeaderDoc.pl: No HeaderDoc framesets found--returning\n" if ($debugging); 
}
exit 0;

# # /*! @abstract
# #         Generates a book.xml file.
# #     @param filename
# #         The path where this file should be written.
# #     @discussion Deprecated.
# #  */
# sub generate_book_xml
# {
    # my $filename = shift;
# 
    # my $text = "";
    # $text .= "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n";
    # $text .= "<plist version=\"1.0\">\n";
    # $text .= "<dict>\n";
# 
    # my $title = "$framework Documentation";
    # my $landingPageUID = "//$apiUIDPrefix/doc/framework/$frameworkShortName";
# 
    # $text .= "<key>BookTitle</key>\n"; 
    # $text .= "<string>$title</string>\n";
    # $text .= "<key>AppleRefBookID</key>\n";
    # $text .= "<string>$landingPageUID</string>\n";
    # $text .= "<key>WriterEmail</key>\n";
    # $text .= "<string>techpubs\@group.apple.com</string>\n";
    # $text .= "<key>EDD_Name</key>\n";
    # $text .= "<string>ProceduralC.EDD</string>\n";
    # $text .= "<key>EDD_Version</key>\n";
    # $text .= "<string>3.31</string>\n";
    # $text .= "<key>ReleaseDateFooter</key>\n";
    # my $date = `date +"%B %Y"`;
    # $date =~ s/\n//smg;
    # $text .= "<string>$date</string>\n";
    # $text .= "</dict>\n";
    # $text .= "</plist>\n";
# 
    # open(OUTFILE, ">$filename") || die("Could not write book.xml file.\n");
    # print OUTFILE $text;
    # close OUTFILE;
# 
    # $text = "";
    # $text .= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    # $text .= "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n";
    # $text .= "<plist version=\"1.0\">\n";
    # $text .= "<dict>\n";
    # $text .= "<key>outputStyle</key>\n";
    # $text .= "<string>default</string>\n";
    # $text .= "</dict>\n";
    # $text .= "</plist>\n";
# 
    # my $gfilename = dirname($filename)."/$frameworkShortName.gutenberg";
# 
# # print STDERR "FILENAME WAS $gfilename\n";
# 
    # open(OUTFILE, ">$gfilename") || die("Could not write gutenberg file.\n");
    # print OUTFILE $text;
    # close OUTFILE;
# 
# }

my $manPageMode = 0;

################### Print Navigation Page #######################

# /*!
#     @abstract
#         Parses the template files and writes the output indices.
#  */
sub printMasterTOC {
  my $outputDir = $inputDir;
  my $masterTOC = $outputDir.$pathSeparator.$masterTOCFileName;
  my %headersLinkString= ();
  my %typeLinkString = ();
  my %macroLinkString = ();
  my %propLinkString = ();
  my %dataLinkString = ();
  my %comintsLinkString = ();
  my %classesLinkString = ();
  my %manpagesLinkString = ();
  my %protocolsLinkString = ();
  my %categoriesLinkString = ();
  my %functionsLinkString = ();

  my $seenHeaders = 0;
  my $seenType = 0;
  my $seenProp = 0;
  my $seenData = 0;
  my $seenMacros = 0;
  my $seenClasses = 0;
  my $seenComInts = 0;
  my $seenManPages = 0;
  my $seenProtocols = 0;
  my $seenCategories = 0;
  my $seenFunctions = 0;

  my $localDebug = 0;
  my %tempgroups = %groups;
  $tempgroups{"hd_master_letters_linked"} = "";

  my $template_number = 0;
  foreach my $TOCTemplate (@TOCTemplateList) {
    %letters_linked = (); # Reset this for each output file.
    my %used = %{$usedInTemplate{$TOCTemplate}};
    my @templatefields = split(/\$\$/, $TOCTemplate);
    my $templatefilename = $TOCNames[$template_number];
    my $templatename = $templatefilename;

    if ($templatename eq "HEADERDOC_DEFAULT_INTERNAL_TEMPLATE") {
	print STDERR "Writing output file using default internal template.\n";
    } else {
	print STDERR "Writing output file for template \"$templatename\"\n";
    }
    if ($localDebug) {
	print STDERR "Contains header list:        ".($used{header} ? 1 : 0)."\n";
	print STDERR "Contains type list:          ".($used{type} ? 1 : 0)."\n";
	print STDERR "Contains property list:      ".($used{prop} ? 1 : 0)."\n";
	print STDERR "Contains data list:          ".($used{data} ? 1 : 0)."\n";
	print STDERR "Contains function list:      ".($used{function} ? 1 : 0)."\n";
	print STDERR "Contains man page list:      ".($used{manpage} ? 1 : 0)."\n";
	print STDERR "Contains macro list:         ".($used{macro} ? 1 : 0)."\n";
	print STDERR "Contains protocol list:      ".($used{protocol} ? 1 : 0)."\n";
	print STDERR "Contains category list:      ".($used{category} ? 1 : 0)."\n";
	print STDERR "Contains class list:         ".($used{class} ? 1 : 0)."\n";
	print STDERR "Contains COM Interface list: ".($used{comint} ? 1 : 0)."\n";
	print STDERR "\n";
    }

    foreach my $group (groupsort(keys (%tempgroups))) {

	print STDERR "processing group $group\n" if ($localDebug);

      %letters_linked = (); # Reset this for each group.
      $headersLinkString{$group} = "";
      $typeLinkString{$group} = "";
      $propLinkString{$group} = "";
      $dataLinkString{$group} = "";
      $comintsLinkString{$group} = "";
      $classesLinkString{$group} = "";
      $manpagesLinkString{$group} = "";
      $protocolsLinkString{$group} = "";
      $categoriesLinkString{$group} = "";
      $functionsLinkString{$group} = "";

      # get the HTML links to each header 
      if ($used{header}) {
        foreach my $ref (sort objName @headerFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  if ($ref->group() ne $group) {
		# print STDERR "GROUP \"".$ref->group()."\" ne \"$group\".\n";
		next;
	  }

	  if ($stripDotH) {
		$name =~ s/\.h$//;
	  }

          my $tmpString = &getLinkToFramesetFrom($masterTOC, $path, $name, $group, "header", "");
          $headersLinkString{$group} .= $tmpString; $seenHeaders = 1;
        }
        print STDERR "\$headersLinkString is '".$headersLinkString{$group}."'\n" if ($localDebug);
      } else { $seenHeaders = scalar @headerFramesetRefs; }

      my $groupns = $group;
      $groupns =~ s/\s/_/sg;

      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_header";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }
    
      # get the HTML links to each macro
      if ($used{macro}) {
        foreach my $ref (sort objName @macroFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  my $uid = $ref->uid();
	  if ($ref->group() ne $group) { next; }
  
          my $tmpString = &getLinkToFunctionFrom($masterTOC, $path, $name, $uid, $group, "macro");
          $macroLinkString{$group} .= $tmpString; $seenMacros = 1;
        }
        if (($localDebug) && length($macroLinkString{$group})) {print STDERR "\$macroLinkString is '".$macroLinkString{$group}."'\n";};
      } else { $seenMacros = scalar @macroFramesetRefs; }
    
      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_macro";
      print STDERR "inserting into \"$grouptype\" count ".scalar(keys %letters_linked)."\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }

      # get the HTML links to each variable/constant 
      if ($localDebug) {
	print STDERR "BLANKLIST: ";
	foreach my $name (keys %letters_linked) {
		print STDERR "$name "
	}
	print STDERR "ENDLIST\n";
      }
      if ($used{data}) {
        foreach my $ref (sort objName @dataFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  my $uid = $ref->uid();
	  if ($ref->group() ne $group) {
		print STDERR "Not adding \"$name\" because GROUP \"".$ref->group()."\" ne \"$group\".\n" if ($localDebug);
		next;
	  }
	  print STDERR "Adding \"$name\".\n" if ($localDebug);

          my $tmpString = &getLinkToFunctionFrom($masterTOC, $path, $name, $uid, $group, "data");
          $dataLinkString{$group} .= $tmpString; $seenData = 1;
        }
        if (($localDebug) && length($dataLinkString{$group})) {print STDERR "\$dataLinkString is '".$dataLinkString{$group}."'\n";};
      } else { $seenData = scalar @dataFramesetRefs; }

      # get the HTML links to each property
      if ($localDebug) {
	print STDERR "BLANKLIST: ";
	foreach my $name (keys %letters_linked) {
		print STDERR "$name "
	}
	print STDERR "ENDLIST\n";
      }
      if ($used{prop}) {
        foreach my $ref (sort objName @propFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  my $uid = $ref->uid();
	  if ($ref->group() ne $group) {
		print STDERR "Not adding \"$name\" because GROUP \"".$ref->group()."\" ne \"$group\".\n" if ($localDebug);
		next;
	  }
	  print STDERR "Adding \"$name\".\n" if ($localDebug);

          my $tmpString = &getLinkToFunctionFrom($masterTOC, $path, $name, $uid, $group, "prop");
          $propLinkString{$group} .= $tmpString; $seenProp = 1;
        }
        if (($localDebug) && length($propLinkString{$group})) {print STDERR "\$propLinkString is '".$propLinkString{$group}."'\n";};
      } else { $seenProp = scalar @propFramesetRefs; }

      # Get the list of letters to create links.
      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_data";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      if ($localDebug) {
	print STDERR "LIST: ";
	# foreach my $name (keys %{$group_letters_linked{$grouptype}}) {
	foreach my $name (keys %letters_linked) {
		print STDERR "$name "
	}
	print STDERR "ENDLIST\n";
      }
      %letters_linked = ();
      }
    
      # get the HTML links to each type 
      if ($used{type}) {
        foreach my $ref (sort objName @typeFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();
	  my $uid = $ref->uid();
	  if ($ref->group() ne $group) { next; }

          my $tmpString = &getLinkToFunctionFrom($masterTOC, $path, $name, $uid, $group, "type");
          $typeLinkString{$group} .= $tmpString; $seenType = 1;
        }
        if (($localDebug) && length($typeLinkString{$group})) {print STDERR "\$typeLinkString is '".$typeLinkString{$group}."'\n";};
      } else { $seenType = scalar @typeFramesetRefs; }
    
      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_type";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }

      # get the HTML links to each man page 
      if ($used{manpage}) {
        foreach my $ref (sort objName @manpageFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  if ($ref->group() ne $group && $group ne "hd_master_letters_linked") { next; }
	  if ($ref->hidden()) { next; }

	  if (!$ref->mansrc()) {
		warn "NO SRC FOR ".$ref->name()." path ".$ref->path()."\n";
	  }

          my $tmpString = &getLinkToFramesetFrom($masterTOC, $path, $name, $group, "man", $ref->mansrc());
          $manpagesLinkString{$group} .= $tmpString; $seenManPages = 1; $manPageMode = 1;
        }
        if (($localDebug) && length($manpagesLinkString{$group})) {print STDERR "\$manpagesLinkString is '".$manpagesLinkString{$group}."'\n";};
      } else { $seenManPages = scalar @manpageFramesetRefs; }

      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_man";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }
    
      # get the HTML links to each COM Interface 
      if ($used{comint}) {
        foreach my $ref (sort objName @comintFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  if ($ref->group() ne $group) { next; }

          my $tmpString = &getLinkToFramesetFrom($masterTOC, $path, $name, $group, "comint", "");
          $comintsLinkString{$group} .= $tmpString; $seenComInts = 1;
        }
        if (($localDebug) && length($comintsLinkString{$group})) {print STDERR "\$comintsLinkString is '".$comintsLinkString{$group}."'\n";};
      } else { $seenComInts = scalar @comintFramesetRefs; }
    
      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_comint";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }

      # get the HTML links to each class 
      if ($used{class}) {
        foreach my $ref (sort objName @classFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  if ($ref->group() ne $group) { next; }

          my $tmpString = &getLinkToFramesetFrom($masterTOC, $path, $name, $group, "class", "");
          $classesLinkString{$group} .= $tmpString; $seenClasses = 1;
        }
        if (($localDebug) && length($classesLinkString{$group})) {print STDERR "\$classesLinkString is '".$classesLinkString{$group}."'\n";};
      } else { $seenClasses = scalar @classFramesetRefs; }

      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_class";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }
    
      # get the HTML links to each protocol 
      if ($used{protocol}) {
        foreach my $ref (sort objName @protocolFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  if ($ref->group() ne $group) { next; }

          my $tmpString = &getLinkToFramesetFrom($masterTOC, $path, $name, $group, "protocol", "");
          $protocolsLinkString{$group} .= $tmpString; $seenProtocols = 1;
        }
        if (($localDebug) && length($protocolsLinkString{$group})) {print STDERR "\$protocolsLinkString is '".$protocolsLinkString{$group}."'\n";};
      } else { $seenProtocols = scalar @protocolFramesetRefs; }

      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_protocol";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }
    
      # get the HTML links to each category 
      if ($used{category}) {
        foreach my $ref (sort objName @categoryFramesetRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  if ($ref->group() ne $group) { next; }

          my $tmpString = &getLinkToFramesetFrom($masterTOC, $path, $name, $group, "category", "");
          $categoriesLinkString{$group} .= $tmpString; $seenCategories = 1;
        }
        if (($localDebug) && length($categoriesLinkString{$group})) {print STDERR "\$categoriesLinkString is '".$categoriesLinkString{$group}."'\n";};
      } else { $seenCategories = scalar @categoryFramesetRefs; }
    
      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_category";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }

      # get the HTML links to each function 
      if ($used{function}) {
        foreach my $ref (sort objName @functionRefs) {
          my $name = $ref->name();
          my $path = $ref->path();        
	  my $uid = $ref->uid();
	  if ($ref->group() ne $group) { next; }

          my $tmpString = &getLinkToFunctionFrom($masterTOC, $path, $name, $uid, $group, "function");
          $functionsLinkString{$group} .= $tmpString; $seenFunctions = 1;
        }
        if (($localDebug) && length($functionsLinkString{$group})) {print STDERR "\$functionsLinkString is '".$functionsLinkString{$group}."'\n";};
      } else { $seenFunctions = scalar @functionRefs; }

      {
      my %temp_letters_linked = %letters_linked;
      my $grouptype = $groupns."_function";
      print STDERR "inserting into \"$grouptype\"\n" if ($localDebug);
      $group_letters_linked{$grouptype} = \%temp_letters_linked;
      %letters_linked = ();
      }

      # printll(\%letters_linked, $groupns);
    }
    # foreach my $key (keys %group_letters_linked) {
      # printll($group_letters_linked{$key}, $key);
    # }

      my $localDebug = 0;
      if ($localDebug) {
	print STDERR "processing # $template_number\n";
        print STDERR "NAME WAS $templatefilename\n";
      }

      $templatename =~ s/^\s*//s;
      $templatename =~ s/\s*$//s;
      $templatename =~ s/\.html$//s;
      $templatename =~ s/\.tmpl$//s;

      my $title = "$framework Documentation";

      my $include_in_output = 1; my $first = 1; my $out = "";
      foreach my $field (@templatefields) {
	my $keep = $field;
	SWITCH: {
		($field =~ /^\s*title/) && do {

			if ($include_in_output) {
				$out .= $title;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkdiscussion/) && do {

			if ($include_in_output) {
				$out .= $frameworkdiscussion;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkabstract/) && do {

			if ($include_in_output) {
				$out .= $frameworkabstract;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*tocname/) && do {
			my $tn = basename($masterTOC);

			if ($include_in_output) {
				$out .= "$tn";
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkrelatedsection/) && do {

			if (!length($frameworkrelated)) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/frameworkrelatedsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkrelatedlist/) && do {
			$field =~ s/\@\@.*//s;
			# print STDERR "FIELD IS $field\n";

			if ($include_in_output) {
				$out .= relatedDocs($frameworkrelated, $field);
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkorheaderpathorrelatedsection/) && do {

			if (!(length($frameworkpath) || length($frameworkrelated) || length($headerpath))) {

				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/frameworkorheaderpathorrelatedsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*headerpathsection/) && do {

			if (!length($headerpath)) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/headerpathsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*headerpath/) && do {

			if ($include_in_output) {
				$out .= "$headerpath";
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkpathsection/) && do {

			if (!length($frameworkpath)) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/frameworkpathsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkpath/) && do {

			if ($include_in_output) {
				$out .= "$frameworkpath";
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkdir/) && do {

			if ($include_in_output) {
				$out .= "$frameworkShortName";
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*frameworkuid/) && do {

			if ($include_in_output) {
				$out .= "<a name=\"$landingPageUID\" title=\"$framework\"></a>";
				if ($landingPageFrameworkUID ne "") {
					$out .= "<a name=\"$landingPageFrameworkUID\" title=\"$framework\"></a>";
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*framework/) && do {

			if ($include_in_output) {
				$out .= "$framework";
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*headersection/) && do {

			if (!$seenHeaders) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/headersection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*headerlist/) && do {

			if ($seenHeaders) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($headersLinkString{$group}, $field, $group, "header");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*manpagesection/) && do {

			if (!$seenManPages) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/manpagesection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*grouplist/) && do {
			$keep =~ s/.*?\@\@//s;
			if ($include_in_output) {
				$out .= groupList();
			}
			last SWITCH;
			};
		($field =~ /^\s*manpagelist/) && do {

			if ($seenManPages) {
				$field =~ s/\@\@.*//s;
				if ($field =~ /^\s*manpagelist\s+nogroups\s+/) {
					$out .= "<!-- manpage mark=start id=all -->";
					$out .= genTable($manpagesLinkString{"hd_master_letters_linked"}, $field, "hd_master_letters_linked", "man", 0);
					$out .= "<!-- manpage mark=end id=all -->";
				} else {
				    foreach my $group (groupsort(keys(%groups))) {
					if ($group =~ /\S/) {
						# All man pages are in a section, so don't emit noise for the empty group.
						my $group_id = $group;
						$group_id =~ s/\s/_/s;
						$group_id = "group_".$group_id;
						$out .= "<!-- manpage mark=start id=$group_id -->";
						$out .= genTable($manpagesLinkString{$group}, $field, $group, "man", 1);
						$out .= "<!-- manpage mark=end id=$group_id -->";
					}
				    }
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*oocontainersection/) && do {

			if (!$seenComInts && !$seenClasses && !$seenCategories && !$seenProtocols) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/oocontainersection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*comintsection/) && do {

			if (!$seenComInts) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/comintsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*comintlist/) && do {

			if ($seenComInts) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($comintsLinkString{$group}, $field, $group, "comint");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*classsection/) && do {

			if (!$seenClasses) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/classsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*classlist/) && do {

			if ($seenClasses) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($classesLinkString{$group}, $field, $group, "class");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*categorysection/) && do {

			if (!$seenCategories) { # @@@ Debug checkpoint for categories
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/categorysection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*categorylist/) && do {

			if ($seenCategories) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($categoriesLinkString{$group}, $field, $group, "category");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*protocolsection/) && do {

			if (!$seenProtocols) { # @@@ Debug checkpoint for protocols
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/protocolsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*protocollist/) && do {

			if ($seenProtocols) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($protocolsLinkString{$group}, $field, $group, "protocol");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*macrosection/) && do {

			if (!$seenMacros) {
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/macrosection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*macrolist/) && do {

			if ($seenMacros) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($macroLinkString{$group}, $field, $group, "macro");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*propsection/) && do {

			if (!$seenProp) { # @@@ Debug checkpoint for properties
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/propsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*proplist/) && do {

			if ($seenProp) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($propLinkString{$group}, $field, $group, "prop");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*datasection/) && do {

			if (!$seenData) { # @@@ Debug checkpoint for data (const, etc.)
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/datasection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*datalist/) && do {

			if ($seenData) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($dataLinkString{$group}, $field, $group, "data");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*typesection/) && do {

			if (!$seenType) { # @@@ Debug checkpoint for data types
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/typesection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*year/) && do {
			$out .= $yearStamp;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*date/) && do {
			$out .= $dateStamp;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*copyright/) && do {

			if (length($frameworkCopyrightString)) {
				my $temp = $frameworkCopyrightString;
				$temp =~ s/\$\$year\@\@/\Q$yearStamp\E/g;
				$temp =~ s/\$\$date\@\@/\Q$dateStamp\E/g;
				$out .= $temp;
			} else {
				if ($HeaderDoc::copyrightOwner && length($HeaderDoc::copyrightOwner)) {
					$out .= "&copy; ".$yearStamp." ".$HeaderDoc::copyrightOwner
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*typelist/) && do {

			if ($seenType) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($typeLinkString{$group}, $field, $group, "type");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*functionsection/) && do {

			if (!$seenFunctions) { # @@@ Debug checkpoint for functions
				$include_in_output = 0;
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*\/functionsection/) && do {

			$include_in_output = 1;

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		($field =~ /^\s*functionlist/) && do {

			if ($seenFunctions) {
				$field =~ s/\@\@.*//s;
				foreach my $group (groupsort(keys(%groups))) {
					$out .= genTable($functionsLinkString{$group}, $field, $group, "function");
				}
			}

			$keep =~ s/.*?\@\@//s;
			last SWITCH;
			};
		{
			if ($first) { $first = 0; }
			else { warn "Unknown field: \$\$$field\n"; $out .= "\$\$"; }
		}
	}
	if ($include_in_output) { $out .= $keep; }
      }

      # print STDERR "HTML: $out\n";

      # write out page
      print STDERR "gatherHeaderDoc.pl: writing master TOC to $masterTOC\n" if ($localDebug);
      if (!$template_number) {
	open(OUTFILE, ">$masterTOC") || die "Can't write $masterTOC.\n";
      } else {
	open(OUTFILE, ">$outputDir$pathSeparator$frameworkShortName-$templatename.html") || die "Can't write $outputDir$pathSeparator$frameworkShortName-$templatename.html.\n";
      }
      print OUTFILE $out;
      close OUTFILE;
      ++$template_number;
  }
}

# /*!
#     @abstract
#         Adds a link to the main TOC index from each of the HTML
#         frameset files.
#  */
sub addTopLinkToFramesetTOCs {
    my $masterTOC = $inputDir.$pathSeparator. $masterTOCFileName;
    my $tocFileName = "toc.html";
    my @allFramesetRefs;
    push(@allFramesetRefs, @headerFramesetRefs);
    push(@allFramesetRefs, @comintFramesetRefs);
    push(@allFramesetRefs, @classFramesetRefs);
    push(@allFramesetRefs, @protocolFramesetRefs);
    push(@allFramesetRefs, @categoryFramesetRefs);
    my $localDebug = 0;
    
    foreach my $ref (@allFramesetRefs) {
        my $name = $ref->name();
        my $type = $ref->type();
        my $path = $ref->path();
        my $tocFile = $path;   				# path to index.html
        my $fsName = quotemeta($framesetFileName);
        $tocFile =~ s/$fsName$/toc.html/; 		# path to toc.html
        
        if (-e "$tocFile" ) {
            my $oldRecSep = $/;
            undef $/; # read in file as string
            open(INFILE, "<$tocFile") || die "Can't read file $tocFile.\n";
            my $fileString = <INFILE>;
            close INFILE;
            $/ = $oldRecSep;

	    my $uniqueMarker = "headerDoc=\"topLink\"";

	    # Determine the style in which the TOC was built.
	    my $newTOC = 0;
	    if ($fileString =~ /headerDoc TOC style: (\d+)\s*-->/) {
		$newTOC = $1;
	    }
	    $HeaderDoc::newTOC = $newTOC;

            my $relPathToMasterTOC = &findRelativePath($tocFile, $masterTOC);
	    my $breadcrumb_added = 0;
	    if ($fileString =~ /<!-- HeaderDoc TOC framework link begin -->.*<!-- HeaderDoc TOC framework link end -->/s) {
                my $breadcrumb = "";
		$breadcrumb_added = 1;

		if ($newTOC) {
			# In a class, so the heading is already there.
			# $breadcrumb .= HeaderDoc::APIOwner->tocSeparator("Other Reference", $newTOC);
			$breadcrumb .= HeaderDoc::APIOwner->tocEntry("$relPathToMasterTOC", "$framework", "_top");
		} else {
			# In a class, so the heading is already there.
			# $breadcrumb .= "<br><h4>Other Reference</h4><hr class=\"TOCSeparator\">\n";
			$breadcrumb .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$relPathToMasterTOC\" target=\"_top\">$framework</a></nobr><br>\n";
		}

		$fileString =~ s/<!-- HeaderDoc TOC framework link begin -->.*<!-- HeaderDoc TOC framework link end -->/<!-- HeaderDoc TOC framework link begin -->$breadcrumb<!-- HeaderDoc TOC framework link end -->/s;
	    } elsif ($fileString =~ /<!-- HeaderDoc TOC framework link block begin -->.*<!-- HeaderDoc TOC framework link block end -->/s) {
                my $breadcrumb = "";
		$breadcrumb_added = 1;

		if ($newTOC) {
			$breadcrumb .= HeaderDoc::APIOwner->tocSeparator("Other Reference", $newTOC);
			$breadcrumb .= HeaderDoc::APIOwner->tocEntry("$relPathToMasterTOC", "$framework", "_top");
		} else {
			$breadcrumb .= "<br><h4>Other Reference</h4><hr class=\"TOCSeparator\">\n";
			$breadcrumb .= "<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=\"$relPathToMasterTOC\" target=\"_top\">$framework</a></nobr><br>\n";
		}

		$fileString =~ s/<!-- HeaderDoc TOC framework link block begin -->.*<!-- HeaderDoc TOC framework link block end -->/<!-- HeaderDoc TOC framework link block begin -->$breadcrumb<!-- HeaderDoc TOC framework link block end -->/s;
	    }
	    if ((($HeaderDoc::addTopLink && !$newTOC) || (!$breadcrumb_added)) && (!$useBreadcrumbs)) {
		if ($fileString !~ /$uniqueMarker/) { # we haven't been here before
                    my $relPathToMasterTOC = &findRelativePath($tocFile, $masterTOC);
                    my $topLink = "\n<font size=\"-2\"><a href=\"$relPathToMasterTOC\" target=\"_top\" $uniqueMarker>[Top]</a></font><br/>\n";
                    
                    $fileString =~ s/(<body[^>]*>)/$1$topLink/i;
                }
	    }
            open (OUTFILE, ">$tocFile") || die "Can't write file $tocFile.\n";
            print OUTFILE $fileString;
            close (OUTFILE);
        } elsif ($debugging) {
            print STDERR "--> '$tocFile' doesn't exist!\n";
            print STDERR "Cannot add [top] link for frameset doc reference:\n";
            print STDERR "   name: $name\n";
            print STDERR "   type: $type\n";
            print STDERR "   path: $path\n";
        }
    }
    if ($useBreadcrumbs) {
	foreach my $file (@contentFiles) {
	    # print STDERR "FILE: $file\n";
            if (-e "$file" && ! -d "$file" ) {
                my $oldRecSep = $/;
                undef $/; # read in file as string
		open(INFILE, "<$file") || die "Can't read file $file.\n";
		my $fileString = <INFILE>;
		close INFILE;
                $/ = $oldRecSep;

		my $uniqueMarker = "headerDoc=\"topLink\"";

		# if ($fileString !~ /$uniqueMarker/) { # we haven't been here before
		if (length($framework)) {
                    my $relPathToMasterTOC = &findRelativePath($file, $masterTOC);
                    my $breadcrumb = "<a href=\"$relPathToMasterTOC\" $linktarget $uniqueMarker>$framework</a>";

                    $fileString =~ s/<!-- begin breadcrumb -->.*?<!-- end breadcrumb -->/<!-- begin breadcrumb -->$breadcrumb<!-- end breadcrumb -->/i;
                
                    open (OUTFILE, ">$file") || die "Can't write file $file.\n";
                    print OUTFILE $fileString;
                    close (OUTFILE);
		} else {
			warn "No framework (.hdoc) file found and breadcrumb specified.  Breadcrumbs will\nnot be inserted.\n";
		}
		# }
	    }
	}
    }
}

# /*!
#     @abstract
#         Returns a relative link to a destination frameset
#         (a header, class, etc.) from the main TOC.
#     @param masterTOCFile
#         The path of the TOC file that this will go into.
#     @param dest
#         The filesystem path of the destination content.
#     @param name
#         The name of the destination as it should appear in the human-readable
#         text for the link.
#     @param group
#         The name of the group (from <code>\@indexgroup</code>) for
#         the destination.
#     @param typename
#         The name of the type of the destination (e.g. header, category, ...)
#     @discussion
#         In addition to being a link, the anchors returned may also
#         be jump link destinations for letter groups within long
#         sets of links.  Thus, this function needs to know the name
#         of the group that the destination is in, as well as the
#         type (e.g. header, category...).
#  */
sub getLinkToFramesetFrom {
    my $masterTOCFile = shift;
    my $dest = shift;    
    my $name = shift;    
    my $group = shift;
    my $typename = shift;
    my $mansrc = shift;
    my $linkString;

    my %manPageTypes = (
	"base" => "Mac OS X (client) manual page",
	"server" => "Mac OS X Server manual page",
	"devtools" => "Developer tools manual page",
	"chud" => "CHUD (part of developer tools) manual page",
	"internal" => "INTERNAL MANUAL PAGE"
    );

    my $maninsert = "";
    if ($mansrc) {
	$maninsert = "<span class=\"manpage_source_$mansrc\">&#x2022;</span>";
	$mansrc = " mansrc=\"$mansrc\" class=\"manpage_source_$mansrc\" title=\"".$manPageTypes{$mansrc}."\" ";
    }
    
    my $relPath = &findRelativePath($masterTOCFile, $dest);
    my $namestring = getNameStringForLink($name, $group, $typename);
    $linkString = "$maninsert<a $namestring href=\"$relPath\" $linktarget $mansrc>$name</a><br/>\n"; 
    return $linkString;
}

# /*!
#     @abstract
#         Returns the jump destination part of an anchor.
#     @param name
#         The name of the destination as it should appear in the human-readable
#         text for the link.
#     @param group
#         The name of the group (from <code>\@indexgroup</code>) for
#         the destination.
#     @param typename
#         The name of the type of the destination (e.g. header, category, ...)
#     @discussion
#         Used by {@link getLinkToFramesetFrom} and
#         {@link getLinkToFunctionFrom}.
#  */
sub getNameStringForLink
{
    my $name = shift;
    my $group = shift;
    my $typename = shift;
    my $namestring = "";
    my $groupns = $group;
    $groupns =~ s/\s/_/sg;

    my $grouptype = $groupns."_".$typename;
    my $firsttwo = uc($name);
    $firsttwo =~ s/^(..).*$/$1/s;
# print STDERR "FIRSTTWO: $firsttwo\n";
# cluck("test\n");
    if (!$letters_linked{$firsttwo}) {
	$namestring = "name=\"group_$grouptype"."_$firsttwo\"";
	$letters_linked{$firsttwo} = 1;
	# print STDERR "SET letters_linked{$firsttwo}\n";
    } else {
	$letters_linked{$firsttwo}++;
    }
    return $namestring;
}

# /*!
#     @abstract
#         Returns a relative link to a function, data type, or other
#         non-API-owning API element (i.e. not an entire header or class).
#     @param masterTOCFile
#         The path of the TOC file that this will go into.
#     @param dest
#         The filesystem path of the destination content.
#     @param name
#         The name of the destination as it should appear in the human-readable
#         text for the link.
#     @param group
#         The name of the group (from <code>\@indexgroup</code>) for
#         the destination.
#     @param typename
#         The name of the type of the destination (e.g. header, category, ...)
#     @discussion
#         In addition to being a link, the anchors returned may also
#         be jump link destinations for letter groups within long
#         sets of links.  Thus, this function needs to know the name
#         of the group that the destination is in, as well as the
#         type (e.g. header, category...).
#  */
sub getLinkToFunctionFrom {
    my $masterTOCFile = shift;
    my $dest = shift;    
    my $name = shift;    
    my $uid = shift;
    my $group = shift;
    my $typename = shift;
    my $linkString;
    
    $uid =~ s/^"//;
    $uid =~ s/"$//;
    my $relPath = &findRelativePath($masterTOCFile, $dest);
    my $ns = getNameStringForLink($name, $group, $typename);
    my $noClassName = $name;
    $noClassName =~ s/.*\:\://s;
    my $urlname = sanitize($noClassName);
    my $lp = "";
    if ($uid && length($uid)) {
	$urlname = $uid;
	$lp = " logicalPath=\"$uid\"";
    }
	# print STDERR "UIDCHECK: $uid\n";
    if ($uid =~ /\/\/apple_ref\/occ\/(clm|instm|intfcm|intfm)\//) {
	# Format Objective-C class name
	my $type = $1;
	$name =~ s/^(.*)\:\://;
	my $class = $1;
	my $plusmin = "+";
	if ($type eq "instm") {
		$plusmin = "-";
	}
	$name = $plusmin."[ $class $name ]";
    }
    $linkString = "<a $lp $ns href=\"$relPath#$urlname\" retarget=\"yes\" $linktarget>$name</a><br/>\n"; 
    return $linkString;
}


# /*!
#     @abstract
#         Sort helper for sorting objects by name.
#     @param obj1
#         Object 1.
#     @param obj2
#         Object 2.
#  */
sub objName { # for sorting objects by their names
    uc($a->name()) cmp uc($b->name());
}

# /*!
#     @abstract
#         Returns a default (minimal) TOC template.
#  */
sub default_template
{
    my $template = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n    \"http://www.w3.org/TR/1998/REC-html40-19980424/loose.dtd\">\n";
    my $stylesheet = "";
    # my $he = HeaderElement::new;
    # my $stylesheet = $he->styleSheet(0);

    $template .= "<html>\n<head>\n    <title>\$\$title\@\@</title>\n    <meta name=\"generator\" content=\"HeaderDoc\" />\n    <meta name=\"formatter\" content=\"gatherHeaderDoc\" />\n    <meta name=\"xcode-display\" content=\"render\" />\n$stylesheet</head>\n<body bgcolor=\"$GHD::bgcolor\"><h1>\$\$framework\@\@ Documentation</h1><hr/><br/>\n";
    $template .= "<p>\$\$frameworkdiscussion\@\@</p>";
    $template .= "\$\$headersection\@\@<h2>Headers</h2>\n<blockquote>\n\$\$headerlist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/headersection\@\@\n";
    $template .= "\$\$classsection\@\@<h2>Classes</h2>\n<blockquote>\n\$\$classlist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/classsection\@\@\n";
    $template .= "\$\$categorysection\@\@<h2>Categories</h2>\n<blockquote>\n\$\$categorylist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/categorysection\@\@\n";
    $template .= "\$\$protocolsection\@\@<h2>Protocols</h2>\n<blockquote>\n\$\$protocollist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/protocolsection\@\@\n";
    $template .= "\$\$functionsection\@\@<h2>Functions</h2>\n<blockquote>\n\$\$functionlist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/functionsection\@\@\n";
    $template .= "\$\$typesection\@\@<h2>Data Types</h2>\n<blockquote>\n\$\$typelist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/typesection\@\@\n";
    $template .= "\$\$datasection\@\@<h2>Globals and Constants</h2>\n<blockquote>\n\$\$datalist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/datasection\@\@\n";
    $template .= "\$\$propsection\@\@<h2>Globals and Constants</h2>\n<blockquote>\n\$\$proplist cols=2 order=down atts=border=\"0\" width=\"80%\"\@\@\n</blockquote>\$\$/propsection\@\@\n";
    $template .= "\$\$copyright\@\@\n";
    $template .= "</body>\n</html>\n";

    $gather_globals_and_constants = 1;
    $gather_types = 1;
    $gather_functions = 1;

    return $template;
}

# /*! 
#     @abstract
#         Returns a link string linking to a jump destination for a
#               given letter group within an <code>\@indexgroup</code>
#               group within a data type family (e.g. headers,
#               functions, etc.).
#     @param group
#         The <code>\@indexgroup</code> group that this will appear under.
#     @param linkletter
#         A name for the letter range suitable for inclusion in an anchor's
#         "name" attribute.
#     @param letter
#         The first letter of the letter range.
#     @param typename
#         The name of the type of the destination (e.g. header, category, ...)
#     @param optional_last
#         The end of the letter range. (Optional.)
#
#         If omitted, for a single-character letter, the last part of
#         the range is omitted.  For example, instead of showing "A-B",
#         it would just show "A".  If the start of the range (letter) is
#         two characters, in which case the range is automatically assumed
#         to end with a Z (AM-AZ, for example).
#
#  */
sub gethierlinkstring
{
    my $group = shift;
    my $linkletter = shift;
    my $letter = shift;
    my $typename = shift;
    my $optional_last = "";
    if (@_) {
	$optional_last = shift;
	$optional_last = "-$optional_last";
    } elsif ($letter =~ /../) {
	$optional_last = $letter;
	$optional_last =~ s/(.)./$1Z/s;
	$optional_last = "-$optional_last";
    }
    my $groupns = $group;
    $groupns =~ s/\s/_/sg;
    my $grouptype = $groupns."_".$typename;

    return "<a href=\"#group_$grouptype"."_$linkletter\">$letter$optional_last</a>";
}

# /*!
#     @abstract
#         Generates a multi-column table of links.
#     @param inputstring
#         A pile of links, one per line.
#     @param settings
#         The table parameters from the template file.  (These are
#         documented in the template section of the
#      {@linkdoc //apple_ref/doc/uid/TP40001215 HeaderDoc User Guide}).
#     @param groupname
#         The <code>\@indexgroup</code> group that this will appear under.
#     @param typename
#         The name of the type of the destination (e.g. header, category, ...)
#     @param isman
#         Set to 1 for manual pages.  This causes the code to generate
#         multiple tables, one per manual section.
#  */
sub genTable
{
    my $inputstring = shift;
    my $settings = shift;
    my $groupname = shift;
    my $typename = shift;
    my $isman = 0;
    if (@_) {
	$isman = shift;
    }
    my $ncols = 0;
    my $order = "down";
    my $attributes = "border=\"0\" width=\"100%\"";
    my $tdclass = "";
    my $trclass = "";
    my $localDebug = 0;
    my $addempty = 0;
    my $notable = 0;

    print STDERR "genTable(IS: [omitted], SET: $settings, GN: $groupname, TN: $typename, IM: $isman)\n" if ($localDebug);

    my $mansectiontext = "";
    if ($isman) {
	my $mansectionname = $groupname;
	$mansectionname =~ s/^\s*Section\s+//s;

	my $filename="sectiondesc/man$mansectionname".".html";
	if (open(SECTIONTEXT, "<$filename")) {
		my $lastrs = $/;
		$/ = undef;
		$mansectiontext = <SECTIONTEXT>;
		$/ = $lastrs;
		close(SECTIONTEXT);
	} else {
		warn "No file for man section $mansectionname\n";
	}
    }

    if (!defined($inputstring)) { return ""; }

    my @lines = split(/\n/, $inputstring);
    my $nlines = scalar(@lines);

    my $addHierarchicalLinks = 0;
    my $hierstring = "";

    if ($HeaderDoc::groupHierLimit && ($nlines > $HeaderDoc::groupHierLimit)) {
	$addHierarchicalLinks = 1;

	my $splitparts = 0;
	my $attempts = 0;
	my $subgroupLimit = $HeaderDoc::groupHierSubgroupLimit;
	my $minsplit = 5;

	while ($splitparts < $minsplit && $attempts < 5) {
		my $linkletter = "";
		my $prevletter = "";
		my $prevtwoletter = "";
		$splitparts = 0; # Count the number of entries and reduce the limit as needed to ensure no singleton lists.
		$hierstring = "<blockquote class='letterlist'><table width='80%'><tr><td>\n";

		print STDERR "GROUPNAME: $groupname\n" if ($localDebug);
		my $groupns = $groupname;
		$groupns =~ s/\s/_/sg;
		my $grouptype = $groupns."_".$typename;
		print STDERR "GROUPTYPE: \"$grouptype\"\n" if ($localDebug);

		my %twoletterlinkcounts = %{$group_letters_linked{$grouptype}};

		print STDERR "GLLCHECK: ".scalar(keys %{$group_letters_linked{$grouptype}})."\n" if ($localDebug);

		my %oneletterlinkcounts = ();
		foreach my $twoletter (sort keys %twoletterlinkcounts) {
			# print STDERR "TL: $twoletter\n";
			my $firstletter = $twoletter;
			$firstletter =~ s/^(.).*$/$1/s;
			if (!$oneletterlinkcounts{$firstletter}) {
				# print STDERR "FIRST $firstletter; linkletter -> $twoletter\n";
				$oneletterlinkcounts{$firstletter} = $twoletterlinkcounts{$twoletter};
				if ($prevletter ne "") {
					$hierstring .= gethierlinkstring($groupname, $linkletter, $prevletter, $typename)."&nbsp;<span class='hierpipe'>|</span> \n";
				}
				$prevletter = $firstletter;
				$linkletter = $twoletter;
				$splitparts++;
			} elsif ($oneletterlinkcounts{$firstletter} + $twoletterlinkcounts{$twoletter} > $subgroupLimit) {
				# print STDERR "LIMIT $firstletter; linkletter -> $twoletter\n";
				$hierstring .= gethierlinkstring($groupname, $linkletter, $prevletter, $typename, $prevtwoletter)."&nbsp;<span class='hierpipe'>|</span> \n";
				$prevletter = $twoletter;
				$linkletter = $twoletter;
				$splitparts++;
			}
			$prevtwoletter = $twoletter;
		}
		if ($prevletter ne "") {
			$hierstring .= gethierlinkstring($groupname, $linkletter, $prevletter, $typename);
		}
		$hierstring .= "</td></tr></table></blockquote>\n";

		# Reduce the subgroup limit and increase the attempt count so that if
		# we execute this code again, we will probably get more subgroups.
		# Use the attempts count to ensure that this loop isn't infinite if
		# all entries have the same first letter.

		if ($splitparts < $minsplit) {
			print STDERR "Minimum split count $minsplit not reached.  Split count was $splitparts.  Reducing split count.\n" if ($localDebug);
			$subgroupLimit = $subgroupLimit / $minsplit;
		}
		$attempts++;
	}
	print STDERR "SPLITPARTS: $splitparts\n" if ($localDebug);
	if ($splitparts <= 1) {
		print STDERR "Could not split list at all.  Dropping singleton.\n" if ($localDebug);
		$hierstring = ""; # eliminate singleton lists.
	}
    # } else {
	# print STDERR "Not over limit: $groupname\n";
    }
    # print STDERR "HIERSTRING: $hierstring\n";

    my $ngroups = scalar(keys(%groups));

    my $groupnamestring = "";
    if ($groupname =~ /\S/) {
	my $groupnospc = $groupname;
	$groupnospc =~ s/\s/_/sg;
	$groupnamestring = "<p class='groupname'><a name='group_$groupnospc'></a><i>$groupname</i></p>\n";
    }
    if ($groupname eq "hd_master_letters_linked") { $groupnamestring = ""; }

    my $groupheadstring = "<blockquote class='groupindent'>\n";
    my $grouptailstring = "</blockquote>\n";
    if (!$ngroups) {
	$groupheadstring = "";
	$grouptailstring = "";
    }

    $settings =~ s/^\s*(\w+list)\s*//;
    my $name = $1;

    if ($settings =~ s/^nogroups\s+//) {
	$ngroups = 0;
    }
    if ($settings =~ s/^cols=(\d+)\s+//) {
	$ncols = $1;
    }
    if ($settings =~ s/^order=(\w+)\s+//) {
	$order = $1;
	if (!$ncols) { $ncols = 1; }
    }
    if ($settings =~ s/^trclass=(\w+)\s+//) {
	$trclass = " class=\"$1\"";
	if (!$ncols) { $ncols = 1; }
    }

    if ($settings =~ s/^tdclass=(\w+)\s+//) {
	$tdclass = " class=\"$1\"";
	if (!$ncols) { $ncols = 1; }
    }
    if ($settings =~ s/^notable//) {
	$notable = 1; $ncols = 1;
    }

    if ($settings =~ s/^addempty=(\d+)//) {
	$addempty = $1;
    }

    if ($settings =~ s/^atts=//) {
	$attributes = $settings;
	$settings = "";
	if (!$ncols) { $ncols = 1; }
    }

    if ($ncols) {
	if (!$nlines) { return ""; }

	my @columns = ();
	my $loopindex = $ncols;
	while ($loopindex--) {
		my @column = ();
		push(@columns, \@column);
	}

	my $curcolumn = 0; my $curline = 0;

	my $lines_per_column = int(($nlines + $ncols - 1) / $ncols);
			# ceil(nlines/ncols)
	my $blanks = ($lines_per_column * $ncols) - $nlines;
	$nlines += $blanks;
	while ($blanks) {
		push(@lines, "");
		$blanks--;
	}

	warn "NLINES: $nlines\n" if ($localDebug);
	warn "Lines per column: $lines_per_column\n" if ($localDebug);

	foreach my $line (@lines) {
		warn "columns[$curcolumn] : adding line\n" if ($localDebug);
		my $columnref = $columns[$curcolumn];

		push(@{$columnref}, $line);

		$curline++;

		if ($order eq "across") {
			$curcolumn = ($curcolumn + 1) % $ncols;
		} elsif ($curline >= $lines_per_column) {
			$curline = 0; $curcolumn++;
		}
	}

	if ($localDebug) {
	    $loopindex = 0;
	    while ($loopindex < $ncols) {
		warn "Column ".$loopindex.":\n";
		foreach my $line (@{$columns[$loopindex]}) {
			warn "$line\n";
		}
		$loopindex++;
	    }
	}

# warn("TABLE $attributes\n");
	my $outstring = "";
	if (!$notable) { $outstring .= "<table $attributes>"; }

	$curline = 0;
	$curcolumn = 0;
	my $currow = 0;
	my $first = 1;

	while ($curline < $nlines) {
		if (!$curcolumn) {
			if ($first) {
				$first = 0;
				if (!$notable) { $outstring .= "<tr$trclass>"; }
			} else {
				if (!$notable) { $outstring .= "</tr><tr>\n"; }
				$currow++;
			}
		} else {
			if ($addempty) {
				if (!$notable) { $outstring .= "<td width=\"$addempty\"$tdclass>&nbsp;</td>\n"; }
			}
		}

		my $line = ${$columns[$curcolumn]}[$currow];
		my $val = floor(100/$ncols);
		if ($notable) {
			$outstring .= "$line<br>\n";
		} else {
			$outstring .= "<td$tdclass width=\"" . $val . "\%\">$line</td>\n";
		}

		$curline++;
		$curcolumn = ($curcolumn + 1) % $ncols;
	}
	if (!$notable) { $outstring .= "</tr></table>\n"; }

	return $groupnamestring.$mansectiontext.$hierstring.$groupheadstring.$outstring.$grouptailstring;
    } else {
	return $groupnamestring.$mansectiontext.$hierstring.$groupheadstring.$inputstring.$grouptailstring;
    }
}

# /*!
#     @abstract
#         Returns the number of parts in a path.
#     @param string The path to check.
#  */
sub pathparts
{
    my $string = shift;
    my $count = 0;
    while ($string =~ s/\///) { $count++; }

	# print STDERR "PATHPARTS FOR $string: $count\n";

    return $count;
}

# /*!
#     @abstract
#         Returns whether the framework discussion is at the
#         same nesting level (pathwise) as the framework UID you
#         just read from elsewhere in that folder.
#     @discussion
#         Although not a complete guarantee, this prevents the most
#         common cause of getting the wrong framework discussion,
#         which is nesting multiple trees worth of HeaderDoc output
#         inside one another and building an outer set of docs that
#         incudes the inner set.
#  */
sub rightframework
{
    my $filename = shift;
    my $count = pathparts($filename);
    if ($frameworknestlevel == -1) {
	$frameworknestlevel = $count;
	return 1;
    }
    if ($frameworknestlevel < $count) {
	return 0;
    }
    return 1;
}

# /*!
#     @abstract
#         Takes a string containing link requests and assembles an array of just the link requests.
#     @param string
#         The input string.
#  */
sub docListFromString
{
    my $string = shift;

    my @parts = split(/<!--/, $string);
    my @list = ();

    my $lastpath = "";
    foreach my $part (@parts) {
	if ($part =~ s/^\s*a logicalPath="//s) {
		# print STDERR "PART $part\n";
		my @subparts = split(/\"/, $part, 2);
		my $uid = $subparts[0];
		my $name = $subparts[1];
		$name =~ s/^\s*-->//s;
		my $string = "<!-- a logicalPath=\"$uid\" -->$name<!-- /a -->\n";
		push(@list, $string);
	}
    }
    return @list;
}

# /*!
#     @abstract
#         Takes a string containing link requests and returns a single-column
#         table containing only the link requests.
#     @param inputstring
#         The input string.
#     @param field
#         Passed as the "settings" argument to {@link genTable}.
#  */
sub relatedDocs
{
    my $inputstring = shift;
    my $field = shift;
    my $retstring = "";
    my $tmpstring = "";

    if (length($inputstring)) {
	my @lines = docListFromString($inputstring);
	foreach my $line (@lines) {
		# print STDERR "LINE IS \"$line\"\n";
		if (length($line)) {
			$tmpstring .= $line . "\n";
		}
	}
	$tmpstring =~ s/\n$//s;

	$retstring .= genTable($tmpstring, $field, "", "");
    }
    return $retstring;
}

# /*!
#     @abstract
#         Returns a list of links to <code>\@indexgroup</code> groups
#         within the TOC.
#  */
sub groupList
{
    my $string = "";
    my $first = 1;
    my @list = groupsort(keys(%groups));
    foreach my $group (@list) {
	if ($group !~ /\S/) { next; }

	if ($first) { $first = 0; }
	else { $string .= "&nbsp;&nbsp;<span class='sectpipe'>|</span>&nbsp; \n"; }

	my $groupnospc = $group;
	$groupnospc =~ s/\s/_/sg;

	my $groupnobr = $group;
	$groupnobr =~ s/\s/&nbsp;/sg;

	$string .= "<a href=\"#group_$groupnospc\">$groupnobr</a>";
    }
    # $string .= "<br>\n";
    return $string;
}

# /*!
#     @abstract
#         Prints a list of the keys in the "letters linked" hash for debugging purposees.
#     @param arrayref
#         A reference to the "letters linked" hash.
#     @param group
#         The name of the group (for printing only).
#  */
sub printll
{
    my $arrayref = shift;
    my $group = shift;

    my %arr = %{$arrayref};
    print STDERR "FOR GROUP \"$group\"\n";
    foreach my $key (sort keys %arr) {
	print STDERR "$key\n";
    }
    print STDERR "\n";
}

# sub writeAPIOwner
# {
    # my $apioRef = shift;
    # my $file = shift;
# 
    # my $name = $apioRef->name();
    # my $type = $apioRef->type();
    # my $path = $apioRef->path();
    # my $uid = $apioRef->uid();
# 
    # print $file "<Node type="file">\n";
    # print $file "    <Name>$name</name>\n";
    # print $file "    <Path>$path</Path>\n";
    # print $file "    <Anchor>$uid</Anchor>\n";
# }

# /*!
#     @abstract
#         Generates an Xcode-compatible pair of DocSet XML files for
#         this documentation set.
#     @param outputDir
#         The input/output directory.
#  */
sub generateDocSetFile
{
    my $outputDir = shift;
    my $masterTOCFile = $outputDir.$pathSeparator.$masterTOCFileName;

# my @allFramesetRefs;
# my @headerFramesetRefs;
# my @dataFramesetRefs;
# my @macroFramesetRefs;
# my @typeFramesetRefs;
# my @comintFramesetRefs;
# my @classFramesetRefs;
# my @manpageFramesetRefs;
# my @categoryFramesetRefs;
# my @protocolFramesetRefs;
# my @functionRefs;
    # foreach my $header (@headerFramesetRefs) {
	# writeAPIOwner($header, OUTFILE);
    # }

    open(OUTFILE, ">$inputDir/Nodes.xml") || die("Could not write Nodes.xml file.\n");

    print OUTFILE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print OUTFILE "<DocSetNodes version=\"1.0\">\n";
    print OUTFILE "    <TOC>\n";
    print OUTFILE "        <Node type=\"file\">\n";
    print OUTFILE "            <Name>$framework</Name>\n";
    print OUTFILE "            <Path>$masterTOCFileName</Path>\n";
    print OUTFILE "        </Node>\n";
    print OUTFILE "    </TOC>\n";
    print OUTFILE "</DocSetNodes>\n";
    close(OUTFILE);

    open(OUTFILE, ">$inputDir/Tokens.xml") || die("Could not write Tokens.xml file.\n");
    print OUTFILE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print OUTFILE "<Tokens version=\"1.0\">\n";

    my %refToObj = ();
    my %refToRelpath = ();
    my %allRelatedRefs = ();

    foreach my $header (@fileRefSets) {
	# warn("Header: ".$header->path()."\n");
	my $path = $header->path();
	my $relPath = &findRelativePath($masterTOCFile, $path);

	my $arrayRef = $header->group();
	my @refs = @{$arrayRef};

	foreach my $ref (@refs) {
		# $ref->dbprint();
		my $uid = $ref->uid();

		# warn("Registering UID: $uid PATH: ".$ref->path()."\n");

		$uid =~ s/^"//;
		$uid =~ s/"$//;

		my $keep = 1;
		if ($refToObj{$uid}) {
			$keep = chooseBest($refToObj{$uid}, $ref, $uid);
		}
		if ($keep) {
			$refToObj{$uid} = $ref;
			$refToRelpath{$uid} = $relPath;
		}
	}
    }

    foreach my $uid (sort keys %refToObj) {
	my $ref = $refToObj{$uid};
	my $relPath = $refToRelpath{$uid};

	# warn("REF: $uid : ".$ref->path()." : $relPath\n");
	# warn("ABS: ".$ref->abstract()."\n");

	if ($uid =~ /\/\/apple_ref\/doc\//) { next; }

	print OUTFILE "<Token>\n";
	print OUTFILE "    <TokenIdentifier>$uid</TokenIdentifier>\n";

	print OUTFILE "    <Path>$relPath</Path>\n";
	my $abs = XMLTokenAbstract($ref);
	print OUTFILE "    <Abstract>$abs</Abstract>\n";

	my $dec = textToXML($ref->declaration());
	if ($dec) {
		print OUTFILE "    <Declaration>$dec</Declaration>\n";
	}
	# TODO: Availability
	my @relatedrefs = $ref->seealso();
	if (scalar(@relatedrefs)) {
		print OUTFILE "    <RelatedTokens>\n";
		foreach my $ref (@relatedrefs) {
			print OUTFILE "        <TokenIdentifier>$ref</TokenIdentifier>\n";
			$allRelatedRefs{$ref} = $ref;
		}
		print OUTFILE "    </RelatedTokens>\n";
	}
	print OUTFILE "</Token>\n";
    }

    foreach my $ref (sort keys %allRelatedRefs) {
	my $refobj = $refToObj{$ref};

	my $title = XMLTokenAbstract($refobj);

	print OUTFILE "        <RelatedTokens title=\"$title\">\n";
	print OUTFILE "             <TokenIdentifier>$ref</TokenIdentifier>\n";
	print OUTFILE "        </RelatedTokens>\n";
    }

    print OUTFILE "</Tokens>\n";

    close(OUTFILE);
}

# /*!
#     @abstract
#         Sorts the names of groups.
#     @param \@_
#         The names to sort.
#     @discussion
#         This forces the "Section legacy" to appear after all of
#         the numeric man page sections when processing manual pages.
#         For all other cases, it just does a simple sort.
#  */
sub groupsort(@)
{
    my @arr = @_;
    # foreach my $temp (@arr) { print STDERR "GROUP: $temp\n"; }

    if ($manPageMode) {
	my @resorted = ();
	my $seenLegacy = 0;
	foreach my $group (sort @arr) {
		if ($group eq "Section legacy") {
			$seenLegacy = 1;
		} else {
			push(@resorted, $group);
		}
	}
	if ($seenLegacy) {
		push(@resorted, "Section legacy");
	}
	return @resorted;
    } else {
	return sort @arr;
    }

}

# /*!
#     @abstract
#         Converts a string of text to XML (minimally).
#  */
sub textToXML
{
    my $textdata = shift;

    $textdata =~ s/&/&amp;/sgo;
    $textdata =~ s/</&lt;/sgo;
    $textdata =~ s/>/&gt;/sgo;

    return $textdata;
}

# /*!
#     @abstract
#         Returns the abstract that goes into the Tokens.xml file.
#     @discussion
#         This returns the abstract if there was one, stripping off
#         any HTML tags in the process.  If there is no abstract,
#         it attempts to scrape the first paragraph from the
#         discussion.
#  */
sub XMLTokenAbstract
{
	my $ref = shift;

	my $abs = stripTags($ref->abstract());
	$abs =~ s/\s+/ /sg;
	$abs =~ s/"/&#34;/sg;
	if ($abs) {
		return $abs;
	} else {
		# Punt and use the discussion
		my $disc = stripTags($ref->discussion());

		# Strip leading newlines.
		$disc =~ s/^[\n\r]*//s;

		# Limit to one paragraph.
		$disc =~ s/\n\n.*$//s;
		if ($disc) {
			return $disc;
		}
	}
	return "";
}

# /*!
#     @abstract
#         Chooses the best object for a UID.
#     @discussion
#         Used by the doc set generation code to choose which HTML file to
#         associate with a given apple_ref in the event of a conflict.
#
#         This is primarily used when generating manual page content because
#         multiple manual pages often describe the same functions.  In
#         general, apple_ref tags should always be unique.  Do not rely
#         on this logic remaining as it is today.
#     @param firstObj
#         The first {@link //apple_ref/perl/cl/HeaderDoc::DocReference DocReference} object to compare.
#     @param secondObj
#         The second {@link //apple_ref/perl/cl/HeaderDoc::DocReference DocReference} object to compare.
#     @param uid
#         The uid in question.
#  */
sub chooseBest($$$)
{
	my $firstObj = shift;
	my $secondObj = shift;
	my $uid = shift;

	my $localDebug = 0;

	my @uidparts = split(/\//, $uid);
	my $count = scalar(@uidparts);
	my $pos = $count;

	# There are 2 bogus leading parts due to the leading //.
	if ($count == 2 + 7) {
		# e.g. intfm, instm, clm, etc. w/ signature and return type
		$pos = $count - 2;
	# } elsif ($count == 2 + 5) {
		# e.g. structs and vars in classes, etc.
		# $pos = $count;
	}

	my $name = $uidparts[$count - 1];

	# For example, foo matches blah/foo.html first.
	if ($firstObj->path =~ /\/\Q$name\E\./) {
		warnRetCause($uid, $firstObj, $secondObj, "$name is ideal (/$name\./).") if ($localDebug);
		return $firstObj;
	}
	if ($secondObj->path =~ /\/\Q$name\E\./) {
		warnRetCause($uid, $secondObj, $firstObj, "$name is ideal (/$name\./).") if ($localDebug);
		return $secondObj;
	}

	# For example, foo matches blah/foo or blah/foo/ next.
	if ($firstObj->path =~ /\/\Q$name\E(\/|$)/) {
		warnRetCause($uid, $firstObj, $secondObj, "$name is a path component (\/$name\/).") if ($localDebug);
		return $firstObj;
	}
	if ($secondObj->path =~ /\/\Q$name\E(\/|$)/) {
		warnRetCause($uid, $secondObj, $firstObj, "$name is a path component (\/$name\/).") if ($localDebug);
		return $secondObj;
	}

	# Check on any arbitrary word boundaries next.
	if ($firstObj->path =~ /\b\Q$name\E\b/) {
		warnRetCause($uid, $firstObj, $secondObj, "$name is between word boundaries.") if ($localDebug);
		return $firstObj;
	}
	if ($secondObj->path =~ /\b\Q$name\E\b/) {
		warnRetCause($uid, $secondObj, $firstObj, "$name is between word boundaries.") if ($localDebug);
		return $secondObj;
	}

	# Check on a leading word boundary next.
	if ($firstObj->path =~ /\b\Q$name\E/) {
		warnRetCause($uid, $firstObj, $secondObj, "$name starts at a word boundary (with trailing garbage).") if ($localDebug);
		return $firstObj;
	}
	if ($secondObj->path =~ /\b\Q$name\E/) {
		warnRetCause($uid, $secondObj, $firstObj, "$name starts at a word boundary (with trailing garbage).") if ($localDebug);
		return $secondObj;
	}

	# Check anywhere in the path.
	if ($firstObj->path =~ /\Q$name\E/) {
		warnRetCause($uid, $firstObj, $secondObj, "$name is in the path.") if ($localDebug);
		return $firstObj;
	}
	if ($secondObj->path =~ /\Q$name\E/) {
		warnRetCause($uid, $secondObj, $firstObj, "$name is in the path.") if ($localDebug);
		return $secondObj;
	}

	# Punt
	warn("Punting\n") if ($localDebug);
	return $firstObj;
}

# /*!
#     @abstract
#         Helper function to simplify warning code used for debugging
#         {@link chooseBest}.
#  */
sub warnRetCause($$$)
{
	my $uid = shift;
	my $obj = shift;
	my $overobj = shift;
	my $reason = shift;

	warn("Chose ".$obj->path()." ($obj) over ".$overobj->path()." ($overobj) for $uid because $reason\n");
}


#! /usr/bin/perl -w
#
# Class name: Test
# Synopsis: Test Harness
#
# Last Updated: $Date: 2014/02/26 11:18:59 $
#
# Copyright (c) 2008 Apple Computer, Inc.  All rights reserved.
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
#         <code>Test</code> class package file.
#     @discussion
#         This file contains the <code>Test</code> class, a class used for
#         testing the HeaderDoc parser and related routines.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Test framework for parser and C preprocessor tests.
#     @discussion
#         The <code>Test</code> class is a test framework for
#         testing the HeaderDoc parser and related routines.
#         Each test file is a freeze-dried instance of this
#         class that is loaded by
#  {@link //apple_ref/doc/header/headerDoc2HTML.pl headerDoc2HTML.pl}.
#
#     @var FILENAME
#         Filename for this test.  Derived from <code>NAME</code>.
#     @var NAME
#         Name of this test.
#     @var TYPE
#         The type of test.  Currently either <code>parser</code>
#         or <code>cpp</code>.
#     @var LANG
#         The programming language for the test.
#     @var SUBLANG
#         The programming language variant for the test.  Usually
#         same as the language, but may differ for languages built
#         on other languages, e.g. <code>javascript</code> or
#         <code>MIG</code>.  C language derivatives, in particular,
#         are <b>not</b> specified more precisely; the parser changes
#         languages as it enters a class block.
#     @var COMMENT
#         The HeaderDoc comment block associated with this test.
#         Used only for parser tests.  Empty for C preprocessor
#         tests.
#     @var CPPCODE
#         The C preprocessor macros to parse; used to modify
#         the declaration in <code>CODE</code>.  Used only
#         in C preprocessor tests.  Empty for parser tests.
#     @var CODE
#         The actual code to parse.
#     @var RESULT
#         The actual test results.  Filled in automatically
#         by {@link runtest_sub}.  Because this should always
#         match the expected results, this field should never be
#         serialized to disk.
#     @var EXPECTED_RESULT
#         The expected test results.  During test creation, this is
#         filled in by running the test once, ignoring the test
#         failure, and copying the obtained results into this field
#         from <code>RESULT</code>.
#     @var RESULT_ALLDECS
#         The actual test results for "all declarations" mode (equivalent to
#         passing the <code>-E</code> flag).  Filled in automatically
#         by {@link runtest_sub}.  Because this should always
#         match the expected results, this field should never be
#         serialized to disk.
#     @var EXPECTED_RESULT_ALLDECS
#         The expected test results.  During test creation, this is
#         filled in by running the test once, ignoring the test
#         failure, and copying the obtained results into this field
#         from <code>RESULT_ALLDECS</code>.
#     @var FILTERED_RESULT
#         A filtered copy of the actual result after applying
#         a series of regular expressions to ignore parts of the
#         results.  Used for simplifying comparison when a
#         particular type of change is expected.  This is
#         temporary data that should never be serialized to disk.
#     @var EXPECTED_FILTERED_RESULT
#         A filtered copy of the expected result after applying
#         a series of regular expressions to ignore parts of the
#         results.  Used for simplifying comparison when a
#         particular type of change is expected.  This is
#         temporary data that should never be serialized to disk.
#     @var FILTERED_RESULT_ALLDECS
#         A filtered copy of the actual "all declarations" result after applying
#         a series of regular expressions to ignore parts of the
#         results.  Used for simplifying comparison when a
#         particular type of change is expected.  This is
#         temporary data that should never be serialized to disk.
#     @var EXPECTED_FILTERED_RESULT_ALLDECS
#         A filtered copy of the expected "all declarations" result after applying
#         a series of regular expressions to ignore parts of the
#         results.  Used for simplifying comparison when a
#         particular type of change is expected.  This is
#         temporary data that should never be serialized to disk.
#     @var FAILMSG
#         A message to display if the test fails.  This can be used
#         to provide additional information about what functionality
#         the test covers.
#  */
package HeaderDoc::Test;


# /*!
#     @abstract
#         Set to 1 if HeaderDoc is currently running a test, else 0.
#     @discussion
#         Disables lots of warnings caused by imperfect test data
#         while the tests are running.
#  */
$HeaderDoc::running_test = 0;


use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash unregisterUID registerUID sanitize parseTokens unregister_force_uid_clear dereferenceUIDObject filterHeaderDocTagContents validTag stringToFields processHeaderComment getLineArrays getAbsPath allow_everything getAvailabilityMacros stripLeading );
use File::Basename;
use strict;
use vars qw($VERSION @ISA);
use Cwd;
use Carp qw(cluck);
use HeaderDoc::Utilities qw(processTopLevel);
use HeaderDoc::BlockParse qw(blockParseOutside blockParse getAndClearCPPHash);

# print STDERR "Do we have FreezeThaw?  ".($HeaderDoc::FreezeThaw_available ? "yes" : "no")."\n";

if ($HeaderDoc::FreezeThaw_available) {
	eval "use FreezeThaw qw(freeze thaw)";
}

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::Test::VERSION = '$Revision: 1393442339 $';

# /*!
#     @abstract
#         Enables "all decs" support in the test module.
#
#     @discussion
#         For now, this should be zero.  In addition to some
#         languages being ostensibly "supported" by alldecs but
#         not being perfectly supported in that mode (Perl,
#         Pascal), there's also the problem of a bunch of tests
#         whose results change radically that I just don't have
#         time to hand-verify.  (TODO: DAG: FIXME)
#
#         Also, there are tests that probably will have to be
#         significantly modified because declarations that are
#         not currently being parsed will suddenly get parsed,
#         resulting in lots of apple_ref conflicts and other
#         such madness.  In short, it's a major effort that will
#         have to wait a bit.
# */
$HeaderDoc::test_alldecs = 0;   # Here, there be dragons.

# /*!
#     @abstract
#         Creates a new <code>Test</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::Test->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my $param = shift;
    my $class = ref($param) || $param;
    my $self = {};
    
    bless($self, $class);
    $self->_initialize();
    # Now grab any key => value pairs passed in
    my (%attributeHash) = @_;
    foreach my $key (sort keys(%attributeHash)) {
	$self->{$key} = $attributeHash{$key};
    }
    $self->{FILENAME} = $self->{NAME};
    $self->{FILENAME} =~ s/[^a-zA-Z0-9_.,-]/_/sg;
    $self->{FILENAME} .= ".test";

    # $self->dbprint();
    return $self;
}

# /*!
#     @abstract
#         Initializes an instance of a <code>Test</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my $self = shift;

    $self->{FILENAME} = undef;
    $self->{FAILMSG} = undef;
    $self->{NAME} = undef;
    $self->{TYPE} = undef;
    $self->{LANG} = undef;
    $self->{SUBLANG} = undef;
    $self->{COMMENT} = undef;
    $self->{CPPCODE} = undef;
    $self->{CODE} = undef;
    $self->{RESULT} = undef;
    $self->{RESULT_ALLDECS} = undef;
    $self->{EXPECTED_RESULT} = undef;
    $self->{EXPECTED_RESULT_ALLDECS} = undef;
}

# /*!
#     @abstract
#         Runs this test.
#     @param self
#         The test instance.
#     @result
#         Returns 0 on success, 1 if the test fails.
#  */
sub runTest {
    my $self = shift;
    my $filterref = shift;

    $HeaderDoc::running_test = 1;
    my $coretestfail = $self->runtest_sub(0);
    if ($self->supportsAllDecs()) {
	my $coretestfail_b = $self->runtest_sub(1);
	$coretestfail = $coretestfail || $coretestfail_b;
    }
    $HeaderDoc::running_test = 0;

    $self->{EXPECTED_FILTERED_RESULT} = filterResults($self->{EXPECTED_RESULT}, $filterref);
    $self->{EXPECTED_FILTERED_RESULT_ALLDECS} = filterResults($self->{EXPECTED_RESULT_ALLDECS}, $filterref);
    $self->{FILTERED_RESULT} = filterResults($self->{RESULT}, $filterref);
    $self->{FILTERED_RESULT_ALLDECS} = filterResults($self->{RESULT_ALLDECS}, $filterref);

    return $coretestfail;
}

# /*!
#     @abstract
#         Filters out bits of the test results for comparison purposes.
#  */
sub filterResults
{
    my $data = shift;
    my $filterref = shift;

    if (!$filterref) {
	return $data;
    }
    my @filters = @{$filterref};

    foreach my $filter (@filters) {
	print STDERR "FILTERING WITH s/$filter//sg\n";
	$data =~ s/$filter//sg;
    }
    return $data;
}

# /*!
#     @abstract
#         Runs this test in the specified mode.
#     @param self
#         The test instance.
#     @param alldecs
#         Pass 0 to run the test normally.
#
#         Pass 1 to run the test with the equivalent of
#         the <code>-E</code> command-line flag.
#     @result
#         Returns 0 on success, 1 if the test fails.
#  */
sub runtest_sub {
    my $self = shift;
    my $alldecs = shift;

    my $results = "";

    my $testDebug = 0;

# print "AD: $alldecs\n";

    my $hashtreecur = undef;
    my $hashtreeroot = undef;

    my $prevignore = $HeaderDoc::ignore_apiuid_errors;
    $HeaderDoc::ignore_apiuid_errors = 1;
    # $HeaderDoc::curParserState = undef;
    use strict;

    $HeaderDoc::globalGroup = "";
    $HeaderDoc::dumb_as_dirt = 0;
    $HeaderDoc::parse_javadoc = 1;
    $HeaderDoc::IncludeSuper = 0;
    $HeaderDoc::ClassAsComposite = 1;
    $HeaderDoc::process_everything = $alldecs;
    $HeaderDoc::align_columns = 0;
    $HeaderDoc::groupright = 1;
    $HeaderDoc::ignore_apiowner_names = 0;
    $HeaderDoc::add_link_requests = 1;
    $HeaderDoc::truncate_inline = 0;
    $HeaderDoc::enableParanoidWarnings = 0;
    $HeaderDoc::outerNamesOnly = 0;
    $HeaderDoc::AccessControlState = "";

    $HeaderDoc::OptionalOrRequired = "";

    $HeaderDoc::idl_language = "idl";
    %HeaderDoc::availability_defs = ();
    %HeaderDoc::availability_has_args = ();

    # warn "MP: ".$HeaderDoc::modulesPath."Availability.list\n";
    if ( -f $HeaderDoc::modulesPath."../../Availability.list") {
	getAvailabilityMacros($HeaderDoc::modulesPath."../../Availability.list", 1);
    } else {
	getAvailabilityMacros($HeaderDoc::modulesPath."Availability.list", 1);
    }

    my $basefilename = basename($self->{FILENAME});
    my $coretestfail = 0;

    my $fullpath=getAbsPath($self->{FILENAME});

    if (! -f $fullpath ) {
	$coretestfail = 1;
    }

    $fullpath=getAbsPath($self->{FILENAME});
    if (! -f $fullpath ) {
	$coretestfail = 1;
    }

    $fullpath="/test_suite_bogus_path/".$basefilename;

    my @temp = ();
    $HeaderDoc::perHeaderRanges{$fullpath} = \@temp;

    my ($cpp_hash_ref, $cpp_arg_hash_ref) = getAndClearCPPHash();

    my @commentLines = split(/\n/, $self->{COMMENT});
    map(s/$/\n/gm, @commentLines);

    # Set up some stuff for the line array code to filter the comment.
    # $HeaderDoc::nodec = 0;

    HeaderDoc::APIOwner->apiUIDPrefix("test_ref");

    $HeaderDoc::lang = $self->{LANG};
    $HeaderDoc::sublang = $self->{SUBLANG};

    my $apiOwner = HeaderDoc::Header->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
    $apiOwner->apiOwner($apiOwner);
    my $headerObject = $apiOwner;
    $HeaderDoc::headerObject = $headerObject;
    $HeaderDoc::currentClass = undef;
    $apiOwner->filename($basefilename);
    $apiOwner->fullpath($fullpath);
    $apiOwner->name($self->{NAME});

    %HeaderDoc::ignorePrefixes = ();
    %HeaderDoc::perHeaderIgnorePrefixes = ();
    %HeaderDoc::perHeaderIgnoreFuncMacros = ();

    HeaderDoc::Utilities::loadhashes($alldecs);

    print STDERR "LANG: $self->{LANG} SUBLANG: $self->{SUBLANG}\n" if ($testDebug);

    print STDERR "Filtering comment\n" if ($testDebug);

    # Filter the comment.
    my @commentLineArray = &getLineArrays(\@commentLines, $self->{LANG}, $self->{SUBLANG});
    my $comment = "";
    foreach my $arr (@commentLineArray) {
	foreach my $item (@$arr) {
	    my $localDebug = 0;
	    if (($self->{LANG} ne "pascal" && $self->{LANG} ne "ruby" && $self->{LANG} ne "python" && (
                             ($self->{LANG} ne "perl" && $self->{LANG} ne "tcl" && $self->{LANG} ne "shell" && $item =~ /^\s*\/\*\!/o) ||
                             (($self->{LANG} eq "perl" ||  $self->{LANG} eq "tcl" || $self->{LANG} eq "shell") && ($item =~ /^\s*\#\s*\/\*\!/o)) ||
                             (($self->{LANG} eq "java" || $HeaderDoc::parse_javadoc) && ($item =~ /^\s*\/\*\*[^\*]/o)))) ||
                            (($self->{LANG} eq "applescript") && ($item =~ s/^\s*\(\*!/\/\*!/so)) ||
                            (($self->{LANG} eq "pascal") && ($item =~ s/^\s*\{!/\/\*!/so)) ||
			    ($self->{LANG} eq "ruby") || ($self->{LANG} eq "python")) {

		if (($self->{LANG} ne "pascal" && $self->{LANG} ne "applescript" && ($item =~ /\s*\*\//o)) ||
                                    ($self->{LANG} eq "applescript" && ($item =~ s/\s*\*\)/\*\//so)) ||
                                    ($self->{LANG} eq "pascal" && ($item =~ s/\s*\}/\*\//so))) { # closing comment marker on same line
                                       print STDERR "PASCAL\n" if ($localDebug);
			if ($self->{LANG} eq "perl" || $self->{LANG} eq "shell" || $self->{LANG} eq "tcl" ) {
						$item = stripLeading($item, "#");
						# $item =~ s/^#//s; # Strip off the '#' added by getLineArrays() here.

						# No longer needed.
                                                # $item =~ s/^\s*\#//s; 
                                                # $item =~ s/\n( |\t)*\#/\n/sg; # Handled for us in getLineArrays() now.
                                                # print STDERR "NEWLINE: $item\n";
			}
		} else {
			$item =~ s/^ \*//o;
			if ($self->{LANG} eq "perl" || $self->{LANG} eq "shell" || $self->{LANG} eq "tcl") {
						    print STDERR "SHELL OR PERL\n" if ($localDebug);

						    $item = stripLeading($item, "#");

						    # $item =~ s/^#//s; # Strip off the '#' added by getLineArrays() here.

						    # No longer needed.
                                                    # $item =~ s/^\s*\#//o;
print STDERR "ITEM NOW $item\n" if ($localDebug);
                        }
		}
	    }
	    $comment .= $item; #$commentLineArray[0][0];
	}
    }

    if (($self->{LANG} eq "ruby") || ($self->{LANG} eq "python")) {
	# Ruby and Python blocks in tests need to just be the bare contents of the
	# comment block because it isn't worth duplicating the parsing machinery here.
	$comment = "/*! ".$comment;
    }

# print("COMMENT: $comment\n");


    if ($comment =~ /^\s*\/\*\*/s) {
	$comment =~ s/\s*\/\*\*/\/\*\!/s;
    }
    if ($comment =~ /^\s*\/\*!/s) {
	$comment =~ s/\*\/\s*$//s;
    }
    $comment =~ s/^\s*//s;
    # print STDERR "COM: $comment\n";

    # Try the top level comment parser code and see what we get.
    my ($inHeader, $inClass, $inInterface, $inCPPHeader, $inOCCHeader, $inPerlScript, $inShellScript, $inPHPScript, $inJavaSource, $inFunctionGroup, $inGroup, $inFunction, $inPDefine, $inTypedef, $inUnion, $inStruct, $inConstant, $inVar, $inEnum, $inMethod, $inAvailabilityMacro, $inUnknown, $classType, $line, $inputCounter, $blockOffset, $junkpath, $linenumdebug, $localDebug);
    if ($self->{TYPE} eq "parser") {
	print STDERR "Running top-level comment parser (case a)\n" if ($testDebug);

	($inHeader, $inClass, $inInterface, $inCPPHeader, $inOCCHeader, $inPerlScript, $inShellScript, $inPHPScript, $inJavaSource, $inFunctionGroup, $inGroup, $inFunction, $inPDefine, $inTypedef, $inUnion, $inStruct, $inConstant, $inVar, $inEnum, $inMethod, $inAvailabilityMacro, $inUnknown, $classType, $line, $inputCounter, $blockOffset, $junkpath, $linenumdebug, $localDebug) = processTopLevel(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "unknown", $comment, 0, 0, $fullpath, 0, 0);
    } else {
	print STDERR "Running top-level comment parser (case b)\n" if ($testDebug);

	($inHeader, $inClass, $inInterface, $inCPPHeader, $inOCCHeader, $inPerlScript, $inShellScript, $inPHPScript, $inJavaSource, $inFunctionGroup, $inGroup, $inFunction, $inPDefine, $inTypedef, $inUnion, $inStruct, $inConstant, $inVar, $inEnum, $inMethod, $inAvailabilityMacro, $inUnknown, $classType, $line, $inputCounter, $blockOffset, $junkpath, $linenumdebug, $localDebug) = processTopLevel(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "unknown", "/*! CPP only */", 0, 0, $fullpath, 0, 0);
    }

    if ($self->{TYPE} eq "parser") {
	$results .= "-=: TOP LEVEL COMMENT PARSE VALUES :=-\n";
	$results .= "inHeader: $inHeader\n";
	$results .= "inClass: $inClass\n";
	$results .= "inInterface: $inInterface\n";
	$results .= "inCPPHeader: $inCPPHeader\n";
	$results .= "inOCCHeader: $inOCCHeader\n";
	$results .= "inPerlScript: $inPerlScript\n";
	$results .= "inShellScript: $inShellScript\n";
	$results .= "inPHPScript: $inPHPScript\n";
	$results .= "inJavaSource: $inJavaSource\n";
	$results .= "inFunctionGroup: $inFunctionGroup\n";
	$results .= "inGroup: $inGroup\n";
	$results .= "inFunction: $inFunction\n";
	$results .= "inPDefine: $inPDefine\n";
	$results .= "inTypedef: $inTypedef\n";
	$results .= "inUnion: $inUnion\n";
	$results .= "inStruct: $inStruct\n";
	$results .= "inConstant: $inConstant\n";
	$results .= "inVar: $inVar\n";
	$results .= "inEnum: $inEnum\n";
	$results .= "inMethod: $inMethod\n";
	$results .= "inAvailabilityMacro: $inAvailabilityMacro\n";
	$results .= "inUnknown: $inUnknown\n";
	$results .= "classType: $classType\n";
	$results .= "inputCounter: $inputCounter\n";
	$results .= "blockOffset: $blockOffset\n";
	$results .= "fullpath: $junkpath\n";
    }

    if ($inGroup || $inFunctionGroup) {
	print STDERR "Processing group info.\n" if ($testDebug);

	my $debugging = 0;
	my $xml_mode = 0;
	my $fieldref = stringToFields($comment, $fullpath, $inputCounter, $xml_mode, $self->{LANG}, $self->{SUBLANG});
	my @fields = @{$fieldref};
	my $line = $comment;

	print STDERR "inGroup\n" if ($debugging);
	my $rawname = $line;
	my $type = "";
	if ($inGroup) {
		$rawname =~ s/.*\/\*!\s*\@(group|name)\s+//sio;
		$type = $1;
	} else {
		if (!($rawname =~ s/.*\/\*!\s+\@(functiongroup)\s+//io)) {
			$rawname =~ s/.*\/\*!\s+\@(methodgroup)\s+//io;
			print STDERR "inMethodGroup\n" if ($debugging);
		}
		$type = $1;
	}
	# $rawname =~ s/\s*\*\/.*//o;
	# my ($name, $desc, $is_nameline_disc) = getAPINameAndDisc($rawname, $self->lang());
	# $name =~ s/^\s+//smgo;
	# $name =~ s/\s+$//smgo;

	# if ($is_nameline_disc) { $name .= " ".$desc; $desc = ""; }


	my $group = HeaderDoc::Group->new("LANG" => $self->{LANG}, "SUBLANG" => $self->{SUBLANG});
	$group->apiOwner($apiOwner);
	$group = $group->processComment(\@fields);

	print STDERR "group name is ".$group->name()."\n" if ($debugging);

	$apiOwner->addGroup($group); #(, $desc);
	# $group->processComment(\@fields);

	if (!$inGroup) {
		$HeaderDoc::globalGroup = $group->name();
	}

	# $inputCounter--;
	# print STDERR "DECREMENTED INPUTCOUNTER [M6]\n" if ($HeaderDoc::inputCounterDebug);

	$results .= "-=: GROUP INFO :=-\n";
	$results .= "request type => ".$type."\n";
	$results .= "name => ".$group->name()."\n";
	$results .= "Description => ".$group->discussion."\n";
    } else {
	print STDERR "Getting line arrays.\n" if ($testDebug);

	my @perHeaderClassObjects = ();
	my @perHeaderCategoryObjects = ();
	my @fields = ();
	my $hangDebug = my $parmDebug = my $blockDebug = 0;
	my $allow_multi = 1;
	my $subparse = 0;
	my $subparseTree = undef;
	my $cppAccessControlState = "protected:"; # the default in C++
	my $objcAccessControlState = "private:"; # the default in Objective C
	my $functionGroup = "default_function_group";

	if ($HeaderDoc::sublang eq "IDL") {
		$cppAccessControlState = "public:"; # IDLs have no notion of protection, typically.
	}

	my @codeLines = split(/\n/, $self->{CODE});
	map(s/$/\n/gm, @codeLines);
	my @codeLineArray = &getLineArrays(\@codeLines, $self->{LANG}, $self->{SUBLANG});
	my $arrayRef = @codeLineArray[0];
	my @inputLines = @$arrayRef;

	my @cppLines = split(/\n/, $self->{CPPCODE});
	map(s/$/\n/gm, @cppLines);
	my @cppLineArray = &getLineArrays(\@cppLines, $self->{LANG}, $self->{SUBLANG});
	$arrayRef = @cppLineArray[0];
	my @cppInputLines = @$arrayRef;

	my $preAtPart = "";
	my $xml_output = 0;

	# Old code.
	# my @inputLines = split(/\n/, $self->{CODE});
	# map(s/$/\n/gm, @inputLines);
	# my @cppInputLines = split(/\n/, $self->{CPPCODE});
	# map(s/$/\n/gm, @cppInputLines);

	my ($case_sensitive, $keywordhashref) = $headerObject->keywords();

	my $inputCounter = 0;

	# print STDERR "TYPE: $self->{TYPE}\n";
	$HeaderDoc::enable_cpp = 1;
	if ($self->{TYPE} eq "cpp") {
		print STDERR "Running blockParse (CPP mode).\n" if ($testDebug);


		$results .= "-=: CPP MACROS PARSED :=-\n";
		while ($inputCounter <= $#cppInputLines) {
			my ($newcount, $declaration, $typelist, $namelist, $posstypes, $value, $pplref, $returntype, $pridec, $parseTree, $simpleTDcontents, $bpavail, $blockOffset, $conformsToList, $functionContents, $parserState, $nameObjectsRef) = &blockParse($fullpath, $blockOffset, \@cppInputLines, $inputCounter, 0, \%HeaderDoc::ignorePrefixes, \%HeaderDoc::perHeaderIgnorePrefixes, \%HeaderDoc::perHeaderIgnoreFuncMacros, $keywordhashref, $case_sensitive, $self->{LANG}, $self->{SUBLANG});
			if ($declaration !~ /\S/) { last; }
			$results .= "PARSED: $namelist\n";
			$inputCounter = $newcount;
		}
		$results .= "\n";
	}

	print STDERR "Running blockParse.\n" if ($testDebug);

	my $blockOffset = $inputCounter;
	$inputCounter = 0;
	my ($newcount, $declaration, $typelist, $namelist, $posstypes, $value, $pplref, $returntype, $pridec, $parseTree, $simpleTDcontents, $bpavail, $blockOffset, $conformsToList, $functionContents, $parserState, $nameObjectsRef, $extendsClass, $implementsClass) = &blockParse($fullpath, $blockOffset, \@inputLines, $inputCounter, 0, \%HeaderDoc::ignorePrefixes, \%HeaderDoc::perHeaderIgnorePrefixes, \%HeaderDoc::perHeaderIgnoreFuncMacros, $keywordhashref, $case_sensitive, $self->{LANG}, $self->{SUBLANG});

	$results .= "-=: BLOCKPARSE PARSER STATE KEYS :=-\n";
	my @pskeys = sort keys %{$parserState};
	foreach my $key (@pskeys) {
		if ($key !~ /(pplStack|hollow|lastDisplayNode|lastTreeNode|freezeStack|parsedParamList|braceStack|treeStack|endOfTripleQuoteToken|rollbackState|availabilityNodesArray|parsedParamAtBrace|parsedParamStateAtBrace)/) {
			$results .= "\$parserState->{$key} => ".$parserState->{$key}."\n";
		} else {
			my $temp = $parserState->{$key};
			$temp =~ s/0x[0-9a-f]+/OBJID/sg;
			$results .= "\$parserState->{$key} => ".$temp."\n";
		}
    	}
	$results .= "-=: BLOCKPARSE RETURN VALUES :=-\n";
	$results .= "newcount: $newcount\n";
	$results .= "typelist: $typelist\n";
	$results .= "namelist: $namelist\n";
	$results .= "posstypes: $posstypes\n";
	$results .= "value: $value\n";
	$results .= "returntype: $returntype\n";
	$results .= "pridec: $pridec\n";
	$results .= "simpleTDcontents: $simpleTDcontents\n";
	$results .= "bpavail: $bpavail\n";
	$results .= "blockOffset: $blockOffset\n";
	$results .= "conformsToList: $conformsToList\n";
	$results .= "functionContents: $functionContents\n";
	$results .= "extendsClass: $extendsClass\n";
	$results .= "implementsClass: $implementsClass\n";

	# Legacy declaration.
	# $results .= "declaration: $declaration\n";

	# Parsed parameters list (array)
	# $results .= "pplref: $pplref\n";
	my @parsedParamList = @{$pplref};

	$results .= "-=: LIST OF PARSED PARAMETERS :=-\n";
	my $count = 0;
	foreach my $ppl (@parsedParamList) {
		$results .= "Parsed Param $count => $ppl\n";
		$count++;
	}

	# Parse tree (data structure)
	# parseTree: $parseTree
	$results .= "-=: DUMP OF PARSE TREE :=-\n";
	$results .= $parseTree->test_output_dump();

	$results .= "-=: COMPUTED VALUE :=-\n";
	my ($success, $value) = $parseTree->getPTvalue();
	$results .= "SUCCESS: $success\n";
	$results .= "VALUE: $value\n";

	$results .= "-=: CPP CHANGES :=-\n";
	$results .= $self->cppTests();

# print STDERR "RESULTS: $results\n";

	my $lang = $self->{LANG};
	my $sublang = $self->{SUBLANG};

	if ($self->{TYPE} eq "parser") {
		# Only do this for parser tests.

		print STDERR "Running stringToFields.\n" if ($testDebug);

		my $xml_mode = 0;
		my $fieldref = stringToFields($comment, $fullpath, $inputCounter, $xml_mode, $lang, $sublang);
		@fields = @{$fieldref};

		if ($inHeader) {
			my $rootOutputDir = "/tmp/bogus";
			my $debugging = 0;
			my $reprocess_input = 0;

			print STDERR "Running processHeaderComment.\n" if ($testDebug);

			($lang, $sublang) = processHeaderComment($apiOwner, $rootOutputDir, \@fields, $debugging, \$reprocess_input, $lang, $sublang);
		}

		print STDERR "Running blockParseOutside.\n" if ($testDebug);

		# Reset any language changes that may have occurred.
		$HeaderDoc::sublang = $self->{SUBLANG};

		my $nodec = 0; # $HeaderDoc::nodec

		print STDERR "my (\$newInputCounter, \$cppAccessControlState, \$classType, \$classref, \$catref, \$blockOffset, \$numcurlybraces, \$foundMatch, \$newlang, \$newsublang, \$hashtreecur, \$hashtreeroot) =
		    blockParseOutside($apiOwner, $inFunction, $inUnknown,
		    $inTypedef, $inStruct, $inEnum, $inUnion,
		    $inConstant, $inVar, $inMethod, $inPDefine,
		    $inClass, $inInterface, $blockOffset, \@perHeaderCategoryObjects,
		    \@perHeaderClassObjects, $classType, $cppAccessControlState,
		    \@fields, $fullpath, $functionGroup,
		    $headerObject, $inputCounter, \@inputLines,
		    $self->{LANG}, $#inputLines, $preAtPart, $xml_output, $localDebug,
		    $hangDebug, $parmDebug, $blockDebug, $subparse,
		    $subparseTree, $nodec, $allow_multi, undef, $self->{SUBLANG},
		    $hashtreecur, $hashtreeroot);\n" if ($testDebug);
		print STDERR "FIELDS:\n" if ($testDebug);
		print "FIRSTLINE: ".$inputLines[$inputCounter]."\n" if ($testDebug);
		printArray(@fields) if ($testDebug);

		# print STDERR "IN TEST APIO: $apiOwner\n";
		my ($newInputCounter, $cppAccessControlState, $classType, $classref, $catref, $blockOffset, $numcurlybraces, $foundMatch, $newlang, $newsublang, $hashtreecur, $hashtreeroot) =
		    blockParseOutside($apiOwner, $inFunction, $inUnknown,
		    $inTypedef, $inStruct, $inEnum, $inUnion,
		    $inConstant, $inVar, $inMethod, $inPDefine,
		    $inClass, $inInterface, $blockOffset, \@perHeaderCategoryObjects,
		    \@perHeaderClassObjects, $classType, $cppAccessControlState,
		    \@fields, $fullpath, $functionGroup,
		    $headerObject, $inputCounter, \@inputLines,
		    $self->{LANG}, $#inputLines, $preAtPart, $xml_output, $localDebug,
		    $hangDebug, $parmDebug, $blockDebug, $subparse,
		    $subparseTree, $nodec, $allow_multi, undef, $self->{SUBLANG},
		    $hashtreecur, $hashtreeroot);


		# print STDERR "NUM CLASSES: ".scalar($apiOwner->classes())."\n";

		if ($alldecs && ($HeaderDoc::test_alldecs || $self->{LANG} eq "tcl")) {
		    my $adLoopDebug = 0;
		    print STDERR "alldecs test in TCL\n" if ($localDebug || $adLoopDebug);
		    print STDERR "$newInputCounter < $#inputLines\n" if ($localDebug || $adLoopDebug);
		    my $loopIC = $newInputCounter;
		    ### $loopIC++; # Why is this needed!?! @@@
		    $loopIC++;
		    while ($loopIC <= $#inputLines) {
			my $junk1; my $junk2; my $junk3; my $junk4; my $junk5; my $junk6; my $junk7; my $junk8;

			print STDERR "pre-BPO.  LOOPIC: $loopIC\n" if ($localDebug || $adLoopDebug);
			print STDERR "NEXT LINE: ".$inputLines[$loopIC]."\n" if ($localDebug || $adLoopDebug);
			# print STDERR "NEWSUBLANG WAS $newsublang\n";
			($loopIC, $junk1, $junk2, $junk3, $junk4, $junk5, $junk6, $junk7, $newlang, $newsublang, $hashtreecur, $hashtreeroot) =
			    blockParseOutside($apiOwner, $inFunction, $inUnknown,
			    $inTypedef, $inStruct, $inEnum, $inUnion,
			    $inConstant, $inVar, $inMethod, $inPDefine,
			    $inClass, $inInterface, $blockOffset, \@perHeaderCategoryObjects,
			    \@perHeaderClassObjects, $classType, $cppAccessControlState,
			    \@fields, $fullpath, $functionGroup,
			    $headerObject, $loopIC, \@inputLines,
			    $newlang, $#inputLines, $preAtPart, $xml_output, $localDebug,
			    $hangDebug, $parmDebug, $blockDebug, $subparse,
			    $subparseTree, $nodec, $allow_multi, undef, $newsublang,
			    $hashtreecur, $hashtreeroot);
			# print STDERR "NEWSUBLANG NOW $newsublang\n";
			print STDERR "Got next declaration : $namelist\n" if ($localDebug || $adLoopDebug);
			print STDERR "NEW LOOP COUNTER IS $loopIC\n" if ($localDebug || $adLoopDebug);

			$loopIC++;
		    }
		}

		$headerObject->fixupTypeRequests();
		$headerObject->setupAPIReferences();

		$results .= "-=: FOUND MATCH :=-\n";
		$results .= $foundMatch."\n";
		$results .= "-=: NAMED OBJECTS :=-\n";
		my ($newresults, @parseTrees) = $self->dumpObjNames($headerObject);
		$results .= $newresults;

		print STDERR "Running parse tree info dumps.\n" if ($testDebug);

		$results .= "-=: NAMED OBJECT PARSE TREES :=-\n";
		foreach my $tree (@parseTrees) {
			# print STDERR "DUMPING PARSE TREE $tree\n";
			my $owner = $tree->apiOwner();
			# if ($owner->{FAILHARD}) {
				# print STDERR "\nTREE: ".$tree."\n";
				# print STDERR "OBJ: ".$owner."\n";
				# print STDERR "OWNER: ".$owner->apiOwner()."\n";
				# printHash(%{$owner->apiOwner()});
				# die();
			# }
			my $name = $owner->name();
			if ($owner->can("rawname")) {
				if (!$owner->{DISCUSSION} || !$owner->{NAMELINE_DISCUSSION}) {
					$name = $owner->rawname();
				}
			}
			my $class = ref($owner) || $owner;

			$results .= "OBJECT: $name ($class)\n";
			$results .= $tree->test_output_dump();
			$results .= "END OF OBJECT\n\n\n";
		}
		$results .= "\n";

		print STDERR "Running parse tree HTML dumps.\n" if ($testDebug);

		$results .= "-=: HTML OUTPUT OF PARSE TREES :=-\n";
		foreach my $tree (@parseTrees) {
			# print STDERR "DUMPING PARSE TREE $tree\n";
			my $owner = $tree->apiOwner();
			my $name = $owner->name();
			if ($owner->can("rawname")) {
				if (!$owner->{DISCUSSION} || !$owner->{NAMELINE_DISCUSSION}) {
					$name = $owner->rawname();
				}
			}
			my $class = ref($owner) || $owner;

			$results .= "OBJECT: $name ($class)\n";

			my $temp = $tree->htmlTree($owner->preserve_spaces(), $owner->hideContents());
			my @parts = split(/\n/, $temp);
    			foreach my $part (@parts) {
				$results .= "\t".$part."\n";
			}
			$results .= "END OF OBJECT\n\n\n";
		}
		$results .= "\n";
    	}
    }

    print STDERR "Done.\n" if ($testDebug);
    # my @lines = split(

	# print STDERR "TEST RESULTS: $results\n";

    $HeaderDoc::ignore_apiuid_errors = $prevignore;

    if ($alldecs) {
	$self->{RESULT_ALLDECS} = $results;
    } else {
	$self->{RESULT} = $results;
    }
    HeaderDoc::Utilities::savehashes($alldecs);

    return $coretestfail;
}

# /*!
#     @abstract
#         Loads this instance from a test file.
#     @param self
#         A newly-created <code>Test</code> class instance.
#     @param filename
#         The filename to read.
#  */
sub readFromFile {
    my $self = shift;
    my $filename = shift;

    open(READFILE, "<$filename") or die("Could not read file \"$filename\"\n");
    my $temprecsep = $/;
    $/ = undef;
    my $string = <READFILE>;
    $/ = $temprecsep;
    close(READFILE);

    my ($obj, $rest) = thaw($string);

	# print STDERR "STRING: $string\n";
	# print STDERR "OBJ: $obj\n";
	# print STDERR "REST: $rest\n";
    my @objkeys = sort keys %{$obj};
    foreach my $key (@objkeys) {
	$self->{$key} = $obj->{$key};
    }
    # $self->{FILENAME} = $self->{NAME};
    # $self->{FILENAME} =~ s/[^a-zA-Z0-9_.,-]/_/sg;

    # Do the right thing if somebody renames a file.
    $self->{FILENAME} = $filename;

    if ($self->{TYPE} eq "") { $self->{TYPE} = "parser"; }
    if ($self->{SUBLANG} eq "") { $self->{SUBLANG} = $self->{LANG}; }
}

# /*!
#     @abstract
#         Writes a freeze-dried copy of  this instance to
#         a test file.
#     @param self
#         A filled-out <code>Test</code> class instance.
#     @param filename
#         The filename to write.
#  */
sub writeToFile {
    my $self = shift;
    my $filename = shift;

    # Filter out junk that need not be written out to disk.
    delete $self->{EXPECTED_FILTERED_RESULT};
    delete $self->{EXPECTED_FILTERED_RESULT_ALLDECS};
    delete $self->{FILTERED_RESULT};
    delete $self->{FILTERED_RESULT_ALLDECS};
    delete $self->{RESULT};
    delete $self->{RESULT_ALLDECS};

    my $string = freeze($self);
    open(WRITEFILE, ">$filename") or die("Could not write file \"$filename\"\n");

    print WRITEFILE $string;
    close(WRITEFILE);
}

# /*!
#     @abstract
#         Writes tests to a property list file.  Currently
#         disabled.
#  */
sub writeToPlist {
    my $self = shift;
    my $filename = shift;

	# print "SELF: $self\n";

    eval {
	require Data::Plist::XMLWriter;
    };

return; # for now.

    if ($@) {
	warn("Not writing property lists because you do not have Data::Plist.\nTo install it, type:\n    sudo cpan YAML\n    sudo cpan Data::Plist::XMLWriter\n");
	return;
    }

    $filename =~ s/\.test$/\.plist/g;

    # my $plist = Data::Plist->new($self);

    my $writer = Data::Plist::XMLWriter->new;

    my %selfhash = %{$self};
    # foreach my $key (keys %selfhash) {
	# print STDERR "DATA $key -> ".$selfhash{$key}."\n";
    # }

    my $str = $writer->write(\%selfhash);
    open(WRITEFILE, ">$filename") or die("Could not write file \"$filename\"\n");
    print WRITEFILE $str;
    close(WRITEFILE);

}

# sub dbprint_expanded
# {
    # print STDERR "NOT IMPLEMENTED.\n";
# }

# /*!
#     @abstract
#         Prints a <code>Test</code> object for debugging purposes.
#     @param self
#         This <code>Test</code> object.
#  */
sub dbprint
{
    my $self = shift;
    # my $expanded = shift;
    my @keys = sort keys %{$self};

    print STDERR "Dumping object $self...\n";
    foreach my $key (@keys) {
        # if ($expanded) {
                # print STDERR "$key => ".dbprint_expanded($self->{$key})."\n";
        # } else {
                print STDERR "$key => ".$self->{$key}."\n";
        # }
    }
    print STDERR "End dump of object $self.\n";
}

# /*!
#     @abstract
#         Prints an explanatory message in a box of asterisks.
#     @param self
#         This <code>Test</code> object.
#     @param string
#         The string to print.
#  */
sub starbox
{
    my $self = shift;
    my $string = shift;

    my $maxlen = 60;
    my @lines = split(/\n/s, $string);

    foreach my $line (@lines) {
	if (length($line) > $maxlen) {
		$maxlen = length($line);
	}
    }


    my $starline = "+-" . ("-" x $maxlen) . "-+";
    my $count = 0;

    $maxlen += 4;

    print "    ".$starline."\n";
    foreach my $line (@lines) {
	$line = "| $line";
	$line .= " " x (($maxlen - length($line)) - 1);
	$line .= "|";
	print "    $line\n";
    }
    print "    ".$starline."\n\n\n";
}

# /*!
#     @abstract
#         Compares actual results with expected.
#     @param self
#         This <code>Test</code> object.
#     @param expanded
#         See {@link showresults_sub} for details.
#  */
sub showresults
{
    my $self = shift;
    my $expanded = shift;

    $self->showresults_sub($expanded, 0);
    if ($self->supportsAllDecs()) {
	$self->showresults_sub($expanded, 1);
    }

}

# /*!
#     @abstract
#         Compares actual results with expected in a given mode.
#     @param self
#         This <code>Test</code> object.
#     @param expanded
#         Supported values are:
#
#         <ul>
#             <li>-1 &mdash; Reduced output; uses diff to show
#                 a minimal set of differences.</li>
#             <li>0 &mdash; Standard output mode.</li>
#             <li>1 &mdash; Expanded output; more raw output.</li>
#         </ul>
#     @param alldecs
#         Specifies whether to do the result comparison for the
#         alldecs (<code>-E</code>) results or not (0/1).
#  */
sub showresults_sub
{
    my $self = shift;
    my $expanded = shift;
    my $alldecs = shift;

    if ($self->{FAILMSG} =~ /\S/) {
	print "\n";
	$self->starbox("FAILURE NOTES:\n\n".$self->{FAILMSG}."\n");
    }

    my @expected_part_arr = ();
    my @got_part_arr = ();
    if ($alldecs) {
	print STDERR "\nALLDECS RESULT:\n\n";
	@expected_part_arr = split(/((?:^|\n)-=:(?:.+?):=-)/s, $self->{EXPECTED_RESULT_ALLDECS});
	@got_part_arr = split(/((?:^|\n)-=:(?:.+?):=-)/s, $self->{RESULT_ALLDECS});
    } else {
	@expected_part_arr = split(/((?:^|\n)-=:(?:.+?):=-)/s, $self->{EXPECTED_RESULT});
	@got_part_arr = split(/((?:^|\n)-=:(?:.+?):=-)/s, $self->{RESULT});
    }

    my %expected_parts = %{$self->convertToHash(\@expected_part_arr)};
    my %got_parts = %{$self->convertToHash(\@got_part_arr)};

    foreach my $key (sort keys %expected_parts) {
	if ($expected_parts{$key} ne $got_parts{$key}) {
		print STDERR "\t$key does not match\n";
		if ($key eq "LIST OF PARSED PARAMETERS" ||
		    $key eq "TOP LEVEL COMMENT PARSE VALUES") {
			if ($expanded == 1) {
				print STDERR $self->multiPrint($expected_parts{$key}, $got_parts{$key});
			} else {
				print STDERR $self->singlePrint($expected_parts{$key}, $got_parts{$key}, 0);
			}
		} elsif ($key eq "BLOCKPARSE PARSER STATE KEYS" && $expanded != 1) {
			print STDERR $self->objCmp($expected_parts{$key}, $got_parts{$key}, $expanded);
		} elsif ($key eq "NAMED OBJECTS" && (!$expanded)) {
			my $part_a = $expected_parts{$key};
			my $part_b = $got_parts{$key};

			$part_a =~ s/\/\/test_ref.*?(\s|"|')//sg;
			$part_b =~ s/\/\/test_ref.*?(\s|"|')//sg;

			if ($part_a eq $part_b) {
				my @refs_a = split(/\/\/test_ref\//, $expected_parts{$key});
				my @refs_b = split(/\/\/test_ref\//, $got_parts{$key});

				my $pos = 1; # position 0 is before the first occurrence.
				while ($pos <= $#refs_a) {
					my $ref_a = $refs_a[$pos];
					my $ref_b = $refs_b[$pos];
					$ref_a =~ s/(\s|"|').*$//s;
					$ref_b =~ s/(\s|"|').*$//s;
					if ($ref_a ne $ref_b) {
						print STDERR "\t\tUID //test_ref/".$ref_a."\n\t\tNOW //test_ref/".$ref_b."\n\n";
					}
					$pos++;
				}
			} else {
				print STDERR $self->multiPrint($expected_parts{$key}, $got_parts{$key});
			}
		} elsif (($key eq "NAMED OBJECTS" || $key eq "NAMED OBJECT PARSE TREES" || $key eq "DUMP OF PARSE TREE" || $key eq "CPP CHANGES" || $key eq "BLOCKPARSE RETURN VALUES" || $key eq "HTML OUTPUT OF PARSE TREES") && $expanded == -1) {
				open(WRITEFILE, ">/tmp/headerdoc-diff-expected") or die("Could not write file \"/tmp/headerdoc-diff-expected\"\n");
				print WRITEFILE $expected_parts{$key};
				close(WRITEFILE);
				open(WRITEFILE, ">/tmp/headerdoc-diff-got") or die("Could not write file \"/tmp/headerdoc-diff-got\"\n");
				print WRITEFILE $got_parts{$key};
				close(WRITEFILE);

				system("/usr/bin/diff -u -U 15 /tmp/headerdoc-diff-expected /tmp/headerdoc-diff-got");

				unlink("/tmp/headerdoc-diff-expected");
				unlink("/tmp/headerdoc-diff-got");
		} else {
			print STDERR $self->multiPrint($expected_parts{$key}, $got_parts{$key});
		}
	} else {
		print STDERR "\t$key matches\n";
	}
    }
    foreach my $key (sort keys %got_parts) {
	# print STDERR "KEY $key\n";
	if (!defined($expected_parts{$key})) {
		print STDERR "\tUnexpected part $key\n";
		print STDERR $self->multiPrint($expected_parts{$key}, $got_parts{$key});
	}
    }

}

# /*!
#     @abstract
#         Prints both the expected and actual values
#         as-is.
#     @param self
#         This <code>Test</code> object.
#     @param string1
#         The expected values.
#     @param string2
#         The actual values.
#  */
sub multiPrint
{
    my $self = shift;
    my $string1 = shift;
    my $string2 = shift;

    my @parts1 = split(/\n/, $string1);
    my @parts2 = split(/\n/, $string2);

    print STDERR "\t\tEXPECTED:\n";
    foreach my $line (@parts1) {
	print STDERR "\t\t\t$line\n";
    }
    print STDERR "\t\tGOT:\n";
    foreach my $line (@parts2) {
	print STDERR "\t\t\t$line\n";
    }

}

# /*!
#     @abstract
#         Compares two object dumps.
#     @discussion
#         Takes the output of an object (key-value pairs)
#         and displays the keys that are different,
#         missing, or added in the actual results.
#              
#     @param self
#         This <code>Test</code> object.
#     @param string1
#         The expected values.
#     @param string2
#         The actual values.
#     @param all
#         Set to 0 normally.  Set to 1 if you want to see
#         all keys whether they are different or not.
#  */
sub objCmp
{
    my $self = shift;
    my $string1 = shift;
    my $string2 = shift;
    my $all = shift;

    my $localDebug = 0;

    my @parts1 = split(/\n/, $string1);
    my @parts2 = split(/\n/, $string2);

    my %expected_keys = ();
    my %got_keys = ();
    my %keysall = ();

    my $retstring = "";

    my $continue = "";
    foreach my $part (@parts1) {
	if ($continue && $part !~ /^\s*\$parserState->.*?=>/) {
		print STDERR "APPENDING TO \"$continue\"\n" if ($localDebug);
		$expected_keys{$continue} .= "\n".$part;
		next;
	}
	my ($key, $value) = split(/=>/, $part, 2);
	$key =~ s/^.*{//s;
	$key =~ s/}.*$//s;

	$continue = $key;
	$expected_keys{$key} = $value;
	$keysall{$key} = 1;
	print STDERR "LINE: $part\n" if ($localDebug);
	print STDERR "KEY: $key\n" if ($localDebug);
    }

    $continue = "";
    foreach my $part (@parts2) {
	if ($continue && $part !~ /^\s*\$parserState->.*?=>/) {
		$got_keys{$continue} .= "\n".$part;
		print STDERR "APPENDING TO \"$continue\"\n" if ($localDebug);
		next;
	}
	my ($key, $value) = split(/=>/, $part, 2);
	$key =~ s/^.*{//s;
	$key =~ s/}.*$//s;

	$continue = $key;
	$got_keys{$key} = $value;
	if ($keysall{$key} == 1) {
		$keysall{$key} = 2;
	} else {
		$keysall{$key} = 3;
	}
	print STDERR "LINE: $part\n" if ($localDebug);
	print STDERR "KEY: $key\n" if ($localDebug);
    }

    my $found_difference = 0;
    foreach my $key (sort keys %keysall) {
	my $found = $keysall{$key};
	if ($found == 1) {
		$retstring .= "\t\tKEY $key is missing.  Value: ".$expected_keys{$key}."\n";
		$found_difference = 1;
	} elsif ($found == 3) {
		# print STDERR "X\t\tKEY $key is new.  Value was: ".$got_keys{$key}."\n";
		$retstring .= "\t\tKEY $key is new.  Value was: ".$got_keys{$key}."\n";
		$found_difference = 1;
	}
    }
    foreach my $key (sort keys %keysall) {
	if (($all == 1) || ($expected_keys{$key} ne $got_keys{$key})) {
		$retstring .= "\t\tEXPECTED: \$parserState->{$key} =>".$expected_keys{$key}."\n";
		$retstring .= "\t\tGOT:      \$parserState->{$key} =>".$got_keys{$key}."\n\n";
		$found_difference = 1;
	}
    }

    if (!$found_difference) {
	$retstring .= "\t\tNo changes found.\n";
	# $retstring .= "EXPECTED:\n$string1\n";
	# $retstring .= "GOT:\n$string2\n";
    }
    return $retstring;
}

# /*!
#     @abstract
#         Shows the individual lines in two arrays that difer.
#     @param self
#         This <code>Test</code> object.
#     @param string1
#         The expected results.
#     @param string2
#         The actual results.
#  */
sub singlePrint
{
    my $self = shift;
    my $string1 = shift;
    my $string2 = shift;
    # my $sort = shift;

    my @parts1 = split(/\n/, $string1);
    my @parts2 = split(/\n/, $string2);

    my $pos = 0;
    my $count = scalar(@parts1);
    if ($count < scalar(@parts2)) {
	$count = scalar(@parts2);
    }

    while ($pos < $count) {
	my $part1 = $parts1[$pos];
	my $part2 = $parts2[$pos];

	if ($part1 ne $part2) {
		print STDERR "\t\tEXPECTED: $part1\n";
		print STDERR "\t\tGOT:      $part2\n\n";
	}

	$pos++;
    }

}

# /*!
#     @abstract
#         Converts an array alternating between keys and values
#         (one per line) to a hash.
#     @param self
#         This <code>Test</code> object.
#     @param arrayRef
#         A reference to the source array.
#  */
sub convertToHash
{
    my $self = shift;
    my $arrayRef = shift;
    my @arr = @{$arrayRef};
    my %retarr = ();

    my $pos = 0;
    my $key = "";
    foreach my $part (@arr) {
	# print STDERR "PART: $part\n";
	if ($pos) {
		$key = $part;
		$key =~ s/^\s*-=:\s*//s;
		$key =~ s/\s*:=-\s*$//s;
		$pos = 0;
		# print STDERR "KEY: $key\n";
	} else {
		$part =~ s/^\n*//s;
		$part =~ s/\n*$//s;
		if ($key) { $retarr{$key} = $part; }
		# print STDERR "SET $key to $part\n";
		$pos = 1;
	}
    }
    return \%retarr;
}

# /*!
#     @abstract
#         Grabs the C preprocessor info from the block parser
#         and stores the results in the <code>Test</code> class.
#     @param self
#         This <code>Test</code> object.
#     @discussion
#         If any CPP hash changes occur as a result of parsing
#         this declaration, they are captured by this code.
#  */
sub cppTests
{
    my $self = shift;
    my $retstring = "";

    my ($cpp_hash_ref, $cpp_arg_hash_ref) = getAndClearCPPHash();
    my %cpp_hash = %{$cpp_hash_ref};
    my %cpp_arg_hash = %{$cpp_arg_hash_ref};

    foreach my $key (sort keys %cpp_hash) {
	$retstring .= "\$CPP_HASH{$key} => ".$cpp_hash{$key}."\n";
    }
    foreach my $key (sort keys %cpp_arg_hash) {
	$retstring .= "\$CPP_ARG_HASH{$key} => ".$cpp_arg_hash{$key}."\n";
    }

    if ($retstring eq "") {
	$retstring = "NO CPP CHANGES\n";
    }

    return $retstring;
}

# /*!
#     @abstract
#         Grabs the HeaderDoc object names resulting from
#         parsing this declaration and stores the results
#         in the <code>Test</code> class.
#     @param self
#         This <code>Test</code> object.
#     @param obj
#         The object tree to dump.
#     @discussion
#         This includes the important keys from the HeaderDoc
#         API objects.  It does not attempt to include every
#         possible key.
#  */
sub dumpObjNames
{
    my $self = shift;
    my $obj = shift;
    my $nest = 0;
    if (@_) {
	$nest = shift;
    }

    my $localDebug = 0;

    my @parseTrees = ();

    my $indent = '    ' x $nest;
    my $retstring = "";

    # print STDERR "OBJ: $obj\n";
    my $name = $obj->name();
    if ($obj->can("rawname")) {
	if (!$obj->{DISCUSSION} || !$obj->{NAMELINE_DISCUSSION}) {
		$name = $obj->rawname();
	}
    }

    my $treecount = 0;
    my $parseTree_ref = $obj->parseTree();
    my $mainTree = undef;
    if ($parseTree_ref) {
	$mainTree = ${$parseTree_ref};
	bless($mainTree, "HeaderDoc::ParseTree");

	print STDERR "ADDED MAIN TREE $mainTree at object $obj\n" if ($localDebug);

	push(@parseTrees, $mainTree);
	$treecount++;
    }

    my $ptlistref = $obj->parseTreeList();
    if ($ptlistref) {
	my @tree_refs = @{$ptlistref};
	foreach my $tree_ref (@tree_refs) {
		my $extratree = ${$tree_ref};
		bless($extratree,  "HeaderDoc::ParseTree");
		if ($extratree != $mainTree) {
			print STDERR "ADDED EXTRA TREE $extratree at object $obj\n" if ($localDebug);;
			push(@parseTrees, $extratree);
			$treecount++;
		}
	}
    }

    $retstring .= $indent."TREE COUNT: $treecount\n";

    if ($obj->can("indexgroup")) {
	$retstring .= $indent."INDEX GROUP: ".$obj->indexgroup()."\n";
    }
    if ($obj->can("isProperty")) {
	$retstring .= $indent."IS PROPERTY: ".$obj->isProperty()."\n";
    }
    if ($obj->can("isBlock")) {
	$retstring .= $indent."IS BLOCK: ".$obj->isBlock()."\n";
    }
    if ($obj->can("isAvailabilityMacro")) {
	$retstring .= $indent."IS AVAILABILITY MACRO: ".$obj->isAvailabilityMacro()."\n";
    }
    if ($obj->can("parseOnly")) {
	$retstring .= $indent."PARSE ONLY: ".$obj->parseOnly()."\n";
    }
    $retstring .= $indent."OBJECT TYPE: ".$obj->class()."\n";
    $retstring .= $indent."NAME: ".$name."\n";
    # $retstring .= $indent."RAWNAME: ".$obj->rawname()."\n";
    my $class = ref($obj) || $obj;
    if ($class =~ /HeaderDoc::MinorAPIElement/) {
	$retstring .= $indent."TYPE: ".$obj->type()."\n";
    }
    # $retstring .= $indent."APIO: ".$obj->apiOwner()."\n";
    $obj->apirefSetup();
    $retstring .= $indent."APIUID: ".$obj->apiuid()."\n";
    $retstring .= $indent."ABSTRACT: \"".$obj->abstract()."\"\n";
    $retstring .= $indent."DISCUSSION: \"".$obj->discussion()."\"\n";
# print STDERR "RAWDISC:   ".$obj->{DISCUSSION}."\n";
# print STDERR "RAWNLDISC: ".$obj->{NAMELINE_DISCUSSION}."\n";
# print STDERR "DISC:      ".$obj->discussion()."\n";

    $retstring .= $indent."UPDATED: \"".$obj->{UPDATED}."\"\n";
    $retstring .= $indent."COPYRIGHT: \"".$obj->{COPYRIGHT}."\"\n";
    $retstring .= $indent."HTMLMETA: \"".$obj->{HTMLMETA}."\"\n";
    $retstring .= $indent."PRIVATEDECLARATION: \"".$obj->{PRIVATEDECLARATION}."\"\n";
    $retstring .= $indent."GROUP: \"".$obj->{GROUP}."\"\n";
    $retstring .= $indent."INDEXGROUP: \"".$obj->{INDEXGROUP}."\"\n";
    $retstring .= $indent."THROWS: \"".$obj->{THROWS}."\"\n";
    $retstring .= $indent."XMLTHROWS: \"".$obj->{XMLTHROWS}."\"\n";
    $retstring .= $indent."UPDATED: \"".$obj->{UPDATED}."\"\n";
    $retstring .= $indent."LINKAGESTATE: \"".$obj->{LINKAGESTATE}."\"\n";
    $retstring .= $indent."ACCESSCONTROL: \"".$obj->{ACCESSCONTROL}."\"\n";
    $retstring .= $indent."AVAILABILITY: \"".$obj->{AVAILABILITY}."\"\n";
    $retstring .= $indent."LINKUID: \"".$obj->{LINKUID}."\"\n";
    $retstring .= $indent."ORIGCLASS: \"".$obj->{ORIGCLASS}."\"\n";
    $retstring .= $indent."ISDEFINE: \"".$obj->{ISDEFINE}."\"\n";
    $retstring .= $indent."ISTEMPLATE: \"".$obj->{ISTEMPLATE}."\"\n";
    $retstring .= $indent."VALUE: \"".$obj->{VALUE}."\"\n";
    $retstring .= $indent."RETURNTYPE: \"".$obj->{RETURNTYPE}."\"\n";
    $retstring .= $indent."LINENUM: \"".$obj->{LINENUM}."\"\n";
    $retstring .= $indent."CLASS: \"".$obj->{CLASS}."\"\n";
    $retstring .= $indent."MASTERENUM: \"".$obj->{MASTERENUM}."\"\n";
    $retstring .= $indent."APIREFSETUPDONE: \"".$obj->{APIREFSETUPDONE}."\"\n";
    $retstring .= $indent."TPCDONE: \"".$obj->{TPCDONE}."\"\n";
    $retstring .= $indent."NOREGISTERUID: \"".$obj->{NOREGISTERUID}."\"\n";
    $retstring .= $indent."SUPPRESSCHILDREN: \"".$obj->{SUPPRESSCHILDREN}."\"\n";
    $retstring .= $indent."NAMELINE_DISCUSSION: \"".$obj->{NAMELINE_DISCUSSION}."\"\n";
    $retstring .= $indent."HIDEDOC: \"".$obj->{HIDEDOC}."\"\n";
    $retstring .= $indent."HIDESINGLETONS: \"".$obj->{HIDESINGLETONS}."\"\n";
    $retstring .= $indent."HIDECONTENTS: \"".$obj->{HIDECONTENTS}."\"\n";

    my $temp = $obj->{MAINOBJECT};
    $temp =~ s/0x[0-9a-f]+/OBJID/sg;
    $retstring .= $indent."MAINOBJECT: \"$temp\"\n";

    my $composite = 1;
    my $list_attributes = $obj->getAttributeLists($composite);
    my $short_attributes = $obj->getAttributes(0);
    my $long_attributes = $obj->getAttributes(1);

    $retstring .= $indent."LIST ATTRIBUTES: ".$list_attributes."\n";
    $retstring .= $indent."SHORT ATTRIBUTES: ".$short_attributes."\n";
    $retstring .= $indent."LONG ATTRIBUTES: ".$long_attributes."\n";

    if ($obj->can("userDictArray")) {
	my @userDictArray = $obj->userDictArray();
	foreach my $hashRef (@userDictArray) {
		$retstring .= $indent."USER DICTIONARY:\n";
		while (my ($param, $disc) = each %{$hashRef}) {
			$retstring .= $indent."    $param\t=>\t$disc\n";
		}
		$retstring .= $indent."END USER DICTIONARY\n";
	}
    }

    if ($obj->isAPIOwner()) {
	my @functions = $obj->functions();
	my @methods = $obj->methods();
	my @constants = $obj->constants();
	my @typedefs = $obj->typedefs();
	my @structs = $obj->structs();
	my @vars = $obj->vars();
	my @enums = $obj->enums();
	my @pDefines = $obj->pDefines();
	my @classes = $obj->classes();
	my @categories = $obj->categories();
	my @protocols = $obj->protocols();
	my @properties = $obj->props();

	if (@functions) {
		foreach my $obj (@functions) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
			($newret, @newtrees) = $self->dumpEmbeddedClasses($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@methods) {
		foreach my $obj (@methods) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@constants) {
		foreach my $obj (@constants) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@typedefs) {
		foreach my $obj (@typedefs) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@structs) {
		foreach my $obj (@structs) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@vars) {
		foreach my $obj (@vars) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@enums) {
		foreach my $obj (@enums) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@pDefines) {
		foreach my $obj (@pDefines) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@classes) {
		foreach my $obj (@classes) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@categories) {
		foreach my $obj (@categories) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@protocols) {
		foreach my $obj (@protocols) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	if (@properties) {
		foreach my $obj (@properties) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
    } else {

	my @objects = $obj->parsedParameters();
	if (@objects) {
		$retstring .= $indent."PARSED PARAMETERS:\n";
		foreach my $obj (@objects) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}

	if ($obj->can("fields")) {
		my @objects = $obj->fields();
		if (@objects) {
			$retstring .= $indent."FIELDS:\n";
			foreach my $obj (@objects) {
				my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
				$retstring .= $newret;
				foreach my $copyobj (@newtrees) {
					push(@parseTrees, $copyobj);
				}
			}
		}
	}

	my @objects = $obj->taggedParameters();
	if (@objects) {
		$retstring .= $indent."TAGGED PARAMETERS:\n";
		foreach my $obj (@objects) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}
	my @objects = $obj->variables();
	if (@objects) {
		$retstring .= $indent."LOCAL VARIABLES:\n";
		foreach my $obj (@objects) {
			my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
			$retstring .= $newret;
			foreach my $copyobj (@newtrees) {
				push(@parseTrees, $copyobj);
			}
		}
	}

	my ($newret, @newtrees) = $self->dumpEmbeddedClasses($obj, $nest + 1);
	$retstring .= $newret;
	foreach my $copyobj (@newtrees) {
		push(@parseTrees, $copyobj);
	}
    }

    return ($retstring, @parseTrees);
}


# /*!
#     @abstract Dumps information about AppleScript scripts embedded
#               within handlers.
#  */
sub dumpEmbeddedClasses
{
    my $self = shift;
    my $obj = shift;
    my $nest = shift;

    my $class = ref($obj) || $obj;

    my $retstring = "";
    my @parseTrees = ();
    my @embeddedClasses = ();

    if ($self->{LANG} eq "applescript" && $class eq "HeaderDoc::Function") {
	my $class_self = undef;
	if (!$obj->{ASCONTENTSPROCESSED}) {
		$class_self = $obj->processAppleScriptFunctionContents();
	} else {
		my $class_self_ref = $obj->{AS_CLASS_SELF};
		if ($class_self_ref) {
			$class_self = ${$class_self_ref};
			bless($class_self, "HeaderDoc::HeaderElement");
			bless($class_self, $class_self->class());
		}
	}
	if ($class_self) {
		my @tempClasses = $class_self->classes();
		foreach my $obj (@tempClasses) {
			push(@embeddedClasses, $obj);
		}
	}
    }

    if (@embeddedClasses) {
	foreach my $obj (@embeddedClasses) {
		my ($newret, @newtrees) = $self->dumpObjNames($obj, $nest + 1);
		$retstring .= $newret;
		foreach my $copyobj (@newtrees) {
			push(@parseTrees, $copyobj);
		}
	}
    }
    return ($retstring, @parseTrees);
}

# /*!
#     @abstract
#         Returns whether this <code>Test</code> object supports the
#         "all declarations" (<code>-E</code>) mode.
#     @param self
#         This <code>Test</code> object.
#  */
sub supportsAllDecs
{
    my $self = shift;
    my $lang = $self->{LANG};
    my $sublang = $self->{SUBLANG};

    return allow_everything($lang, $sublang);

    ## if ($lang eq "C") { return 1; };
    ## if ($lang eq "java") {
	## if ($sublang ne "javascript") {
		## return 1;
	## }
    ## }
    ## if ($lang eq "pascal") { return 1; } # Maybe
    ## if ($lang eq "perl") { return 1; } # Maybe

    return 0;
}

1;


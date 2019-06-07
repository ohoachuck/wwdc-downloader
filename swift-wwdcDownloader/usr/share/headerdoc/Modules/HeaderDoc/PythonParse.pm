#! /usr/bin/perl -w
#
# Module name: BlockParse
# Synopsis: Block parser code
#
# Last Updated: $Date: 2012/02/28 15:37:59 $
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
#         <code>PythonParse</code> package file.
#     @discussion
#         This file contains the <code>PythonParse</code> package, a collection
#         of functions for parsing Python declarations.
#
#         For details, see the package documentation below.
#     @indexgroup HeaderDoc Parser Pieces
#  */

# /*!
#     @abstract
#         Internal parser routines for parsing Python code.
#     @discussion
#         The <code>PythonParse</code> package parses a Python declaration.  It is
#         essentially a language-specific replacement for parts of the
#         {@link //apple_ref/perl/cl/HeaderDoc::BlockParse BlockParse}
#         class.
#
#         In general, you should not call routines in this package
#         directly.  Instead, call the appropriate routines in the
#         {@link //apple_ref/perl/cl/HeaderDoc::BlockParse BlockParse}
#         package with the appropriate language values and let them
#         call these routines for you.
#  */
package HeaderDoc::PythonParse;

BEGIN {
	foreach (qw(Mac::Files)) {
	    $MOD_AVAIL{$_} = eval "use $_; 1";
    }
}

use Carp qw(cluck);
use HeaderDoc::TypeHelper;
use Exporter;
foreach (qw(Mac::Files Mac::MoreFiles)) {
    eval "use $_";
}

# $HeaderDoc::disable_parms = 0;

@ISA = qw(Exporter);
@EXPORT = qw(pythonParse);

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash parseTokens isKeyword classTypeFromFieldAndBPinfo casecmp addAvailabilityMacro printFields);


use strict;
use vars qw($VERSION @ISA);
use File::Basename qw(basename);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::PythonParse::VERSION = '$Revision: 1330472279 $';

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


$HeaderDoc::inputCounterDebug = 0;

# /*! @abstract
#         The number of spaces that a tab should be replaced with
#         when parsing Python.
#     @discussion
#         This value can be changed with the <code>-w</code> flag on
#         the command line.
#  */
$HeaderDoc::python_tab_spaces = 8;

my $test_pyspace = 0;

################ Code ###################################

# /*!
#     @abstract
#         Converts tabs to spaces and calculates indentation.
#     @param string
#         The string of spaces.
#     @discussion
#         Converts tabs to spaces using the variable
#  */
sub pylength
{
	my $str = shift;
	# print "SPACES: $HeaderDoc::python_tab_spaces\n";

	if ($str =~ /\t/) {
	    my $pos = 0;
	    my $newstr;
	    my @parts = split(/(\t)/, $str);
	    foreach my $part (@parts) {
		if ($part =~ /\t/) {
			my $nspaces = $HeaderDoc::python_tab_spaces - ($pos % $HeaderDoc::python_tab_spaces);
			my $pyspace = " " x $nspaces;
			$newstr .= $pyspace;
			$pos += $nspaces;
		} else {
			$newstr .= $part;
			$pos += length($part);
		}
	    }
	    $str = $newstr;
	}
	return length($str);
}

# /*!
#     @abstract
#         Runs a single python space handling test.
#     @param testnum
#         The test number (string).
#     @param test
#         The string of spaces and tabs to test.
#     @param testresult
#         The expected test result.
#     @result
#         Returns 1 for a successful test, 0 for a failed test.
#  */
sub pySpaceTest
{
	my $testnum = shift;
	my $test = shift;
	my $testresult = shift;

	my $temp = pylength($test);
	if ($temp != $testresult) {
		print STDERR "Python space test $testnum: \e[31mFAILED\e[39m\nGot $temp, expected $testresult.\n";
		return 0;
	} else {
		print STDERR "Python space test $testnum: \e[32mOK\e[39m\n";
		return 1;
	}
}

# /*!
#     @abstract
#         Runs a series of tests on Python tab-to-space conversion.
#     @result
#         Returns an array containing the number of successes and failures.
#  */
sub runPythonSpaceTests
{
	my $tmp = $HeaderDoc::python_tab_spaces;

	print STDERR "\n-= Running Python space tests =-\n\n";

	$HeaderDoc::python_tab_spaces = 8;

	my $pass_count = 0;

	$pass_count += pySpaceTest(1, " \t", 8); # 8
	$pass_count += pySpaceTest(2, "       \t", 8); # 8
	$pass_count += pySpaceTest(3, "\t", 8); # 8
	$pass_count += pySpaceTest(4, "\t ", 9); # 9
	$pass_count += pySpaceTest(5, " \t \t", 16); # 16

	$HeaderDoc::python_tab_spaces = 4;

	$pass_count += pySpaceTest("1a", " \t", 4); # 8
	$pass_count += pySpaceTest("2a", "       \t", 8); # 8
	$pass_count += pySpaceTest("3a", "\t", 4); # 8
	$pass_count += pySpaceTest("4a", "\t ", 5); # 9
	$pass_count += pySpaceTest("5a", " \t \t", 8); # 16

	$HeaderDoc::python_tab_spaces = $tmp;

	print STDERR "\n";

	return ($pass_count, 10-$pass_count); # Change if we add more tests.
}

# /*!
#     @abstract
#         Parses a Python declaration.
#     @discussion
#         Python is a painful language to parse because it has no
#         tokens to end most block structures (except, thankfully,
#         for multi-line comments, without which supporting it
#         would be almost impossible).  Merging this into the main
#         parser would be way too messy, so its parser lives in a
#         separate block of code.
#
#         This function is called at the start of {@link blockParse} and
#         replaces its functionality.  Upon completion, it passes its
#         state to {@link blockParseReturnState} just like the main parser
#         does, then returns the result.
#
#     @param fullpath
#         The path to the file being parsed.
#     @param fileoffset
#         The line number where the current block begins.  The line number
#         printed is <code>(fileoffset + inputCounter)</code>.
#     @param inputLinesRef
#         A reference to an array of code lines.
#     @param inputCounter
#         The offset within the array.  This is added to fileoffset when
#         printing the line number.
#     @param argparse
#         Disable warnings when parsing arguments to avoid seeing them twice.
#     @param ignoreref
#         A reference to a hash of tokens to ignore on all headers.
#     @param perheaderignoreref
#         A reference to a hash of tokens, generated from <code>\@ignore</code>
#         headerdoc comments.
#     @param perheaderignorefuncmacrosref
#         A reference to a hash of tokens, generated from
#         <code>\@ignorefunmacro</code> headerdoc comments.
#     @param keywordhashref
#         A reference to a hash of keywords.
#     @param case_sensitive
#         Boolean value that controls whether keywords should be processed
#         in a case-sensitive fashion.
#     @result
#         Returns the array <code>($inputCounter, $declaration, $typelist, $namelist, $posstypes, $value, \@pplStack, $returntype, $privateDeclaration, $treeTop, $simpleTDcontents, $availability)</code> to the caller.
#
#     @vargroup State variables
#
#         @var continue
#             Indicates that parsing should continue.  Upon receiving a terminating token,
#                 this gets set to zero, and parsing ends at the end of the line.
#         @var parserState
#             The {@link //apple_ref/perl/cl/HeaderDoc::ParserState ParserState} 
#             object used for storing most of the parser state variables.
#
#     @vargroup Token and line variables
#
#         @var line
#             The (input) line being parsed.
#         @var part
#             The current token being processed (from <code>curline</code>).
#         @var nextpart
#             The token after the token being processed (from <code>line</code>).
#         @var treepart
#             In some cases, it is necessary to drop a token for formatting purposes but keep it in
#             the parse tree.  When this is needed, the <code>treepart</code> variable contains
#             the original token, and the <code>part</code> variable contains a placeholder value
#             (generally a space).
#
#     @vargroup Parse tree nodes
#
#         @var treeTop
#             The top of the current parse tree.
#         @var treeCur
#             The current position in the parse tree.
#  */
sub pythonParse
{
    my $fullpath = shift;
    my $fileoffset = shift;
    my $inputLinesRef = shift;
    my $inputCounter = shift;
    my $argparse = shift;
    my $ignoreref = shift;
    my $perheaderignoreref = shift;
    my $perheaderignorefuncmacrosref = shift;
    my $keywordhashref = shift;
    my $case_sensitive = shift;
    my $lang = shift;
    my $sublang = shift;

    my $parseDebug = 0;
    my $liteDebug = 0;
    my $parmDebug = 0;
    my $nameDebug = 0;
    my $stateDebug = 0;
    my $spaceDebug = 0;
    my $stackDebug = 0;
    my $inputCounterDebug = 0;

    my $anyDebug = ($parseDebug || $liteDebug || $parmDebug || $nameDebug || $stateDebug || $spaceDebug ||
                    $stackDebug || $inputCounterDebug);
    # print STDERR "Test\n";

    my $treeTop = HeaderDoc::ParseTree->new();
    my $treeCur = $treeTop;

    my @parserStack = ();
    my $parserState = HeaderDoc::ParserState->new( "FULLPATH" => $fullpath, "lang" => $lang, "sublang" => $sublang );

    # $parserState->{hollow} = $treeTop;
    # $parserState->setHollowWithLineNumbers($treeCur, $fileoffset, $inputCounter);
    $parserState->{lang} = $lang;
    $parserState->{inputCounter} = $inputCounter;
    $parserState->{initbsCount} = 0; # included for consistency....

    my $retDebug = 0;

    my @inputLines = @{$inputLinesRef};

    # Get the parse tokens from Utilities.pm.
    # my ($sotemplate, $eotemplate, $operator, $soc, $eoc, $ilc, $ilc_b, $sofunction,
	# $soprocedure, $sopreproc, $lbrace, $rbrace, $unionname, $structname,
	# $enumname,
	# $typedefname, $varname, $constname, $structisbrace, $macronameref,
	# $classregexp, $classbraceregexp, $classclosebraceregexp, $accessregexp,
	# $requiredregexp, $propname, $objcdynamicname, $objcsynthesizename, $moduleregexp, $definename,
	# $functionisbrace, $classisbrace, $lbraceconditionalre, $lbraceunconditionalre, $assignmentwithcolon,
	# $labelregexp, $parmswithcurlybraces, $superclasseswithcurlybraces, $soconstructor) = parseTokens($lang, $sublang);
    my %parseTokens = %{parseTokens($lang, $sublang)};

    # $parserState->{sodname} = "foo";
    # $parserState->{sodtype} = "";
    # $parserState->{sodclass} = "function";
    # $treeTop->token("test");

    my $continue = 1;

    my $nlines = $#inputLines;
    while ($continue && ($inputCounter <= $nlines)) {
	my $line = $inputLines[$inputCounter];

	print STDERR "LINE IS $line\n" if ($parseDebug);

	# The tokenizer
	my @parts = split(/("|'|\n|\r|[ \t]+|\=\=|\!headerdoc\!|\!\=|\<\=|\>\=|\+\=|\-\=|\<\<|\>\>|\W)/, $line);
	push(@parts, "BOGUSBOGUSBOGUS");

	$parserState->{lastpart} = "";

	my $part = "";
	foreach my $nextpart (@parts) {
		REDO:
		if ($stackDebug) {
			print STDERR "BEGIN STACK DUMP\n";
			foreach my $token (@{$parserState->{braceStack}}) {
				print "ITEM: $token\n";
			}
			print STDERR "END STACK DUMP\n";
		}

		if (!length($part)) {
			# print STDERR "SKIP TO \"$nextpart\"\n";
			$part = $nextpart;
			next;
		}

		print STDERR "PART IS \"$part\"\n" if ($parseDebug || $liteDebug);

		# The version of the part to insert into the tree (if different);
		my $treepart = $part;

		if ($part =~ /\s/ && $part !~ /[\r\n]/) {
			print STDERR "WSATTOP\n" if ($parseDebug || $spaceDebug);
			if ($parserState->{lastpart} =~ /[\n\r]/ || $parserState->{lastpart} eq "") {
			    if (!$parserState->isContinuationLine()) {
				# print STDERR "CMP ".pylength($part)." TO ".$parserState->{leadspace}."\n";
				if ($parserState->{leadspace} == -1) {
					if ($nextpart !~ /[\n\r]/) {
						$parserState->{leadspace} = pylength($part);
						$parserState->{setleading} = 1;
						print STDERR "SETLEADING -> 1[1]\n" if ($parseDebug || $stateDebug);
						print STDERR "leadspace -> ".$parserState->{leadspace}."\n" if ($parseDebug || $stateDebug || $spaceDebug);
						$treepart = "";
					} else {
						print STDERR "Ignoring leading space for blank line.\n" if ($spaceDebug);
					}
				} else {
						print STDERR "Not setting leading space because it is already set (".$parserState->{leadspace}.").\n" if ($spaceDebug);
				}
				if ((!$parserState->{seenToken}) && (!$parserState->{seenLeading})) {
					$parserState->{seenLeading} = pylength($part);
				}
			    } else {
					print STDERR "Ignoring leading whitespace for continuation line.\n" if ($parseDebug || $spaceDebug);
					print STDERR "LEADSPACE: ".$parserState->{leadspace}."\n" if ($spaceDebug);
			    }
			} else {
			    print STDERR "Not setting leading whitespace because this is not the first whitespace\n"."on the line (lastpart is ".$parserState->{lastpart}.").\n" if ($spaceDebug);
			}
		} elsif ($part =~ /[\r\n]/) {
			print STDERR "NLATTOP\n" if ($parseDebug);
			$parserState->{seenLeading} = 0;
			if ($parserState->{seenToken}) {
				$parserState->{setleading} = 0;
				print STDERR "SETLEADING -> 0\n" if ($parseDebug || $stateDebug);
			}
			$parserState->{seenToken} = 0;
		} else {
			print STDERR "TEXTATTOP\n" if ($parseDebug);
			if ($parserState->{leadspace} == -1) {
				$parserState->{leadspace} = 0; # pylength($part);
				$parserState->{setleading} = 1;
				print STDERR "SETLEADING -> 1[1]\n" if ($parseDebug || $stateDebug);
				print STDERR "leadspace -> ".$parserState->{leadspace}."\n" if ($parseDebug || $stateDebug);
			}
			if (!$parserState->{seenLeading}) { $parserState->{seenLeading} = 0; };

			print STDERR "CMP: ".$parserState->{seenLeading}." TO ".$parserState->{leadspace}."\n" if ($parseDebug || $spaceDebug);
			if ((!$parserState->isContinuationLine()) && (!$parserState->{setleading}) && ($parserState->{seenLeading} <= $parserState->{parentLeading}) && (!$parserState->{onlyComments})) {
				if (!$parserState->{seenToken}) {
					$parserState->{endgame} = 3;
					print STDERR "ENDGAME -> 3[TAT-LTPARENTLEAD]\n" if ($parseDebug || $stateDebug);
				} else {
					print STDERR "ENDGAME NOT SET (ST: ".$parserState->{seenToken}.", OC: ".$parserState->{onlyComments}.") [TAT-LTPARENTLEAD]\n" if ($parseDebug);
				}
			} elsif ((!$parserState->isContinuationLine()) && (!$parserState->{setleading}) && ($parserState->{seenLeading} <= $parserState->{leadspace}) && (!$parserState->{onlyComments})) {
				if (!$parserState->{seenToken}) {
					$parserState->{endgame} = 2;
					print STDERR "ENDGAME -> 2[TAT-LTLEAD]\n" if ($parseDebug || $stateDebug);
				} else {
					print STDERR "ENDGAME NOT SET (ST: ".$parserState->{seenToken}.", OC: ".$parserState->{onlyComments}.") [TAT-LTPARENTLEAD]\n" if ($parseDebug);
				}
			} elsif (!$parserState->{seenToken}) {
				if ($parserState->{leadspace}) {
					my $temp = ' ' x $parserState->{leadspace};
					$treeCur = $treeCur->addSibling($temp, 0);
				}
			}

			if (($parserState->{leadspace} == -1) && (!$parserState->{seenLeading})) {
				$parserState->{leadspace} = 0;
				$parserState->{setleading} = 1;
				print STDERR "SETLEADING -> 1[2]\n" if ($parseDebug || $stateDebug);
				print STDERR "leadspace -> ".$parserState->{leadspace}."\n" if ($parseDebug || $stateDebug);
			}
			$parserState->{seenToken} = 1;
		}
		print STDERR "POSTCMP: ".$parserState->{seenLeading}." TO ".$parserState->{leadspace}."\n" if ($parseDebug);


		if (($parserState->{endgame} != 2) && ($parserState->{endgame} != 3)) {
		    SWITCH: {
			($parserState->{endgame} == 1 && $part =~ /\S/) && do {
				if ($parserState->{onlyComments}) { 
					print STDERR "Only comments, so not setting endgame\n" if ($parseDebug);
					$parserState->{endgame} = 0;
					print STDERR "ENDGAME -> 0[ONLYCOMMENTS]\n" if ($parseDebug || $stateDebug);
				} else {
					$parserState->{endgame} = 2;
					print STDERR "ENDGAME -> 2[WAS1]\n" if ($parseDebug || $stateDebug);
					$parserState->{popAfter} = 1;
					last SWITCH;
				}
				# Fall through to next matching case;
			};
			($part eq "=") && do {
				if (!($parserState->{inComment} || $parserState->{inChar} ||
				      $parserState->{inInlineComment} || $parserState->{inString})) {
					$parserState->{valuepending} = 1;
				}
			};
			($part eq ":") && do {
				if ($parserState->{bracePending}) {
					print STDERR "BRACE IS PENDING\n" if ($parseDebug);
					$parserState->{nestAfter} = 1;
					$parserState->{popAtEnd} = 1;
					if (($parserState->{pushParserStateOnBrace} == 1)) {
						$parserState->{pushParserStateOnBrace} = 2;
					}
					if ($parserState->{autoContinue} == 1) {
						$parserState->{seenBraces} = 1;
					}
				}
			};
			($part =~ /[\n\r]/) && do {
				print STDERR "newline\n" if ($parseDebug);
				if ($parserState->isQuoted($lang, $sublang)) {
					$parserState->{lastNLWasQuoted} = 1;
					print STDERR "lastNLWasQuoted -> 1\n" if ($spaceDebug || $stateDebug);
				} else {
					print STDERR "MAYBE ENDGAME: AC IS ".$parserState->{autoContinue}."\n" if ($parseDebug);
					$parserState->{lastNLWasQuoted} = 0;
					print STDERR "lastNLWasQuoted -> 0\n" if ($spaceDebug || $stateDebug);
					if ((!$parserState->{autoContinue}) && (!$parserState->{onlyComments})) {
						print STDERR "ENDGAME\n" if ($parseDebug);
						$parserState->{endgame} = 1;
						print STDERR "ENDGAME -> 1[NEWLINE]\n" if ($parseDebug || $stateDebug);
					}
				}
				last SWITCH;
			};
			($part =~ /\s/) && do {
				print STDERR "whitespace\n" if ($parseDebug);
				last SWITCH;
			};
			(($part eq "[") || ($part eq "(")) && do {
				print STDERR "OPAREN OR LEFT BRACKET: $part\n" if ($parseDebug);
				if (!($parserState->{inComment} || $parserState->{inChar} ||
				      $parserState->{inInlineComment} || $parserState->{inString})) {
					$parserState->pushBrace($part);
					$parserState->{nestAfter} = 1;
					if ($part eq "(") {
						$parserState->{parsedParamParse} = 1;
					}
				}
				last SWITCH;
			};
			(($part eq ")") || ($part eq "]")) && do {
				print STDERR "CPAREN OR RIGHT BRACKET: $part\n" if ($parseDebug);
				if (!($parserState->{inComment} || $parserState->{inChar} ||
				      $parserState->{inInlineComment} || $parserState->{inString})) {
					if ($part ne $parserState->peekBraceMatch()) {
						warn("Braces do not match.  We may have a problem.\n");
					} else {
						my $junk = $parserState->popBrace();
					}
					$parserState->{popAfter} = 1;
					if ($part eq ")") {
						$parserState->{parsedParamParse} = 3;
					}
				}
				last SWITCH;
			};
			($part eq "\"" && (!$parserState->isQuoted($lang, $sublang))) && do {
				print STDERR "DOUBLE QUOTE\n" if ($parseDebug);
				if (!($parserState->{inComment} || $parserState->{inChar} ||
				      $parserState->{inInlineComment})) {
					print STDERR "IS: ".$parserState->{inString}."\n" if ($parseDebug);
					if ($parserState->{inString} == 1) {
						if ($parserState->{lastpart} eq "\"") {
							print STDERR "SET JLST: $treeCur\n" if ($parseDebug);
							$parserState->{justLeftStringToken} = 1;
						}
						$parserState->{inString} = 0;
						$parserState->{popAfter} = 1;
					} elsif ($parserState->{inString} == 2) {
						print STDERR "EOTQ: ".$parserState->{endOfTripleQuote}." EG: ".$parserState->{endgame}."\n" if ($parseDebug);
						if ($parserState->{endOfTripleQuote} == 2) {
							$parserState->{endOfTripleQuote} = 0;
							$parserState->{inString} = 0;

							print STDERR "$parserState"."->{endOfTripleQuoteToken} WAS ".$parserState->{endOfTripleQuoteToken}."\n" if ($parseDebug);
							# wipe out the previous two quote marks and merge them.
							my $firstquote = $parserState->{endOfTripleQuoteToken};
							bless($firstquote, "HeaderDoc::ParseTree");
							$firstquote->token("");
							$firstquote->next()->token("");
							$treepart = "\"\"\"";
							if ($parserState->popBrace() ne "\"\"\"") {
								die("Top of brace stack not \"\"\" as expected.\n");
							}
							$parserState->{popAfter} = 1;
						} else { 
							if ($parserState->{endOfTripleQuote} == 1) {
								# treeCur contains the first of a possible
								# triple while leaving.  Store it for later.
								$parserState->{endOfTripleQuoteToken} = $treeCur;
								print STDERR "SET $parserState"."->{endOfTripleQuoteToken} = $treeCur\n" if ($parseDebug);
							}
							$parserState->{endOfTripleQuote} =
							    $parserState->{endOfTripleQuote} + 1;
						}
					} elsif ($parserState->{justLeftStringToken}) {
						$parserState->{inString} = 2; # triple quoted string

						# wipe out the previous two quote marks and merge them.
						print STDERR "IN TQUO\n" if ($parseDebug);
						$treepart = "\"\"\"";
						$treeCur->dbprint() if ($parseDebug);
						$treeCur->token($treepart);
						$treeCur->firstchild()->next()->token("");
						$treeCur->firstchild()->next(undef);
						$parserState->pushBrace($treepart);
						$parserState->{nestAfter} = 2;
						$treepart = "";
						print STDERR "NA: ".$parserState->{nestAfter}."\n" if ($parseDebug);
						print STDERR "CHECK: ".$parserState->{endgame}."\n" if ($parseDebug);
					} else {
						$parserState->{nestAfter} = 1;
						$parserState->{inString} = 1;
					}
				}
				last SWITCH;
			};
			($part eq "\\") && do {
				$parserState->addBackslash();
			};
			($part eq "'" && (!$parserState->isQuoted($lang, $sublang))) && do {
				print STDERR "SINGLE QUOTE\n" if ($parseDebug);
				if (!($parserState->{inComment} || $parserState->{inString} ||
				      $parserState->{inInlineComment})) {
					if ($parserState->{inChar}) {
						$parserState->{inChar} = 0;
						$parserState->{popAfter} = 1;
					} else {
						$parserState->{inChar} = 1;
						$parserState->{nestAfter} = 1;
					}
				}
				last SWITCH;
			};
			($part =~ /\s/) && do {
				print STDERR "whitespace\n" if ($parseDebug);
				last SWITCH;
			};
			($part =~ $parseTokens{classregexp}) && do {
				if (!($parserState->{inComment} || $parserState->{inString} ||
				      $parserState->{inChar} || $parserState->{inInlineComment})) {
					$parserState->{sodclass} = "class";
					$parserState->{inClass} = 1;
					$parserState->{classtype} = "class";
					$parserState->{namepending} = 1;
					$parserState->{bracePending} = 1;
					# $parserState->pushBrace($part);
					$parserState->{autoContinue}++;
					$parserState->{pushParserStateOnBrace} = 1;
				}
				last SWITCH;
			};
			($part eq $parseTokens{sofunction}) && do {
				if (!($parserState->{inComment} || $parserState->{inString} ||
				      $parserState->{inChar} || $parserState->{inInlineComment})) {
					$parserState->{sodclass} = "function";
					$parserState->{namepending} = 1;
					$parserState->{bracePending} = 1;
					# $parserState->pushBrace($part);
					$parserState->{autoContinue}++;
				}
				last SWITCH;
			};
			{
				print STDERR "NP: ".$parserState->{namepending}." PART \"$part\"\n" if ($parseDebug || $nameDebug);
				if (($parserState->{namepending}) &&
				    ((!($parserState->{inString} || $parserState->{inComment} || $parserState->{inChar} ||
				       $parserState->{inInlineComment})) && ($part =~ /\w/))) {

					print STDERR "NAME CHANGED TO $part\n" if ($parseDebug || $nameDebug);
					$parserState->{sodname} = $part;
					$parserState->{namepending} = 0;
					if (!$parserState->{sodclass}) {
						$parserState->{sodclass} = "variable";
					}
				}
				print STDERR "default\n" if ($parseDebug);
			};
		    }
		}

		if ($parserState->{parsedParamParse} == 1) {
			print "PPL -> 2\n" if ($parmDebug);
			$parserState->{parsedParamParse} = 2;
		} elsif ($parserState->{parsedParamParse}) {
			if (($part eq ",") || ($parserState->{parsedParamParse} == 3)) {
				if ($parserState->{parsedParamParse} == 3) {
					$parserState->{parsedParamParse} = 0;
				}
				print STDERR "Pushing ".$parserState->{parsedParam}." onto parsed parameters list.\n" if ($parmDebug);
				push(@{$parserState->{parsedParamList}}, $parserState->{parsedParam});
				$parserState->{parsedParam} = "";
			} else {
				$parserState->{parsedParam} .= $part;
			}
		}

		if ((!($parserState->{inString} || $parserState->{inComment} || $parserState->{inChar} ||
                       $parserState->{inInlineComment})) && ($part =~ /\w/)) {
			if ($parserState->{onlyComments}) {
				$parserState->{setHollowAfter} = 1;
				# $parserState->setHollowWithLineNumbers($treeCur, $fileoffset, $inputCounter);
				print STDERR "ONLYCOMMENTS -> 0\n" if ($parseDebug || $stateDebug);
				$parserState->{onlyComments} = 0;
			}
		}

		if (($parserState->{endgame} != 2) && ($parserState->{endgame} != 3)) {
			if ($parserState->{valuepending} == 1) {
				# Skip the "=" part.
				$parserState->{valuepending} = 2;
				$parserState->{preEqualsSymbol} = $parserState->{sodname};
			} elsif ($parserState->{valuepending} == 2) {
				$parserState->{value} .= $part;
			}

			if ($part ne "\"") {
				$parserState->{justLeftStringToken} = 0;
				$parserState->{endOfTripleQuote} = 0;
			}
			if ($part ne "\\" && $part =~ /\S/) {
				$parserState->resetBackslash();
			}

			if ($treepart ne "") {
				print STDERR "ADDED PART AS SIBLING OF $treeCur: " if ($parseDebug);
				$treeCur = $treeCur->addSibling($treepart, $parserState->{seenBraces});
				print STDERR "$treeCur\n" if ($parseDebug);
			} else {
				print STDERR "TREEPART EMPTY.  NOT ADDING\n" if ($parseDebug);
			}
		} else {
			print STDERR "ENDGAME == ".$parserState->{endgame}.".  NOT ADDING\n" if ($parseDebug);
		}

		if (($parserState->{nestAfter}) && (!$parserState->{endgame})) {
			print STDERR "TREEPUSH\n" if ($parseDebug);
			$parserState->treePush($treeCur);
			if ($parserState->{nestAfter} == 2) {
				print STDERR "TREENESTLITE\n" if ($parseDebug);
				$treeCur = $treeCur->firstchild();
			} else {
				print STDERR "TREENEST\n" if ($parseDebug);
				$treeCur = $treeCur->addChild("", $parserState->{seenBraces});
			}
			$parserState->{nestAfter} = 0;
		} elsif ($parserState->{popAfter}) {
			$parserState->{popAfter} = 0;
			print STDERR "TREEPOP\n" if ($parseDebug);
			$treeCur = $parserState->treePop() || $treeCur;
			print STDERR "TREECUR: \"$treeCur\"\n" if ($parseDebug);
		}
		if ($parserState->{pushParserStateOnBrace} == 2) {
			$parserState->{pushParserStateOnBrace} = 3;
			print STDERR "ENDCMP: ".$parserState->{seenLeading}." TO ".$parserState->{leadspace}."\n" if ($parseDebug);
			push(@parserStack, $parserState);
			my $leading = $parserState->{seenLeading};
			my $parentLeading = $parserState->{leadspace};

			print STDERR "NEW PARSER STATE (PPSOB)\n" if ($parseDebug || $stateDebug);
			$parserState = HeaderDoc::ParserState->new( "FULLPATH" => $fullpath, "lang" => $lang, "sublang" => $sublang );
			# $parserState->setHollowWithLineNumbers($treeCur, $fileoffset, $inputCounter);
			$parserState->{lang} = $lang;
			$parserState->{inputCounter} = $inputCounter;
			$parserState->{initbsCount} = 0; # included for consistency....
			$parserState->{parentLeading} = $parentLeading || 0;
			$parserState->{leadspace} = -1;
			print STDERR "PARENTLEADING -> ".$parserState->{parentLeading}."\n" if ($parseDebug || $stateDebug);

			# In the brace case, we haven't gotten the leading space yet.
			# if ($leading ne "" && $leading != -1) {
				# print STDERR "SETTING LEAD SPACE TO \"$leading\"\n" if ($parseDebug);
				# $parserState->{seenLeading} = $leading;
				# $parserState->{leadspace} = $leading;
			# }
		}

		if ($parserState->{setHollowAfter}) {
			$parserState->{setHollowAfter} = 0;
			$parserState->setHollowWithLineNumbers($treeCur, $fileoffset, $inputCounter);
			print STDERR "SET HOLLOW TO $treeCur\n" if ($parseDebug);
		}

		if ($parserState->{endgame} == 2 || $parserState->{endgame} == 3) {
			# Either the part has to be reprocessed with the new parser
			# state (so redo it) or it's time to quit entirely.

			if (!scalar(@parserStack)) {
				$continue = 0;
				$inputCounter--;
				print STDERR "Decremented inputCounter from ".($inputCounter+1)." to $inputCounter [1]\n" if ($inputCounterDebug);
				last;
			} elsif (!$parserState->{onlyComments}) {
				# @@@ FIXME? @@@
				my $treeRef = $parserState->{hollow};
				print STDERR "NEW PARSER STATE (ENDGAME)\n" if ($parseDebug || $stateDebug);

				my $leading = $parserState->{seenLeading};

				$parserState->{lastTreeNode} = $treeCur;

				if ($parserState->{popAtEnd} == 1) {
					print STDERR "POP AT END\n" if ($parseDebug);
					$parserState->{popAtEnd} = 0;
					$parserState->{popAfter} = 0;
					print STDERR "TREEPOP\n" if ($parseDebug);
					$treeCur = $parserState->treePop() || $treeCur;
					print STDERR "TREECUR: \"$treeCur\"\n" if ($parseDebug);
				}

				# if ($treeRef) {
				$treeRef->addRawParsedParams(\@{$parserState->{parsedParamList}});
				$treeRef->parserState($parserState);
				print STDERR "HOLLOW: ADDED $parserState to $treeRef\n" if ($parseDebug);
				# } else {
					# warn("Can't find hollow.  This might be a bug.\n");
				# }

				my $parentLeading = $parserState->{parentLeading};

				if ($parserState->{endgame} == 3) {
					# leaving a class.
					$continue = 0;
					$inputCounter--;
					print STDERR "Decremented inputCounter from ".($inputCounter+1)." to $inputCounter [2]\n" if ($inputCounterDebug);
					last;
				} else {
					$parserState = HeaderDoc::ParserState->new( "FULLPATH" => $fullpath, "lang" => $lang, "sublang" => $sublang );
					if ($leading ne "" && $leading != -1) {
						print STDERR "SETTING LEAD SPACE TO \"$leading\"\n" if ($parseDebug);
						$parserState->{seenLeading} = $leading;
						$parserState->{leadspace} = $leading;
					}
					$parserState->{parentLeading} = $parentLeading
				}
			}
			if ($anyDebug) { print STDERR "REDO\n"; }
			goto REDO;
		} else {
			# This part has been handled.  Move on to the
			# next one.
			$parserState->{lastpart} = $part;
			$part = $nextpart;
		}
	}

	print STDERR "Incremented inputCounter from $inputCounter to ".($inputCounter+1)."\n" if ($inputCounterDebug);
	$inputCounter++;
    }

    while (scalar(@parserStack)) {
	$parserState = pop(@parserStack);
    }


    my $inPrivateParamTypes = 0;
    my $declaration = $treeTop->textTree();
    my $publicDeclaration = "";
    my $lastACS = "";

    # $retDebug = 1;

    print STDERR "LEAVING PARSER\n" if ($parseDebug || $stateDebug);

    return HeaderDoc::BlockParse::blockParseReturnState($parserState, $treeTop, $argparse, $declaration, $inPrivateParamTypes, $publicDeclaration, $lastACS, $retDebug, $fileoffset, 0, $parseTokens{definename}, $inputCounter, $lang, $sublang);
}

1;


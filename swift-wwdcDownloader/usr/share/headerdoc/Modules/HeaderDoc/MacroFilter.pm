#!/usr/bin/perl
#
# Class name: MacroFilter
# Synopsis: Used for filtering content based on #if/#ifdef directives
#
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

# /*! @header
#     @abstract
#         <code>MacroFilter</code> class package file.
#     @discussion
#         This file contains the <code>MacroFilter</code> class, used for
#         filtering out sections of a header based on C preprocessor
#         directives.
#
#         See the class documentation below for details.
#     @indexgroup HeaderDoc Parser Pieces
#  */

# /*! @abstract
#         Filters content based on C preprocessor directives.
#     @discussion
#         This class is basically a data structure for interpreting
#         if statements, #if statements, and other similar conditional
#         statements (e.g. switch), depending on the value of
#         {@link HeaderDoc::interpret_case}.
#
#         The way the tree behaves regarding unknown tokens is described
#         in more detail in the discusion for {@link doit}.
#
#     @vargroup Trees and content strings
#
#     @var IFDECLARATION
#         The #if declaration itself.
#     @var IFGUTS
#         The contents of an if/#if statement (from the
#         {@link //apple_ref/perl/data/HeaderDoc::ParserState/ifContents ifContents}
#         field in the {@link //apple_ref/perl/cl/HeaderDoc::ParserState ParserState}
#         class).
#     @var IFTREE
#         A constraint tree representing any nested if/#if statements or
#         similar within the "if" side of this conditional.
#     @var ELSEGUTS
#         The contents of an else statement (from the
#         {@link //apple_ref/perl/data/HeaderDoc::ParserState/elseContents elseContents}
#         field in the {@link //apple_ref/perl/cl/HeaderDoc::ParserState ParserState}
#         class).
#     @var ELSETREE
#         A constraint tree representing any nested if/#if statements or
#         similar within the "else" side of this conditional.
#     @var SWITCHGUTS
#         The contents of an switch statement (from the
#         {@link //apple_ref/perl/data/HeaderDoc::ParserState/functionContents functionContents}
#         field in the {@link //apple_ref/perl/cl/HeaderDoc::ParserState ParserState}
#         class).  Not currently used by HeaderDoc.
#     @var SWITCHTREE
#         A constraint tree representing any nested if/#if statements or
#         similar within the body of a switch statement.  Not currently
#         used by HeaderDoc.
#     @var NEXT
#         The next constraint.  This represents any statement that should
#         be treated as an alternative to this one.
#
#         For example, if you have <code>A || B</code>, then for the
#         constraint <code>A</code>, the <code>MEXT</code> constraint
#         is the constraint for <code>B</code>.
#     @var PREVIOUS
#         Points to the constraint whose <code>NEXT</code> field points to
#         this one.
#     @var FIRSTCHILD
#         Points to a constraint that should be treated as mandatory in order
#         for this constraint to succeed.  In other words, an "AND" clause.
#
#         For example, if you have <code>A || B</code>, the
#         <code>FIRSTCHILD</code> chain for <code>A</code> points to
#         the constraint for <code>B</code>.
#     @var PARENT
#         Points to the constraint whose <code>FIRSTCHILD</code> field points
#         to this one or to a constraint in this constraint's <code>PREV</code>
#         chain.
#     @var LASTJOIN
#         The joining operator that connects this to its immediate predecessor
#         in the actual code.  For something hanging off the NEXT tree, this
#         is usually "||".  For something hanging off the "FIRSTCHILD" tree,
#         this is usually "&&".  In the case of a parenthesis constraint, the
#         value of <code>LASTJOIN</code> is an open parenthesis.
#     @var PARENTREE
#         The tree of constraints for contents within this parenthesis
#         constraint.
#
#         For example, if you have the string <code>(A || B)<code>, the
#         top constraint represents the open parenthesis.  Its
#         <code>PARENTREE<code> chain points to the constraint for
#         <code>A</code> (whose <code>NEXT</code> field, in turn, points
#         to the constraint for <code>B</code>).
#     @var PREVPAREN
#         For a parenthesis token, a reference to the enclosing
#         parenthesis token.
#
#         If <code>HeaderDoc::interpret_case</code> is set, then for
#         a <code>case</code> statement, this points to the enclosing
#         switch statement.
#     @var PARENWRAPPER
#         The parenthesis token that encloses the current token.
#         Used as the fast path cache for {@link unrolltoparen}.
#
#     @vargroup Temporary storage
#
#     @var TOKENCONCAT
#         Contains a token that might be followed by another token as part
#         of an operator or might live on its own.  This is a temporary
#         value used while building the constraint tree.
#
#         For example, while building up the tree, when the parser encounters
#         an exclamation point (<code>!</code>), this could either negate
#         the token after it or could be part of a not-equals operator
#         (<code>!=</code>).  Until it knows which, the exclamation point
#         gets stored in the <code>TOKENCONCAT</code> field.
#     @var GROUP
#         Set to true for the <code>defined</code> token and the
#         <code>case</code> token (<code>switch</code>).  This is
#         vestigial.  Do not depend on this behavior.
#
#     @vargroup Comparison constraint parts
#
#     @var LEFTISSYMBOL
#         If set, the left side of the comparison is nonempty and was
#         either explicitly defined or undefined by flags on the
#         command line.
#     @var LEFTVALUE
#         The numerical value assigned to the left side of the
#         comparison.
#     @var LEFTTOKEN
#         The actual text token from the left side of the comparison.
#     @var LEFTDONTCARE
#         The value on the left side is a symbol that was neither
#         explicitly defined (-D flag) nor undefined (-U flag).
#
#     @var COMPARISON
#         The comparison operator itself.
#
#     @var RIGHTISSYMBOL
#         If set, the right side of the comparison is nonempty and was
#         either explicitly defined or undefined by flags on the
#         command line.
#     @var RIGHTVALUE
#         The numerical value assigned to the right side of the
#         comparison.
#     @var RIGHTTOKEN
#         The actual text token from the right side of the comparison.
#     @var RIGHTDONTCARE
#         The value on the right side is a symbol that was neither
#         explicitly defined (-D flag) nor undefined (-U flag).
#         
#     @var WAITINGCOMPARISON
#         A comparison found before any recognized tokens.
#     @var WAITINGTOKEN
#         A token found before any comparisons.
#
#     @vargroup Miscellaneous attributes
#
#     @var DEFINED
#         True if the token is the word "defined".  Used for interpreting
#         <code>#if (defined(...))</code> statements.
#     @var NOT
#         True if the constraint's token was preceded by an exclamation
#         point that inverts this constraint's return values.
#     @var ISPAREN
#         True if the constraint is for a parenthesis.
#     @var ALWAYSFALSE
#         If set, this constraint always returns false.  This is
#         vestigial; this flag is never set.  Do not depend on this
#         behavior.
#     @var DEFINEDSKIPCP
#         Used to prevent normal parenthesis nesting in contexts
#         where it makes no sense.
#     @var HASRETURNORBREAK
#         Cache for the {@link hasReturnOrBreak} function.
#  */
package HeaderDoc::MacroFilter;

BEGIN {
        foreach (qw(Mac::Files)) {
            $MOD_AVAIL{$_} = eval "use $_; 1";
    }
}


#insert start
use lib "/System/Library/Perl/Extras/5.8.6/";
use HeaderDoc::BlockParse qw(blockParse);
use HeaderDoc::ParserState;
use HeaderDoc::ParseTree;
use HeaderDoc::APIOwner;
use File::Basename qw(basename);
use strict;
use vars qw(@ISA @EXPORT $VERSION);
# use Carp qw(cluck);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::MacroFilter::VERSION = '$Revision: 1298084578 $';
@ISA = qw(Exporter);
@EXPORT = qw(ignoreWithinCPPDirective filterFileString run_macro_filter_tests
		matchesconstraints doit printconstraint newchild newsibling
                unrolltoparen walkTree hasReturnOrBreak);

my $debug = 0;
my $matchdebug = 0;
my $debug_hrb = 0;
my $stackDebug = 0;

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

#insert end

# $/ = undef;

# Set to 1 for value we want defined to a particular value.
# Set to -1 for value we want to be explicitly undefined.
# The implicit value 0 means "don't care".
%HeaderDoc::filter_macro_definition_state = (
);

# Values for ignore_expressions
# Only used if HeaderDoc::filter_macro_definition_state value is 1.
%HeaderDoc::filter_macro_definition_value = (
);


# /*!
#     @abstract
#         Runs a series of tests on the macro filter engine.
#  */
sub run_macro_filter_tests
{
	my $lang = "C";
	my $sublang = "C";

	$HeaderDoc::lang = $lang;
	$HeaderDoc::sublang = $sublang;
	my $headerObj = HeaderDoc::APIOwner->new("LANG" => $lang, "SUBLANG" => $sublang);

	$headerObj->lang($lang);
	$headerObj->sublang($sublang);
	$HeaderDoc::headerObject = $headerObj;

	%HeaderDoc::filter_macro_definition_state = (
		"FOO" => 1,
		"BAR" => 1,
		"BAZ" => 1,
		"DEFZ" => 1,
		"NDEF" => -1,
		"LANGUAGE_OBJECTIVE_C" => -1,
		"LANGUAGE_JAVASCRIPT" => 1
	);

	%HeaderDoc::filter_macro_definition_value = (
		"FOO" => 1,
		"BAR" => 2,
		"BAZ" => 3,
		"DEFZ" => 0,
		"LANGUAGE_JAVASCRIPT" => 1
	);

	my $good = 0;
	my $bad = 0;

        print STDERR "-= Running macro filter tests =-\n\n";

	if (dotest("if ((10 < 3) && 10 < 5 || 10 > 9)", 1, $lang, $sublang)) { $good++; } else { $bad++; } # (BAT is a "don't care")
	if (dotest("if (BAT && (FOO || BAR) && BAZ && BAG)", -3, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (BAT && (FOO || BAR) && !BAZ && BAG)", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (BAT && (FOO || BAR) && BAZ && !BAG)", -3, $lang, $sublang)) { $good++; } else { $bad++; } # (BAG is a "don't care")
	if (dotest("if (!BAT && (FOO || BAR) && BAZ && !BAG)", -3, $lang, $sublang)) { $good++; } else { $bad++; } # (BAT is a "don't care")
	if (dotest("if (BAT && !(FOO || BAR) && BAZ && !BAG)", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (BAT && !(BAG) && BAZ && !BAG)", -3, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (BAT && !(FOO) && BAZ && !BAG)", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (BAT && (FOO < BAR) && BAZ && BAG)", -3, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (BAT && (FOO > BAR) && BAZ && BAG)", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (0)", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (1)", 1, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (defined(FOO))", 1, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (defined(BAG))", -3, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (defined(NDEF))", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (defined(DEFZ))", 1, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (!defined(FOO))", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (!defined(BAG))", -3, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (!defined(NDEF))", 1, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (!defined(DEFZ))", 0, $lang, $sublang)) { $good++; } else { $bad++; }
	if (dotest("if (FOO && 1)", 1, $lang, $sublang)) { $good++; } else { $bad++; }

	print STDERR "\n";

	return ($good, $bad);
}

# /*!
#     @abstract
#         Determines whether the contents of a given C preprocessor
#         directive should be ignored or not.
#     @param cpp_command
#         The C preprocessor command (e.g. "#if").
#     @param text
#         The entire contents of the #if/#else/#ifdef, including
#         the enclosed text (but not including the #else for a #if).
#     @param curshow
#         Indicates whether the previous block is ignored.  Used to
#         determine whether #else clauses should return true or false.
#     @discussion
#         The primary purpose of this function is to pre-parse the
#         declaration and scrape out only the actual #if expression
#         without the contents.
#
#         Secondarily, this simplifies "#ifdef" to "#if (defined(...))"
#         so that the later parsing code is smaller.
#  */
sub ignoreWithinCPPDirective($$$)
{
	my $cpp_command = shift;
	my $text = shift;
	my $curshow = shift;

	my $localDebug = 0;

	my ($expression, $rest) = split(/\n/s, $text, 2);

	if (!$curshow && ($cpp_command ne "#elif")) {
		return (0, "", "");
	}

	# Handle run-ons.
	while ($expression =~ /\\\s*$/) {
		my ($a, $b) = split(/\n/s, $rest, 2);
		$expression =~ s/\\\s*$//s;
		$expression .= " ".$a;
		$rest = $b;
	}

	print STDERR "EXPRESSION: $expression\n" if ($localDebug);

	my $ignore = 0;

	my $tree = undef;
	my @junk = undef;
	if ($cpp_command eq "#if" || $cpp_command eq "#elif") {
		print STDERR "#if/#elif\n" if ($localDebug);
		($tree, @junk) = doit("if (".$expression.")");
	} elsif ($cpp_command eq "#ifdef") {
		print STDERR "#ifdef\n" if ($localDebug);
		($tree, @junk)  = doit("if (defined(".$expression."))");
	} elsif ($cpp_command eq "#ifndef") {
		print STDERR "#ifndef\n" if ($localDebug);
		($tree, @junk)  = doit("if (!defined(".$expression."))");
	} else {
		die("Unknown CPP command $cpp_command in ignoreWithinCPPDirective\n");
	}

	my $matches = matchesconstraints($tree);

	print STDERR "MATCHES: $matches\n" if ($localDebug);

	return ($matches, $rest, $tree->{IFDECLARATION});
}

# /*!
#     @abstract
#         Parses a #if/#ifdef/#else block and builds up a constraint tree.
#     @param block
#         The block of code to parse.
#     @discussion
#
# Called by {@link ignoreWithinCPPDirective}, calls itself recursively,
# and called by {@link dotest}.
#
# This is the core of the macro filter engine.  This parses the declaration
# using {@link blockParse}, calls {@link walkTree} to build up a constraint
# tree.  The calling function can then call {@link matchesconstraints} to
# determine whether to include or exclude the content within any portion
# of the content.
# 
#
# <b>Propagation of "Don't care":</b>
#
# If a symbol is marked as an explicit "must be undefined", its value is 0
# just as it would be with a real C preprocessor.  However, this leaves open
# the issue of symbols for which no value is specified.  We call tese "don't
# care" values.
# 
# The way these values are handled makes it possible to have combinations that
# cannot occur in the real world (a value being interpreted one way in one spot
# and differently in another spot).  This is intentional because we prefer
# inclusion over exclusion for these values in all cases.
#
# To support this goal, when we see an unknown symbol, we mark that constraint as
# a "don't care" value.  This propagates up the chain as follows:
#
# 1.  Check && chain (parent/child).  If we get a logic false farther down,
#     constraint must be false because "false && X" is false for all X.
# 2.  Check || chain (siblings).  If we get a logic true to the left or right,
#     constraint must be true because "true && X" is true for all X.
# 3.  If we get here, propagate DC up one level.
# 4.  If top level is DC, assume true.
# */
sub doit
{
	my $block = shift;
	my $lang = shift;
	my $sublang = shift;
	my $return_hrb = 0;

	my $hierDebug = 0;

	# print STDERR "BLOCK: \"$block\"\n";

	my @inputLines = split(/\n/, $block);
	# my @symbols = split(/\s+/, "FOO");

	my $firstconstraint = newconstraint();
	my $constraint = $firstconstraint;
	my $inputCounter = 0;
	my $nlines = $#inputLines;
	print STDERR "Root constraint is $constraint\n" if ($debug);
	print STDERR "$nlines $inputCounter $debug\n" if ($debug);

	my ($case_sensitive, $keywordhashref) = $HeaderDoc::headerObject->keywords();
	my @cparray = ();

	# print STDERR "LANG: $lang SUBLANG: $sublang\n";

	while ($inputCounter <= $nlines) {
		my ($newInputCounter, $dec, $type, $name, $pt, $value, $pplref, $returntype, $pridec, $parseTree, $simpleTDcontents, $bpavail, $fileoff, $conformsToList, $functionContents, $parserState) = &blockParse("myheader.h", 0, \@inputLines, $inputCounter, 0, \%HeaderDoc::ignorePrefixes, \%HeaderDoc::perHeaderIgnorePrefixes, \%HeaderDoc::perHeaderIgnoreFuncMacros, $keywordhashref, $case_sensitive, $lang, $sublang);
		print STDERR "FC: $functionContents\n" if ($debug);
		print STDERR "TYPE: $type NAME: $name\n" if ($debug);
		$inputCounter = $newInputCounter;

		print STDERR "GOT DEC:\n" if ($debug || $hierDebug);
		print STDERR $parseTree->textTree() if ($debug || $hierDebug);
		print STDERR "END DEC.\n\n" if ($debug || $hierDebug);

		$constraint = newsibling($constraint, $constraint);
		$constraint->{IFDECLARATION} = $parseTree->textTree();

		# $parseTree->dbprint();
		# print "FUNCTIONCONTENTS:\n".$functionContents."\nENDFUNCTIONCONTENTS\n";
		my ($junk1, $junk2) = walkTree($parseTree, $constraint, $constraint, $constraint);
		# $parseTree->dbprint();
		# printconstraint($constraint) if ($debug);

		my %temp = ();
		$temp{CONSTRAINT} = $constraint;
		$temp{FUNCTIONCONTENTS} = $functionContents;
		push(@cparray, \%temp);

		my $ifHRB = 0;
		my $elseHRB = 0;

		if ($parserState->{ifContents}) {
			print STDERR "HAS IF\n" if ($hierDebug);
		}
		if ($parserState->{elseContents}) {
			print STDERR "HAS ELSE\n" if ($hierDebug);
		}
		if ($parserState->{ifContents}) {
			print STDERR "IF CONTENTS:\n" if ($hierDebug);
			print STDERR $parserState->{ifContents} if ($hierDebug);
			print STDERR "END IF CONTENTS\n" if ($hierDebug);

			print STDERR "RECURSE IN (IF)\n" if ($hierDebug);
			my ($tree2, @cparray2) = doit($parserState->{ifContents}, $lang, $sublang);
			print STDERR "RECURSE OUT (IF)\n" if ($hierDebug);
			$constraint->{IFGUTS} = $parserState->{ifContents};
			$constraint->{IFTREE} = $tree2;
			print STDERR "ADDED $tree2 AS IFTREE OF $constraint\n" if ($hierDebug);
		}
		if ($parserState->{elseContents}) {
			print STDERR "ELSE CONTENTS:\n" if ($hierDebug);
			print STDERR $parserState->{elseContents} if ($hierDebug);
			print STDERR "END ELSE CONTENTS\n" if ($hierDebug);

			print STDERR "RECURSE IN (ELSE)\n" if ($hierDebug);
			my ($tree2, @cparray2) = doit($parserState->{elseContents}, $lang, $sublang);
			print STDERR "RECURSE OUT (ELSE)\n" if ($hierDebug);
			$constraint->{ELSEGUTS} = $parserState->{elseContents};
			$constraint->{ELSETREE} = $tree2;
			print STDERR "ADDED $tree2 AS ELSETREE OF $constraint\n" if ($hierDebug);
		}
		if ($parserState->{functionContents}) {
			print STDERR "SWITCH CONTENTS:\n" if ($hierDebug);
			print STDERR $parserState->{functionContents} if ($hierDebug);
			print STDERR "END SWITCH CONTENTS\n" if ($hierDebug);

			print STDERR "RECURSE IN (SWITCH)\n" if ($hierDebug);
			my ($tree2, @cparray2) = doit($parserState->{functionContents}, $lang, $sublang);
			print STDERR "RECURSE OUT (SWITCH)\n" if ($hierDebug);
			$constraint->{SWITCHGUTS} = $parserState->{functionContents};
			$constraint->{SWITCHTREE} = $tree2;
			print STDERR "ADDED $tree2 AS SWITCHTREE OF $constraint\n" if ($hierDebug);
		}
	}

	if (!$matchdebug) {
		$debug = 0;
	}

	return ($firstconstraint->{NEXT}, @cparray)
}

# /*!
#     @abstract
#         Creates a new constraint for insertion into the constraint tree.
#  */
sub newconstraint
{
	my $constraint = ();
	$constraint->{PARENT} = undef;
	$constraint->{FIRSTCHILD} = undef;
	$constraint->{NEXT} = undef;
	$constraint->{LASTJOIN} = undef;
	return $constraint;
}

# /*!
#     @abstract
#         Prints a constraint for debugging purposes.
#     @param constraint
#         The constraint node to print.
#     @param nodeonly
#         Indicates that children and successors of this
#         node should not be printed.  (Optional.  Defaults
#         to 0.)
#  */
sub printconstraint
{
	my $constraint = shift;
	my $nodeonly = 0;
	if (@_) {
		$nodeonly = shift;
	}
	my $prespace = "";
	if (@_) {
		$prespace = shift;
	}
	if (!$constraint) { return; }

	my $printconstraintanyway = 1;

	print STDERR "$prespace"."Constraint $constraint\n" if ($debug || $printconstraintanyway);

	if (isnullconstraint($constraint)) {
		print STDERR "$prespace    NULL CONSTRAINT\n" if ($debug || $printconstraintanyway);
	} else {
		my %constrainthash = %{$constraint};
		foreach my $key (keys %constrainthash) {
			print STDERR "$prespace	$key => ".$constraint->{$key}."\n" if ($debug || $printconstraintanyway);
		}
	}
	if (isnullconstraint($constraint)) {
		print STDERR "$prespace    END NULL CONSTRAINT\n" if ($debug || $printconstraintanyway);
	}

	if ($nodeonly) {
		return;
	}

	printconstraint($constraint->{PARENTREE}, 0, "$prespace     PAREN      ");
	printconstraint($constraint->{IFTREE}, 0, "$prespace     IFGUTS_X   ");
	printconstraint($constraint->{ELSETREE}, 0, "$prespace     ELSEGUTS_X ");
	printconstraint($constraint->{SWITCHTREE}, 0, "$prespace   SWITCHGUTS_X ");
	printconstraint($constraint->{FIRSTCHILD}, 0, "$prespace    ");
	printconstraint($constraint->{NEXT}, 0, $prespace);
}

# /*!
#     @abstract
#         Walks through a parse tree and builds up the corresponding
#         constraint tree.
#     @param parseTree
#         The parse tree to walk.
#     @param constraint
#         The constraint to alter.
#     @param parenconstraint
#         The nearest enclosing parenthesis around this constraint.
#     @param topconstraint
#         The top node in the constraint tree.
#  */
sub walkTree($$$$)
{
	my $parseTree = shift;
	my $constraint = shift;
	my $parenconstraint = shift;
	my $topconstraint = shift;
	my $token = $parseTree->token();

	# print STDERR "WALKTREE TOKEN: $token\n";

	my $longtoken = $token;

	print STDERR "TOKEN: $token\n" if ($debug || $debug_hrb);

	my $concat = "";
	if ($constraint->{TOKENCONCAT}) {
		$concat = $constraint->{TOKENCONCAT};
		$longtoken = $constraint->{TOKENCONCAT}.$token;
		$constraint->{TOKENCONCAT} = "";
	}

	print STDERR "in walkTree.  token: \"$token\" longtoken: \"$longtoken\" constraint: $constraint lastjoin: $constraint->{LASTJOIN}\n" if ($debug);
	# printconstraint($topconstraint) if ($debug);

	if ($HeaderDoc::interpret_case && $token eq "case") {

		while ($constraint && $constraint->{NEXT}) {
			$constraint = $constraint->{NEXT};
		}

		$constraint = newsibling($constraint);
		print STDERR "$constraint\n" if ($debug);
		$constraint->{GROUP} = 1;
		$constraint->{LASTJOIN} = undef;
		$constraint->{PREVPAREN} = $parenconstraint;
		print STDERR "Parenthesis constraint changed from $parenconstraint to " if ($debug);
		$parenconstraint = $constraint;
		print STDERR "$parenconstraint\n" if ($debug);

		print STDERR "Constraint changed from $constraint to " if ($debug);
		$constraint = newchild($constraint);
		print STDERR "$constraint\n" if ($debug);
	} elsif ($token eq "(" && (!$constraint->{DEFINED})) {
		my $newconstraint_not = 0;
		if ($concat eq "!") {
			$newconstraint_not = 1;
		}
		print STDERR "Constraint changed from $constraint to " if ($debug);
		# $constraint = newchild($constraint);
		$constraint->{NOT} = $newconstraint_not;
		$constraint->{ISPAREN} = 1;

		print STDERR "$constraint\n" if ($debug);
		$constraint->{GROUP} = 1;
		$constraint->{LASTJOIN} = "(";
		$constraint->{PREVPAREN} = $parenconstraint;
		print STDERR "Parenthesis constraint changed from $parenconstraint to " if ($debug);
		$parenconstraint = $constraint;
		print STDERR "$parenconstraint\n" if ($debug);

		print STDERR "Constraint changed from $constraint to " if ($debug);
		$constraint = newparenguts($constraint);
		print STDERR "$constraint\n" if ($debug);
		$constraint->{LASTJOIN} = "(";
	} elsif ($token eq "(") {
		if (!$constraint->{DEFINEDSKIPCP}) {
			$constraint->{DEFINEDSKIPCP} = 1;
		} else {
			$constraint->{DEFINEDSKIPCP}++;
		}
	} elsif ($longtoken eq ">" || $longtoken eq "<" || $longtoken eq "<=" || $longtoken eq ">=" || $longtoken eq "==" || $longtoken eq "!=") {
		print STDERR "got comparison: $longtoken\n" if ($debug);
		$constraint->{WAITINGCOMPARISON} = $longtoken;
	} elsif ($token eq "defined") {
		my $constraint_not = 0;
		if ($concat eq "!") {
			$constraint_not = 1;
		}
		$constraint->{NOT} = $constraint_not;
		$constraint->{DEFINED} = 1;
	} elsif ($token =~ /\s*\w+\s*/ && $token ne "if" && $token ne "else" && ((!$HeaderDoc::interpret_case) || ($token ne "case" && $token ne "switch"))) {
		print STDERR "got token of interest: $token\n" if ($debug);
		if ($constraint->{WAITINGCOMPARISON}) {
			print STDERR "Already saw comparison.\n" if ($debug);
			print STDERR "LJ: $constraint->{LASTJOIN}\n" if ($debug);
			$constraint = adjconstraint($constraint, $parenconstraint, $topconstraint, $constraint->{WAITINGTOKEN}, $constraint->{WAITINGCOMPARISON}, $token);
			$constraint->{WAITINGTOKEN} = undef;
			$constraint->{WAITINGCOMPARISON} = undef;
			$constraint->{LASTJOIN} = undef
		} else {
			print STDERR "CONSTRAINT IS $constraint\n" if ($debug);
			print STDERR "WAITINGTOKEN -> $token\n" if ($debug);
			$constraint->{WAITINGTOKEN} = $token;
			print STDERR "TOKENCONCAT IS ".$constraint->{TOKENCONCAT}."\n" if ($debug);
			if ($concat eq "!") {
				print STDERR "INVERSE MATCH\n" if ($debug);
				$constraint = adjconstraint($constraint, $parenconstraint, $topconstraint, $constraint->{WAITINGTOKEN}, "==", "0"); # not reversed.
				$constraint->{TOKENCONCAT} = undef;
				$constraint->{WAITINGTOKEN} = undef;
				$constraint->{WAITINGCOMPARISON} = undef;
				$constraint->{LASTJOIN} = undef
			}
		}
	} elsif ($longtoken eq "||") {
		if ($constraint->{WAITINGTOKEN}) {
			$constraint = adjconstraint($constraint, $parenconstraint, $topconstraint, $constraint->{WAITINGTOKEN}, "!=", "0"); # not reversed.
		}
		# Or creates new sibling
		print STDERR "OR\n" if ($debug);
		print STDERR "Constraint changed from $constraint to " if ($debug);
		$constraint = newsibling($constraint, $parenconstraint);
		print STDERR "$constraint\n" if ($debug);
	} elsif ($longtoken eq "&&") {
		if ($constraint->{WAITINGTOKEN}) {
			$constraint = adjconstraint($constraint, $parenconstraint, $topconstraint, $constraint->{WAITINGTOKEN}, "!=", "0"); # not reversed.
			$constraint->{WAITINGTOKEN} = undef;
			$constraint->{LASTJOIN} = undef
		}
		# Or creates new sibling
		print STDERR "AND\n" if ($debug);
		print STDERR "Constraint changed from $constraint to " if ($debug);
		my $oldcons = $constraint;
		# if ($constraint->{LASTJOIN} eq "(") {
			# $parenconstraint = $constraint;
			# $constraint = newsibling($constraint, $parenconstraint);
		# } else {
			$constraint = newchild($constraint);
		# }
	# print "POINTA CONS: $oldcons\n";
	# printconstraint($oldcons);
	# print "POINTB\n";
		print STDERR "$constraint\n" if ($debug);
	} elsif ($HeaderDoc::interpret_case && $token eq ":" && $constraint->{WAITINGTOKEN}) {
		# Inside a case statement.
		# print STDERR "PREVIOUS JOIN: $constraint->{LASTJOIN}\n" if ($debug);
		$constraint = adjconstraint($constraint, $parenconstraint, $topconstraint, $constraint->{WAITINGTOKEN}, $token); # not reversed.
	} elsif ($token eq ")" && !$constraint->{DEFINEDSKIPCP}) {
		if ($constraint->{WAITINGTOKEN}) {
			$constraint = adjconstraint($constraint, $parenconstraint, $topconstraint, $constraint->{WAITINGTOKEN}, "!=", "0"); # not reversed.
			$constraint->{WAITINGTOKEN} = undef;
			$constraint->{LASTJOIN} = undef
		}
		print STDERR "Constraint changed from $constraint to " if ($debug);
		my $oldparenconstraint = $parenconstraint;
		($constraint, $parenconstraint) = unrolltoparen($constraint, $parenconstraint, 1);
		print STDERR "$constraint\n" if ($debug);
		print STDERR "Parenthesis constraint changed from $oldparenconstraint to $parenconstraint\n" if ($debug);
	} elsif ($token eq ")") {
		$constraint->{DEFINEDSKIPCP}--;
	} elsif ($token eq "&" || $token eq "|" || $token eq "!" || $token eq "=") {
		print STDERR "CONSTRAINT IS -> $constraint\n" if ($debug);
		$constraint->{TOKENCONCAT} = $token;
		print STDERR "TOKENCONCAT -> ".$constraint->{TOKENCONCAT}."\n" if ($debug);
	} elsif ($token =~ /\S/) {
		print STDERR "Unexpected token \"$token\".  Resetting\n" if ($debug);
		$constraint->{WAITINGTOKEN} = undef;
		$constraint->{WAITINGCOMPARISON} = undef;
		if (attop($topconstraint, $constraint)) {
			print STDERR "Full reset\n" if ($debug);
			$constraint->{LASTJOIN} = undef;
			$constraint = $topconstraint;
			$parenconstraint = $topconstraint;
			$constraint = newsibling($topconstraint, $parenconstraint);
			$parenconstraint = $constraint;
			print STDERR "New top node: $constraint\n" if ($debug);
			print STDERR "New paren constraint: $parenconstraint\n" if ($debug);
		}
	}

	# HRB: 0 - not yet
	#      1 - found
	#     -1 - looking in "if" case or "else' case
	#     -2 - found in "if" case or "else' case

	if ($token =~ /if/) {
		print STDERR "IF FOUND\n" if ($debug || $debug_hrb);
	} elsif ($token =~ /else/) {
		print STDERR "ELSE FOUND\n" if ($debug || $debug_hrb);
	} elsif ($token =~ /switch/) {
		print STDERR "FOUND $token\n" if ($debug || $debug_hrb);
	} elsif ($token =~ /{/) {
		print STDERR "FOUND $token\n" if ($debug || $debug_hrb);
	} elsif ($token =~ /}/ || $token =~ /;/) {
		print STDERR "FOUND $token\n" if ($debug || $debug_hrb);
	} elsif (($token =~ /break/) || ($token =~ /return/)) {
		print STDERR "FOUND $token\n" if ($debug || $debug_hrb);
		$constraint->{HASRETURNORBREAK} = 1;
	}

	if ($parseTree->firstchild()) {
		($constraint, $parenconstraint) = walkTree($parseTree->firstchild(), $constraint, $parenconstraint, $topconstraint);
	}
	if ($parseTree->next()) {
		return walkTree($parseTree->next(), $constraint, $parenconstraint, $topconstraint);
	}
	return ($constraint, $parenconstraint);
}

# /*!
#     @abstract
#         Adds a new variable or operator to an existing constraint.
#     @param constraint
#         The constraint to alter.
#     @param parenconstraint
#         The nearest enclosing parenthesis around this constraint.
#     @param topconstraint
#         The top node in the constraint tree.
#     @param lefttoken
#         The token on the left side of the comparison operator.
#     @param comparison
#         The comparison operator (==, !=, etc.).
#     @param righttoken
#         The token on the right side of the comparison operator.
#  */
sub adjconstraint($$$$$$)
{
	my $constraint = shift;
	my $parenconstraint = shift;
	my $topconstraint = shift;
	my $lefttoken = shift;
	my $comparison = shift;
	my $righttoken = shift;

	print STDERR "in adjconstraint\n" if ($debug);
	print STDERR "CONSTRAINT: $constraint LJ: $constraint->{LASTJOIN}\n" if ($debug);

	# Create new top level constraint if we're in a different
	# comparison statement.
	if (!defined($constraint->{LASTJOIN})) {
		print STDERR "Constraint changed from $constraint to " if ($debug);
		$constraint = newsibling($topconstraint, $parenconstraint);
		print STDERR "$constraint\n" if ($debug);
	}

	my $leftmds = 1;
	my $leftvalue = 0;
	if ($lefttoken =~ /^0x[0-9a-fA-F]+$/ || $lefttoken =~ /^0b[01]+$/ ||
	    $lefttoken =~ /^0[0-9]+$/) {
		$leftvalue = oct($lefttoken);
	} elsif ($lefttoken =~ /^\d+$/) {
		$leftvalue = $lefttoken;
	} else {
		$leftmds = $HeaderDoc::filter_macro_definition_state{$lefttoken};
		if ($leftmds == 1) {
			$leftvalue = $HeaderDoc::filter_macro_definition_value{$lefttoken};
		}
		if ($leftmds && length($lefttoken)) {$constraint->{LEFTISSYMBOL} = 1; }
	}

	my $rightmds = 1;
	my $rightvalue = 0;
	if ($righttoken =~ /^0x[0-9a-fA-F]+$/ || $righttoken =~ /^0b[01]+$/ ||
	    $righttoken =~ /^0[0-9]+$/) {
		$rightvalue = oct($righttoken);
	} elsif ($righttoken =~ /^\d+$/) {
		$rightvalue = $righttoken;
	} else {
		$rightmds = $HeaderDoc::filter_macro_definition_state{$righttoken};
		if ($rightmds == 1) {
			$rightvalue = $HeaderDoc::filter_macro_definition_value{$righttoken};
		}
		if ($rightmds && length($righttoken)) {$constraint->{RIGHTISSYMBOL} = 1; }
	}

	$constraint->{LEFTVALUE} = $leftvalue;
	$constraint->{LEFTTOKEN} = $lefttoken;
	$constraint->{RIGHTVALUE} = $rightvalue;
	$constraint->{RIGHTTOKEN} = $righttoken;
	$constraint->{COMPARISON} = $comparison;

	if (!$leftmds) { $constraint->{LEFTDONTCARE} = 1; }
	if (!$rightmds) { $constraint->{RIGHTDONTCARE} = 1; }

	print STDERR "IN ADJCONSTRAINT: LEFTVALUE IS $leftvalue LEFTMDS IS $leftmds\n" if ($debug);
	print STDERR "RIGHTVALUE IS $rightvalue RIGHTMDS IS $rightmds\n" if ($debug);

	# canonicalize "lefttoken < foo" to be "foo > lefttoken".

	print STDERR "CONSTRAINT $constraint:\nLEFT TOKEN: $lefttoken\nLEFT VALUE: ".$constraint->{LEFTVALUE}."\nLEFTDONTCARE: ".$constraint->{LEFTDONTCARE}."\nCOMPARISON: $comparison\nRIGHT TOKEN: $righttoken\nRIGHT VALUE: ".$constraint->{RIGHTVALUE}."\nRIGHTDONTCARE: ".$constraint->{RIGHTDONTCARE}."\n" if ($debug);
	return $constraint;
}

# /*!
#     @abstract
#         Unrolls from current constraint to the nearest enclosing
#         parenthesis constraint.
#     @param constraint
#         The constraint to alter.
#     @param parenconstraint
#         An enclosing parenthesis around this constraint.
#
#         Depending on the value of <code>including</code>, this is either
#         an absolute upper bound parenthesis that should never be reached
#         or this is a parenthesis constraint whose enclosing parenthesis
#         constraint you want to obtain.
#     @param including
#         If this is 1, the functino unrolls to the parenthesis constraint
#         that encloses <code>parencontraint</code>.
#
#         If this is 0, unroll to the parenthesis constraint that encloses
#         <code>constraint</code>.
#  */
sub unrolltoparen
{
	my $constraint = shift;
	my $parenconstraint = shift;
	my $including = shift;

	if ($including) {
		if ($debug) {
			print STDERR "QUICK UNROLLED TO $parenconstraint\n";
			if (!$parenconstraint->{ISPAREN}) {
				warn "NOT A PARENTHESIS!\n";
			}
		}
		return ($parenconstraint, $parenconstraint->{PREVPAREN});
	}
	if ($constraint->{PARENWRAPPER}) {
		print STDERR "PRETTY QUICK UNROLL: $constraint (parenconstraint is $parenconstraint)\n" if ($debug);
		return $constraint->{PARENWRAPPER}->{PARENTREE};
	}
	print STDERR "SLOW UNROLL: $constraint (parenconstraint is $parenconstraint)\n" if ($debug);
	my $lastconstraint = $constraint;
	while ($constraint && $constraint != $parenconstraint) {
		$lastconstraint = $constraint;
		if ($constraint->{PREVIOUS}) { $constraint = $constraint->{PREVIOUS}; }
		elsif ($constraint->{PARENT}) { $constraint = $constraint->{PARENT}; }
		else { last; }
		if ($debug) {
			print STDERR "UNROLL: $constraint\n";
		}
		if ($constraint->{ISPAREN} && ($constraint != $parenconstraint) && !$HeaderDoc::interpret_case) {
			warn "Oops.  We hit a parenthesis.  This should not happen.\n";
		}
	}
	print STDERR "POSTUNROLL: $lastconstraint (compare to $parenconstraint)\n" if ($debug);
	return ($lastconstraint, $parenconstraint);
}

# /*!
#     @abstract
#         Creates a new parenthesis guts sibling node for a parenthesis
#         constraint.
#     @discussion
#         The constraints representing what comes between this parenthesis
#         and the matching parenthesis hang off the PARENTREE chain.
#         This function creates an initial null constraint for those
#         additional constraints to hang off of.
#  */
sub newparenguts
{
	my $constraint = shift;
	my $parenconstraint = undef;
	if (@_) {
		$parenconstraint = shift;
	}

	my $nextconstraint = newconstraint();

	print STDERR "Adding new sibling $nextconstraint to $constraint\n" if ($debug);

	$nextconstraint->{PARENT} = $constraint->{PARENT};
	$nextconstraint->{PARENWRAPPER} = $constraint;
	$constraint->{PARENTREE} = $nextconstraint;
	$constraint->{WAITINGCOMPARISON} = undef;
	$constraint->{WAITINGTOKEN} = undef;
	$nextconstraint->{LASTJOIN} = "||";
	$nextconstraint->{PREVIOUS}=$constraint;
	return $nextconstraint;
}


# /*!
#     @abstract
#         Creates a new constraint as a sibling of the current
#         constraint.
#     @param constraint
#         The current constraint.
#     @param parenconstraint
#         If specified (see {@link unrolltoparen} for details;
#         call sets <code>including=0</code>), this represents
#         an outer bound for unrolling to the nearest enclosing
#         parenthesis.
#
#         If unspecified, the function does not unroll to the
#         nearest parenthesis constraint.
#  */
sub newsibling
{
	my $constraint = shift;
	my $parenconstraint = undef;
	if (@_) {
		$parenconstraint = shift;
	}

	# Unroll to the last close parenthesis because of precedence
	# interaction between the && and || operators.
	# Don't worry about returning parenconstraint, as it won't ever change
	# with the third parameter set to zero (0).

	if ($parenconstraint) {
		# print STDERR "UNROLLING FROM $constraint." if ($debug);
		($constraint, $parenconstraint) = unrolltoparen($constraint, $parenconstraint, 0);
		# print STDERR "$constraint\n" if ($debug);
	}

	# Roll down to the end of the "or" chain.
	while ($constraint->{NEXT}) {
		$constraint = $constraint->{NEXT};
	}

	my $nextconstraint = newconstraint();

	print STDERR "Adding new sibling $nextconstraint to $constraint\n" if ($debug);

	$nextconstraint->{PARENT} = $constraint->{PARENT};
	$constraint->{NEXT} = $nextconstraint;
	$constraint->{WAITINGCOMPARISON} = undef;
	$constraint->{WAITINGTOKEN} = undef;
	$nextconstraint->{LASTJOIN} = "||";
	$nextconstraint->{PREVIOUS} = $constraint;
	$nextconstraint->{PARENWRAPPER} = $constraint->{PARENWRAPPER};
	return $nextconstraint;
}

# /*!
#     @abstract
#         Creates a new constraint as a cild of the
#         current constraint.
#  */
sub newchild 
{
	my $constraint = shift;
	my $childconstraint = newconstraint();

	my $localDebug = 0;

	print STDERR "Adding new child $childconstraint to $constraint\n" if ($localDebug);

	# Roll down into "&&" chain to add a new required constraint.
	while ($constraint->{FIRSTCHILD}) {
		$constraint = $constraint->{FIRSTCHILD};
		# print STDERR "Pushing new constraint down to $constraint\n";
	}

	print STDERR "Really adding new child $childconstraint to $constraint\n" if ($localDebug || $debug);

	if ($constraint->{DEFINED}) { $childconstraint->{DEFINED} = $constraint->{DEFINED} + 1; }
	$constraint->{FIRSTCHILD} = $childconstraint;
	$childconstraint->{PARENT} = $constraint;
	$constraint->{WAITINGCOMPARISON} = undef;
	$constraint->{WAITINGTOKEN} = undef;
	$childconstraint->{LASTJOIN} = "&&";
	$childconstraint->{PARENWRAPPER} = $constraint->{PARENWRAPPER};
	return $childconstraint;
}

# /*!
#     @abstract
#         Checks the value for a given node without recursion.
#     @result
#         Returns 0 if the constraint fails explicitly
#         with either an "<code>if (!defined(X))</code>"
#         where "<code>X</code>" is defined or with a
#         comparison failure where both values are defined.
#
#         Returns 1 if the constraint succeeds explicitly
#         with either an "<code>if (defined(X))</code>" 
#         where "<code>X</code>" is defined or with a
#         comparison success where both values are defined.
#
#         Returns -1 for a null comparison.  Also
#         returns -1 if the result cannot be determined
#         because of a constant token without a specified
#         value and <code>use_default_value<code> is 1.
#
#         Returns -3 if the result cannot be determined
#         because of a constant token without a specified
#         value and <code>use_default_value<code> is 0.
#     @param constraint
#         The constraint to check.
#     @param use_default_value
#         Indicates that the macro filter engine should use
#         a specific default value to use for undefined
#         parameters.
#     @param default_value
#         The default value to use for undefined parameters.
#     @param printing
#         Set to disable debug output if you are in the middle
#         of printing a constraint. (Optional.  Default is 0.)
#  */
sub localmatch
{
	my $constraint = shift;
	my $use_default_value = shift;
	my $default_value = shift;
	my $printing = 0;
	if (@_) {
		$printing = shift;
	}

	my $leftvalue = $constraint->{LEFTVALUE};
	my $rightvalue = $constraint->{RIGHTVALUE};

	print STDERR "Checking constraint $constraint\n" if ($debug);
	printconstraint($constraint, 1) if ($debug && !$printing);

	if ($constraint->{DEFINED}) {
		# print STDERR "DEFINED TEST:\n";
		my $def = $HeaderDoc::filter_macro_definition_state{$constraint->{LEFTTOKEN}};
		# print STDERR "    LEFT TOKEN: ".$constraint->{LEFTTOKEN}."\n";

		if ($constraint->{NOT}) {
			# print STDERR "INVERTED.\n";
			if ($def == 1) { return 0; } # explicitly defined w/ !defined
			if ($def == -1) { return 1; } # explicitly not defined w/ !defined
			return -3; # don't know.
		} else {
			# print STDERR "NORMAL.\n";
			if ($def == -1) { return 0; } # explicitly not defined
			if ($def == 1) { return 1; } # explicitly defined (maybe w/ value)
			return -3; # don't know.
		}
	}
	if ($constraint->{LEFTDONTCARE}) {
		print STERR "LEFTDONTCARE\n" if ($debug);
		if ($use_default_value && $constraint->{RIGHTISSYMBOL}) {
			print STDERR "USING DEFAULT VALUE ($default_value) FOR LEFT (".$constraint->{LEFTTOKEN}." ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}.")\n" if ($debug);
			$leftvalue = $default_value;
		} elsif ($use_default_value) {
			return -1;
		} else {
			return -3;
		}
	}
	if ($constraint->{RIGHTDONTCARE}) {
		print STERR "RIGHTDONTCARE\n" if ($debug);
		if ($use_default_value && $constraint->{LEFTISSYMBOL}) {
			print STDERR "USING DEFAULT VALUE ($default_value) FOR RIGHT (".$constraint->{LEFTTOKEN}." ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}.")\n" if ($debug);
			$rightvalue = $default_value;
		} elsif ($use_default_value) {
			return -1;
		} else {
			return -3;
		}
	}
	if ($constraint->{ALWAYSFALSE}) {
		return 0;
	}
	if (!$constraint->{COMPARISON}) {
		# NULL comparison.
		return -1;
	}
	if ($constraint->{COMPARISON} eq "==") {
		if ($leftvalue == $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	}
	# Micro-feature for an internal tool.
	if ($HeaderDoc::enable_reverse_match && ($constraint->{COMPARISON} eq "!=") &&
	    (($HeaderDoc::reverse_match eq $constraint->{LEFTTOKEN} && !$constraint->{RIGHTISSYMBOL}) ||
	     ($HeaderDoc::reverse_match eq $constraint->{RIGHTTOKEN} && !$constraint->{LEFTISSYMBOL})
	    )) {
		if ($leftvalue == $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	} elsif ($constraint->{COMPARISON} eq "!=") {
		if ($leftvalue != $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	}
	if ($constraint->{COMPARISON} eq "<") {
		if ($leftvalue < $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	}
	if ($constraint->{COMPARISON} eq "<=") {
		if ($leftvalue <= $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	}
	if ($constraint->{COMPARISON} eq ">") {
		if ($leftvalue > $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	}
	if ($constraint->{COMPARISON} eq ">=") {
		if ($leftvalue >= $rightvalue) {
			return 1;
		} else {
			return 0;
		}
	}
	if ($HeaderDoc::interpret_case && ($constraint->{COMPARISON} eq ":")) {
		if ($constraint->{LEFTISSYMBOL} && $use_default_value &&
		    ($leftvalue == $default_value)) {
			return 1;
		}
		return 0;
	}

	die("Unknown comparison operator ".$constraint->{COMPARISON}."\n");
}

# /*!
#     @abstract
#         Returns whether the constraints match the
#         current set of macro definitions.
#
#     @param constraint
#         The constraint to check.
#     @param default_value
#         The default value to use for undefined variables.
#  */
sub matchesconstraints
{
	my $constraint = shift;

	my $use_default_value = 0;
	my $default_value = undef;
	if (@_) {
		$use_default_value = 1;
		$default_value = shift;
	}

	my ($result, $poss) = matchesconstraints_sub($constraint, $use_default_value, $default_value);
	print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug);
	print STDERR "TOP: RETURN($result, $poss): $constraint\n" if ($debug);

	if ($poss == -3) { return -3; }
	return $result;
}

# /*!
#     @abstract
#         The recursive portion of {@link matchesconstraints}.
#     @param constraint
#         The constraint to check.
#     @param use_default_value
#         Indicates that the macro filter engine should use
#         a specific default value to use for undefined
#         parameters.
#     @param default_value
#         The default value to use for undefined parameters.
#  */
sub matchesconstraints_sub
{
	my $constraint = shift;
	my $use_default_value = shift;
	my $default_value = shift;

	my $possmatch = 0;

	my $localDebug = 0;

	my $local = localmatch($constraint, $use_default_value, $default_value);
	print STDERR "INMATCH: $constraint\n" if ($debug || $localDebug);
	print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}."/".$constraint->{LEFTDONTCARE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}."/".$constraint->{RIGHTDONTCARE}.")\n" if ($debug || $localDebug);

	if ($constraint->{ISPAREN} && $constraint->{PARENTREE}) {
		($local, $possmatch) = matchesconstraints_sub($constraint->{PARENTREE}, $use_default_value, $default_value);
		print STDERR "PARENTHESIS: CHECKING NEXT" if ($debug || $localDebug);

		if ($constraint->{NOT}) {
			if ($local) {
				$local = 0;
			} elsif ($possmatch == -3) {
				$local = -3;
			} else {
				$local = 1;
			}
		} else {
			if ((!$local) && ($possmatch == -3)) {
				$local = -3;
			}
		}
	}

	print STDERR "LOCAL STARTING AT $local\n" if ($debug || $localDebug);
	if (($local == -3 || $local == -1) && $constraint->{SWITCHGUTS}) {
		print STDERR "SWITCHGUTS FOUND\n" if ($debug || $localDebug);
		print STDERR $constraint->{SWITCHGUTS}."\n" if ($debug || $localDebug);
		print STDERR "SWITCHGUTS END\n" if ($debug || $localDebug);

		my ($newlocal, $newpossmatch) = matchesconstraints_sub($constraint->{SWITCHTREE}, $use_default_value, $default_value);

		print STDERR "SWITCHGUTS RETURNED $newlocal\n" if ($debug || $localDebug);
		if ($newlocal == 1) {
			$local = 1;
		}
	}
	if (($local == -3 || $local == -1) && $constraint->{IFGUTS}) {
		print STDERR "IFGUTS FOUND\n" if ($debug || $localDebug);

		my ($newlocal, $newpossmatch) = matchesconstraints_sub($constraint->{IFTREE}, $use_default_value, $default_value);

		print STDERR "IFGUTS RETURNED $newlocal\n" if ($debug || $localDebug);
		if ($newlocal == 1) {
			$local = 1;
		} else {
			my $elseguts = undef;
			my $elsetree = undef;
			if ($constraint->{ELSEGUTS}) {
				$elseguts = $constraint->{ELSEGUTS};
				$elsetree = $constraint->{ELSETREE};
			} else {
				my $next = $constraint->{NEXT};
				while ($next) {
					if ($next->{ELSEGUTS}) {
						$elseguts = $next->{ELSEGUTS};
						$elsetree = $next->{ELSETREE};
					}
					$next = $next->{NEXT};
				}
			}
			if ($elseguts) {
				print STDERR "ELSEGUTS FOUND\n" if ($debug || $localDebug);
				my ($newlocal, $newpossmatch) = matchesconstraints_sub($elsetree, $use_default_value, $default_value);

				print STDERR "IFGUTS RETURNED $newlocal\n" if ($debug || $localDebug);
				if ($newlocal == 1) {
					$local = 1;
				}
			}
		}
	}

	# If we are either null or matching, check the AND chain.
	if ($local) {
		# See if we have an AND chain
		if ($constraint->{FIRSTCHILD}) {
			print STDERR "Calling on FIRSTCHILD $constraint->{FIRSTCHILD}\n" if ($debug || $localDebug);
			my ($childres, $childpos) = matchesconstraints_sub($constraint->{FIRSTCHILD}, $use_default_value, $default_value);

			# See if our AND clauses passed.  If so, return 1.
			if ($childres) {
				print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
				print STDERR "[0]RETURN(1, 0): $constraint\n" if ($debug || $localDebug);
				return ($local, 0);
			}

			# If our AND clauses returned a "maybe" and local is true
			# or if local is "maybe" and the AND clauses are true,
			# set our "MAYBE" state for possible return
			# if none of our OR clauses pass.
			if ($childpos == -3 && $local) {
				print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);

				print STDERR "SETTING POSSMATCH -> -3\n" if ($debug || $localDebug);
				$possmatch = -3;
			} elsif ($childpos) {
				print STDERR "CHILDPOS IS $childpos\n" if ($debug || $localDebug);
				if ($local == 1) {
					print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
					print STDERR "[3]RETURN(1, 0): $constraint\n" if ($debug || $localDebug);
					return (1, 0);
				} elsif ($local == -3) {
					print STDERR "SETTING POSSMATCH -> -3\n" if ($debug || $localDebug);
					$possmatch = -3;
				} else {
					# print STDERR "LOCAL IS $local\n";
					if (!$HeaderDoc::interpret_case) { die "SETTING POSSMATCH -> 1\n"; }
					$possmatch = 1;
				}
			}
			# else we did not match one of our "and" clauses, so this constraint fails,
			# but one of its "or" clauses may still pass, so don't return 0 yet.
		} else {
			# No "and" clauses left, so we return the local value on success
			# or set possmatch on failure for possible return by "or" clauses.
			if ($local == 1) {
				print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
				print STDERR "[4]RETURN(1, 0): $constraint\n" if ($debug || $localDebug);
				return (1, 0);
			} elsif ($local == -3) {
				$possmatch = $local;
			} else {
				$possmatch = $local;
			}
		}
	}
	# If we get here, this constraint failed.  Try the next option if
	# one exists.

	if ($constraint->{NEXT}) {
		# print STDERR "NEXT: $constraint\n" if ($debug || $localDebug);
		print STDERR "Calling on NEXT $constraint->{FIRSTCHILD}\n" if ($debug || $localDebug);
		my ($nextres, $nextposs) = matchesconstraints_sub($constraint->{NEXT}, $use_default_value, $default_value);
		if ($nextres) {
			print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
			print STDERR "[5]RETURN(1, 0): $constraint\n" if ($debug || $localDebug);
			return (1, 0);
		}
		if ($nextposs == -3) {
			print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
			print STDERR "[5A]RETURN(0, -3): $constraint\n" if ($debug || $localDebug);
			return (0, -3);
		} else {
			print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
			print STDERR "[6]RETURN(0, 0): $constraint\n" if ($debug || $localDebug);
			return (0, $possmatch);
		}
	}
	# Nope.  We only get here if this node either fails to pass an "and" clause
	# or has no "and" clauses and is a null constraint or parenthesis.
	print STDERR "TEST: ".$constraint->{LEFTTOKEN}." (".$constraint->{LEFTVALUE}.") ".$constraint->{COMPARISON}." ".$constraint->{RIGHTTOKEN}." (".$constraint->{RIGHTVALUE}.")\n" if ($debug || $localDebug);
	print STDERR "AT END: RETURN(0, $possmatch): $constraint\n" if ($debug || $localDebug);
	return (0, $possmatch);
}

# /*!
#     @abstract
#         Returns whether this is a null constraint.
#     @discussion
#         In the process of building up the tree, it is sometimes necessary
#         to insert null constraints as placeholders.  (For example, the
#         first node in any chain is a NULL constraint.)  These constraints
#         merely propagate the values below/beside them.
#     @param constraint
#         The constraint to check.
#     @param printing
#         Set to disable debug output if you are in the middle
#         of printing a constraint. (Optional.  Default is 0.)
#  */
sub isnullconstraint
{
	my $constraint = shift;
	my $olddebug = $debug;
	my $printing = 0;
	if (@_) {
		$printing = shift;
	}

	if ($constraint->{IFGUTS}) { return 0; }
	if ($constraint->{ELSEGUTS}) { return 0; }
	if ($constraint->{ISPAREN}) { return 0; }

	$debug = 0;
	if (localmatch($constraint, 0, 0, $printing) == -1) {
		$debug = $olddebug;
		return 1;
	}
	$debug = $olddebug;
	return 0;
}

# /*!
#     @abstract
#         Returns whether there are any non-null constraints
#         between the current constraint and the top of the
#         constraint tree.
#     @param topconstraint
#         The top node in the constraint tree.
#     @param constraint
#         The constraint node to check.
#  */
sub attop
{
	my $topconstraint = shift;
	my $constraint = shift;

	my $attopdebug = 1;

	print STDERR "attop: $constraint\n" if ($debug && $attopdebug);

	$constraint= $constraint->{PARENT};
	while ($constraint && isnullconstraint($constraint)) {
		print STDERR "attop_loop: $constraint\n" if ($debug && $attopdebug);
		$constraint = $constraint->{PARENT};
	}
	print STDERR "attop_end: $constraint\n" if ($debug && $attopdebug);
	if ($constraint) {
		print STDERR "NOT NULL CONSTRAINT IN PATH:\n" if ($debug);
		printconstraint($constraint) if ($debug);
		return 0;
	}
	return 1;
}

# /*!
#     @abstract
#         Runs a single test of the macro filter engine.
#     @param string
#         The initial #if or whatever.
#     @param expected_value
#         The expected return value from the engine.
#  */
sub dotest($$)
{
	my $string = shift;
	my $expected_value = shift;
	my $lang = shift;
	my $sublang = shift;

	my $retval = 1;

	$HeaderDoc::lang = $lang;
	$HeaderDoc::sublang = $sublang;

	my $temp = $HeaderDoc::parseIfElse;
	$HeaderDoc::parseIfElse = 1;

	my ($tree, @junk) = doit($string, $lang, $sublang);
	# printconstraint($tree);

	my $mc = matchesconstraints($tree);
	# print "MC: $mc\n";
	if ($mc != $expected_value) {
		warn("$string: \e[31mFAILED\e[39m\nEXPECTED: $expected_value GOT: $mc\n");
		printconstraint($tree);
		$retval = 0;
	} else {
		warn("$string: \e[32mOK\e[39m\n");
	}
	$HeaderDoc::parseIfElse = $temp;
	return $retval;
}

# /*!
#     @abstract
#         Filters an entire file string based on
#         the specified macros.
#     @param data
#         The entire contents of a file as a string.
#  */
sub filterFileString($)
{
	my $data = shift;
	my $output = "";
	my $localDebug = 0;

	my @parts = split(/(\n\s*)(#ifdef|#if|#else|#elif|#endif)/, $data);

	my @curshow_stack = ();
	my $curshow = 1;
	my $handlenext = undef;
	foreach my $part (@parts) {
		print STDERR "PART: $part\n" if ($localDebug);
		if ($part =~ /#endif/) {
			$curshow = pop(@curshow_stack);
			print STDERR "POPPED $curshow\n" if ($localDebug);
			if ($curshow) { $output .= $part; };
		} elsif ($handlenext) {
			my $rest = "";

			if ($handlenext =~ /(#ifdef|#if)/) {
				print STDERR "PUSHING $curshow\n" if ($localDebug);
				push(@curshow_stack, $curshow);
			}
			my $prevcurshow = $curshow;
			my $ifDeclaration = "";
			($curshow, $rest, $ifDeclaration) = ignoreWithinCPPDirective($handlenext, $part, $curshow);
			if ($prevcurshow) { $output .= "#".$ifDeclaration."\n"; };
			# print STDERR "IGNOREWITHIN RETURNED $curshow.\n" if ($localDebug);
			# print STDERR "HANDLENEXT IS $handlenext\n" if ($localDebug);
			# print STDERR "PART IS $part\n" if ($localDebug);
			# print STDERR "REST IS $rest\n" if ($localDebug);
			$handlenext = undef;

			if ($curshow) { $output .= $rest; }
		} elsif ($part =~ /#else/) {
			my $tempcurshow = $curshow;
			$curshow = pop(@curshow_stack);
			if ($curshow) { $output .= $part."\n"; };
			push(@curshow_stack, $curshow);
			$curshow = $tempcurshow;

			print STDERR "PREVIOUS SHOW WAS $curshow\n" if ($localDebug);
			if ($curshow == 1) {
				$curshow = 0;
			} else {
				# if it was 0 or negative (unknown), show else clause.
				print STDERR "curshow -> 1\n" if ($localDebug);
				$curshow = 1;
			}
		} elsif ($part =~ /(#ifdef|#if|#elif)/) {
			# if ($curshow) { $output .= $part; };
			$handlenext = $part;
		} else {
			if ($curshow) { $output .= $part; }
		}
	}
	return $output;
}

# /*!
#     @abstract
#         Checks for return/break statements in a code tree.
#     @discussion
#         This function determines whether a parse tree fragment
#         contains a return or break statement in every possible
#         path through a tree of <code>if() {...} else {...}</code>
#         statements.
#
#         This function is not used by HeaderDoc.  It is provided
#         for use by other tools that take advantage of the
#         HeaderDoc parser and related modules.
#   */
sub hasReturnOrBreak($)
{
	my $tree = shift;

	my $localDebug = 0;

	if (!$tree) { return 0; }

	print STDERR "HRB CHECK $tree\n" if ($localDebug);

	if ($tree->{HASRETURNORBREAK}) {
		print STDERR "HRB LOCAL YES\n" if ($localDebug);
		return 1;
	}

	my $ifHRB = 0;
	my $elseHRB = 0;

	if ($tree->{IFTREE} && $localDebug) {
		print STDERR "HRB CHECKING IF\n";
		print STDERR "BEGIN IF GUTS\n";
		print STDERR $tree->{IFGUTS}."\n";
		print STDERR "END IF GUTS\n";
	}
	if (hasReturnOrBreak($tree->{IFTREE})) {
		print STDERR "HRB IF YES\n" if ($localDebug);
		$ifHRB = 1;
	}
	my $elsetree = undef;
	my $elseguts = undef;
	if ($tree->{IFTREE}) {
		print STDERR "HRB DONE CHECKING IF\n" if ($localDebug);

		# Depending on whether the "else" clause comes on the
		# same line as the closing brace of the "if" statement
		# or on a separate line (or after an unbraced "if" clause),
		# the "else" clause may or may not be parsed at the same
		# time as the "if" clause.  If it is, it will be part of
		# the same node.  Otherwise, it will hang off of the
		# current node's NEXT chain.
		if ($tree->{ELSETREE}) {
			# The "else" was on the same line as the closing brace
			$elsetree = $tree->{ELSETREE}
		} else {
			# Nope.  We have to hunt for it.
			my $next = $tree->{NEXT};
			while ($next) {
				if ($next->{ELSETREE}) {
					$elsetree = $next->{ELSETREE};
					$elseguts = $next->{ELSEGUTS};
					print STDERR "HRB CHAIN ($next) HAS ELSE\n" if ($localDebug);
					last;
				}
				$next = $next->{NEXT};
			}
		}
	}
	if ($elsetree && $localDebug) {
		print STDERR "HRB CHECKING ELSE\n";
		print STDERR "BEGIN ELSE GUTS\n";
		print STDERR $elseguts."\n";
		print STDERR "END ELSE GUTS\n";
	}
	if (hasReturnOrBreak($elsetree)) {
		print STDERR "HRB ELSE YES\n" if ($localDebug);
		$elseHRB = 1;
	}
	if ($elsetree && $localDebug) {
		print STDERR "HRB DONE CHECKING ELSE\n";
	}
	if ($ifHRB && $elseHRB && $localDebug) {
		print STDERR "HRB IF AND ELSE YES\n";
	}

	return ($ifHRB && $elseHRB);
}

1;

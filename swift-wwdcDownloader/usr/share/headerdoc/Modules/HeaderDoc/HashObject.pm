#! /usr/bin/perl -w
#
# Class name: HashObject
# Synopsis: Class for a tree of CPP hashes
#
# Last Updated: $Date: 2011/02/18 19:02:58 $
#
# Copyright (c) 1999-2008 Apple Computer, Inc.  All rights reserved.
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
#         <code>HashObject</code> class package file.
#     @discussion
#         This file contains the <code>HashObject</code> class, a class
#         for nodes in a tree of CPP hashes.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Stores C preprocessor hashes.
#     @discussion
#         Each instance of the <code>HashObject</code> class stores a
#         CPP hash pair for use in handling trees of
#         <code>#if/#else/#elif/#endif</code> statements.
#
#         The purpose of this module is not entirely obvious until
#         you see an example.  Consider the following code:
#
#         <pre>
#         #if BLAH
#             #define function_1 function_2
#         #else
#             void function_1(int arg);
#         #endif
#         </pre>
#
#         Normally, with a C preprocessor, either the <code>#if</code>
#         or <code>#else</code> side of this CPP directive is parsed,
#         but not both.
#
#         With HeaderDoc's C preprocessor, most of the time, HeaderDoc
#         cannot know which version to include.  Thus, it errs on the
#         side of completeness and includes both.  (HeaderDoc does,
#         however, include only one side if you pass a <code>-D</code>
#         or <code>-U</code> flag on the command line or if you provide a
#         HeaderDoc comment for a definition of <code>BLAH</code>
#         earlier in the header or in any header that it includes.)
#
#         Thus, without this module, the macro definition inside the
#         <code>#if</code> side would rewrite the code inside the
#         <code>#else</code> side, causing it to be parsed as:
#
#         <pre>
#             void function_2(int arg);
#         </pre>
#
#         This is clearly not correct.  This module fixes that problem
#         by allowing the entire set of currently known C preprocessor macros
#         to be stored in a tree structure and later restored while parsing
#         these <code>#if/#else/#elif/#endif</code> directives.
#
#         Whenever the parser encounters any C preprocessor directive that this
#         code cares about, the parser calls its helper function
#         {@link //apple_ref/perl/instm/HeaderDoc::BlockParse/cppHashMerge//() cppHashMerge},
#         where the control logic for this module actually appears.
#
#         If the parser encounters a <code>#if</code> directive, that function
#         stores the current C preprocessor macro set in the current tree node,
#         then calls {@link cppHashNodeNewChild}.  This function creates
#         a new, nested chain containing a single entry (the <code>#if</code>
#         node).
#
#         If the parser encounters a <code>#else</code>, <code>#elif</code>, or
#         <code>#endif</code> directive, that function similarly stores the
#         C preprocessor macro set in the current node (in this case, the
#         <code>#if</code> node).
#
#         Next, if the directive was a <code>#else</code> or <code>#elif</code>
#         directive, it also calls {@link cppHashNodeNewSibling} to create a new sibling
#         and {@link cppHashNodeResetToParent} to obtain the parent's C preprocessor
#         macro set for restoration by the parser (effectively undoing the result
#         of the <code>#if</code> clause).
#
#         If the directive was the closing <code>#endif</code> directive, after
#         storing the macro set, the parser calls {@link cppHashNodePop}.  This
#         function pops the entire <code>#if</code> chain off the tree, then merges
#         the macro sets from all of the chains together.  The result is that the
#         contents of the <code>#if</code> clause do not alter the contents of
#         the <code>#else</code> clause, but become active upon reaching the
#         terminating <code>#endif</code> clause.  In cases of conflicting
#         definitions of symbols, the first definition wins.
#
#     @var DEBUGNAME
#         A name for the hash object used for debugging purposes.
#         This is set to the contents of the second parameter to
#         {@link cppHashNodeNewChild}.
#
#     @var CPPHASH
#         The CPP name hash associated with this hash object.
#
#     @var CPPARGHASH
#         The CPP argument hash associated with this hash object.
#
#  */

package HeaderDoc::HashObject;

# use HeaderDoc::Utilities qw();
# use HeaderDoc::HeaderElement;

use Carp qw(cluck);
# @ISA = qw( HeaderDoc::HeaderElement );

use strict;
use vars qw($VERSION @ISA);

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::HashObject::VERSION = '$Revision: 1298084578 $';

my $hashNodeDebug = 0;

# /*!
#     @abstract
#         Creates a new <code>HashObject</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::MinorAPIElement->new()</code> to allocate
#         a new instance of this class).
#  */
sub new {
    my($param) = shift;
    my($class) = ref($param) || $param;
    my $self = {};
    
    print STDERR "new CPP Hash node($param)\n" if ($hashNodeDebug);
    # cluck("Created $self\n");

    bless($self, $class);
    $self->_initialize();
    return ($self);
}

# /*!
#     @abstract
#         Initializes an instance of a MinorAPIElement object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->{DEBUGNAME} = "";
    $self->{PARENT} = undef;
    $self->{FIRSTCHILD} = undef;
    $self->{NEXT} = undef;
    $self->{CPPHASH} = undef;
    $self->{CPPARGHASH} = undef;
}

# /*!
#     @abstract
#         Pops a CPP hash node chain off the tree.
#     @param self
#         Any node in the topmost chain on the tree.
#     @discussion
#         This function is called at the end of a
#         <code>#if ... #else ... #elif ... #endif</code>
#         grouping.  It pops the top chain off the tree,
#         then returns the union of the <code>#define</code>
#         declarations from each part of the group.
#
#         For example, if you have a <code>#if</code>, a
#         <code>#define</code>, a <code>#else</code>, a
#         <code>#define</code>, and a <code>#endif</code>,
#         this pops the <code>#if</code> chain off of the
#         tree and returns both of the two <code>#define</code>
#         declarations if they do not conflict.  If they
#         conflict, it returns the first declaration
#         encountered.
#  */
sub cppHashNodePop
{
    my $self = shift;
    my $parent = $self->{PARENT};

    print STDERR "cppHashNodePop($self)\n" if ($hashNodeDebug);

    if (!$parent) {
	cluck("backtrace:\n");
	die("cppHashNodePop called on top of tree!\n");
    }

    my $childnode = $parent->{FIRSTCHILD};
    $parent->{FIRSTCHILD} = undef;

    my %newhash = ();
    my %newarghash = ();

    while ($childnode) {
	# print STDERR "MERGING IN $childnode (".$childnode->{DEBUGNAME}.")\n";

	my $childcpphashref = $childnode->{CPPHASH};
	my $childcpparghashref = $childnode->{CPPARGHASH};

	my ($mergedhashref, $mergedarghashref) = cppHashNodeMergeHashes(
		\%newhash,\%newarghash,
		$childcpphashref, $childcpparghashref);

	%newhash = %{$mergedhashref};
	%newarghash = %{$mergedarghashref};

	$childnode = $childnode->{NEXT};
    }
    $parent->{CPPHASH} = \%newhash;
    $parent->{CPPARGHASH} = \%newarghash;

    # print "CPPHASHREF: $cpphashref\n";

    return ($parent, $parent->{CPPHASH}, $parent->{CPPARGHASH});
}

# /*!
#     @abstract
#         Creates a CPP hash tree node as a sibling of another node
#     @param self
#         The last node in the topmost chain.
#     @param debugname
#         A name used when printing the object for debugging.
#  */
sub cppHashNodeNewSibling
{
    my $self = shift;
    my $debugname = shift;

    my $parent = $self->{PARENT};

    print STDERR "cppHashNodeNewSibling($self, $debugname)\n" if ($hashNodeDebug);

	# cluck("SELF: $self PARENT: $parent\n");

    return $parent->cppHashNodeNewChild($debugname)
}

# /*!
#     @abstract
#         Creates a CPP hash tree node as a child of another node
#     @param self
#         The last node in the topmost chain.
#     @param debugname
#         A name used when printing the object for debugging.
#  */
sub cppHashNodeNewChild
{
    my $self = shift;
    my $debugname = shift;

    print STDERR "cppHashNodeNewChild($self, $debugname)\n" if ($hashNodeDebug);

    my $newchild = HeaderDoc::HashObject->new();

    $newchild->{PARENT} = $self;
    $newchild->{DEBUGNAME} = $debugname;

    my $lastchild = $self->cppHashNodeLastChild();
    if ($lastchild) {
	$lastchild->{NEXT} = $newchild;
    } else {
	$self->{FIRSTCHILD} = $newchild;
    }

    return $newchild;
}

# /*!
#     @abstract
#         Returns the last child of a CPP hash tree node.
#     @param self
#         The node whose child you are requesting.
#  */
sub cppHashNodeLastChild
{
    my $self = shift;

    print STDERR "cppHashNodeLastChild($self)\n" if ($hashNodeDebug);

    my $child = $self->{FIRSTCHILD};
    my $lastchild = $child;

    while ($child) {
	$lastchild = $child;
	$child = $child->{NEXT};
    }

    return $lastchild;
}

# /*!
#     @abstract
#         Stores a copy of C preprocessor macro sets
#         (hash and argument hash) into a <code>HashObject</code>
#         node.
#     @param self
#         The node to modify.
#     @param cpphashref
#         The C preprocessor name hash to store.
#     @param cpparghashref
#         The C preprocessor argument hash to store.
#  */
sub cppHashNodeSetHashes
{
    my $self = shift;

    my $cpphashref = shift;
    my $cpparghashref = shift;

    print STDERR "cppHashNodeSetHashes($self, $cpphashref, $cpparghashref)\n" if ($hashNodeDebug);

    # print STDERR "Setting hashes on node $self to $cpphashref, $cpparghashref\n";

    my %hash = %{$cpphashref};
    my %copyhash = %hash;

    my %arghash = %{$cpparghashref};
    my %copyarghash = %arghash;

    $self->{CPPHASH} = \%copyhash;
    $self->{CPPARGHASH} = \%copyarghash;

    return ($self->{CPPHASH}, $self->{CPPARGHASH});
}

# /*!
#     @abstract
#         Returns the C preprocessor macro set
#         (hash and argument hash) from the parent of
#         the specified node.
#     @param self
#         The child of the node whose macro set
#         you wish to obtain.  This is usually the
#         current node being manipulated.
#  */
sub cppHashNodeResetToParent
{
    my $self = shift;

    print STDERR "cppHashNodeResetToParent($self)\n" if ($hashNodeDebug);

    my $parent = $self->{PARENT};

    # print STDERR "cppHashNodeResetToParent: NODE $self PARENT $parent\n";

    my %hash = %{$parent->{CPPHASH}};
    my %arghash = %{$parent->{CPPARGHASH}};

    return (\%hash, \%arghash);
}


# /*!
#     @abstract
#         Merges two C preprocessor macro sets, with
#         precedence given to the first.
#     @param hashref_1
#         A reference to the first CPP name hash.
#     @param arghashref_1
#         A reference to the first CPP argument hash.
#     @param hashref_2
#         A reference to the second CPP name hash.
#     @param arghashref_2
#         A reference to the second CPP argument hash.
#     @result
#         Returns an array containing a reference to the
#         combined name hash and a reference to the
#         combined argument hash.
#  */
sub cppHashNodeMergeHashes
{
    my $hashref_1 = shift;
    my $arghashref_1 = shift;
    my $hashref_2 = shift;
    my $arghashref_2 = shift;

    print STDERR "cppHashNodeMergeHashes($hashref_1, $arghashref_1, $hashref_2, $arghashref_2)\n" if ($hashNodeDebug);

    my %hash_1 = %{$hashref_1};
    my %arghash_1 = %{$arghashref_1};
    my %hash_2 = %{$hashref_2};
    my %arghash_2 = %{$arghashref_2};

    foreach my $val ( keys %hash_2 ) {
        if (!exists $hash_1{$val}) {
                $hash_1{$val} = $hash_2{$val};
        }
    }
    foreach my $val ( keys %arghash_2 ) {
        if (!exists $arghash_1{$val}) {
                $arghash_1{$val} = $arghash_2{$val};
        }
    }

    return (\%hash_1, \%arghash_1);
}

# /*!
#       @abstract
#           Prints a CPP <code>HashObject</code> tree for debugging.
#       @param self
#           The tree to print.
#  */
sub dbprint
{
    my $self = shift;
    my $indent = "";

    if (@_) {
	$indent = shift;
    } else {
	# cluck("Dumping hash tree.\n");
	print STDERR "Dumping hash tree.\n";
    }

    print $indent."\n";
    print $indent."-- NODE $self\n";
    print $indent."   |\n";
    print $indent."   |   DEBUGNAME:  ".$self->{DEBUGNAME}."\n";
    print $indent."   |   PARENT:     ".$self->{PARENT}."\n";
    print $indent."   |   FIRSTCHILD: ".$self->{FIRSTCHILD}."\n";
    print $indent."   |   NEXT:       ".$self->{NEXT}."\n";
    print $indent."   |   CPPHASH:    ".$self->{CPPHASH}."\n";
    print $indent."   |   CPPARGHASH: ".$self->{CPPARGHASH}."\n";
    print $indent."   |\n";

    my $fc = $self->{FIRSTCHILD};
    if ($fc) {
        my $newindent = $indent."   |";

	$fc->dbprint($newindent);
    }

    my $next = $self->{NEXT};
    if ($next) {
	$next->dbprint($indent);
    }
}


1;

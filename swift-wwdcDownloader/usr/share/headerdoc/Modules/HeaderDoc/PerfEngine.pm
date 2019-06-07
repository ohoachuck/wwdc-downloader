#! /usr/bin/perl -w
#
# Class name: PerfEngine
# Synopsis: Performance Testing Engine
#
# Last Updated: $Date: 2011/07/07 15:15:10 $
#
# Copyright (c) 2005 Apple Computer, Inc.  All rights reserved.
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
#         <code>PerfEngine</code> class package file.
#     @discussion
#         This file contains the <code>PerfEngine</code> class, a class for
#         testing performance.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Performance testing class.
#     @discussion
#         The <code>PerfEngine</code> class contains the bulk of the performance
#         testing code.
#
#         To use the <code>PerfEngine</code> class, you first create a new instance
#         like this:
#
#         <code>my $global_perf = HeaderDoc::PerfEngine->new();</code>
#
#         You then periodically call the {@link checkpoint} method,
#         alternating the argument between 1 (creating a new checkpoint)
#         and 0 (closing the checkpoint).  For example:
#
#         <code>$global_perf->checkpoint(1);</code>
#
#         Each <code>PerfEngine</code> instance can handle nested checkpoints
#         or consecutive checkpoints.  Checkpoints may not, however,
#         overlap (e.g. start #1, start #2, end #1, end #2).
#
#         After you have finished executing the code you want to profile,
#         call {@link printstats} like this:
#
#         <code>$global_perf->printstats();</code>
#
#         It then prints statistics about each of the checkpoint
#         ranges, telling how long it took to execute each one.
#     @var COMPLETE
#         An array of points that have been started and ended.
#     @var PENDING
#         An array of points that have been started but have not been
#         ended.
#  */
package HeaderDoc::PerfEngine;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash unregisterUID registerUID sanitize unregister_force_uid_clear);
use HeaderDoc::PerfPoint;
use File::Basename;
use strict;
use vars qw($VERSION @ISA);

use Carp;

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::PerfEngine::VERSION = '$Revision: 1310076910 $';

my $perfDebug = 0;

# /*!
#     @abstract
#         Creates a new <code>PerfEngine</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::PerfEngine->new()</code> to allocate
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
#         Initializes an instance of a <code>PerfEngine</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    my @temp1 = ();
    my @temp2 = ();
    $self->{COMPLETE} = \@temp1;
    $self->{PENDING} = \@temp2;
}

# /*!
#     @abstract
#         Opens and closes checkpoints.
#     @param self
#         The <code>PerfEngine</code> object.
#     @param entering
#         Pass 1 when you enter a range that you want to time.
#
#         Pass 0 when you reach the end of that range.
#  */
sub checkpoint {
    my $self = shift;
    my $entering = shift;
    # my $bt = Devel::StackTrace->new();
    # my $btstring = $bt->as_string;
    my $bt = Carp::longmess("");
    $bt =~ s/^.*?\n//s;
    $bt =~ s/\n/ /sg;

    if ($perfDebug) { print STDERR "CP: $bt\n"; }

    if ($entering) {
	$self->addCheckpoint($bt);
    } else {
	$self->matchCheckpoint($bt);
    }
}

# /*!
#     @abstract
#         Creates a new checkpoint and adds it to the stack.
#     @param self
#         The <code>PerfEngine</code> object.
#     @param bt
#         A backtrace taken at the start of this checkpoint.
#         Used to distinguish different checkpoints.
#     @discussion
#         This function is called by {@link checkpoint} and
#         should generally not be called directly.
#  */
sub addCheckpoint
{
    my $self = shift;
    my $bt = shift;

    if ($perfDebug) {
	print STDERR "Adding checkpoint.  Backtrace: $bt\n";
    }
    my $checkpoint = HeaderDoc::PerfPoint->new( backtrace => $bt);
    push(@{$self->{PENDING}}, $checkpoint);
}

# /*!
#     @abstract
#         Pops a checkpoint from the stack and computes
#         the elapsed time.
#     @param self
#         The <code>PerfEngine</code> object.
#     @param bt
#         The backtrace taken at the start of this checkpoint.
#         Used to distinguish different checkpoints.
#     @discussion
#         This function is called by {@link checkpoint} and
#         should generally not be called directly.
#  */
sub matchCheckpoint
{
    my $self = shift;
    my $bt = shift;
    my @keep = ();

    my $localDebug = 0;

    if ($perfDebug) {
	print STDERR "Routine returned.  Backtrace: $bt\n";
    }

    foreach my $point (@{$self->{PENDING}}) {
	if ($point->{BACKTRACE} eq $bt) {
		if ($localDebug) {
			print STDERR "MATCHED\n";
		}
		$point->finished();
		push(@{$self->{COMPLETE}}, $point);
	} else {
		push(@keep, $point);
	}
    }
    $self->{PENDING} = \@keep;
}

# /*!
#     @abstract
#         Prints accumulated statistics.
#     @param self
#         The <code>PerfEngine</code> object.
#  */
sub printstats
{
    my $self = shift;

    my %pointsByBacktrace = ();

    foreach my $point (@{$self->{COMPLETE}}) {
	# print STDERR "POINT: ".$point->{BACKTRACE}."\n";
	my $arrayref = $pointsByBacktrace{$point->{BACKTRACE}};
	if (!$arrayref) {
		# print STDERR "NEW\n";
		my @temparray = ();
		$arrayref = \@temparray;
	# } else {
		# print STDERR "OLD\n";
	}
	my @array = @{$arrayref};
	push(@array, $point);
	$pointsByBacktrace{$point->{BACKTRACE}} = \@array;
    }

    print STDERR "Completed routines:\n";
    my $first = 1;
    foreach my $bt (keys %pointsByBacktrace) {
	my $arrayref = $pointsByBacktrace{$bt};
	my @array = @{$arrayref};
	my $maxusec = 0;
	my $ttlsec = 0;
	my $ttlusec = 0;
	my $count = 0;

	if ($first) {
		$first = 0;
	} else { 
		printSeparator();
	}

	print STDERR "$bt\n";
	foreach my $point (@array) {
		my $usec = $point->{SECS} * 1000000;
		$usec += $point->{USECS};
		if ($usec > $maxusec) {
			$maxusec = $usec;
		}
		$ttlsec += $point->{SECS};
		$ttlusec += $point->{USECS};
		if ($ttlusec > 1000000) {
			$ttlusec -= 1000000;
			$ttlsec += 1;
		}
		$count++;
	}
	print STDERR "COUNT: $count\n";
	print STDERR "MAX: $maxusec usec\n";
	print STDERR "TTL: $ttlsec seconds, $ttlusec usec\n";
    }


    print STDERR "\n\nIncomplete routines:\n";

    $first = 1;
    foreach my $point (@{$self->{PENDING}}) {
	if ($first) {
		$first = 0;
	} else { 
		printSeparator();
	}
	print STDERR $point->{BACKTRACE}."\n";
    }

}

# /*!
#     @abstract
#         Prints a separator line.
#  */
sub printSeparator
{
    print STDERR "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n";
}

1;

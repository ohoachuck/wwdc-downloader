#! /usr/bin/perl -w
#
# Class name: PerfPoint
# Synopsis: Test Point Object for Performance Testing Engine
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
#         <code>PerfPoint</code> class package file.
#     @discussion
#         This file contains the <code>PerfPoint</code> class, a class for
#         storing performance data.
#
#         For details, see the class documentation below.
#     @indexgroup HeaderDoc Miscellaneous Helpers
#  */

# /*!
#     @abstract
#         Performance testing data structure.
#     @discussion
#         The <code>PerfPoint</code> class stores performance data for a single
#         checkpoint, for use by the
#         {@link //apple_ref/perl/cl/HeaderDoc::PerfEngine PerfEngine}
#         class.
#     @var BACKTRACE
#         The backtrace for the start of this test point.  Used to match
#         it upon seeing an end call.
#     @var SECS
#         The number of seconds this execution took.
#     @var USECS
#         The number of microseconds this execution took (minus the seconds).
#     @var STARTSEC
#         The time of day (in seconds) when this point was started.
#     @var STARTUSEC
#         The microsecond part of the time of day when this point was started.
#     @var FINISHSEC
#         The time of day (in seconds) when this point ended.
#     @var FINISHUSEC
#         The microsecond part of the time of day when this point ended.
#  */
package HeaderDoc::PerfPoint;

use HeaderDoc::Utilities qw(findRelativePath safeName printArray printHash unregisterUID registerUID sanitize unregister_force_uid_clear);
use File::Basename;
use strict;
use vars qw($VERSION @ISA);
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );

use Carp;

# /*!
#     @abstract
#         The revision control revision number for this module.
#     @discussion
#         In the git repository, contains the number of seconds since
#         January 1, 1970.
#  */
$HeaderDoc::PerfPoint::VERSION = '$Revision: 1310076910 $';

my $perfDebug = 1;

# /*!
#     @abstract
#         Creates a new <code>PerfPoint</code> object.
#     @param param
#         A reference to the relevant package object (e.g.
#         <code>HeaderDoc::PerfPoint->new()</code> to allocate
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
#         Initializes an instance of a <code>PerfPoint</code> object.
#     @param self
#         The object to initialize.
#  */
sub _initialize {
    my($self) = shift;
    $self->{BACKTRACE} = undef;
    ($self->{STARTSEC}, $self->{STARTUSEC}) = gettimeofday();
    $self->{FINISHSEC} = undef;
    $self->{FINISHUSEC} = undef;
    $self->{SECS} = undef;
    $self->{USECS} = undef;
}

# /*!
#     @abstract
#         Marks this checkpoint finished and records the
#         elapsed time.
#     @param self
#         The <code>PerfPoint</code> object.
#  */
sub finished {
    my $self = shift;
    my $localDebug = 0;

    ($self->{FINISHSEC}, $self->{FINISHUSEC}) = gettimeofday();
    $self->{SECS} = $self->{FINISHSEC} - $self->{STARTSEC};
    $self->{USECS} = $self->{FINISHUSEC} - $self->{STARTUSEC};

    if ($self->{USECS} < 0) {
	$self->{USECS} += 1000000;
	$self->{SECS} -= 1;
    }

    if ($localDebug) {
	print STDERR "BT: ".$self->{BACKTRACE}."\n";
	print STDERR "STARTSEC: ".$self->{STARTSEC}."\n";
	print STDERR "STARTUSEC: ".$self->{STARTUSEC}."\n";
	print STDERR "FINISHSEC: ".$self->{FINISHSEC}."\n";
	print STDERR "FINISHUSEC: ".$self->{FINISHUSEC}."\n";
	print STDERR "SECONDS: ".$self->{SECS}."\n";
	print STDERR "USECS: ".$self->{USECS}."\n";
    }

}


1;

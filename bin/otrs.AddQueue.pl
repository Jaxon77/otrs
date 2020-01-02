#!/usr/bin/perl
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Getopt::Std;
use Kernel::System::ObjectManager;

# create object manager
local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'OTRS-otrs.AddQueue.pl',
    },
);

# get options
my %Opts;
getopts( 'hg:n:s:S:c:t:r:u:l:C:', \%Opts );

if ( $Opts{h} ) {
    print STDOUT "otrs.AddQueue.pl - add new queue\n";
    print STDOUT "Copyright (C) 2001-2020 OTRS AG, https://otrs.com/\n";
    print STDOUT "usage: otrs.AddQueue.pl -n <NAME> -g <GROUP> [-s <SYSTEMADDRESSID> -S \n";
    print STDOUT
        "<SYSTEMADDRESS> -c <COMMENT> -t <UnlockTimeout> -r <FirstResponseTime> -u <UpdateTime> \n";
    print STDOUT "-l <SolutionTime> -C <CalendarID>]\n";
    exit 1;
}

if ( !$Opts{n} ) {
    print STDERR "ERROR: Need -n <NAME>\n";
    exit 1;
}
if ( !$Opts{g} ) {
    print STDERR "ERROR: Need -g <GROUP>\n";
    exit 1;
}

# check group
my $GroupID = $Kernel::OM->Get('Kernel::System::Group')->GroupLookup( Group => $Opts{g} );
if ( !$GroupID ) {
    print STDERR "ERROR: Found no GroupID for $Opts{g}\n";
    exit 1;
}

my $SystemAddressID;

# check System Address
if ( $Opts{S} ) {
    my %SystemAddressList = $Kernel::OM->Get('Kernel::System::SystemAddress')->SystemAddressList(
        Valid => 1
    );
    ADDRESS:
    for my $ID ( sort keys %SystemAddressList ) {
        my %SystemAddressInfo = $Kernel::OM->Get('Kernel::System::SystemAddress')->SystemAddressGet(
            ID => $ID
        );
        if ( $SystemAddressInfo{Name} eq $Opts{S} ) {
            $SystemAddressID = $ID;
            last ADDRESS;
        }
    }
    if ( !$SystemAddressID ) {
        print STDERR "ERROR: Address $Opts{S} not found\n";
        exit 1;
    }
}

# add queue
my $Success = $Kernel::OM->Get('Kernel::System::Queue')->QueueAdd(
    Name              => $Opts{n},
    GroupID           => $GroupID,
    SystemAddressID   => $SystemAddressID || $Opts{s} || undef,
    Comment           => $Opts{c} || undef,
    UnlockTimeout     => $Opts{t} || undef,
    FirstResponseTime => $Opts{r} || undef,
    UpdateTime        => $Opts{u} || undef,
    SolutionTime      => $Opts{l} || undef,
    Calendar          => $Opts{C} || undef,
    ValidID           => 1,
    UserID            => 1,
);

# error handling
if ( !$Success ) {
    print STDERR "ERROR: Can't create queue!\n";
    exit 1;
}

print STDOUT "Queue '$Opts{n}' created.\n";
exit 0;

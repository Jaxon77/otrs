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

# get options
my %Opts;
getopt( 'tl', \%Opts );
if ( $Opts{h} || !$Opts{t} ) {
    print "otrs.GetTicketThread.pl - Prints out a ticket with all its articles.\n";
    print "Copyright (C) 2001-2020 OTRS AG, https://otrs.com/\n";
    print "usage: otrs.GetTicketThread.pl -t <TicketID> [-l article limit]\n";
    exit 1;
}

# create object manager
local $Kernel::OM = Kernel::System::ObjectManager->new(
    'Kernel::System::Log' => {
        LogPrefix => 'OTRS-otrs.GetTicketThread.pl',
    },
);

# get ticket data
my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
    TicketID      => $Opts{t},
    DynamicFields => 0,
);

exit 1 if !%Ticket;

print STDOUT "=====================================================================\n";

KEY:
for my $Key (qw(TicketNumber TicketID Created Queue State Priority Lock CustomerID CustomerUserID))
{

    next KEY if !$Key;
    next KEY if !$Ticket{$Key};

    print STDOUT "$Key: $Ticket{$Key}\n";
}

print STDOUT "---------------------------------------------------------------------\n";

# get article index
my @Index = $Kernel::OM->Get('Kernel::System::Ticket')->ArticleIndex(
    TicketID => $Opts{t},
);

my $Counter = 1;
ARTICLEID:
for my $ArticleID (@Index) {

    last ARTICLEID if $Opts{l} && $Opts{l} < $Counter;
    next ARTICLEID if !$ArticleID;

    # get article data
    my %Article = $Kernel::OM->Get('Kernel::System::Ticket')->ArticleGet(
        ArticleID     => $ArticleID,
        DynamicFields => 0,
    );

    next ARTICLEID if !%Article;

    KEY:
    for my $Key (qw(ArticleID From To Cc Subject ReplyTo InReplyTo Created SenderType)) {

        next KEY if !$Key;
        next KEY if !$Article{$Key};

        print STDOUT "$Key: $Article{$Key}\n";
    }

    $Article{Body} ||= '';

    print STDOUT "Body:\n";
    print STDOUT "$Article{Body}\n";
    print STDOUT "---------------------------------------------------------------------\n";
}
continue {
    $Counter++;
}

1;

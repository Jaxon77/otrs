# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::Database::mysql::MaxAllowedPacket;

use strict;
use warnings;

use base qw(Kernel::System::SupportDataCollector::PluginBase);

our @ObjectDependencies = (
    'Kernel::System::DB',
);

sub GetDisplayPath {
    return 'Database';
}

sub Run {
    my $Self = shift;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if ( $DBObject->GetDatabaseFunction('Type') ne 'mysql' ) {
        return $Self->GetResults();
    }

    $DBObject->Prepare( SQL => "show variables like 'max_allowed_packet'" );
    while ( my @Row = $DBObject->FetchrowArray() ) {

        if (
            !$Row[1]
            || $Row[1] < 1024 * 1024 * 20
            )
        {
            $Self->AddResultProblem(
                Label => 'Maximum Query Size',
                Value => $Row[1] / 1024 / 1024 . ' MB',
                Message =>
                    "The setting 'max_allowed_packet' must be higher than 20 MB.",
            );
        }
        else {
            $Self->AddResultOk(
                Label => 'Maximum Query Size',
                Value => $Row[1] / 1024 / 1024 . ' MB',
            );
        }
    }

    return $Self->GetResults();
}

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<https://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut

1;

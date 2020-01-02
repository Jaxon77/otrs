# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

use Kernel::Output::HTML::Layout;

# get needed objects
my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

my $LayoutObject = Kernel::Output::HTML::Layout->new(
    UserChallengeToken => 'TestToken',
    UserID             => 1,
    Lang               => 'de',
    SessionID          => 123,
);

# rich text tests
my @Tests = (
    {
        Name => '_RichTextReplaceLinkOfInlineContent() - generated by outlook',
        String =>
            '<img alt="" src="/otrs-cvs/otrs-cvs/bin/cgi-bin/index.pl?Action=PictureUpload&amp;FormID=1255961382.1012148.29113074&amp;ContentID=&lt;734083011@19102009-1795&gt;" />',
        Result => '<img alt="" src="cid:&lt;734083011@19102009-1795&gt;" />',
    },
    {
        Name => '_RichTextReplaceLinkOfInlineContent() - generated itself',
        String =>
            '<img width="343" height="563" alt="" src="/otrs-cvs/otrs-cvs/bin/cgi-bin/index.pl?Action=PictureUpload&amp;FormID=1255961382.1012148.29113074&amp;ContentID=inline244217.547683276.1255961382.1012148.29113074@vo7.vo.otrs.com" />',
        Result =>
            '<img width="343" height="563" alt="" src="cid:inline244217.547683276.1255961382.1012148.29113074@vo7.vo.otrs.com" />',
    },
    {
        Name => '_RichTextReplaceLinkOfInlineContent() - generated itself, with newline',
        String =>
            "<img width=\"343\" height=\"563\" alt=\"\"\nsrc=\"/otrs-cvs/otrs-cvs/bin/cgi-bin/index.pl?Action=PictureUpload&amp;FormID=1255961382.1012148.29113074&amp;ContentID=inline244217.547683276.1255961382.1012148.29113074\@vo7.vo.otrs.com\" />",
        Result =>
            "<img width=\"343\" height=\"563\" alt=\"\"\nsrc=\"cid:inline244217.547683276.1255961382.1012148.29113074\@vo7.vo.otrs.com\" />",
    },
    {
        Name =>
            '_RichTextReplaceLinkOfInlineContent() - generated itself, with internal and external image',
        String =>
            '<img width="140" vspace="10" hspace="1" height="38" border="0" alt="AltText" src="http://www.otrs.com/fileadmin/templates/skins/skin_otrs/css/images/logo.gif" /> This text should be displayed <img width="400" height="81" border="0" alt="Description: cid:image001.jpg@01CC3AFE.F81F0B30" src="/otrs/index.pl?Action=PictureUpload&amp;FormID=1311080525.12118416.3676164&amp;ContentID=image001.jpg@01CC4216.1E22E9A0" id="Picture_x0020_1" />',
        Result =>
            '<img width="140" vspace="10" hspace="1" height="38" border="0" alt="AltText" src="http://www.otrs.com/fileadmin/templates/skins/skin_otrs/css/images/logo.gif" /> This text should be displayed <img width="400" height="81" border="0" alt="Description: cid:image001.jpg@01CC3AFE.F81F0B30" src="cid:image001.jpg@01CC4216.1E22E9A0" id="Picture_x0020_1" />',
    },
    {
        Name =>
            '_RichTextReplaceLinkOfInlineContent() - generated itself, with internal and external image, no space before />',
        String =>
            '<img width="140" vspace="10" hspace="1" height="38" border="0" alt="AltText" src="http://www.otrs.com/fileadmin/templates/skins/skin_otrs/css/images/logo.gif" /> This text should be displayed <img width="400" height="81" border="0" alt="Description: cid:image001.jpg@01CC3AFE.F81F0B30" src="/otrs/index.pl?Action=PictureUpload&amp;FormID=1311080525.12118416.3676164&amp;ContentID=image001.jpg@01CC4216.1E22E9A0" id="Picture_x0020_1"/>',
        Result =>
            '<img width="140" vspace="10" hspace="1" height="38" border="0" alt="AltText" src="http://www.otrs.com/fileadmin/templates/skins/skin_otrs/css/images/logo.gif" /> This text should be displayed <img width="400" height="81" border="0" alt="Description: cid:image001.jpg@01CC3AFE.F81F0B30" src="cid:image001.jpg@01CC4216.1E22E9A0" id="Picture_x0020_1"/>',
    },
);

for my $Test (@Tests) {
    my $HTML = $LayoutObject->_RichTextReplaceLinkOfInlineContent(
        String => \$Test->{String},
    );
    $Self->Is(
        ${$HTML} || '',
        $Test->{Result},
        $Test->{Name},
    );
}

1;

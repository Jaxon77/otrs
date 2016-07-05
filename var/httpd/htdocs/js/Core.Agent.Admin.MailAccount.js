// --
// Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.MailAccount
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for MailAccount module.
 */
 Core.Agent.Admin.MailAccount = (function (TargetNS) {

    /*
    * @name Init
    * @memberof Core.Agent.Admin.MailAccount
    * @function
    * @description
    *      This function registers onchange events for showing IMAP Folder and Queue field
    */
    TargetNS.Init = function () {

        // Show IMAP Folder selection only for IMAP backends
        $('select#TypeAdd, select#Type').bind('change', function(){
            if (/IMAP/.test($(this).val())) {
                $('.Row_IMAPFolder').show();
            }
            else {
                $('.Row_IMAPFolder').hide();
            }
        }).trigger('change');

        // Show Queue field only if Dispatch By Queue is selected
        $('select#DispatchingBy').bind('change', function(){
            if (/Queue/.test($(this).val())) {
                $('.Row_Queue').show();
                Core.UI.InputFields.Activate();
            }
            else {
                $('.Row_Queue').hide();
            }
        }).trigger('change');

        Core.UI.Table.InitTableFilter($("#FilterMailAccounts"), $("#MailAccounts"));
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.MailAccount || {}));
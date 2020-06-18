/*!================================================================
 *  JavaScript Popups
 *  emxUIPopups.js
 *  Version 1.0
 *  Requires: emxUIModal.js
 *  Last Updated: 19-Mar-03, Nicholas C. Zakas (NCZ)
 *
 *  This file contains JavaScript functions to show various popups.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 *
 *  static const char RCSID[] = $Id: emxUIPopups.js.rca 1.8.2.1 Fri Nov  7 09:44:19 2008 ds-kvenkanna Experimental $
 *=================================================================
 */
//! Public Function showDialog()
//!     This function shows a generic dialog.
function showDialog(strURL) {
	showModalDialog(strURL, 570, 520,true);
} 
//! Public Function showConfirmDialog()
//!     This function shows a confirmation box and only displays the dialog
//!     if the user presses "OK".
function showConfirmDialog(strConfirm, strURL, strType) {
    if (decodeAndShowConfirm(strConfirm)) {
        switch(strType) {
            case "generic": showDialog(strURL);
                break;
            case "list":  showListDialog(strURL);
                break;
            case "tree": showTreeDialog(strURL);
                break;
        } 
    } 
} 
//! Public Function showListDialog()
//!     This function shows a generic list dialog.
function showListDialog(strURL) {
	showModalDialog(strURL, 730, 450,true);
} 
//! Public Function showTreeDialog()
//!     This function shows a generic tree dialog.
function showTreeDialog(strURL) {
	showModalDialog(strURL, 400, 400,true);
} 
//! Public Function showWizard()
//!     This function shows a wizard dialog.
function showWizard(strURL) {
    showModalDialog(strURL, 780, 500,true);
} 
//! Public Function showDetailsPopup()
//!     This function shows a details tree in a popup window.
function showDetailsPopup(strURL) {
    window.open(strURL, (new Date()).getTime(), "width=875,height=550,resizable=yes");
} 
//! Public Function showSearch()
//!     This function shows a search dialog.
function showSearch(strURL) {
    window.open(strURL, "Search", "width=700,height=500,resizable=yes").focus();
} 
//! Public Function showChooser()
//!     This function shows a chooser dialog.
function showChooser(strURL) {
    showModalDialog(strURL, 700, 500,true);
} 
//! Public Function showPrinterFriendlyPage()
//!     This function shows a printer-friendly page.
function showPrinterFriendlyPage(strURL) {
	window.open(strURL, "PF" + (new Date()).getTime(), "scrollbars=yes,toolbar=yes,location=no,resizable=yes").focus();
} 
//! Public Function showPopupListPage()
//!     This function shows a popup list page.
function showPopupListPage(strURL) {
	window.open(strURL, "PopupList" + (new Date()).getTime(), "width=700,height=500,resizable=yes").focus();
} 
//! Public Function confirmRemove()
//!     This function shows a removal confirmation warning that is used
//!     the user clicks on "Remove Selected". Note: This is for use by
//!     sandbox mockup only.
function confirmRemove() {
	confirm("You have chosen to remove the selected item(s) from this list.\nRemoving an item from a list does not delete the item from the database.\nTo continue with the removal, click OK. To cancel the removal, click Cancel.");
} 
//! Public Function confirmDelete()
//!     This function shows a delete confirmation warning that is used
//!     the user clicks on "Delete Selected".Note: This is for use by
//!     sandbox mockup only.
function confirmDelete() {
	confirm("You have chosen to delete the selected item(s) from the database.\nDeleted items can no longer be accessed from the system.\nTo continue with the deletion, click OK. To cancel the deletion, click Cancel.");
} 
//! Public Function confirmDelete()
//!     This function shows an task added confirmation warning that is used
//!     when the user clicks on "Add" in a add WBS Task dialog. Note: This is for use by
//!     sandbox mockup only.
function confirmAddTaskComplete() {
	confirm("The new task was [added/inserted] successfully");
} 
//! Function showConfirmGeneric()
//!     This function shows generic confirmation message.
function showConfirmGeneric(strConfirm) {
    decodeAndShowConfirm(strConfirm);
} 
//!     This function shows generic confirmation message and returns the
//!     confirm value.
function decodeAndShowConfirm(strConfirm) {
        strConfirm = unescape(strConfirm);
        strConfirm = strConfirm.replace(new RegExp("&nbsp;", "g"), "\n");
        return confirm(strConfirm);
} 
//! Public Function showCalendarPage()
//!     This function shows the calendar page popup.
function showCalendarPage() {
        window.open("../common/emxengchgCalendarPopup.htm",'SelectDate','height=280,width=300,status=no,toolbar=no,menubar=no,location=no');
} 
function showProjectBaseline() {
	showModalDialog("../program/BaselineFrame.htm", 800, 520, true);
}
function showRiskList() {
	showModalDialog("../program/RiskListFrame.htm", 800, 520, true);
}
function showSigmaList() {
	showModalDialog("../program/SigmaListFrame.htm", 800, 520, true);
}
function showCostList() {
	showModalDialog("../program/CostListFrame.htm", 800, 520, true);
}
function showSlipDaysList() {
	showModalDialog("../program/ProjectDashFrame.htm", 800, 520, true);
}
function showProjectAssessmentList() {
	showModalDialog("../program/ProjectAssessmentListFrame.htm", 800, 520, true);
}
function showCTQList() {
	showModalDialog("../program/CTQListFrame.htm", 800, 520, true);
}
function showFinancialsList() {
	showModalDialog("../program/FinancialsFrame.htm", 800, 520, true);
}
function showExcelExportSample(strURL, iWidth, iHeight) {
	var strFeatures = "width=" + iWidth + ",height=" + iHeight;
	var winleft = parseInt((screen.width - iWidth) / 2);
	var wintop = parseInt((screen.height - iHeight) / 2);
	if (isIE)
	  strFeatures += ",left=" + winleft + ",top=" + wintop + ",resizable=yes,statusbar,menubar";
	else
	  strFeatures += ",screenX=" + winleft + ",screenY=" + wintop + ",resizable=no,statusbar,menubar";
	var winNonModalDialog = window.open(strURL, "NonModalWindow" + (new Date()).getTime(), strFeatures);
       	registerChildWindows(winNonModalDialog, getTopWindow())
	winNonModalDialog.focus();
}
//! Public Functions Homepage Prefs
function showHomepagePrefs() {
	showModalDialog("../common/EditDefaultHomepageFrame.htm", 200, 520, true);
} 
//! Public Functions Export()
//!     This function shows the Export page.
function Import() {
        showModalDialog("../../softwareInfy/Export.htm", 400, 220, true);
} 
//! Public Function Import()
//!     This function shows the Export page.
function Export() {
        showModalDialog("../../softwareInfy/Export.htm", 400, 220, true);
} 
//! Public Function confirmDisconnect()
//!     This function shows a disconnect confirmation warning that is used
//!     the user clicks on "Disconnect Selected". Note: This is for use by
//!     sandbox mockup only.
function confirmDisconnect() {
        confirm("You have chosen to disconnect the selected item(s) from this list.\nDisconnecting an item from a list does not delete the item from the database.\nTo continue with the disconnect, click OK. To cancel the disconnect, click Cancel.");
} 
//! Public Function reviseSelected()
//!     This function shows a revise confirmation warning that is used
//!     the user clicks on "Revise Selected". Note: This is for use by
//!     sandbox mockup only.
function reviseSelected() {
        confirm("You have chosen to revise the selected item(s) from this list.\nTo continue with the revise, click OK. To cancel the revise, click Cancel.");
} 
//! Public Function revise()
//!     This function shows a revise confirmation warning that is used
//!     the user clicks on "Revise". Note: This is for use by
//!     sandbox mockup only.
function revise() {
        confirm("You have chosen to revise the object.\nTo continue with the revise, click OK. To cancel the revise, click Cancel.");
} 
//! Public Function version()
//!     This function shows a version change confirmation warning that is used
//!     the user clicks on "Version". Note: This is for use by
//!sandbox mockup only.
function version() {
        confirm("You have chosen to change the version of the object.\nTo continue with the version, click OK. To cancel the version, click Cancel.");
} 
//! Public Function validateConfiguration()
//!     This function shows a validation confirmation message when the
//!     user clicks on "Validate Configuration" link for configurations.
//!     Note: This is for use by sandbox mockup only.
function validateConfiguration() {
        confirm("The selected configuration(s) are valid.");
} 
//! Public Function validateConfiguration()
//!     This function shows a Generate PBOM Message
function generatePBOM() {
        alert("A Precise BOM has been generated for each of the selected Product Configuration(s)");
}

//! Public Function openDynamicURLWindow()
//!     This function shows a hypelined URL object or link
function openDynamicURLWindow(href, type, name, rev, vault, external) {
      if("no"==external) {
           if(""==href) {
              var url 	   = "../common/emxConstructNavigatorURL.jsp";
              var postdata = "&type=" + type + "&name=" + emxUICore.EncodeUrlParam(name) + "&rev=" + rev + "&vault=" + vault;
              var myXMLHTTPRequest = emxUICore.createHttpRequest();
              myXMLHTTPRequest.open("POST", url, false);
              myXMLHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded"); 
              myXMLHTTPRequest.setRequestHeader("charset", "UTF-8"); 
              myXMLHTTPRequest.send(postdata);
              href = myXMLHTTPRequest.responseText;
              href = href.match(/http[^ ]+mode=tree/i) + "";
          }
          if(href.search(/objectId=[\d\.]+/) == -1) {
              var sURLFeatures = "width=" + 700 + ",height=" + 600 + ",menubar=yes" + ",titlebar=yes" + ",toolbar=yes" + ",resizable=yes" + ",status=yes"+ ",scrollbars=yes, location=yes";
              window.open(href,"DynamicURLWindow" + (new Date()).getTime(),sURLFeatures);
          }else {
             showNonModalDialog(href, 700, 600, true);
          }
      }else {
          var sURLFeatures = "width=" + 700 + ",height=" + 600 + ",menubar=yes" + ",titlebar=yes" + ",toolbar=yes" + ",resizable=yes" + ",status=yes"+ ",scrollbars=yes, location=yes";
          window.open(href,"DynamicURLWindow" + (new Date()).getTime(),sURLFeatures);
      }
}

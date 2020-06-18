<%--  emxTriggerReportFS.jsp  -   FS page for displaying admin objects
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTriggerReportFS.jsp.rca 1.2.5.4 Wed Oct 22 15:48:26 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>

<%
String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}
    framesetObject fs = new framesetObject(request);

    fs.setDirectory(appDirectory);
    fs.setSubmitMethod(request.getMethod());

    String suiteKey = emxGetParameter(request, "suiteKey");

    // ----------------- Do Not Edit Above ------------------------------

    // Specify URL to come in middle of frameset
    StringBuffer contentURL = new StringBuffer("emxTriggerReportDialog.jsp");
    contentURL.append("?");
    contentURL.append("suiteKey=");
    contentURL.append(suiteKey);
    contentURL.append("&adminObjectName=");
    contentURL.append(emxGetParameter(request, "adminObjectName"));
    contentURL.append("&adminObjectType=");
    contentURL.append(emxGetParameter(request, "adminObjectType"));
    contentURL.append("&objectId=");
    contentURL.append(emxGetParameter(request, "objectId"));
    contentURL.append("&relId=");
    contentURL.append(emxGetParameter(request, "relId"));

    // Page Heading - Internationalized
    String PageHeading = "emxFramework.TriggerReport.TriggerReportHeading";

    String HelpMarker = "emxhelptriggerreport";

    //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
    fs.initFrameset(PageHeading,
                    HelpMarker,
                    contentURL.toString(),
                    false,
                    true,
                    false,
                    false);

    fs.setStringResourceFile("emxFrameworkStringResource");

    String roleList = "role_GlobalUser";

    fs.createFooterLink("emxFramework.Common.Done",
                      "whenSubmit()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


    fs.createFooterLink("emxFramework.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


    // ----------------- Do Not Edit Below ------------------------------

    fs.writePage(out);

%>

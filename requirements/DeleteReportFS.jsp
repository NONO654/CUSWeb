<%--  DeleteReportFS.jsp
   FrameSet page for Create Requirement Specification dialog

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%--
@quickreview T25 DJH 2014:03:03 HL Single Shot Deletion of Requirement Specification. Passing mode value in URL to DeleteReport.jsp
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.framework.ui.framesetObject"%>
<%
    framesetObject fs = new framesetObject();
    fs.setDirectory(appDirectory);

    String suiteKey     = emxGetParameter(request, "suiteKey");
    String key = emxGetParameter(request, "key");
	boolean isFromSearchDialog = "true".equalsIgnoreCase(emxGetParameter(request, "fromSearch"));
	boolean isFromStructureBrowser = "true".equalsIgnoreCase(emxGetParameter(request, "isFromStructureBrowser"));
	String timeStamp = emxGetParameter(request, "timeStamp"); 
	String modevalue = emxGetParameter(request, "mode"); 

    // Specify URL to come in middle of frameset
    String contentURL  = "DeleteReport.jsp";

    contentURL += "?suiteKey=" + suiteKey + "&key=" + key + "&fromSearch=" + isFromSearchDialog + "&timeStamp=" + timeStamp + "&isFromStructureBrowser=" + isFromStructureBrowser + "&mode=" +modevalue;

    // Marker to pass into Help Pages
    // icon launches new window with help frameset inside
    String HelpMarker  = "emxhelpdeletereport";
    String Header      = "Delete Report:"; 

    fs.initFrameset(Header,
                    HelpMarker,
                    contentURL,
                    false,
                    true,
                    false,
                    false);

    fs.setStringResourceFile("emxRequirementsStringResource");

    fs.createFooterLink("emxRequirements.Button.Done",
                        "refreshParentAndClose()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        0);
    fs.writePage(out);
%>

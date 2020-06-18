<%--  DeleteReportFS.jsp
   FrameSet page for Create Requirement Specification dialog

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.framework.ui.framesetObject"%>
<%
    framesetObject fs = new framesetObject();
    fs.setDirectory(appDirectory);

    String suiteKey     = emxGetParameter(request, "suiteKey");
    String key = emxGetParameter(request, "key");
	String timeStamp = emxGetParameter(request, "timeStamp");      

    // Specify URL to come in middle of frameset
    String contentURL  = "UpdateRevisionReport.jsp";

    contentURL += "?suiteKey=" + suiteKey + "&key=" + key + "&timeStamp=" + timeStamp;

    // Marker to pass into Help Pages
    // icon launches new window with help frameset inside
    String HelpMarker  = "emxhelpupdaterevisionreport";
    String Header      = "emxRequirements.UpdateRevision.Header"; 

    fs.initFrameset(Header,
                    HelpMarker,
                    contentURL,
                    false,
                    true,
                    false,
                    false);

    fs.setStringResourceFile("emxRequirementsStringResource");
 //KIE1 ZUD TSK447636 
    fs.createFooterLink("emxRequirements.Button.Done",
                        "getTopWindow().closeWindow()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        0);
    fs.writePage(out);
%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>

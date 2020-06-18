<!--emxMCCImportDataDialogFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxMCCImportDataDialogFS.jsp.rca 1.5.5.2.2.3 Thu Feb  7 19:55:24 2008 przemek Experimental przemek przemek $
-->
 <%--
    	@quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
    --%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.framework.ui.framesetObject"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
    // construct frameset object
    framesetObject fs = new framesetObject();

    // request paramaters:
    String suiteKey = emxGetParameter(request, "suiteKey");

    // Specify the content URL
    StringBuffer contentURL =  new StringBuffer("ImportXMLStructure.jsp");
    contentURL.append("?suiteKey=");
    contentURL.append(suiteKey);

    String pageHeader = "emxRequirements.ActionLink.ImportStructure";
    String helpMarker = "exmimportxmlstructure";

    fs.setDirectory(appDirectory);
    fs.initFrameset(pageHeader, helpMarker, contentURL.toString(), false, true, false, false);

    fs.setStringResourceFile("emxRequirementsStringResource");
    fs.createFooterLink("emxRequirements.RequirementCapture.LabelImportButtonCaption",
                        "submitImport()",
                        "role_Employee",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        0);
 //KIE1 ZUD TSK447636 
    fs.createFooterLink("emxRequirements.RequirementCapture.LabelButtonCancel",
                        "parent.closeWindow();",
                        "role_Employee",
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        0);

    //fs.setToolbar("ImportXMLStructureToolbar");
    fs.writePage(out);
%>

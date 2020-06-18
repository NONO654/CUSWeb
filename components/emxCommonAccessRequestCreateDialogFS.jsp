<%--  emxCommonAccessRequestCreateDialogFS.jsp   - Frameset Page for create new Access Request dialog.

   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonAccessRequestCreateDialogFS.jsp.rca 1.3.6.5 Wed Oct 22 16:17:42 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>


<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  // ----------------- Do Not Edit Above ------------------------------

  session.setAttribute("documentIds",com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId")));

  String contentURL = "emxCommonAccessRequestCreateDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;

  String PageHeading = "emxComponents.Heading.CreateRequest";
  String HelpMarker = "emxhelprequestcreate";
     
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.useCache(false);
  fs.createCommonLink("emxComponents.Common.Done",
									  "submitform();",
									  "role_GlobalUser",
									  false,
									  true,
									  "common/images/buttonDialogDone.gif",
									  false,
									  0);

  fs.createCommonLink("emxComponents.Common.Cancel",
									  "cancel();",
									  "role_GlobalUser",
									  false,
									  true,
									  "common/images/buttonDialogCancel.gif",
									  false,
									  0);

  fs.writePage(out);
%>

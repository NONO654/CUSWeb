<%--  emxTeamRouteContentBlockedStateDialogFS.jsp  -   Frameset for Attached Documents
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteContentBlockedStateDialogFS.jsp.rca 1.7 Wed Oct 22 16:17:55 2008 przemek Experimental przemek $
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String Directory = appDirectory;

  fs.setDirectory(Directory);

  String objectId  = emxGetParameter(request,"objectId");

  String contentURL = "emxRouteContentBlockedStateDialog.jsp";

  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  String PageHeading = "emxComponents.EditContent.EditStateBlock";

  String HelpMarker = "emxhelpeditlifecycleblocks";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.removeDialogWarning();
  fs.writePage(out);
%>

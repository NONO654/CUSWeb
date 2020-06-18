<%--  emxRouteStopDemoteConnectedObjectDialogFS.jsp   -   Frameset Page for Manual-Stop functionality

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteStopDemoteConnectedObjectDialogFS.jsp.rca 1.2.3.2 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String objectId  = emxGetParameter(request,"objectId");
  String demoteObjectKey  = emxGetParameter(request,"demoteObjectKey");

  fs.setDirectory(appDirectory);
  fs.useCache(false);




  StringBuffer contentURL = new StringBuffer(128);
  contentURL.append("emxRouteStopDemoteConnectedObjectDialog.jsp");
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&demoteObjectKey=");
  contentURL.append(demoteObjectKey);

  String PageHeading = "emxComponents.Heading.StopRoute";
  String HelpMarker = "emxhelpmanualstop";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);

  fs.createCommonLink("emxComponents.Button.Done",
                      "done_onclick()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "cancel_onclick()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);
  fs.writePage(out);


%>

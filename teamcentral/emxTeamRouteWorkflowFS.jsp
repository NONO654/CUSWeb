<%-- emxTeamRouteWorkflowFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamRouteWorkflowFS.jsp.rca 1.6 Wed Oct 22 16:06:27 2008 przemek Experimental przemek $
--%>
<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc" %>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
    initSource = "";
  }

  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String objectId  = emxGetParameter(request,"objectId");


  fs.setDirectory(appDirectory);
fs.useCache(false);
  String contentURL = "emxTeamRouteWorkflow.jsp";

  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId= "+ objectId;

  String PageHeading = "emxCommon.Route.TasksGraphical";
  String HelpMarker = "emxhelprouteworkflow";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);
  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.setObjectId(objectId);

  fs.writePage(out);
%>

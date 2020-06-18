<%-- emxRouteWorkflowFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteWorkflowFS.jsp.rca 1.7 Wed Oct 22 16:18:08 2008 przemek Experimental przemek $
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

  fs.setDirectory(appDirectory);

  String contentURL = "emxRouteWorkflow.jsp";

  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId= "+ objectId;

  String PageHeading = "emxComponents.Route.TasksGraphical";
  String HelpMarker = "emxhelproutetasksgraphical";

//(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly,
//boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);
  fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
  fs.writePage(out);
%>

<%--  emxTeamEditRouteTaskDetailsDailogFS.jsp   -   Frameset for Editing Tasks
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxEditRouteTaskDetailsDialogFS.jsp.rca 1.8 Wed Oct 22 16:18:01 2008 przemek Experimental przemek $"
--%>


<%@ include file = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String routeId      = emxGetParameter(request,"routeId");
  String taskId       = emxGetParameter(request,"taskId");
  String routeNodeId  = emxGetParameter(request,"routeNodeId");
  String taskCreated  = emxGetParameter(request,"taskCreated");

  // Specify URL to come in middle of frameset
  String contentURL = "emxEditRouteTaskDetailsDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&routeId=" + routeId + "&taskCreated=" + taskCreated + "&routeNodeId=" + routeNodeId + "&taskId=" + taskId;

  String PageHeading = "emxComponents.TaskDetails.EditTaskDetails";
  String HelpMarker = "emxhelpedittaskdetails";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxComponentsStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
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


  fs.writePage(out);

%>

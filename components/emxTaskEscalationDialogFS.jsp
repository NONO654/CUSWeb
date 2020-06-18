<%--  emxTaskEscalationDialogFS.jsp   -   Frameset page for escalating task.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTaskEscalationDialogFS.jsp.rca 1.6 Wed Oct 22 16:17:45 2008 przemek Experimental przemek $
--%>


<%@include file = "../emxUIFramesetUtil.inc"%>
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
  String objectId = emxGetParameter(request,"objectId");
  String fromPage  = emxGetParameter(request,"fromPage");
  String routeIds =emxGetParameter(request,"routeIds");
  if( routeIds == null)
        routeIds="";

  // Specify URL to come in middle of frameset
  String contentURL = "emxTaskEscalationDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId+"&fromPage="+fromPage+"&routeIds="+routeIds;

  // page heading - internationalized
  String PageHeading = "emxComponents.Common.SetTaskEscalation";
  fs.setObjectId(objectId);

  // Marker to pass into Help Pages, icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsettaskescalation";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      0);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "getTopWindow().close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);

  fs.removeDialogWarning();
  fs.writePage(out);
%>

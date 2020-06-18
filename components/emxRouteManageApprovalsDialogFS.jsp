<%--  emxRouteManageApprovalsDialogFS.jsp   -   FS page for Manage Route Approval dialog

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteManageApprovalsDialogFS.jsp.rca 1.2.3.2 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  String initSource = emxGetParameter(request,"initSource");
  String strObjectId = emxGetParameter(request,"objectId");
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  if (initSource == null){
    initSource = "";
  }

  framesetObject fs = new framesetObject();
  String Directory  = appDirectory;
  fs.setDirectory(Directory);

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(64);
  contentURL.append("emxRouteManageApprovalsDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(strObjectId);
  contentURL.append("&warn=false"); // To hide the red required field warning

  fs.setStringResourceFile("emxComponentsStringResource");

  String PageHeading = "emxComponents.Heading.ManageRouteApprovals";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpmanagerouteapprovals";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);


  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxComponents.Button.Apply",
                      "apply_onclick()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogApply.gif",
                      false,
                      5);

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

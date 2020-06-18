<%-- emxTaskUpdateCommentsFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTaskUpdateCommentsFS.jsp.rca 1.6 Wed Oct 22 16:17:42 2008 przemek Experimental przemek $
  --%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  framesetObject fs    = new framesetObject();

  String initSource    = emxGetParameter(request,"initSource");
  String suiteKey      = emxGetParameter(request,"suiteKey");
  String objectId      = emxGetParameter(request,"objectId");
  String routeId      = emxGetParameter(request,"routeId");
  String approvalStatus      = emxGetParameter(request,"approvalStatus");
  String Comments      = emxGetParameter(request,"Comments");
  
    
  if (initSource == null){
    initSource = "";
  }

  fs.setDirectory(appDirectory);

  // specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(50);
  contentURL.append("emxTaskUpdateCommentsDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&objectId=");
  contentURL.append( objectId );
  contentURL.append("&routeId=");
  contentURL.append( routeId );
  contentURL.append("&approvalStatus=");
  contentURL.append( approvalStatus );
  contentURL.append("&Comments=");
  contentURL.append( Comments );
  
  // page Heading - Internationalized
  String PageHeading = "emxComponents.Common.RejectComments";

  // marker to pass into Help Pages ,icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcompletetask";

  // PageHeading, HelpMarker, middleFrameURL, UsePrinterFriendly, IsDialogPage,
  // ShowPagination, ShowConversion
  fs.initFrameset(PageHeading, HelpMarker, contentURL.toString(), false, true,
                  false, false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "window.closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
 fs.writePage(out);
%>

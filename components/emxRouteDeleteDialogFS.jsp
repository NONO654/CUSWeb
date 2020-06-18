<%-- emxRouteDeleteDialogFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteDeleteDialogFS.jsp.rca 1.8 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $
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

  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String routeId    = emxGetParameter(request,"routeId");
  String objectId   = emxGetParameter(request,"objectId");
  String sPageName  = emxGetParameter(request,"pageName");
  String param      = emxGetParameter(request,"param");
  String portalMode = emxGetParameter(request,"portalMode");
  // Specify URL to come in middle of frameset
  String contentURL = "emxRouteDeleteDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&routeId=" + routeId + "&objectId=" + objectId + "&pageName=" + sPageName + "&portalMode=" + portalMode;

  // Page Heading - Internationalized
  String PageHeading  = "emxComponents.DeleteRoute.Heading";

  // Marker to pass into Help Pages icon launches new window with help frameset inside
  String HelpMarker = "emxhelpdeleteroute";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))

  fs.createCommonLink("emxComponents.Button.Done",
                      "showEditDialogPopup()",
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

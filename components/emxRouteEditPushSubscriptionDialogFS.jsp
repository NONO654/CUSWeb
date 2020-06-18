<%--  emxRouteEditPushSubscriptionDialogFS.jsp   -   Frameset page for editing push subscription.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteEditPushSubscriptionDialogFS.jsp.rca 1.8 Wed Oct 22 16:18:43 2008 przemek Experimental przemek $
--%>

<%@ include file ="../emxUIFramesetUtil.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<jsp:useBean id = "emxRouteEditPushSubscriptionDialogFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  framesetObject fs     = new framesetObject();
  String tableBeanName  = "emxRouteEditPushSubscriptionDialogFS";
  String initSource     = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String Directory          = appDirectory;
  String objectId           = emxGetParameter(request,"objectId");
  String chkSubscribeEvent  = emxGetParameter(request,"chkSubscribeEvent");
  String projectId          = emxGetParameter(request,"projectId");
  String restrictMembers          = emxGetParameter(request,"restrictMembers");

  String PageHeading        = "emxComponents.Common.PushSubscriptionRecipients";
  String HelpMarker         = "emxhelpeditpushsubscriptionrecipients";


  // Specify URL to come in middle of frameset
  String contentURL         = "emxRouteEditPushSubscriptionDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&projectId="+ projectId + "&flag=pushSubscription&chkSubscribeEvent="+chkSubscribeEvent+"&objectId="+objectId;
  contentURL += "&beanName=" + tableBeanName;
  contentURL += "&restrictMembers=" + restrictMembers; //16 dec
  contentURL                = Framework.encodeURL(response,contentURL);

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.setDirectory(Directory);
  fs.setBeanName(tableBeanName);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxComponents.Button.AddRecipients",
                      "addSelected()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      true,
                      0);

  fs.createCommonLink("emxComponents.Button.RemoveSelected",
                      "removeSelected()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      0);

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      0);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);
  fs.writePage(out);
%>

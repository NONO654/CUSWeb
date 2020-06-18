<%--  emxRouteTaskAddCommentsFS.jsp  - Frameset page for adding a persons roles

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $ Exp $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String keyValue         = emxGetParameter(request,"keyValue");
  String isFDAEnabled = emxGetParameter(request, "isFDAEnabled");
  String requireComment = emxGetParameter(request, "requireComment");

   if(keyValue == null){
         keyValue = formBean.newFormKey(session);
 }

 formBean.processForm(session,request,"keyValue");

  // Specify URL to come in middle of frameset
  String contentURL = "emxRouteTaskAddComments.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?keyValue=" +XSSUtil.encodeForURL(context, keyValue)+"&isFDAEnabled="+XSSUtil.encodeForURL(context, isFDAEnabled)+"&requireComment="+XSSUtil.encodeForURL(context, requireComment);

  // Page Heading  - Internationalized
  String PageHeading = "emxComponents.Tasks.AddComments";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.removeDialogWarning();
  fs.setStringResourceFile("emxComponentsStringResource");

  // TODO!
  // Narrow this list and add access checking
  
  fs.createCommonLink("emxComponents.Command.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);


  fs.createCommonLink("emxComponents.Command.Cancel",
                      "window.closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>

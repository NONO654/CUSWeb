<%--  emxRouteActionRequiredDialogFS.jsp   -   Frameset for Action required
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteActionRequiredDialogFS.jsp.rca 1.18 Wed Oct 22 16:17:45 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>


<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String portalMode = emxGetParameter(request,"portalMode");
  fs.setDirectory(appDirectory);
  fs.useCache(false);

  // ----------------- Do Not Edit Above ------------------------------
  String sourcePage = "";

  Enumeration paramNames = request.getParameterNames();

  Map paramMap = new HashMap();
  while(paramNames.hasMoreElements()) {
   String paramName = (String)paramNames.nextElement();
   String paramValue = emxGetParameter(request,paramName);
   paramMap.put(paramName, paramValue);
   if (paramName.equals("sourcePage")){
     sourcePage = paramValue;
   }
  }

  session.setAttribute("strParams", paramMap);

  fs.setStringResourceFile("emxComponentsStringResource");

  // Page Heading - Internationalized
  String PageHeading = "";
  if (sourcePage==null){
    sourcePage = "";
  }

  if (sourcePage.equals("EditAllTasks")){
    PageHeading = "emxComponents.EditAllTasks.StepActionRequired";
  }else{
    PageHeading = "emxComponents.ActionRequiredDialog.StepActionRequired";
  }

  // Specify URL to come in middle of frameset
  String contentURL = "emxRouteActionRequiredDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&portalMode=" + portalMode;

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcreateroutewizard5";
  fs.removeDialogWarning();
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.createCommonLink("emxComponents.Button.Previous",
                      "goBack()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);

  if (sourcePage.equals("EditAllTasks")) {
    fs.createCommonLink("emxComponents.Button.Done",
                          "submitForm()",
                          "role_GlobalUser",
                          false,
                          true,
                          "common/images/buttonDialogDone.gif",
                          false,
                          3);
  } else {
   fs.createCommonLink("emxComponents.Button.Next",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);
  }

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>

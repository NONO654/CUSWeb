<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPasswordPopupFS.jsp.rca 1.8 Wed Oct 22 15:48:45 2008 przemek Experimental przemek $
--%>

<%@include file = "emxLifecycleUtils.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String signName = emxGetParameter(request, "signatureName");
  String sFnName = emxGetParameter(request, "callbackFunctionName");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxPasswordPopup.jsp");
  
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&callbackFunctionName=");
  contentURL.append(sFnName);

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelplifecyclepassword";

  String roleList = "role_GlobalUser";

  fs.initFrameset("emxFramework.Lifecycle.VerifyPassword",
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

  fs.createFooterLink("emxFramework.Lifecycle.Done",
                      "returnDetails()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  fs.writePage(out);
%>

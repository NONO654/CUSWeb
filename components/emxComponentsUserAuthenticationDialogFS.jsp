<%--  emxComponentsUserAuthenticationDialogFS.jsp  -

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxComponentsUserAuthenticationDialogFS.jsp.rca 1.5 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $"
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@ include file="emxComponentsUtil.inc"%>

<%
//Check whether FDA is enabled in framework properties file.(should it be app specific?)
//before popping up this page when task approve link is clicked.

  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------
  String queryString = request.getQueryString();

  // Added for 359515
  String strCharSet = Framework.getCharacterEncoding(request);
  queryString = FrameworkUtil.decodeURL(queryString,strCharSet);
  queryString = FrameworkUtil.encodeURL(queryString,strCharSet);
  // Ended
  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsUserAuthenticationDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&" + queryString;
  // Page Heading - Internationalized
  String PageHeading = "emxComponents.UserAuthentication.VerifyUser";
  String HelpMarker = "";
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  //fs.removeDialogWarning();


  String i18nDone = "emxComponents.Common.Done";
  String strJScript = "submitFn()";
  fs.createCommonLink(i18nDone,
                      strJScript,
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      4);
  String i18nCancel = "emxComponents.Common.Cancel";
  fs.createCommonLink(i18nCancel,
                      "windowClose()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

   // ----------------- Do Not Edit Below ------------------------------
 fs.writePage(out);

%>







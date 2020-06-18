<%-- emxChangePassword.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String suiteKey     = emxGetParameter(request,"suiteKey");

  fs.setDirectory(appDirectory);


  String sPageResponse=emxGetParameter(request, "pageResponse");
  if(sPageResponse==null || sPageResponse.equalsIgnoreCase("null") || sPageResponse.equals("")) {
      sPageResponse="";
  } else {
    sPageResponse=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sPageResponse);
  }

  // Specify URL to come in middle of frameset
  String contentURL = "emxChangePasswordForm.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&pageResponse=" + sPageResponse;

  fs.setStringResourceFile("emxFrameworkStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Common.ChangePassword";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpchangepassword";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.createFooterLink("emxFramework.Button.Submit",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);

  fs.createFooterLink("emxFramework.Button.Cancel",
                      "doCancel()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

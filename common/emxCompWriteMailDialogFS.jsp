<%-- emxCompWriteMailDialogFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCompWriteMailDialogFS.jsp.rca 1.11 Wed Oct 22 15:48:23 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@ include file  = "emxCompCommonUtilAppInclude.inc" %>


<%
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String sMailId = emxGetParameter(request,"mailId");
  String sLink = emxGetParameter(request,"pageName");

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(150);
  contentURL.append("emxCompWriteMailDialog.jsp");
  String PageHeading  ="";
  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&page=");
  contentURL.append(sLink);
  contentURL.append("&mailId=");
  contentURL.append(sMailId);
  contentURL.append("");

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = emxGetParameter(request,"HelpMarker");

  // Page Heading - Internationalized
  if(sLink.equals("Reply")) {
    PageHeading="emxFramework.IconMail.Common.ReplyMsg";
    if (HelpMarker == null || HelpMarker.trim().length() == 0)
      HelpMarker = "emxhelpreplymail";  
  } else if(sLink.equals("ReplyAll")) {
    PageHeading="emxFramework.IconMail.Common.ReplyallMsg";
    if (HelpMarker == null || HelpMarker.trim().length() == 0)
      HelpMarker = "emxhelpreplymail";  
  } else if(sLink.equals("Forward")) {
    PageHeading="emxFramework.IconMail.Common.FwdMsg";
    if (HelpMarker == null || HelpMarker.trim().length() == 0)
      HelpMarker = "emxhelpreplymail";  
  } else if(sLink.equals("New")) {
    PageHeading="emxFramework.IconMail.Common.CreateMsg";
    if (HelpMarker == null || HelpMarker.trim().length() == 0)
      HelpMarker = "emxhelpcreatemail";  
  }
    
  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
  fs.setStringResourceFile("emxFrameworkStringResource");
  
  
  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxFramework.IconMail.Common.Done",
                      "submitform()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxFramework.IconMail.Common.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);
   fs.removeDialogWarning();

  // ------------ Define any Filters to show in drop down-------------
  // Syntax: addFilterOption(Display String (Internationalized), parameter Value)


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

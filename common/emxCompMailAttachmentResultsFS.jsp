<%-- emxCompMailAttachmentResultsFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCompMailAttachmentResultsFS.jsp.rca 1.10 Wed Oct 22 15:48:13 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxCompCommonUtilAppInclude.inc"%>
<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.setSubmitMethod(request.getMethod());

  // ----------------- Do Not Edit Above ------------------------------


  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  
  String objectId  = emxGetParameter(request,"objectId");
  String objectName = emxGetParameter(request,"objectName");
  String sType = emxGetParameter(request,"txtType");
  String sName = emxGetParameter(request,"txtName");
  String sRevision = emxGetParameter(request,"txtRevision");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("emxCompMailAttachmentResults.jsp");
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&txtType=");
  contentURL.append(sType);
  contentURL.append("&txtName=");
  contentURL.append(sName);
  contentURL.append("&txtRevision=");
  contentURL.append(sRevision);

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.IconMail.Common.SelectContent";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpmailattachments";

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


  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

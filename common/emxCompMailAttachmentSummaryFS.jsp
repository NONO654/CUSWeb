<%-- emxCompMailAttachmentSummaryFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCompMailAttachmentSummaryFS.jsp.rca 1.14 Wed Oct 22 15:48:28 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<jsp:useBean id="emxCompMailAttachmentSummaryFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>

<%
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.setSubmitMethod(request.getMethod());

  String tableBeanName = "emxCompMailAttachmentSummaryFS";
  fs.setBeanName(tableBeanName);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String sMailId = emxGetParameter(request,"objId");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");


  // ----------------- Do Not Edit Above ------------------------------


 // Add Parameters Below
  String param = emxGetParameter(request,"param");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxCompMailAttachmentSummary.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objId=");
  contentURL.append(sMailId);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);

  // Define Top Include Params

  // Page Heading - Internationalized
  String PageHeading ="emxFramework.IconMail.Common.Attachments";



  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = emxGetParameter(request,"HelpMarker");
  if (HelpMarker == null || HelpMarker.trim().length() == 0)
    HelpMarker = "emxhelpmailattachments";



  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,true,false);
  fs.setStringResourceFile("emxFrameworkStringResource");
  fs.setCategoryTree(emxGetParameter(request,"categoryTreeName"));
  fs.setOtherParams(UINavigatorUtil.getRequestParameterMap(request));
   // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);

  %>












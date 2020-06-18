<%--
   emxCommonDownloadEditDialog.jsp
   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDownloadEditDialogFS.jsp.rca 1.2.7.5 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  String tableBeanName = null;
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();
  fs.setBeanName(tableBeanName);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxCommonDownloadEditDialog.jsp";

  String sUrl = emxGetParameter(request,"typename");
  String relId   = emxGetParameter(request,"relId");
  String partName = emxGetParameter(request,"partName");
  String documentName = emxGetParameter(request,"documentName");
  String originator = emxGetParameter(request,"originator");
  
  String sPagination= null;//emxGetParameter(request,"pagination");
  String sQueryLimit = emxGetParameter(request,"QueryLimit");

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&beanName=" + tableBeanName;
  contentURL += "&typename="+sUrl+"&relId="+relId + "&pagination=" + sPagination + "&QueryLimit=" + sQueryLimit;
  contentURL += "&partName="+XSSUtil.encodeForURL(context,partName)+"&documentName="+XSSUtil.encodeForURL(context,documentName)+"&originator="+XSSUtil.encodeForURL(context,originator);


  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Download.EditDownload";
  String HelpMarker = "emxhelpdownloadedit";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.removeDialogWarning();
  fs.initFrameset(PageHeading,HelpMarker,contentURL, false, true, false, false);
  
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitDownload()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);
%>

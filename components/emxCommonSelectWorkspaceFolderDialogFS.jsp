<%--
  emxCommonSelectWorkspaceFolderDialogFS.jsp -  This page is the Frame page to create a template

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCommonSelectWorkspaceFolderDialogFS.jsp.rca 1.10 Wed Oct 22 16:18:05 2008 przemek Experimental przemek $
--%>
<%@include file="emxComponentsCommonUtilAppInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();


  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String sFolderAccessMember = emxGetParameter(request,"folderAccessMember");

  String fieldName = emxGetParameter(request,"fieldName");
  String fieldId = emxGetParameter(request,"fieldId");

  // Default fieldName, fieldId to "txtWSFolder", "folderId" for use with
  // Common Document showFolder and folderURL parameters.
  if ((fieldName == null) || (fieldName.equals("")) ||
      (fieldName.equals("null")))
    fieldName = "txtWSFolder";

  if ((fieldId == null) || (fieldId.equals("")) ||
      (fieldId.equals("null")))
    fieldId = "folderId";

  fs.setFieldParams(fieldName,fieldId);


  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset

  String objectId = emxGetParameter(request,"objectId");
  String strSelect = emxGetParameter(request,"select");
  StringBuffer contentURL = new StringBuffer(128);
  contentURL.append("emxCommonSelectWorkspaceFolderDialog.jsp?objectId=");
  contentURL.append(objectId);
  contentURL.append("&select=");
  contentURL.append(strSelect);
  contentURL.append("&folderAccessMember=");
  contentURL.append(sFolderAccessMember);
  // Page Heading - Internationalized
  String PageHeading = "";
  if(strSelect !=null && strSelect.equals("multiple"))
  {   
      PageHeading = "emxComponents.Common.SelectFolder";
  } 
  else
  {
      PageHeading = "emxComponents.Common.SelectOneFolder";
  }

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsearch";
  String strSelectItem = i18nNow.getI18nString("emxComponents.Common.Select","emxComponentsStringResource",request.getHeader("Accept-Language"));

  // (String pageHeading,String helpMarker, String middleFrameURL, 
  //  boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination,
  //  boolean ShowConversion)
  fs.initFrameset(PageHeading, HelpMarker, contentURL.toString(), false,
                  true, false, false);
  fs.useCache(false);  
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.removeDialogWarning();


  // (String displayString, String href, String roleList, boolean popup,
  //  boolean isJavascript, String iconImage, boolean isheading link,
  //  int WindowSize (1 small - 5 large))
  String i18nNext = "emxComponents.Common.Done";
  String done = "parent.doDone()";
  if ((strSelect != null && !"null".equals(strSelect)) && 
      ("multiple".equals(strSelect)))
  {
    done = "parent.doMultiDone()";
  }
  fs.createCommonLink(i18nNext,
                      done,
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  String i18nCancel = "emxComponents.Common.Cancel";
  fs.createCommonLink(i18nCancel,
                      "window.closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      4);



  // ------------ Define any Filters to show in drop down-------------
  // Syntax: addFilterOption(Display String (Internationalized), parameter Value)

  // ----------------- Do Not Edit Below ------------------------------

  fs.writeSelectPage(out);
%>

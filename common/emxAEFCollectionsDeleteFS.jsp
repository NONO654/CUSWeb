<%--  emxCollectionDeleteDialogFS.jsp  -   FS page for Collections Delete dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAEFCollectionsDeleteFS.jsp.rca 1.12 Wed Oct 22 15:48:54 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>
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
  String objectId = emxGetParameter(request,"emxTableRowId");

  // ----------------- Do Not Edit Above ------------------------------

  // To get the selected collection name from Delete Check page
    String strCollections = "";
    strCollections = emxGetParameter(request,"strCollections");

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxAEFCollectionsDeleteDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&selectedCollections=");
  contentURL.append(strCollections);

  String finalURL=contentURL.toString();

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Collections.ConfirmDelete";

  String HelpMarker = "emxhelpcollectionsdelete";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  finalURL,
                  false,
                  true,
                  false,
                  false);

  fs.removeDialogWarning();
  fs.setStringResourceFile("emxFrameworkStringResource");

  // Set page title - internationalized
  String pageTitle = i18nNow.getI18nString("emxFramework.Collections.ConfirmDelete", "emxFrameworkStringResource",
                                       request.getHeader("Accept-Language"));
  fs.setPageTitle(pageTitle);

  String roleList = "role_GlobalUser";

  fs.createFooterLink("emxFramework.Common.Done",
                      "submit()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


  fs.createFooterLink("emxFramework.Button.Cancel",
                      "parent.window.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

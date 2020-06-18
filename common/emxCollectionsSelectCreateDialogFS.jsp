<%--  emxCollectionSelectCreateDialogFS.jsp  -   FS page for Collections Select/Create  dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsSelectCreateDialogFS.jsp.rca 1.12 Wed Oct 22 15:47:46 2008 przemek Experimental przemek $
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
  String objectId = emxGetParameter(request,"objectId");
  String strNoofItemsSelected = "";

  // ----------------- Do Not Edit Above ------------------------------

  String memberIds[] = emxGetParameterValues(request,"emxTableRowId");

  /* Getting the No of Items selected from the previous page and display it as SubPageHeading */
  if (memberIds != null)
  {    
    session.setAttribute("emx.memberIds",memberIds);
    strNoofItemsSelected = String.valueOf(memberIds.length);
  }
  strNoofItemsSelected = String.valueOf(((String [])session.getAttribute("emx.memberIds")).length);

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxCollectionsSelectCreateDialog.jsp");
  String addFrom3DSearch = emxGetParameter(request,"addFrom3DSearch");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&addFrom3DSearch=");
  contentURL.append(XSSUtil.encodeForURL(context, addFrom3DSearch));

  // Page Headings - Internationalized
  fs.setStringResourceFile("emxFrameworkStringResource");
  String PageHeading = "emxFramework.Collections.SelectCollection";
  
  String pageSubHeading = "emxFramework.Collections.AddToCollectionSubHeader";
  
  String strSubHeading = strNoofItemsSelected+"||~||"+pageSubHeading;
  String HelpMarker = "emxhelpcollectionadd";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)

  // Added SubPageHeading also to display the number of items selected from the previous page
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false,
                  4,
                  strSubHeading);
  fs.removeDialogWarning();
  

  // Set page title - internationalized
  String pageTitle = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Collections.SelectCollection", new Locale(request.getHeader("Accept-Language")));
  
  fs.setPageTitle(pageTitle);

  String roleList = "role_GlobalUser";

  fs.createFooterLink("emxFramework.Common.Done",
                      "doSubmit()",
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

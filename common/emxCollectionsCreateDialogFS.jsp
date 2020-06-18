<%--  emxCollectionsCreateDialogFS.jsp   -   FS page for Creating Collection Details
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsCreateDialogFS.jsp.rca 1.9 Wed Oct 22 15:48:45 2008 przemek Experimental przemek $
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
  String objectName = emxGetParameter(request,"objectName");

  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below

  // Specify URL to come in middle of frameset
  StringBuffer contentURLBuf = new StringBuffer(80);
  contentURLBuf.append("emxCollectionsCreateDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURLBuf.append("?suiteKey=");
  contentURLBuf.append(suiteKey);
  contentURLBuf.append("&initSource=");
  contentURLBuf.append(initSource);
  contentURLBuf.append("&jsTreeID=");
  contentURLBuf.append(jsTreeID);
  
  String contentURL=FrameworkUtil.encodeHref(request,contentURLBuf.toString());

  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Command.CreateCollection";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcollectioncreate";

  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

  
   String pageTitle = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, PageHeading, new Locale(request.getHeader("Accept-Language")));
   fs.setPageTitle(pageTitle);

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";
                    
  fs.createFooterLink("emxFramework.Common.Done",
                      "doneMethod()",
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

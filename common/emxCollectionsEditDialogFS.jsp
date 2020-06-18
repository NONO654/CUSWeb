<%--  emxCollectionEditDialogFS.jsp   -   FS page for Editing Collection Details
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsEditDialogFS.jsp.rca 1.13 Wed Oct 22 15:47:49 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>       
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
  String strSetId = emxGetParameter(request, "relId");
  String objectName = SetUtil.getCollectionName(context, strSetId);
  String sCharSet = Framework.getCharacterEncoding(request);

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(100);
  contentURL.append("emxCollectionsEditDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);

  contentURL.append("&objectName=");
  contentURL.append(FrameworkUtil.encodeNonAlphaNumeric(objectName,sCharSet));
  contentURL.append("&relId=");
  contentURL.append(strSetId);
  // Page Heading - Internationalized
  String PageHeading = "emxFramework.Collections.EditCollections";
   
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcollectionproperties";

  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

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

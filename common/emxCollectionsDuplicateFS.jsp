<%--  emxCollectionsDuplicateFS.jsp   -   FS page for Creating Duplicate Collections
   Copyright (c) 2008-2018 Dassault Systemes, 1993-2007.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsDuplicateFS.jsp.rca 1.4.3.2 Wed Oct 22 15:48:27 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@page import="java.util.StringTokenizer"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxCompCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null)
  {
    initSource = "";
  }
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String objectName = emxGetParameter(request,"objectName");
  String langStr    = request.getHeader("Accept-Language");

  // ----------------- Do Not Edit Above ------------------------------
  String[]  strSelectedCollections          = emxGetParameterValues(request,"emxTableRowId");
  StringBuffer strTemp                      = new StringBuffer();
  String strCharSet                         = Framework.getCharacterEncoding(request);
  String strSystemGeneratedCollectionLabel  = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(langStr), "emxFramework.ClipBoardCollection.NameLabel");
  //Modified for Bug 342586
  String strSystemGeneratedCollection       = EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
  
  if(strSelectedCollections != null)
  {
    for(int i = 0; i < strSelectedCollections.length; i++)
    {
        StringTokenizer strTokenizer    = new StringTokenizer(strSelectedCollections[i] , "|");
        String strCollectionId          = strTokenizer.nextToken() ;
        strTemp.append(strCollectionId);
        strTemp.append("|");
    }
  }
  String strCollections = (strTemp.toString()).substring(0, strTemp.length() - 1);
  strTemp               = new StringBuffer(50);
  strTemp.append(strCollections);

  // Add Parameters Below

  // Specify URL to come in middle of frameset
  StringBuffer contentURLBuf = new StringBuffer(80);
  contentURLBuf.append("emxCollectionsDuplicateDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURLBuf.append("?suiteKey=");
  contentURLBuf.append(suiteKey);
  contentURLBuf.append("&initSource=");
  contentURLBuf.append(initSource);
  contentURLBuf.append("&jsTreeID=");
  contentURLBuf.append(jsTreeID);
  contentURLBuf.append("&selectedCollections=");
  contentURLBuf.append(strTemp.toString());
  
  //String contentURL=FrameworkUtil.encodeHref(request,contentURLBuf.toString());
  String finalURL = contentURLBuf.toString();

  // Page Heading - Internationalized
  String PageHeading = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Collections.DuplicateSelectedCollections", new Locale(langStr)); 

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcollectioncreate";

  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  finalURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxFrameworkStringResource");

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

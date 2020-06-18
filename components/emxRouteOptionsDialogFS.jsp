<%--  emxRouteOptionsDialogFS.jsp   -   Frameset for Action required
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteOptionsDialogFS.jsp.rca 1.16 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String sRouteAction = emxGetParameter(request,"selectedAction");
  String portalMode   = emxGetParameter(request,"portalMode");
  
  String Directory = appDirectory;
  fs.setDirectory(Directory);

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(64);
  contentURL.append("emxRouteOptionsDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&selectedAction=");
  contentURL.append(sRouteAction);
  contentURL.append("&portalMode=");
  contentURL.append(portalMode);
  

  // Page Heading - Internationalized
  fs.setStringResourceFile("emxComponentsStringResource");

  String PageHeading = "emxComponents.OptionsDialog.Options";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  	  
  	  
  String HelpMarker = "emxhelproutecreatertstrt";
  	  

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
  fs.removeDialogWarning();
  fs.createCommonLink("emxComponents.Button.Previous",
                    "goBack()",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogPrevious.gif",
                    false,
                    3);

  fs.createCommonLink("emxComponents.Common.Done",
                    "submitForm()",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogDone.gif",
                    false,
                    3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                    "closeWindow()",
                    "role_GlobalUser",
                    false,
                    true,
                    "common/images/buttonDialogCancel.gif",
                    false,
                    3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

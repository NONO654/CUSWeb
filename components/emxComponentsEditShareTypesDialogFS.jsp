<%--  emxComponentsEditShareTypesFS.jsp   -   FS page for Editing Share Types
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditShareTypesDialogFS.jsp.rca 1.6 Wed Oct 22 16:18:06 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>
<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");
  String relId      = emxGetParameter(request,"relId");
  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsEditShareTypesDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId+"&relId="+relId;
  
  // Page Heading - Internationalized
  String PageHeading = "emxComponents.EditShareTypes.Heading";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpeditsharetypes";
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  // remove the warning                
  fs.removeDialogWarning();
  // setting the string resource file
  fs.setStringResourceFile("emxComponentsStringResource");
  
  fs.createFooterLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_OrganizationManager",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);
                      
  fs.createFooterLink("emxComponents.Button.Cancel",
                      "window.closeWindow()",
                      "role_OrganizationManager",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);
  fs.writePage(out);
%>

<%--  emxComponentsEditPeopleDialogFS.jsp   -   Edit Frameset for Person
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditPeopleDialogFS.jsp.rca 1.13 Wed Oct 22 16:18:11 2008 przemek Experimental przemek $
--%>

<link rel="stylesheet" type="text/css" href="../common/mobile/styles/emxUIMobile.css">
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  if(jsTreeID == null) { jsTreeID = ""; }
  String suiteKey = emxGetParameter(request,"suiteKey");
  if(suiteKey == null) { suiteKey = "Components"; }
  String Directory = appDirectory;

  fs.setDirectory(Directory);

  String personId = emxGetParameter(request,"objectId");

  String relId = emxGetParameter(request,"relId");
  if(relId == null) { relId = "";}
  
  String strContextUserEditProfile  = emxGetParameter(request,"contextusereditprofile");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsEditPeopleDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + personId + "&relId=" + relId + "&contextusereditprofile=" + strContextUserEditProfile;


  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Common.EditPersonDetails";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpprofileedit";

  
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(personId);

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeProfileWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);

%>

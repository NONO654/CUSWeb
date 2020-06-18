<%--  emxProgramCentralQualityMetricCreateDialogFS.jsp

  Displays the header and footer links and loads the page.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxProgramCentralQualityMetricCreateDialogFS.jsp.rca 1.7 Wed Oct 22 15:49:46 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "./emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  // get parameters
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String Directory  = appDirectory;

  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if(initSource == null)
  {
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------
  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralQualityMetricCreateDialog.jsp";
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  // Page Heading & Help Page
  String pageHeading = "emxProgramCentral.Common.CreateMetrics";
  String HelpMarker = "emxhelpqualitymetriccreatedialog";

  fs.initFrameset(pageHeading,HelpMarker,contentURL,false,true,false,false);

  String cancel = "emxProgramCentral.Button.Cancel";
  String done   = "emxProgramCentral.Button.Done";

  fs.createFooterLink(done, "submitFormCreate()", "role_GlobalUser",
                      false, true, "emxUIButtonDone.gif", 0);
  fs.createFooterLink(cancel, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>

<%--  emxProgramCentralQualityMetricEditDialogFS.jsp

  Displays the header and footer links and loads the page.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxProgramCentralQualityMetricEditDialogFS.jsp.rca 1.8 Wed Oct 22 15:49:36 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "./emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  // get parameters
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String qualityId  = emxGetParameter(request,"qualityId");
  String metricId   = emxGetParameter(request,"metricId");
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
  String contentURL = "emxProgramCentralQualityMetricEditDialog.jsp";
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&qualityId=" + qualityId;
  contentURL += "&metricId=" + metricId;

  // Page Heading & Help Page
  String pageHeading = "emxProgramCentral.Common.QualityMetricEditHeading";
  String HelpMarker = "emxhelpqualitymetriceditdialog";

  fs.initFrameset(pageHeading,HelpMarker,contentURL,false,true,false,false);

  String cancel = "emxProgramCentral.Button.Cancel";
  String done   = "emxProgramCentral.Button.Done";

  fs.createFooterLink(done, "submitFormEdit()", "role_GlobalUser",
                      false, true, "emxUIButtonDone.gif", 0);
  fs.createFooterLink(cancel, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>

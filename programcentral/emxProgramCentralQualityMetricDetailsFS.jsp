<%--  emxProjectCentralQualityMetricDetailsFS.jsp

  Displays the header and footer links and loads the page.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxProgramCentralQualityMetricDetailsFS.jsp.rca 1.10 Wed Oct 22 15:49:46 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "./emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String qualityId  = emxGetParameter(request,"qualityId");
  String metricId   = emxGetParameter(request,"metricId");
  String editAccess = emxGetParameter(request,"editAccess");
  String Directory  = appDirectory;

  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // add these parameters to each content URL, and any others the App needs
  String contentURL = "emxProgramCentralQualityMetricDetails.jsp";
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + metricId;
  contentURL += "&qualityId=" + qualityId;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Common.MetricProperties";
  String HelpMarker = "emxhelpqualitymetricdetails";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,true);

  String edit = "emxProgramCentral.Button.Edit";
  String editURL = "emxProgramCentralQualityMetricEditDialogFS.jsp?metricId=" + metricId;

  //Only display the edit button if the metric is the goal or the newest
  if ("true".equals(editAccess)) {
    fs.createHeaderLink(edit, editURL, "role_GlobalUser", true, false, "default", 4);
  }

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

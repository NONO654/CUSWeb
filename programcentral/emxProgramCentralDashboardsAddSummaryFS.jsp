 <%--  emxProgramCentralDashboardsAddSummaryFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralDashboardsAddSummaryFS.jsp.rca 1.8 Wed Oct 22 15:49:45 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String formKey = emxGetParameter(request, "formKey");
  String Directory  = appDirectory;
  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);

  fs.setStringResourceFile("emxProgramCentralStringResource");

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------
  String pageHeader = "emxProgramCentral.ProgramTop.Dashboards";
  String contentURL = "emxProgramCentralDashboardsSummary.jsp?addingTo=True";
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpselectlist";

  fs.initFrameset(pageHeader,HelpMarker,contentURL,false,true,false,false);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 //Footer buttons
  String done   = "emxProgramCentral.Route.Done";
  String cancel = "emxProgramCentral.Button.Cancel";

    fs.createCommonLink(done, "pageSubmition()", "role_GlobalUser",
                        false, true, "emxUIButtonDone.gif", false, 3);

    fs.createCommonLink(cancel, "parent.window.closeWindow()", "role_GlobalUser",
                        false, true, "emxUIButtonCancel.gif", false, 5);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
<html>
</html>

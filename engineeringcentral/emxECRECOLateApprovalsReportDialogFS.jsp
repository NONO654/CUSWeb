<%--    emxECRECOLateApprovalsReportDialogFS.jsp   FS page for ECR ECO Late Approval Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
  String pageValue = emxGetParameter(request,"pageFlag");

  String searchMessage = "emxEngineeringCentral.Common.Search";
  String PageHeading = "emxEngineeringCentral.Search.LateApprovalsReport";

  // create a search frameset object
  searchFramesetObject fs = new searchFramesetObject();

  fs.setDirectory(appDirectory);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");
  fs.setHelpMarker("emxhelplateapprovalrpt");


  String contentURL = "emxECRECOLateApprovalsReportDialog.jsp";

  fs.initFrameset(searchMessage,contentURL,PageHeading,false);

  fs.writePage(out);

%>


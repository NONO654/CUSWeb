<%--  emxEngrECOPdfSummaryReportFS.jsp   -  This page displays the ECR Summary Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file="../emxUIFramesetUtil.inc"%>

<%
String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteEnterpriseChangeMgt.Directory");
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String categoryTreeName = emxGetParameter(request, "categoryTreeName");


  // ----------------- Do Not Edit Above ------------------------------

  String generateSummary = emxGetParameter(request,"generateSummary");
  // Specify URL to come in middle of frameset
  String contentURL = "emxECMPdfSummaryReport.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId +"&generateSummary="+generateSummary + "&categoryTreeName=" + categoryTreeName;

  // Page Heading - Internationalized
  String PageHeading = "EnterpriseChangeMgt.Common.SummaryReportHeader";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpecsummaryreport";

  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxEnterpriseChangeMgtStringResource");
  fs.setCategoryTree(categoryTreeName);
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,false,false);

  String renderSoftwareInstalled = com.matrixone.apps.common.util.JSPUtil.getCentralProperty(application,session,"EnterpriseChangeMgt","RenderPDF");
  if(renderSoftwareInstalled!=null && renderSoftwareInstalled.equalsIgnoreCase("true")) {
	  fs.setToolbar("ECMSummaryReportToolBarMenu");
  }
  fs.writePage(out);

%>

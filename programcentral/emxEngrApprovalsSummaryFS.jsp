<%--  emxEngrApprovalsSummaryFS.jsp - frameset definition page for Revisions in UI3
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEngrApprovalsSummaryFS.jsp.rca 1.13 Wed Oct 22 15:49:35 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<jsp:useBean id="emxEngrApprovalsSummaryFS" scope="session" class="com.matrixone.apps.framework.ui.UITable"/>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String Directory = appDirectory;

  // ----------------- Do Not Edit Above ------------------------------
  String objectId = emxGetParameter(request,"objectId");
  String tableBeanName = "emxEngrApprovalsSummaryFS";

  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrApprovalsSummary.jsp" + "?suiteKey=" + suiteKey + 
                      "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + 
                      "&objectId="+objectId + "&beanName=" + tableBeanName;

  // Page Heading - Internationalized
  String PageHeading = "emxProgramCentral.Program.ApprovalsPageHeading";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpapprovalsummary";

  fs.setBeanName(tableBeanName);
  fs.setDirectory(Directory);
  fs.setObjectId(objectId);
  fs.setStringResourceFile("emxProgramCentralStringResource");
  fs.setCategoryTree(emxGetParameter(request, "categoryTreeName"));
  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,false,true,false);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

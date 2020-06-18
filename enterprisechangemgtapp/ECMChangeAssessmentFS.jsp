<%--  ECMChangeAssessmentFS.jsp   -   FS page for opening Change Assessment in a slidein page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);
  fs.setSubmitMethod(request.getMethod());

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
	initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String emxTableRowId = emxGetParameter(request,"emxTableRowId");
  String[] strArrObjectId = emxGetParameterValues(request,"objectId");
	String strObjectId = strArrObjectId[0];
  
  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below

  // Specify URL to come in middle of frameset
String contentURL="../common/emxIndentedTable.jsp?program=enoECMChangeUX:getChangeAssessmentItems&Level=All&table=ECMRelatedItemTable&header=EnterpriseChangeMgt.Command.ChangeAssessment&toolbar=ECMRelatedItemToolbar&selection=multiple&massPromoteDemote=false&editRootNode=false&rowGroupingColumnNames=CustomLabel&rowGrouping=false&autoFilter=false&export=false&multiColumnSort=false&printerFriendly=false&objectCompare=false&triggerValidation=false&showClipboard=false&customize=false&expandLevelFilterMenu=false&displayView=details&hideHeader=true&HelpMarker=emxhelpchangeassessment&suiteKey=EnterpriseChangeMgt&emxTableRowId="+emxTableRowId+"&contextCOId="+strObjectId;

  // Page Heading - Internationalized
	String PageHeading = "EnterpriseChangeMgt.Command.ChangeAssessment";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "false";

  
  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  false,
                  false,
                  false,
                  false);

  fs.setStringResourceFile("emxEnterpriseChangeMgtStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";
                    
//   fs.createFooterLink("emxFramework.Common.Done",
//                       "doneMethod()",
//                       roleList,
//                       false,
//                       true,
//                       "common/images/buttonDialogDone.gif",
//                       0);

                      
  fs.createFooterLink("EnterpriseChangeMgt.Command.Cancel",
                      "getTopWindow().closeWindow()",
                      roleList,
                      true,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

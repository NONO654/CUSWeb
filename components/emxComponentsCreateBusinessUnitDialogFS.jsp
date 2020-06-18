<%--  emxComponentsCreateBusinessUnitDialogFS.jsp   -   Dispaly the FrameSet BusinessUnit Dialog Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreateBusinessUnitDialogFS.jsp.rca 1.9 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $
--%>


<%@ include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null)
  {
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID"); 
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String Directory = appDirectory;

  fs.setDirectory(Directory);

  String companyId       = emxGetParameter(request,"objectId");
  String businessUnitId = emxGetParameter(request,"businessUnitId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsCreateBusinessUnitDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&companyId=" + companyId;
  contentURL += "&businessUnitId=" + businessUnitId;

  String PageHeading = "";

  if (businessUnitId == null ) {
    PageHeading = "emxComponents.Common.CreateBusinessUnit";
  } else {
    PageHeading = "emxComponents.Common.EditBusinessUnit";
  }

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcompanycreate";
  if (businessUnitId != null) {
     HelpMarker = "emxhelpbusinessuniteditdetails";
  } 
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.createCommonLink("emxComponents.Button.Done",
                      "validateAndSubmit()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_OrganizationManager",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_OrganizationManager",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>

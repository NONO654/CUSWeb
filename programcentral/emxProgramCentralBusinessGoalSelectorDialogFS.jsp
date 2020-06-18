
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%> <%--  emxProgramCentralBusinessGoalSelectorDialogFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxProgramCentralBusinessGoalSelectorDialogFS.jsp.rca 1.8 Wed Oct 22 15:49:19 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>
 
<%
  com.matrixone.apps.common.Company company = (com.matrixone.apps.common.Company) DomainObject.newInstance(context, DomainConstants.TYPE_COMPANY);

  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String fieldName  = emxGetParameter(request,"fieldName");
  String fieldId    = emxGetParameter(request,"fieldId");
  String objectId   = emxGetParameter(request,"objectId");
  String Directory  = appDirectory;

  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fieldName = XSSUtil.encodeURLForServer(context,fieldName);
  fieldId = XSSUtil.encodeURLForServer(context,fieldId);
  fs.setFieldParams(fieldName,fieldId);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null){
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  // see if company has any business units to determine if submit button should be shown
  company.setId(objectId);
  StringList busSelects =  new StringList();
  busSelects.add (company.SELECT_ID);
  MapList busUnitList = company.getBusinessUnits(context, 0, busSelects, false);  

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralBusinessGoalSelectorDialog.jsp?companyId="+ objectId;
  // add these parameters to each content URL, and any others the App needs
  contentURL += "&suiteKey=" + suiteKey + "&initSource=" + initSource;
  contentURL += "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Common.SelectOrganization";
  String HelpMarker = "emxhelpbusinessgoalselectordialog";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  String submitStr = "emxProgramCentral.Button.Done";
  String cancelStr = "emxProgramCentral.Button.Cancel";
  String actionString = "parent.doDone()";

  fs.createFooterLink(submitStr, actionString, "role_GlobalUser",
                        false, true, "emxUIButtonDone.gif", 0); 

  fs.createFooterLink(cancelStr, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writeSelectPage(out);
%>

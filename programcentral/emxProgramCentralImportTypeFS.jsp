 <%--  emxProgramCentralImportTypeFS.jsp  -

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.

  static const char RCSID[] = $Id: emxProgramCentralImportTypeFS.jsp.rca 1.14 Wed Oct 22 15:50:32 2008 przemek Experimental przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<jsp:useBean id="domainObject" scope="page" class="com.matrixone.apps.domain.DomainObject"/>

<%
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String objectId = (String) emxGetParameter(request, "objectId");
  String calledFrom = (String) emxGetParameter(request, "calledFrom");

  String Directory  = appDirectory;
  framesetObject fs = new framesetObject();
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  // ----------------- Do Not Edit Above ------------------------------

  // Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralImportType.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?objectId=" + objectId;

  // Page Heading & Help Page
  String PageHeading = "emxProgramCentral.Common.Import";

 //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //Import page can be called from several places, determine type and then
  //set the correct help marker
  String HelpMarker = "emxhelpimportdetails";
  String importType = (String) session.getValue("importType");

  //if importType was not set in the session get it from request and set it
  //in session
  if(calledFrom != null && !"".equals(calledFrom)){
    importType = PropertyUtil.getSchemaProperty(context,calledFrom);
    session.setAttribute("importType",importType);
  }

  if (importType != null) {
    String importTypeQuality = PropertyUtil.getSchemaProperty(context,"type_Quality");
    String importTypeRisk = PropertyUtil.getSchemaProperty(context,"type_Risk");
    String importTypeFinancial = PropertyUtil.getSchemaProperty(context,"type_FinancialItem");

    if (importType.equals(importTypeQuality)) {
      HelpMarker = "emxhelpimportqualitydetails";
    }
    else if (importType.equals(importTypeRisk)) {
      HelpMarker = "emxhelpimportriskdetails";
    }
    if (importType.equals(importTypeFinancial)) {
      HelpMarker = "emxhelpimportfinancialdetails";
    }
  } //end if importType != null
  fs.initFrameset("emxProgramCentral.Common.Import", HelpMarker, contentURL,
                  true, false, false, false);

  fs.createFooterLink("emxProgramCentral.Button.Next", "validateForm()",
                      "role_GlobalUser", false, true, "common/images/buttonDialogNext.gif", 1);

  fs.createFooterLink("emxProgramCentral.Button.Cancel", "cancel()",
                      "role_GlobalUser", false, true, "common/images/buttonDialogCancel.gif", 1);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

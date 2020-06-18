<%--  emxTeamCreateWorkspaceWizardDialogFS.jsp   -   Create Frameset for WorkSpace Wizard
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateWorkspaceWizardDialogFS.jsp.rca 1.9 Wed Oct 22 16:06:33 2008 przemek Experimental przemek $
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil" %>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID              = emxGetParameter(request,"jsTreeID");
  String suiteKey              = emxGetParameter(request,"suiteKey");
  String workspaceName         = emxGetParameter(request,"workspaceName");
  String workspaceDesc         = emxGetParameter(request,"workspaceDesc");
  String templateId            = emxGetParameter(request, "templateId");
  String template              = emxGetParameter(request, "template");

  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.useCache(false);
  String projectId  = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamCreateWorkspaceWizardDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + projectId+ "&templateId=" + templateId+ "&template=" + template;
  contentURL += "&workspaceName=" + XSSUtil.encodeForURL(workspaceName) + "&workspaceDesc=" + XSSUtil.encodeForURL(workspaceDesc);

  String PageHeading = "emxTeamCentral.CreateWorkSpaceDialog.SpecifyDetails";
  String HelpMarker  = "emxhelpwcreateworkspacewizard1";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Next",
                      "submitForm()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>

<%--  emxTeamCreateWorkspaceWizardSubFoldersFS.jsp   -   Create Frameset for SubFolders
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateWorkspaceWizardSubFoldersFS.jsp.rca 1.10 Wed Oct 22 16:06:22 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String Directory = appDirectory;
  fs.setDirectory(Directory);
  fs.useCache(false);
  String projectId        = emxGetParameter(request,"objectId");
  String projectName      = emxGetParameter(request,"projectName");
  String templateId       = emxGetParameter(request, "templateId");
  String template         = emxGetParameter(request, "template");
  String buyerDesk        = emxGetParameter(request,"buyerDesk");
  String description      = emxGetParameter(request,"description");
  String image            = emxGetParameter(request,"image");
  String sFolderId        = emxGetParameter(request,"FolderId");


  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamCreateWorkspaceWizardSubFolders.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + projectId;
  contentURL += "&projectName=" + projectName + "&template=" + template +"&templateId="+templateId+ "&buyerDesk=" + buyerDesk;
  contentURL += "&description=" + description + "&image=" + image+"&FolderId="+sFolderId;

  String PageHeading = "emxTeamCentral.CreateWorkSpaceDialog.SpecifySubfolders";
  String HelpMarker = "emxhelpwcreateworkspacewizard3";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Previous",
                      "goBack()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_VPLMAdmin,role_VPLMViewer,role_VPLMProjectLeader,role_VPLMExperimenter,role_VPLMCreator",
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);

  fs.createCommonLink("emxTeamCentral.Button.Next",
                      "submitForm()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_VPLMAdmin,role_VPLMViewer,role_VPLMProjectLeader,role_VPLMExperimenter,role_VPLMCreator",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_VPLMAdmin,role_VPLMViewer,role_VPLMProjectLeader,role_VPLMExperimenter,role_VPLMCreator",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);
%>

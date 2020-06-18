<%--  emxTeamCreateWorkspaceToplevelFoldersFS.jsp   -   Create Frameset for TopLevel Folders
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateWorkspaceToplevelFoldersFS.jsp.rca 1.12 Wed Oct 22 16:06:03 2008 przemek Experimental przemek $
--%>


<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<jsp:useBean id="emxTeamCreateWorkspaceToplevelFoldersFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String tableBeanName = "emxTeamCreateWorkspaceToplevelFoldersFS";
  framesetObject fs = new framesetObject();

  String initSource        = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID          = emxGetParameter(request,"jsTreeID");
  String suiteKey          = emxGetParameter(request,"suiteKey");
  String Directory         = appDirectory;

  fs.setDirectory(Directory);
  fs.useCache(false);

  String projectId       = emxGetParameter(request,"objectId");
  String projectName     = emxGetParameter(request,"projectName");
  String template        = emxGetParameter(request,"template");
  String buyerDesk       = emxGetParameter(request,"buyerDesk");
  String description     = emxGetParameter(request,"description");
  String image           = emxGetParameter(request,"image");
  String sWsTemplateId   = emxGetParameter(request,"templateId");

  StringList sVPLMRoleList = new StringList(4);
  sVPLMRoleList.addElement("VPLMAdmin");
  sVPLMRoleList.addElement("VPLMViewer");
  sVPLMRoleList.addElement("VPLMProjectLeader");
  sVPLMRoleList.addElement("VPLMCreator");
 	String roles = PersonUtil.getVPLMChildrenRoleList(context, sVPLMRoleList); 
 	roles = roles.concat(",role_ExchangeUser,role_CompanyRepresentative"); 
  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamCreateWorkspaceToplevelFolders.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + projectId +"&templateId=" +sWsTemplateId;
  contentURL += "&projectName=" + projectName + "&template=" + template + "&buyerDesk=" + buyerDesk;
  contentURL += "&description=" + description + "&image=" + image;
  contentURL += "&beanName=" + tableBeanName;

  String PageHeading = "emxTeamCentral.CreateWorkSpaceDialog.SpecifyTopFolders";
  String HelpMarker = "emxhelpwcreateworkspacewizard2";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);
  fs.setBeanName(tableBeanName);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.RemoveSelected",
                      "showDeleteDialogPopup()",
                      roles,
                      false,
                      true,
                      "default",
                      false,
                      0);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.CreateNew",
                      "showCreateNewFolderDilaog()",
                      roles,
                      false,
                      true,
                      "default",
                      true,
                      3);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Previous",
                      "goBack()",
                      roles,
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);

  fs.createCommonLink("emxTeamCentral.Button.Next",
                      "submitForm()",
                      roles,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      roles,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>

<%--  emxTeamSubscribeWorkspaceDialogFS.jsp   -   Display all the Task objects connected to person
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSubscribeWorkspaceOptionsFS.jsp.rca 1.11 Wed Oct 22 16:05:54 2008 przemek Experimental przemek $
--%>


<%@ include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>


<%
  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);
fs.useCache(false);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");
  String sTypeProjVault   = Framework.getPropertyValue(session, "type_ProjectVault");
  String sTypeProject     = Framework.getPropertyValue(session, "type_Project");
  String sTypeRoute       = Framework.getPropertyValue(session, "type_Route");
  String sDocument        = Framework.getPropertyValue( session, "type_DOCUMENTS");
  String PageHeading      = "";
  String sType            = "";

  BusinessObject boGeneric = new BusinessObject(objectId);
  boGeneric.open(context);
  sType = boGeneric.getTypeName();
  boGeneric.close(context);

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamSubscribeWorkspaceOptionsDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+ "&objectId="+objectId;

  Vault vault = new Vault(JSPUtil.getVault(context,session));
  String BaseType= FrameworkUtil.getBaseType(context,sType,vault);


  if (sType.equals(sTypeProject)) {
    PageHeading = "emxTeamCentral.WorkspaceSubscribe.Options";
  } else if(sType.equals(sTypeRoute)) {
    PageHeading = "emxTeamCentral.RouteSubscribe.Options";
  } else if(sType.equals(sTypeProjVault)) {
    PageHeading = "emxTeamCentral.FolderSubscribe.Options";
  } else if(BaseType.equals(sDocument)) {
    PageHeading = "emxTeamCentral.FileSubscribe.Options";
  }

  String HelpMarker = "emxhelpsubscribe";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");
  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitForm()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_CompanyRepresentative,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>

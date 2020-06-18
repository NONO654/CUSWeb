<%-- emxTeamCreateSubFoldersWorkspaceDialogFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamCreateSubFoldersWorkspaceDialogFS.jsp.rca 1.8 Wed Oct 22 16:06:13 2008 przemek Experimental przemek $
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
  String callPage = emxGetParameter(request,"callPage");

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamCreateSubFoldersWorkspaceDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+"&objectId="+objectId + "&callPage=" + callPage ;

  String PageHeading = "emxTeamCentral.common.CreateNewSubfolder";

  String HelpMarker = "emxhelpcreatenewsubfolder";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitform()",
                      "role_Buyer,role_Supplier,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "closeWindow()",
                      "role_Buyer,role_Supplier,role_ExchangeUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);

%>

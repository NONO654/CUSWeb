<%-- emxTeamDeleteContentDialogFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamDeleteContentDialogFS.jsp.rca 1.9 Wed Oct 22 16:06:29 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
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

  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  //String contentId  = emxGetParameter(request,"documentId");
  String objectId   = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamDeleteContentDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;

  String PageHeading  = "emxTeamCentral.DeleteContentFS.Heading";
  String HelpMarker = "emxhelpremovecontentconfirmation";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,true,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxTeamCentral.Button.Ok",
                      "showEditDialogPopup()",
                      "role_ExchangeUser,role_CompanyRepresentative",
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

<%--  emxTeamCreatePeopleDialogFS.jsp   -   Create Frameset for Person
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSubscribeDialogFS.jsp.rca 1.9 Wed Oct 22 16:06:02 2008 przemek Experimental przemek $
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
  String objectId = emxGetParameter(request,"objectId");
  Message message=(Message)DomainObject.newInstance(context,objectId ,DomainObject.TEAM);
  

  // Specify URL to come in middle of frameset
  String contentURL = "emxTeamSubscribeDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;

  String PageHeading = "emxTeamCentral.Discussion.Subscribe";
  String HelpMarker = "emxhelpdiscussionmessagesubscriptionoptions";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.setStringResourceFile("emxTeamCentralStringResource");

  fs.setObjectId(objectId);

  fs.removeDialogWarning();

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Done",
                      "submitForm()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      0);

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, boolean isTopLink, int WindowSize)
  fs.createCommonLink("emxTeamCentral.Button.Cancel",
                      "getTopWindow().closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      0);

  fs.writePage(out);

%>

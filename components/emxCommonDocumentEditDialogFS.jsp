<%--  emxCommonDocumentEditDialogFS.jsp   -   FS page for Editing Document Details
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentEditDialogFS.jsp.rca 1.7 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  DomainObject rel = DomainObject.newInstance(context);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");


  framesetObject fs = new framesetObject();
  String Directory  = appDirectory;
  fs.setDirectory(Directory);

  // Specify URL to come in middle of frameset
  String contentURL = "emxCommonDocumentEditDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID+"&objectId="+objectId;
  contentURL += "";

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);

  String PageHeading = "emxComponents.Common.EditDetailsHeadingWithoutRev";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpdocumenteditdetails";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);


  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>

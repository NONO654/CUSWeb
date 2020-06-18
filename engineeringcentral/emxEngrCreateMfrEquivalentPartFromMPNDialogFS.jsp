<%--  emxEngrCreateMfrEquivalentPartFromMPNDialogFS.jsp   -   FS page for Editing Part Details
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  //fs.setDirectory(appDirectory);
  fs.setDirectory("manufacturerequivalentpart");
  
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
        initSource = "";
    }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");


  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrCreateMfrEquivalentPartFromMPNDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;

  // Page Heading - Internationalized
  String PageHeading =  "emxEngineeringCentral.Command.AssignNewPartToPlaceholder";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
   String HelpMarker = "emxhelpmpnaddmep";

  fs.initFrameset(PageHeading,
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))
  fs.createFooterLink("emxFramework.Command.Done",
                      "checkInput()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


  fs.createFooterLink("emxFramework.Command.Cancel",
                      "closeThis()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>






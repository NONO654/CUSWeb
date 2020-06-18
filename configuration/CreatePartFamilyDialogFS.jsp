<%--  emxProductCentralCreatePartFamilyDialogFS.jsp   -   FS page for Create Part Family dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/CreatePartFamilyDialogFS.jsp 1.4.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------
  String sNewRev = emxGetParameter(request,"RevMode");
  String strObjectId  = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  String contentURL = "CreatePartFamilyDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&PRCFSParam1=PartFamily";
  contentURL += "&objectId=" + strObjectId;
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartfamilycreate";

  fs.initFrameset("emxProduct.DesignTOP.CreatePartFamily",
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxConfigurationStringResource");

  fs.createFooterLink("emxProduct.Button.Done",
                      "checkInput()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);

  fs.createFooterLink("emxProduct.Button.Cancel",
                      "parent.window.closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>






<%-- emxComponentsEditCapabilityDialogFS.jsp   -

   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditCapabilityDialogFS.jsp.rca 1.7 Wed Oct 22 16:18:26 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

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

  // Add Parameters Below
  String strObjectId = emxGetParameter(request,"objectId");
  String strRelId = emxGetParameter(request,"relId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsEditCapabilityDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + strObjectId;
  contentURL += "&relId=" + strRelId;

  // Page Heading - Internationalized
  String PageHeading = "emxComponents.Capabilities.EditCapability";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcapabilityeditdetails";

  fs.setObjectId(strObjectId);

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");

  String languageStr = request.getHeader("Accept-Language");

  fs.createCommonLink("emxComponents.Button.Done",
                      "modify()",
                      "role_BuyerAdministrator,role_SupplierRepresentative,role_SupplierDevelopmentManager",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "window.closeWindow()",
                      "role_BuyerAdministrator,role_SupplierRepresentative,role_SupplierDevelopmentManager",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);
  fs.writePage(out);

%>






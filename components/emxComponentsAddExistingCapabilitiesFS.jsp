<%-- emxComponentsAddExistingCapabilitiesFS.jsp   -

   Copyright (c) 1992-2018  Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingCapabilitiesFS.jsp.rca 1.8 Wed Oct 22 16:18:02 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
String accessUsers = "role_AdministrationManager,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

 
  framesetObject fs = new framesetObject();
  fs.setStringResourceFile("emxComponentsStringResource");

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  fs.setDirectory(appDirectory);
  fs.useCache(false);
  
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
 
  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");
  fs.setObjectId(objectId);

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsAddExistingCapabilities.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;

  //String PageHeading = objectName + ": Capabilities";
  String PageHeading  = "emxComponents.Capabilities.AddCapability";
  String HelpMarker = "emxhelpcapabilitycreate";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.createCommonLink("emxComponents.Button.Done",
                      "add()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_OrganizationManager,role_Buyer,role_BuyerAdministrator,role_SupplierDevelopmentManager,role_SupplierRepresentative,role_AdvancedQualityEngineer",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "parent.window.closeWindow()",
                      "role_ExchangeUser,role_CompanyRepresentative,role_OrganizationManager,role_Buyer,role_BuyerAdministrator,role_SupplierDevelopmentManager,role_SupplierRepresentative,role_AdvancedQualityEngineer",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>






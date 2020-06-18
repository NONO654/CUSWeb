<%--  emxEngrCreateApplicationPartDialogFS.jsp   -   FS page for Create Application Part dialog
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

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
		initSource = "";
	}
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String SuiteDirectory = emxGetParameter(request,"SuiteDirectory");
  String objectId = emxGetParameter(request,"objectId");
  String assemblyPartId = emxGetParameter(request,"assemblyPartId");
  String fromsummarypage = emxGetParameter(request, "fromsummaryPage");
  String prevmode = emxGetParameter(request,"prevmode");
  String objType = DomainConstants.TYPE_PART;

  String propertyKeyValueForApplicationPart= EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(), "emxEngineeringCentral.ApplicationPart.ErrorMsg");
  
  // ----------------- Do Not Edit Above ------------------------------
  // Specify URL to come in middle of frameset
  String contentURL = "emxEngrCreateApplicationPartDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&SuiteDirectory=" + SuiteDirectory;
  contentURL += "&objectId=" + objectId;
  contentURL += "&assemblyPartId=" + assemblyPartId;
  contentURL += "&fromsummaryPage=" + fromsummarypage;
  contentURL += "&prevmode=" + prevmode;

  if(objectId != null) {
     DomainObject doEPart = DomainObject.newInstance(context,objectId);
     objType = doEPart.getInfo(context,doEPart.SELECT_TYPE);
     if(objType.equals(DomainConstants.TYPE_APPLICATION_PART)) {
        session.putValue("error.message",propertyKeyValueForApplicationPart);
     }
  }

  
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpapplicationpartcreate";

  /*String roleList = "role_DesignEngineer," +
                    "role_ManufacturingEngineer," +
                    "role_ComponentEngineer," +
                    "role_SeniorDesignEngineer," + "role_SeniorManufacturingEngineer";*/
  String roleList ="role_GlobalUser";

  fs.initFrameset("emxEngineeringCentral.Part.CreateNewApplicationPart",
                  HelpMarker,
                  contentURL,
                  false,
                  true,
                  false,
                  false);

  fs.setStringResourceFile("emxEngineeringCentralStringResource");

if(!objType.equals(DomainConstants.TYPE_APPLICATION_PART)) {
   fs.createFooterLink("emxFramework.Command.Next",
                      "checkInput()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      0);
}
  

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "cancel()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>






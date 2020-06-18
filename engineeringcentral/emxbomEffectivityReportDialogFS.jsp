<%--emxbomEffectivityReportDialogFS.jsp
	Copyright (c) 1998-2018 Dassault Systemes.
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


  // ----------------- Do Not Edit Above ------------------------------

  // Add Parameters Below
  String objectId = emxGetParameter(request,"objectId");

  // Specify URL to come in middle of frameset
  String contentURL = "emxbomEffectivityReportDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.EngrEffReport.EngineeringEffectivityReport";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbomeffectivityreport";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");
  //Added for IR-164107V6R2013x start
  fs.setSuiteKey("EngineeringCentral");
//Added for IR-164107V6R2013x end
  if (acc.has(Access.cRead)) {

 // Role based access
 /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator";*/
 String roleList ="role_GlobalUser";

  fs.createFooterLink("emxEngineeringCentral.Common.Done",
                      "doneMethod()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      4);

  fs.createFooterLink("emxEngineeringCentral.Common.Cancel",
                      "parent.closeWindow()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);


  }
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

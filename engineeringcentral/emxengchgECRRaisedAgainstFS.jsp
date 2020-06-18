 <%--  emxengchgECRRaisedAgainstFS.jsp  -
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
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // Specify URL to come in middle of frameset
  String contentURL = "emxengchgECRRaisedAgainst.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID + "&objectId=" + objectId;

  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.ECR.RaisedAgainst";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpecrraisedagainst";


  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.removeDialogWarning();
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

 // Role based access
 /*String roleList ="role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator";*/
 String roleList ="role_GlobalUser";

  if (acc.has(Access.cRead)) {

  fs.createFooterLink("emxEngineeringCentral.Common.Done",
                      "parent.closeWindow()",
                       roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      5);

  }

  fs.writePage(out);

%>






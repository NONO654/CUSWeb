<%--  emxpartAVLEditLocationFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%> 

<%@ include file="../emxUIFramesetUtil.inc"%>
<%@ include file="emxEngrFramesetUtil.inc"%>
<script language="javascript" src="scripts/emxUIUtility.js"></script>
<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  StringBuffer contentURL = new StringBuffer("emxpartAVLEditLocation.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(emxGetParameter(request,"suiteKey"));
  // set showWarning variable to false for not to show the required fields message.
  contentURL.append("&showWarning=false");
  contentURL.append("&jsTreeID=");
  contentURL.append(emxGetParameter(request,"jsTreeID"));
  contentURL.append("&objectId=");
  contentURL.append(emxGetParameter(request,"objectId"));

  // Page Heading - Internationalized
  
  String PageHeading = "emxEngineeringCentral.Part.AVL.EditLocation";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbomavl";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  if (acc.has(Access.cRead)) {

  // Role based access
 /*String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer,role_ECRCoordinator,role_ECREvaluator,role_ECRChairman,role_ProductObsolescenceManager,role_PartFamilyCoordinator,role_SupplierEngineer,role_SupplierRepresentative";*/
 String roleList ="role_GlobalUser";

  fs.createFooterLink("emxFramework.Command.Done",
                      "submit()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);


  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.closeWindow()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      5);
  }
  fs.writePage(out);
%>

<%--  emxengchgChangeEBOMSubstituteUpdateDialogFS.jsp
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
	if (initSource == null)
	{
    initSource = "";
  }
	
 String objectId = emxGetParameter(request,"objectId");
 //stbstitute mass change
 String initSourceaa = emxGetParameter(request,"mecoFieldId");
 
  if(objectId==null || "".equals(objectId)){
	objectId = emxGetParameter(request,"objectId");
}
	String dojObjName = emxGetParameter(request,"dojObjName");
	String partId = emxGetParameter(request,"partId");
	String[] selectedObjs      = (String[])session.getAttribute("selectedObjs");
	StringBuffer contentURL = new StringBuffer("emxengchgChangeEBOMSubstituteUpdateDialog.jsp?dojObjName=" +dojObjName+"&partId="+partId);

  contentURL.append("&suiteKey=");
  contentURL.append(emxGetParameter(request,"suiteKey"));
  contentURL.append("&initSource=");
  contentURL.append(initSource)  ;
  contentURL.append("&jsTreeID=");
  contentURL.append(emxGetParameter(request,"jsTreeID"));
  contentURL.append("&objectId=");
  contentURL.append(emxGetParameter(request,"objectId"));
  contentURL.append("&Relationship=");
  contentURL.append(emxGetParameter(request,"relationship"));
  contentURL.append("&affectedaction=");
  contentURL.append(emxGetParameter(request,"affectedaction"));
  contentURL.append("&selectedType=");
  contentURL.append(emxGetParameter(request,"selectedType"));
  String HelpMarker = "emxhelpmassebomupdate";
  StringBuffer roleList = new StringBuffer("role_DesignEngineer,");
  roleList.append("role_ECRChairman,");
  roleList.append("role_ECRCoordinator,");
  roleList.append("role_ECREvaluator,");
  roleList.append("role_ManufacturingEngineer,");
  roleList.append("role_OrganizationManager,");
  roleList.append("role_PartFamilyCoordinator,");
  roleList.append("role_ProductObsolescenceManager,");
  roleList.append("role_SeniorDesignEngineer,");
  roleList.append("role_SeniorManufacturingEngineer");



  fs.initFrameset("emxEngineeringCentral.DesignTOP.MassEBOMUpdate",
                  HelpMarker,
                  contentURL.toString(),
                  false,
                  true,
                  false,
                  false);

 fs.setStringResourceFile("emxEngineeringCentralStringResource");
 fs.createFooterLink("emxFramework.Command.Done",
                      "checkInput()",
                      roleList.toString(),
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      0);


  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.closeWindow()",
                      roleList.toString(),
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      0);
  fs.writePage(out);

%>

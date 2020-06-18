<%--  emxEngrBOMManualAddExistingPartFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ include file="../emxUIFramesetUtil.inc"%>
<%@ include file="emxEngrFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.removeDialogWarning();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxEngrBOMManualAddExistingpart.jsp");


 String uiType = emxGetParameter(request, "uiType");
  

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(emxGetParameter(request,"suiteKey"));
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(emxGetParameter(request,"jsTreeID"));

  contentURL.append("&AVLReport=");
  contentURL.append(emxGetParameter(request,"AVLReport"));

  contentURL.append("&uiType=");
  contentURL.append(emxGetParameter(request,"uiType"));

  // Loop through parameters and pass on to summary page
  StringBuffer param = new StringBuffer("");
  for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();)
  {
      String name = (String) names.nextElement();

      if(name.equals("checkBox"))
      {
        String[] selPartIds = emxGetParameterValues(request, name);
        session.setAttribute("checkBox", selPartIds);
      } else {
        param.append("&");
        param.append(name);
        param.append("=");
        param.append(emxGetParameter(request, name));
        contentURL.append(param.toString());
        param.setLength(0);
      }
  }


  // Page Heading - Internationalized
  String PageHeading = "emxEngineeringCentral.EBOMManualAddExisting.WizardStep1";


  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelppartbommanualadd";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,true,false,false);
  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  if (acc.has(Access.cRead)) {

  // Role based access
  String roleList = "role_DesignEngineer,role_SeniorDesignEngineer,role_ManufacturingEngineer,role_SeniorManufacturingEngineer";
  //String roleList ="role_GlobalUser";

  fs.createFooterLink("emxFramework.Command.Next",
                      "next()",
                      roleList,
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
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

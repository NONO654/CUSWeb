<%--  emxProgramCentralFinancialCreate2of3DialogFS

  Frameset for the second page in the Financial Create dialog

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>

<%
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String suiteKey   = emxGetParameter(request,"suiteKey");
  String initSource = emxGetParameter(request,"initSource");
  String objectId   = emxGetParameter(request,"objectId");
  String costNames   = emxGetParameter(request,"costNames");
  String Directory  = appDirectory;


  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setDirectory(Directory);
  fs.setStringResourceFile("emxProgramCentralStringResource");

  if (initSource == null)
  {
    initSource = "";
  }

  // ----------------- Do Not Edit Above ------------------------------

  String cleanSession = emxGetParameter(request, "cleanSession");
  if("true".equalsIgnoreCase(cleanSession)){
    session.removeValue("selectedBenefitCategories");
    session.removeValue("benefitNames");
    session.removeValue("CreateFinancialParameters");
  }

  // refresh session objects
  java.util.Enumeration allParamterNames = emxGetParameterNames(request);
  java.util.HashMap createParams = (HashMap)session.getValue("CreateFinancialParameters");
  if (createParams == null) {
  createParams = new java.util.HashMap();
  }
  while(allParamterNames.hasMoreElements())
  {
    String name  = (String)allParamterNames.nextElement();

    if ((name.trim()).equals("costCatNames") || (name.trim()).equals("costCatLedgerNumbers") || (name.trim()).equals("costCatTypes")
      || (name.trim()).equals("costCatOptions") || (name.trim()).equals("costCatPlannedCosts")) {

    String[] values = emxGetParameterValues(request,name);
      createParams.put(name, values);

    } else if ((name.trim()).equals("benefitCatNames") || (name.trim()).equals("benefitCatLedgerNumbers") || (name.trim()).equals("benefitCatTypes")
      || (name.trim()).equals("benefitCatOptions") || (name.trim()).equals("benefitCatPlannedBenefits")) {

    String[] values = emxGetParameterValues(request,name);
      createParams.put(name, values);

    } else {
      String value =  emxGetParameter(request, name);
      createParams.put(name, value);
    }
  }
  createParams.put("isSubmitted", "false");
  session.putValue("CreateFinancialParameters", createParams);

// Specify URL to come in middle of frameset
  String contentURL = "emxProgramCentralBenefitItemCreateDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&objectId=" + objectId;


  MapList selectedBenefitCategories = (MapList)request.getAttribute("selectedBenefitCategories");
  if(selectedBenefitCategories != null) {
    session.putValue("selectedBenefitCategories", selectedBenefitCategories);
  }

  // Page Heading & Help Page
   String PageHeading = "emxProgramCentral.Financials.CreateBenefitCategories";
  String HelpMarker = "emxhelpfinancialcreatedialog";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  String previous = "emxProgramCentral.Button.Back";
  String next = "emxProgramCentral.Button.Next";
  String cancel = "emxProgramCentral.Button.Cancel";
  String delete = "emxProgramCentral.Button.Delete";
  String doneStr = "emxProgramCentral.Button.Done";
  String accessRoles = "role_GlobalUser";

  String selectBenefitItem = "emxProgramCentral.Common.SelectBenefitCategories";
  String test;
  String selectBenefitItemURL = "emxProgramCentralBenefitItemSelectorDialogFS.jsp?fieldName=BenefitNames&fieldId=BenefitIds&objectId="+objectId;
  //selectBenefitItemURL = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(selectBenefitItemURL);

  fs.createHeaderLink(selectBenefitItem, selectBenefitItemURL,"role_GlobalUser",
                      true, false, "default", 3);

  fs.createFooterLink(delete, "submitDelete()", "role_GlobalUser",
                      false, true, "default", 0);

  fs.createFooterLink(doneStr, "submitFormCreate()", accessRoles,
                      false, true, "emxUIButtonDone.gif", 0);

  fs.createFooterLink(cancel, "submitCancel()", "role_GlobalUser",
                      false, true, "emxUIButtonCancel.gif", 0);

/*
  fs.createFooterLink(previous, "backToStepOne()", "role_GlobalUser",
                      false, true, "default", 0);

  fs.createFooterLink(next, "submitStepTwo()", "role_GlobalUser",
                      false, true, "default", 0);

  fs.createFooterLink(cancel, "parent.window.closeWindow()", "role_GlobalUser",
                      false, true, "default", 0);
*/
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
%>




<%-- emxComponentsCreateCompanyDialogFS.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsCreateCompanyDialogFS.jsp.rca 1.13 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
--%>

<%@ include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<% 
String accessUsers = "role_SupplierDevelopmentManager,role_VPLMProjectLeader,role_BuyerAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  //Added for Organization feature v 11
  String companyType = emxGetParameter(request,"companyType");
  if(companyType == null || "null".equalsIgnoreCase(companyType))
  {
     companyType ="";
  }
  
  String keyCompany=emxGetParameter(request,"keyCompany");
  if(keyCompany == null)
  {
     keyCompany = formBean.newFormKey(session);
     formBean.processForm(session,request,"keyCompany");
  }

  framesetObject fs = new framesetObject();
  String Directory = appDirectory;
  fs.setDirectory(Directory);

  String initSource = (String)formBean.getElementValue("initSource");
  if (initSource == null){
    initSource = "";
  }
  
  String isSubsidiaryCreate = emxGetParameter(request,"isSubsidiaryCreate");


  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer("emxComponentsCreateCompanyDialog.jsp");
  contentURL.append("?keyCompany=").append(keyCompany);
  contentURL.append("&companyType=").append(companyType);

  String PageHeading = "emxComponents.Common.CreateCompany";
  if("Supplier".equalsIgnoreCase(companyType))
  {
     PageHeading = "emxComponents.Common.CreateSupplier";
  } 
  else if("Customer".equalsIgnoreCase(companyType))
  {
     PageHeading = "emxComponents.Common.CreateCustomer";
  }

  if ("true".equals(isSubsidiaryCreate))
  {
    PageHeading = "emxComponents.Common.CreateSubsidiary";
  }
 
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcompanycreate";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.setStringResourceFile("emxComponentsStringResource");

  fs.createCommonLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      false,
                      5);

  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      5);

  fs.writePage(out);

%>

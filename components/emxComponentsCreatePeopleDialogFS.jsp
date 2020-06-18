<%--  emxComponentsCreatePeopleDialogFS.jsp   -   Create Frameset for Person
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreatePeopleDialogFS.jsp.rca 1.18 Wed Oct 22 16:18:49 2008 przemek Experimental przemek $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  framesetObject fs = new framesetObject();
  
  String keyPerson=emxGetParameter(request,"keyPerson");
  if(keyPerson == null)
  {
     keyPerson = formBean.newFormKey(session);
     formBean.processForm(session,request,"keyPerson");
  }
  
  String initSource = (String)formBean.getElementValue("initSource");
  if (initSource == null || "null".equals(initSource)){
    initSource = "";
  }

  String Directory = appDirectory;

  fs.setDirectory(Directory);
  fs.useCache(false);

  // Specify URL to come in middle of frameset
  String contentURL = "emxComponentsCreatePeopleDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?keyPerson=" + keyPerson;

  String PageHeading = "emxComponents.CreatePeopleDialog.Step1of2SpecifyDetails";

  // Marker to pass into Help Pages, icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcreateperson1";

  boolean showNext = false;
  
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.setPageTitle(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",
          new Locale(request.getHeader("Accept-Language")), "emxComponents.CreatePersonDialog.CreatePerson"));
  
  fs.createCommonLink("emxComponents.Button.Next",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      false,
                      3);
 
  fs.createCommonLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

 fs.writePage(out);

 %>

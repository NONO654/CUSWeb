<%--  emxCreateRouteTemplateWizardDialogFS.jsp   -   Create Frameset for Route Template Wizard
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCreateRouteTemplateWizardDialogFS.jsp.rca 1.8 Wed Oct 22 16:17:59 2008 przemek Experimental przemek $
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String showmenuinToolbar     = emxGetParameter(request,"showmenuinToolbar");

  fs.setDirectory(appDirectory);
 fs.checkshowmenuinToolbar(showmenuinToolbar);

  // ----------------- Do Not Edit Above ------------------------------
  String firstTime=emxGetParameter(request,"init1");
  /*For the First time clear the Form Bean*/
  if(firstTime!=null && firstTime.equals("true"))
  {
         formBean.clear();
  }
  String keyValue=emxGetParameter(request,"keyValue");
  if(keyValue == null){
      // Begin : Bug 341297 : Code modification
      // The previously stored data should be deleted from session
      formBean.removeFormInstance(session, request);
      // End : Bug 341297 : Code modification

        keyValue = formBean.newFormKey(session);
  }
  formBean.processForm(session,request,"keyValue");

  String templateId   = emxGetParameter(request, "templateId");
  String routePreserveTaskOwner   = emxGetParameter(request, "routePreserveTaskOwner");
  if(UIUtil.isNullOrEmpty(routePreserveTaskOwner)){
	  routePreserveTaskOwner = "False";
  }

  // Specify URL to come in middle of frameset
  String contentURL = "emxCreateRouteTemplateWizardDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL +="&templateId=" + templateId+"&keyValue="+keyValue+"&firstTime="+firstTime+"&routePreserveTaskOwner="+routePreserveTaskOwner;

  fs.setStringResourceFile("emxComponentsStringResource");

  // Page Heading - Internationalized
  String PageHeading = "emxComponents.CreateRouteTemplateWizard.SpecifyDetails";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcreateroutetemplatewizard1";

  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);
  String pageTitle = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.CreateNewRouteTemplate");
  fs.setPageTitle(pageTitle);

  fs.createFooterLink("emxComponents.Button.Next",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogNext.gif",
                      3);

  fs.createFooterLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

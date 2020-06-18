<%--  emxRouteAssignTaskaDialogFS.jsp   -   Assign Tasks Frameset for Route Wizard
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteAssignTaskDialogFS.jsp.rca 1.15 Wed Oct 22 16:18:18 2008 przemek Experimental przemek $
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String portalMode = emxGetParameter(request,"portalMode");
  
  fs.setDirectory(appDirectory);

  // ----------------- Do Not Edit Above ------------------------------
  String projectId     = emxGetParameter(request, "objectId");
  String routeId       = emxGetParameter(request, "routeId");
  String sTemplateId   = emxGetParameter(request, "templateId");
  String sScopeId      = emxGetParameter(request, "scopeId");
  String sTemplateName = emxGetParameter(request, "templateName");
  String sSortName     = emxGetParameter(request, "sortName");
  String sActionName   = emxGetParameter(request, "selectedAction");
  String supplierOrgId = emxGetParameter(request,"supplierOrgId");

  if ( sSortName == null ) {
    sSortName = "false";
  }

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(128);
  contentURL.append("emxRouteAssignTaskDialog.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(projectId);
  contentURL.append("&routeId=");
  contentURL.append(routeId);
  contentURL.append("&templateId=");
  contentURL.append(sTemplateId);
  contentURL.append("&templateName=");
  contentURL.append(sTemplateName);
  contentURL.append("&sortName=");
  contentURL.append(sSortName);
  contentURL.append("&scopeId=");
  contentURL.append(sScopeId);
  contentURL.append("&selectedAction=");
  contentURL.append(sActionName);
  contentURL.append("&supplierOrgId=");
  contentURL.append(supplierOrgId);
  contentURL.append("&portalMode=");
  contentURL.append(portalMode);
  

  fs.setStringResourceFile("emxComponentsStringResource");
  // Page Heading - Internationalized
  String PageHeading = "emxComponents.AssignTasksDialog.AssignTasks";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpcreateroutewizard4";

  // PageHeading, HelpMarker, middleFrameURL, UsePrinterFriendly, IsDialogPage,
  // ShowPagination, ShowConversion
  fs.initFrameset(PageHeading, HelpMarker, contentURL.toString(), false, true,
                  false, false);
  fs.removeDialogWarning();

  fs.createCommonLink("emxComponents.Button.AddTask",
                      "addTask()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      true,
                      3);

  fs.createCommonLink("emxComponents.Button.SortTaskList",
                      "sortTaskList()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      true,
                      3);

  fs.createCommonLink("emxComponents.Button.RemoveSelected",
                      "removeSelected()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      3);

  fs.createCommonLink("emxComponents.Button.AllowDenyDelegation",
                      "AllowDelegation()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      3);

   fs.createCommonLink("emxComponents.Button.Previous",
                      "goBack()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogPrevious.gif",
                      false,
                      3);

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

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>

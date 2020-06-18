<%--  emxTeamEditAllTasksDialogFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEditAllTasksDialogFS.jsp.rca 1.14 Wed Oct 22 16:18:31 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String routeId = emxGetParameter(request,"objectId");
  String addTasks     = emxGetParameter(request,"addTasks");
  String fromPage     = emxGetParameter(request,"fromPage");
  String isRouteTemplateRevised = emxGetParameter(request,"isRouteTemplateRevised");
  
  //Added for IR-043896V6R2011
     String newTaskIds                      = emxGetParameter(request,"newTaskIds");
  //Addition ends for IR-043896V6R2011

  fs.setDirectory(appDirectory);
  fs.useCache(false);

  String strTaskEditSetting   = null;  

  String sTypeRoute          = PropertyUtil.getSchemaProperty(context, "type_Route");
  String sTypeRouteTemplate  = PropertyUtil.getSchemaProperty(context, "type_RouteTemplate");

  // Page Heading - Internationalized
  String PageHeading = "";

  DomainObject boRoute  = new DomainObject(routeId);
  boRoute.open(context);
  String sType = boRoute.getTypeName();
  String sName = boRoute.getName();
  boRoute.close(context);

  if (sTypeRoute.equals(sType)) {
    PageHeading = "emxComponents.EditAllTasks.Step1";
  } else if (sTypeRouteTemplate.equals(sType)) {
    PageHeading = "emxComponents.EditAllTasks.Heading";
  }

  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(256);
  if(sType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
  {
      contentURL.append("emxEditRouteTemplateAllTasksDialog.jsp");
  }
  else
  {
      contentURL.append("emxEditAllTasksDialog.jsp");
  }

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(routeId);
  ////Added for IR-043896V6R2011
  contentURL.append("&addTasks=");
  contentURL.append(addTasks);
  contentURL.append("&fromPage=");
  contentURL.append(fromPage);
  contentURL.append("&newTaskIds=");
  contentURL.append(newTaskIds);
  contentURL.append("&isRouteTemplateRevised=");
  contentURL.append(isRouteTemplateRevised);
	  
   //Addition ends for IR-043896V6R2011
  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpeditalltasks1";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  strTaskEditSetting = boRoute.getAttributeValue(context,DomainObject.ATTRIBUTE_TASKEDIT_SETTING);

  fs.setStringResourceFile("emxComponentsStringResource");

   if (strTaskEditSetting !=null){
        if(strTaskEditSetting.equals("Modify/Delete Task List") || sType.equals(DomainObject.TYPE_ROUTE_TEMPLATE)){
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
                            "showDeleteSelected()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            false,
                            3);
                
                
                fs.createCommonLink("emxComponents.Common.AssignSelected",
                        "AssignSelected()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        false,
                        3);
        }
        else if(strTaskEditSetting.equals("Extend Task List") || strTaskEditSetting.equals("Modify Task List"))
        {
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
                
                fs.createCommonLink("emxComponents.Common.AssignSelected",
                        "AssignSelected()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        false,
                        3);

        }
        else if(sTypeRoute.equals(sType) && strTaskEditSetting.equals("Maintain Exact Task List"))
        {
            fs.setMenu(new HashMap(), fs.getNameRoot() + "_top_menu");
        }
        else
        {
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

                  fs.createCommonLink("emxComponents..Button.RemoveSelected",
                            "showDeleteSelected()",
                            "role_GlobalUser",
                            false,
                            true,
                            "default",
                            false,
                            3);
                  
                  fs.createCommonLink("emxComponents.Common.AssignSelected",
                          "AssignSelected()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          false,
                          3);
        } 
  }
   else
  {

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
                      "showDeleteSelected()",
                      "role_GlobalUser",
                      false,
                      true,
                      "default",
                      false,
                      3);
        
        fs.createCommonLink("emxComponents.Common.AssignSelected",
                "AssignSelected()",
                "role_GlobalUser",
                false,
                true,
                "default",
                false,
                3);
  }
 


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
  fs.removeDialogWarning();
  fs.writePage(out);
%>


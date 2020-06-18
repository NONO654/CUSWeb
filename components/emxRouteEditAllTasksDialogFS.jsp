<%--  emxRouteEditAllTasksDialogFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteEditAllTasksDialogFS.jsp.rca 1.12 Wed Oct 22 16:18:38 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null)
    initSource = "";

  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String routeId = emxGetParameter(request,"objectId");

  fs.setDirectory(appDirectory);
  fs.useCache(false);

  String sSortName    = emxGetParameter(request,"sortName");
  String isTemplate   = emxGetParameter(request,"isTemplate");
  String addTasks     = emxGetParameter(request,"addTasks");
  String fromPage     = emxGetParameter(request,"fromPage");

  String isPreviousPage=emxGetParameter(request,"previous");


  String strTaskEditSetting   = null;

  if (sSortName == null)
    sSortName="";

  String slctdd = emxGetParameter(request,"slctdd");
  String slctmm = emxGetParameter(request,"slctmm");
  String slctyy = emxGetParameter(request,"slctyy");

  String newTaskIds = emxGetParameter(request,"newTaskIds");


  // Page Heading - Internationalized
  String PageHeading = "";

  Route route = (Route)DomainObject.newInstance(context,routeId);
  String templateId=(String)route.getInfo(context,
                                          route.SELECT_ROUTE_TEMPLATE_ID);

  if ((templateId != null) && (!templateId.equals("")))
  {
	strTaskEditSetting   = getTaskSetting(context,templateId);
  }

 if (strTaskEditSetting == null)
    strTaskEditSetting = "";

  PageHeading = "emxComponents.EditAllTasks.Step1";

  // Specify URL to come in middle of frameset

  StringBuffer contentURL = new StringBuffer(256);
  contentURL.append("emxRouteEditAllTasksDialog.jsp");


  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&initSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(routeId);
  contentURL.append("&sortName=");
  contentURL.append(sSortName);
  contentURL.append("&slctdd=");
  contentURL.append(slctdd);
  contentURL.append("&slctmm=");
  contentURL.append(slctmm);
  contentURL.append("&slctyy=");
  contentURL.append(slctyy);
  contentURL.append("&isTemplate=");
  contentURL.append(isTemplate);
  contentURL.append("addTasks=");
  contentURL.append(addTasks);
  contentURL.append("&fromPage=");
  contentURL.append(fromPage);
  contentURL.append("&newTaskIds=");
  contentURL.append(newTaskIds);

  if(UIUtil.isNotNullAndNotEmpty(isPreviousPage)){
	contentURL.append("&previous=");
	contentURL.append(isPreviousPage);
  }

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  // marker to pass into help Pages, icon launches new window with help frameset inside
  String HelpMarker = "emxhelpeditalltasks1";

  // (String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,false,false);

  fs.setStringResourceFile("emxComponentsStringResource");
  StringList sVPLMRoleList = new StringList(4);
  sVPLMRoleList.addElement("VPLMAdmin");
  sVPLMRoleList.addElement("VPLMViewer");
  sVPLMRoleList.addElement("VPLMProjectLeader");
  sVPLMRoleList.addElement("VPLMCreator");
  sVPLMRoleList.addElement("Project Lead");
  sVPLMRoleList.addElement("Project User");
  String roles = PersonUtil.getVPLMChildrenRoleList(context, sVPLMRoleList); 
  roles = roles.concat(",role_Employee,role_ExchangeUser,role_CompanyRepresentative"); 
  
  if(strTaskEditSetting.equals("Modify/Delete Task List") || strTaskEditSetting.equals("Modify Task List") || strTaskEditSetting.equals("Extend Task List")){
      fs.createCommonLink("emxComponents.Button.AddTask",
                          "addTask()",
                          roles,
                          false,
                          true,
                          "default",
                          true,
                          3);

      fs.createCommonLink("emxComponents.Button.SortTaskList",
                          "sortTaskList()",
                          roles,
                          false,
                          true,
                          "default",
                          true,
                          3);

      fs.createCommonLink("emxComponents.Button.RemoveSelected",
                          "showDeleteSelected()",
                          roles,
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
    else if(strTaskEditSetting.equals("Maintain Exact Task List")){
        
    	fs.setMenu(new HashMap(), fs.getNameRoot() + "_top_menu");
     }
     else
     {
          fs.createCommonLink("emxComponents.Button.AddTask",
                              "addTask()",
                              roles,
                              false,
                              true,
                              "default",
                              true,
                              3);

          fs.createCommonLink("emxComponents.Button.SortTaskList",
                              "sortTaskList()",
                              roles,
                              false,
                              true,
                              "default",
                              true,
                              3);

          fs.createCommonLink("emxComponents.Button.RemoveSelected",
                              "showDeleteSelected()",
                              roles,
                              false,
                              true,
                              "default",
                              false,
                              3);
          fs.createCommonLink("emxComponents.Common.AssignSelected",
                        "AssignSelected()",
                        roles,
                        false,
                        true,
                        "default",
                        false,
                        3);
  
      }
    fs.createCommonLink("emxComponents.Button.Next",
                          "submitForm()",
                          roles,
                          false,
                          true,
                          "common/images/buttonDialogNext.gif",
                          false,
                          3);

    fs.createCommonLink("emxComponents.Button.Cancel",
                        "closeWindow()",
                        roles,
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        false,
                        3);
    fs.removeDialogWarning();
    fs.writePage(out);
  %>

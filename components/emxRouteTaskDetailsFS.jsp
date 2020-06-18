<%--  emxRouteTaskDetailsFS.jsp   -   Display Details of Tasks
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxRouteTaskDetailsFS.jsp.rca 1.20 Wed Oct 22 16:18:05 2008 przemek Experimental przemek $"
--%>
<%@ include file = "../emxUIFramesetUtil.inc"%>
<%@include file  = "emxRouteInclude.inc"%>

<%
  DomainObject domainObject = DomainObject.newInstance(context);
  InboxTask task = (InboxTask)DomainObject.newInstance(context,DomainConstants.TYPE_INBOX_TASK);
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.useCache(false);

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String routeId      = emxGetParameter(request,"routeId");
  String taskId       = emxGetParameter(request,"taskId");
  String routeNodeId  = emxGetParameter(request,"routeNodeId");
  String taskCreated  = emxGetParameter(request,"taskCreated");
  String routeOwner   = "";
  String taskState    = "";
  String sTaskTitle   = "";
  String sAttrTitle   = PropertyUtil.getSchemaProperty(context, "attribute_Title");

  boolean isAssignedToGroupOrRole = false;

  if(routeId!=null)  {
    fs.setObjectId(routeId);
    domainObject.setId(routeId);
    routeOwner = domainObject.getInfo(context, domainObject.SELECT_OWNER);
  }

  String PageHeading = "emxComponents.Task.Properties";

  if(taskCreated.equals("yes") && taskId != null && !taskId.equals("")) {
    PageHeading = "emxComponents.Task.Properties";
    fs.setObjectId(taskId);
    //domainObject.setId(taskId);
    task.setId(taskId);
    BusinessObject boTask = new BusinessObject(taskId);
    boTask.open(context);
    sTaskTitle  = FrameworkUtil.getAttribute(context,task,sAttrTitle);


    isAssignedToGroupOrRole = task.checkIfTaskIsAssignedToGroupOrRole(context);

    boTask.close(context);
    if ( sTaskTitle.equals("") ) {
      PageHeading = "emxComponents.Task.Properties";
    }

    taskState  = task.getInfo(context, task.SELECT_CURRENT);
  } else if(taskCreated.equals("no") && routeNodeId != null && !routeNodeId.equals("")) {
   // fs.setObjectId(routeNodeId);
  }

  String person = context.getUser();
  boolean isRouteOwner = false;
  //BNC - AGR code
  if(routeOwner.equals(person)) {
    isRouteOwner = true;
  }

  String contentURL = "emxRouteTaskDetails.jsp";

  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&routeId=" + routeId + "&taskCreated=" + taskCreated + "&routeNodeId=" + routeNodeId + "&taskId=" + taskId;

  String HelpMarker  = "emxhelptaskproperties";


  fs.setStringResourceFile("emxComponentsStringResource");

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,false,false);

  fs.removeDialogWarning();
  // show the edit link only if the logged in person is the Route owner
  // and only if the task state is not Complete (is in Assigned state if task is created)
  if((isRouteOwner) && (taskState.equals("") || taskState.equals("Assigned")))
  {
    fs.createCommonLink("emxComponents.Button.EditDetails",
                        "showEditDialogPopup()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        true,
                        3);
  }

  fs.createCommonLink("emxComponents.Button.Close",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      false,
                      3);

  fs.writePage(out);
%>

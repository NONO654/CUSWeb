<%--  emxRouteContentSummaryFS.jsp  -   Frameset for Attached Documents
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteContentSummaryFS.jsp.rca 1.21 Wed Oct 22 16:18:39 2008 przemek Experimental przemek $
--%>


<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<jsp:useBean id="emxCommonRouteContentSummaryFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  Route route = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  String tableBeanName = "emxCommonRouteContentSummaryFS";
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  fs.useCache(false);

  String initSource = emxGetParameter(request,"initSource");
  String objectId      = emxGetParameter(request,"objectId");
  String isFromTask = emxGetParameter(request,"isFromTask");
  String isFromDialog = emxGetParameter(request,"isFromDialog");
  if(isFromDialog == null) {
    isFromDialog = "";
  }

  if (isFromTask == null || "null".equals(isFromTask))
  {
    isFromTask = "";
  }

  if(isFromTask.equals("true"))
  {
    String selectStr = "from["+DomainConstants.RELATIONSHIP_ROUTE_TASK+"].to.id";
    DomainObject taskObject = DomainObject.newInstance(context,objectId);
    objectId = taskObject.getInfo(context,selectStr);
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  if (initSource == null){
    initSource = "";
  }

  StringBuffer contentURL = new StringBuffer(128);
  contentURL.append("emxRouteContentSummary.jsp");
  contentURL.append("?suiteKey=");
  contentURL.append(suiteKey);
  contentURL.append("&iitSource=");
  contentURL.append(initSource);
  contentURL.append("&jsTreeID=");
  contentURL.append(jsTreeID);
  contentURL.append("&objectId=");
  contentURL.append(objectId);
  contentURL.append("&isFromTask=");
  contentURL.append(isFromTask);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);


  String PageHeading = "emxComponents.ContentSummary.Content";
  String HelpMarker = "emxhelproutecontent";

  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),true,false,true,false);

  fs.setStringResourceFile("emxComponentsStringResource");
  fs.setObjectId(objectId);
  fs.setBeanName(tableBeanName);

  route.setId(objectId);
  String sOwner       = route.getInfo(context, route.SELECT_OWNER);
  String sState = route.getInfo(context,route.SELECT_CURRENT);
  boolean isRouteEditable = true;

  // Do not show links if the Route State is Complete or Archive
  if(sState.equals("Complete") || sState.equals("Archive")){
     isRouteEditable = false;
  }
   boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
   boolean bProgram = FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);

   route.open(context);
   Access contextAccess = route.getAccessMask(context);
   route.close(context);

  // show these links only to the route owner
  if ( (sOwner.equals(context.getUser()) && isRouteEditable && !isFromTask.equals("true")) && (AccessUtil.hasAddAccess(contextAccess)) ){

    fs.createCommonLink("emxComponents.Common.AddContent",
                          "AddContent()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          3);
       if(bTeam || bProgram){

            fs.createCommonLink("emxComponents.Common.Upload",
                        "uploadExternalFile()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        true,
                        3);
        }
  }
 if ( sOwner.equals(context.getUser()) && isRouteEditable && !isFromTask.equals("true")){
    fs.createCommonLink("emxComponents.EditContent.EditStateBlock",
                          "editBlockState()",
                          "role_GlobalUser",
                          false,
                          true,
                          "default",
                          true,
                          5);
}
 if ( sOwner.equals(context.getUser()) && isRouteEditable && !isFromTask.equals("true")){
 	 
        if(AccessUtil.hasRemoveAccess(contextAccess))
        {
                fs.createCommonLink("emxComponents.Button.RemoveSelected",
                        "removeSelected()",
                        "role_GlobalUser",
                        false,
                        true,
                        "default",
                        false,
                        3);
        }
}

  if(isFromTask.equals("true") && isFromDialog.equals("true"))
  {
    fs.createCommonLink("emxComponents.Button.Close",
                         "window.closeWindow()",
                         "role_GlobalUser",
                         false,
                         true,
                         "../common/images/buttonDialogCancel.gif",
                         false,
                         3);
  }
  fs.removeDialogWarning();
  fs.writePage(out);
%>

 <%--  emxRouteSelectProjectMembersFS.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $ Exp $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<jsp:useBean id  = "emxRouteSelectProjectMembersFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String formKey = emxGetParameter(request, "formKey");
  String keyValue = emxGetParameter(request, "keyValue");
  String flag              = emxGetParameter(request,"flag");
  String chkSubscribeEvent = emxGetParameter(request,"chkSubscribeEvent");

  /*Quick Route Creation Start */
   String fromPage=emxGetParameter(request,"fromPage");
   if(fromPage==null)
   {
       fromPage="";
   }
/*Quick Route Creation End*/
  String tableBeanName = "emxRouteSelectProjectMembersFS";
  framesetObject fs = new framesetObject();
  fs.useCache(false);
  fs.setDirectory(appDirectory);

  fs.setBeanName(tableBeanName);

  fs.setStringResourceFile("emxComponentsStringResource");

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  // ----------------- Do Not Edit Above ------------------------------


  String hasTarget      = emxGetParameter(request, "hasTarget");
  String selectMultiple = emxGetParameter(request, "multiSelect");
  String projectId   = emxGetParameter(request,"projectId");
  hasTarget      = (hasTarget != null) ? hasTarget : "false";


String routeId   = emxGetParameter(request,"routeId");
String memberType   = emxGetParameter(request,"memberType");

  //Set contentURL
  String contentURL = "";

 contentURL = "emxRouteSelectProjectMembers.jsp?hasTarget=" + hasTarget + "&selectMultiple=" + selectMultiple+"&projectId="+projectId+"&beanName=" + tableBeanName+"&keyValue="+keyValue+"&routeId="+routeId+"&memberType="+memberType+"&flag="+flag+"&chkSubscribeEvent="+chkSubscribeEvent;
 contentURL+="&fromPage="+fromPage;

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpsearchresults";
  String PageHeading = "emxComponents.AddPeople.SelectPeople";

  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //Only display the done button if page calling search expects values to be returned
  if ("true".equalsIgnoreCase(hasTarget)) {
    fs.createCommonLink("emxComponents.Button.Done", "pageSubmition()", "role_GlobalUser",
                        false, true, "common/images/buttonDialogDone.gif", false, 3);
  }

  fs.createCommonLink("emxComponents.Button.Cancel", "window.closeWindow()", "role_GlobalUser",
                      false, true, "common/images/buttonDialogCancel.gif", false, 5);

  // ----------------- Do Not Edit Below ------------------------------
  fs.writePage(out);
%>
<html>
</html>

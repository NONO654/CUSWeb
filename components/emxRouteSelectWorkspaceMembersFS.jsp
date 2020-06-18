<%--  emxRouteSelectWorkspaceMembersFS.jsp   - Display Frameset for Add Members
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteSelectWorkspaceMembersFS.jsp.rca 1.11 Wed Oct 22 16:17:55 2008 przemek Experimental przemek $
--%>


<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<jsp:useBean id  = "emxRouteSelectWorkspaceMembersFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
  String keyValue = emxGetParameter(request, "keyValue");

  framesetObject fs = new framesetObject();
  String tableBeanName = "emxRouteSelectWorkspaceMembersFS";
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");

  String Directory = appDirectory;

  fs.setDirectory(Directory);

  // Specify URL to come in middle of frameset

  String projectId         = emxGetParameter(request,"projectId");
  String sRouteId          = emxGetParameter(request, "routeId");
  String firstPersonName   = emxGetParameter(request, "firstName");
  String lastPersonName    = emxGetParameter(request, "lastName");
  String role              = emxGetParameter(request, "role");
  String flag              = emxGetParameter(request,"flag");
  String chkSubscribeEvent = emxGetParameter(request,"chkSubscribeEvent");
  String objectId          = emxGetParameter(request,"objectId");
  String strnoSearch       = emxGetParameter(request,"noSearch");
  String strCompany        = emxGetParameter(request,"company");
  String sfromPage         = emxGetParameter(request,"fromPage");
  String userName          = emxGetParameter(request,"userName");
  String searchFlag        = emxGetParameter(request,"searchFlag");
  //searchFlag

  String contentURL = "emxRouteSelectWorkspaceMembers.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&projectId="+projectId+"&routeId="+sRouteId;
  contentURL += "&firstName="+firstPersonName+"&lastName="+lastPersonName+"&role="+role;
  contentURL += "&flag="+flag+"&chkSubscribeEvent="+chkSubscribeEvent+"&objectId="+objectId;
  contentURL += "&beanName=" + tableBeanName + "&noSearch=" + strnoSearch + "&company=" + strCompany;
  contentURL += "&userName=" + userName + "&searchFlag=" + searchFlag+"&fromPage="+sfromPage;
  contentURL += "&firstName="+firstPersonName+"&lastName="+lastPersonName+"&chkSubscribeEvent="+chkSubscribeEvent;
  contentURL +=  "&company=" + strCompany+"&fromPage="+sfromPage+"&objectId="+objectId;
  contentURL += "&userName=" + userName+"&beanName="+tableBeanName +"&keyValue=" + keyValue;


  

  fs.setBeanName(tableBeanName);

  String PageHeading = "emxComponents.AddPeople.SelectPeople";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpaddworkspacemembersforroute";

  contentURL = Framework.encodeURL(response,contentURL);
  //(String pageHeading,String helpMarker, String middleFrameURL, boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination, boolean ShowConversion)
  fs.initFrameset(PageHeading,HelpMarker,contentURL,false,true,true,false);

  fs.setStringResourceFile("emxComponentsStringResource");

  //(String displayString,String href,String roleList, boolean popup, boolean isJavascript,String iconImage, int WindowSize (1 small - 5 large))


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

  fs.removeDialogWarning();
  fs.writePage(out);
%>

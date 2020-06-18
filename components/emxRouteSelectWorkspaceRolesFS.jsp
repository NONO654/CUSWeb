<%-- emxRouteSelectWorkspaceRolesFS.jsp -- Frameset for Role Search Result page
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSelectWorkspaceRolesFS.jsp.rca 1.8 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<jsp:useBean id  = "emxRouteSelectWorkspaceRolesFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
  String keyValue = emxGetParameter(request, "keyValue");
  framesetObject fs = new framesetObject();
  String tableBeanName = "emxRouteSelectWorkspaceRolesFS";

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null)
  {
    initSource = "";
  }

  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");

  String projectId   = emxGetParameter(request, "projectId");
  String routeId     = emxGetParameter(request, "routeId");
  String objectId    = emxGetParameter(request, "objectId");

  String txtRoleName = emxGetParameter(request,"txtRoleName");
  String sTopChecked = emxGetParameter(request,"chkTopLevel");
  String sSubChecked = emxGetParameter(request,"chkSubLevel");

  String roleList        = emxGetParameter(request, "roleList");
  String fromPage        = emxGetParameter(request, "fromPage");

  if (roleList == null){
    roleList = "";
  }

  if(fromPage==null)
  {
        fromPage="";
  }

  String Directory = appDirectory;
  fs.setDirectory(Directory);

  String contentURL = "emxRouteSelectWorkspaceRoles.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID;
  contentURL += "&projectId="+projectId+"&routeId="+routeId+"&objectId="+objectId;
  contentURL += "&txtRoleName="+txtRoleName+"&chkTopLevel="+sTopChecked+"&chkSubLevel="+sSubChecked;
  contentURL += "&roleList=" + roleList;
  contentURL += "&beanName=" + tableBeanName + "&keyValue=" + keyValue;
  contentURL += "&fromPage="+fromPage;

  fs.setBeanName(tableBeanName);

  String PageHeading = "emxComponents.AddRoles.SelectRoles";

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelpselectroles";
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

<%--  emxRouteSelectProjectRolesOrGroupsFS.jsp   -   Create Frameset for Quick Route Create
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $ Exp $
--%>
<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<jsp:useBean id  = "emxRouteSelectProjectRolesOrGroupsFS" class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%

  String keyValue = emxGetParameter(request, "keyValue");
  String tableBeanName = "emxRouteSelectProjectRolesOrGroupsFS";
  String projectId = emxGetParameter(request,"projectId");
  String memberType = emxGetParameter(request,"memberType");
  String routeId   = emxGetParameter(request,"routeId");
    /*Quick Route Creation Start */
   String fromPage=emxGetParameter(request,"fromPage");
   if(fromPage==null)
   {
       fromPage="";
   }
/*Quick Route Creation End*/


  // Specify URL to come in middle of frameset
  StringBuffer contentURL = new StringBuffer(175);
  contentURL.append("emxRouteSelectProjectRolesOrGroups.jsp");

  // add these parameters to each content URL, and any others the App needs
  contentURL.append("?projectId=");
  contentURL.append(projectId);
  contentURL.append("&memberType=");
  contentURL.append(memberType);
  contentURL.append("&beanName=");
  contentURL.append(tableBeanName);
  contentURL.append("&keyValue=");
  contentURL.append(keyValue);
  contentURL.append("&routeId=");
  contentURL.append(routeId);
  contentURL.append("&fromPage=");
  contentURL.append(fromPage);


  framesetObject fs = new framesetObject();
  fs.setStringResourceFile("emxComponentsStringResource");

  // Page Heading - Internationalized
  String PageHeading = "";
  if (memberType.equals("Role"))
	PageHeading = "emxComponents.AddRoles.SelectRoles";
  if (memberType.equals("Group"))
	PageHeading = "emxComponents.AddGroups.SelectGroups";


  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "emxhelproutecreatewiz";

  fs.setBeanName(tableBeanName);
  fs.initFrameset(PageHeading,HelpMarker,contentURL.toString(),false,true,true,false);

  fs.createFooterLink("emxComponents.Button.Done",
                      "submitForm()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogDone.gif",
                      3);

  fs.createFooterLink("emxComponents.Button.Cancel",
                      "closeWindow()",
                      "role_GlobalUser",
                      false,
                      true,
                      "common/images/buttonDialogCancel.gif",
                      3);

  fs.writePage(out);
%>

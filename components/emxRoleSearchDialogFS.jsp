<%--  emxRoleSearchDialogFS.jsp -  Search role dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>


<%
  String objectId = emxGetParameter(request,"objectId");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect = emxGetParameter(request,"multiSelect");

  String parentForm  = emxGetParameter(request,"form");
  String parentField = emxGetParameter(request,"field");
  String idField = emxGetParameter(request,"idfield");
  String callPage = emxGetParameter(request,"callPage");
  String mainSearchPage   = emxGetParameter(request,"mainSearchPage");
  String txtName   = emxGetParameter(request,"txtName");
  String chkTopLevel      = emxGetParameter(request,"chkTopLevel");
  String chkSubLevel      = emxGetParameter(request,"chkSubLevel");

  String strOrgId         = emxGetParameter(request,"orgId");
  if(strOrgId == null || "null".equals(strOrgId))
  {
    strOrgId = "";
  }

  // Only one line added - Nishchal
  String keyValue=emxGetParameter(request,"keyValue");

  String searchMessage = "";

  // Modified the page heading - Nishchal
  if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
  {
      searchMessage = "emxComponents.AddRoles.SearchRoles";
  }
  else
  {
      searchMessage = "emxComponents.AddMembers.SelectRole";
  }

  // Added keyvalue parameter to the url - Nishchal
  // add these parameters to each content URL, and any others the App needs
  String params = "?objectId=" + objectId + "&searchMessage=" + searchMessage + "&targetSearchPage=" + targetSearchPage;
  params += "&form=" + parentForm + "&field=" + parentField + "&idfield=" + idField;
  params += "&multiSelect=" + multiSelect+"&callPage="+callPage+"&mainSearchPage="+mainSearchPage+"&txtName="+txtName+"&chkTopLevel="+chkTopLevel+"&chkSubLevel="+chkSubLevel;
  params += "&orgId=" + strOrgId+"&keyValue="+keyValue;

  // Specify URL to come in middle of frameset
  String contentURL = "../components/emxComponentsSearchRolesDialog.jsp" + params;
  String searchRoleContentURL = "../components/emxComponentsSearchRolesDialog.jsp" + params;

  searchFramesetObject fs = new searchFramesetObject();

  fs.setStringResourceFile("emxComponentsStringResource");

  // Search Heading - Internationalized
  String searchHeading = "emxFramework.Suites.Display.Common";

  fs.setDirectory(appDirectory);
  fs.setHelpMarker("emxhelpsearchroles");

  fs.initFrameset(searchMessage,contentURL,searchHeading,false);

  //  createSearchLink(String displayString,String href, String roleList){
  String roleList = "role_GlobalUser";

  fs.createSearchLink("emxComponents.AddMembers.SelectRole", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchRoleContentURL), roleList);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

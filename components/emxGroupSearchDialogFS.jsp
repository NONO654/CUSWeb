<%--  emxGroupSearchDialogFS.jsp -  Search group dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

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

  // Only one line added - Nishchal
  String keyValue=emxGetParameter(request,"keyValue");

  // Modified the page heading - Nishchal
  String searchMessage = "";
  if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
  {
      searchMessage = "emxComponents.AddGroups.SearchGroups";
  }
  else
  {
      searchMessage = "emxComponents.AddMembers.SelectGroup";
  }


  // Added keyvalue parameter to the url - Nishchal
  // add these parameters to each content URL, and any others the App needs
  String params = "?objectId=" + objectId + "&searchMessage=" + searchMessage + "&targetSearchPage=" + targetSearchPage;
  params += "&form=" + parentForm + "&field=" + parentField + "&idfield=" + idField;
  params += "&multiSelect=" + multiSelect+"&callPage="+callPage+"&mainSearchPage="+mainSearchPage+"&txtName="+txtName+"&chkTopLevel="+chkTopLevel+"&chkSubLevel="+chkSubLevel+"&keyValue="+keyValue;

  // Specify URL to come in middle of frameset
  String contentURL = "../components/emxComponentsSearchGroupsDialog.jsp" + params;
  String searchGroupContentURL = "../components/emxComponentsSearchGroupsDialog.jsp" + params;
  searchFramesetObject fs = new searchFramesetObject();

  fs.setStringResourceFile("emxComponentsStringResource");

  // Search Heading - Internationalized
  String searchHeading = "emxFramework.Suites.Display.Common";

  fs.setDirectory(appDirectory);
  fs.setHelpMarker("emxhelpselectuser");

  fs.initFrameset(searchMessage,contentURL,searchHeading,false);

  //  createSearchLink(String displayString,String href, String roleList){
  String roleList = "role_GlobalUser";

  fs.createSearchLink("emxComponents.AddMembers.SelectGroup", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchGroupContentURL), roleList);

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>

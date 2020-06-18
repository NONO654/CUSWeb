 <%--  emxRouteContentSearchDialogFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxRouteInclude.inc"%>


<%
  // ----------------- Do Not Edit Above ------------------------------

  String objectId = emxGetParameter(request,"objectId");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect  = emxGetParameter(request,"multiSelect");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String portalMode   = emxGetParameter(request,"portalMode");

  String page1Heading = "emxComponents.ContentSearch.Page1Heading";
  String findContent = "emxComponents.ContentSearch.FindContent";
  String searchHeading = "emxFramework.Suites.Display.Common";

  // Specify URL to come in middle of frameset
  String contentURL = "../components/emxRouteContentSearchDialog.jsp";

  // add these parameters to each content URL, and any others the App needs
  contentURL += "?objectId=" + objectId + "&targetSearchPage=" + targetSearchPage + "&multiSelect=" + multiSelect + "&suiteKey=" + XSSUtil.encodeForURL(context, suiteKey) + "&portalMode=" + portalMode;


  searchFramesetObject fs = new searchFramesetObject();
  fs.setDirectory(appDirectory);
  fs.setHelpMarker("emxhelpfindcontentroute");
  fs.setStringResourceFile("emxComponentsStringResource");

  fs.initFrameset(page1Heading,contentURL,searchHeading,false);

  //  createSearchLink(String displayString,String href, String roleList){
  String roleList = "role_GlobalUser";


  fs.createSearchLink(findContent, com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);
  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);

%>






 <%--  SearchGroupsFS.jsp  -  Search dialog frameset

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<%

  String strFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
  String strFieldNameActual = emxGetParameter(request,"fieldNameActual");
  String strParentForm = emxGetParameter(request,"formName");
  String strParentFrame = emxGetParameter(request,"frameName");
  String parentGroup = emxGetParameter(request,"parentGroup");

  if (parentGroup == null || parentGroup.equals("null") || parentGroup.equals("")){
      parentGroup = "";
  }

  String searchMessage = "emxProduct.Heading.Search";

  // Specify URL to come in middle of frameset
  String contentURL = "SearchGroupsDialog.jsp";
  // add these parameters to each content URL, and any others the App needs
  contentURL += "?parentGroup=" + parentGroup + "&dir="+ appDirectory;
  contentURL += "&formName="+ strParentForm + "&frameName="+ strParentFrame;
  contentURL += "&fieldNameDisplay="+ strFieldNameDisplay + "&fieldNameActual="+ strFieldNameActual;
  searchFramesetObject fs = new searchFramesetObject();

  // Search Heading - Internationalized
  String searchHeading = "emxProduct.Tab.Label.Product";
  fs.initFrameset(searchMessage,contentURL,searchHeading,false);

  fs.setDirectory(appDirectory);
  fs.setHelpMarker("emxhelpselectuser");
  fs.setStringResourceFile("emxProductLineStringResource");
  // TODO!
  // Narrow this list and add access checking
  //
  String roleList = "role_GlobalUser";

  fs.createSearchLink("emxProduct.ActionLink.FindGroups", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL), roleList);
  fs.writePage(out);

%>

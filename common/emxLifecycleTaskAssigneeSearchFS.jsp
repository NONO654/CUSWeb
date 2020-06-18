<%--  emxLifecycleTaskAssigneeSearchFS.jsp   -   Assignee Search FS

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

--%>

<%@include file  =  "../emxUIFramesetUtil.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>
<%
	String objectId 	= emxGetParameter(request,"objectId");
	
	String strHidePersonSearch = emxGetParameter(request,"hidePersonSearch");
	String strHideRoleSearch   = emxGetParameter(request,"hideRoleSearch");
	String strHideGroupSearch  = emxGetParameter(request,"hideGroupSearch");
	
	if (strHidePersonSearch == null || "".equals(strHidePersonSearch) || "null".equals(strHidePersonSearch)) {
	    strHidePersonSearch = "false";
	}
	if (strHideRoleSearch == null || "".equals(strHideRoleSearch) || "null".equals(strHideRoleSearch)) {
	    strHideRoleSearch = "false";
	}
	if (strHideGroupSearch == null || "".equals(strHideGroupSearch) || "null".equals(strHideGroupSearch)) {
	    strHideGroupSearch = "false";
	}
	
  String contentURL = "emxLifecycleTaskAssigneeSearchDialog.jsp";
  
  contentURL += "?objectId=" + objectId +"&hidePersonSearch="+strHidePersonSearch+"&hideRoleSearch="+strHideRoleSearch+"&hideGroupSearch="+strHideGroupSearch;
  
  searchFramesetObject fs = new searchFramesetObject();
 
  String appDir = EnoviaResourceBundle.getProperty(context, "eServiceSuiteComponents.Directory");
  if(appDir == null || "".equals(appDir) || "null".equals(appDir)){
	appDir = "components";
  }
  
  // Variable retrieved from emxCompCommonUtilAppInclude.inc - value : common
  
  fs.setDirectory(appDirectory);
  
  fs.setStringResourceFile("emxFrameworkStringResource");
  String searchHeading = "emxFramework.Suites.Display.Common";
  String searchMessage = "emxFramework.SelectPeople.Step1Heading";
  
  fs.initFrameset(searchMessage,contentURL + "&searchType=Person",searchHeading,false);
  
  fs.setHelpMarker("emxhelpselectuser");
  String roleList = "role_GlobalUser";
  
  if ("false".equalsIgnoreCase(strHidePersonSearch)) {
  	fs.createSearchLink("emxFramework.SelectPeople.SelectPerson", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL + "&searchType=Person"), roleList);
  }
  if ("false".equalsIgnoreCase(strHideRoleSearch)) {
  	fs.createSearchLink("emxFramework.SelectPeople.SelectRole", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL + "&searchType=Role"), roleList);
  }
  if ("false".equalsIgnoreCase(strHideGroupSearch)) {
	fs.createSearchLink("emxFramework.SelectPeople.SelectGroup", com.matrixone.apps.domain.util.XSSUtil.encodeForURL(contentURL + "&searchType=Group"), roleList); 
  }
  
  fs.writePage(out);
%>

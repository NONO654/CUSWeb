<%-- This page is used to Reactivate an archived Workspace

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "eServiceUtil.inc"%>
<%@ include file  = "emxTeamUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String projectId = emxGetParameter(request, "objectId");

	//When opened from Designer Central, the objectId parameter is not sent, instead projectId is passed.
	if (projectId == null) {
	    projectId = emxGetParameter(request, "projectId");	    
	}

  BusinessObject busProject = new BusinessObject(projectId);
  busProject.open(context);

  // Demote the project back to the "Active" state to make it an active project
  // Requires 2 demote(context)s to move to "Active" from "Archive"
  String stateActive        = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_PROJECT, "state_Active");
  while (!FrameworkUtil.getCurrentState(context, busProject).getName().equals(stateActive))
  {
    busProject.demote(context);
  }
  busProject.close(context);
%>

<form name="newFor"m target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>"/>
</form>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
  <script language="javascript">
  getTopWindow().emxUICategoryTab.reloadTabs(getTopWindow().emxUICategoryTab.catObj);
    parent.window.location.href=parent.window.location.href;
  if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
		getTopWindow().opener.getTopWindow().RefreshHeader();      
	}else if(getTopWindow().RefreshHeader){
		getTopWindow().RefreshHeader();     
	}
  </script>

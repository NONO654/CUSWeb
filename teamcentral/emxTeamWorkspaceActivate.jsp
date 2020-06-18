<%--  emxTeamWorkspaceActivate.jsp -- To Make the Workspace active

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamWorkspaceActivate.jsp.rca 1.14 Wed Oct 22 16:06:11 2008 przemek Experimental przemek $
--%>


<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String projectId = emxGetParameter(request, "objectId");
	
// When opened from Designer Central, the objectId parameter is not sent, instead projectId is passed.
	if (projectId == null) {
	    projectId = emxGetParameter(request, "projectId");	    
	}

  DomainObject domainObject     = DomainObject.newInstance(context,projectId);
  domainObject.gotoState(context, "Active");
%>

<form name="newForm" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
</form>

<script language="javascript">
  //parent.window.location.reload(); This does not work with Netscape 7.0
  parent.window.location.href=parent.window.location.href;
//  parent.window.close();
</script>


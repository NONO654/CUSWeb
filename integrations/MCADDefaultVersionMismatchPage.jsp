<%--  MCADDefaultVersionMismatchPage.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import = "com.matrixone.MCADIntegration.server.beans.*,com.matrixone.MCADIntegration.utils.*" %>

<%@ include file ="MCADTopInclude.inc" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String versionMismatchMessage = request.getParameter("message");
	if(versionMismatchMessage != null)
	{
		versionMismatchMessage = MCADUrlUtil.hexDecode(versionMismatchMessage);
		 versionMismatchMessage =  versionMismatchMessage.replace('$','\n');		 
		 versionMismatchMessage = getHtmlSafeString(versionMismatchMessage);
	}
%>

<html>
<head>
</head>
<body>
	<h2><%= XSSUtil.encodeForHTML(integSessionData.getClonedContext(session),versionMismatchMessage) %></h2>
</body>
</html>

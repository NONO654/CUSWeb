<%--  IEFPreferencesContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String activeTabName =Request.getParameter(request,"activeTabName");
%>

<html>
<body>
	
	<script language="javascript">
	function closeModalDialog()
	{
		window.close();
	}

		parent.loadPage("<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),activeTabName) %>");
	</script>
</body>
</html>

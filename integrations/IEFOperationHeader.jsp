<%--  IEFOperationHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String pageTitle		=Request.getParameter(request,"pageTitle");
	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title." + pageTitle);
%>

<html>
<head>
	<title>emxTableControls</title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>

</head>
<body>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
		<tr>
			<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
	</table>
	<table border="0" width="100%" cellpadding="2">
		<tr>
			<td nowrap width="1%" class="pageHeader"><%=XSSUtil.encodeForHTML(integSessionData.getClonedContext(session),operationTitle) %></td>
			<td><img src="../common/images/utilProgressDialog.gif" width="26" height="22" name="imgProgress" border="0"></td>
		</tr>
	</table>

	<br>

</body>
</html>

<%--  IEFIntegrationAssignmentHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String pageIndex = emxGetParameter(request, "pageIndex");

	String pageHeader	= "";
	if(pageIndex.equals("1"))
	{
		pageHeader = integSessionData.getStringResource("mcadIntegration.Server.Heading.StepSelectIntegration");
	}
	else if(pageIndex.equals("2"))
	{
		pageHeader = integSessionData.getStringResource("mcadIntegration.Server.Heading.StepSelectGCO");
	}
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
                        <!--XSSOK-->
			<td class="pageHeader"><%= pageHeader %></td>
		</tr>
	</table>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
	</table>
	<br>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td align="right" >
			<a href='javascript:openIEFHelp("emxhelpdscassignint2")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
		</tr>
	</table>
</body>
</html>

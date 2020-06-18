<%--  MCADEBOMSynchHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
%>

<html>
<head>
	<title>emxTableControls</title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>

</head>
<body>
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
		<tr>
			<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
	</table>
	<table border="0" cellspacing="2" cellpadding="2" width="100%">
		<tr>
		        <!--XSSOK-->
			<td nowrap width="1%" class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.EBOMSynch")%></td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="26" height="22" name="imgProgress"></td>
		</tr>

	</table>

	<br>
	
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td align="right" >
			<a href='javascript:openIEFHelp("emxhelpebomsync")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
		</tr>
	</table>
</body>
</html>

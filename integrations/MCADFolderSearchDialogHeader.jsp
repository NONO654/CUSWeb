<%--  MCADFolderSearchDialogHeader.jsp

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
	<link rel="stylesheet" href="../integrations/styles/emxIEFCommonStyle.css" type="text/css">
	<link rel="stylesheet" href="styles/emxIEFCommonUI.css" type="text/css">

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
			<td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.SelectFolder")%></td>
			<td><img src="images/utilSpace.gif" width="34" height="28" name="imgProgress"></td>
		</tr>
	</table>
</body>
</html>

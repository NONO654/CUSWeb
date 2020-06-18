<%--  IEFNotificationDialogContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body>

<form name="notificationForm">

	<table border="0" cellpadding="5" cellspacing="2" width="100%" class="formBG" align="center">
		<tr class="odd">
		    <!--XSSOK-->
			<td><input type="radio" name="reminder" value="now"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RefreshNow")%></td>
		</tr>
		<tr class="even">
		    <!--XSSOK-->
			<td><input type="radio" name="reminder" value="later" checked><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.RemidMeLater")%></td>
		</tr>
		<tr class="odd">
		<!--XSSOK-->
			<td><input type="radio" name="reminder" value="ignore"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.IgnoreForThisSession")%></td>
		</tr>
	</table>

</form>

</body>
</html>

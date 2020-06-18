<%--  IEFNotificationDialogHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String HelpMarker = "emxhelpdscnotification";
	String language	  = request.getHeader("Accept-Language");
	String strHelp	  = UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Help", "emxFrameworkStringResource", language);
%>

<html>
<head>
	<title>emxTableControls</title>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>
<script language="javascript" src="./scripts/IEFHelpInclude.js">
</script>
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
			<td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.Notification")%></td>
			<td align="right" ><a href='javascript:openIEFHelp("<%=HelpMarker%>")'><img src="images/buttonContextHelp.gif" width="16" height="16" border="0" title="<%=strHelp%>"></a></td>
  		</tr>
	</table>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td>
		</tr>
	</table>
</body>
</html>


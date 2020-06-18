<%--  IEFBaselineHeader.jsp

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
	<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
	
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
			<!-- Fix this-->
			<!-- td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.StartDesign")%></td -->
			<td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.Baseline")%></td>
			<td >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpacer.gif" width="34" height="28" name="progress" ></td>

		</tr>
	</table>
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td align="right" >
			<a href='javascript:openIEFHelp("emxhelpdscstartdesign")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
		</tr>
	</table>
</body>
</html>

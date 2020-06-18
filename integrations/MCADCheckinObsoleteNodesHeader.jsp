<%--  MCADCheckinObsoleteNodesHeader.jsp

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
	<style type=text/css > body { background-color: #DDDECB; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 
	</style>

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
			<td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.Obsolete")%></td>
		</tr>
	</table>
	<table border="0" cellspacing="3" cellpadding="0" width="100%">
		<tr>
			<td align="right" >
			<a href='javascript:openIEFHelp("emxhelpdsccheckin")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			&nbsp;
			</td>
		</tr>
	</table>

</body>
</html>

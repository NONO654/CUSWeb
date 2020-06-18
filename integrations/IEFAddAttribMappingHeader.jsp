<%--  IEFAddAttribMappingHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String strMappingType	=Request.getParameter(request,"MappingType");
	String pageHeader = "";
	
	if(strMappingType != null && "ENOVIAToCAD".equals(strMappingType))
	{
		pageHeader = integSessionData.getStringResource("mcadIntegration.Server.Title.AddAttribENOVIAToCAD");
	}																			
	if(strMappingType != null && "CADToENOVIA".equals(strMappingType))
	{
		pageHeader = integSessionData.getStringResource("mcadIntegration.Server.Title.AddAttribCADToENOVIA");
	}
%>

<html>
<head>
	<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
	<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
	<link rel="stylesheet" href="../common/styles/emxUIDialog.css" type="text/css">
	<link rel="stylesheet" href="styles/emxIEFCommonUI.css" type="text/css">

	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>

</head>

<body>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr><td class="pageBorder"><img src="images/utilSpace.gif" width="1" height="1"></td></tr>
	</table>

	<table border="0" width="100%" cellpadding="2">
		<tr><td class="pageHeader"><xss:encodeForHTML><%=pageHeader%></xss:encodeForHTML></td></tr>
	</table>

	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td align="right" >
			<a href='javascript:openIEFHelp("emxhelpdscattrmapping")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
		</tr>
	</table>
</body>
</html>

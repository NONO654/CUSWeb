<%--  IEFIntegrationAssignmentFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String pageIndex = emxGetParameter(request, "pageIndex");

	//Get the String values from properties file.
	String sCancel		= integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonStyle.css" type="text/css">
</head>

<body>
<form name="bottomCommonForm">

<table border="0" cellspacing="0" cellpadding="0" align=right>
	<tr><td>&nbsp</td></tr>
	<tr>
<%
	if(pageIndex.equals("1"))
	{
		String sNext = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Next");
%>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.goToNextPage()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%= sNext %>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.goToNextPage()"><%= sNext %></a>&nbsp&nbsp;</td>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.closeWindow()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%= sCancel %>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.closeWindow()"><%= sCancel %></a>&nbsp&nbsp;</td>
<%
	}
	else if(pageIndex.equals("2"))
	{
		String sDone		 = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done");
		String sPrevious	 = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Previous");
%>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.goBack()"><img src="../integrations/images/emxUIButtonPrevious.gif" border="0" alt="<%= sPrevious %>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.goBack()"><%= sPrevious %></a>&nbsp&nbsp;</td>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.done()"><img src="../integrations/images/emxUIButtonDone.gif" border="0" alt="<%= sDone %>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.done()"><%= sDone %></a>&nbsp&nbsp;</td>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.closeWindow()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%= sCancel %>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.closeWindow()"><%= sCancel %></a>&nbsp&nbsp;</td>
<%
	}
%>
	</tr>
 </table>
</form>
</body>
</html>

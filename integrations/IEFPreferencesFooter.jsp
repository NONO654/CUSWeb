<%--  IEFPreferencesFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	//Get the String values from properties file.
	String sUpdate = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Update");
	String sCancel = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body>
<form name="bottomCommonForm">

<table border="0" cellspacing="0" cellpadding="0" align=right>
	<tr><td>&nbsp</td></tr>
	<tr>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.updatePreferences()"><img src="../integrations/images/emxUIButtonDone.gif" border="0" alt="<%=sUpdate%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.updatePreferences()"><%=sUpdate%></a>&nbsp&nbsp;</td>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.closeWindow()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=sCancel%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.closeWindow()"><%=sCancel%></a>&nbsp&nbsp;</td>
	</tr>
 </table>

</form>
</body>
</html>

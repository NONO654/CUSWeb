<%--  IEFOperationFooter.jsp

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
	<table border="0" cellspacing="2" cellpadding="3" width="100%">
	<tr>
	<td align="right">
	<table border="0">
	<tr>
		<td nowrap>
		        <!--XSSOK-->
			<a href="javascript:parent.closeWindow()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>
		</td>
		<td nowrap>
		        <!--XSSOK-->
			<a href="javascript:parent.closeWindow()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a>
		</td>
	
	</tr>
	</table>
	</td>
	</tr>
	</table>
  </body>
</html>

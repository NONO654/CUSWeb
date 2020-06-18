<%--  MCADCheckinObsoleteNodesFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%	
	String integrationName						=Request.getParameter(request,"integrationName");
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	MCADLocalConfigObject localConfig			= integSessionData.getLocalConfigObject();	
	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName, integSessionData.getClonedContext(session));	
%>

<html>
  <head>
    <style type=text/css > 
	  body { background-color: #DDDECB; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 
    </style>
  </head>
  <body>
	<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
	<tr>
	<td align="right">
	<table border="0">
	<tr>
		<td nowrap>
		    <!--XSSOK-->
			<a href="javascript:parent.checkoutSelectedNodes()"><img src="../integrations/images/emxUIButtonNext.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.checkoutSelectedNodes")%>"></a>&nbsp;
		</td>
		<td nowrap>
		    <!--XSSOK-->
			<a href="javascript:parent.checkoutSelectedNodes()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.CheckoutSelected")%></a>
		</td>
		<td nowrap>&nbsp;</td>
		<td nowrap>
		    <!--XSSOK-->
			<a href="javascript:parent.checkinCancelled()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp;
		</td>
		<td nowrap>
		    <!--XSSOK-->
			<a href="javascript:parent.checkinCancelled()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a>
		</td>
	
	</tr>
	</table>
	</td>
	</tr>
	</table>
  </body>
</html>

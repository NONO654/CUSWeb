<%--  MCADCheckinUnrecognizedNodesFooter.jsp

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
    <style type=text/css > 
	  body { background-color: #DDDECB; } body, th, td, p { font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt; }a { color: #003366; } a:hover { } a.object { font-weight: bold; } a.object:hover { } span.object {  font-weight: bold; } a.button { } a.button:hover { } td.pageHeader {  font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } td.pageBorder {  background-color: #003366; } th { text-align: left; color: white; background-color: #336699; } th.sub { text-align: left; color: white; background-color: #999999; } tr.odd { background-color: #ffffff; } tr.even { background-color: #eeeeee; } 
    </style>
  </head>
  <body>

	<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
	<tr><form name="configOptions">
	<!--XSSOK-->
	<td align="left" nowrap><input type="checkBox" name="showOnlyNodesCurrentlyUnrecognized" onClick="parent.showOnlyNodesCurrentlyUnrecognized(this)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.ShowOnlyNodesCurrentlyUnrecognized")%>
	</td>
	</form></tr>
	</table>
	<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
	<tr>
	<td align="right">
	<table border="0">
	<tr>
	<!--XSSOK-->
	<td nowrap><a href="javascript:parent.changeRecognitionStatus(true)"><img src="./images/buttonMainMyTasks.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.RecognizeAllSelected")%>"></a></td>
	<!--XSSOK-->
	<td nowrap><a href="javascript:parent.changeRecognitionStatus(true)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.RecognizeAllSelected")%></a></td>
	<td nowrap>&nbsp;</td>
	<!--XSSOK-->
	<td nowrap><a href="javascript:parent.changeRecognitionStatus(false)"><img src="./images/buttonRemove.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.UnrecognizeAllSelected")%>"></a></td>
	<!--XSSOK-->
	<td nowrap><a href="javascript:parent.changeRecognitionStatus(false)"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ButtonName.UnrecognizeAllSelected")%></a></td>
	</tr>
	</table>
	</td>
	</tr>
	</table>

	<script language="javascript">
		var checkStatus = parent.getShowOnlyNodesCurrentlyUnrecognizedFlag();
		if(checkStatus == "true")
		{
			document.forms["configOptions"].showOnlyNodesCurrentlyUnrecognized.checked = true;	
		}
		else if(checkStatus == "false")
		{
			document.forms["configOptions"].showOnlyNodesCurrentlyUnrecognized.checked = false;
		}	
	</script>

  </body>
</html>

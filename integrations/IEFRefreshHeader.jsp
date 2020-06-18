<%--  IEFRefreshHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String integrationName						=Request.getParameter(request,"integrationName");
	MCADLocalConfigObject localConfigObject		= integSessionData.getLocalConfigObject();
	String defaultExpandLevel					= localConfigObject.getDefaultExpandLevel(integrationName);
%>

<html>
<head>
	<title>emxTableControls</title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>

<script language="javascript">
function onLevelChange(levelStr)
{
  if (levelStr == 'All')
     //XSSOK
	 document.expansion.showLevel.value = "<%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>";
  else
     //XSSOK
	 document.expansion.showLevel.value = '<%= defaultExpandLevel %>';
}
</script>

</head>
<body>
  <form name="expansion" onsubmit="return false">
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
			<td nowrap width="1%" class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.Refresh")%></td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="26" height="22" name="imgProgress"></td>
		</tr>
	</table>
	<table border="0" cellspacing="2" cellpadding="0" width="100%">
		<tr>
			<td class="filter">
				 <%= integSessionData.getStringResource("mcadIntegration.Server.Heading.ExpandLevels")%>
				 <select name="filterLevel" id="filterLevel" onChange="javascript:onLevelChange(filterLevel.options[filterLevel.selectedIndex].value);return true;">
					<%
					if(defaultExpandLevel.equalsIgnoreCase("All"))
					{
					%>
					    <!--XSSOK-->
						<option selected value="All"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%></option>
						<!--XSSOK-->
						<option value="UpTo"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.Upto")%></option>
					<%	
					}
					else
					{
					%>
					    <!--XSSOK-->
						<option value="All"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%></option>
						<!--XSSOK-->
						<option selected value="UpTo"><%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.Upto")%></option>
					<%
					}
					%>

				 </select>
				 <!--XSSOK-->
				 <input type="text" name="showLevel"  size="2" value=<%=defaultExpandLevel%>>
			</td>
			<td align="right" >
				<a href='javascript:openIEFHelp("emxhelpdscdesignchangereport")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
			</td>
		</tr>
	</table>
  </form>
</body>
</html>


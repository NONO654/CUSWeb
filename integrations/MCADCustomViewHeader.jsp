<%--  MCADCustomViewHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	String localisedAdminPrefix   = integSessionData.getStringResource("mcadIntegration.Server.FieldName.AdminTablePrefix");
	String localisedUserPrefix    = integSessionData.getStringResource("mcadIntegration.Server.FieldName.WorkspaceTablePrefix");
	
	Context context					= integSessionData.getClonedContext(session);
	
	String integrationName		= Request.getParameter(request,"integrationName");
	String defaultTableName		= Request.getParameter(request,"defaultTableName");

	IEFConfigUIUtil configUIUtil	= new IEFConfigUIUtil(context, integSessionData, integrationName);

	Vector allTableNames = configUIUtil.getAdminAndWorkspaceTableNamesWithPrefix(context, integrationName, integSessionData);

	defaultTableName = MCADUrlUtil.hexDecode(defaultTableName);

	defaultTableName = MCADUtil.replaceString(defaultTableName, localisedAdminPrefix, IEFConfigUIUtil.ADMIN_PREFIX);
	defaultTableName = MCADUtil.replaceString(defaultTableName, localisedUserPrefix, IEFConfigUIUtil.USER_PREFIX);
%>

<html>
<head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
	<title>emxTableControls</title>

	<script language="javascript" type="text/javascript" src="./scripts/IEFHelpInclude.js"></script>
	<script language="javascript" type="text/javascript" src="./scripts/MCADUtilMethods.js"></script>
	<script language="JavaScript" src="./scripts/IEFUIConstants.js"></script>
	<script language="javascript" type="text/javascript" src="./scripts/IEFUIModal.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	<!-- Function FUN080585 : Removal of Cue, Tips and Views -->
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
			<td class="pageHeader"><%= integSessionData.getStringResource("mcadIntegration.Server.Title.CustomView")%> </td>
			<td><img src="images/utilSpace.gif" width="325" height="1"></td>

			<td>&nbsp;&nbsp;<a href="javascript:parent.csvExport();"><img src="../common/images/iconActionExcelExport.gif" border="0" width="15" height="15" alt="<%= integSessionData.getStringResource("mcadIntegration.Common.Export")%>"></a></td>	
                        <!-- Function FUN080585 : Removal of Cue, Tips and Views -->
  			<td align="left" class="filter" nowrap><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.ConfigTable")%>&nbsp;&nbsp;<select name="workSpaceTable" onChange="parent.selectedCustomView(this)">
<%

	for(int i=0; i<allTableNames.size(); i++)
	{
		String tableListDisplayValue = (String)allTableNames.elementAt(i);

		String tableListActualValue  = MCADUtil.replaceString(tableListDisplayValue, localisedAdminPrefix, IEFConfigUIUtil.ADMIN_PREFIX);
		tableListActualValue         = MCADUtil.replaceString(tableListActualValue, localisedUserPrefix, IEFConfigUIUtil.USER_PREFIX);

		String isSelected = "";
		if(tableListActualValue.equals(defaultTableName))
			isSelected = "selected";
%>
        <!--XSSOK-->
        <option value="<%=tableListDisplayValue%>" <%= isSelected %>><%=tableListDisplayValue%></option>
<%
	}
%>
          		</select>
        	</td>
		</tr>
	</table>

	<table border="0" cellspacing="3" cellpadding="0" width="100%">
		<tr>
			<td align="right" >
				<a href='javascript:openIEFHelp("helpFeatureNotImplemented")'><img src="./images/buttonContextHelp.gif" width="16" height="16" border="0" ></a>
				&nbsp;
			</td>
		</tr>
	</table>

</body>
</html>

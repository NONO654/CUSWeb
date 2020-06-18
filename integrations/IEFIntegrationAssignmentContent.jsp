<%--  IEFIntegrationAssignmentContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	String userLabel					= integSessionData.getStringResource("mcadIntegration.Server.FieldName.User");
	String assignedIntegrationsLabel	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.AssignedIntegrations");
	String unassignedIntegrationsLabel	= integSessionData.getStringResource("mcadIntegration.Server.FieldName.UnassignedIntegrations");
	Context context								= integSessionData.getClonedContext(session);
%>

<html>
<head>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>
<form name="formAssignUnassignIntegration" action="IEFIntegrationAssignmentSelectGCO.jsp" method="post" target="_self">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

	<input type="hidden" name="selectedUserType" value="">
	<input type="hidden" name="assignedIntegrationsList" value="">

	<table border="0" cellspacing="2" cellpadding="3" width="100%">
		<tr><td>&nbsp;</td></tr>
		<tr>
		    <!--XSSOK-->
			<td align="center" width="100%"><%= userLabel %>&nbsp;<input type="text" name="selectedUser" size="30" readonly>&nbsp;&nbsp;<input type="button" name="userChooser" value="..." alt="..." onClick="javascript:parent.selectUser('selectedUser')">
			</td>
		</tr>
		<tr><td>&nbsp;</td></tr>
		<tr><td>
			<table border="0" cellspacing="2" cellpadding="3" width="100%">
				<tr>
				    <!--XSSOK-->
					<td align="center" width="40%"><%= assignedIntegrationsLabel %>&nbsp;</td>
					<td align="center" width="20%">&nbsp;</td>
					<!--XSSOK-->
					<td align="center" width="40%"><%= unassignedIntegrationsLabel %>&nbsp;</td>
				</tr>
				<tr>
					<td align="center" width="40%">
						<select width="150" style="width:150px;overflow-x:auto;" size="10" name="assignedIntegrations" multiple>
						</select>
					</td>
					<td align="center" width="20%">
						<table border="0" cellspacing="2" cellpadding="3">
							<tr>
								<td align="center" width="50%"><input type="button" style="width: 75px;" size="200" name="assign" value="<<<" alt="Assign selected integration to user" onClick="javascript:parent.assignIntegration()"></td>
							</tr>
							<tr><td>&nbsp;</td></tr>
							<tr><td>&nbsp;</td></tr>
							<tr><td>&nbsp;</td></tr>
							<tr>
								<td align="center" width="50%"><input type="button" style="width: 75px;" size="200" name="unassign" value=">>>" alt="Unassign selected integration to user" onClick="javascript:parent.unassignIntegration()"></td>
							</tr>
						</table>
					</td>
					<td align="center" width="40%">
						<select width="150" style="width:150px;overflow-x:auto;" size="10" name="unassignedIntegrations" multiple>
						</select>
					</td>
				</tr>
			</table>
			</td>
		</tr>
	</table>
</form>
<script language="JavaScript">
	if(parent.userName != "" && parent.userType != "")
	{
		var formObject = document.formAssignUnassignIntegration;

		formObject.selectedUser.value = parent.userName;
		formObject.selectedUserType.value = parent.userType;
		
		if(parent.assignedIntegrationsList.length > 0)
		{
			var assignedIntegrationsElements = parent.assignedIntegrationsList.split('|');
			for(i=0; i<assignedIntegrationsElements.length; i++)
			{	
				var assignedIntegration = assignedIntegrationsElements[i];
			
				formObject.assignedIntegrations.options[i] = new Option(assignedIntegration, assignedIntegration);
			}
		}
		
		if(parent.unassignedIntegrationsList.length > 0)
		{
			var unassignedIntegrationsElements = parent.unassignedIntegrationsList.split('|');
			for(i=0; i<unassignedIntegrationsElements.length; i++)
			{	
				var unassignedIntegration = unassignedIntegrationsElements[i];
			
				formObject.unassignedIntegrations.options[i] = new Option(unassignedIntegration, unassignedIntegration);
			}
		}
	}
</script>
</body>
</html>

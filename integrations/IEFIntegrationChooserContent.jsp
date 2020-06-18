<%--  IEFIntegrationChooserContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,java.util.ResourceBundle" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
	Context context = integSessionData.getClonedContext(session);
	String allowedIntegrations				=Request.getParameter(request,"allowedIntegrations");	
	Hashtable integrationNameGCONameMap		= localConfigObject.getIntegrationNameGCONameMapping();	

	Vector allowedIntegrationNames = new Vector();

	if(allowedIntegrations != null && !allowedIntegrations.equals(""))
	{
		allowedIntegrationNames = MCADUtil.getVectorFromString(allowedIntegrations,"|");
	}
	ResourceBundle iefProperties = PropertyResourceBundle.getBundle("ief");
	Vector upsIntegration = new Vector();
	String psuActivatedIntegrations ="";
	try
	{
		psuActivatedIntegrations = iefProperties.getString("mcadIntegration.server.PSUActivatedIntegrations");
			if(psuActivatedIntegrations!=null && !psuActivatedIntegrations.equals(""))
			{
				psuActivatedIntegrations=psuActivatedIntegrations.trim();	
				upsIntegration = MCADUtil.getVectorFromString(psuActivatedIntegrations,",");
			}
	}
	catch(Exception e)
	{
		System.out.println("mcadIntegration.server.PSUActivatedIntegrations doesn't exist");
	}	
	
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">

</head>

<body>
	<center>
		<form name="frmIntegNameChooser" method="post" target="_top" action="javascript:formSubmit()">	
		<table align="left" width="100%">
			<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
<%
	if(integrationNameGCONameMap.size() > 0)
	{
		Enumeration integrationNameElements = integrationNameGCONameMap.keys();
		while(integrationNameElements.hasMoreElements())
		{
			String integrationName = (String)integrationNameElements.nextElement();
			if(!allowedIntegrationNames.isEmpty())
			{
				if(allowedIntegrationNames.contains(integrationName) && !upsIntegration.contains(integrationName))
				{
%>
				<tr>
					<td>&nbsp;</td>
					<td width="5%"><input type="radio" name="integrationName" value="<%= XSSUtil.encodeForHTML(context, integrationName) %>"></td>
					<td><%=XSSUtil.encodeForHTML(context, integrationName)  %></td>
				</tr>
<%
				}
			}
			else
			{
%>
				<tr>
					<td>&nbsp;</td>
					<td width="5%"><input type="radio" name="integrationName" value="<%= XSSUtil.encodeForHTML(context, integrationName) %>"></td>
					<td><%=XSSUtil.encodeForHTML(context, integrationName)  %></td>
				</tr>
<%
			}			
		}
	}
	else
	{
%>
		<tr bgcolor="#eeeeee">
		  <!--XSSOK-->
		  <td align=center colspan=3><%=integSessionData.getStringResource("mcadIntegration.Common.NoItemsFound")%></td>
		</tr>
<%
	}
%>
		</table>
		</form>
	</center>
</body>
</html>

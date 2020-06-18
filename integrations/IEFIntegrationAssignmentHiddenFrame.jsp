<%--  IEFIntegrationAssignmentHiddenFrame.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file ="MCADTopInclude.inc"%>

<%!
	private final String GLOBAL_CONFIG_OBJ_TYPE = "MCADInteg-GlobalConfig";

	private String getDefaultGCOName(Context context, String integrationName) 
	{
		String[] args = new String[1];
		args[0] = integrationName;
		
		String integrationDetails = "";
		try
		{
			 integrationDetails = (String)JPO.invoke(context, "IEFGetRegistrationDetails", null, "getRegistrationDetails" , args, String.class);
		}
		catch(Exception e)
		{
		}

		if(integrationDetails.equals(""))
		{
			return "";
		}

		String defaultGCOName = integrationDetails.substring(integrationDetails.lastIndexOf("|") + 1, integrationDetails.length());

		return defaultGCOName;
	}
%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

	MCADMxUtil util	= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String selectedUserName = emxGetParameter(request, "selectedUserName");
	String selectedUserType = emxGetParameter(request, "selectedUserType");
%>

<html>

<head>
	<script language="javascript">
		parent.resetLists();
	</script>
</head>

<body>

<%
	String allRegisteredIntegrations = (String)JPO.invoke(context, "IEFGetRegisteredIntegrations", null, "getRegisteredIntegrations", null, String.class);

	String assignedIntegrationsGCONamesList = "";

	String adminType = "";
	if(selectedUserType.equalsIgnoreCase("Person"))
	{
		adminType = "person";
	}
	else if(selectedUserType.equalsIgnoreCase("Role"))
	{
		adminType = "role";
	}
	else if(selectedUserType.equalsIgnoreCase("Group"))
	{
		adminType = "group";
	}
	String Args[]=new String[3];
	Args[0]=adminType;
	Args[1]=selectedUserName;
	Args[2]="property[IEF-IntegrationAssignments].value";
	String result = util.executeMQL(context, "print $1 $2 select $3 dump",Args);
	if(result.startsWith("false|"))
	{
%>
		<script language="javascript">
		    //XSSOK
			alert("Failed to get integrations assigned to " + "<%= adminType %>" + " " + "<%= selectedUserName %>" + " : " + "<%= result.substring(6) %>");
		</script>
<%
	}
	else if(result.startsWith("true|"))
	{
		assignedIntegrationsGCONamesList = result.substring(5);
	}
	
	StringTokenizer tokens =  new StringTokenizer(allRegisteredIntegrations, "|");
	while(tokens.hasMoreTokens())
	{
		String integrationName = tokens.nextToken();
		
		String gcoName =  "";
		
		int index = assignedIntegrationsGCONamesList.indexOf(integrationName);
		if(index > -1)
		{	
			//integration is assigned.Add it to assigned integrations list
%>
			<script language="javascript">
			    //XSSOK
				parent.addToAssignedIntegrationsList('<%= integrationName %>');
			</script>
<%
			//get the gco name assigned for this integration
			int valueStartIndex = index + integrationName.length() + 1;
            int valueEndIndex   = assignedIntegrationsGCONamesList.indexOf(";", valueStartIndex);

            if(valueEndIndex > -1)
			{
                gcoName = assignedIntegrationsGCONamesList.substring(valueStartIndex, valueEndIndex);
			}
            else
			{
                gcoName = assignedIntegrationsGCONamesList.substring(valueStartIndex);
			}
			
			String gcoID = util.getGlobalConfigObjectID(context, GLOBAL_CONFIG_OBJ_TYPE, gcoName);
			if(gcoID.equals(""))
			{
				gcoName = "";
			}
		}
		else
		{	
			//integration is unassigned.Add it to unassigned integrations list
%>
			<script language="javascript">
			    //XSSOK
				parent.addToUnassignedIntegrationsList('<%= integrationName %>');
			</script>
<%
			//get the default gco name for this integration
			gcoName = getDefaultGCOName(context, integrationName);
			
			//check if the gco with gcoName exists in the database. If it doesn't exist throw
			//error and exit.
			String gcoID = util.getGlobalConfigObjectID(context, GLOBAL_CONFIG_OBJ_TYPE, gcoName);
			if(gcoID.equals(""))
			{
				//no gco exists with name gcoName.
				Hashtable details = new Hashtable(2);
				details.put("INTEGRATION", integrationName);
				details.put("GCONAME", gcoName);
				String errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.RegisteredGCONotFound", details);
%>
				<script language="javascript">
				    //XSSOK
					alert("<%= errorMessage %>");
					parent.closeWindow();
				</script>
<%
			}
		}
%>
		<!-- Add the integration and gco name to the array-->
		<script language="javascript">
		    //XSSOK
			parent.setIntegrationNameGCONameMap('<%= integrationName %>', '<%= gcoName %>');
		</script>
<%
	}
%>

</body>
</html>

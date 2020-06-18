<%--  IEFIntegrationAssignmentSelectGCO.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import = "com.matrixone.MCADIntegration.server.cache.IEFGlobalCache" %>
<%@ include file ="MCADTopInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%!
	private final String GLOBAL_CONFIG_OBJ_TYPE = "MCADInteg-GlobalConfig";
	//MCADMxUtil util								= null;
	IEFIntegAccessUtil util		= null;

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

	private HashMap getAssignedIntegrationsGCOMap(Context context, String selectedUserType, String name) throws Exception
	{
		HashMap returnMap = new HashMap();

		String allRegisteredIntegrations = (String)JPO.invoke(context, "IEFGetRegisteredIntegrations", null, "getRegisteredIntegrations", null, String.class);

		String assignedIntegrationsGCONamesList = "";
		String propertyToSelect = "property[IEF-IntegrationAssignments].value";
		
		if(selectedUserType.equalsIgnoreCase("Person"))
		{
			Hashtable assignedIntegrationsTable = util.getAssignedIntegrationsTable(context,name);
			returnMap.putAll(assignedIntegrationsTable);
			
			String localConfigObjectRevision = MCADMxUtil.getConfigObjectRevision(context); 
			BusinessObject selectedUserLCO   = new BusinessObject("MCADInteg-LocalConfig", name, localConfigObjectRevision, "");

			if(selectedUserLCO.exists(context))
			{   
				selectedUserLCO.open(context);
				
				Attribute integrationGCOMappingAttr = selectedUserLCO.getAttributeValues(context, "IEF-IntegrationToGCOMapping");
				String integrationToGCOMapping		= "";
				
				if(integrationGCOMappingAttr != null)
				{
					integrationToGCOMapping			= integrationGCOMappingAttr.getValue();
					StringTokenizer tokensFromLCO	= new StringTokenizer(integrationToGCOMapping, "\n");

					while(tokensFromLCO.hasMoreTokens())
		{
						String integrationGCONameTokens = tokensFromLCO.nextToken();
						String integrationName			= integrationGCONameTokens.substring(0, integrationGCONameTokens.indexOf("|"));
						String gcoName					= integrationGCONameTokens.substring(integrationGCONameTokens.indexOf("|") + 1);
						
						if(returnMap.containsKey(integrationName))
							returnMap.put(integrationName, gcoName);
		}
		}

				selectedUserLCO.close(context); 
		}
		
		
		}
		else if( selectedUserType.equalsIgnoreCase("Role"))
		{
			String Args[]=new String[2];
			Args[0]=name;
			Args[1]=propertyToSelect;
			String result = util.executeMQL(context, "print role $1 select $2 dump",Args);
			if(result.startsWith("true|"))
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
					int valueStartIndex = index + integrationName.length() + 1;
					int valueEndIndex   = assignedIntegrationsGCONamesList.indexOf(",", valueStartIndex);

					if(valueEndIndex > -1)
					{
						gcoName = assignedIntegrationsGCONamesList.substring(valueStartIndex, valueEndIndex);
					}
					else
					{
						gcoName = assignedIntegrationsGCONamesList.substring(valueStartIndex);
					}
				}
		
				if(gcoName != null && !gcoName.equals(""))
					returnMap.put(integrationName, gcoName);
			}

		}
		else if(selectedUserType.equalsIgnoreCase("Group"))
		{
			StringTokenizer tokens =  new StringTokenizer(allRegisteredIntegrations, "|");
			
			while(tokens.hasMoreTokens())
			{
				String integrationName = tokens.nextToken();
				returnMap.put(integrationName, getDefaultGCOName(context, integrationName));
			}
		}
		return returnMap;
	}
%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
	//util										= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	util										= new IEFIntegAccessUtil(context,integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	String selectedUser							= emxGetParameter(request, "selectedUser");
	selectedUser = MCADUrlUtil.hexDecode(selectedUser);

	String chkbxTopLevel		= emxGetParameter(request, "chkbxTopLevel");
	String chkbxPerson			= emxGetParameter(request, "chkbxPerson");
	String chkbxRole			= emxGetParameter(request, "chkbxRole");
	String filterInput			= emxGetParameter(request, "txtFilter");
	
	if(filterInput!= null)
		session.setAttribute("txtFilter", filterInput);
	if(chkbxTopLevel!= null)
		session.setAttribute("chkbxTopLevel", chkbxTopLevel);
	if(chkbxPerson!= null)
		session.setAttribute("chkbxPerson", chkbxPerson);
	if(chkbxRole!= null)
		session.setAttribute("chkbxRole", chkbxRole);	
	if(selectedUser!= null)
		session.setAttribute("selectedUser", selectedUser);

	String selectedUserType				= emxGetParameter(request, "selectedUserType");
	
	HashMap integrationGCONameMap		= getAssignedIntegrationsGCOMap(context, selectedUserType, selectedUser);
	
	String assignedIntegrationsList		= MCADUtil.getDelimitedStringFromCollection(integrationGCONameMap.keySet(), "|");
%>

<html>
  <head>
    
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

  </head>
  <body>
	<form name="formSelectGCO" action="javascript:parent.done()" method="post" target="_self">

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

		<table border="0" cellspacing="2" cellpadding="3" width="100%">
			<tr><td>&nbsp;</td></tr>
<%	
	if(assignedIntegrationsList == null || assignedIntegrationsList.equals(""))
	{
		String message = integSessionData.getStringResource("mcadIntegration.Server.Message.NoIntegrationAssigned");
%>
                <!--XSSOK-->
		<tr><td width="100%" align="center"><%= message %></td></tr>
<%
	}
	else
	{
		StringTokenizer tokens = new StringTokenizer(assignedIntegrationsList, "|");
		while(tokens.hasMoreTokens())
		{
			String assignedIntegrationName	= tokens.nextToken();
			String gcoName							= (String)integrationGCONameMap.get(assignedIntegrationName); 

			String integrationExists = "false";
			if(gcoName != null && !gcoName.equals(""))
			{
				//check if the gco with gcoName exists in the database. If it doesn't exist throw
				//error and exit.
				String gcoID = util.getGlobalConfigObjectID(context, GLOBAL_CONFIG_OBJ_TYPE, gcoName);
				if(gcoID.equals(""))
				{
					//no gco exists with name gcoName.
					Hashtable details = new Hashtable(2);
					details.put("INTEGRATION", assignedIntegrationName);
					details.put("GCONAME", gcoName);
					String errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.AssignedGCONotFound", details);
					
					//set the gcoName as blank
					gcoName = "";

%>
					<script language="javascript">
				         	//XSSOK
						alert("<%= errorMessage %>");
					</script>
<%
				}

				integrationExists = "true";
			}
%>
			<tr>
				<td align="right" width="35%">
					<%= XSSUtil.encodeForHTML(context,assignedIntegrationName) %>
				</td>
				<td>
					<script language="javascript">
						var gcoName			  = "";
						//XSSOK
						var integrationExists = "<%= integrationExists %>";
						
						parent.addToAssignedIntegrationsList('<%=XSSUtil.encodeForJavaScript(context,assignedIntegrationName) %>');

						if(integrationExists == "true")
						{
						    //XSSOK
							gcoName = "<%= gcoName %>";
							parent.setIntegrationNameGCONameMap('<%=XSSUtil.encodeForJavaScript(context,assignedIntegrationName)%>', gcoName);
						}
						else
						{
							gcoName = parent.getIntegrationNameGCONameMap('<%= XSSUtil.encodeForJavaScript(context,assignedIntegrationName)%>');
						}

						document.write("<input type=\"text\" name=\"<%= XSSUtil.encodeForJavaScript(context,assignedIntegrationName) %>\" value = \"" + gcoName +"\" readonly>&nbsp;&nbsp;");
						document.write("<input type=\"button\" name=\"btnGCOSelector\" size=\"200\" value=\"...\" alt=\"...\" onClick=\"javascript:parent.selectGCO('<%=XSSUtil.encodeForJavaScript(context, assignedIntegrationName) %>', '" + gcoName + "')\">");
					</script>
				</td>
			</tr>
			<tr><td>&nbsp;</td></tr>
<%
		}
	}
%>
		</table>
	</form>
  </body>
</html>

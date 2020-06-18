<%--  IEFPurgeConfirmationDialog.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file ="MCADTopErrorInclude.inc" %>

<html>

<head>
<%!
	public String getParentObjectTableContent(HashMap minorObjectIDParentDataTable, Context context, MCADIntegrationSessionData integSessionData, String acceptLanguage)
	{
		String deselectSelectedObjVersions = integSessionData.getStringResource("mcadIntegration.Server.Message.DeselectSelectedObjectVersions");

		StringBuffer htmlContentBuffer = new StringBuffer("<tr><font size='+1'><b>" + deselectSelectedObjVersions + "</b></font></tr><br>");

		java.util.Set completeSet	= minorObjectIDParentDataTable.keySet();
		Iterator completeDataItr	= completeSet.iterator();
		while(completeDataItr.hasNext())
		{
			String minorObjId	    = (String)completeDataItr.next();
			MapList relObjTableList	= (MapList)minorObjectIDParentDataTable.get(minorObjId);

			String minorObjType     = "";			
			String minorObjName     = "";
			String minorObjRev      = "";
			try
			{
				BusinessObject bus = new BusinessObject(minorObjId);
				bus.open(context);
				minorObjType = bus.getTypeName();
				minorObjName = bus.getName();
				minorObjRev  = bus.getRevision();
				bus.close(context);
			}
			catch(Throwable exception)
			{
				System.out.println("Error in opening business object in purge dialog. Error :" + exception.getMessage());
			}

			Hashtable msgTable = new Hashtable();
			msgTable.put("TYPE", minorObjType);
			msgTable.put("NAME", minorObjName);
			msgTable.put("REVISION", minorObjRev);
			String selectedDesignReference = integSessionData.getStringResource("mcadIntegration.Server.Message.DesignReferenceInPurge", msgTable);

			htmlContentBuffer.append("<tr><td valign='top'><b>" + selectedDesignReference + "</b></td></tr>");

			htmlContentBuffer.append("<tr><td valign='top'>");
			for(int i=0; i<relObjTableList.size(); i++)
			{
				HashMap relObjMap = (HashMap)relObjTableList.get(i);
				String type     = (String)relObjMap.get(DomainObject.SELECT_TYPE);
				String name     = (String)relObjMap.get(DomainObject.SELECT_NAME);
				String revision = (String)relObjMap.get(DomainObject.SELECT_REVISION);

				htmlContentBuffer.append(type + " " + name + " " + revision + "<br>");
			}

			htmlContentBuffer.append("</td></tr>");
		}

		return htmlContentBuffer.toString();
	}	
%>

<%
	String instanceName		= request.getParameter("instanceName");	
	String integrationName  = request.getParameter("integrationName");
	String selectedBusIds	= request.getParameter("selectedObjIds");
	String acceptLanguage   = request.getHeader("Accept-Language");

	Context context						= null;
	HashMap completeRelationshipObjMap	= null;

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	if(integSessionData == null)
	{
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

        String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		context = integSessionData.getClonedContext(session);
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

		HashMap paramMap = new HashMap();
		if(integrationName != null && integrationName.length() != 0 && !integrationName.equalsIgnoreCase("null"))
		{
			MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
			paramMap.put("GCO", globalConfigObject);				
		}
		
		completeRelationshipObjMap = new HashMap();
		StringTokenizer selectedBusIdsTokens = new StringTokenizer(selectedBusIds, "|");
		while(selectedBusIdsTokens.hasMoreTokens())
		{
			String selectedBusId = selectedBusIdsTokens.nextToken();

			paramMap.put("objectId",     selectedBusId);
			paramMap.put("relationship", "CAD SubComponent");
			paramMap.put("instanceName", instanceName);
			paramMap.put("languageStr",  acceptLanguage);
			paramMap.put("end",          "to");

			try
			{     
				String[] intArgs = new String[]{};

				//invoke the JPO now to get parent objects with SubComponent relationship.				
				MapList relObjList = new MapList();
				relObjList = (MapList)JPO.invoke(context, "IEFObjectWhereUsed", intArgs, "getList", JPO.packArgs(paramMap), MapList.class);
				
				if(relObjList == null || relObjList.size()== 0)
				{
					paramMap.put("relationship", "Associated Drawing");
					paramMap.put("end",          "from");
					relObjList = (MapList)JPO.invoke(context, "IEFObjectWhereUsed", intArgs, "getList", JPO.packArgs(paramMap), MapList.class);
				}
								
				if(relObjList != null && relObjList.size() > 0)
				{
					completeRelationshipObjMap.put(selectedBusId, relObjList);
						
				}
					
					
			}
			catch(Exception e)
			{
				emxNavErrorObject.addMessage(e.getMessage());
				e.printStackTrace();
			}
		}
	}
%>

<script src="scripts/IEFUIModal.js" type="text/javascript"></script>
</head>

<body>
</body>

<%
	String url = "";
	if(completeRelationshipObjMap == null || completeRelationshipObjMap.size() == 0)
	{
%>
	<script language="JavaScript">
			top.contentFrame.purge();
	</script>
<%
	}
	else
	{
		String messageContent = getParentObjectTableContent(completeRelationshipObjMap, context, integSessionData, acceptLanguage);
		if(messageContent != null)
		{
			String messageHeader = integSessionData.getStringResource("mcadIntegration.Server.Title.Purge");
			session.setAttribute("mcadintegration.messageHeader", messageHeader);

			messageContent		 = MCADUrlUtil.hexEncode(messageContent);
			session.setAttribute("mcadintegration.message", messageContent);
			url= "./IEFPurgeConfirmationDialogFS.jsp?isContentHtml=true";
		}
%>
	<script language="JavaScript">
		showIEFNonModalDialog("<%=XSSUtil.encodeForHTML(context,url)%>", 600, 450);
	</script>
<%
	}
%>

<%@include file = "MCADBottomErrorInclude.inc"%>

</html>

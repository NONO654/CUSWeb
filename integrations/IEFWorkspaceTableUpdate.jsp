<%--  IEFWorkspaceTableUpdate.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%!
	private void updateLCO(String selectedTable, String newTableName, MCADIntegrationSessionData integSessionData, HttpSession session) throws MCADException, Exception
	{
		Context context                         = integSessionData.getClonedContext(session);
		MCADMxUtil util                         = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();

		if("".equals(newTableName))
		{
			newTableName = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.DefaultTableName");;
		}

		Hashtable integrationGCOMapping	= localConfigObject.getIntegrationNameGCONameMappingForAll();
		if(integrationGCOMapping != null)
		{
			Enumeration integrationNames		= integrationGCOMapping.keys();
			if(integrationNames.hasMoreElements())
			{
				Hashtable defaultTables				= localConfigObject.getDefaultTables((String)integrationNames.nextElement());
				boolean defaultTableDeleted			= false;
				Enumeration tableKeys				= defaultTables.keys();
				StringBuffer attrValue				= new StringBuffer("");
				while(tableKeys.hasMoreElements())
				{
					String pageName = (String) tableKeys.nextElement();				
					String DefaultTableForPage = (String) defaultTables.get(pageName);
					
					if(DefaultTableForPage.equals(selectedTable))
					{				
						defaultTableDeleted = true;
						attrValue.append(pageName);
						attrValue.append(MCADAppletServletProtocol.TABLE_SEP);
						attrValue.append(newTableName);
						attrValue.append(MCADAppletServletProtocol.VALUE_SEP);
					}
					else
					{
						attrValue.append(pageName);
						attrValue.append(MCADAppletServletProtocol.TABLE_SEP);
						attrValue.append(DefaultTableForPage);
						attrValue.append(MCADAppletServletProtocol.VALUE_SEP);
					}
				}
				if(defaultTableDeleted)
				{
					String iefDefaultConfigTables    = util.getActualNameForAEFData(context,"attribute_IEF-DefaultConfigTables");
					localConfigObject.setAttributeValue(iefDefaultConfigTables, attrValue.toString());
					integSessionData.updateMatrixLocalConfigObject(context, localConfigObject);
				}
			}
		}
	}
%>
<%	
	MCADIntegrationSessionData integSessionData  = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context _context							 = integSessionData.getClonedContext(session);
	
	ENOCsrfGuard.validateRequest(_context, session, request, response);
	
	String encodedListPageUrl =Request.getParameter(request,"encodedListPageUrl");
    String workspacePrefix    = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.WorkspaceTablePrefix");

	String title              = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Title.WorkSpaceTableHeader");	
	String action             =Request.getParameter(request,"mode");
	String tableName          = MCADUrlUtil.hexDecode(Request.getParameter(request,"tableName"));
	String expType            = "businessobject";
	String result             = "";		
	String tableNameOrig      = "";

	if (action.equals("modify"))
	{					 
		 tableNameOrig = MCADUrlUtil.hexDecode(Request.getParameter(request,"tableNameOrig"));
	}	
	if(tableName != null && action != null)
	{		
		if (action.equalsIgnoreCase("delete"))
		{			
			IEFConfigUIUtil iefConfigUIUtil = new IEFConfigUIUtil(_context, integSessionData, "");
			result							= iefConfigUIUtil.deleteTable(_context, tableName);
			if(!result.startsWith("false"))
			{
				updateLCO(workspacePrefix + tableName, "", integSessionData, session);
			}
		}

		if(action.equals("modify") || action.equals("add"))
		{	
			String tableData  = MCADUrlUtil.hexDecode(Request.getParameter(request,"tableData"));

			Vector tableDataList = new Vector();
			StringTokenizer tableToken = new StringTokenizer(tableData.trim(),"@");
			String columnData = "";
			while(tableToken.hasMoreTokens())
			{
				columnData            = tableToken.nextToken();
				Hashtable columnDataTable       = new Hashtable(5);
				StringTokenizer token = new StringTokenizer(columnData, "|");
				if(token.countTokens() == 2)
				{			
					String label          = token.nextToken();
					String expression     = token.nextToken();
					String expressionType = expType;
					String columnName     = label;
					columnDataTable.put(IEFConfigUIUtil.COLUMN_NAME,columnName);
					columnDataTable.put(IEFConfigUIUtil.LABEL,label);
					columnDataTable.put(IEFConfigUIUtil.EXPRESSION,expression);
					columnDataTable.put(IEFConfigUIUtil.EXPRESSION_TYPE,expressionType);
				}

				tableDataList.addElement(columnDataTable);
			}

			IEFConfigUIUtil iefConfigUIUtil = new IEFConfigUIUtil(_context, integSessionData, "");
			result							= iefConfigUIUtil.addOrModifyTable(_context, tableName, tableNameOrig, action, tableDataList);

			if(!result.startsWith("false") && action.equals("modify"))
			{
				updateLCO(workspacePrefix + tableNameOrig, workspacePrefix + tableName, integSessionData, session);
			}
		}	
	}

	String decodedListPageUrl = MCADUrlUtil.hexDecode(encodedListPageUrl);	
	decodedListPageUrl        = decodedListPageUrl + "&result=" + result;	
%>
<!--XSSOK-->
<jsp:forward page ="<%=decodedListPageUrl%>">
	<jsp:param name="helpMarker" value="false"/>
</jsp:forward>

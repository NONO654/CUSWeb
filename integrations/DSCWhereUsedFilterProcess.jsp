 <%--  IEFWhereUsedFilterProcess.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
 <%@ page import = "java.util.*,java.util.Set,matrix.db.*,matrix.util.*,com.matrixone.servlet.*" isErrorPage="true"%>
<%@ page import = "com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.apps.common.*" %>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>				  



<%		
	String tableID			= emxGetParameter(request, "tableID");
	String objectId			= emxGetParameter(request, "objectId");
		
	MapList revisionVersionsList		= null;
	
	// Get object & relationship ids
	
	HashMap tableData		= tableBean.getTableData(tableID);
	MapList relBusObjList	= tableBean.getObjectList(tableData);		
	
	String filterLevel				= emxGetParameter(request, "filterLevel");
	String filterDesignVersion		= emxGetParameter(request, "filterDesignVersion");
	String filterRevisionList		= emxGetParameter(request, "filterRevisionList");
	String filterVersionList		=Request.getParameter(request,"filterVersionList");
	String showLevel				= emxGetParameter(request, "showLevel");
			
	String acceptLanguage							= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);

	 MCADIntegrationSessionData integSessionData	=    (MCADIntegrationSessionData)session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT); 	 			

	MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String integrationName						   = util.getIntegrationName(integSessionData.getClonedContext(session),objectId);
	MCADGlobalConfigObject globalConfigObject	   = integSessionData.getGlobalConfigObject(integrationName,integSessionData.getClonedContext(session));	 
	
	// Get business object list from session level Table bean
	tableData = tableBean.getTableData(tableID);
		
	MapList filteredObjPageList				= new MapList();
	StringList busSelects					= new StringList();
	BusinessObjectWithSelectList busObjwsl  = null;
		
	if ( relBusObjList != null)
	{
		HashMap paramMap = new HashMap();
		paramMap.put("objectId", objectId);
		paramMap.put("filterLevel", filterLevel);
		paramMap.put("filterRev", filterRevisionList);
		paramMap.put("filterVer", filterVersionList);			
		paramMap.put("filterDesignVersion", filterDesignVersion);
		paramMap.put("GCO", globalConfigObject);
		paramMap.put("LCO", integSessionData.getLocalConfigObject());
		paramMap.put("languageStr", serverResourceBundle.getLanguageName());
		
		String jpoName		 = "DSCWhereUsed";
		String jpoMethod	 = "getList";
		revisionVersionsList = (MapList)JPO.invoke(context, jpoName, new String[0], jpoMethod, JPO.packArgs(paramMap), MapList.class);
	}
	
	tableBean.setFilteredObjectList(tableData, revisionVersionsList);

	%>
<script language="JavaScript">
	parent.refreshTableBody();
</script>

<%--  MCADRecentlyAccessedPartsFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<%@ page import="com.matrixone.servlet.Framework"%>
<%@ page import="com.matrixone.MCADIntegration.utils.MCADUrlUtil"%>
<%@ page import= "com.matrixone.apps.domain.util.*" %>
<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*"%>
<%@ page import = "com.matrixone.apps.domain.util.CacheUtil"%>
<%@ page import = "java.io.*,javax.servlet.*,javax.servlet.http.*"%>;

<% 	

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String recentlyAccessedDesignsTitle	= "";
	String queryString = emxGetEncodedQueryString(context,request);
	if(integSessionData != null)
	{		
		
		recentlyAccessedDesignsTitle = integSessionData.getStringResource("mcadIntegration.Server.FieldName.RecentlyAccessedDesigns");
	}

	String sIntegName							= Request.getParameter(request,"integrationName");
	String dateSelected						    = "Today";
    
	MCADGlobalConfigObject globalConfigObject   = integSessionData.getGlobalConfigObject(sIntegName, context);	  	    		
				
	MCADRecentlyAccessedPartsHelper helper      = new  MCADRecentlyAccessedPartsHelper(integSessionData);
	MapList mResultList							= helper.getRecentlyAccessedBusObjectList(context, MCADRecentlyAccessedPartsHelper.ALL,globalConfigObject);
	String jpoPackedArgs						= MCADUtil.covertToString(mResultList,true,true);
    
    jpoPackedArgs								= MCADUrlUtil.encode(jpoPackedArgs); 

	session.setAttribute("GCO",globalConfigObject);
	session.setAttribute("LCO",integSessionData.getLocalConfigObject());
	session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(context));	

	
	String requestURI = request.getRequestURI();

	
	String pathWithIntegrationsDir	= requestURI.substring(0, requestURI.lastIndexOf('/'));
	String pathWithAppName			= pathWithIntegrationsDir.substring(0, pathWithIntegrationsDir.lastIndexOf('/'));

	
	CacheUtil.setCacheObject(context, "RECENTLY_ACCESSED_PARTS", jpoPackedArgs);
	
	String sForward =  pathWithAppName + "/common/emxIndentedTable.jsp?program=DSCRecentlyAccessedParts:getRecentlyAccessedBusObjectsList&editLink=false&table=DSCRecentlyAccessedParts&toolbar=DSCRecentlyAccessedPartsToolBar&mode=view&selection=multiple&sortColumnName=AccessDate&sortDirection=descending&header=emxIEFDesignCenter.Common.RecentlyAccessedDesigns&GlobalContext=true&displayView=details&suiteKey=DesignerCentral&fromExt=true&dateSelected=" + dateSelected+"&integrationName="+sIntegName+"&jpoAppServerParamList=session:GCOTable,session:LCO,session:GCO"; // +"&RECENTLY_ACCESSED_PARTS="+jpoPackedArgs;

	
	response.sendRedirect(sForward);	

%>



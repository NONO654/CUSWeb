<%--  MCADRenameAppletFreePost.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ page import="com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.server.managers.IEFBrowserCommandsManager" %>
<%@ page import="java.util.ArrayList" %>
<%@page import = "com.matrixone.apps.domain.util.*" %>
<%@page contentType="text/html; charset=UTF-8"%>

<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.managers.* , com.matrixone.MCADIntegration.server.beans.*,com.matrixone.MCADIntegration.server.managers.IEFBrowserCommandsManager" %>
<%@ page import="java.util.*" %>
<%
		
MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context								= integSessionData.getClonedContext(session);


String integrationName			= request.getParameter("integrationName");
String isAutoName	= request.getParameter("isAutoName");
String seriesName			= request.getParameter("seriesName");
String busId			= request.getParameter("busId");
String newName	= request.getParameter("newName");
String instanceName	= request.getParameter("instanceName");

Hashtable paramTable = new Hashtable();

paramTable.put(MCADAppletServletProtocol.INTEGRATION_NAME, integrationName); 
//paramTable.put(MCADAppletServletProtocol.ACCEPT_LANGUAGE, acceptLanguage); 
paramTable.put("newName", newName); 
paramTable.put("busId", busId);
paramTable.put("isAutoName", "false");
paramTable.put("seriesName", "");
paramTable.put("instanceName", instanceName);
if("true".equalsIgnoreCase(isAutoName)){
	paramTable.put("isAutoName", "true");
	paramTable.put("seriesName", seriesName);
}
paramTable.put("Action", MCADGlobalConfigObject.FEATURE_RENAME);

MCADRenameHandler handler = new MCADRenameHandler(context, paramTable, integSessionData, integrationName, false);
//IEFBrowserCommandsManager brwManr = new IEFBrowserCommandsManager(null);
String resp = handler.executeCommand();
//IEFServerResponse  resp =brwManr.executeBrowserCommand(paramTable,  "",  integSessionData);
//String resp =(String) handler.getServerResponse();
//String respCode =resp.getResponseCode();

String messageStatus	= "";
String messageHeader	= "";
String messageContent	= "";


StringTokenizer detailTokens = new StringTokenizer(resp, MCADAppletServletProtocol.HEXA_DELIT);

if(detailTokens.hasMoreTokens())
	messageStatus = detailTokens.nextToken();
if(detailTokens.hasMoreTokens())
	messageHeader = detailTokens.nextToken();
if(detailTokens.hasMoreTokens())
	messageContent = detailTokens.nextToken();

response.getWriter().write(messageContent.trim());
		
 %>

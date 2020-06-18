<%--  IEFMultiplePurgeAppletFreePost.jsp

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

String busId			= request.getParameter("busId"); 
String Command			= request.getParameter("Command");
String action	= request.getParameter("Action");
String integrationName			= request.getParameter("IntegrationName");
String busIdList			= request.getParameter("busIdList");

Hashtable paramTable = new Hashtable();
paramTable.put(MCADAppletServletProtocol.INTEGRATION_NAME, integrationName); 
paramTable.put("busId", busId);
paramTable.put("Command", Command);
paramTable.put("Action", action);
paramTable.put("busIdList", busIdList);

MCADPurgeBusinessObjectHandler handler = new MCADPurgeBusinessObjectHandler(context, paramTable, integSessionData, integrationName);

String resp = handler.executeCommand();

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

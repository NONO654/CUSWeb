<%--  MCADSaveAsAppletFreePost.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import = "com.matrixone.apps.domain.util.*" %>

<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.managers.* , com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.matrixone.json.JSONObject" %>
<%@page contentType="text/html; charset=UTF-8"%>
<%		

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
	
	String regEx			= request.getParameter("regEx");
	String replaceString	= request.getParameter("replaceStr");
	String objectId			= request.getParameter("objectId");
	String folderId			= request.getParameter("folderId");
	String integrationName	= request.getParameter("integrationName");
	String stdPart			= request.getParameter("stdPart");
	String cadModelSeries	= request.getParameter("cadmodelseries");
	String cadDrwSeries		= request.getParameter("caddrawseries");
	String objectIds		= request.getParameter("objectIds");
	String silentSaveAs		="true";

	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
 String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
	HashMap inputDetailsMap = new HashMap();
	inputDetailsMap.put("StdPart",stdPart);
	inputDetailsMap.put("folderId",folderId);
	inputDetailsMap.put("regEx",regEx);
	inputDetailsMap.put("replaceString",replaceString);
	inputDetailsMap.put("cadDrwSeries",cadDrwSeries);
	inputDetailsMap.put("cadModelSeries",cadModelSeries);
	inputDetailsMap.put("IntegrationName",integrationName);
	inputDetailsMap.put("silentSaveAs",silentSaveAs);
	inputDetailsMap.put("objectIds",objectIds);	
	IEFSaveAsManager saveAsManager = new IEFSaveAsManager(new Hashtable());
	JSONObject retObject = new JSONObject();
	retObject  = saveAsManager.executeSaveAs(context,objectId,inputDetailsMap,globalConfigObject,integSessionData,true);
	System.out.println("retObject: " + retObject);
	response.getWriter().write(retObject.toString());

%>

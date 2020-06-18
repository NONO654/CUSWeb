<%--  emxReadAjaxCall.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@ page import="com.matrixone.jdom.*,com.matrixone.jdom.output.*,com.matrixone.apps.framework.ui.UITableIndentedUtil"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.Json"%>

<%@ page import = "matrix.db.*, matrix.util.*,
				   com.matrixone.util.*,
				   com.matrixone.servlet.*,
				   com.matrixone.apps.framework.ui.*,
				   com.matrixone.apps.domain.util.*,
				   com.matrixone.apps.domain.*,
				   java.util.*,
				   java.io.*,
				   java.util.*,
				   com.matrixone.jsystem.util.*"%>
<%

//Added code to support the Global Search 
String cmddName = emxGetParameter(request, "cmddName");
if(cmddName!=null && "AEFTypesGlobalSearchCommand".equalsIgnoreCase(cmddName)){
	HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
	Vector userRoleList = PersonUtil.getAssignments(context);
	String stToolbar = emxGetParameter(request, "toolbar");
	String language = request.getHeader("Accept-Language");
	
	JsonObjectBuilder shortcutJson = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	HashMap params = new HashMap();
	JsonArray objectJsonArr  = null;
	JsonArray collectioArr = UIUtil.getObjectCategoryJson(context,"", cmddName, application, session, request, objectJsonArr);
	shortcutJson.add("collections",collectioArr);
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(shortcutJson.build().toString());
	return;
	}

if(cmddName!=null && "AEFCollabSpace".equalsIgnoreCase(cmddName)){
	HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
	String language = request.getHeader("Accept-Language");
	JsonArray collectioArr = PersonUtil.getCollaborativeSpaceCommands_New(context);
	
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(collectioArr.toString());
	return;
	}
%>

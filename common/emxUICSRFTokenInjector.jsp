<%--  emxUICSRFTokenInjector.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.JsonObject"%>
<%@include file = "emxNavigatorInclude.inc"%>

<%
	JsonObject CSRFTokenJson = ENOCsrfGuard.getCSRFTokenJson_New(context,session);
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(CSRFTokenJson.toString());
%>


<%--  emxIndentedTable.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.framework.ui.UITableIndented"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.Json"%>
<%@page import="java.io.StringReader"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
try {
    // 1. get received JSON data from request
    BufferedReader br = new BufferedReader(new InputStreamReader(request.getInputStream()));
    String json = "";
    if(br != null){
        json = br.readLine();
    }
    // 2. Get drag and drop objects from request.
    JsonReader jsonReader = Json.createReader(new StringReader(json));
	JsonObject objIn = jsonReader.readObject();
	jsonReader.close();
	JsonObject dragInfo = objIn.getJsonObject("drag");
	JsonObject dropInfo = objIn.getJsonObject("drop");
	
    // 3. Call drop process
    JsonObject ret = indentedTableBean.dropProcess(context, dragInfo, dropInfo);
    // 4 set output
    out.clear();
    response.setContentType("application/json; charset=UTF-8");
    out.print(ret);
	out.flush();
} catch (Exception ex) {
    // 5. pass error massage back
    out.clear();
    response.setContentType("application/json; charset=UTF-8");
    String value = "{result: 'error',  message: '" + ex.getMessage() + "'}";
    JsonReader jsonReader = Json.createReader(new StringReader(value));
	JsonObject objOut = jsonReader.readObject();
	jsonReader.close();
    out.print(objOut);
	out.flush();
    ex.printStackTrace();
} 
%>

<%--  emxEngrBOMCopyToPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ page import="java.util.HashMap"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
String timeStamp = emxGetParameter(request, "timeStamp");

HashMap tableData = indentedTableBean.getTableData(timeStamp);
HashMap requestMap = indentedTableBean.getRequestMap(timeStamp);

requestMap.put("XMLINFO", (String)session.getAttribute("XMLINFO"));
session.removeAttribute("XMLINFO");
request.setAttribute("requestMap", requestMap);

%>







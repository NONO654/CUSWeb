 <%--  DMCPlanningValidationProcess.jsp

   Copyright (c) 1999-2018 Dassault Systemes.

   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
 --%>

<%@page import="com.matrixone.apps.dmcplanning.Product"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%
out.clear();
response.setContentType("text/plain; charset=UTF-8");

boolean strOut = false;
String objId = emxGetParameter(request, "objectID");
strOut =Product.isObsoleteState(context, objId);
out.println(strOut);
%>




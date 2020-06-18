<%--  DMCPlanningCommonInclude.inc

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
--%>

<%@include file = "../emxTagLibInclude.inc"%>
<%
String acceptLanguage = request.getHeader("Accept-Language");

//Code to be inserted for the bundle to be read from prop file.
String bundle = "dmcplanningStringResource";
String DateFrm = "";

%>
<%-- XSSOK--%>
<framework:localize id="i18nId" bundle="dmcplanningStringResource" locale='<%=acceptLanguage%>'/>




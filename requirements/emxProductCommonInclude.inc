<%--  emxProductCommonInclude.inc

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/emxProductCommonInclude.inc 1.2.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$"

--%>

<%@include file = "../emxTagLibInclude.inc"%>
<%
String acceptLanguage = request.getHeader("Accept-Language");

//Code to be inserted for the bundle to be read from prop file.
String bundle = "emxRequirementsStringResource";
String DateFrm = "";

%>

<framework:localize id="i18nId" bundle="emxRequirementsStringResource"
        locale='<%=acceptLanguage%>'/><%--XSSOK--%>




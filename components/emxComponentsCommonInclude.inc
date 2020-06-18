<%--  emxComponentsCommonInclude.inc

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = "$Id: emxComponentsCommonInclude.inc.rca 1.5 Wed Oct 22 16:18:05 2008 przemek Experimental przemek $"

--%><%@include file = "../emxTagLibInclude.inc"%><%
final String acceptLanguage = request.getHeader("Accept-Language");

//Code to be inserted for the bundle to be read from prop file.
String bundle = "emxComponentsStringResource";

%>
<!-- //XSSOK -->
<framework:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%=acceptLanguage%>'/>

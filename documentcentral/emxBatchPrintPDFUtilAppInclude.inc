<%--  emxBatchPrintPDFUtilAppInclude.jsp   -   Top include file for Batch Print/PDF Suite
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains prorietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   Description: Top include file for Batch Print/PDF Suite
   Parameters : None

   Author     : Devon Jones
   Date       : 02/05/2003

   History    :

   static const char RCSID[] = $Id: emxBatchPrintPDFUtilAppInclude.inc.rca 1.5 Wed Oct 22 15:53:04 2008 przemek Experimental przemek $
--%>


<%
  /*
  Section 1:optional Import Statement
  */
%>

<%@page import = "com.matrixone.apps.domain.util.*" %>
<%@page import = "com.matrixone.apps.domain.*" %>
<%@page import = "com.matrixone.apps.framework.taglib.*" %>
<%@page import = "com.matrixone.servlet.*" %>
<%@page import = "java.lang.*" %>
<%@page import = "java.util.*" %>
<%@page import = "javax.servlet.http.*" %>
<%@page import = "matrix.db.*" %>
<%@page import = "matrix.util.*" %>

<%@include file = "../emxTagLibInclude.inc"%> 

<%
  //Localization stuff
  String appDirectory = null;

  Properties properties = (Properties) application.getAttribute("eMatrixProperties");
  if (appDirectory == null && properties != null) {
    appDirectory = properties.getProperty("eServiceSuiteLibraryCentral.Directory");
  }
%>

<%-- Begin Localization --%>
<%-- XSSOK --%>
<emxUtil:localize id="i18nId" bundle="emxDocumentCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%-- End Localization --%>



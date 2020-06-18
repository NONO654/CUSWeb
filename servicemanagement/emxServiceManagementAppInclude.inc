<%--  emxServiceManagementUtilAppInclude.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxServiceManagementAppInclude.inc 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.taglib.*" 
                   errorPage="../common/emxNavigatorErrorPage.jsp"%>

<%@include file = "../emxTagLibInclude.inc"%>

<%
   final String appDirectory = (String)FrameworkProperties.getProperty(context,"eServiceSuiteServiceManagement" + ".Directory");
  final String sLanguage = request.getHeader("Accept-Language");
%>
<%-- //XSSOK --%>
<emxUtil:localize id="i18nId" bundle="emxWSManagementStringResource" locale='<%= sLanguage %>' />

<%--  
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@  include file = "../emxUICommonAppInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<%
String orgName = emxGetParameter(request,"orgName");
String strLanguage = request.getHeader("Accept-Language");
String strMQL = "list role \"" + orgName + "\";";
boolean orgNameExists = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context, strMQL, true).trim().length() > 0;
String i18NOrgNameExists = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Profiling.OrganizationAlreadyExists"); 

String result = "<result>success</result>";
String message = "<errorMsg><![CDATA[]]></errorMsg>";

if (orgNameExists) {
    result = "<result>fail</result>";
    message = "<errorMsg> <![CDATA["+i18NOrgNameExists+ "]]> </errorMsg>";            
} 
out.clear();
out.println("<mxOrgNameCheck>" + result + message +"</mxOrgNameCheck>");
%>

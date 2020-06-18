<%--
   emxNavigator403ErrorPage.jsp -- error page referenced by web.xml on the CLOUD

   Copyright (c) 1992-2012 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxNavigator403ErrorPage.jsp.rca 1.8 Wed Oct 22 15:48:38 2008 przemek Experimental przemek $";
--%>

<%@ page import="java.util.Enumeration" isErrorPage="true"%>
<%@ page import = "com.matrixone.apps.domain.util.Request" isErrorPage="true"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" isErrorPage="true"%>
<%@ page import = "com.matrixone.servlet.Framework" isErrorPage="true"%>
<%@ page import = "com.matrixone.servlet.MatrixServletException" isErrorPage="true"%>
<!DOCTYPE html>
<!-- Navigator 403 Error Page -->
<html>
<head>
<%
String contextPath = request.getContextPath();
%>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%--
<link rel="stylesheet" type="text/css" href="<%=Framework.getClientSideURL(response, "common/styles/emxUIDefault.css")%>"/>
--%>
<style>
body.errorNotice {
	font:normal 12px Verdana, Geneva, sans-serif;
}

#messageBox {
	margin: 50px;
	
	filter: progid:DXImageTransform.Microsoft.dropShadow(color=#818181, offX=17, offY=17, positive=true);
	box-shadow: 7px 7px 8px #818181;
	-webkit-box-shadow: 7px 7px 8px #818181;
	-moz-box-shadow: 7px 7px 8px #818181;
	
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#FFFFFF endColorstr=#DDDDDD);
	background:-webkit-gradient(linear, left top, left bottom, from(#fff), to(#ddd));
	background:-moz-linear-gradient(top, #fff, #ddd);
	
	-moz-border-radius: 10px;
	-webkit-border-radius: 10px;
	-khtml-border-radius: 10px;
	border-radius: 10px;
	
	padding: 10px 20px 20px 20px;
	max-width: 50%;
	min-width: 300px;
	text-align:center;
		
	font: 16px Arial, Geneva, sans-serif;
		
	margin-left: auto;
	margin-right: auto;
	border: solid 4px #C30;
}
.errorNumber {
	font: bold 20px Arial, Geneva, sans-serif;
}
.errorReason {
	color: red;
}
</style>
</head>
<body class="errorNotice">
<%
	String languageStr  = Request.getLanguage(request);
	String errorMessage =  UINavigatorUtil.getI18nString("emxFramework.403.Error","emxCloudStringResource",languageStr);
	String errorDiag    =  UINavigatorUtil.getI18nString("emxFramework.403.Message","emxCloudStringResource",languageStr);
	String errorAdvice  =  UINavigatorUtil.getI18nString("emxFramework.403.Advice","emxCloudStringResource",languageStr);
	//String errorReasonKey =  UINavigatorUtil.getI18nString("emxFramework.403.Reason","emxCloudStringResource",languageStr);
    //if (errorReasonKey==null) errorReasonKey = "Reason";

	String errorReason  =  (String)request.getAttribute("javax.servlet.error.message");
%>

<div id="messageBox">
<div class="errorNumber">
<%
    String user = null;
    if (request.getUserPrincipal() != null) {
        user = request.getUserPrincipal().getName();
    }
    else {
        user = request.getRemoteUser();
    }
    if (session != null) {
        session.invalidate();
    }
%>
<span>
<%=errorMessage%>
<% if (user!=null) { %>
"<%=user%>"
<% } %>
</span>
</div>
<div>
<%=errorDiag%>
</div>
<% if (errorAdvice!=null && !errorAdvice.isEmpty()) { %>
<div>
<%=errorAdvice%>
</div>
<% } %>
<% if (errorReason!=null && !errorReason.isEmpty()) { %>
<hr/>
<div class="errorReason">
    <img src="<%=Framework.getClientSideURL(response, "common/images/iconStatusError.gif")%>"/>
    <%=errorReason%>
</div>
<%
    response.setHeader("X-3DSLogin-error", errorReason);
    String dbg = (String)request.getHeader("X-debug");
    String errorCause = null;
    MatrixServletException servletException = Framework.getError(request);
    if (servletException != null) {
        errorCause = servletException.getMessage();
    }
    if ( errorCause != null ) {
        response.setHeader("X-3DSLogin-error-cause", errorCause);
        if ("true".equals(dbg)) {
%>
<div> [Cause] <%=errorCause%> </div>
<%
        }
    }
} 
%>
</div>
</body>
</html>


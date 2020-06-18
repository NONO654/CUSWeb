<%--  emxAppletTimeOutErrorFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file = "MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
    MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
	String acceptLanguage		= request.getHeader("Accept-Language");
	String I18NResourceBundle	= "emxIEFDesignCenterStringResource";
	String errorMessage			= UINavigatorUtil.getI18nString("emxIEFDesignCenter.Common.ERROR", "emxIEFDesignCenterStringResource", acceptLanguage);
	String featureName			= Request.getParameter(request,"featureName");
	if(featureName == null)
		featureName = "";
%>

<html>
<head>
<!--XSSOK-->
<title><%=errorMessage%></title>

</head>
<frameset rows="55,*,55" frameborder="no" framespacing="2">	
	<frame name="headerFrame" src="emxAppletTimeOutErrorHeader.jsp" marginwidth="4" marginheight="1"/>
	<frame name="contentFrame" src="emxAppletTimeOutErrorPage.jsp?featureName=<%=XSSUtil.encodeForURL(context,featureName)%>" marginwidth="4" marginheight="1"/>
	<frame name="footerFrame" src="emxAppletTimeOutErrorFooter.jsp"  marginwidth="0" marginheight="0" noresize="noresize" scrolling="no"/>
</frameset>
</html>

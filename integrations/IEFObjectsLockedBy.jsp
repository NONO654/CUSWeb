<%--  IEFObjectsLockedBy.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>


<%
	String sIntegName =Request.getParameter(request,"integrationName");
	String portalMode =Request.getParameter(request,"portalMode");
	
	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	Context context								= integSessionData.getClonedContext(session);

	String acceptLanguage = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
       	String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(sIntegName == null || sIntegName.length() == 0)
		{
			sIntegName = "";

        	String errorMessage2 = serverResourceBundle.getString("mcadIntegration.Server.Message.CriticalError") +  serverResourceBundle.getString("mcadIntegration.Server.Message.FailedToGetGlobalConfigObject");
			emxNavErrorObject.addMessage(errorMessage2);
		}
	}
%>
</head>
<body>

<form name="lockedByForm" action="../iefdesigncenter/emxInfoTable.jsp" method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>


	<input type="hidden" name="program" value="IEFObjectsLockedBy:getList">
	<input type="hidden" name="table" value="IEFDefault">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="sortColumnName" value="name">
	<input type="hidden" name="Sortdirection" value="ascending">
	<input type="hidden" name="targetLocation" value="content">
	<input type="hidden" name="selection" value="multiple">
	<input type="hidden" name="topActionbar" value="IEFObjectRelatedDrawingsTopActionBarActions">
	<!--XSSOK-->
	<input type="hidden" name="header" value="<%= integSessionData.getStringResource("mcadIntegration.Server.Heading.LockedObjects") %>">
	<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%= sIntegName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="emxhelplockedobjects">
	<!--XSSOK-->
	<input type="hidden" name="funcPageName" value="<%= MCADGlobalConfigObject.PAGE_MY_LOCKED_OBJECTS %>">
	<% if (null != portalMode) { %>
        <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%= portalMode %></xss:encodeForHTMLAttribute>">
<% } %>
</form>

<%@include file = "MCADBottomErrorInclude.inc"%>
<%
	if ((emxNavErrorObject.toString()).trim().length() == 0)
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
	document.lockedByForm.submit();
	</SCRIPT>
<%
	}
%>

</body>
</html>

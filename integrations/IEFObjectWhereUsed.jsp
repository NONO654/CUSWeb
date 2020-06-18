<%--  IEFObjectWhereUsed.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ include file="../emxTagLibInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>

<%

	String objectID		=Request.getParameter(request,"objectId");
	String relnshipName =Request.getParameter(request,"relName");
	String end			=Request.getParameter(request,"end");
	String headerKey	=Request.getParameter(request,"header");	
	String instanceName	=Request.getParameter(request,"instanceName");	
	String target		=Request.getParameter(request,"targetFrame");
	String helpMarker	=Request.getParameter(request,"HelpMarker");
	String funcPageName	=Request.getParameter(request,"funcPageName");
	String table		=Request.getParameter(request,"table");
	String topActionbar =Request.getParameter(request,"topActionbar");
	String portalMode	=Request.getParameter(request,"portalMode");
        String categoryTree =Request.getParameter(request,"categoryTreeName");
    String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");

	if (null == table)
	{
	   table = "IEFDefault";
	}
	if (null == topActionbar)
	{
	   topActionbar = "IEFObjectRelatedDrawingsTopActionBarActions";
	}

	String integrationName		= "";
	String headerString			= "";
	String actualObjectIDToWork = "";

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context								= null;
	String acceptLanguage = request.getHeader("Accept-Language");

	if(integSessionData == null)
	{
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
context = Framework.getFrameContext(session);
        String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target="content";
	 context = integSessionData.getClonedContext(session);
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName	= util.getIntegrationName(context, objectID);
		headerString	= integSessionData.getStringResource(headerKey);
	}
%>
</head>
<body>
<form name="whereUsedForm" action="../iefdesigncenter/emxInfoTable.jsp" method="post">

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
	<input type="hidden" name="program" value="IEFObjectWhereUsed:getList">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="sortColumnName" value="name">
	<input type="hidden" name="Sortdirection" value="ascending">
	<input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%= target %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="multiple">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="header" value="<%= headerString %>">
	<input type="hidden" name="relationship" value="<xss:encodeForHTMLAttribute><%= relnshipName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="end" value="<xss:encodeForHTMLAttribute><%= end %></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="integrationName" value="<%= integrationName %>">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="languageStr" value="<%= acceptLanguage %>">
	<input type="hidden" name="instanceName" value="<xss:encodeForHTMLAttribute><%= instanceName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="showAllTables" value="false">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
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
		document.whereUsedForm.submit();
	</SCRIPT>
<%
	}
%>

</body>
</html>

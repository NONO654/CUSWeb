<%--  IEFPurge.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,matrix.db.*" %>

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
	String funcPageName	=Request.getParameter(request,"funcPageName");
	String sHelpMarker  =Request.getParameter(request,"help");
	String portalMode	=Request.getParameter(request,"portalMode");

	String integrationName		= "";
	String headerString			= "";
	String actualObjectIDToWork = "";
	String sSuitKey  = "DesignerCentral";

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String acceptLanguage = request.getHeader("Accept-Language");
	Context context    = integSessionData.getClonedContext(session);
	
	if(integSessionData == null)
	{
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

        String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target="popup";
	
		MCADMxUtil util	= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName	= util.getIntegrationName(integSessionData.getClonedContext(session), objectID);
		headerString	= integSessionData.getStringResource(headerKey);
		
	    session.setAttribute("GCO",integSessionData.getGlobalConfigObject(integrationName,context));
	    session.setAttribute("LCO",integSessionData.getLocalConfigObject());
	    session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(context));
	  
	}
%>
</head>
<body>
    <form name="purgeForm" action="../common/emxTable.jsp"> 


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
	<input type="hidden" name="table" value="IEFPurgeTable">
	<input type="hidden" name="pagination" value="0">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="sortColumnName" value="name">
	<input type="hidden" name="Sortdirection" value="ascending">
	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%= target %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="multiple">
	<input type="hidden" name="topActionbar" value="IEFObjectPurgeTopActionBarActions">
    <input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= headerString %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="relationship" value="<xss:encodeForHTMLAttribute><%= relnshipName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="end" value="<xss:encodeForHTMLAttribute><%= end %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%= integrationName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%= acceptLanguage %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="instanceName" value="<xss:encodeForHTMLAttribute><%= instanceName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=sHelpMarker%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=sSuitKey%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="showAllTables" value="false">
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
		document.purgeForm.submit();
	</SCRIPT>
<%
	}
%>

</body>
</html>

<%--  emxIEFTable.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>

<%
	String sIntegName	= request.getParameter("integrationName");
	Context context		= null;
	java.util.Enumeration itl = request.getParameterNames();
       
	String sTopActionBar					= request.getParameter("topActionbar");
	String sHeader							= request.getParameter("header");
	String sProgram							= request.getParameter("program");
	String sInquiry							= request.getParameter("inquiry");
	String sTable							= request.getParameter("table");
	String sPortalMode						= request.getParameter("portalMode");
	String sPortalCmdName					= request.getParameter("portalCmdName");
	String sFilterFramePage					= request.getParameter("FilterFramePage");
	String sFilterFrameSize					= request.getParameter("FilterFrameSize");
	String sObjectId						= request.getParameter("objectId");
	String sParentOID						= request.getParameter("parentOID");
	String sSuiteKey						= request.getParameter("suiteKey");
	String sTarget							= request.getParameter("Target Location");
	String sRelName							= request.getParameter("relName");
	String sTargetFrame						= request.getParameter("targetFrame");
	String sInstanceName					= request.getParameter("instanceName");
	String sRelEnd							= request.getParameter("end");
	String sSortColumnName                  = request.getParameter("sortColumnName");
	String sSortDirection                   = request.getParameter("sortDirection");
	String sShowIntegrationOption           = request.getParameter("showIntegrationOption");
	String funcPageName						= request.getParameter("funcPageName");
	String isPortal							= request.getParameter("isPortal");
	String sShowWSTable						= request.getParameter("showWSTable");
	String sHelpMarker						= request.getParameter("HelpMarker");
	String programLabel                     = request.getParameter("programLabel");
	String selection						= request.getParameter("selection");
	String featureName						= request.getParameter("featureName");
	String portalMode						= request.getParameter("portalMode");
	String showAllTables					= "false";

	funcPageName = (funcPageName == null) ? "" : funcPageName;
	featureName	 = (featureName == null) ? funcPageName : featureName;
	sIntegName	 = (sIntegName == null) ? "" : sIntegName;

	if(selection == null || selection.equals(""))
		selection = "multiple";

	if(isPortal == null)
		isPortal = "false";
	

    sSortColumnName			= (sSortColumnName == null || sSortColumnName.length() == 0) ? "name" : sSortColumnName;
    sSortDirection			= (sSortDirection == null || sSortDirection.length() == 0) ? "ascending" : sSortDirection;
    sShowIntegrationOption  = (sShowIntegrationOption  == null || sShowIntegrationOption.length() == 0) ? "false" : sShowIntegrationOption;

	sTable	= (sTable == null) ? "DSCDefault" : sTable;
	sTarget = (sTarget == null) ? "popup" : sTarget;
    sHeader = (sHeader == null) ? "" : sHeader;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);

	String errorMessage = "";	
	
	if(integSessionData == null)
	{
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(request.getHeader("Accept-Language"));
		errorMessage								  = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	
	//stuff required for showing MyLockedObjects and RecentlyCheckedInFiles
	if(!integSessionData.isNonIntegrationUser() && sIntegName.length() == 0)
	{
		MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
		String[] init = new String[] {};
		String jpoName = "DSC_CommonUtil";
		// get the Integration Assignment from user's Local Config Object
		// if Integration Assignment is not default. The first one in the
		// list will be selected
		String jpoMethod = "getDefaultIntegrationAssignment";
		HashMap paramMap = new HashMap();
		paramMap.put("LCO", (Object)localConfigObject);
		context = Framework.getFrameContext(session);
		Map result = (Map)JPO.invoke(context, jpoName, init, jpoMethod, 
							JPO.packArgs(paramMap), Map.class);
		sIntegName = (String)result.get("integrationName");

		if(sShowIntegrationOption.equals("false"))
			showAllTables = "true";
	}

	String isFeatureAllowed	= integSessionData.isFeatureAllowedForIntegration(sIntegName, featureName);
	if(!isFeatureAllowed.startsWith("true") && sIntegName.equals(""))
	{
		String errorPage	= "/integrations/emxAppletTimeOutErrorPage.jsp?featureName="+featureName;
%> 
        <jsp:forward page="<%=XSSUtil.encodeForHTML(context,errorPage)%>" />              
<%
	}

	sProgram = (sProgram == null) ? "" : sProgram;
	sIntegName = (sIntegName == null) ? "" : sIntegName;
%>
</head>
<body>

<form name="emxIEFTableForm" action="../iefdesigncenter/emxInfoTable.jsp" method="post">

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


		
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=sSortColumnName%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortDirection" value="<xss:encodeForHTMLAttribute><%=sSortDirection%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%= sTopActionBar %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= sHeader %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="WSTable" value="">
	<!--XSSOK-->
	<input type="hidden" name="integrationName" value="<%= sIntegName %>">
	<input type="hidden" name="showIntegrationOption" value="<xss:encodeForHTMLAttribute><%=sShowIntegrationOption%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="isPortal" value="<xss:encodeForHTMLAttribute><%=isPortal%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="programLabel" value="<xss:encodeForHTMLAttribute><%=programLabel%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="showAllTables" value="<%=showAllTables%>">
<% if (null != sProgram) { %>
        <input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=sProgram%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sInquiry) { %>
        <input type="hidden" name="inquiry" value="<xss:encodeForHTMLAttribute><%=sInquiry%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sTable) { %>
        <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=sTable%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sPortalCmdName) { %>
        <input type="hidden" name="portalCmdName" value="<xss:encodeForHTMLAttribute><%=sPortalCmdName%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sPortalMode) { %>
        <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=sPortalMode%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sSuiteKey) { %>
        <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=sSuiteKey%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sFilterFramePage) { %>
        <input type="hidden" name="FilterFramePage" value="<xss:encodeForHTMLAttribute><%=sFilterFramePage%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sFilterFrameSize) { %>
        <input type="hidden" name="FilterFrameSize" value="<xss:encodeForHTMLAttribute><%=sFilterFrameSize%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sObjectId) { %>
        <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjectId%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sParentOID) { %>
        <input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=sParentOID%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sTarget) { %>
        <input type="hidden" name="Target Location" value="<xss:encodeForHTMLAttribute><%=sTarget%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sRelName) { %>
        <input type="hidden" name="relationship" value="<xss:encodeForHTMLAttribute><%=sRelName%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sTargetFrame) { %>
        <input type="hidden" name="targetFrame" value="<xss:encodeForHTMLAttribute><%=sTargetFrame%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sInstanceName) { %>
        <input type="hidden" name="instanceName" value="<xss:encodeForHTMLAttribute><%=sInstanceName%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sRelEnd) { %>
        <input type="hidden" name="end" value="<xss:encodeForHTMLAttribute><%=sRelEnd%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != sPortalCmdName) { %>
        <input type="hidden" name="portalCmdName" value="<xss:encodeForHTMLAttribute><%=sPortalCmdName%></xss:encodeForHTMLAttribute>">
<% } %>
<% if(null != sShowWSTable) { %>
		<input type="hidden" name="showWSTable" value="<xss:encodeForHTMLAttribute><%=sShowWSTable%></xss:encodeForHTMLAttribute>">
<% } %>
<% if(null != sHelpMarker) { %>
		<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=sHelpMarker%></xss:encodeForHTMLAttribute>">
<% } %>
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
	document.emxIEFTableForm.submit();
	</SCRIPT>
<%
	}
%>

</body>
</html>

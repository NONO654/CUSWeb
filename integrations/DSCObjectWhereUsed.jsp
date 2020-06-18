<%--  DSCObjectWhereUsed.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<html>
<head>
<%@ page import="com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	String objectID				=Request.getParameter(request,"objectId");
	String typeName		        =Request.getParameter(request,"typeName");	
	String headerKey			=Request.getParameter(request,"header");	
	String instanceName			=Request.getParameter(request,"instanceName");	
	String target				=Request.getParameter(request,"targetFrame");
	String level				=Request.getParameter(request,"level");
	String filterFramePage		=Request.getParameter(request,"FilterFramePage");
	String filterFrameSize		=Request.getParameter(request,"FilterFrameSize");
	String tableFilter			=Request.getParameter(request,"TableFilter");
	String relName				=Request.getParameter(request,"relName");
	String funcPageName			=Request.getParameter(request,"funcPageName");
	java.util.Enumeration itl	= emxGetParameterNames(request);
	String helpMarker			=Request.getParameter(request,"HelpMarker");	
	String suiteKey				=Request.getParameter(request,"suiteKey");
	String featureName			= MCADGlobalConfigObject.FEATURE_WHERE_USED;
	String portalMode			=Request.getParameter(request,"portalMode");
	String sortColumnName		=Request.getParameter(request,"sortColumnName");
	String categoryTree =Request.getParameter(request,"categoryTreeName");
	String printerFriendly		=Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;
	String suiteDirectory	 	= Request.getParameter(request,"emxSuiteDirectory");
	typeName		= (typeName == null) ? "CADSubcomponent" : typeName;
	filterFramePage	= (filterFramePage == null) ? "../integrations/DSCWhereUsedFilter.jsp" : filterFramePage;
	filterFrameSize	= (filterFrameSize == null) ? "40" : filterFrameSize;
	headerKey		= (headerKey == null) ? "emxIEFDesignCenter.Common.WhereUsed" : headerKey;
	level			= (level == null) ? "1" : level;
	funcPageName	= (funcPageName == null) ? "WhereUsed" : funcPageName;
	helpMarker		= (helpMarker == null) ? "emxhelpdscwhereused" : helpMarker;

	if (tableFilter != null)
	{
	}
	else
	{	   
	   if (level != null)
	   {
		  tableFilter = "filterLevel=UpTo:" + level;
	   }
	}
	String integrationName		= "";
	String headerString			= "";
	String actualObjectIDToWork = "";
	String relDirection			= "";
	String relnshipName			= "";
	String errorMessage			= "";

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage							= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);


	if(integSessionData == null)
	{
        errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		//emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target="content";
		Context context = integSessionData.getClonedContext(session);
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName	= util.getIntegrationName(context, objectID);
		headerString	= integSessionData.getStringResource(headerKey);
		if (integrationName == null || "".equals(integrationName))
		{
			errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.FailedToGetIntegName");
		}
		else
		{
			String isFeatureAllowed			= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
			if(!isFeatureAllowed.startsWith("true"))
			{
				errorMessage = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
			}

			try
			{
				MCADGlobalConfigObject  globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName, context);
			}
			catch(Exception e)
			{
				errorMessage = e.getMessage();
			}
		}
	}
%>
</head>
<body>
<form name="whereUsedForm" action="../common/emxTable.jsp" style="height: 100px">
	<input type="hidden" name="program" value="DSCWhereUsed:getList">
	<input type="hidden" name="table" value="DSCWhereUsed">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="sortColumnName" value="">
	<input type="hidden" name="Sortdirection" value="descending">
	<input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%= target %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="multiple">
	<input type="hidden" name="toolbar" value="DSCMCADWhereUsedTopActionBarActions">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= headerKey %></xss:encodeForHTMLAttribute>">
		<!--XSSOK-->
	<input type="hidden" name="end" value="<%= relDirection %>">	
	<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%= integrationName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%= acceptLanguage %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="instanceName" value="<xss:encodeForHTMLAttribute><%= instanceName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="level" value="<xss:encodeForHTMLAttribute><%= level %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= suiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="showAllTables" value="false">
	<input type="hidden" name="objectCompare" value="false">
	<input type="hidden" name="multiColumnSort" value="false">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="refresh" value="true">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">

<% if(null != suiteDirectory) { %>
		<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
<% } %>

<% if (null != filterFramePage) { %>
        <input type="hidden" name="FilterFramePage" value="<xss:encodeForHTMLAttribute><%= filterFramePage %></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != filterFrameSize) { %>
        <input type="hidden" name="FilterFrameSize" value="<xss:encodeForHTMLAttribute><%= filterFrameSize %></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != tableFilter) { %>
        <input type="hidden" name="TableFilter" value="<xss:encodeForHTMLAttribute><%= tableFilter %></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != relName) { %>
        <input type="hidden" name="sRelationName" value="<xss:encodeForHTMLAttribute><%= relName %></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != portalMode) { %>
        <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%= portalMode %></xss:encodeForHTMLAttribute>">
<% } %>
</form>

<%@include file = "MCADBottomErrorInclude.inc"%>

<%
	if ("".equals(errorMessage.trim()))
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
		document.whereUsedForm.submit();
	</SCRIPT>
<%
	} else {
%>
	<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
	&nbsp;
      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
        <tr >
	  <!--XSSOK-->
          <td class="errorHeader"><%=serverResourceBundle.getString("mcadIntegration.Server.Heading.Error")%></td>
        </tr>
        <tr align="center">
       	  <!--XSSOK-->
          <td class="errorMessage" align="center"><%=errorMessage%></td>
        </tr>
      </table>
<%
	}
%>

</body>
</html>

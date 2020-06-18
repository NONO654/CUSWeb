<%--  IEFObjectRelatedObjects.jsp

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

<%
 matrix.db.Context contextGuard = Framework.getFrameContext(session);
%>


<%
	String objectID			 =Request.getParameter(request,"objectId");
	String program			 =Request.getParameter(request,"program");
	String table			 =Request.getParameter(request,"table");
	String headerKey		 =Request.getParameter(request,"header");
	String filterFramePage	         =Request.getParameter(request,"FilterFramePage");
	String filterFrameSize	         =Request.getParameter(request,"FilterFrameSize");
	String headerRepeat		 =Request.getParameter(request,"headerRepeat");
	String pagination		 =Request.getParameter(request,"pagination");
	String selection		 =Request.getParameter(request,"selection");
	String RelatedPage		 =Request.getParameter(request,"RelatedPage");
	String suiteKey			 =Request.getParameter(request,"suiteKey");
	String funcPageName		 =Request.getParameter(request,"funcPageName");
	String excludeRelNames	         =Request.getParameter(request,"excludeRelNames");
	String featureName		 = MCADGlobalConfigObject.FEATURE_RELATED_ITEMS;
	String categoryTree =Request.getParameter(request,"categoryTreeName");
	String target			 =Request.getParameter(request,"targetFrame");
	String helpMarker		 =Request.getParameter(request,"HelpMarker");
	String topActionbar		 =Request.getParameter(request,"topActionbar");
	String portalMode		 =Request.getParameter(request,"portalMode");
	String printerFriendly	 =Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");
        helpMarker	 = (helpMarker == null) ? "emxhelpviewrelateditems" : helpMarker;

	program			= (program == null) ? "IEFListConnectedObject:getList" : program;
	table			= (table == null) ? "IEFRelatedObjects" : table;
	headerKey		= (headerKey == null) ? "emxIEFDesignCenter.Header.RelatedObjects" : headerKey;
	headerRepeat	        = (headerRepeat == null) ? "0" : headerRepeat;
	pagination		= (pagination == null) ? "10" : pagination;
	filterFramePage         = (filterFramePage == null) ? "../integrations/IEFRelationshipFilter.jsp" : filterFramePage;
	filterFrameSize	        = (filterFrameSize == null) ? "80" : filterFrameSize;
	RelatedPage		= (RelatedPage == null) ? "true" : RelatedPage;
	suiteKey		= (suiteKey == null) ? "eServiceSuiteDesignerCentral" : suiteKey;
	funcPageName	        = (funcPageName == null) ? "RelatedItems" : funcPageName;
	excludeRelNames	        = (excludeRelNames == null) ? "Viewable" : excludeRelNames;


	String integrationName						= "";
	String headerString						= "";
	String actualObjectIDToWork					= "";
	String relDirection						= "";
	String relnshipName						= "";
	String errorMessage						= "";
	Hashtable MCADTypeRelMap					= new Hashtable();

	MCADGlobalConfigObject  globalConfigObject  = null;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
        errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	else
	{
		Context context = integSessionData.getClonedContext(session);
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName	= util.getIntegrationName(context, objectID);
		headerString	= integSessionData.getStringResource(headerKey);
		
		String isFeatureAllowed			= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
		if(!isFeatureAllowed.startsWith("true"))
		{
			errorMessage = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
		}
		else
		{
			try
			{			
				globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
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
<form name="whereUsedForm" action="../common/emxTable.jsp">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(contextGuard);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(contextGuard, session);
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

	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=program%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=headerKey%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="pagination" value="<xss:encodeForHTMLAttribute><%=pagination%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="headerRepeat" value="<xss:encodeForHTMLAttribute><%=headerRepeat%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="RelatedPage" value="<xss:encodeForHTMLAttribute><%=RelatedPage%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= suiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="excludeRelNames" value="<xss:encodeForHTMLAttribute><%= excludeRelNames %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="targetFrame" value="<xss:encodeForHTMLAttribute><%= target %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="integrationName" value="<%= integrationName %>">
	<!--XSSOK-->
	<input type="hidden" name="languageStr" value="<%= acceptLanguage %>">
	<input type="hidden" name="showAllTables" value="false">
	<input type="hidden" name="massPromoteDemote" value="false">
	<input type="hidden" name="expandLevelFilter" value="false">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">
    <input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
		
	<% if (null != portalMode) { %>
		<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%= portalMode %></xss:encodeForHTMLAttribute>">
	<% } %>
	<% if (null != filterFramePage) { %>
		<input type="hidden" name="FilterFramePage" value="<xss:encodeForHTMLAttribute><%= filterFramePage %></xss:encodeForHTMLAttribute>">
	<% } %>
	<% if (null != filterFrameSize) { %>
		<input type="hidden" name="FilterFrameSize" value="<xss:encodeForHTMLAttribute><%= filterFrameSize %></xss:encodeForHTMLAttribute>">
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

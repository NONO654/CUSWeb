<%--  IEFObjectRelatedParts.jsp

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

	String objectID			 =Request.getParameter(request,"objectId");
	String typeName			 =Request.getParameter(request,"typeName");	
	String headerKey		 =Request.getParameter(request,"header");
	String instanceName		 =Request.getParameter(request,"instanceName");	
	String target			 =Request.getParameter(request,"targetFrame");
	String helpMarker		 =Request.getParameter(request,"HelpMarker");
	String funcPageName		 =Request.getParameter(request,"funcPageName");
	String table			 =Request.getParameter(request,"table");
	String topActionbar		 =Request.getParameter(request,"topActionbar");
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");
	String suiteKey			 =Request.getParameter(request,"suiteKey");
	String featureName		 = MCADGlobalConfigObject.FEATURE_RELATED_PARTS;
	String portalMode		 =Request.getParameter(request,"portalMode");
	String categoryTree =Request.getParameter(request,"categoryTreeName");
	String printerFriendly	 =Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;

	table		 = (table == null) ? "IEFRelatedParts" : table;
	topActionbar = (topActionbar == null) ? "" : topActionbar;
	funcPageName = (funcPageName == null) ? "RelatedItems" : funcPageName;
	headerKey	 = (headerKey == null) ? "emxIEFDesignCenter.Header.RelatedParts" : headerKey;
	suiteKey	 = (suiteKey == null) ? "eServiceSuiteDesignerCentral" : suiteKey;
	helpMarker	   = (helpMarker == null) ? "emxhelpdscrelatedparts" : helpMarker;

	String integrationName						= "";
	String headerString							= "";
	String actualObjectIDToWork					= "";
	String relDirection							= "";
	String relnshipName							= "";
	String errorMessage							= "";

	Hashtable MCADTypeRelMap					= new Hashtable();

	MCADGlobalConfigObject  globalConfigObject	= null;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage						= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
Context _context = null;
	if(integSessionData == null)
	{
	_context = Framework.getFrameContext(session);
        errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		//emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target="content";

		 _context = integSessionData.getClonedContext(session);
		MCADMxUtil util	 = new MCADMxUtil(_context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName	 = util.getIntegrationName(_context, objectID);
		headerString	 = integSessionData.getStringResource(headerKey);
		
		String isFeatureAllowed			= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
		if(!isFeatureAllowed.startsWith("true"))
		{
			errorMessage = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
		}
		else
		{
			try
			{
				globalConfigObject						= integSessionData.getGlobalConfigObject(integrationName,_context);

				relDirection							= "to";
				relnshipName							= util.getActualNameForAEFData(_context, "relationship_PartSpecification");
			}
			catch(Exception e)
			{
				errorMessage = e.getMessage();
			}
			session.setAttribute("GCO",globalConfigObject);
			session.setAttribute("LCO",integSessionData.getLocalConfigObject());
			session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(_context));
		}
	}
	
%>


</head>
<body>
<form name="whereUsedForm" action="../common/emxIndentedTable.jsp">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(_context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(_context, session);
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

	<input type="hidden" name="program" value="IEFListConnectedObject:getList">
	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="0">
	<input type="hidden" name="sortColumnName" value="Name">
	<input type="hidden" name="sortDirection" value="ascending">
	<input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%= target %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= headerKey %></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="relationshipName" value="<%= relnshipName %>">
	<!--XSSOK-->
	<input type="hidden" name="toFrom" value="<%= relDirection %>">	
	<!--XSSOK-->
	<input type="hidden" name="integrationName" value="<%= integrationName %>">
	<input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%= acceptLanguage %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="instanceName" value="<xss:encodeForHTMLAttribute><%= instanceName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="RelatedPage" value="false">
	<input type="hidden" name="showWSTable" value="false">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= suiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="showAllTables" value="false">
	<input type="hidden" name="triggerValidation" value="false"> 
	<input type="hidden" name="massPromoteDemote" value="false">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
		
	<% if (null != portalMode) { %>
        <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%= portalMode %></xss:encodeForHTMLAttribute>">
<% } %>
</form>


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

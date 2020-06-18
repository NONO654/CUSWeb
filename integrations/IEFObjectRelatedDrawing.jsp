<%--  IEFObjectRelatedDrawing.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*"%>

<%@ include file="../common/emxNavigatorTopErrorInclude.inc" %>
<%@ include file = "../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>

<%
    Context context          = null;
	String objectID			 =Request.getParameter(request,"objectId");
	String typeName			 =Request.getParameter(request,"typeName");	
	String headerKey		 =Request.getParameter(request,"header");	
	String helpMarker		 =Request.getParameter(request,"HelpMarker");
	String table     		 =Request.getParameter(request,"table");
	String topActionbar		 =Request.getParameter(request,"topActionbar");
	String suiteKey			 =Request.getParameter(request,"suiteKey");
	String sortColumnName	 =Request.getParameter(request,"sortColumnName");
	String sortDirection	 =Request.getParameter(request,"sortDirection");
	String featureName		 = MCADGlobalConfigObject.FEATURE_RELATED_DRAWINGS;
	String selection		 =Request.getParameter(request,"selection");
	String portalMode		 =Request.getParameter(request,"portalMode");
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");
	String categoryTree =Request.getParameter(request,"categoryTreeName");
	String printerFriendly	 =Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;

	typeName	   = (typeName == null) ? "CADDrawing" : typeName;
	table   	   = (table == null) ? "DSCDefault" : table;
	topActionbar   = (topActionbar == null) ? "DSCMCADTopActionBar" : topActionbar;
	headerKey	   = (headerKey == null) ? "emxIEFDesignCenter.Header.RelatedDrawings" : headerKey;
	suiteKey	   = (suiteKey == null) ? "eServiceSuiteDesignerCentral" : suiteKey;
	helpMarker	   = (helpMarker == null) ? "emxhelpdscrelateddrawings" : helpMarker;
	selection 	   = (selection == null) ? "multiple" : selection;
	sortColumnName = (sortColumnName == null) ? "Name" : sortColumnName;
	sortDirection  = (sortDirection == null) ? "ascending" : sortDirection;
	portalMode	   = (portalMode == null) ? "false" : portalMode;

	String integrationName						= "";
	String headerString							= "";
	String errorMessage							= "";

	MCADGlobalConfigObject  globalConfigObject	= null;
	MCADLocalConfigObject  localConfigObject	= null;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
%>
		<SCRIPT LANGUAGE="JavaScript">
		window.location.href=window.location.href;
		</SCRIPT>
<%		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	else
	{
		context     = integSessionData.getClonedContext(session);
		MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName		= util.getIntegrationName(context, objectID);
		headerString		= integSessionData.getStringResource(headerKey);
		
		String isFeatureAllowed		= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
		localConfigObject		= integSessionData.getLocalConfigObject();
		try
		{


			if(isFeatureAllowed.startsWith("false"))
		{
			Hashtable exceptionDetails = new Hashtable();
			exceptionDetails.put("NAME",integSessionData.getStringResource("mcadIntegration.Server.Feature."+featureName));
			if(integSessionData.isNonIntegrationUser())
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.FeatureNotAllowedForNonIntegrationUser",exceptionDetails);
			else
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.FeatureNotAllowedForAssignedIntegrations",exceptionDetails);
		}
		else
		{
			globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);

			session.setAttribute("GCO",globalConfigObject);
			session.setAttribute("LCO", localConfigObject);
			session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(context));
				
			}
		}
		catch(Exception e)
		{
			errorMessage	= e.getMessage();
		}
	}
%>

</head>
<body>
<form name="whereUsedForm" action="../common/emxIndentedTable.jsp" >

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


	<input type="hidden" name="program" value="DSCRelatedDrawing:getParent">
	<input type="hidden" name="typeName" value="<xss:encodeForHTMLAttribute><%= typeName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="expandLevelFilter" value="false">
	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%= table %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=sortColumnName%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortDirection" value="<xss:encodeForHTMLAttribute><%=sortDirection%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= headerKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectCompare" value="false">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= suiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%= portalMode %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
</form>

<%@ include file="../common/emxNavigatorBottomErrorInclude.inc" %>

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


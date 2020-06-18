<%--  IEFObjectInstances.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*"%>

<%@ include file="../common/emxNavigatorTopErrorInclude.inc" %>
<%@ include file="../emxTagLibInclude.inc" %>

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
	String errorMessage		 = "";
	String featureName		 = MCADGlobalConfigObject.FEATURE_RELATED_INSTANCES;
	String portalMode		 =Request.getParameter(request,"portalMode");
	String sSuiteKey		 =Request.getParameter(request,"suiteKey");
	String topActionbar		 = Request.getParameter(request,"topActionbar");
	String categoryTree		 = Request.getParameter(request,"categoryTreeName");
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");

	table   	   = (table == null) ? "DSCDefault" : table;
	helpMarker	   = (helpMarker == null) ? "emxhelpdscinstances" : helpMarker;

	String integrationName						= "";
	String headerString							= "";
	String actualObjectIDToWork					= "";
	String relDirection							= "";
	String relnshipName							= "";

	Hashtable MCADTypeRelMap					= new Hashtable();

	MCADGlobalConfigObject  globalConfigObject	= null;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	Context context								= null;

	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
	context=Framework.getFrameContext(session);
		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target="content";

                context	= integSessionData.getClonedContext(session);
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName	= util.getIntegrationName(context, objectID);
		//headerString	= integSessionData.getStringResource(headerKey);
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
			else
			{
				session.setAttribute("GCO",integSessionData.getGlobalConfigObject(integrationName, context));
				session.setAttribute("LCO",integSessionData.getLocalConfigObject());
				session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(context));
			}
		}

	}

	   if(null != objectID && integSessionData != null) 
	   {
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		    if(!util.isMajorObject(context, objectID))
			  {
				//System.out.println("Inside IEFObject Instances IF.................");
				topActionbar   = "DSCInstancesTopActionBarForVersion"; 
			  }
			  else
				  topActionbar   = (topActionbar == null) ? "DSCDefaultTopActionBar" : topActionbar;
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

	<input type="hidden" name="program" value="DSCRelatedInstances:getChild">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="sortColumnName" value="Name">
	<input type="hidden" name="Sortdirection" value="ascending">
	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="targetLocation" value="<xss:encodeForHTMLAttribute><%= target %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="multiple">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=headerKey%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="integrationName" value="<xss:encodeForHTMLAttribute><%= integrationName %></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="languageStr" value="<%= acceptLanguage %>">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="typeName" value="<xss:encodeForHTMLAttribute><%= typeName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= sSuiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectCompare" value="false">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">

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

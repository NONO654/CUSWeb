<%--  DSCDerivedOutput.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*"%>

<%@ include file="../common/emxNavigatorTopErrorInclude.inc" %>
<%@ include file="../emxRequestWrapperMethods.inc" %>
<%@ include file="../emxTagLibInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>

<%
    String sIntegName   = Request.getParameter(request,"integrationName");
	Context context		= null;
    java.util.Enumeration itl = emxGetParameterNames(request);
       
    String sTopActionBar                    = Request.getParameter(request,"topActionbar");
    String sHeader                          = Request.getParameter(request,"header");
    String sProgram                         = null; // Request.getParameter(request,"program");
    String sInquiry                         = Request.getParameter(request,"inquiry");
    String sTable                           = Request.getParameter(request,"table");
    String sPortalMode                      = Request.getParameter(request,"portalMode");
    String sPortalCmdName                   = Request.getParameter(request,"portalCmdName");
    String sFilterFramePage                 = Request.getParameter(request,"FilterFramePage");
    String sFilterFrameSize                 = Request.getParameter(request,"FilterFrameSize");
    String sObjectId                        = Request.getParameter(request,"objectId");
    String sParentOID                       = Request.getParameter(request,"parentOID");
    String sSuiteKey                        = Request.getParameter(request,"suiteKey");
    String sTarget                          = Request.getParameter(request,"Target Location");
    String sRelName                         = Request.getParameter(request,"relName");
    String sTargetFrame                     = Request.getParameter(request,"targetFrame");
    String sInstanceName                    = Request.getParameter(request,"instanceName");
    String sRelEnd                          = Request.getParameter(request,"end");
    String sSortColumnName                  = Request.getParameter(request,"sortColumnName");
    String sSortDirection                   = Request.getParameter(request,"sortDirection");
    String sShowIntegrationOption           = Request.getParameter(request,"showIntegrationOption");
    String funcPageName                     = Request.getParameter(request,"funcPageName");
    String isPortal                         = Request.getParameter(request,"isPortal");
    String sShowWSTable                     = Request.getParameter(request,"showWSTable");
    String sHelpMarker                      = Request.getParameter(request,"HelpMarker");
	String featureName						= MCADGlobalConfigObject.FEATURE_DERIVED_OUTPUT;
    String categoryTree                     =Request.getParameter(request,"categoryTreeName");
	String suiteDirectory	 				= Request.getParameter(request,"emxSuiteDirectory");
    String printerFriendly                  = Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;
	String errorMessage							= "";
	//IR-460641: Drawing derived outputs not visible under EC Part
	String cadlist                 = Request.getParameter(request,"cadlist");

	isPortal = (isPortal == null) ? "false" : isPortal;
	
	sSortColumnName			= (sSortColumnName == null || sSortColumnName.length() == 0) ? "name" : sSortColumnName;
    sSortDirection			= (sSortDirection == null || sSortDirection.length() == 0) ? "ascending" : sSortDirection;
    sShowIntegrationOption  = (sShowIntegrationOption  == null || sShowIntegrationOption.length() == 0) ? "false" : sShowIntegrationOption;

	sTable	= (sTable == null) ? "DSCTableDerivedOutput" : sTable;
	sTarget = (sTarget == null) ? "popup" : sTarget;
    sHeader = (sHeader == null) ? "emxIEFDesignCenter.Common.DerivedOutput" : sHeader;
	sHelpMarker = (sHelpMarker == null) ? "featureDerivedOutputPage.HelpMarker" : sHelpMarker;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	context		= integSessionData.getClonedContext(session);
	
	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
	MCADGlobalConfigObject globalConfigObject	  = null;
	IEFConfigUIUtil iefConfigUIUtil               = null;
	boolean isCreateDerivedOutputObj			  = true;
	String selection							  = "multiple";

	if(integSessionData == null)
	{
%> 
 	   <SCRIPT LANGUAGE="JavaScript">
			window.location.href=window.location.href;
		</SCRIPT>
<%
	errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	else
	{
		try
		{
			Context iefContext				= integSessionData.getClonedContext(session);
			MCADMxUtil util					= new MCADMxUtil(iefContext, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
			
			if(sIntegName == null || sIntegName.length() == 0) {
				sIntegName						= util.getIntegrationName(iefContext, sObjectId);
			}

			String isFeatureAllowed			= integSessionData.isFeatureAllowedForIntegration(sIntegName, featureName);
			if(!isFeatureAllowed.startsWith("true"))
			{
				errorMessage = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
			}
			if (sIntegName == null || "".equals(sIntegName))
			{
				isCreateDerivedOutputObj	= false;
				selection					= "none";
			}
			else
			{
				globalConfigObject		 = integSessionData.getGlobalConfigObject(sIntegName,iefContext);
				isCreateDerivedOutputObj = globalConfigObject.isCreateDependentDocObj();
				session.setAttribute("GCO",globalConfigObject);
				session.setAttribute("LCO",integSessionData.getLocalConfigObject());
				session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(iefContext));
			}
			iefConfigUIUtil = new IEFConfigUIUtil(iefContext, integSessionData, sIntegName);
		}
		catch (Exception e)
		{
			errorMessage = e.getMessage();
		}

		if (true == isCreateDerivedOutputObj)
		{
		    sTable = "DSCTableObjectDerivedOutput";
		    sSortColumnName = "Name";
		}
		else
		{
			sTable = "DSCTableDerivedOutput";
			sSortColumnName = "FileName";
		} 
	}
	sProgram			= (sProgram == null) ? "DSCDerivedOutputsTableData:getTableData" : sProgram;
	sIntegName			= (sIntegName == null) ? "" : sIntegName;
	sTopActionBar		= (sTopActionBar == null) ? "DSCDownloadAttachmentFiles" : sTopActionBar;
	String targetPage	= "../common/emxIndentedTable.jsp";
	
	//AppletFree code:- Download Attachement command should not be visible if appletFree UI is active
		boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);
	
	if(bEnableAppletFreeUI)
		sTopActionBar = "";
	//End
	
	if(null!= integSessionData && integSessionData.useUnassignedIntegGCO(sIntegName))
		selection = "none";
%>
</head>
<body>

<form name="emxIEFTableForm" action="<xss:encodeForHTML><%=targetPage%></xss:encodeForHTML>">

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
//System.out.println("CSRFINJECTION::DSCDerivedOutput.jsp");
%>
	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="expandLevelFilter" value="false">
	<input type="hidden" name="sortColumnName" value="<xss:encodeForHTMLAttribute><%=sSortColumnName%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="sortDirection" value="<xss:encodeForHTMLAttribute><%=sSortDirection%></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="selection" value="<%=selection%>">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%= sTopActionBar %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= sHeader %></xss:encodeForHTMLAttribute>">
	<!--XSSOK-->
	<input type="hidden" name="integrationName" value="<%= sIntegName %>">
	<input type="hidden" name="showIntegrationOption" value="<xss:encodeForHTMLAttribute><%=sShowIntegrationOption%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="isPortal" value="<xss:encodeForHTMLAttribute><%=isPortal%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="featureName" value="<xss:encodeForHTMLAttribute><%=featureName%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=sHelpMarker%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">

<% if (null != sProgram) { %>
        <input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=sProgram%></xss:encodeForHTMLAttribute>">
<% } %>
<% if (null != categoryTree) { %>
        <input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
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
<% if(null != suiteDirectory) { %>
		<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">
<% } %>
<% if(null != cadlist) { %>
		<input type="hidden" name="cadlist" value="<%=cadlist%>">
<% } %>
</form>

<%@ include file="../common/emxNavigatorBottomErrorInclude.inc" %>
<%
	if ("".equals(errorMessage.trim()))
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
		document.emxIEFTableForm.submit();
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

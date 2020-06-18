<%--  IEFObjectVersions.jsp

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
        Context context                  = null;
	String objectID			 =Request.getParameter(request,"objectId");
	String typeName			 =Request.getParameter(request,"typeName");	
	String headerKey		 =Request.getParameter(request,"header");	
	String helpMarker		 =Request.getParameter(request,"HelpMarker");
	String table     		 =Request.getParameter(request,"table");
	String topActionbar		 =Request.getParameter(request,"topActionbar");
	String suiteKey			 =Request.getParameter(request,"suiteKey");
	String sortColumnName	         =Request.getParameter(request,"sortColumnName");
	String sortDirection	         =Request.getParameter(request,"sortDirection");
	String selection		 =Request.getParameter(request,"selection");
	String portalMode		 =Request.getParameter(request,"portalMode");
	String categoryTree =Request.getParameter(request,"categoryTreeName");
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");
	String printerFriendly	 =Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;
	
	typeName	   = (typeName == null) ? "CADDrawing" : typeName;
	table   	   = (table == null) ? "DSCVersions" : table;
	headerKey	   = (headerKey == null) ? "emxIEFDesignCenter.Header.Versions" : headerKey;
	suiteKey	   = (suiteKey == null) ? "eServiceSuiteDesignerCentral" : suiteKey;
	helpMarker	   = (helpMarker == null) ? "emxhelpdscversions" : helpMarker;
	selection 	   = (selection == null) ? "single" : selection;
	
	
	sortColumnName = (sortColumnName == null) ? "Name" : sortColumnName;
	sortDirection  = (sortDirection == null) ? "ascending" : sortDirection;
	portalMode     = (portalMode == null) ? "false" : portalMode;

	String integrationName				= "";
	String errorMessage				= "";

	MCADGlobalConfigObject  globalConfigObject	= null;

	MCADIntegrationSessionData integSessionData     = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage				= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle   = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
        errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	else
	{
		context     = integSessionData.getClonedContext(session);
		MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName		= util.getIntegrationName(context, objectID);
		
		globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);

		BusinessObject busObj = new BusinessObject(objectID);
		busObj.open(context);
		String busType		  = busObj.getTypeName();
	
		if(!util.isMajorObject(context, objectID))//!globalConfigObject.isMajorType(busType))
		{
			BusinessObject majorObject = util.getMajorObject(context, busObj);
			if(majorObject != null)
			{
				busObj.close(context);				
				busObj = majorObject;
				busObj.open(context);
			}
			objectID = busObj.getObjectId();
		 }
		
		busObj.close(context);

		session.setAttribute("GCO",globalConfigObject);
		session.setAttribute("LCO",integSessionData.getLocalConfigObject());
		session.setAttribute("GCOTable",integSessionData.getIntegrationNameGCOTable(context));
	}
%>
</head>
<body>
<form name="whereUsedForm" action="../common/emxIndentedTable.jsp">


	<input type="hidden" name="program" value="DSCVersions:getVersions">
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
	<input type="hidden" name="massPromoteDemote" value="false">
	<input type="hidden" name="triggerValidation" value="false">
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

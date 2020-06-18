<%--  IEFObjectRevisions.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<html>
<head>
<%
	String objectID			 =Request.getParameter(request,"objectId");
	String program			 =Request.getParameter(request,"program");
	String table			 =Request.getParameter(request,"table");
	String headerKey		 =Request.getParameter(request,"header");
	String pagination		 =Request.getParameter(request,"pagination");	
	String selection		 =Request.getParameter(request,"selection");
	String helpMarker		 =Request.getParameter(request,"HelpMarker");
	String suiteKey			 =Request.getParameter(request,"suiteKey");
	String funcPageName		 =Request.getParameter(request,"funcPageName");
	String topActionbar		 =Request.getParameter(request,"topActionbar");
	String suiteDirectory	 = Request.getParameter(request,"emxSuiteDirectory");
	String portalMode		 =Request.getParameter(request,"portalMode");
	String categoryTree =Request.getParameter(request,"categoryTreeName");
        String printerFriendly	 =Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;
	String errorMessage		 = "";



	table		 = (table == null) ? "IEFRevisions" : table;
	program		 = (program == null) ? "IEFFindRevision:getList" : program;
	headerKey	 = (headerKey == null) ? "emxIEFDesignCenter.Header.Revision" : headerKey;
	pagination	 = (pagination == null) ? "10" : pagination;
	selection	 = (selection == null) ? "multiple" : selection;
	suiteKey	 = (suiteKey == null) ? "eServiceSuiteDesignerCentral" : suiteKey;
	helpMarker	 = (helpMarker == null) ? "emxhelpdscrevisions" : helpMarker;
	topActionbar = (topActionbar == null) ? "IEFObjectRevisionsTopActionBarActions" : topActionbar;
	funcPageName = (funcPageName == null) ? "Revisions" : table;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);

	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	
%>
</head>
<body>
<form name="whereUsedForm" action="../common/emxIndentedTable.jsp">
	<input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=program%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="pagination" value="<xss:encodeForHTMLAttribute><%=pagination%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%= headerKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%= selection %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="topActionbar" value="<xss:encodeForHTMLAttribute><%=topActionbar%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectID %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%= helpMarker %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="funcPageName" value="<xss:encodeForHTMLAttribute><%= funcPageName %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%= suiteKey %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%= acceptLanguage %></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="categoryTreeName" value="<xss:encodeForHTMLAttribute><%=categoryTree%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="showAllTables" value="false">
	<input type="hidden" name="triggerValidation" value="false">
	<input type="hidden" name="objectCompare" value="false">
	<input type="hidden" name="massPromoteDemote" value="false">
	<input type="hidden" name="PrinterFriendly" value="<xss:encodeForHTMLAttribute><%=printerFriendly%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=suiteDirectory%></xss:encodeForHTMLAttribute>">

	<input type="hidden" name="jpoAppServerParamList" value="session:GCOTable,session:LCO,session:GCO">
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

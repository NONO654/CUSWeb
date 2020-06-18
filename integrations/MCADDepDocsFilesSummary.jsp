<%--  MCADDepDocsFilesSummary.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	if(integSessionData == null)
	{
		String acceptLanguage = request.getHeader("Accept-Language");
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

        String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}

	String objectId		= request.getParameter("objectId");
	String jsTreeID		= request.getParameter("jsTreeID");
	String instanceName = request.getParameter("instanceName");
	String programName	= request.getParameter("custProgram");
	String suiteDir		= request.getParameter("emxSuiteDirectory");
	String helpMarker	= "emxhelpdscderivedoutput";

	String headerKey = "mcadIntegration.Server.Title.DependentDocuments";
	if(!programName.equalsIgnoreCase("MCADDerivedOutputsTableData"))
	{
		headerKey	= "mcadIntegration.Server.Title.Representations";
	}
%>

<html>
<head></head>

<body>
<form name="derivedOutputListForm" action="emxInfoCustomTable.jsp">
	<input type="hidden" name="custHeader" value="<%= headerKey %>">
	<input type="hidden" name="custProgram" value="<%= programName %>">
	<input type="hidden" name="custSelection" value="muliple">
	<input type="hidden" name="custSortColumnName" value="Grantor">
	<input type="hidden" name="custSortDirection" value="ascending">
	<input type="hidden" name="custBottomActionbar" value="">
	<input type="hidden" name="custTargetLocation" value="">
	<input type="hidden" name="custTopActionbar" value="">
	<input type="hidden" name="custSortType" value="string">
	<input type="hidden" name="suiteKey" value="">
	<input type="hidden" name="emxSuiteDirectory" value="<%= suiteDir %>">
	<input type="hidden" name="objectId" value="<%= objectId %>">
	<input type="hidden" name="instanceName" value="<%= instanceName %>">
	<input type="hidden" name="jsTreeID" value="<%= jsTreeID %>">
	<input type="hidden" name="HelpMarker" value="<%=helpMarker%>">
</form>

<%@include file = "MCADBottomErrorInclude.inc"%>
<%
	if ((emxNavErrorObject.toString()).trim().length() == 0)
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
	document.derivedOutputListForm.submit();
	</SCRIPT>
<%
	}
%>
</body>
</html>

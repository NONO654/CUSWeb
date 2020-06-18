<%--  emxEngrRefreshECOSummaryReport.jsp - This page displays the ECO summary 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

<%
   String objectId = (String)session.getAttribute("ECOSummaryReportObjectId");
   session.removeAttribute("ECOSummaryReportObjectId");
   String categoryTreeMenu = (String) session.getAttribute("ECOSummaryReportCategoryTreeMenu");
%>

<html> <head>
<script language="javascript">
		 if(confirm("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.SummaryReport.RefreshConfirmationMessage</emxUtil:i18n>")) {
			var contentFrame = getTopWindow().findFrame(getTopWindow(), "detailsDisplay");
			contentFrame.location.href="emxEngrECOPdfSummaryReportFS.jsp?generateSummary=true&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&categoryTreeName=<xss:encodeForJavaScript><%=categoryTreeMenu%></xss:encodeForJavaScript>";
		 }

</script>
</head>
<body>
</body>
</html>

<%@include file = "emxDesignBottomInclude.inc"%>

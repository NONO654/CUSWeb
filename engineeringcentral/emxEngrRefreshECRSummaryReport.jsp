<%--  emxEngrRefreshECRSummaryReport.jsp - This page initiates the the ECR refresh summary action
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

<%
   String objectId = (String)session.getAttribute("ECRSummaryReportObjectId");
   String categoryTreeMenu = (String) session.getAttribute("ECRSummaryReportCategoryTreeMenu");
%>

<html> <head>
<script language="javascript">
		 if(confirm("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.SummaryReport.RefreshConfirmationMessage</emxUtil:i18n>")) {
			var contentFrame = getTopWindow().findFrame(getTopWindow(), "detailsDisplay");
			contentFrame.location.href="emxEngrECRPdfSummaryReportFS.jsp?generateSummary=true&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&categoryTreeName=<xss:encodeForJavaScript><%=categoryTreeMenu%></xss:encodeForJavaScript>";
		 }

</script>
</head>
<body>
</body>
</html>

<%@include file = "emxDesignBottomInclude.inc"%>

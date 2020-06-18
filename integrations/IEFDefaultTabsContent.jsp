<%--  IEFDefaultTabsContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
%>
<html>
<head>
	<title>emxTabsControl</title>
</head>
<body>

<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<%@include file = "IEFTabsContentInclude.inc"%>
</table>

<script language="javascript" >
	parent.changeTabSelection(<%= activeTabSelectionArgumentsString %>);
</script>
</body>
</html>

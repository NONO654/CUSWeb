<%--  IEFPageLoadingBanner.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "com.matrixone.MCADIntegration.server.beans.*" %>
<%@include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String loadingBanner = integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Message.Loading");
%>

<html>
<head>
<style type="text/css"> 
body { background-color: white; }
body { font-family: Verdana, Arial, Helvetica, Sans-Serif; font-size: 10pt; }
</style>
</head>
<body>
        <!--XSSOK-->
	<h4><%= loadingBanner %></h4>
</body>
</html>

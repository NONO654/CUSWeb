<%--  MCADLocalFilesDeleteConfirmFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);
%>

<html>
<head>
<!--XSSOK-->
<title> <%=integSessionData.getStringResource("mcadIntegration.Server.Title.LocalFilesDeleteConfirmDialog")%> </title>
</head>

<frameset rows="55,*,55" frameborder="no" framespacing="2">
	<frame src="MCADLocalFilesDeleteConfirmHeader.jsp" name="overWriteHeaderFrame" marginwidth="0" marginheight="0" scrolling="no" />
	<!--XSSOK-->
	<frame src="MCADLocalFilesDeleteConfirmContent.jsp?<%= queryString %>" name="overWriteContentFrame" marginwidth="4" marginheight="1" />
	<frame src="MCADLocalFilesDeleteConfirmFooter.jsp" name="overWriteFooterFrame" marginwidth="0" marginheight="0" noresize="noresize" scrolling="no" />
</frameset>
</html>

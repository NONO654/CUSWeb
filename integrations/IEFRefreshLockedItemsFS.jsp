<%--  IEFRefreshLockedItemsFS.jsp

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
<!--XSSOK-->
<title> <%=integSessionData.getStringResource("mcadIntegration.Server.Title.refreshLockedItemsConfirmDialog")%> </title>
</head>

<frameset rows="55,*,55" frameborder="no" framespacing="2">
	<frame src="IEFRefreshLockedItemsHeader.jsp" name="refreshLockedItemsHeaderFrame" marginwidth="0" marginheight="0" scrolling="no" />
	<frame src="IEFRefreshLockedItemsContent.jsp?<%=XSSUtil.encodeForURL(integSessionData.getClonedContext(session),request.getQueryString()) %>" name="refreshLockedItemsContentFrame" marginwidth="4" marginheight="1" />
	<frame src="IEFRefreshLockedItemsFooter.jsp" name="refreshLockedItemsFooterFrame" marginwidth="0" marginheight="0" noresize="noresize" scrolling="no" />
</frameset>
</html>

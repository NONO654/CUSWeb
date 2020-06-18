<%--  IEFTabsWindowFS.jsp

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
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" >

//Event Handlers Start
function changeTabSelection(headerPage, contentPage, footerPage)
{
	var frameheader = findFrame(parent,"header");	var framecontent = findFrame(parent,"content");
	var framefooter = findFrame(parent,"footer");
	frameheader.document.location	= headerPage;
	framecontent.document.location	= contentPage;
	framefooter.document.location	= footerPage;
}
//Event Handlers End
<%
	String tabsContentJPO	= request.getParameter("tabsJPO");
	String jpoMethod		= request.getParameter("jpoMethod");
	String activeTabName	= request.getParameter("activeTabName");
%>
</script>
</head>

<frameset rows="80,*,80" frameborder="yes" framespacing="2">
	<frame name="header" src="MCADPageLoadingBanner.jsp" scrolling=no>
	<frame name="content" src="IEFDefaultTabsContent.jsp?tabsJPO=<%=tabsContentJPO%>&jpoMethod=<%=jpoMethod%>&activeTabName=<%=activeTabName%>" marginheight="3">
	<frame name="footer" src="MCADPageLoadingBanner.jsp" scrolling=no>
</frameset>
</html>

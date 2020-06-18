<%--  MCADOverWriteConfirmFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	Context context = integSessionData.getClonedContext(session);
	
	String queryString = emxGetEncodedQueryString(context,request);
%>

<html>
<head>
<script language="javascript" >
function closeWindow()
{
	window.close();
}
</script>
<title> <%=integSessionData.getStringResource("mcadIntegration.Server.Title.CheckoutConfirmDialog")%> </title>
</head>

<frameset rows="55,*,55" frameborder="no" framespacing="2">
	<frame src="MCADOverWriteConfirmHeader.jsp" name="overWriteHeaderFrame" marginwidth="0" marginheight="0" scrolling="no" />
	<frame src="MCADOverWriteConfirmContent.jsp?<%= queryString %>" name="overWriteContentFrame" marginwidth="4" marginheight="1" />
	<frame src="MCADOverWriteConfirmFooter.jsp" name="overWriteFooterFrame" marginwidth="0" marginheight="0" noresize="noresize" scrolling="no" />
</frameset>
</html>

<%--  MCADDependentDocsFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.beans.*, com.matrixone.apps.domain.util.*" %>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String nodeID			= Request.getParameter(request,"nodeid");
	String integrationName	= Request.getParameter(request,"integrationName");
%>

<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<html>
<head>
<title> <%=integSessionData.getStringResource("mcadIntegration.Server.Title.DependentDocuments")%> </title>

<script language="JavaScript">
function handledependentDocSelection()
{
<%
	if(nodeID == null || "".equals(nodeID) || "null".equalsIgnoreCase(nodeID))
	{
%>
	var integrationFrame 	 = getIntegrationFrame(this);
	var dependentDocsContent = integrationFrame.getAppletObject().callCommandHandler("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName) %>","handledependentDocSelectionForSilentCheckin", "");
<%
	}
%>
}
</script>

</head>
<frameset rows="55,*,55" frameborder="no" framespacing="2">
	<frame src="MCADDependentDocsHeader.jsp" name="headerFrame" marginwidth="0" marginheight="0" scrolling="no" />
	<frame src="MCADDependentDocsContent.jsp?nodeid=<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),nodeID)%>&integrationName=<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName)%>" name="contentFrame" marginwidth="4" marginheight="1" />
	<frame src="MCADDependentDocsFooter.jsp?integrationName=<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName)%>" name="footerFrame" marginwidth="0" marginheight="0" noresize="noresize" scrolling="no" />
</frameset>
</html>

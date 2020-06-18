<%--  IEFOperationFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context	= integSessionData.getClonedContext(session);
	
	String queryString = emxGetEncodedQueryString(context,request);
	String integrationName =Request.getParameter(request,"integrationName");

	String pageTitle		=Request.getParameter(request,"pageTitle");
	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title." + pageTitle);
	
%>

<%
if(integSessionData != null)
{
%>

	<html>
	<head>
	<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" >
	<%@include file = "IEFTreeTableInclude.inc"%>

	var integrationName	= '<%=XSSUtil.encodeForJavaScript(context,integrationName)%>';
	//Confirmation dialog content
	var confirmWindowContent;
	//Confirmation dialog content
	var confirmDeleteWindowContent;


	function closeWindow()
	{
		if(cancelOperation)
		{
			var integFrame = getIntegrationFrame(this);
			integFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, 'abortOperation', true);	
			cancelOperation = false;
			window.close();
		}
	}

	function updateProgressBar(metaCurrentCount, fileCurrentCount)
	{

	}

	function closeProgressBar()
	{

	}

	function showAlert(message, closeOption)
	{
		alert(message);
		if(closeOption)
		{
			isCancelRequired = false;
			window.close();
		}
	}
	function showCheckoutConfirmDialog(integrationName, content)
	{
		confirmWindowContent = content;		
		showIEFModalDialog('MCADOverWriteConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
	}


	function getConfirmWindowContent()
	{
		return confirmWindowContent;
	}

	function showLocalFilesDeleteConfirmationDialog(integrationName, content)
	{
		confirmDeleteWindowContent = content;
	
		showIEFModalDialog('MCADLocalFilesDeleteConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
	}

	function getConfirmDeleteWindowContent()
	{
		return confirmDeleteWindowContent;
	}
	</script>
	</head>
	<title><xss:encodeForHTML><%=operationTitle%></xss:encodeForHTML></title>
	<frameset rows="75,*,120" frameborder="no" framespacing="0" onUnload="javascript:closeWindow()">
		<frame name="headerDisplay" src="IEFOperationHeader.jsp?<%=XSSUtil.encodeForHTML(context, queryString)  %>" scrolling=no marginheight="3" marginwidth="3" border="0" scrolling="no">
		<frame name="tableDisplay" src="IEFPageLoadingBanner.jsp" marginheight="3" marginwidth="3" border="0" scrolling="auto">
		<frame name="bottomDisplay" src="IEFOperationFooter.jsp?<%=XSSUtil.encodeForHTML(context, queryString)  %>" scrolling=no marginheight="3" marginwidth="3" border="0" scrolling="no">
	</frameset>
	</html>
<%
} //if(integSessionData != null) check
else
{
	String loginPage = Framework.getClientSideURL(response, FrameworkProperties.getProperty("emxLogin.LoginPage"));
%>
	<script language="javascript" >
	//XSSOK
	top.document.location.href = "<%=loginPage%>";
	</script>
<%
}%>

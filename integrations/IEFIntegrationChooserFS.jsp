<%--  IEFIntegrationChooserFS.jsp

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
	boolean keepOpen = "true".equals(Request.getParameter(request,"keepOpen"));

	//eventHandler must be passed as a parameter whenever this JSP is called
	//NOTE: eventHandler must be implemented in the opener otherwise error will
	//be thrown
	String eventHandler =Request.getParameter(request,"eventHandler");
	String workspaceFolderId =Request.getParameter(request,"folderId");
	String allowedIntegrations	=Request.getParameter(request,"allowedIntegrations");	
%>

<html>
<head>
<!--XSSOK-->
<title><%=integSessionData.getStringResource("mcadIntegration.Server.Title.IntegrationChooser")%></title>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript">
//XSSOK
	var keepOpen = '<%=keepOpen%>';
   	var workspaceFolderId = '<%=XSSUtil.encodeForJavaScript(context,workspaceFolderId)%>';

	//To put this window on top of the parent i.e. caller
	window.top.focus();

	function formSubmit()
	{
		var framecontentFrame = findFrame(this,"contentFrame");
		for (var i = 0; i < framecontentFrame.document.forms['frmIntegNameChooser'].elements.length; i++)
			{
			if (framecontentFrame.document.forms['frmIntegNameChooser'].elements[i].checked)
				{
				var integrationName = framecontentFrame.document.forms['frmIntegNameChooser'].elements[i].value;
				//The method  eventHandler should be implemented in the opener
				//otherwise the following line will throw javascript error
				window.top.opener.<%= XSSUtil.encodeForJavaScript(context,eventHandler) %>(integrationName,workspaceFolderId);

				if(keepOpen=="false")
				{
					window.top.close();
			}

			}
		}
	}

	function showAlert(message, closeWindow)
	{
		alert(message);

		if(closeWindow == "true")
			window.close();
	}

	function closeModalDialog()
	{
		window.close();
	}

</script>
</head>
<frameset rows="55,*,55" frameborder="no" framespacing="2">
	<frame src="IEFIntegrationChooserHeader.jsp" name="headerFrame" marginwidth="0" marginheight="0" scrolling="no" />
	<frame src="IEFIntegrationChooserContent.jsp?allowedIntegrations=<%=XSSUtil.encodeForURL(context,allowedIntegrations)%>" name="contentFrame" marginwidth="4" marginheight="1" />
	<frame src="IEFIntegrationChooserFooter.jsp" name="footerFrame" marginwidth="0" marginheight="0" noresize="noresize" scrolling="no" />
</frameset>
</html>

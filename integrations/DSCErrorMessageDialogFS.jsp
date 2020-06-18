<%--  DSCErrorMessageDialogFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
	String messageHeaderKey						=Request.getParameter(request,"messageHeader");	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String messageHeader                        = "";
	String headerImage							=Request.getParameter(request,"headerImage");
	String headerImageParam						= "headerImage=";
	String showExportIcon						=Request.getParameter(request,"showExportIcon");
	String showContinueBtn                      =Request.getParameter(request,"showContinueBtn");
	String buttonName                          ="Close";
	String errorMessagePageLabel			= integSessionData.getStringResource("mcadIntegration.Server.Title.ErrorMessagePageLabel");
	
	if(headerImage != null)
		headerImageParam += headerImage;
	
	if(messageHeaderKey != null && !messageHeaderKey.equals("") && !messageHeaderKey.equals("null"))
		messageHeader = integSessionData.getStringResource(messageHeaderKey);

    if(messageHeader != null && !messageHeader.equals("") && !messageHeader.equals("null"))
		session.setAttribute("mcadintegration.messageHeader", messageHeader);
    
    if(showContinueBtn != null && !showContinueBtn.equals("") && !showContinueBtn.equals("null"))
    {
    	if(showContinueBtn.equalsIgnoreCase("true"))
	    	buttonName = "ContinueCancel";
    }

	
	String requestString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);
%>

<html>
<head>
<!--XSSOK-->
<title><%= errorMessagePageLabel %></title>
</head>
<frameset rows="65,*,65" frameborder="no">
	<frame src="MCADGenericHeaderPage.jsp?<%=XSSUtil.encodeForURL(XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),headerImageParam))%>&showExportIcon=<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),showExportIcon)%>" name="headerFrame" scrolling=no>
	<!--XSSOK-->
	<frame src="DSCErrorMessageDialogContent.jsp?<%=requestString%>" name="contentFrame">
	<!--XSSOK-->
	<frame src="MCADGenericFooterPage.jsp?buttonName=<%=buttonName%>" name="footerFrame" scrolling=no>
</frameset>
<html>

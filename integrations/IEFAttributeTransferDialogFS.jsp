<%--  IEFAttributeTransferFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%
Context context= Framework.getMainContext(session);
    MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String pageHeading	    = emxGetParameter(request, "pageHeading");
	String sHelpMarker		= emxGetParameter(request, "helpMarker");
	String queryString		= request.getQueryString();

    pageHeading				= integSessionData.getStringResource(pageHeading);

	session.setAttribute("mcadintegration.messageHeader", pageHeading);
	
	//Header page URL
	StringBuffer headerPageURLBuffer = new StringBuffer("MCADGenericHeaderPage.jsp?helpMarker="+sHelpMarker);
	
	//Content page URL
	StringBuffer contentPageURLBuffer = new StringBuffer("IEFAttributeTransferContent.jsp");
	contentPageURLBuffer.append("?");
	contentPageURLBuffer.append(queryString);

	//Bottom page URL
	StringBuffer bottomPageURLBuffer = new StringBuffer();
	bottomPageURLBuffer.append("IEFAttributeTransferFooter.jsp");  
	
%>

<html>
<head>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
</head>

<frameset rows="85,*,75" frameborder="no" >
	<frame src="<%=XSSUtil.encodeURLwithParsing(context, headerPageURLBuffer.toString())%>" name="headerFrame" scrolling=no>
	<frame src="<%= XSSUtil.encodeURLwithParsing(context, contentPageURLBuffer.toString()) %>" name="contentFrame">
	<frame src="<%= XSSUtil.encodeURLwithParsing(context, bottomPageURLBuffer.toString()) %>" name="footerFrame" scrolling=no>
</frameset>

<html>

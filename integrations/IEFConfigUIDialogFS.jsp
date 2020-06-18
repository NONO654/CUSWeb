<%--  IEFConfigUIDialogFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
    MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String pageHeading	    = emxGetParameter(request, "pageHeading");
	String contentPageName	= emxGetParameter(request, "contentPage");
	String createIcon	    = emxGetParameter(request, "createIcon");
	String modifyIcon	    = emxGetParameter(request, "modifyIcon");
	String deleteIcon	    = emxGetParameter(request, "deleteIcon");
	String onBeforeUnload   = emxGetParameter(request, "onBeforeUnload");
	String sHelpMarker		= emxGetParameter(request, "helpMarker");

	if(onBeforeUnload == null)
		onBeforeUnload = "";

	Context context = integSessionData.getClonedContext(session);
	
	String queryString = emxGetEncodedQueryString(context,request);
	
    String mcadRoleList		= integSessionData.getPropertyValue("mcadIntegration.MCADRoles");

    pageHeading				= integSessionData.getStringResource(pageHeading);

	session.setAttribute("mcadintegration.messageHeader", pageHeading);

	//StringBuffer headerPageURLBuffer = new StringBuffer("../common/emxAppTopPageInclude.jsp?mx.page.filter=null&dir=mcadintegration&links=0&fltnum=0&phead=");
	//headerPageURLBuffer.append(pageHeading);
	//headerPageURLBuffer.append("&usepf=false&dialog=true&usecon=false&lmax=4&showWarning=true&oidp=null&strfile=");

	//Header page URL
	StringBuffer headerPageURLBuffer = new StringBuffer("MCADGenericHeaderPage.jsp?helpMarker="+XSSUtil.encodeForURL(context,sHelpMarker));

	//Content page URL
	StringBuffer contentPageURLBuffer = new StringBuffer(contentPageName);
	contentPageURLBuffer.append("?");
	contentPageURLBuffer.append(queryString);

	//Bottom page URL
	StringBuffer bottomPageURLBuffer = new StringBuffer();
	if(createIcon != null && modifyIcon != null && deleteIcon != null)
	{
		bottomPageURLBuffer.append("IEFConfigUIFooter1.jsp?createIcon=");
		bottomPageURLBuffer.append(XSSUtil.encodeForURL(context,createIcon));
		bottomPageURLBuffer.append("&modifyIcon=");
		bottomPageURLBuffer.append(XSSUtil.encodeForURL(context,modifyIcon));
		bottomPageURLBuffer.append("&deleteIcon=");
		bottomPageURLBuffer.append(XSSUtil.encodeForURL(context,deleteIcon));
	}
	else
	{
		bottomPageURLBuffer.append("IEFConfigUIFooter2.jsp");
	}
%>



<html>
<head>
</head>

<frameset rows="85,*,75" frameborder="no" onBeforeUnload="<%=XSSUtil.encodeForJavaScript(context,onBeforeUnload)%>">javascript:findFrame(parent,"contentFrame").parent.window.close()
<frame src="<%=XSSUtil.encodeForHTML(context,headerPageURLBuffer.toString())  %>" name="headerFrame" scrolling=no>
	<frame src="<%=XSSUtil.encodeForHTML(context,contentPageURLBuffer.toString()) %>" name="contentFrame">
	<frame src="<%=XSSUtil.encodeForHTML(context, bottomPageURLBuffer.toString())  %>" name="footerFrame" scrolling=no>
</frameset>

<html>

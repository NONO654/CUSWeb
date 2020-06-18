<%--  IEFReplaceTableFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "emxInfoCustomTableInclude.inc" %>
<%@ include file ="MCADTopInclude.inc" %>
<%@include file = "MCADTopErrorInclude.inc"%>


<%

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

	String objectID			= emxGetParameter(request, "objectId");
	String relnshipName		= emxGetParameter(request, "relName");
	String end				= emxGetParameter(request, "end");
	String headerKey		= emxGetParameter(request, "header");	

	String funcPageName		= emxGetParameter(request, "funcPageName");
	String selectedRows		= emxGetParameter(request, "selectedRows");
	String integrationName	= emxGetParameter(request, "integrationName");
	String help				= emxGetParameter(request, "help");
	String contentPage		= "IEFReplaceTableContent.jsp";
	contentPage += "?header=" + XSSUtil.encodeForURL(integSessionData.getClonedContext(session),headerKey) + "&funcPageName=" + XSSUtil.encodeForURL(context,funcPageName) + "&relName=" + XSSUtil.encodeForURL(context,relnshipName) + "&end=" + XSSUtil.encodeForURL(context,end) + "&integrationName=" + XSSUtil.encodeForURL(context,integrationName) + "&help=" + XSSUtil.encodeForURL(context,help) + "&selectedRows=" + XSSUtil.encodeForURL(context,selectedRows) + "&objectId=" + XSSUtil.encodeForURL(context,objectID);
	
	String queryString	= request.getQueryString();
	String pageHeading	= integSessionData.getStringResource("mcadIntegration.Server.Title.Replace");
	String mcadRoleList = integSessionData.getPropertyValue("mcadIntegration.MCADRoles");
    String strFind   = i18nNow.getI18nString("emxFramework.Button.Find",null,lStr);
%>

<html>
<head>
<!--XSSOK-->
<title><%=pageHeading%></title>
</head>

<frameset rows="120,*,75" frameborder="no">
     <!--XSSOK-->
	 <!--Fix for IR-606673: Web page error after clicking replace command in Japanese language.-->
	 <frame src="IEFReplaceTableHeader.jsp?mx.page.filter=null&dir=mcadintegration&links=0&fltnum=0&phead=<%=XSSUtil.encodeForURL(context,pageHeading)%>&usepf=false&dialog=true&usecon=false&lmax=4&showWarning=true&oidp=null&strfile=iefStringResource&objectId=<%=XSSUtil.encodeForURL(context,objectID)%>" name="headerFrame" scrolling=no>
	 <!--XSSOK-->
	<frame src="<%= contentPage %>" name="contentFrame">
	<frame  src="IEFReplaceTableFooter.jsp?mx.page.filter=null&dir=mcadintegration&links=0&oidp=null&strfile=iefStringResource" name="footerFrame" scrolling=no>
</frameset>
<html>

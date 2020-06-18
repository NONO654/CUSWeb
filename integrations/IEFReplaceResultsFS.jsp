<%--  IEFReplaceResultsFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "emxInfoCustomTableInclude.inc" %>
<%@ include file ="MCADTopInclude.inc" %>
<%@include file = "MCADTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%


   	String objectID		=Request.getParameter(request,"objectId");
	String replacee		=Request.getParameter(request,"replaceWith");
	String selRows		=Request.getParameter(request,"usrSelRowsForReplace");
	String searchType   =Request.getParameter(request,"searchType");

	//Page Details


	String contentPage		= "./IEFReplaceResults.jsp";

	
	contentPage += "?replaceWith=" + replacee + "&usrSelRowsForReplace=" + selRows + "&objectId=" + objectID +"&searchType="+searchType;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context context = integSessionData.getClonedContext(session);
	String queryString	= emxGetQueryString(request);
	String pageHeading	= integSessionData.getStringResource("mcadIntegration.Server.Title.Replace");
	String mcadRoleList = integSessionData.getPropertyValue("mcadIntegration.MCADRoles");

%>

<html>
<head>
</head>

<frameset rows="85,*,75,0" frameborder="no">
    <!--XSSOK-->
	<frame src="IEFReplaceResultsHeader.jsp?mx.page.filter=null&dir=mcadintegration&links=0&fltnum=0&phead=<%=pageHeading%>&usepf=false&dialog=true&usecon=false&lmax=4&showWarning=true&oidp=null&strfile=iefStringResource" name="headerFrame" scrolling=no>
	<frame src="<%=XSSUtil.encodeForHTML(context,contentPage) %>" name="contentFrame">
	<frame  src="IEFReplaceResultsFooter.jsp?mx.page.filter=null&dir=mcadintegration&links=0&oidp=null&strfile=iefStringResource" name="headerFrame" scrolling=no>
	<frame src="IEFBlank.jsp" name="hiddenFrame" scrolling=no>
</frameset>

<html>

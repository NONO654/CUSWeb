<%--  IEFAttribMappingFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.MCADIntegration.server.beans.IEFAttrMapping" %>
<%@ page import="com.matrixone.MCADIntegration.server.beans.IEFAttrMappingBase" %>

<%
	String gcoName	=Request.getParameter(request,"gcoName");
	String sAction = Request.getParameter(request,"sAction");
	String sAttrib= Request.getParameter(request,"attri");
	String sMappingType = Request.getParameter(request,"MappingType");
	String sFirstTime = Request.getParameter(request,"firstTime");
	String sCADAttribMappingAttrName = "";
	
	if(sFirstTime != null && "true".equals(sFirstTime))
	{
		session.removeAttribute("IEFAttrMapping");
	}
	
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	if(sAction!=null){
		ENOCsrfGuard.validateRequest(context, session, request, response);
	}	
	IEFAttrMappingBase objIEFAttrMappingBase = new IEFAttrMapping(context,integSessionData,sMappingType,gcoName);
	
	String sTitle = objIEFAttrMappingBase.getDialogHeaderString();
	if(sFirstTime != null && "true".equals(sFirstTime))
	{
		objIEFAttrMappingBase.executeAction(context,objIEFAttrMappingBase.ACTION_READ,null,null);
		session.setAttribute("IEFAttrMapping", objIEFAttrMappingBase);
	}
%>
<html>
<head>
<title> <xss:encodeForHTML><%=sTitle%></xss:encodeForHTML> </title>
</head>

<frameset rows="50,*,60" frameborder="no" framespacing="2">
	<frame name="headerDisplay" src="IEFAttribMappingHeader.jsp?MappingType=<%=XSSUtil.encodeForURL(context,sMappingType)%>"  marginwidth="0" marginheight="0" scrolling="no"/>
	<frame name="tableDisplay" src="IEFAttribMappingContent.jsp?gcoName=<%=XSSUtil.encodeForURL(context,gcoName)%>&sAction=<%=XSSUtil.encodeForURL(context,sAction)%>&attri=<%=XSSUtil.encodeForURL(context,sAttrib)%>&MappingType=<%=XSSUtil.encodeForURL(context,sMappingType)%>"  marginwidth="4" marginheight="1"/>
	<frame name="bottomDisplay" src="IEFAttribMappingFooter.jsp?gcoName=<%=XSSUtil.encodeForURL(context,gcoName)%>&MappingType=<%=XSSUtil.encodeForURL(context,sMappingType)%>"  marginwidth="0" marginheight="0" noresize="noresize" scrolling="no"/>
</frameset>

</html>

<%--  IEFGCOChooserFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>


<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String chooserQueryString = emxGetQueryString(request);
	Context context = integSessionData.getClonedContext(session);
	Enumeration enumParamNames = emxGetParameterNames(request);
	while(enumParamNames.hasMoreElements()) 
	{
		String paramName =XSSUtil.encodeForJavaScript(context,XSSUtil.encodeForURL(context,(String) enumParamNames.nextElement()));
		String paramValue = emxGetParameter(request, paramName);
		if (paramValue != null && paramValue.trim().length() > 0 )
			paramValue = XSSUtil.encodeForJavaScript(context,XSSUtil.encodeForURL(context,paramValue));
		chooserQueryString += "&"+paramName+ "=" +paramValue;
	}
%>

<html>
<head>
<!--XSSOK-->
<title> <%=integSessionData.getStringResource("mcadIntegration.Server.Title.GCOChooser")%> </title>

</head>
<frameset rows="55,*,55" frameborder="no" framespacing="2">

	<frame name="headerFrame" src="IEFGCOChooserHeader.jsp"  marginwidth="0" marginheight="0" scrolling="no"/>
	<frame name="contentFrame" src="IEFGCOChooserContent.jsp?<%= XSSUtil.encodeURLwithParsing(context, chooserQueryString) %>"   marginwidth="4" marginheight="1"/>
	<frame name="footerFrame" src="IEFGCOChooserFooter.jsp"  marginwidth="0" marginheight="0" noresize="noresize" scrolling="no"/>
</frameset>
</html>

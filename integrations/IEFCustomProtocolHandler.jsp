<%--  IEFCustomProtocolHandler.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%
Context context = Framework.getFrameContext(session);
String hrefLink							= Request.getParameter(request,"hreflink");
String integrationName					= Request.getParameter(request,"integrationname");

%>

<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript">

	var hostName	= window.location.hostname;
	var integrationName	= "<%=XSSUtil.encodeForJavaScript(context,integrationName)%>";
	var encodedHostName	= hexEncode(integrationName,hostName);
	
	var link = "<%=XSSUtil.encodeForJavaScript(context,hrefLink)%>" + ":servername=" + encodedHostName;

	// Changed for CRIT HF-363748-V5-6R2014SP3
	window.location.href = link;

</script>


<%--  MCADInstanceUpdateDetails.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%@ page import = "com.matrixone.MCADIntegration.server.beans.MCADServerGeneralUtil"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String languageStr	= request.getHeader("Accept-Language");
	String busId		= request.getParameter("busId");
	String instanceName = request.getParameter("instanceName");

	if(instanceName	!= null)
		instanceName = MCADUrlUtil.hexDecode(instanceName);

	Context context	= integSessionData.getClonedContext(session);
	MCADMxUtil util = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	String integrationName					= util.getIntegrationName(context, busId);
	MCADServerGeneralUtil serverGeneralUtil = new MCADServerGeneralUtil(context,integSessionData, integrationName);
	
	Hashtable attributesTable = new Hashtable();
	Enumeration parameterNamesElements = request.getParameterNames();
	while(parameterNamesElements.hasMoreElements())
	{
		String parameterName	= (String)parameterNamesElements.nextElement();
		String parameterValue	= request.getParameter(parameterName);

		if(!parameterName.equalsIgnoreCase("busId") && !parameterName.equalsIgnoreCase("instanceName"))
		{
			if(parameterValue == null)
				parameterValue = "";

			attributesTable.put(parameterName, parameterValue);
		}
	}

	String errorString = null;
%>

<html>
<head>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIForm.css" type="text/css">
</head>
<body>

<script language="javascript">
<%
	if(errorString != null)
	{
%>
	alert(errorString);
<%
	}
	else
	{
%>
	top.opener.top.frames[1].refreshPage(false);
<%
	}
%>
	parent.window.close();
</script>

</body>
</html>


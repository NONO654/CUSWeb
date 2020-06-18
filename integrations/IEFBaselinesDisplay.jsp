<%--  IEFBaselinesDisplay.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<%@ page import = "com.matrixone.apps.common.*, com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.server.beans.*, matrix.util.*, matrix.db.*"%>
<%@ page import = "com.matrixone.MCADIntegration.uicomponents.util.*" %>

<%
	
	String topObjectId  		= emxGetParameter(request, "objectId");
	String integrationName		=Request.getParameter(request,"integrationName");
	String helpMarker		 = Request.getParameter(request,"HelpMarker");
        String printerFriendly		=Request.getParameter(request,"PrinterFriendly") == null ? "true":Request.getParameter(request,"PrinterFriendly") ;
	String featureName			= MCADGlobalConfigObject.FEATURE_BASELINE;
	String errorMessage			= "";
	String forwardPage			= "";

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");	
	Context context								= integSessionData.getClonedContext(session);	
	MCADServerLogger logger						= integSessionData.getLogger();
    MCADMxUtil util								= new MCADMxUtil(context, logger, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

    helpMarker	 = (helpMarker == null) ? "emxhelplistbaseline" : helpMarker;

	if(integrationName == null)
	{		
		integrationName = util.getIntegrationName(context, topObjectId);	
	}
	
	try
	{
		MCADLocalConfigObject  localConfigObject	= null;
		String isFeatureAllowed						= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
		localConfigObject							= integSessionData.getLocalConfigObject();
		
		if(isFeatureAllowed.startsWith("false") || localConfigObject == null)
		{
			Hashtable exceptionDetails = new Hashtable();
			exceptionDetails.put("NAME",integSessionData.getStringResource("mcadIntegration.Server.Feature."+featureName));

			if(integSessionData.isNonIntegrationUser())
			{
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.FeatureNotAllowedForNonIntegrationUser", exceptionDetails);
			}	
			else
			{
				exceptionDetails.put("INTEGRATION_NAME" ,integrationName);
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.BaselineNotAllowedForNonIntegrationUser", exceptionDetails);
			}
			
			emxNavErrorObject.addMessage(errorMessage);
		}
		else
		{
			StringBuffer urlBuffer = new StringBuffer();
			urlBuffer.append("../common/emxIndentedTable.jsp?program=DECBaselineDetails:getList");
			urlBuffer.append("&table=DECShowBaselineDetails");
			urlBuffer.append("&topActionbar=DECBaselineTopActionBar");
			urlBuffer.append("&header=emxIEFDesignCenter.Header.Baselines");
			urlBuffer.append("&sortColumnName=BaselineName");
			urlBuffer.append("&sortDirection=ascending");
			urlBuffer.append("&selection=multiple");
			urlBuffer.append("&HelpMarker=");
			urlBuffer.append(helpMarker);
			urlBuffer.append("&PrinterFriendly=");
			urlBuffer.append(printerFriendly);
			urlBuffer.append("&jpoAppServerParamList=session:GCO,session:GCOTable,session:LCO&");			
			urlBuffer.append(emxGetQueryString(request));				
			
			forwardPage = urlBuffer.toString();	
		}
	}
	catch(Exception e)
	{
		errorMessage	= e.getMessage();
		emxNavErrorObject.addMessage(errorMessage);
	}

	if ((emxNavErrorObject.toString()).trim().length() == 0)
	{
%>
		<html>
		<head>
		<script language="javascript">

		function redirectToNewLocation()
		{
			window.location.replace("<%=XSSUtil.encodeForJavaScript(context,forwardPage)%>");
		}

		</script>
		</head>
		<body onLoad="redirectToNewLocation()">
		</body>
		</html>
<%
	}
	else
	{
%>
		<html>
		<body>
			<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
			&nbsp;
			  <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
				<tr >
				  <!--XSSOK-->
				  <td class="errorHeader"><%=integSessionData.getStringResource("mcadIntegration.Server.Heading.Error")%></td>
				</tr>
				<tr align="center">
				  <td class="errorMessage" align="center"><%=emxNavErrorObject%></td>
				</tr>
			  </table>
		</body>
		</html>
<%
	}
%>

	


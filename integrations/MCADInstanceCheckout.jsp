<%--  MCADInstanceCheckout.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import = "com.matrixone.apps.domain.util.*" %>>
<%
	String objectID				= Request.getParameter(request,"objectId");
	String instanceName			= Request.getParameter(request,"instanceName");
	String representationName	= Request.getParameter(request,"representationName");

	if(instanceName != null)
	{
		instanceName = MCADUrlUtil.hexDecode(instanceName);
	}
	else
	{
		instanceName = "";
	}

	if(representationName != null)
	{
		representationName = MCADUrlUtil.hexDecode(representationName);
	}
	else
	{
		representationName = "";
	}

    //DMUSession customization
    //Find out DMUSession object connected with minor object. Assign its name to variable dmuSessionName
    String dmuSessionName	= "";

    if(dmuSessionName != null)
	{
		dmuSessionName = MCADUrlUtil.hexDecode(dmuSessionName);
	}
	else
	{
		dmuSessionName = "";
	}

	String integrationName			= null;
	String[] objectCheckoutDetails	= null;

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	if (integSessionData != null)
	{
		MCADMxUtil util	= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName = util.getIntegrationName(integSessionData.getClonedContext(session), objectID);

		MCADServerGeneralUtil serverGeneralUtil	= new MCADServerGeneralUtil(integSessionData.getClonedContext(session), integSessionData, integrationName);
		objectCheckoutDetails					= serverGeneralUtil.getValidObjctIdForCheckout(integSessionData.getClonedContext(session), objectID);
	}
	else
	{
		String acceptLanguage = request.getHeader("Accept-Language");
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

		String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");

		objectCheckoutDetails = new String[3];
		objectCheckoutDetails[0] = "false";
		objectCheckoutDetails[1] = objectID;
		objectCheckoutDetails[2] = errorMessage;
	}
%>

<html>
<head>
	<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
	<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</head>

<body>
	<script Language="JavaScript">
	    //XSSOK
		checkout('<%= integrationName %>', "<%= objectCheckoutDetails[0] %>", "<%= objectCheckoutDetails[1] %>|<%= instanceName %>|<%= representationName %>|<%= dmuSessionName %>", "<%= objectCheckoutDetails[2] %>", "interactive", "false");
	</script>
</body>
</html>

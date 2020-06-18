<%--  emxAppletTimeOutErrorPage.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file = "MCADTopInclude.inc" %>
<%@ page import = "com.matrixone.apps.framework.ui.*, java.util.*, com.matrixone.MCADIntegration.server.*, com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
	
	MCADIntegrationSessionData integSessionData	  = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	String isAppletLoaded						  = (String) session.getAttribute("mcadintegration.applet.loaded");
	String featureName							  =Request.getParameter(request,"featureName");
    String errorMessage							  = "";
	try 
	{
		if(integSessionData != null)
		{
			if(featureName == null)
				featureName = "";

			Hashtable exceptionDetails = new Hashtable(1);
			exceptionDetails.put("NAME",integSessionData.getStringResource("mcadIntegration.Server.Feature."+featureName));
			errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.FeatureNotAllowedForNonIntegrationUser",exceptionDetails);
		}
		else
		{
			if(isAppletLoaded == null)
				errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
			else if(isAppletLoaded.trim().equals("true"))
			{
				String I18NResourceBundle = "emxIEFDesignCenterStringResource";
				errorMessage			  = UINavigatorUtil.getI18nString("emxIEFDesignCenter.Error.AppletNotLoadedOrNoIntegration", "emxIEFDesignCenterStringResource", acceptLanguage);
			}
		}
    }
    catch (Exception e)
    {
	}
%>
<html>
<head>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css"><!--This is required for the font of the text-->
<style type=text/css > 
  span.error {
        color: red;
        font-family: verdana, helvetica, arial, sans-serif; 
	font-size: 10pt; 
  }
</style>
</head>

<body class="content">
 <span class="error">
 <BR>   
<%
   StringTokenizer st = new StringTokenizer(errorMessage, "|");
   while(st.hasMoreTokens())
   {
       String token = st.nextToken();
%>
            <!--XSSOK-->
            <%=token%>
            <BR>
<%
   }
 %>
 </span>
</body>
</html>



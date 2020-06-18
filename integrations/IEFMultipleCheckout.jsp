<%--  IEFMultipleCheckout.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>



<%@include file = "MCADTopInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	java.util.Enumeration itl =emxGetParameterNames(request);

	String launchCADTool		=Request.getParameter(request,"LaunchCADTool");
	String action		=Request.getParameter(request,"action");

	String errorMessage			= ""; 

%>
<html>
<head>
</head>
<body onload = showErrorMessage() >

<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
	String featureName	  = MCADGlobalConfigObject.FEATURE_CHECKOUT;	

	if(null != action && action.equalsIgnoreCase(MCADGlobalConfigObject.FEATURE_QUICKCHECKOUT))
		featureName = MCADGlobalConfigObject.FEATURE_QUICKCHECKOUT;

	String[] objectIds	  = emxGetParameterValues(request, "emxTableRowId");
	String acceptLanguage = request.getHeader("Accept-Language");

	for(int i=0; i < objectIds.length; i++)
	{
		//emxTableRowId value is obtained in the format relID|objectid Or ObjectId. Need to parse the value
		StringList sList = FrameworkUtil.split(objectIds[i],"|");
	  
		if(sList.size() == 1 || sList.size() == 2)
		         objectIds[i] = (String)sList.get(0);

		//Structure Browser value is obtained in the format relID|objectID|parentID|additionalInformation
		else if(sList.size() == 3)
			objectIds[i] = (String)sList.get(0);
		
		else if(sList.size() == 4)
			objectIds[i] = (String)sList.get(1);
	}

    //For DMUSession implementation, populate this map as objectId Vs DMUSessionName.
    HashMap objectIdDmuSessionNameMap = null;
    String dmuSessionName = "";
	
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context  context	= integSessionData.getClonedContext(session);
	if(integSessionData != null) 
	{
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		String localeLanguage	= integSessionData.getLanguageName();
		String integrationName	= util.getIntegrationName(context, objectIds[0]);
		String[] objectCheckoutDetails = null;
		
		try
		{
			for(int i=0;i<objectIds.length;i++)
			{
				integrationName = util.getIntegrationName(context, objectIds[i]);
				
				if (integrationName != null && !"null".equalsIgnoreCase(integrationName) && !"".equalsIgnoreCase(integrationName))
				{
					if(integrationName.equals(MCADAppletServletProtocol.SOLIDWORKS_INTEG_NAME))
					{
						Hashtable messageTable = new Hashtable(2);
						messageTable.put("NAME", integSessionData.getStringResource("mcadIntegration.Server.Feature.checkout"));
						messageTable.put("INTEGNAME", integrationName);

						errorMessage = integSessionData.getResourceBundle().getString("mcadIntegration.Server.Message.FeatureNotSupported", messageTable);
						throw new Exception(errorMessage);
					}

					String isFeatureAllowed = integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
					if(!isFeatureAllowed.startsWith("true"))
					{
						errorMessage = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
						throw new Exception(errorMessage);
					}

					BusinessObject bus = new BusinessObject(objectIds[i]);
					bus.open(context);
					String typeName = bus.getTypeName();
					bus.close(context);
					boolean isOperationAllowed = integSessionData.isOperationAllowed(context,integrationName,typeName,featureName);
					
					if(!isOperationAllowed)
					{
						errorMessage = featureName + " " + UINavigatorUtil.getI18nString("emxIEFDesignCenter.Error.OperationNotAllowed","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language")) + " " + typeName;

						throw new Exception(errorMessage);
					}
				}
				else 
				{
					errorMessage = UINavigatorUtil.getI18nString("emxIEFDesignCenter.Common.NotIntegrationSpecific","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"));
					throw new Exception(errorMessage);
				}
			}

			HashMap argumentsMap = new HashMap();

			argumentsMap.put("ObjectIDs", objectIds);
			argumentsMap.put("ObjectIDsDMUSessionNameTable", objectIdDmuSessionNameMap);
			argumentsMap.put("LocaleLanguage", localeLanguage);
			argumentsMap.put("GCOTable", integSessionData.getIntegrationNameGCOTable(context));
			argumentsMap.put("LCO", integSessionData.getLocalConfigObject());

			String [] packedArguments = JPO.packArgs(argumentsMap);
			objectCheckoutDetails     = util.executeJPOReturnStrArray(context, "IEFMultipleCheckout", "getValidObjIdsForCheckout", packedArguments);			
%>


			<script language="JavaScript">
				function showCheckoutPage(selectedIntegrationName)
				{					
					if(<%=XSSUtil.encodeForJavaScript(context,launchCADTool)%>== null)
					{
						checkout(selectedIntegrationName, "<%=objectCheckoutDetails[1]%>", "<%=objectCheckoutDetails[2]%>", "<%=objectCheckoutDetails[3]%>", "interactive", "false");
					}
					else
					{
						checkout(selectedIntegrationName, "<%=objectCheckoutDetails[1]%>", "<%=objectCheckoutDetails[2]%>", "<%=objectCheckoutDetails[3]%>","silent","<%=XSSUtil.encodeForJavaScript(context,launchCADTool)%>");
					}
				}
				var commandDetails = "";
				</script>
<%
			
				if(objectCheckoutDetails[4] != null && objectCheckoutDetails[4].equalsIgnoreCase(MCADAppletServletProtocol.TYPE_NEUTRAL))
				{
%>
						<script language="JavaScript">

						var integrationFrame	= getIntegrationFrame(this);						
						var detailsArray;

						if(integrationFrame!=null)
						{	
							var mxmcadApplet = integrationFrame.getAppletObject(); 
							if(mxmcadApplet != null)
							{								
                                //XSSOK							
								commandDetails	= mxmcadApplet.callCommandHandlerSynchronously("<%=integrationName%>", "getCommandDetails", "<%=integrationName%>");
								
							commandDetails = commandDetails + "";
							detailsArray	= commandDetails.split('|');							
						}
						}
						if(detailsArray[0] != null && detailsArray[0] != "" && detailsArray[1] != null && detailsArray[1] == "checkout")
						{							
							showCheckoutPage(detailsArray[0]);
						}						
						</script>
<%
				}
				if(objectCheckoutDetails[0] == null || objectCheckoutDetails[0] == "")			
				{			
%>
					<script language="JavaScript">
					if(commandDetails == null || commandDetails == "")
					{
						showIEFModalDialog("IEFIntegrationChooserFS.jsp?keepOpen=false&eventHandler=showCheckoutPage", "300", "325");
					}
					</script>
<%
				}
		}
		catch(Exception e)
		{
			objectCheckoutDetails	 = new String[4];
            objectCheckoutDetails[0] = "";
			objectCheckoutDetails[1] = "false";
			objectCheckoutDetails[2] = "";
			objectCheckoutDetails[3] = e.getMessage();
			errorMessage			 = e.getMessage();
		}
%>
<script language="JavaScript">
if("<%=objectCheckoutDetails[0]%>" != null && "<%=objectCheckoutDetails[0]%>" != "")
{
	if(<%=XSSUtil.encodeForJavaScript(context,launchCADTool)%>== null)
	{
		checkout("<%=objectCheckoutDetails[0]%>", "<%=objectCheckoutDetails[1]%>", "<%=objectCheckoutDetails[2]%>", "<%=objectCheckoutDetails[3]%>", "interactive", "false");
	}
	else
	{
		checkout("<%=objectCheckoutDetails[0]%>", "<%=objectCheckoutDetails[1]%>", "<%=objectCheckoutDetails[2]%>", "<%=objectCheckoutDetails[3]%>","silent","<%=XSSUtil.encodeForJavaScript(context,launchCADTool)%>");
	}
}


</script>
<%
}
else
{
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
	String sessionTimeOutMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
%>
<script language="JavaScript">
    //XSSOK
	alert("<%=sessionTimeOutMessage%>");
</script>
<%
}
%>
<script language="JavaScript">
function showErrorMessage()
{	
    //XSSOK
	if("<%=errorMessage%>" != "")
	{
	    //XSSOK
		alert("<%=errorMessage%>");
	}
	window.close();
}
</script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
</body>
</html>

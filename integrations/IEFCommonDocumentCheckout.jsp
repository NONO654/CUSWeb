<%--  IEFCommonDocumentCheckout.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ page import = "com.matrixone.MCADIntegration.utils.UUID" %>
<%@ include file ="MCADTopInclude.inc" %>
<%@include file= "../common/emxNavigatorTopErrorInclude.inc"%>
<% 	 
    matrix.db.Context context = Framework.getFrameContext(session);
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	if(integSessionData == null)//user is not assigned any or the session has expired. Show error.
	{
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(request.getHeader("Accept-Language"));
        
		String errorMessage		= serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else //go ahead only if integSessionData is not null.
	{
	context											= integSessionData.getClonedContext(session);
	String languageStr								= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(languageStr);

	MCADMxUtil mxUtil				= new MCADMxUtil(context, serverResourceBundle, integSessionData.getGlobalCache());
	
	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
	Hashtable integrationNameGCONameMap		= new Hashtable();
				
	if(localConfigObject != null)
		integrationNameGCONameMap = localConfigObject.getIntegrationNameGCONameMapping();

	Map emxCommonDocumentCheckoutData = (Map) session.getAttribute("emxCommonDocumentCheckoutData");
	String objectId = (String) emxCommonDocumentCheckoutData.get("objectId");
	if(objectId == null || "".equals(objectId))
	{
		String[] objectIds = (String[]) emxCommonDocumentCheckoutData.get("objectIds");
		if(objectIds != null && objectIds.length > 0)
			objectId = objectIds[0];
	}

	String[] objectCheckoutDetails = new String[3];
	objectCheckoutDetails[0] = "true";
	objectCheckoutDetails[1] = objectId;
	objectCheckoutDetails[2] = "";

	String integrationName	= mxUtil.getIntegrationName(context, objectId);
	String featureName		= MCADGlobalConfigObject.FEATURE_CHECKOUT;
	String isFeatureAllowed	= "";


	isFeatureAllowed = integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
		
	if(isFeatureAllowed.startsWith("true"))
		isFeatureAllowed = "true";
	else
		emxNavErrorObject.addMessage(isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length()));

		String actionLink = "";
		String errMessage		= "";
		
		
	if(integrationName != null && integrationNameGCONameMap.containsKey(integrationName))
	{
		MCADGlobalConfigObject gco              = integSessionData.getGlobalConfigObject(integrationName,context);
		MCADServerGeneralUtil serverGeneralUtil = new MCADServerGeneralUtil(context, gco, serverResourceBundle, integSessionData.getGlobalCache());
		objectCheckoutDetails					= serverGeneralUtil.getValidObjctIdForCheckout(context, objectId);
			
			String jpoName	= gco.getFeatureJPO("OpenFromWeb");

			if(null != jpoName && !"".equals(jpoName))	
			{
				Hashtable jpoArgsTable = new Hashtable();

				jpoArgsTable.put(MCADServerSettings.GCO_OBJECT, gco);
				jpoArgsTable.put(MCADServerSettings.LANGUAGE_NAME, serverResourceBundle.getLanguageName());
				jpoArgsTable.put(MCADServerSettings.OBJECT_ID, objectCheckoutDetails[1]);
				jpoArgsTable.put(MCADAppletServletProtocol.INTEGRATION_NAME, integrationName);
				jpoArgsTable.put(MCADServerSettings.OPERATION_UID, UUID.getNewUUIDString());
				jpoArgsTable.put("featureName", "open");

				String[] args 			= JPO.packArgs(jpoArgsTable);

				Hashtable result 		= (Hashtable) JPO.invoke(context, jpoName, new String[] {}, "execute", args, Hashtable.class);
				String hrefLink			= (String) result.get("hrefString");
				
				actionLink	= "../integrations/IEFCustomProtocolHandler.jsp?integrationname=" + integrationName + "&hreflink=" + hrefLink;

	}
			else
			{
				Hashtable messageTable = new Hashtable(2);
				messageTable.put("NAME", integSessionData.getStringResource("mcadIntegration.Server.Feature.checkout"));
				messageTable.put("INTEGNAME", integrationName);

				errMessage = integSessionData.getResourceBundle().getString("mcadIntegration.Server.Message.FeatureNotSupported", messageTable);
			}
		}
		
%>

<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
//XSSOK
if("<%= isFeatureAllowed %>" == "true")
	{
	       //XSSOK
	       if("<%=errMessage%>" == "")
		      //XSSOK
		      document.location.href = "<%=actionLink%>";
        	else
			    //XSSOK
	        	alert("<%=errMessage%>");
	}
	else
	      //XSSOK
	      alert("<%= isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length()) %>");
	
</script>
<%
	}// end of integSessionData null check
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

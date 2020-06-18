<%--  DSCMCADMultiPromote.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--  IEFObjectsUnlock.jsp   -  Does unlock operation on selected objects.
--%>

<%@ include file = "MCADTopInclude.inc" %>
<%@ include file = "MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
	String featureName			= MCADGlobalConfigObject.FEATURE_PROMOTE;
	java.util.Enumeration itl	= emxGetParameterNames(request);
	
	String sIntegrationName		=Request.getParameter(request,"tableFilter");
	String sAction				=Request.getParameter(request,"action");
	String sRefreshFrame		=Request.getParameter(request,"refreshFrame");
	String currentObjectId		=Request.getParameter(request,"objectId");

	String actionURL						= "";
	String sObjectId						= "";
	String integrationName					= "";
	String checkoutStatus					= "";
	String objectsInfo						= "";
	String checkoutMessage					= "";
	String errorMessage						= "";
	Context _context						= null;
	String[] objectCheckoutDetails			= null;
	String params							= "";
	String sTargetLocation					= "";
	String selectedObjectIds				= "";
	String isMultiPromote					= "false";
	String restrictMultiPromoteToECOSearch	= "false";

	MCADIntegrationSessionData integSessionData		= (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	String acceptLanguage							= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
	String unSupportedCommandErrorMessage			= "";
	String otherCommandActiveErrorMessage			= "";

	if(integSessionData != null)
	{   		
		Context context = integSessionData.getClonedContext(session);
		ENOCsrfGuard.validateRequest(context, session, request, response);
		unSupportedCommandErrorMessage	= integSessionData.getResourceBundle().getString("mcadIntegration.Server.Message.UnSupportedCommand");
		otherCommandActiveErrorMessage	= integSessionData.getResourceBundle().getString("mcadIntegration.Server.Message.OtherCommandActive");
		restrictMultiPromoteToECOSearch	= integSessionData.getPropertyValue("mcadIntegration.RestrictMultiPromoteToECOSearch").toLowerCase();	

		String[] objectIds	= emxGetParameterValues(request, "emxTableRowId");
		sTargetLocation =Request.getParameter(request,"Target Location");
		
		if (objectIds == null || objectIds.equals("null"))
		{
		    String objectId = (String)Request.getParameter(request,"objectId");
		    if (null != objectId)
		    {
		        objectIds = new String[1];
		        objectIds[0] = objectId;         
		    }
		}
		else if(objectIds!=null && objectIds.length>0)
		{
			for(int i=0; i < objectIds.length; i++)
			{
				//emxTableRowId value is obtained in the format relID|rowInfo Or ObjectId. Need to parse the value
				StringList sList = FrameworkUtil.split(objectIds[i],"|");
			
				if(sList.size() == 1 || sList.size() == 2)
				    objectIds[i] = (String)sList.get(0);

			        //StructureBrowser value is obtained in the format relID|objectID|parentID|additionalInformation
				else if(sList.size() == 3)
				    objectIds[i] = (String)sList.get(0);
					
				else if(sList.size() == 4)
				    objectIds[i] = (String)sList.get(1);
			}
		}
		
		if(objectIds.length>1)
			isMultiPromote = "true";
		
		
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(),integSessionData.getGlobalCache());
        
		if (null == objectIds || objectIds.length <= 0)
		{
			 String message	= integSessionData.getResourceBundle().getString("mcadIntegration.Server.Message.ErrorNoSelection");				 
			 actionURL		= "./MCADMessageFS.jsp?";
			 actionURL		+= "&message=" + message;
			 errorMessage	= message;
		}
		else
		{
			String lastIntegName = "";
			
			boolean errorOccured  = false;
			try
			{
				for(int i=0; i < objectIds.length; i++)
				{
					sObjectId				= objectIds[i];
					integrationName			= util.getIntegrationName(integSessionData.getClonedContext(session),sObjectId);
					MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
				
					
					if(!"".equals(lastIntegName) && lastIntegName != null && !lastIntegName.equals(integrationName))
					{
						String message	= integSessionData.getResourceBundle().getString("mcadIntegration.Server.Message.ErrorMultipleGCOObjectSelection");
						actionURL		= "./MCADMessageFS.jsp?";
						actionURL		+= "&message=" + message;
						errorMessage	= message;
						errorOccured	= true;
						break;
					}

					lastIntegName		= integrationName;
		
				
					BusinessObject bus = new BusinessObject(sObjectId);
					bus.open(context);
					String typeNameOrig		= bus.getTypeName();
					String typeName			= typeNameOrig;

					//[NDM] OP6
					/*if(!globalConfigObject.isMajorType(typeName))
					{						
						typeName = util.getCorrespondingType(context, typeName);
					}*/
					
					bus.close(context);
				    
					boolean isOperationAllowed = integSessionData.isOperationAllowed(context,integrationName,typeName,sAction);
					
					if(!isOperationAllowed)
					{
						if("".equals(errorMessage))
						{
							errorMessage = sAction + " " + UINavigatorUtil.getI18nString("emxIEFDesignCenter.Error.OperationNotAllowed","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language")) + " " + typeNameOrig;
						}
						else
						{
							errorMessage = errorMessage + " ||| " + sAction + " " + UINavigatorUtil.getI18nString("emxIEFDesignCenter.Error.OperationNotAllowed","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language")) + " " + typeNameOrig;
						}
						
					}
					
					
					if("".equals(selectedObjectIds))
					{
						selectedObjectIds = sObjectId;
					}
					else
					{
						selectedObjectIds = selectedObjectIds + "," + sObjectId;
					}
				}

				String isFeatureAllowed	= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
				if(!isFeatureAllowed.startsWith("true"))
				{
					String message	= isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
					actionURL		= "./MCADMessageFS.jsp?";
					actionURL		+= "&message=" + message;
					errorMessage	= message;
					errorOccured	= true;
				}

				if(lastIntegName != null && !lastIntegName.equals("") && errorOccured == false)
				{
  					MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
							
					HashMap paramMap		= new HashMap();
					MapList objectList		= new MapList();
					HashMap objectDetails	= new HashMap();
					HashMap gcoMap			= new HashMap();
				   
					objectDetails.put("id", selectedObjectIds);
					objectList.add(objectDetails);
					gcoMap.put(lastIntegName, globalConfigObject);
					paramMap.put("objectList", objectList);
					paramMap.put("GCOTable", gcoMap);
					paramMap.put("LocaleLanguage", integSessionData.getLanguageName());
					
					String[] init		= new String[] {};
					String jpoMethod	= "getURL";
					String jpoName		= "DSCShowPromoteLink";
					
					_context   = Framework.getFrameContext(session);
					
					String url = (String)JPO.invoke(_context, jpoName, init, jpoMethod, 
								   JPO.packArgs(paramMap), String.class);
					actionURL += url; 
					actionURL += "&integrationName=" + lastIntegName;					
				}

				if(sAction.equalsIgnoreCase("AppletFreeMultiPromote"))
				{	
					String site = "  ../integrations/DSCProgressBarForAppletFree.jsp?url=../integrations/DSCpromoteAppletFree.jsp&refreshFrame=content&objectIds="+selectedObjectIds+"&integrationName="+lastIntegName+"&action=AppletFreePromote";
									
			        response.setStatus(response.SC_MOVED_TEMPORARILY);
			        response.setHeader("Location", site); 
				}

			}
			catch(Exception exception)
			{
				emxNavErrorObject.addMessage(exception.getMessage());
			}	
		}
	}
	else
	{
		String message	= serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");	
		emxNavErrorObject.addMessage(message);
		errorMessage	= message;
	}
%>
<html>
<head>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="JavaScript" type="text/javascript" src="../emxUIPageUtility.js"></script>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>

<script language="javascript" >

var refreshFrame		= getFrameObject(top, '<%=XSSUtil.encodeForJavaScript(_context,sRefreshFrame)%>');
var integrationFrame	= getIntegrationFrame(this);
if(integrationFrame != null)
{
	if(refreshFrame == null) 
	{
		//Set the refresh for Full Search
		refreshFrame = getFrameObject(top, "structure_browser");
	}

	integrationFrame.setActiveRefreshFrame(refreshFrame);
}

function showDialogPopup(url) 
{
	var integrationFrame			= getIntegrationFrame(this);
	//XSSOK
	var integrationName				= '<%=integrationName%>';
	//XSSOK
	var unSupportedCommandErrorMsg	= "<%=unSupportedCommandErrorMessage%>";
	//XSSOK
	var otherCommandActiveErrorMsg	= "<%=otherCommandActiveErrorMessage%>";
	var details						= integrationName;
	
	var commandName = null;
	if(integrationFrame!=null)
	{
		var mxmcadApplet = integrationFrame.getAppletObject(); 
		if(mxmcadApplet!= null)
			commandName = mxmcadApplet.callCommandHandlerSynchronously(integrationName, "getCommandName", details);
	}	
	if(commandName!=null && commandName == 'initiatewsm')
	{
		alert(unSupportedCommandErrorMsg);
	}
	else
	{
		var isCommandActive = integrationFrame.isDSCCommandActive();
        //XSSOK
		if ("<%=errorMessage%>" == '')
		{   //XSSOK
			if(parent != null && parent.location != null && "<%=isMultiPromote%>" == "true" && "<%=restrictMultiPromoteToECOSearch%>"=="true" && parent.location.href.indexOf("table=DSCECOSearch") == -1)
			    //XSSOK
				alert("<%=serverResourceBundle.getString("mcadIntegration.Server.Message.MultiPromoteRestrictedToECOSearch")%>");
			else
			{
				if("<%=XSSUtil.encodeForJavaScript(_context,sAction)%>" == "MultiPromote")
				{
					if(isCommandActive=="true" || isCommandActive==true)
					{
						alert(otherCommandActiveErrorMsg);
					}
					else
					{
						var finalizationDetails = null;
						//XSSOK
						if("<%=isMultiPromote%>" == "true")
						    //XSSOK
							finalizationDetails = '<%=integrationName%>' + "@" + "isMultiPromote|" + '<%=XSSUtil.encodeForJavaScript(_context,selectedObjectIds)%>';
						else
						    //XSSOK
							finalizationDetails = '<%=integrationName%>' + "|" + '<%=XSSUtil.encodeForJavaScript(_context,selectedObjectIds)%>';
                            //XSSOK
						showFinalizationPage('<%=integrationName%>', finalizationDetails);
					}
				}
				else
				{
					showIEFModalDialog(url, '500', '500');
				}
			}
		}
	}
}
</script>

</head>

<%@include file = "MCADBottomErrorInclude.inc"%>
<body onLoad="showDialogPopup('<%=actionURL%>')">
    
<script language="javascript" >
        //XSSOK
	if ("<%=errorMessage%>" != '')
	   //XSSOK
	   javascript:alert("<%=errorMessage%>");

</script>
	
</body>
</html>

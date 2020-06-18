<%--  IEFObjectsLockUnlock.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ include file="../iefdesigncenter/emxInfoTableInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.utils.xml.IEFXmlNodeImpl,com.matrixone.MCADIntegration.utils.xml.IEFXmlNode" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%
    DSCServerErrorMessageTable errorMessageTable		  = null;
	String acceptLanguage						  = request.getHeader("Accept-Language");
	String action								  = emxGetParameter(request, "action");  // "lock" or "unlock"

	String featureName							  = MCADGlobalConfigObject.FEATURE_LOCK_UNLOCK;

	String isFeatureAllowed						  = "";

	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	String integrationName						  = "";
	String[] objectIds							  = null;
	String errMsg								  = "";
	boolean bLockUnlockObjects					  = true;
	boolean	bLock								  = false;
	boolean isObjectDetailsPageRequest			  = false;
	String bEnableAppletFree = MCADAppletServletProtocol.FALSE;
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context		= integSessionData.getClonedContext(session);
	if(integSessionData != null)
	{
		objectIds = emxGetParameterValues(request, "emxTableRowId");

		if (objectIds == null || objectIds.equals("null"))
		{
			String objectId = (String)Request.getParameter(request,"objectId");
			if (null != objectId)
			{
				objectIds = new String[1];
				objectIds[0] = XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),objectId);
				isObjectDetailsPageRequest = true;
			}
		}
		else
		{
			for(int i=0; i < objectIds.length; i++)
			{
				//emxTableRowId value is obtained in the format relID|objectid Or ObjectId. Need to parse the value
				StringList sList = FrameworkUtil.split(objectIds[i],"|");
				
				if(sList.size() == 1 || sList.size() == 2)
					objectIds[i] = (String)sList.get(0);

				// StructureBrowser value is obtained in the format relID|objectID|parentID|additionalInformation 
				else if(sList.size() == 3)
					objectIds[i] = (String)sList.get(0);

				else if(sList.size() == 4)
					objectIds[i] = (String)sList.get(1);
			}
		}

		
		ENOCsrfGuard.validateRequest(context, session, request, response);	
		MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		errorMessageTable	= new DSCServerErrorMessageTable(context, integSessionData.getIntegrationNameGCOTable(context), util, integSessionData.getResourceBundle());
		errorMessageTable.setRootId("");

		//boolean isMajorType = false; [NDM] OP6
		for(int i=0; i < objectIds.length; i++)
		{
			try
			{
				objectIds[i]	= util.getValidObjectIdForLockunlock(context, objectIds[i]);
				integrationName	= util.getIntegrationName(context, objectIds[i]);

				if(integrationName != null && !integrationName.equals(""))
				{

					isFeatureAllowed = integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
					if(!isFeatureAllowed.startsWith("true"))
					{
						bLockUnlockObjects = false;
						errMsg = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
						throw new Exception(errMsg);
					}

				}
				else
				{
					bLockUnlockObjects = false;
					errMsg = UINavigatorUtil.getI18nString("emxIEFDesignCenter.Common.NotIntegrationSpecific","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"));
					throw new Exception(errMsg);
				}
			}
			catch(Exception exception)
			{
				errorMessageTable.addErrorMessage(context, objectIds[i], exception.getMessage());
			}
		}

		if (action.equalsIgnoreCase("lock"))
			bLock = true;

		if(bLockUnlockObjects)
		{
			String objIds = null;
			StringBuffer objIdBuffer = new StringBuffer();
			for(int i=0; i < objectIds.length; i++)
			{

				objIdBuffer.append(objectIds[i]);
				if(i < objectIds.length -1)
				objIdBuffer.append("#");
				}
			objIds = objIdBuffer.toString();

			String makeFileReadOnlyDetails = null;
			makeFileReadOnlyDetails = objIds+"|"+bLock+"|"+integrationName;
			String headerRes = "mcadIntegration.Server.Title.LockUnlokResult";
		%>
			<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
			<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
			<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
			<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
			<script language = "Javascript">
			//XSSOK
			var makeFileReadOnlyDetails = '<%=makeFileReadOnlyDetails%>';
			//XSSOK
			var integrationName			= '<%=integrationName%>';
			var integrationFrame		= getIntegrationFrame(this);
			var messageToShow			= "";

			<%	
			boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);
			if(bEnableAppletFreeUI)
			{
				bEnableAppletFree = MCADAppletServletProtocol.TRUE;
				IEFXmlNodeImpl commandNode = new IEFXmlNodeImpl(IEFXmlNodeImpl.TAG);	
				commandNode.setName("command");

				IEFXmlNodeImpl cadObjectListNode = new IEFXmlNodeImpl(IEFXmlNodeImpl.TAG);	
				cadObjectListNode.setName("cadobjectlist");

				commandNode.addNode(cadObjectListNode);

				if(objIds.indexOf("#") > -1)
				{
					StringTokenizer token = new StringTokenizer(objIds ,"#");
					while(token.hasMoreTokens())
					{
						String busId 			= token.nextToken().trim();					

						IEFXmlNodeImpl cadObjectNode = new IEFXmlNodeImpl(IEFXmlNodeImpl.TAG);					
						cadObjectNode.setName("cadobject");

						Hashtable cadObjectAttributes = new Hashtable();
						cadObjectAttributes.put("busid", busId);
						//if(lockObject.equalsIgnoreCase("true"))
					//	{
							cadObjectAttributes.put("action", action);
					//	}
						//else
						//{
						//	cadObjectAttributes.put("action", "unlock");
						//}

						cadObjectAttributes.put("type", "");
						cadObjectAttributes.put("name", "");					
						cadObjectAttributes.put("dirname", "");
						cadObjectAttributes.put("filename", "");
						cadObjectAttributes.put("islocked", "");
						cadObjectAttributes.put("lockedby", "");
						cadObjectAttributes.put("mxtype", "");
						cadObjectAttributes.put("mxversion", "");
						cadObjectAttributes.put("hashcode", "");
						cadObjectAttributes.put("cadid", "");

						cadObjectNode.setAttributes(cadObjectAttributes);
						cadObjectListNode.addNode(cadObjectNode);

					}
				}
				else
				{
					IEFXmlNodeImpl cadObjectNode = new IEFXmlNodeImpl(IEFXmlNodeImpl.TAG);
					cadObjectNode.setName("cadobject");

					Hashtable cadObjectAttributes = new Hashtable();
					cadObjectAttributes.put("busid", objIds);
					cadObjectAttributes.put("action", action);   
					cadObjectAttributes.put("type", "");
					cadObjectAttributes.put("name", "");					
					cadObjectAttributes.put("dirname", "");
					cadObjectAttributes.put("filename", "");
					cadObjectAttributes.put("islocked", "");
					cadObjectAttributes.put("lockedby", "");
					cadObjectAttributes.put("mxtype", "");
					cadObjectAttributes.put("mxversion", "");
					cadObjectAttributes.put("hashcode", "");
					cadObjectAttributes.put("cadid", "");

					cadObjectNode.setAttributes(cadObjectAttributes);

					cadObjectListNode.addNode(cadObjectNode);   
				}
				
				IEFLockUnlockExHandler lockUnlockExHandler	= new IEFLockUnlockExHandler(context, integSessionData, commandNode, integrationName,true);
				lockUnlockExHandler.start();
			}
			else
			{
	%>	
			
			
			var response = integrationFrame.getAppletObject().callCommandHandlerSynchronously("", 'executeLockUnlockCommand', makeFileReadOnlyDetails);

	            if(response != null && response.length > 0)
				{
					messageToShow =  response;
					//XSSOK
					var messageDialogURL = "DSCErrorMessageDialogFS.jsp?messageHeader=<%= headerRes %>&headerImage=images/iconError.gif&showExportIcon=false&callBackFunction=refreshParent";
					showIEFModalDialog(messageDialogURL, 500, 400);
				}

			</script>
		<%
		}}
	}
	else
	{
		String errorMessage	= serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		emxNavErrorObject.addMessage(errorMessage);
	}
%>
<html>
<head>
</head>
<%@include file = "MCADBottomErrorInclude.inc"%>
<body>

<%@ include file="../iefdesigncenter/DSCIndentedTableInclude.inc" %>

<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUITableUtil.js"  type="text/javascript"></script>

	<script language="javascript" >
var bEnableAppletFree = <%= XSSUtil.encodeForJavaScript(context,bEnableAppletFree) %>;

				if(bEnableAppletFree == true)
				{
					parent.location.href = parent.location.href;
				}
	function refreshParent()
	{
	        //XSSOK
		var lockunlockObjects			= "<%=bLockUnlockObjects%>";
		//XSSOK
		var isObjectDetailsPageRequest	= "<%=isObjectDetailsPageRequest%>";

		if(isObjectDetailsPageRequest == "true")
		{
			parent.document.location.href=parent.document.location.href;
			//parent.location.reload();
		}
		else
		{
			var targetFrame		= top.findFrame(top, "listDisplay");
			if(targetFrame)
			{
				var objForm			= targetFrame.document.forms['emxTableForm'];
				var commandName		= (objForm && objForm.commandName) ? objForm.commandName.value : "";
				if (targetFrame && commandName!="Navigate")
				{
					if(lockunlockObjects == "true")
					{
						if(parent.listDisplay)
						refreshTableContent();
						else
							parent.document.location.href=parent.document.location.href;
					}
				}

				else
				{
					if(lockunlockObjects == "true")
					{
						var objectIds = '<%=objectIds%>';
						parent.reloadNavigateTable(objectIds);
					}
				}
			}
			else
			{
				var searchContentFrame		= top.findFrame(top, "searchContent");
				var detailsDisplayFrame		= top.findFrame(top, "detailsDisplay");
				var structureBrowserFrame	= top.findFrame(top, "structure_browser");
				var appletReturnHiddenFrame = top.findFrame(top, "appletReturnHiddenFrame");

				if(searchContentFrame)
					searchContentFrame.refreshSearchResultPage();
				else if(detailsDisplayFrame)
					refreshIndentedTable("detailsDisplay");
				else if(structureBrowserFrame)
					refreshIndentedTable("structure_browser");
				else if(appletReturnHiddenFrame)
					parent.parent.location.href = parent.parent.location.href;
				else
				{
					//window.parent.parent.location.reload();
					parent.parent.location.href = parent.parent.location.href;
					window.parent.opener.parent.location.reload();
				}
			}
		}
	}

<%
	if ( !((emxNavErrorObject.toString()).trim().length() > 0) && errorMessageTable != null && !errorMessageTable.errorsOccured())
	{
		//refresh table content frame.
%>
		if(messageToShow == null || messageToShow.length <= 0)
			refreshParent();
<%
	}
	else if(errorMessageTable != null && errorMessageTable.errorsOccured())
	{
		String message	= errorMessageTable.getErrorMessageHTMLTable();
		message			= MCADUtil.replaceString(message, "'","\"");
		String header	= "mcadIntegration.Server.ColumnName.ErrorMessage";
%>
        //XSSOK
		messageToShow	= '<%= message %>';
		//XSSOK
		var messageDialogURL = "DSCErrorMessageDialogFS.jsp?messageHeader=<%= header %>&headerImage=images/iconError.gif&showExportIcon=false";
		showIEFModalDialog(messageDialogURL, 500, 400);
<%
	}
%>
	</script>
</body>
</html>


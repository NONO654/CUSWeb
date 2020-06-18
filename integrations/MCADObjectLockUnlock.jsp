<%--  MCADObjectLockUnlock.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import = "com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.utils.xml.IEFXmlNodeImpl,com.matrixone.MCADIntegration.utils.xml.IEFXmlNode" %>
<%
	String busDetails		= Request.getParameter(request,"busDetails");

	StringTokenizer busDetailsTokens = new StringTokenizer(busDetails, "|");
	String integrationName	= busDetailsTokens.nextToken();
	String refreshBasePage	= busDetailsTokens.nextToken();
	String objectId			= busDetailsTokens.nextToken();
	String lockObject		= busDetailsTokens.nextToken();

	String operationStatus	= MCADAppletServletProtocol.FALSE;
	String errorMessage		= "";
	String bEnableAppletFree = MCADAppletServletProtocol.FALSE;
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
        Context context		= integSessionData.getClonedContext(session);
	if(integSessionData != null)
	{
		try
		{
			boolean isLockObject = (Boolean.valueOf(lockObject)).booleanValue();
			String makeFileReadOnlyDetails = null;
			makeFileReadOnlyDetails = objectId+"#"+"|"+lockObject+"|"+integrationName;
			String header				   = "mcadIntegration.Server.Title.LockUnlokResult";
%>
			<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
			<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
			<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
			<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
			<script language = "Javascript">
			    //XSSOK
				var makeFileReadOnlyDetails = '<%=makeFileReadOnlyDetails%>';
				//XSSOK
				var integrationName			= '<%=integrationName%>';
				//XSSOK
				var header					= '<%=header%>';
				var integrationFrame		= getIntegrationFrame(this);
				
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
	
					if(objectId.indexOf("#") > -1)
					{
						StringTokenizer token = new StringTokenizer(objectId ,"#");
						while(token.hasMoreTokens())
						{
							String busId 			= token.nextToken().trim();					
	
							IEFXmlNodeImpl cadObjectNode = new IEFXmlNodeImpl(IEFXmlNodeImpl.TAG);					
							cadObjectNode.setName("cadobject");
	
							Hashtable cadObjectAttributes = new Hashtable();
							cadObjectAttributes.put("busid", busId);
							if(lockObject.equalsIgnoreCase("true"))
							{
								cadObjectAttributes.put("action", "lock");
							}
							else
							{
								cadObjectAttributes.put("action", "unlock");
							}
	
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
						cadObjectAttributes.put("busid", objectId);
						if(lockObject.equalsIgnoreCase("true"))
						{
							cadObjectAttributes.put("action", "lock");
						}
						else
						{
							cadObjectAttributes.put("action", "unlock");
						}    
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

                var res = new String(response);
				if(response != null && res.length > 0)
				{
						messageToShow = response;
						//XSSOK
						var messageDialogURL = "DSCErrorMessageDialogFS.jsp?messageHeader=<%= header %>&headerImage=images/iconError.gif&showExportIcon=false";
						showIEFModalDialog(messageDialogURL, 500, 400);
				}
			</script>
<%
				}			
				operationStatus = MCADAppletServletProtocol.TRUE;
			}
		catch(Exception exception)
		{
			errorMessage = exception.getMessage();
		}
	}
	else
	{
		String acceptLanguage = request.getHeader("Accept-Language");
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}

	if(!errorMessage.equals(""))
	{
		StringTokenizer tokens = new StringTokenizer(errorMessage, "\n");
		String errMsg = "";
		while(tokens.hasMoreTokens())
		{
			errMsg += tokens.nextToken() + "\\n";
		}

		errorMessage = errMsg;
	}
%>

<html>
<head>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script>
</head>
<body>

<%@ include file="../iefdesigncenter/DSCIndentedTableInclude.inc" %>

<script language="javascript" >
    //XSSOK
	var operationStatus = <%= operationStatus %>;
	if (operationStatus == true)
	{
		var targetFrame = findFrame(top, "listDisplay");

		if(targetFrame)
		{
			var objForm			= targetFrame.document.forms['emxTableForm'];
			var commandName = (objForm && objForm.commandName) ? objForm.commandName.value : "";

			if (targetFrame && commandName!="Navigate")
			{
				if(parent.listDisplay)
				refreshTableContent();
				else
					parent.location.href = parent.location.href;
			}
			else if(commandName == "Navigate")
			{
			    //XSSOK
				var objectId = '<%=objectId%>';
				parent.reloadNavigateTable(objectId);
			}
		}
		else
		{
				var bEnableAppletFree = <%= XSSUtil.encodeForJavaScript(context,bEnableAppletFree) %>;
				if(bEnableAppletFree == true)
				{
					parent.location.href = parent.location.href;
				}
				else
				{
						if(response == "")
						{
							var searchContentFrame		= top.findFrame(top,"searchContent");
							var detailsDisplayFrame		= top.findFrame(top,"detailsDisplay");
							var structureBrowserFrame	= top.findFrame(top,"structure_browser");
							var appletReturnHiddenFrame = top.findFrame(top,"appletReturnHiddenFrame");

							if(searchContentFrame)
								searchContentFrame.refreshSearchResultPage();
							else if(detailsDisplayFrame)
									refreshIndentedTable("detailsDisplay");
							else if(structureBrowserFrame)
										refreshIndentedTable("structure_browser");
							else if(appletReturnHiddenFrame)
							{
								parent.parent.location.href = parent.parent.location.href;
							}
							else
							{
								parent.parent.location.href = parent.parent.location.href;
								window.parent.opener.parent.location.reload();
							//window.parent.parent.location.reload();
							}
						}
			
				}
		}
	}
	else
	{
	    //XSSOK
		alert("<%= errorMessage %>");
	}
	window.close();
</script>

</body>
</html>


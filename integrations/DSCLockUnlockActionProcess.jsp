<%--  DSCLockUnlockActionProcess.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.utils.xml.IEFXmlNodeImpl,com.matrixone.MCADIntegration.utils.xml.IEFXmlNode" %>
<script language="javascript">
var operationStatus = false;
</script>
<%
	String busDetails		=Request.getParameter(request,"busDetails");
	StringTokenizer busDetailsTokens = new StringTokenizer(busDetails, "|");
	String integrationName	= busDetailsTokens.nextToken();
	String refreshBasePage	= busDetailsTokens.nextToken();
	String objectId			= busDetailsTokens.nextToken();
	String lockObject		= busDetailsTokens.nextToken();
	String errorMessage		= "";
	Context context = null;
	String bEnableAppletFree = MCADAppletServletProtocol.FALSE;
	String operationStatus	= MCADAppletServletProtocol.FALSE;
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	if(integSessionData != null)
	{
		try
		{
			context					= integSessionData.getClonedContext(session);
			MCADMxUtil util			= new MCADMxUtil(context,integSessionData.getLogger(),integSessionData.getResourceBundle(),integSessionData.getGlobalCache());
			boolean isLockObject	= (Boolean.valueOf(lockObject)).booleanValue();
			integrationName			= util.getIntegrationName(context, objectId);
			if (integrationName != null && !integrationName.equals(""))
			{
				String makeFileReadOnlyDetails = null;
				makeFileReadOnlyDetails		   = objectId+"#"+"|"+lockObject+"|"+integrationName;
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
				if(response != null && response.length > 0)
			     {
						messageToShow = response + ""; 						
                        //XSSOK						
						var messageDialogURL = "DSCErrorMessageDialogFS.jsp?messageHeader=<%= header %>&headerImage=images/iconError.gif&showExportIcon=false";
						showIEFModalDialog(messageDialogURL, 500, 400);
				}
				else
					operationStatus = true;

				
<%
				}
				
				}
			     else
			     {
			      try
				  {
					  BusinessObject busObj = new BusinessObject(objectId);
					  busObj.open(context);
					  if (isLockObject)
						  busObj.lock(context);
					  else
						  busObj.unlock(context);
					  busObj.close(context);
				  }
				  catch (Exception e)
				  {
				  }
			}
			%>
			
			operationStatus = true;
			</script>
			<%
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
</head>
<body>
<script language="javascript" >

	if (operationStatus != true)
	{
	    //XSSOK
		if("<%= errorMessage %>" != "")
		//XSSOK
		alert("<%= errorMessage %>");
	}
	else if(operationStatus == true)
	{var bEnableAppletFree = <%= XSSUtil.encodeForJavaScript(context,bEnableAppletFree) %>;
		if(bEnableAppletFree == true)
	{
					parent.location.href = parent.location.href;
				}
				else 
		parent.document.location.href = parent.document.location.href;
	}
</script>

</body>
</html>

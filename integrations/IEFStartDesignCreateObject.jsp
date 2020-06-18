<%--  IEFStartDesignCreateObject.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="java.rmi.server.*"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

    String isOperationSuccessful = "";
	String errorMessage			 = "";	
	String rootDesignObjectID    = "";
	String isCheckoutRequired    = "";
	String parentObjectId        = "";
	String folderId				 = "";
	String _operationUID		 = "";
	_operationUID					= (new UID()).toString();

	String integrationName		= emxGetParameter(request, "integrationName");
	String specificationName	= emxGetParameter(request, "specificationName");

	if(integrationName != null && !integrationName.equals("") && !integrationName.equals("null"))
	{
		ENOCsrfGuard.validateRequest(context, session, request, response);
		MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
		MCADLocalConfigObject localConfigObject   = integSessionData.getLocalConfigObject();
		MCADMxUtil util							  = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

		String selectedTemplateObjID	= emxGetParameter(request, "templateObjID");
		String cadType					= emxGetParameter(request, "cadType");
		String partId					= emxGetParameter(request, "partId");
		String source					= emxGetParameter(request, "source");
		String type						= emxGetParameter(request, "TypeList");
		String name						= emxGetParameter(request, "SpecDrawingNum");
		String policy					= emxGetParameter(request, "PolicyList");
		String autoNameSeries			= emxGetParameter(request, "AutoNameList");
		String description				= emxGetParameter(request, "Description").trim();
		String customRevision			= emxGetParameter(request, "CustomRevLevel").trim();
		String autoNameChkbox			= emxGetParameter(request, "checkAutoName");
		folderId						= emxGetParameter(request, "folderId");
		isCheckoutRequired				= emxGetParameter(request, "isCheckoutRequired");		
		parentObjectId					= emxGetParameter(request, "parentObjectId");

		String _commandName = globalConfigObject.FEATURE_EBOMSYNCHRONIZE;
		
		String autoName = "false";
		if (autoNameChkbox != null && autoNameChkbox.equalsIgnoreCase("on")) 
		{
			autoName = "true";
		}

		Map map = (Map) session.getAttribute("startDesignAttributeMap");

		HashMap attributesMap = new HashMap();

		java.util.Set keys = map.keySet();
		Iterator itr = keys.iterator();
		while (itr.hasNext())
		{
			Map valueMap = (Map)map.get((String)itr.next());

			String attrName  = (String)valueMap.get("name");
			String attrValue ="";
			attrValue = emxGetParameter(request,attrName);

			if ((attrValue!= null) && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals(""))) 
			{
				attributesMap.put(attrName, attrValue);
			}
		}

		String mappedFormat = globalConfigObject.getFormatsForType(type, cadType);
		String renamedFrom  = util.getFileNameWithoutExtnForBusID(context, selectedTemplateObjID, mappedFormat);
		attributesMap.put("Renamed From", renamedFrom);

		//add "CAD Type" and "Source" attribute to this list
		attributesMap.put("CAD Type", cadType);
		attributesMap.put("Source", source);
		attributesMap.put("Description", description);
		attributesMap.put("IEF-FileSource", MCADAppletServletProtocol.FILESOURCE_TEMPLATE);
		attributesMap.put("IEF-Specification", specificationName);
		
		Hashtable argsForJPO = new Hashtable();

		argsForJPO.put("GCO",globalConfigObject);
		argsForJPO.put("LCO",localConfigObject);

		argsForJPO.put("languageName",integSessionData.getLanguageName());
		argsForJPO.put("templateObjID",selectedTemplateObjID);
		argsForJPO.put("type",type);
		argsForJPO.put("name",name);
		argsForJPO.put("customRevision",customRevision);
		argsForJPO.put("policy",policy);
		argsForJPO.put("autoName",autoName);
		argsForJPO.put("isRootObject","true");
		argsForJPO.put("attributesMap",attributesMap);
		argsForJPO.put("source",source);

	        if(globalConfigObject.isAssignCADModelNameFromPart())
			argsForJPO.put("partId",partId);
		else
			argsForJPO.put("autoNameSeries",autoNameSeries);
		
		if(folderId != null && !folderId.equals("") && !folderId.equals("null"))
			argsForJPO.put("folderId", folderId);
		else
			argsForJPO.put("folderId", "");

		String[] args =new String[2];
		args = JPO.packArgs(argsForJPO);

		try
		{
			//start the transaction
			context.start(true);
			
			Hashtable templateObjIDDesignObjIDMap = null;

			//invoke the JPO now to create startdesign objects
			templateObjIDDesignObjIDMap = (Hashtable)JPO.invoke(context, "IEFStartDesignCreateStructure", null, "createStructure", args, Hashtable.class);

			if(templateObjIDDesignObjIDMap != null & templateObjIDDesignObjIDMap.size() > 0)
			{	
				String operationStatus = (String)templateObjIDDesignObjIDMap.get("OPERATION_STATUS");
				if(operationStatus.equals("false"))
				{
					String errMessage = (String)templateObjIDDesignObjIDMap.get("ERROR_MESSAGE");
					MCADServerException.createException(errMessage,null);
				}
				
				String attrTitle = "";
				if(util.isAEFInstalled(context))
				{
					attrTitle = util.getActualNameForAEFData(context,"attribute_Title");
				}

				//Reached here means operation status is true, so remove this element from the table
				templateObjIDDesignObjIDMap.remove("OPERATION_STATUS");

				String workingDir	= integSessionData.getUserWorkingDirectory().getName();
				
				Enumeration templateObjIDs = templateObjIDDesignObjIDMap.keys();
				while(templateObjIDs.hasMoreElements())
				{
					String templateObjID	= (String)templateObjIDs.nextElement();
					String designObjDetails = (String)templateObjIDDesignObjIDMap.get(templateObjID);
					
					String designObjID		= "";
					String designObjName	= "";
					String designObjCADType ="";

					StringTokenizer tokens = new StringTokenizer(designObjDetails, "|");
					if(tokens.hasMoreTokens())
					{
						designObjID = tokens.nextToken();
					}
					if(tokens.hasMoreTokens())
					{
						designObjName = tokens.nextToken();
					}
					if(tokens.hasMoreTokens())
					{
						designObjCADType = tokens.nextToken();
					}
					
					if(templateObjID.equals(selectedTemplateObjID))
					{
						rootDesignObjectID = designObjID;
					}
					
					BusinessObject templateObj				= new BusinessObject(templateObjID);
					BusinessObject designObj				= new BusinessObject(designObjID);
					BusinessObject templateActiveMinorObj	= null;
					
					BusinessObject majorDesignObj = util.getMajorObject(context, designObj);
					
					majorDesignObj.open(context);

					String majorPolicyName = majorDesignObj.getPolicy(context).getName();

					majorDesignObj.close(context);
					
					templateObj.open(context);
					
					//get the mapped format for the template Type from GCO	
					mappedFormat = globalConfigObject.getFormatsForType(templateObj.getTypeName(), designObjCADType);
					
					//Copy files from template Object to minor Object
					FormatList formatList = templateObj.getFormats(context);
					if (formatList != null || formatList.size() > 0)
					{	
						designObj.open(context);

						FormatItr formatItr = new FormatItr(formatList);
						while(formatItr.next())
						{
							String format = formatItr.obj().getName();

							if(!format.equals(mappedFormat))
							{
								continue;
							}

							//need to set the Title attribute with value as the file names
							String titleValue		= "";
							FileList fileList		= templateObj.getFiles(context, format);
							boolean isFileFromMajor = true;
							if (fileList.size() == 0)
							{
								templateActiveMinorObj = util.getActiveMinor(context,templateObj);
								if(templateActiveMinorObj != null)
								{
									templateActiveMinorObj.open(context);
									fileList		= templateActiveMinorObj.getFiles(context, mappedFormat);
									isFileFromMajor = false;
								}
								if(fileList.size() == 0)
								{
									String error = integSessionData.getStringResource("mcadIntegration.Server.Message.NoFileInTemplateObject");
									MCADServerException.createException(error,null);
								}
							}

							FileItr  fileItr  = new FileItr(fileList);
							while (fileItr.next())
							{
								String fileName	 = fileItr.obj().getName();
								String newFileName = "";

								//Checkout file from template object
								if(isFileFromMajor)
									templateObj.checkoutFile(context,false, format, fileName, workingDir);
								else if(templateActiveMinorObj != null)
								{
									templateActiveMinorObj.checkoutFile(context,false, format, fileName, workingDir);
									templateActiveMinorObj.close(context);
								}

								java.io.File originalFile = new java.io.File(workingDir + java.io.File.separator + fileName);
																	
								if(globalConfigObject.isFileRenameOnServerSide())
								{
									String actualFileExtn  = fileName.substring(fileName.lastIndexOf('.'));
									newFileName = designObjName + actualFileExtn;
									
                                                                        if(globalConfigObject.getNonSupportedCharacters() != null && !globalConfigObject.getNonSupportedCharacters().equals(""))
                                                                        {
									      boolean isValidFileName = MCADNameValidationUtil.isValidNameForEntityType(newFileName, MCADAppletServletProtocol.ENTITY_FILE_NAME, globalConfigObject);
									      if(!isValidFileName)
									      {
										String fieldNameDisplay   = integSessionData.getStringResource("mcadIntegration.Server.FieldName.Name");

										Hashtable messageTable = new Hashtable(1, 1);
										messageTable.put("NAME", newFileName);
										messageTable.put("FIELDNAME", fieldNameDisplay);


										String errMsg    =  integSessionData.getStringResource("mcadIntegration.Server.Message.IEF0002300347", messageTable);
										MCADServerException.createManagedException("IEF0002300347", errMsg, null);
									      }
                                                                        }

								}
								else
								{
									newFileName = fileName;
								}

								if(integrationName.equalsIgnoreCase("MxPRO"))
								{
									int lastIndex = newFileName.lastIndexOf('.');

									if(lastIndex > 0)
									{
										String tempStr = newFileName.substring(lastIndex +1, newFileName.length());

										try
										{
											int tempInt = Integer.parseInt(tempStr); 
											newFileName = newFileName.substring(0, lastIndex);
										}
										catch(NumberFormatException ex )
										{
										}
									}
								}

                                java.io.File renamedFile	= new java.io.File(workingDir + java.io.File.separator + newFileName);
								originalFile.renameTo(renamedFile);

								util.checkinFile(context,designObj,workingDir, newFileName, format, null , majorPolicyName, cadType, integrationName, integSessionData);
								//delete the renamed file
								renamedFile.delete();

								if(!"".equals(titleValue))
								{
									titleValue += ";";
								}
								titleValue += newFileName;
							}

							if(util.isAEFInstalled(context))
							{
								//set the Title attribute here
								util.setAttributeOnBusObject(context, designObj, attrTitle, titleValue);
								util.setAttributeOnBusObject(context, majorDesignObj, attrTitle, designObj.getName());
							}

						}//format itr loop

						designObj.close(context);
					}
					templateObj.close(context);				
				}

	

				if(globalConfigObject.isEBOMSynchOnDesignCreation())
				{
					Hashtable JPOArgsTable = new Hashtable();

					JPOArgsTable.put(MCADServerSettings.GCO_OBJECT, globalConfigObject);            
					JPOArgsTable.put(MCADServerSettings.LANGUAGE_NAME, integSessionData.getLanguageName());
					JPOArgsTable.put(MCADServerSettings.OBJECT_ID, rootDesignObjectID);
					JPOArgsTable.put(MCADServerSettings.OPERATION_UID, _operationUID);

					

					String [] packedArgumentsTable = JPO.packArgs(JPOArgsTable);
					String jpoName   = globalConfigObject.getFeatureJPO(_commandName);
					String jpoMethod = "execute";
					String[] init = new String[] {};

					templateObjIDDesignObjIDMap = (Hashtable)JPO.invoke(context, jpoName, init ,jpoMethod, packedArgumentsTable, Hashtable.class);

				}
				
			}
			if(templateObjIDDesignObjIDMap != null & templateObjIDDesignObjIDMap.size() > 0)
			{
				String operationStatus = (String)templateObjIDDesignObjIDMap.get(MCADServerSettings.JPO_EXECUTION_STATUS);				
				if(operationStatus != null && operationStatus.equals("false"))
				{
					String errMessage = (String)templateObjIDDesignObjIDMap.get(MCADServerSettings.JPO_STATUS_MESSAGE);					
					MCADServerException.createException(errMessage,null);
				}
			}
			isOperationSuccessful = "true";
			//Commit the transaction
			util.commitTransaction(context);
		}
		catch(Exception e)
		{
			errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.StartPartCreationError") + e.getMessage().trim();
			
			isOperationSuccessful = "false";
			//Some problem has occured. Abort the transaction.
			try
			{
				if(context.isTransactionActive())
				context.abort();
			}
			catch(Exception ex)
			{
				System.out.println("Error in Aborting Transaction :" + ex.getMessage());	
			}
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
	}	
%>

<html>
<body>
<form name="connectionForm" action="../iefdesigncenter/DSCPSEEditActionsPostProcessing.jsp" method="post">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

   <input type="hidden" name="objectId" value="">
   <input type="hidden" name="childObjectId" value="">
   <input type="hidden" name="editAction" value="">
</form>

<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="javascript">

//XSSOK
var isOperationSuccessful = "<%= isOperationSuccessful %>";
var isCheckoutRequired = "<%= XSSUtil.encodeForJavaScript(context,isCheckoutRequired) %>";
var parentObjectId = "<%= XSSUtil.encodeForJavaScript(context,parentObjectId) %>";
var folderId = "<%=XSSUtil.encodeForJavaScript(context,folderId)%>";

if(isOperationSuccessful == "false")
{
        //XSSOK
	var errMessage = "<%= errorMessage %>";
	
	//stop the progress clock
	parent.stopProgressClock();

	alert(errMessage);
}
else if((isOperationSuccessful == "true"))
{
	if(isCheckoutRequired!=null && isCheckoutRequired == "FALSE")
	{		
		if(parentObjectId != null && parentObjectId != "" && parentObjectId != "none")
		{		//XSSOK	
			var childObjectId = "<%= rootDesignObjectID %>";			
			var connectionForm = document.connectionForm;			
			connectionForm.objectId.value = parentObjectId;
			connectionForm.childObjectId.value = childObjectId;
			connectionForm.editAction.value = "Add New";
			connectionForm.submit();
		}
		else
		{	
			if(folderId != null && folderId != "" && folderId != "none")
			{
				var integFrame				= getIntegrationFrame(this);			
				var contentFrame			= integFrame.getActiveRefreshFrame();

				if(null != contentFrame && !contentFrame.closed)
				{
					contentFrame.location.href  = contentFrame.location.href;
				}
			}
			window.top.close();
		}			
	}
	else 
	{	
		parent.cancelOperation = false;

		parent.createCheckoutPage('<%= XSSUtil.encodeForJavaScript(context,integrationName) %>', '<%=XSSUtil.encodeForJavaScript(context,rootDesignObjectID)  %>');
		
		//stop the progress clock
		parent.stopProgressClock();
	}	
}
</script>
</body>
</html>

<%--  IEFCreateDesignTemplateObject.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%!
	private String autoName(Context context, MCADMxUtil util, String name, String autoNameSeries, String policy, String vault, String customRevision) throws MCADException
    {
        String autoName = "";

        try
        {
			 
			 String Args[] = new String[7];
				Args[0] = "eServicecommonNumberGenerator.tcl";
				Args[1] = name;
				Args[2] = autoNameSeries;
				Args[3] = policy;
				Args[4] = "Null";
				Args[5] = vault;
				Args[6] = customRevision; 
            String result = util.executeMQL(context, "execute program  $1 $2 $3 $4 $5 $6 $7", Args);

			if(result.startsWith("true|"))
            {
                result = result.substring(5);
            }
            else
            {
                MCADServerException.createException(result.substring(6),null);
            }
            if(result.length() == 0)
            {
                throw new MatrixException("No results returned");
            }

            StringTokenizer tokens = new StringTokenizer(result, "|");

            String exitCode = tokens.nextToken().trim();
            if(exitCode.equals("1"))
            {
                throw new MatrixException("Error creating object of type " + name + "\n" + tokens.nextToken().trim());
            }

			tokens.nextToken().trim();
			tokens.nextToken().trim();

			name = tokens.nextToken().trim();
        }
        catch(MatrixException matrixexception)
        {
           MCADServerException.createException(matrixexception.getMessage(),matrixexception);
        }

        return name;
    }

	private void setAttributes(BusinessObject templateObject, HashMap attrNameValMap, Context context, MCADMxUtil util, String integrationName) throws MCADException
    {
		try
		{
			AttributeList attributeList = new AttributeList();

			if(attrNameValMap != null && attrNameValMap.size() > 0 )
			{
				Iterator itr = attrNameValMap.keySet().iterator();
				while(itr.hasNext())
				{
					String attrName  = (String)itr.next();
					String attrValue = (String)attrNameValMap.get(attrName);

					if(attrName.equals("Description") )
					{
						//Description is a system attribute so handle it separately
						templateObject.setDescription(context, attrValue);
						templateObject.update(context);
					}
					else
					{
						Attribute attribute = new Attribute(new AttributeType(attrName), attrValue);
						attributeList.addElement(attribute);
					}
				}
			}

			String sourceAttrName  = util.getActualNameForAEFData(context,"attribute_Source");
			String sourceAttrValue = integrationName + "|";
			Attribute sourceAttribute = new Attribute(new AttributeType(sourceAttrName), sourceAttrValue);
			attributeList.addElement(sourceAttribute);

			//set the attributes on the object
			templateObject.setAttributes(context, attributeList);
		}
		catch(Exception e)
		{
			MCADServerException.createException(e.getMessage(),e);
		}
    }
%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	//ENOCsrfGuard.validateRequest(context, session, request, response);
	String isOperationSuccessful = "";
    String errorMessage			 = "";
	String integrationName       = emxGetParameter(request, "integrationName");

	if(integrationName != null && !integrationName.equals("") && !integrationName.equals("null"))
	{
		MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
		MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		MCADServerGeneralUtil mcadServerGeneral		= new MCADServerGeneralUtil(context, integSessionData, integrationName );
		MCADFolderUtil _folderUtil					= new MCADFolderUtil(context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		String startDesignSiteNameAttribute			= util.getActualNameForAEFData(context, "attribute_IEF-StartDesignTemplateSites");

		String cadType			= emxGetParameter(request, "cadType");
		String type				= emxGetParameter(request, "TypeList");
		String policy			= emxGetParameter(request, "PolicyList");
		String vault			= emxGetParameter(request, "VaultList");
		String name				= emxGetParameter(request, "Name");
		String instanceName		= emxGetParameter(request, "InstanceName");
		String title				= emxGetParameter(request, "Title");
		String autoNameCheckbox	= emxGetParameter(request, "AutoName");
		String instanceAutoName	= emxGetParameter(request, "InstanceAutoName");
		String autoNameSeries	= emxGetParameter(request, "AutoNameList");
		String description		= emxGetParameter(request, "Description").trim();
		String revision			= emxGetParameter(request, "Revision").trim();
		String templateFileWithPath		= emxGetParameter(request, "templateFileWithPath");

	    String folderId			= emxGetParameter(request, "folderId");
		String applyToChild		= emxGetParameter(request,"applyToChild");

		BusinessObject bus	= new BusinessObject(type, name, revision, vault);
		String templateType	= bus.getTypeName();
		String cadTypeName	= globalConfigObject.getCADTypeForTemplateType(templateType);
		String formatName	= mcadServerGeneral.getFormatsForType(context, templateType , cadTypeName);
		String storeName = "";

		java.io.File templateFile = new java.io.File(templateFileWithPath);
    	String templateFileName = templateFile.getName();

		Map map = (Map) session.getAttribute("attributeMap");

		HashMap attrNameValMap = new HashMap();

		String[] sites			= emxGetParameterValues(request, "Sites");

		String siteNameFinalValue = "";
		StringBuffer siteNameValue = new StringBuffer();
		if(sites != null)
		{
			for (int i = 0; i < sites.length ; i++)
			{
				String siteName = sites[i];
				if(siteName != null && !"".equals(siteName) && !"null".equalsIgnoreCase(siteName))
				{
					siteNameValue.append(siteName);
					siteNameValue.append(",");
				}
			}
					String siteNameValueString = siteNameValue.toString();
			if(siteNameValueString != null && !"".equals(siteNameValueString) && siteNameValueString.indexOf(",") >= 0)
			{
					int lastIndexOfSites = siteNameValueString.lastIndexOf(',');
					siteNameFinalValue = siteNameValueString.substring(0,lastIndexOfSites);
			}
					attrNameValMap.put(startDesignSiteNameAttribute, siteNameFinalValue);
				}

		java.util.Set keys = map.keySet();
		Iterator itr = keys.iterator();
		while(itr.hasNext())
		{
			Map valueMap = (Map)map.get((String)itr.next());

			String attrName  = (String)valueMap.get("name");
			String attrValue = "";
	    	 attrValue = emxGetParameter(request, attrName);

			if((attrValue != null) && !(attrValue.equalsIgnoreCase("null")) && !(attrValue.equals("")))
			{
				attrNameValMap.put(attrName, attrValue);
			}
		}

		attrNameValMap.put("Description", description);

		try
		{
			//start the transaction
			context.start(true);

			String baseType             = util.getBaseType(context, type);
			String symbolicBaseTypeName = util.getSymbolicName(context, "type", baseType);
			String symbolicPolicyName   = util.getSymbolicName(context, "policy", policy);

			if(autoNameCheckbox != null && autoNameCheckbox.equalsIgnoreCase("on"))
			{
				name = autoName(context, util, symbolicBaseTypeName, autoNameSeries, symbolicPolicyName, vault, revision);
			}

			MQLCommand command = new MQLCommand();
            boolean result = command.executeCommand(context,"temp query bus $1 $2 $3 select $4 dump $5",type,name,"*","name","|");
			String comResult = command.getResult();

			command = new MQLCommand();
			StringBuffer checkinQuery = new StringBuffer();
			if( comResult !=null  && comResult.equals(""))
			{
				if(title == null || title.equals(""))
				{
					   String titleAttrValue  = name;
					   if(globalConfigObject != null && globalConfigObject.isObjectAndFileNameDifferent())
					   {
							titleAttrValue  = templateFileName;
					   }
					  
						result = command.executeCommand(context, "add bus $1 $2 $3 policy $4 vault $5 $6 $7",type,name,revision,policy,vault,"Title",titleAttrValue);
				}
				else
				{
				        result = command.executeCommand(context, "add bus $1 $2 $3 policy $4 vault $5",type,name,revision,policy,vault);
				}

				if(result)
				{
					isOperationSuccessful = "true";
				}
				else
				{
						errorMessage = command.getError();
						isOperationSuccessful = "false";
				}


				storeName = util.getObjectStoreForFile(context, type, name, revision, formatName, templateFileName);

			%>

			
			<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
			<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

            <script language = "Javascript">
//XSSOK  
			if("<%=isOperationSuccessful%>" == "true")
			{

				var templateFileWithPath = parent.contentFrame.document.createForm.templateFileWithPath.value;

				var integrationName = '<%=XSSUtil.encodeForJavaScript(context,integrationName)%>';
               //XSSOK
				var templateFileCheckinDetails = templateFileWithPath+"|"+"<%=type%>"+"|"+"<%=name%>"+"|"+"<%=revision%>"+"|"+"<%=formatName%>"+"|"+"<%=storeName%>"+"|"+"<%=policy%>";

				var integrationFrame = getIntegrationFrame(this);
				var response = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "handleFileCheckinCommand", templateFileCheckinDetails);
			}

			</script>

			<%
			}
			else
			{
				errorMessage = "' " + type + " '  ' " + name + " ' " + UINavigatorUtil.getI18nString("emxIEFDesignCenter.Common.NotAUniqueName","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"));
				isOperationSuccessful = "false";
			}

			boolean isFamilyLike = globalConfigObject.isTypeOfClass(cadType,MCADAppletServletProtocol.TYPE_FAMILY_LIKE);
		
			//if family template, needs to create instance
			if(isOperationSuccessful.equalsIgnoreCase("true") && isFamilyLike)
			{
				BusinessObject templateFamilyObject = new BusinessObject(type, name, revision, vault);		
				String instanceNameAfterAutoName = "";
				
				if((instanceAutoName != null && instanceAutoName.equalsIgnoreCase("on"))|| (instanceAutoName != null && globalConfigObject.isObjectAndFileNameDifferent())||(instanceAutoName != null && !globalConfigObject.isObjectAndFileNameDifferent() && !globalConfigObject.isUniqueInstanceNameInDBOn()))
				{
					instanceNameAfterAutoName = autoName(context, util, symbolicBaseTypeName, autoNameSeries, symbolicPolicyName, vault, revision);
				}
				mcadServerGeneral.createInstanceTemplateForFamily(context, templateFamilyObject, instanceNameAfterAutoName,instanceName, policy, vault, cadType, globalConfigObject,integrationName);				
			}
			if(isOperationSuccessful.equalsIgnoreCase("true"))
			{
				BusinessObject templateObject = new BusinessObject(type, name, revision, vault);

				//Transfer the attributes to the template object
				setAttributes(templateObject, attrNameValMap, context, util, integrationName);

				if(folderId != null && !"".equals(folderId))
				{
					boolean hasAssignedFolders = _folderUtil.hasAssignedFolders(context, folderId , type, name, revision);

					if(!hasAssignedFolders)
					{
						_folderUtil.assignToFolder(context, templateObject, folderId, applyToChild);
					}
				}
				//Commit the transaction
				util.commitTransaction(context);
			}
		}
		catch(MatrixException me)
		{
			errorMessage = me.getMessage().trim();
			isOperationSuccessful = "false";

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
		catch(MCADException e)
		{
			errorMessage = e.getMessage().trim();
			isOperationSuccessful = "false";

			try
			{
				context.abort();
			}
			catch(Exception ex)
			{
				System.out.println("Error in Aborting Transaction :" + ex.getMessage());
			}
		}

		if(!errorMessage.equals(""))
		{
			String errMsg = "";

			StringTokenizer tokens = new StringTokenizer(errorMessage, "\n");
			while(tokens.hasMoreTokens())
			{
				errMsg += tokens.nextToken() + "\\n";
			}

			errorMessage = errMsg;
		}
	}
	if(isOperationSuccessful == "true")
	{
		ENOCsrfGuard.validateRequest(context, session, request, response);
	}
%>
		
<html>
<body>
<script language="javascript">

var isOperationSuccessful = "<%=XSSUtil.encodeForJavaScript(context,isOperationSuccessful)  %>";

if(isOperationSuccessful == "true")
{
	parent.opener.parent.reloadTabData();
	parent.cancel();
}
else if(isOperationSuccessful == "false")
{
	var errMessage = "<%= XSSUtil.encodeForJavaScript(context,errorMessage) %>";
	alert(errMessage);
}
</script>
</body>
</html>

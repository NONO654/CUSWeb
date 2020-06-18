<%--  IEFMultiplePurge.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file ="MCADTopErrorInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>
	<script src="scripts/IEFUIModal.js"      type="text/javascript"></script>
	<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
	<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</head>

<body>
<%
	String featureName		= MCADGlobalConfigObject.FEATURE_PURGE;
	String isFeatureAllowed = "";
	String integrationName	= emxGetParameter(request,"integrationName");
	String errMsg			= "";

	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	MCADIntegrationSessionData integSessionData	  = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	Context context								  = integSessionData.getClonedContext(session);
	ENOCsrfGuard.validateRequest(context, session, request, response);	
	MCADMxUtil util								  = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(),integSessionData.getGlobalCache());

	boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);
	
    String[] objectId = emxGetParameterValues(request,"objectId");
    
    String busId = "";
    if(objectId != null  && objectId.length >0)
    {
        busId = objectId[0]; 
        integrationName = util.getIntegrationName(context, busId);
    } 
    else
    {
        throw new Exception(integSessionData.getStringResource("mcadIntegration.Server.Message.PurgeFailedObjectIdNull"));
    }

	MCADServerGeneralUtil generalUtil			  = new MCADServerGeneralUtil(context,integSessionData, integrationName);
	MCADGlobalConfigObject  globalConfigObject	  = null;

	isFeatureAllowed							  = integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
	if(!isFeatureAllowed.startsWith("true"))
	{
		errMsg = isFeatureAllowed.substring(isFeatureAllowed.indexOf("|")+1, isFeatureAllowed.length());
	}
	else
		globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);


	// get the list of Ids seleccted for deletion
   
	String majorBusId = "";
	String selectedObjs = "";

	BusinessObject finalizedMinorBO = null;

	String[] selectedIds = emxGetParameterValues(request,"emxTableRowId");

	if(selectedIds == null || selectedIds.length == 0)
	{
		errMsg =  integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectIsNotSelected");
	}

	BusinessObject majorBO = new BusinessObject(busId);
	majorBO.open(context);
	if(globalConfigObject != null && !util.isMajorObject(context, busId))//!globalConfigObject.isMajorType(majorBO.getTypeName())) //[NDM] OP6
	{
		majorBO = util.getMajorObject(context,majorBO);
		if(majorBO == null)
		{
			errMsg = integSessionData.getStringResource("mcadIntegration.Server.Message.CantPurgeNoMajorFound");
		}
	}

	if(majorBO.isOpen())
		majorBO.close(context);

	if(errMsg.equals(""))
	{
		majorBO.open(context);

		boolean bLocked = majorBO.isLocked(context);
		String type     = majorBO.getTypeName();
		String name     = majorBO.getName();
		String revision = majorBO.getRevision();
		majorBusId		= majorBO.getObjectId();
		majorBO.close(context);
		if(bLocked)
		{
				Hashtable msgTable = new Hashtable();
				msgTable.put("TYPE", type);
				msgTable.put("NAME", name);
				msgTable.put("REVISION", revision);
				errMsg = integSessionData.getStringResource("mcadIntegration.Server.Message.CanNotPurgeLockedObject", msgTable);
		}
		else
		{
			BusinessObject minorBO;
			for(int c=0;c<selectedIds.length;c++)
			{
				String minorBusId = selectedIds[c];
				selectedObjs = selectedObjs + "|" + minorBusId;
			}
		}
	}
%>

<%!
	public void addInstanceIDsToVerificationList(Context context, MCADServerGeneralUtil generalUtil, BusinessObject familyObj, Vector idList)
	{
		try
		{
			familyObj.open(context);
			idList.addElement(familyObj.getObjectId());

			Vector instanceList = generalUtil.getInstanceListForFamilyObject(context,familyObj.getObjectId());
			for(int i=0; i<instanceList.size(); i++)
			{
				BusinessObject instObj = (BusinessObject) instanceList.elementAt(i);
				instObj.open(context);
				idList.addElement(instObj.getObjectId());
				instObj.close(context);
			}
			familyObj.close(context);
		}
		catch(Exception e)
		{
		}
	}

	private String getLocalizedType(String NLtype,String acceptLanguage) throws MatrixException
	{
					String typeKey= NLtype.replace(" ","_");
					String i18nString = "emxFramework.Type."+typeKey;
					typeKey = FrameworkUtil.i18nStringNow(i18nString, acceptLanguage);
					return typeKey;
	}

	public String getParentObjectTableContent(HashMap minorObjectIDParentDataTable, Context context, MCADIntegrationSessionData integSessionData, String acceptLanguage)
	{
		String deselectSelectedObjVersions = integSessionData.getStringResource("mcadIntegration.Server.Message.DeselectSelectedObjectVersions");

		StringBuffer htmlContentBuffer = new StringBuffer("<tr><font size='+1'><b>" + deselectSelectedObjVersions + "</b></font></tr><br>");

		java.util.Set completeSet	= minorObjectIDParentDataTable.keySet();

		Iterator completeDataItr	= completeSet.iterator();
		while(completeDataItr.hasNext())
		{
			String minorObjId	    = (String)completeDataItr.next();
			MapList relObjTableList	= (MapList)minorObjectIDParentDataTable.get(minorObjId);

			String minorObjType     = "";
			String minorObjName     = "";
			String minorObjRev      = "";
			try
			{
				BusinessObject bus = new BusinessObject(minorObjId);
				bus.open(context);
				minorObjType = bus.getTypeName();
				minorObjName = bus.getName();
				minorObjRev  = bus.getRevision();
				bus.close(context);
				minorObjType = getLocalizedType(minorObjType,acceptLanguage);
			Hashtable msgTable = new Hashtable();
			msgTable.put("TYPE", minorObjType);
			msgTable.put("NAME", minorObjName);
			msgTable.put("REVISION", minorObjRev);
			String selectedDesignReference = integSessionData.getStringResource("mcadIntegration.Server.Message.DesignReferenceInPurge", msgTable);

			htmlContentBuffer.append("<tr><td valign='top'><b>" + selectedDesignReference + "</b></td></tr>");

			htmlContentBuffer.append("<tr><td valign='top'>");
			for(int i=0; i<relObjTableList.size(); i++)
			{
				HashMap relObjMap = (HashMap)relObjTableList.get(i);
				String typeRel     = (String)relObjMap.get(DomainObject.SELECT_TYPE);
				typeRel = getLocalizedType(typeRel,acceptLanguage);			
				String name     = (String)relObjMap.get(DomainObject.SELECT_NAME);
				String revision = (String)relObjMap.get(DomainObject.SELECT_REVISION);

				htmlContentBuffer.append(typeRel + " " + name + " " + revision + "<br>");
			}
		}
			catch(Throwable exception)
			{
				System.out.println("Error in opening business object in purge dialog. Error :" + exception.getMessage());
			}

			htmlContentBuffer.append("</td></tr>");
		}

		return htmlContentBuffer.toString();
	}
%>

<%
	HashMap completeRelationshipObjMap = null;
	if(integSessionData == null)
	{
        String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
		errMsg = errorMessage;
	}
	else
	{
		HashMap paramMap = new HashMap();

		paramMap.put("GCO", globalConfigObject);
		paramMap.put("instanceName", "");
		paramMap.put("languageStr",  acceptLanguage);

		Hashtable relClassMapTable = new Hashtable(globalConfigObject.getRelationshipsOfClass(MCADAppletServletProtocol.ASSEMBLY_LIKE));
		Hashtable externalReferenceLikeRelsAndEnds = globalConfigObject.getRelationshipsOfClass(MCADServerSettings.EXTERNAL_REFERENCE_LIKE);
		Enumeration externalReferenceRels = externalReferenceLikeRelsAndEnds.keys();
		while (externalReferenceRels.hasMoreElements())
		{
			String relName = (String) externalReferenceRels.nextElement();
		
			if(relClassMapTable.containsKey(relName))
				relClassMapTable.remove(relName);
		}

		Vector busIdsToTest = new Vector();
		String cadType = null;
		StringTokenizer selectedBusIdsTokens = new StringTokenizer(selectedObjs, "|");
		while(selectedBusIdsTokens.hasMoreTokens())
		{
			String selectedBusId = selectedBusIdsTokens.nextToken();

			if(cadType == null)
			{
				String cadTypeAttrName = util.getActualNameForAEFData(context,"attribute_CADType");
				cadType				   = util.getAttributeForBO(context, selectedBusId, cadTypeAttrName);
			}

			if(globalConfigObject.isTypeOfClass(cadType, MCADAppletServletProtocol.TYPE_INSTANCE_LIKE))
			{
				BusinessObject familyObj = generalUtil.getFamilyObjectForInstance(context, new BusinessObject(selectedBusId));
				addInstanceIDsToVerificationList(context, generalUtil, familyObj, busIdsToTest);
			}
			else if(globalConfigObject.isTypeOfClass(cadType, MCADAppletServletProtocol.TYPE_FAMILY_LIKE))
			{
				addInstanceIDsToVerificationList(context, generalUtil, new BusinessObject(selectedBusId), busIdsToTest);
			}
			else
			{
				busIdsToTest.addElement(selectedBusId);
			}
		}

		completeRelationshipObjMap = new HashMap();
		for(int i=0; i<busIdsToTest.size(); i++)
		{
			String selectedBusId = (String)busIdsToTest.elementAt(i);

			Enumeration assemblyLikeRels = relClassMapTable.keys();
			while (assemblyLikeRels.hasMoreElements())
			{
				String relName = (String) assemblyLikeRels.nextElement();
				String relEnd = (String) relClassMapTable.get(relName);
				
				if(relEnd.equalsIgnoreCase("from"))
					relEnd = "to";
				else
					relEnd = "from";
		
				paramMap.put("objectId",     selectedBusId);
				paramMap.put("relationship", relName);
				paramMap.put("end",          relEnd);

				try
				{
					String[] intArgs = new String[]{};

					//invoke the JPO now to get parent objects with SubComponent relationship.
					MapList relObjList = new MapList();
					relObjList = (MapList)JPO.invoke(context, "IEFObjectWhereUsed", intArgs, "getList", JPO.packArgs(paramMap), MapList.class);

					if(relObjList != null && relObjList.size() > 0)
					{
						completeRelationshipObjMap.put(selectedBusId, relObjList);
					}
				}

				catch(Exception e)
				{
					errMsg = e.getMessage();
				}
			}
		}
	}
%>


<form name="UpdatePage" action="MCADUpdateWithMessage.jsp" target="_top" method="post">

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
	<input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=majorBusId%></xss:encodeForHTMLAttribute>">
	<input type="hidden" name="refresh" value="true">
	<input type="hidden" name="details" value="">
	<input type="hidden" name="refreshmode" value="replace">
</form>

<%
	String url = "";
	if( (completeRelationshipObjMap.size() == 0) && (errMsg.length() == 0) )
	{
%>
<script language="JavaScript">
		var integrationFrame = getIntegrationFrame(this);

		var integrationName = "<%=XSSUtil.encodeForJavaScript(context,integrationName)%>";
		<!--XSSOK-->
		var unitSeparator	= "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
		//XSSOK
		var recordSeparator = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";

		var parametersArray = new Array;

		parametersArray["busId"]			= "<%=XSSUtil.encodeForJavaScript(context,busId)%>";
		parametersArray["Command"]			= "executeBrowserCommand";
		//XSSOK
		parametersArray["Action"]			= "<%=MCADGlobalConfigObject.FEATURE_PURGE%>";
		parametersArray["IntegrationName"]	= integrationName;
	
		parametersArray["busIdList"]		= "<%=XSSUtil.encodeForJavaScript(context,selectedObjs)%>";

		var queryString = getQueryString(parametersArray, unitSeparator, recordSeparator);

		if('<%=bEnableAppletFreeUI%>' == "true")
        	{
        	var purgeDetails = "busId="+"<%=XSSUtil.encodeForJavaScript(context,busId)%>" + "&Command=" + "executeBrowserCommand" + "&Action="+ "<%=MCADGlobalConfigObject.FEATURE_PURGE%>"+"&IntegrationName="+integrationName+"&busIdList="+"<%=XSSUtil.encodeForJavaScript(context,selectedObjs)%>";
    		var url = "../integrations/IEFMultiplePurgeAppletFreePost.jsp";
    		url += "?" + purgeDetails;
    		var http = emxUICore.createHttpRequest();
    	
    		http.onreadystatechange=function()
    		 {
    			if (http.readyState < 4)
    			 {
    			
    			}
    			if (http.readyState == 4) 
    			{   
    				var response1 = http.responseText;
    				alert(response1.trim());
    				parent.window.close();
    			}
    		}
    		http.open("POST", url, true);
    		http.send();
    		}
        else
		{
		var response = integrationFrame.getAppletObject().callCommandHandlerSynchronously(integrationName, "sendRequestToServerForBrowserCommands", queryString);

		response =  replaceAll(response, "\n", "<br>");
		var encodedString	= hexEncode(integrationName,response);

		document.UpdatePage.details.value=encodedString;
		document.UpdatePage.submit();
		}
</script>
<%
	}
	else
	{

		String messageContent = getParentObjectTableContent(completeRelationshipObjMap, context, integSessionData, acceptLanguage);

		if(messageContent == null || errMsg.length() > 0)
			messageContent = messageContent + errMsg;

		if(messageContent != null)
		{
			String messageHeader = integSessionData.getStringResource("mcadIntegration.Server.Title.Purge");
			session.setAttribute("mcadintegration.messageHeader", messageHeader);

			messageContent		 = MCADUrlUtil.hexEncode(messageContent);
			session.setAttribute("mcadintegration.message", messageContent);
			url= "./IEFPurgeConfirmationDialogFS.jsp?isContentHtml=true";
		}
%>
<script language="JavaScript">
		showIEFNonModalDialog("<%=XSSUtil.encodeForJavaScript(context,url)%>", 600, 450);
</script>
<%
	}
%>

</body>

<%@include file = "MCADBottomErrorInclude.inc"%>
</html>


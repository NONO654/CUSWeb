<%--  MCADVersionsDialog.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ page import="com.matrixone.MCADIntegration.server.beans.*,com.matrixone.apps.domain.util.*"%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file ="../iefdesigncenter/IEFTableInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
	String integrationName	= emxGetParameter(request, "integrationName");
	String cadType				= emxGetParameter(request, "cadType");
	String busName				= emxGetParameter(request, "busName");
	String dirName				= emxGetParameter(request, "mxDirName");
	String fileName				= emxGetParameter(request, "mxFileName");
	String instanceName			= emxGetParameter(request, "instanceName");
	String instanceCadType		= emxGetParameter(request, "instanceCadType");
	String autoRecognizedTNR	= emxGetParameter(request, "autoRecognizedTNR");
	String defaultApplication		= "";
	String majorRevision			= "";
	String objectId					= "";
	String errorMessage			= "";

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context									= integSessionData.getClonedContext(session);
	MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	IEFConfigUIUtil iefConfigUIUtil             = new IEFConfigUIUtil(context, integSessionData, integrationName);
	MCADGlobalConfigObject  globalConfigObject		= integSessionData.getGlobalConfigObject(integrationName,context);
    MCADServerGeneralUtil serverGeneralUtil			= new MCADServerGeneralUtil(context, globalConfigObject, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	MCADSessionData sessionData							= integSessionData.getSessionData();
    MCADSessionDataManager sessionDataManager		= new MCADSessionDataManager(context,integSessionData, integrationName);
	boolean isCreateVersionObjectsEnabled						= globalConfigObject.isCreateVersionObjectsEnabled();
	StringBuffer recognizedLatestTNR								= new StringBuffer();
    boolean      isRecognizedFromWorkingSet					= false;

	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.Versions");
	try
	{
		cadType			= MCADUrlUtil.hexDecode(cadType);
		busName			= MCADUrlUtil.hexDecode(busName);
		dirName			= MCADUrlUtil.hexDecode(dirName);
		fileName			= MCADUrlUtil.hexDecode(fileName);

		if(instanceName != null && !instanceName.equals("") && instanceCadType != null && !instanceCadType.equals(""))
		{
			instanceName		= MCADUrlUtil.hexDecode(instanceName);
			instanceCadType	= MCADUrlUtil.hexDecode(instanceCadType);
		}

		String actualName		= busName;
		String actualCadType	= cadType;
		if(instanceName != null && !instanceName.equals("") && instanceCadType != null && !instanceCadType.equals(""))
		{
			actualName		= serverGeneralUtil.getNameForInstance(busName, instanceName);
			actualCadType	= instanceCadType;
		}

        BusinessObject busObject = null;

        if(autoRecognizedTNR != null && !autoRecognizedTNR.trim().equals(""))
		{
			String autoRecognizedType			= null;
			String autoRecognizedName		= null;
			String autoRecognizedRevision	= null;

			StringTokenizer autoRecognizedTokens = new StringTokenizer(autoRecognizedTNR, "|");

			if(autoRecognizedTokens.hasMoreTokens())
				autoRecognizedType = autoRecognizedTokens.nextToken();
			if(autoRecognizedTokens.hasMoreTokens())
				autoRecognizedName = autoRecognizedTokens.nextToken();
			if(autoRecognizedTokens.hasMoreTokens())
				autoRecognizedRevision = autoRecognizedTokens.nextToken();

			if(autoRecognizedType != null && autoRecognizedName != null && autoRecognizedRevision != null)
			{
				if(instanceName != null && !instanceName.equals("") && instanceCadType != null && !instanceCadType.equals(""))
					autoRecognizedName = serverGeneralUtil.getNameForInstance(busName, autoRecognizedName);

				busObject = new BusinessObject(autoRecognizedType, autoRecognizedName, autoRecognizedRevision, "");

				if(!util.doesBusinessObjectExist(context,autoRecognizedType,autoRecognizedName,autoRecognizedRevision))
				{
					MCADServerException.createException(integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectNewOrDoesNotExist"),null);
				}

				busObject.open(context);
				String type		= busObject.getTypeName();
				objectId		= busObject.getObjectId();

				if(!util.isMajorObject(context, objectId))//!globalConfigObject.isMajorType(type)) // [NDM] OP6
				{
					busObject = util.getMajorObject(context,busObject);
					if(busObject == null)
					{
						String activeMajor	= util.getActiveVersionObjectFromMinor(context,objectId);
						busObject				=  new BusinessObject(activeMajor);
						objectId					= busObject.getObjectId();
					}
				}
				busObject.close(context);
			}
		}
        if(busObject == null)
		{
			busObject = sessionDataManager.identifyBusinessObjectWithName(context, actualCadType, actualName, dirName, fileName, sessionData, true);
            if(busObject != null)
				isRecognizedFromWorkingSet = true;
        }

		if(busObject == null)
		{
            // Due to last minute change for V6R2010, new MCADServerGeneralUtil instance is created with different constructor to minimise impact. Should change the instance created at the top of the file to use this contructor in later release.
            MCADServerGeneralUtil serverGenUtil		= new MCADServerGeneralUtil(context, integSessionData, integrationName);
			String recognizedLatestRevisionBusId					 = serverGenUtil.getRecognizedLatestRevisionBusId(context, actualCadType, actualName);
			if(recognizedLatestRevisionBusId != null && !recognizedLatestRevisionBusId.equals(""))
			{
				 busObject = new BusinessObject(recognizedLatestRevisionBusId);
				 busObject.open(context);
				 String recognizedType				= busObject.getTypeName();
				 String recognizedLatestRevision = busObject.getRevision();
				 busObject.close(context);
				 if(recognizedType != null && !recognizedType.equals("") && actualName != null && !actualName.equals("") && recognizedLatestRevision != null && !recognizedLatestRevision.equals(""))
				 {
						recognizedLatestTNR.append(recognizedType);
						recognizedLatestTNR.append("|");
						recognizedLatestTNR.append(actualName);
						recognizedLatestTNR.append("|");
						recognizedLatestTNR.append(recognizedLatestRevision);
				}
			}
		}

		if(busObject == null)
		{
			MCADServerException.createException(integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectCanNotBeRecognized"),null);
		}
		try
		{
			busObject.open(context);
		}
		catch(Exception Ex)
		{
			MCADServerException.createException(integSessionData.getStringResource("mcadIntegration.Server.Message.BusinessObjectNotFound"),null);
		}

		String type			= busObject.getTypeName();
		String name		= busObject.getName();
		String revision	= busObject.getRevision();
		objectId				= busObject.getObjectId();

		BusinessObjectList businessObjectList = new BusinessObjectList();
		if(util.isMajorObject(context, objectId))//globalConfigObject.isMajorType(type)) // [NDM] OP6
		{
			majorRevision		= revision;
			businessObjectList	= util.getRevisionBOsOfAllStreams(context, busObject, false);
		}
		else
		{
			majorRevision		= util.getRevisionStringForMinorRev(revision);
			businessObjectList	= util.getRevisionBOsOfAllStreams(context, busObject, true);
		}

        MapList busObjectsMapList			 = new MapList();
		BusinessObjectItr businessObjectItr = new BusinessObjectItr(businessObjectList);
		for(int i=0; businessObjectItr.next(); i++)
		{
			BusinessObject currentBusObject			= businessObjectItr.obj();
			BusinessObject currentMajorBusObject	= null;

			currentBusObject.open(context);
			String currentObjectType = currentBusObject.getTypeName();
			
			//[NDM] OP6
			if(util.isMajorObject(context, currentBusObject.getObjectId()))//globalConfigObject.isMajorType(currentObjectType))
			{
				currentMajorBusObject = currentBusObject;

				if(isCreateVersionObjectsEnabled)
				{
					boolean isFinalized = serverGeneralUtil.isBusObjectFinalized(context,currentBusObject);

					//if object is of major type and is not finalized, don't show it
					if(!isFinalized)
						continue;
				}
			}
			else
			{
				currentMajorBusObject = util.getMajorObject(context,currentBusObject);
				if(isCreateVersionObjectsEnabled)
				{
					if(currentMajorBusObject == null)
						continue;
				}
				else
					continue;
			}

			currentMajorBusObject.open(context);
			String objectLocker					= currentMajorBusObject.getLocker(context).getName();
			String currentMajorObjectRevision	= currentMajorBusObject.getRevision();
			currentMajorBusObject.close(context);

			String currentObjectID = currentBusObject.getObjectId();

			HashMap busObjectHashMap = new HashMap();
			busObjectHashMap.put("id", currentObjectID);

			busObjectsMapList.add(busObjectHashMap);
		}

		//Put data in session alongwith timestamp

		String timeStamp = Long.toString(System.currentTimeMillis());

		session.setAttribute("CurrentIndex" + timeStamp, new Integer(0));
		session.setAttribute("BusObjList" + timeStamp, busObjectsMapList);
	}
	catch(Exception e)
	{
		errorMessage =  e.getMessage();
	}


	String funcPageName = MCADGlobalConfigObject.PAGE_VERSIONS_CLIENTSIDE;
	//Get the roles from property file
    String mcadRoleList = integSessionData.getPropertyValue("mcadIntegration.MCADRoles");

	String defaultTable       = iefConfigUIUtil.getDefaultCustomTableName(integrationName, MCADGlobalConfigObject.PAGE_VERSIONS_CLIENTSIDE, integSessionData);

	String versionDialogTitle = null;
	if(globalConfigObject.isCreateVersionObjectsEnabled())
	    versionDialogTitle = "mcadIntegration.Server.Title.Versions";
	else
	    versionDialogTitle = "mcadIntegration.Server.Title.Revisions";

    //Specify URL to come in middle of frameset
    String contentURL = "MCADVersionsContent.jsp";

    //Add Parameters Below
    String queryString = request.getQueryString();
	if((null == autoRecognizedTNR || autoRecognizedTNR.equals("")) && !isRecognizedFromWorkingSet  && recognizedLatestTNR.length()>0)
            queryString += "&recognizedLatestTNR=" + recognizedLatestTNR.toString();

    if (queryString != null && !queryString.equals("") && !queryString.equals("null"))
		contentURL += "?" + queryString;

	String absoluteContentURL = "/integrations/" + contentURL;

	String encodedContentURL  = MCADUrlUtil.hexEncode(absoluteContentURL);

	String timeStamp = Long.toString(System.currentTimeMillis());

	String tableFooterURL  = "../integrations/MCADGenericFooterPage.jsp?buttonName=Close";

	String encodedTableFooterURL = MCADUrlUtil.hexEncode(tableFooterURL);
%>

<html>

<head>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">

var framepageheader = null;
var framelistDisplay = null;
var framefooterFrame = null;

function loadFrames()
{
	framepageheader = findFrame(this,"pageheader");
	framelistDisplay = findFrame(this,"listDisplay");
	framefooterFrame = findFrame(this,"footerFrame");
    //XSSOK
	updateFrames(framelistDisplay, framepageheader, framefooterFrame,"<%= versionDialogTitle %>","<%= encodedContentURL %>","<%= encodedTableFooterURL %>","<%= timeStamp %>", "<%= defaultTable %>", true, "<%= funcPageName %>", '<%=objectId%>','<%=integrationName%>',null,"false","false");
}

function selectAllNodes()
{
	var objectIDList = framelistDisplay.document.forms["tableForm"].selectAllCheckbox;

	var fieldList = framelistDisplay.document.forms["tableForm"].list;
	var isChecked = framelistDisplay.document.forms["tableForm"].selectAllCheckbox.checked ;
	if(fieldList.length > 1)
	{
		for (i = 0; i < fieldList.length; i++)
		{
			fieldList[i].checked = isChecked;
		}
	}
	else
	{
		fieldList.checked = isChecked;
	}
}
function changeNodeSelection()
{
	var fieldList			= framelistDisplay.document.forms["tableForm"].list;
	var checkedListCount	= 0;

	if(fieldList.length > 1)
	{
		for (i = 0; i < fieldList.length; i++)
		{
			if(fieldList[i].checked)
			{
				checkedListCount++;
			}
		}
	}
	else
	{
		checkedListCount++;
	}
	var isChecked = framelistDisplay.document.forms["tableForm"].selectAllCheckbox.checked ;
	if(fieldList.length == checkedListCount)
	{
		framelistDisplay.document.forms["tableForm"].selectAllCheckbox.checked	= true;
	}
	else
	{
		framelistDisplay.document.forms["tableForm"].selectAllCheckbox.checked	= false;
	}
}

</script>

</head>
<!--XSSOK-->
<title><%=operationTitle%></title>
<%
   if(errorMessage.equals(""))
	{
%>
     <!--XSSOK-->
	<frameset name="baseFrame" rows="100,*,65,0" frameborder="no" onunload="sessionCleanup('<%=timeStamp%>','<%=funcPageName%>')" onload="javascript:loadFrames()">

   	<frame name="pageheader" noresize scrolling="NO" />
	<frame name="listDisplay"/>
	<frame name="footerFrame" noresize scrolling="NO"/>
	<frame name="listHidden" src="emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" border="0" scrolling="no"  />
	</frameset>
<%
    }
	else
	{
		String messsagePageHeader	= integSessionData.getStringResource("mcadIntegration.Server.Heading.Error");
				errorMessage		= MCADUrlUtil.hexEncode(errorMessage);
				messsagePageHeader	= MCADUrlUtil.hexEncode(messsagePageHeader);
%>
<body>
	<form name="errorForm" action="./MCADMessageFS.jsp" method="post" target="_top">

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


		<input type="hidden" name="messageHeader" value="">
		<input type="hidden" name="message" value="">
	 </form>
</body>
<script>
    //XSSOK
	document.forms['errorForm'].messageHeader.value	= "<%= messsagePageHeader %>";
//XSSOK
    document.forms['errorForm'].message.value				= "<%= errorMessage %>";
    document.forms['errorForm'].submit();
</script>
<%
	}
%>

</html>


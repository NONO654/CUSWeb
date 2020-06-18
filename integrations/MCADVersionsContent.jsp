<%--  MCADVersionsContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--    Shows the server preferences for MCAD Integrations.

--%>
<%@ page import="com.matrixone.MCADIntegration.utils.*" %>
<%@ include file ="MCADTopInclude.inc" %>
<%@include file = "MCADTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>



<%!
	// Get object details page to show object details page based on the application being used.
	public String getObjectDetailsPageName(MCADIntegrationSessionData integSessionData)
	{
		String objectDetailsPageName = "../common/emxTree.jsp";

		String defaultApplication    = integSessionData.getPropertyValue("mcadIntegration.Server.DefaultApplication");
		if(defaultApplication != null)
		{
			if(defaultApplication.indexOf("infocentral") > -1)
				objectDetailsPageName = "../infocentral/emxInfoManagedMenuEmxTree.jsp";
			else if(defaultApplication.indexOf("iefdesigncenter") > -1)
				objectDetailsPageName = "../common/emxTree.jsp";
		}

		return objectDetailsPageName;
	}
%>

<%
	String integrationName		= emxGetParameter(request, "integrationName");
	String cadType				= emxGetParameter(request, "cadType");
	String busName				= emxGetParameter(request, "busName");
	String dirName				= emxGetParameter(request, "mxDirName");
	String fileName				= emxGetParameter(request, "mxFileName");
	String instanceName			= emxGetParameter(request, "instanceName");
	String instanceCadType		= emxGetParameter(request, "instanceCadType");
	String autoRecognizedTNR	= emxGetParameter(request, "autoRecognizedTNR");
        String recognizedLatestTNR	= emxGetParameter(request, "recognizedLatestTNR");
	String defaultApplication	= "";
	
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");

	Context context								= integSessionData.getClonedContext(session);

	if(integSessionData == null)
	{
		String acceptLanguage = request.getHeader("Accept-Language");
		MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

		String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.UserDoesNotHavePrivilegesToUseIEF");
		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		defaultApplication = integSessionData.getPropertyValue("mcadIntegration.Server.DefaultApplication");
	}

	String appName = application.getInitParameter("ematrix.page.path");
	if(appName == null ) 
		appName = "";

	String previewServletPath = appName + "/servlet/MCADBrowserServlet";
%>

<html>
<head>

<style type="text/css"> 
	body { background-color: white; }
	body, th, td, p, select, option { font-family: Verdana, Arial, Helvetica, Sans-Serif; font-size: 8pt; }
	a { color: #003366; }
	a:hover { }
	td.pageHeader {  text-align: left; font-family: Arial, Helvetica, Sans-Serif; font-size: 13pt; font-weight: bold; color: #990000; } 
	td.pageBorder {  background-color: #003366; } 
	th { text-align: center; color: white; background-color: #336699; font-size: 10pt;}
	td { text-align: center; }
	tr.odd  { color:#13345a;background-color:#dbdbdb }
	tr.even { color:#13345a;background-color:#ffffff }
	tr.selected { color:#13345a;background-color:#ffff00 }
	td.MCADMsgHeader { text-align: left; font-family: Arial, Helvetica, Sans-Serif; font-weight: bold; color: #FFFFFF; background-color: #106090; font-family: Arial, Helvetica, Sans-Serif; font-size: 10pt; }
	td.MCADMsgBody { text-align: center; color: black; font-weight: bold; font-family: Arial, Helvetica, Sans-Serif; font-size: 10pt; }
</style>

<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
	function operationSelect()
	{
		parent.window.close();
	}

	function operationCancelled()
	{
	    //XSSOK
		top.opener.getAppletObject().callCommandHandler("<%= integrationName %>", "cancelOperation", true);
	}
  
	function previewObject(previewObjId, previewFormatName, previewFileName)
	{
		window.open("", "previewWindow", "height=500,width=600,left=0,top=0,toolbar=0,status=0,menubar=0,scrollbars=1,resizable=1");
	 
		document.forms['previewForm'].BusObjectId.value = previewObjId;    
		document.forms['previewForm'].FormatName.value = previewFormatName;
		document.forms['previewForm'].FileName.value = previewFileName;
		document.forms['previewForm'].target = "previewWindow";
		document.forms['previewForm'].submit();
	}

	function refreshParent(oid, oname, objectDetailsPageName)
	{
	    //XSSOK
		var url =  objectDetailsPageName + "?objectId=" + oid + "&emxSuiteDirectory=<%= defaultApplication %>";

		parent.window.opener.top.content.location = url;
		parent.window.close();
	}
</script>
</head>

<body>
<form name="previewForm" style="height:0;" action="<%= previewServletPath %>" method="post">


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


	<input type="hidden" name="FileName" value="">
	<input type="hidden" name="FormatName" value="">
	<input type="hidden" name="BusObjectId" value="">
	<input type="hidden" name="Command" value="GetPreviewFile">
 </form>

<!--XSSOK-->
<form name="errorForm" style="height:0;" action="<%=appName%>/integrations/MCADMessageFS.jsp" method="post" target="_top">

<%
boolean csrfEnabled1 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled1)
{
  Map csrfTokenMap1 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName1 = (String)csrfTokenMap1 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue1 = (String)csrfTokenMap1.get(csrfTokenName1);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName1%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName1%>" value="<%=csrfTokenValue1%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

	<input type="hidden" name="messageHeader" value="">
	<input type="hidden" name="message" value="">
 </form>

<%
	String majorRevision	= "";
	String errorMessage		= "";

	//Context context								= integSessionData.getClonedContext(session);
	MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	MCADGlobalConfigObject  globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
	MCADServerGeneralUtil serverGeneralUtil		= new MCADServerGeneralUtil(context, globalConfigObject, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	MCADSessionData sessionData					= integSessionData.getSessionData();
    MCADSessionDataManager sessionDataManager	= new MCADSessionDataManager(context,integSessionData, integrationName);
	boolean isCreateVersionObjectsEnabled		= globalConfigObject.isCreateVersionObjectsEnabled();
	String mcadLabelAttrName					=  util.getActualNameForAEFData(context,"attribute_MCADLabel");
	boolean isOpenedPartFinalised				= false;
	String localeLanguage						= context.getLocale().getLanguage();
	try 
	{
		cadType	   = MCADUrlUtil.hexDecode(cadType);
		busName	   = MCADUrlUtil.hexDecode(busName);
		dirName	   = MCADUrlUtil.hexDecode(dirName);
		fileName   = MCADUrlUtil.hexDecode(fileName);

		if(instanceName != null && !instanceName.equals("") && instanceCadType != null && !instanceCadType.equals(""))
		{
			instanceName	= MCADUrlUtil.hexDecode(instanceName);
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
			String autoRecognizedType     = null;
			String autoRecognizedName     = null;
			String autoRecognizedRevision = null;
			
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
				busObject.open(context);
				String type		= busObject.getTypeName();
				String objectId		= busObject.getObjectId();				

				//bulk loading
				if(!util.isMajorObject(context, objectId))//!globalConfigObject.isMajorType(type)) //[NDM] OP6
				{
					BusinessObject majorBO = util.getMajorObject(context,busObject);
					if(majorBO == null)
					{
						String activeMajor = util.getActiveVersionObjectFromMinor(context,objectId);						
						busObject =  new BusinessObject(activeMajor);
						objectId		= busObject.getObjectId();
					}
				}
				busObject.close(context);
			}
		}
		if(busObject == null)
		{
			busObject = sessionDataManager.identifyBusinessObjectWithName(context, actualCadType, actualName, dirName, fileName, sessionData, true);
		}
        if(busObject == null && recognizedLatestTNR != null && !recognizedLatestTNR.trim().equals(""))
		{
			String recognizedLatestType     = null;
			String recognizedLatestName     = null;
			String recognizedLatestRevision = null;
			
			StringTokenizer recognizedLatestTokens = new StringTokenizer(recognizedLatestTNR, "|");

			if(recognizedLatestTokens.hasMoreTokens())
				recognizedLatestType = recognizedLatestTokens.nextToken();
			if(recognizedLatestTokens.hasMoreTokens())
				recognizedLatestName = recognizedLatestTokens.nextToken();
			if(recognizedLatestTokens.hasMoreTokens())
				recognizedLatestRevision = recognizedLatestTokens.nextToken();

			if(recognizedLatestType != null && recognizedLatestName != null && recognizedLatestRevision != null)
			{
				if(instanceName != null && !instanceName.equals("") && instanceCadType != null && !instanceCadType.equals(""))
					recognizedLatestName = serverGeneralUtil.getNameForInstance(busName, recognizedLatestName);

				busObject = new BusinessObject(recognizedLatestType, recognizedLatestName, recognizedLatestRevision, "");
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
		String type		= busObject.getTypeName();
		String name		= busObject.getName();
		String revision	= busObject.getRevision();
		String busId	= busObject.getObjectId();

		BusinessObjectList businessObjectList = new BusinessObjectList();
		BusinessObject majorObject			  = null;
		if(util.isMajorObject(context, busId))//globalConfigObject.isMajorType(type)) // [NDM] OP6
		{
			if(!busObject.exists(context))
			{
				Hashtable messageDetails = new Hashtable(2);
				messageDetails.put("NAME", name);

				MCADServerException.createException(integSessionData.getStringResource("mcadIntegration.Server.Message.CannotPerformOperationAsMajorAbsentOrNotAccessible", messageDetails),null);
			}
			majorObject			= busObject;
			majorRevision		= revision;
			businessObjectList	= util.getRevisionBOsOfAllStreams(context, busObject, false);
		}
		else
		{
			BusinessObject majorBusObject = util.getMajorObject(context,busObject);
			if(majorBusObject == null)
			{
				Hashtable messageDetails = new Hashtable(2);
				messageDetails.put("NAME", name);

				MCADServerException.createException(integSessionData.getStringResource("mcadIntegration.Server.Message.CannotPerformOperationAsMajorAbsentOrNotAccessible", messageDetails),null);
			}
			majorObject			= majorBusObject;
			majorRevision		= util.getRevisionStringForMinorRev(revision);
			businessObjectList	= util.getRevisionBOsOfAllStreams(context, busObject, true);
		}		
		BusinessObject finalizedMinorObject = null; // util.getFinalizedFromMinorObject(context, majorObject); // IR-626442 - Remove expensive method call always returning null minor object.
		String finalBusId = "";
		if(finalizedMinorObject != null)
		{
			finalBusId = finalizedMinorObject.getObjectId();
		}		
		isOpenedPartFinalised = finalBusId.equals(busId);
		BusinessObjectItr businessObjectItr = new BusinessObjectItr(businessObjectList);
%>
<form name = "tableForm" method="post">

<%
boolean csrfEnabled2 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled2)
{
  Map csrfTokenMap2 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName2 = (String)csrfTokenMap2 .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue2 = (String)csrfTokenMap2.get(csrfTokenName2);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName2%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName2%>" value="<%=csrfTokenValue2%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>


<table border="0" width="100%">
    <tr>
		<th width="5%"><img border="0" src="images/iconPreview.gif" width="16" height="16" alt="Preview"></th>
		<!--XSSOK-->
		<th width="20%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Type")%></th>
		<!--XSSOK-->
		<th width="20%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name")%></th>
		<!--XSSOK-->
		<th width="20%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Title")%></th>
		<!--XSSOK-->
		<th width="15%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Revision")%></th>		
        <!--XSSOK-->		
		<th width="20%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.LockedBy")%></th>
    </tr>
<%
	String recognizedMajorObjectId = null;
	if(majorObject != null)
		recognizedMajorObjectId = majorObject.getObjectId();
    
	for(int i = 0; businessObjectItr.next(); i++)
	{
		BusinessObject currentBusObject			= businessObjectItr.obj();
		BusinessObject currentMajorBusObject	= null;
		boolean isSelected = false;
		currentBusObject.open(context);
		String strMcadlabel			= currentBusObject.getAttributeValues(context, mcadLabelAttrName).getValue();
		String currentObjectType	= currentBusObject.getTypeName();
		String currentBusObjectId = currentBusObject.getObjectId();

		if(util.isMajorObject(context, currentBusObjectId))//globalConfigObject.isMajorType(currentObjectType)) // [NDM] OP6
		{
			currentMajorBusObject = currentBusObject;
			
			if(isCreateVersionObjectsEnabled)
			{
				if(isOpenedPartFinalised && currentBusObjectId != null && recognizedMajorObjectId != null && currentBusObjectId.equals(recognizedMajorObjectId))
				{
					isSelected = true;
				}
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
		String objectLocker					= util.getNLSName(context, "Person", currentMajorBusObject.getLocker(context).getName(), "", "" , localeLanguage);	
		String currentMajorObjectRevision	= currentMajorBusObject.getRevision();
		currentMajorBusObject.close(context);
		
		String currentObjectID = currentBusObject.getObjectId();
		String objTitle 		= util.getAttributeForBO(context, currentObjectID, MCADMxUtil.getActualNameForAEFData(context, "attribute_Title"));
		String sType 			= util.getNLSName(context, "Type", currentBusObject.getTypeName(), "", "", localeLanguage);

		if(!isCreateVersionObjectsEnabled && majorRevision.equals(currentMajorObjectRevision))
			isSelected = true;
		else if(isCreateVersionObjectsEnabled && currentBusObject.getRevision().equals(revision) && !isOpenedPartFinalised)
			isSelected = true;
		
		if(isSelected)
		{
%>
	<tr class="selected" >
<%
		}
		else
		{
%>
	<tr class=<%= i%2 == 0 ? "even" : "odd"%> >
<%
		}

		Vector previewObjectDetails = serverGeneralUtil.getPreviewObjectInfo(context, currentBusObject, cadType);
	  	if(previewObjectDetails.size() == 3) 
		{
			String previewObjectID		= (String)previewObjectDetails.get(0);
			String previewFormatName	= (String)previewObjectDetails.get(1);
  			String previewFileName		= (String)previewObjectDetails.get(2);
%>
        <!--XSSOK-->
		<td><a href='javascript:previewObject("<%= previewObjectID %>", "<%= previewFormatName %>", "<%= previewFileName %>")'><img border="0" src="images/iconPreview.gif" width="16" height="16" alt="Preview"></a></td>
<%		
		}
		else 
		{
%> 
		<td></td> 
<%
		} 
%>				
        <!--XSSOK-->		
		<td><%= sType %></td>
		<!--XSSOK-->
		<td><a href="javascript:refreshParent('<%= currentBusObject.getObjectId() %>', '<%= currentBusObject.getName() %>', '<%= getObjectDetailsPageName(integSessionData) %>')"><%= currentBusObject.getName() %></a></td>
		<!--XSSOK-->
		<td><%=MCADUtil.escapeStringForHTML(objTitle) %></td>
		<td><%= currentBusObject.getRevision() %></td>		
		<!--XSSOK-->
		<td><%= objectLocker %></td>
    </tr>
<%			
			String strMcadLabelObjId	= strMcadlabel + "-" + currentObjectID;
			String strMcadId			= "mcad" + "-" + currentObjectID;
%>
            <!--XSSOK-->
			<input type="hidden" name ="mcadlabelStr" id = "<%=strMcadId%>" value="<%=strMcadLabelObjId%>">
<%
			busObject.close(context);
		}
%>
	</table>
<%
    }
    catch(Exception exception)
	{
		errorMessage = exception.getMessage();
    }

    if(errorMessage.equals("")) 
	{   

    } 
	else 
	{ 
		String messsagePageHeader	= integSessionData.getStringResource("mcadIntegration.Server.Heading.Error");

				messsagePageHeader	= MCADUrlUtil.hexEncode(messsagePageHeader);
				errorMessage		= MCADUrlUtil.hexEncode(errorMessage);

%>
		<script>
		    //XSSOK
			document.forms['errorForm'].messageHeader.value = "<%= messsagePageHeader %>";
			//XSSOK
		    document.forms['errorForm'].message.value = "<%= errorMessage %>";
		    document.forms['errorForm'].submit();			
		</script>
<%
	} 
%>

</form>
<%@include file = "MCADBottomErrorInclude.inc"%>
</body>
</html>


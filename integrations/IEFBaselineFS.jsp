<%--  IEFBaselineFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import = "com.matrixone.apps.common.*, com.matrixone.apps.domain.*, com.matrixone.apps.domain.util.*,com.matrixone.MCADIntegration.server.beans.*, matrix.util.*,java.util.*,java.text.*" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
	String contentURL = "IEFBaselineContent.jsp?";

	HashMap viewNameMap = new HashMap();
	viewNameMap.put("DSCProductStructureEditor:getObjectsWithLatestReleasedRevisions","LatestReleasedRevision");
	viewNameMap.put("DSCProductStructureEditor:getObjectsWithLatestVersions","LatestVersion");
	viewNameMap.put("DSCProductStructureEditor:getObjectsWithLatestRevisions","LatestRevision");

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);
	
	MCADServerLogger logger		= integSessionData.getLogger();
    MCADMxUtil util				= new MCADMxUtil(context, logger, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	String objectIdList     				=Request.getParameter(request,"objectIdList") == null ? "":Request.getParameter(request,"objectIdList");

	
	if("".equals(objectIdList)){
		ENOCsrfGuard.validateRequest(context, session, request, response);	
	}	
	String baselineName     			=Request.getParameter(request,"baselineName") == null ? "":Request.getParameter(request,"baselineName");
	String baselineDesc     			=Request.getParameter(request,"baselineDesc") == null ? "":Request.getParameter(request,"baselineDesc");
	String integrationName		=Request.getParameter(request,"integrationName");
	String[] objectIds					= emxGetParameterValues(request, "emxTableRowId");
	String parentObjectId  			= emxGetParameter(request, "objectId");
	String objectId						= null;
	String errorMessage			=Request.getParameter(request,"errorMessage")== null ? "":Request.getParameter(request,"errorMessage");
	String featureName			= MCADGlobalConfigObject.FEATURE_BASELINE;

	String lateralViewProgramLabel	=Request.getParameter(request,"selectedProgram");
	String defaultBaselineDesc			= integSessionData.getStringResource("mcadIntegration.Server.Message.defaultBaselineDesc");

	if(baselineDesc	==null || "".equals(baselineDesc))
	{
		baselineDesc =defaultBaselineDesc;
	}

	if(integrationName==null)
	{
		integrationName = util.getIntegrationName(context, parentObjectId);
	}

	if("".equals(objectIdList ))
	{
			if(objectIds != null)
			{
					for(int i=0;i<objectIds.length;i++)
					{
							String objectDetails = objectIds[i];
							Enumeration objectDetailsTokens = MCADUtil.getTokensFromString(objectIds[i],"|");

							if(objectDetailsTokens.hasMoreElements())
							{
									String relid = (String)objectDetailsTokens.nextElement();

									if(objectDetailsTokens.hasMoreElements())
									{
										objectId = (String)objectDetailsTokens.nextElement();
										objectIds[i] = objectId;
										if(objectIds.length == 1 || i == objectIds.length - 1 )
											objectIdList  =  objectIdList + objectId ;
										else
											objectIdList  =  objectIdList  + objectId + "|";
									}
							}
					}
			}
	}

	Vector selectedObjList		= new Vector();
	Hashtable objStructExpLevelMap		= new Hashtable();
	HashSet		expandedObjectIdSet		= new HashSet();
	StringBuffer  traversedObjectIdList = new StringBuffer();

	selectedObjList	= MCADUtil.getVectorFromString(objectIdList, "|");
	IEFBaselineHelper baselineHelper	= new IEFBaselineHelper(context,  integSessionData,integrationName);
	baselineName						= baselineHelper.getDefaultBaselineName(context, parentObjectId);

	try
	{
		MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
		MCADLocalConfigObject  localConfigObject	= null;
		String isFeatureAllowed		= integSessionData.isFeatureAllowedForIntegration(integrationName, featureName);
		localConfigObject			= integSessionData.getLocalConfigObject();

		BusinessObject parentObj = new BusinessObject(parentObjectId);
		parentObj.open(context);
		String typeName	= parentObj.getTypeName();
		
		//[NDM] OP6
		/*if(!globalConfigObject.isMajorType(typeName))
		{
			typeName = util.getCorrespondingType(context, typeName);
		}*/

		boolean isOperationAllowed = integSessionData.isOperationAllowed(context,integrationName,typeName,featureName);
		parentObj.close(context);

		if(isFeatureAllowed.startsWith("false") || localConfigObject == null)
		{
			Hashtable exceptionDetails = new Hashtable();
			exceptionDetails.put("NAME",integSessionData.getStringResource("mcadIntegration.Server.Feature."+featureName));

			if(integSessionData.isNonIntegrationUser())
			{
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.FeatureNotAllowedForNonIntegrationUser",exceptionDetails);
			}
			else
			{
				exceptionDetails.put("INTEGRATION_NAME" ,integrationName);
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.BaselineNotAllowedForNonIntegrationUser", exceptionDetails);
			}

			emxNavErrorObject.addMessage(errorMessage);
		}
		else if(!isOperationAllowed)
		{
			errorMessage = featureName + " " + UINavigatorUtil.getI18nString("emxIEFDesignCenter.Error.OperationNotAllowed","emxIEFDesignCenterStringResource", request.getHeader("Accept-Language")) + " " + typeName;
			emxNavErrorObject.addMessage(errorMessage);
		}
		else
		{
		DSCExpandObjectWithSelect objectExpander	= new DSCExpandObjectWithSelect( context,  integSessionData, integrationName);
			DSCPageViews pageViews						= new IEFBaselinePageView( context, integSessionData, integrationName);

			objectExpander.setViewApplier(pageViews);

		Hashtable objectIdExpLevelMap = new  Hashtable();
		objectIdExpLevelMap.put(parentObjectId, "all");

		String defaultLateralViewName	= MCADAppletServletProtocol.VIEW_AS_BUILT;
		String lateralViewName			= (String)viewNameMap.get(lateralViewProgramLabel);

		Hashtable objectIdViewMap		= new  Hashtable(2);
		ArrayList viewInfo 				= new ArrayList(2);

		if(lateralViewName == null || "".equals(lateralViewName))
		{
			lateralViewName	= defaultLateralViewName;
			viewInfo.add(defaultLateralViewName);
		}
		else
			{
			viewInfo.add(lateralViewName);
			}

		viewInfo.add(MCADAppletServletProtocol.VIEW_NONE);
		objectIdViewMap.put(parentObjectId, viewInfo);

		objStructExpLevelMap	= objectExpander.getRelationshipAndChildObjectInfoForParent(context, objectIdExpLevelMap, globalConfigObject.getRelationshipsOfClass(MCADAppletServletProtocol.ASSEMBLY_LIKE), new HashMap(),  objectIdViewMap, false,  lateralViewName,  null,  null);

		Enumeration e	= objStructExpLevelMap.keys();
		while(e.hasMoreElements())
		{
			String key = (String)e.nextElement();
			if(objStructExpLevelMap.size() == 1 || (!e.hasMoreElements()))
				{
					traversedObjectIdList.append(key) ;
				}
			else
			{
					traversedObjectIdList.append(key);
					traversedObjectIdList.append("|");
			}

			expandedObjectIdSet.add(key);
		}
		}

	}
	catch(Exception e)
	{
		errorMessage	= e.getMessage();
		emxNavErrorObject.addMessage(errorMessage);
	}

	if ((emxNavErrorObject.toString()).trim().length() == 0)
	{
		contentURL = contentURL + "errorMessage=" + MCADUrlUtil.hexEncode(errorMessage) + "&baselineName=" + MCADUrlUtil.hexEncode(baselineName) + "&baselineDesc=" +  MCADUrlUtil.hexEncode(baselineDesc);
%>
<html>
<head>
<script language="JavaScript">

var frameheaderFrame = null;
var framecontentFrame = null;
var framefooterFrame = null;

function init()
{
	frameheaderFrame = findFrame(this,"headerFrame");
	framecontentFrame = findFrame(this,"contentFrame");
	framefooterFrame = findFrame(this,"footerFrame");
}

function submit()
{

		baselineName = framecontentFrame.document.baseline.baselineName.value ;
		if(baselineName =="")
		{
		    //XSSOK
			alert('<%=integSessionData.getStringResource("mcadIntegration.Server.Message.EnterValidBaselineName")%>');
		}
		else
		{
			//show the progress clock
			showProgressClock();

			<!--XSSOK CAUSED REG-->
			framecontentFrame.document.baseline.objectIdList.value = '<%=traversedObjectIdList%>';
			framecontentFrame.document.baseline.parentObjectId.value = '<%=XSSUtil.encodeForJavaScript(context,parentObjectId)%>';
			framecontentFrame.document.baseline.selectedProgram.value = '<%=XSSUtil.encodeForJavaScript(context,lateralViewProgramLabel)%>';
			framecontentFrame.document.baseline.action = "IEFBaselinePreProcessing.jsp";
			framecontentFrame.document.baseline.submit();
			top.opener.location.reload();
		}



}

function showProgressClock()
{
	frameheaderFrame.document.progress.src = "images/utilProgressDialog.gif";
}

function stopProgressClock()
{
	frameheaderFrame.document.progress.src = "images/utilSpacer.gif";
}

//implement server side cancel operation
function cancel()
{
	window.close();
}

//Event handlers End
</script>
</head>
<title><%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.Baseline")%></title>
<frameset rows="80,*,80" frameborder="no" framespacing="0" onLoad="javascript:init()" onUnload="javascript:closeWindow()">
	<frame name="headerFrame" src="IEFBaselineHeader.jsp"  noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<!--XSSOK-->
	<frame name="contentFrame"  src="<%=contentURL%>" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomFrame" src="IEFBaselineFooter.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
</frameset>
</html>
<%
	}
	else
	{
%>
	<html>
	<body>
	<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
	&nbsp;
      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
        <tr >
		  <!--XSSOK-->
          <td class="errorHeader"><%=integSessionData.getStringResource("mcadIntegration.Server.Heading.Error")%></td>
        </tr>
        <tr align="center">
          <td class="errorMessage" align="center"><%=emxNavErrorObject%></td>
        </tr>
      </table>
		  </body>
		  </html>
<%
	}
	  %>


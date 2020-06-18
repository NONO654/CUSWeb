<%--  MCADVersionsSummaryFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--  frameset definition page for Revisions in UI3

--%>


<%@ include file="../emxUIFramesetUtil.inc"%>
<%@ include file="../iefdesigncenter/IEFTableInclude.inc"%>

<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*"%>


<jsp:useBean id="bo" class="com.matrixone.apps.domain.DomainObject" scope="page" />
<%@include file = "../emxTagLibInclude.inc"%>

<%
	String integrationName			= emxGetParameter(request, "integrationName");
	String instanceName				= emxGetParameter(request, "instanceName");

    String jsTreeID					= emxGetParameter(request,"jsTreeID");
	String objectId					= emxGetParameter(request,"objectId");
	String suiteDirectory			= emxGetParameter(request, "emxSuiteDirectory");

	String timeStamp				= "";
	String errorMessage				= "";
	String pageHeader				= "";
	String encodedContentURL		= "";
	String encodedDefaultFooterUrl	= "";
	String defaultTable				= "";
	String funcPageName				= "";

	String queryString				= request.getQueryString();
	MapList revisionsList			= null;

	SelectList busSelects = bo.getBusSelectList(6);
	busSelects.add(bo.SELECT_ID);
	busSelects.add(bo.SELECT_NAME);
	busSelects.add(bo.SELECT_REVISION);
	busSelects.add(bo.SELECT_TYPE);
	busSelects.add(bo.SELECT_CURRENT);
	busSelects.add(bo.SELECT_DESCRIPTION);

	//Prepare MapList busIDs to be shown in the versions dialog
	MapList busObjectsMapList = new MapList();
	//Get any versioned object and pass its id
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");

	if(integSessionData != null)
	{
		Context iefContext = integSessionData.getClonedContext(session);

		MCADMxUtil util = new MCADMxUtil(iefContext, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

		integrationName									= util.getIntegrationName(iefContext, objectId);
		IEFConfigUIUtil iefConfigUIUtil = new IEFConfigUIUtil(iefContext, integSessionData, integrationName);
		MCADServerGeneralUtil serverGeneralUtil			= null;
		MCADGlobalConfigObject  globalConfigObject		= null;
		try
		{
			serverGeneralUtil	= new MCADServerGeneralUtil(iefContext,integSessionData, integrationName);
			globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,iefContext);
		}
		catch (Exception e)
		{
			errorMessage = e.getMessage();
		}

		BusinessObject busObj = new BusinessObject(objectId);
		busObj.open(iefContext);
		bo.setId(objectId);
		request.setAttribute("objectId", objectId);
		BusinessObjectList list    = util.getMinorObjects(iefContext,busObj);
		BusinessObjectItr boRevItr = new BusinessObjectItr(list);
		if(boRevItr.next())
		{
			BusinessObject thisBO = boRevItr.obj();
			thisBO.open(iefContext);
			bo.setId(thisBO.getObjectId());

			revisionsList = bo.getRevisions(iefContext, busSelects, false);
%>
        <!--XSSOK-->
		<fw:mapListItr mapList="<%= revisionsList %>" mapName="revMap">
<%
			String busObjectId		 = (String)revMap.get(bo.SELECT_ID);//(String)((HashMap)revisionsList.get(i)).get("id");

			HashMap busObjectHashMap = new HashMap();
			busObjectHashMap.put("id", busObjectId);
			busObjectHashMap.put("type", (String)revMap.get(bo.SELECT_TYPE));
			busObjectHashMap.put("name", (String)revMap.get(bo.SELECT_NAME));
			busObjectHashMap.put("revision", (String)revMap.get(bo.SELECT_REVISION));

			busObjectsMapList.add(busObjectHashMap);
%>
		</fw:mapListItr>
<%
			thisBO.close(iefContext);
		}

		busObj.close(iefContext);

		//Put data in session alongwith timestamp
		timeStamp = Long.toString(System.currentTimeMillis());

		session.setAttribute("CurrentIndex" + timeStamp, new Integer(0));
		session.setAttribute("BusObjList" + timeStamp, busObjectsMapList);

		framesetObject fs = new framesetObject();
		fs.setDirectory("mcadintegration-verdi");

		funcPageName = MCADGlobalConfigObject.PAGE_VERSIONS_SERVERSIDE;
		defaultTable =  iefConfigUIUtil.getDefaultCustomTableName(integrationName, funcPageName, integSessionData);

		String contentURL   = "";

		// Construct page header from bean info
		bo.setId(objectId);
		SelectList selects = bo.getBusSelectList(2);
		selects.add(bo.SELECT_NAME);
		selects.add(bo.SELECT_REVISION);
		Map boInfo = bo.getInfo(iefContext, selects);

		// Page Heading - Internationalized
		String PageHeading = "mcadIntegration.Server.Title.Versions";

	    String defaultContentURL = "MCADVersionsSummary.jsp";

		if (queryString != null && !queryString.equals("") && !queryString.equals("null"))
			defaultContentURL += "?" + queryString;
		if(defaultContentURL.indexOf("%") == -1 && defaultContentURL.indexOf("+") == -1)
			defaultContentURL = FrameworkUtil.encodeURLParamValues(defaultContentURL);

		defaultContentURL = defaultContentURL + "&contentPageIsDialog=true&showWarning=true";

		String absoluteContentURL = "/integrations/" + defaultContentURL;
		encodedContentURL = MCADUrlUtil.hexEncode(absoluteContentURL);

		pageHeader = "mcadIntegration.Server.Title.Versions";

		String defaultFooterUrl = "/common/emxAppBottomPageInclude.jsp?bean=null&dir=mcadintegration-verdi&dia log=false&usepg=false&links=0&strfile=iefStringResource&portalMode=false&pageType=table&oidp="+ objectId;
		encodedDefaultFooterUrl = MCADUrlUtil.hexEncode(defaultFooterUrl);
	}
	else
	{
		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
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

	var toolbarName = "IEFVersionPageTopActionBar";

	//XSSOK
	if("<%=errorMessage%>" != "")
	{
	    //XSSOK
		alert("<%=errorMessage%>");
	}
	else
	{
	    //XSSOK
		updateFrames(listDisplay, headerFrame, footerFrame, '<%=pageHeader%>', '<%=encodedContentURL%>', '<%=encodedDefaultFooterUrl%>', '<%=timeStamp%>', "<%=defaultTable%>", false, '<%=funcPageName%>', '<%=objectId%>', '<%=integrationName%>',toolbarName,"false","false");
	}
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
<%
	if ("".equals(errorMessage.trim()))
	{
%>
<!--XSSOK-->
<frameset id="fsNav" rows="115,*,45,0" framespacing="0" border="0" frameborder="no" onunload="sessionCleanup('<%=timeStamp%>','<%=funcPageName%>')" onload="javascript:loadFrames()" >
  <frame name="pageheader"  noresize scrolling="NO" />
  <frame name="listDisplay" noresize scrolling="auto"/>
  <frame name="footerFrame" noresize scrolling="NO" />
  <frame name="listHidden" src="emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" border="0" scrolling="no" />
</frameset>
<%
	} else {
%>
	<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
	&nbsp;
      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
        <tr >
		  <!--XSSOK-->
          <td class="errorHeader"><%=serverResourceBundle.getString("mcadIntegration.Server.Heading.Error")%></td>
        </tr>
        <tr align="center">
		  <!--XSSOK-->
          <td class="errorMessage" align="center"><%=errorMessage%></td>
        </tr>
      </table>
<%
	}
%>
</html>



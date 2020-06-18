<%--  MCADEBOMSynchFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.*" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String refresh = Request.getParameter(request,"refresh");
	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);

	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.EBOMSynch");
%>

<html>
<head>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" >
//XSSOK
var unitSeparator	= "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
//XSSOK
var recordSeparator = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";

<%@include file = "IEFTreeTableInclude.inc"%>

var frameheaderDisplay = null;
var frametableDisplay = null;
var framebottomDisplay = null;

function init()
{
	frameheaderDisplay = findFrame(this,"headerDisplay");
	frametableDisplay = findFrame(this,"tableDisplay");
	framebottomDisplay = findFrame(this,"bottomDisplay");
}

var isOperationComplete = false;

//Event Handlers Start
function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
    var footerPage	= treeControlObject.getFooterPage(activeTabName);


    var pframeheaderDisplay = findFrame(parent,"headerDisplay");
	var pframetableDisplay = findFrame(parent,"tableDisplay");
	var pframebottomDisplay = findFrame(parent,"bottomDisplay");

	pframeheaderDisplay.document.location	= headerPage;
	pframetableDisplay.document.location		= contentPage;
	pframebottomDisplay.document.location	= footerPage;

}

function ebomSynchSelected()
{
	var submitStatus = treeControlObject.submitPage("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),refresh)%>");

	if(submitStatus != TRUE && submitStatus != FALSE)
	{
		alert(submitStatus);
	}
}

function updateTreeTableWindow(operationStatusMessage)
{
        operationStatusMessage = operationStatusMessage +""
	if(operationStatusMessage.indexOf("true") > -1 || operationStatusMessage.indexOf("false") > -1)
	{
		var integrationName = treeControlObject.getIntegrationName();
		var encodedString	= hexEncode(integrationName,operationStatusMessage);
		isOperationComplete = true;

		framebottomDisplay.document.forms['UpdatePage'].details.value=encodedString;
		framebottomDisplay.document.forms['UpdatePage'].submit();
	}
	else
	{
		alert(operationStatusMessage);
	}

}

function refreshParentFrame(arguments)
{
	var integrationFrame = getIntegrationFrame(this);

	if(integrationFrame != null)
	{
		var refreshFrame = integrationFrame.getActiveRefreshFrame();

		if(refreshFrame != null)
		{
			var refreshFrameURL	= refreshFrame.location.href;

			if(refreshFrameURL.indexOf("funcPageName=WhereUsed") != -1)
			{
				var refreshFrameURL	= refreshFrameURL + "&refresh=true&program=DSCWhereUsed:getList";
				refreshFrame.location.href = refreshFrameURL;
			}
			else if(refreshFrameURL.indexOf("funcPageName=RelatedDrawings") != -1)
			{
				var refreshFrameURL	= refreshFrameURL + "&refresh=true&program=IEFObjectWhereUsed:getList";
				refreshFrame.location.href = refreshFrameURL;
			}
			else if(refreshFrameURL.indexOf("funcPageName=Instances") != -1)
			{
				var refreshFrameURL	= refreshFrameURL + "&refresh=true&program=IEFObjectWhereUsed:getList";
				refreshFrame.location.href = refreshFrameURL;
			}
		}
	}
}


function startProgressBar()
{
	framebottomDisplay.document.progress.src = "images/utilProgress.gif";
}

function stopProgressBar()
{
	framebottomDisplay.document.progress.src = "images/utilSpace.gif";
}

function ebomSynchCancelled()
{
    window.close();
}

function showAlert(message, closeWindow)
{
	alert(message);
	if(closeWindow == "true")
	{
		window.close();
	}
}

function closeWindow()
{
	if(!isOperationComplete)
	{
		isOperationComplete = true;
		integrationFrame.activeBrowserCommandOpener	= null;

		var integrationName = treeControlObject.getIntegrationName();
		top.opener.getAppletObject().callCommandHandler(integrationName, "cancelEBOMSynchOperation", true);
	}

}



//Event Handlers End

//Support Methods Start
function getExpandArguments()
{
	return "";
}
//Support Methods End
</script>
<!--XSSOK-->
<title><%=operationTitle%></title>
</head>
<frameset rows="85,*,80,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="MCADEBOMSynchHeader.jsp?<%=XSSUtil.encodeForHTML(context, queryString)  %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" onresize="parent.reloadTable(this)" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="MCADEBOMSynchFooter.jsp?<%= XSSUtil.encodeForHTML(context, queryString) %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />

</frameset>
</html>

<%--  IEFRefreshFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String integrationName =Request.getParameter(request,"integrationName");
	Context context	= integSessionData.getClonedContext(session);
	MCADLocalConfigObject localConfigObject		= integSessionData.getLocalConfigObject();
	String defaultExpandLevel					= localConfigObject.getDefaultExpandLevel(integrationName);

	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.Refresh");
%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript">

<%@include file = "IEFTreeTableInclude.inc"%>

var isOperationCancelled = false;
var integrationName	= '<%=XSSUtil.encodeForJavaScript(context,integrationName)%>';
var lockeditemsPageContent	= "";

var frameheaderDisplay = null;
var frametableDisplay = null;
var framebottomDisplay = null;
function init(){
	frameheaderDisplay = findFrame(this,"headerDisplay");
	frametableDisplay = findFrame(this,"tableDisplay");
	framebottomDisplay = findFrame(this,"bottomDisplay");
	}
function refreshSelected()
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet = integFrame.getAppletObject(); 
	var message = mxmcadApplet.callTreeTableUIObject("getDirectoryChangeMessage", "");
	if(message != "NONE")
		alert(message);

	var implicitSelectionRequired = mxmcadApplet.callTreeTableUIObject("getImplicitSelectionRequired", "");

	frametableDisplay.focus();
	var status = treeControlObject.submitPage(" ");

	if(status == "true")
	{
		mxmcadApplet.callCommandHandler(integrationName, "downloadAndRefresh", implicitSelectionRequired);
		isOperationCancelled = true;
	}
	else
	{
		alert(status);
	}

}

function showAlert(message, close)
{

	alert(message);

	if(close == "true")
		closeWindow();
}

function showLockItemsConfirmDialog(integrationName)
{
	showIEFModalDialog("IEFRefreshLockedItemsFS.jsp?integrationName=" + integrationName, 400, 400);
}


function refreshCancelled()
{
	if(!isOperationCancelled)
	{
		var integFrame = getIntegrationFrame(this);
		integFrame.getAppletObject().callCommandHandler(integrationName, "cancelOperation","");
		isOperationCancelled = true;
	}

	closeWindow();
}

function closeWindow()
{
   window.close();
}

function changeNodeSelection(nodeId, selectedField)
{
	var isSelected = selectedField.checked;

	var response = treeControlObject.changeNodeSelection(nodeId + "|" + isSelected);
	if(response != TRUE && response != FALSE)
	{
		selectedField.checked = false;
		alert(response);
	}
}

function changeSelectionForAll(selectedField)
{
	var isSelected = selectedField.checked;
	treeControlObject.changeSelectionForAll(isSelected);
	frametableDisplay.document.forms["nodeSelectionHeader"].changeSelectionForAll.checked = isSelected;
}

function startProgressBar()
{
    framebottomDisplay.document.progress.src = "./images/utilProgress.gif";
}

function stopProgressBar()
{
    framebottomDisplay.document.progress.src = "./images/utilSpace.gif";
}

function refresh()
{
	if (frametableDisplay.document.layers) 
    {
        treeControlObject.scrollX = frametableDisplay.pageXOffset;
        treeControlObject.scrollY = frametableDisplay.pageYOffset;
    }
    else if (frametableDisplay.document.all) 
    {
        treeControlObject.scrollX = frametableDisplay.document.body.scrollLeft;
        treeControlObject.scrollY = frametableDisplay.document.body.scrollTop;
    }
    treeControlObject.refresh();
}

function showDirectoryChooser(nodeID)
{
	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet = integFrame.getAppletObject(); 
	var defaultDir = mxmcadApplet.callTreeTableUIObject("getDefaultDirectory", nodeID);
	mxmcadApplet.callCommandHandler(integrationName, "showDirectoryChooser", defaultDir + "|" + nodeID);
}

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

//Support Methods Start
function getExpandArguments()
{
	var pageOptions = "";
	var expansionLevel	= frameheaderDisplay.document.forms["expansion"].showLevel.value;
	//XSSOK
	if(expansionLevel!= "<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>")
	{
	    //XSSOK
		var isValid = validateExpandLevel(expansionLevel, "<%=defaultExpandLevel %>", "expansion", "<%= integSessionData.getStringResource("mcadIntegration.Server.Message.OnlyAllOrNumericValueAllowed")%>");
		if(isValid == true)
			pageOptions = expansionLevel;
	}
	else
	{
		pageOptions = "ALL";
	}

	return pageOptions;
}
//Support Methods End
</script>
</head>
<!--XSSOK-->
<title><%=operationTitle%></title>
<frameset rows="80,*,80,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onUnload="javascript:refreshCancelled()">
	<frame name="headerDisplay" src="IEFRefreshHeader.jsp?integrationName=<%=XSSUtil.encodeForURL(context,integrationName)%>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" onresize="parent.reloadTable(this)" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="IEFRefreshFooter.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />
</frameset>
</html>

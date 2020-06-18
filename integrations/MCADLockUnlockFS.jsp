<%--  MCADLockUnlockFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context context = integSessionData.getClonedContext(session);
	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);
	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.LockUnlock");
%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript">
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

function lockUnlockSelected()
{
    frametableDisplay.focus();

    var pageOptions  = getPageOptions();
    var submitStatus = treeControlObject.submitPage(pageOptions);

    if(submitStatus == TRUE)
    {
	startProgressBar();
    }
    else
    {
	alert(submitStatus);
    }
}

function getPageOptions()
{
    var pageOptions = framebottomDisplay.document.forms["directoryChooser"].workingDirectory.value;
    return pageOptions;
}

function showDirectoryChooser()
{
	var integrationName			= treeControlObject.getIntegrationName();
	var checkoutDirectoryField	= framebottomDisplay.document.forms["directoryChooser"].workingDirectory;

	integrationFrame.showDirectoryChooser(integrationName, checkoutDirectoryField, "");
}

function lockUnlockCancelled()
{
   window.close();
}

function changeLockSelectionForAll(isSelected)
{
	var response = treeControlObject.changeSelectionForAll(isSelected);

    if(response != TRUE && response != FALSE)
    {
        alert(response);
    }
}

function changeLockSelectionForModified(isSelected)
{
	var response = treeControlObject.changeSelectionForModified(isSelected);
    if(response != TRUE && response != FALSE)
    {
        alert(response);
    }
}

function startProgressBar()
{
    framebottomDisplay.document.progress.src = "./images/utilProgress.gif";
}

function stopProgressBar()
{
    framebottomDisplay.document.progress.src = "./images/utilSpace.gif";
}

function changeNodeSelection(nodeId, field)
{
    var selectedNodeDetails = nodeId + "|" + field.name + "|" + field.checked;

	var response = treeControlObject.changeNodeSelection(selectedNodeDetails);
	if(response == FALSE)
	{
		changeSelectionForMutuallyExclusive(field);
	}
	else if(response != TRUE && response != FALSE)
	{
		field.checked = !field.checked;
		alert(response);
	}
}

function changeSelectionForMutuallyExclusive(field)
{
	var anotherCheckbox = null;

	if(field.name == "Lock")
		anotherCheckbox = field.parentNode.nextSibling.nextSibling.childNodes[0];
	else
		anotherCheckbox = field.parentNode.previousSibling.previousSibling.childNodes[0];

	anotherCheckbox.checked = !field.checked;
}

function closeWindow()
{
	if(cancelOperation)
	{
		cancelOperation = false;

		var integrationName = treeControlObject.getIntegrationName();
		top.opener.getAppletObject().callCommandHandler(integrationName, "cancelOperation", true);
	}
}

function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
    var footerPage	= treeControlObject.getFooterPage(activeTabName);

	var pframeheaderDisplay = findFrame(this,"headerDisplay");
	var pframetableDisplay = findFrame(this,"tableDisplay");
	var pbottomDisplay = findFrame(this,"bottomDisplay");

	pframeheaderDisplay.document.location	= headerPage;
	pframetableDisplay.document.location		= contentPage;
	pbottomDisplay.document.location	= footerPage;
}

//Support Methods Start
function getExpandArguments()
{
	return "";
}
//Support Methods End
</script>
</head>
<!--XSSOK-->
<title><%=operationTitle%></title>
<frameset rows="80,*,80,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="MCADLockUnlockHeader.jsp?<%= XSSUtil.encodeForHTML(context, queryString)  %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" onresize="parent.reloadTable(this)" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="MCADLockUnlockFooter.jsp?<%= XSSUtil.encodeForHTML(context, queryString)  %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />
</frameset>
</html>

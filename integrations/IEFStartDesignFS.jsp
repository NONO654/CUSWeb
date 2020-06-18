<%--  IEFStartDesignFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String integrationName			=Request.getParameter(request,"integrationName");
	String workspaceFolderId		=Request.getParameter(request,"workspaceFolderId");
	String isCheckoutRequired		=Request.getParameter(request,"isCheckoutRequired");
	String isFolderDisabled			=Request.getParameter(request,"isFolderDisabled");
	String parentObjectId			=Request.getParameter(request,"parentObjectId");
%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript">

<%@include file = "IEFTreeTableInclude.inc"%>

function changeFieldSelection(selectedNodeID, activeTabName)
{
	var argsList = activeTabName + "|" + selectedNodeID;
	var response = appletObject.callTreeTableUIObject("changeFieldSelection", argsList);
}

function submit()
{
	var args		= "<%=XSSUtil.encodeForJavaScript(  integSessionData.getClonedContext(session),isCheckoutRequired)%>|<%=XSSUtil.encodeForJavaScript(  integSessionData.getClonedContext(session),isFolderDisabled)%>|<%=XSSUtil.encodeForJavaScript(  integSessionData.getClonedContext(session),workspaceFolderId)%>|<%=XSSUtil.encodeForJavaScript(  integSessionData.getClonedContext(session),parentObjectId)%>";

	var response	= appletObject.callTreeTableUIObject("templateObjectSelected", args);
	response		= response + "";
	if(response.indexOf("false") > -1)
	{
                //XSSOK
		alert("<%= integSessionData.getStringResource("mcadIntegration.Server.Message.SelectATemplateObject") %>");
	}
	else if(response != "true")
	{
        alert(response);
		window.close();
	}
	else
	{
		cancelOperation = false;
	}
}

function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
    var footerPage	= treeControlObject.getFooterPage(activeTabName);

	var frametopFrame = findFrame(this,"topFrame");
	var frametableDisplay = findFrame(this,"tableDisplay");
	var framelowerFrame = findFrame(this,"lowerFrame");

	frametopFrame.document.location	= headerPage;
	frametableDisplay.document.location	= contentPage;
	framelowerFrame.document.location	= footerPage;
}

function cancel()
{
	window.close();
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

function createDesignTemplateObject()
{

	var integrationName = "<%= XSSUtil.encodeForURL( integSessionData.getClonedContext(session), integrationName) %>";
	var workspaceFolderId = "<%= XSSUtil.encodeForURL( integSessionData.getClonedContext(session), workspaceFolderId) %>";
	var cadType			= appletObject.callTreeTableUIObject("getActiveTabName", "");
	var createDesignTemplateObjectURL = "IEFCreateDesignTemplateObjectFS.jsp?integrationName=" + integrationName + "&cadType=" + cadType + "&workspaceFolderId=" + workspaceFolderId;

	if(emxUIConstants.isCSRFEnabled){
		var csrfKey = emxUIConstants.CSRF_TOKEN_KEY;
		var csrfName = emxUIConstants.CSRF_TOKEN_NAME;
		var tokenName = lowerFrame.document.forms.bottomCommonForm.elements[csrfKey].value;
		var tokenValue = lowerFrame.document.forms.bottomCommonForm.elements[csrfName].value;

		createDesignTemplateObjectURL=createDesignTemplateObjectURL+"&"+csrfKey+"="+tokenName+"&"+csrfName+"="+tokenValue;
        }


	showIEFModalDialog(createDesignTemplateObjectURL, 700, 600);
}

function showObjectDetailsPage(objectID, objectName)
{
	var queryString = "AppendParameters=true&mode=insert&objectId=" + objectID + "&objectName=" + objectName;
	var objectDetailsPage = "../common/emxNavigator.jsp?" + queryString;

	showIEFModalDialog(objectDetailsPage, 700, 600);
}

//Event handlers End
</script>
</head>
<!--XSSOK-->
<title><%= integSessionData.getStringResource("mcadIntegration.Server.Title.StartDesign")%></title>
<frameset rows="80,*,80,0" frameborder="no" framespacing="0" onUnload="javascript:closeWindow()">
	<frame name="topFrame" src="IEFStartDesignHeader.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="tableDisplay"  src="IEFStartDesignContent.jsp?activeTabName=" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="lowerFrame" src="IEFStartDesignFooter.jsp?integrationName=<%= XSSUtil.encodeForURL( integSessionData.getClonedContext(session), integrationName) %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />
</frameset>
</html>


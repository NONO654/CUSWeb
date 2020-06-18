<%--  MCADSaveAsFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@page import = "com.matrixone.apps.domain.util.*" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String refresh = Request.getParameter(request,"refresh");

	String acceptLanguage							= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
	String saveAsSelectedWithoutViewApplication	= serverResourceBundle.getString("mcadIntegration.Server.Heading.SaveAsSelectedWithoutViewApplication");

	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);

	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.SaveAs");
%>

<html>
<head>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" >
var unitSeparator	= "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
var recordSeparator = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";
var groupSeparator  = "<%=MCADAppletServletProtocol.GROUP_SEPERATOR%>";

<%@include file = "IEFTreeTableInclude.inc"%>

var isOperationComplete = false;
var activePartSelectionNode = null;

var frameheaderDisplay = null;
var frametableDisplay = null;
var framebottomDisplay = null;

function init()
{
	frameheaderDisplay = findFrame(this,"headerDisplay");
	frametableDisplay = findFrame(this,"tableDisplay");
	framebottomDisplay = findFrame(this,"bottomDisplay");
}
//Event Handlers Start

function getPageOptionsForFooter()
{
	var regularExpression      = framebottomDisplay.document.forms["PatternMatching"].RegularExpression.value;
	var replaceString          = framebottomDisplay.document.forms["PatternMatching"].ReplaceString.value;
	var autoSeriesCADModel     = framebottomDisplay.document.forms["AutoNaming"].AutoSeriesCADModel.value;
	var autoSeriesCADDrawing   = framebottomDisplay.document.forms["AutoNaming"].AutoSeriesCADDrawing.value;
	var selectAllChildren	   = framebottomDisplay.document.forms["configOptions"].selectAllChildren.checked?"true":"false";

   var pageoption = new Array();
   pageoption[0] =  regularExpression;
   pageoption[1] =  replaceString;
   pageoption[2] =  autoSeriesCADModel;
   pageoption[3] =  autoSeriesCADDrawing;
   pageoption[4] =  selectAllChildren;

    return pageoption;
}



function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
        var footerPage	= treeControlObject.getFooterPage(activeTabName);

	var footerOptions       = getPageOptionsForFooter()
	var integrationFrame	= getIntegrationFrame(this);

	var pframeheaderDisplay = findFrame(parent,"headerDisplay");
	var pframetableDisplay = findFrame(parent,"tableDisplay");
	var pframebottomDisplay = findFrame(parent,"bottomDisplay");

	integrationFrame.setFooterOptions(footerOptions);


	pframeheaderDisplay.document.location	= headerPage;
	pframetableDisplay.document.location		= contentPage;
	pframebottomDisplay.document.location	= footerPage;
}

function changeNodeSelection(nodeId, field)
{
	var selectChildNodes	= framebottomDisplay.document.forms["configOptions"].selectAllChildren.checked;

	var selectedNodeDetails = nodeId + "|" + field.checked + "|" + selectChildNodes;

	var response = treeControlObject.changeNodeSelection(selectedNodeDetails);
	if(response != TRUE && response != FALSE)
	{
		field.checked = !field.checked;
		alert(response);
	}
}

function changeNodeCellValue(nodeId, field)
{
	var fieldValue = "";
	var fieldName =  field.name;

	if(field.type == "text")
	{
		fieldValue = field.value;
	}
	else if(field.type == "select-one")
    {
		fieldValue = field.options[field.selectedIndex].value;
		showProgressBar("progessWindowType=ActivityBar&metaMaxCount=0&fileMaxCount=0");

    }
	var selectedNodeDetails = nodeId + "|" + field.name + "|" + field.type + "|" + fieldValue;
	treeControlObject.changeNodeCellValue(selectedNodeDetails);

	if(fieldName == "Revision")
	{
		var viewsDetails = treeControlObject.getViewsDetails();
		var viewDetailsElements = viewsDetails.split('|');
		frameheaderDisplay.document.forms['views'].verticalViewsComboControl.value	= viewDetailsElements[0];
	}
}

function saveAsSelected(isConfirmed)
{
	if(arguments.length == 0 )
	{
		confirmSaveAsWithUnappliedView();
		return;
	}
	else if( isConfirmed != "true")
	{
		return;
	}

	var pageOptions  = getPageOptions();
	var submitStatus = treeControlObject.submitPage(pageOptions);

	if(submitStatus != TRUE && submitStatus != FALSE)
	{
		alert(submitStatus);
	}
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
}

function updateTreeTableWindow(operationStatusMessage)
{
	operationStatusMessage  = operationStatusMessage + ""
	if(operationStatusMessage.indexOf("true") > -1)
	{
		var integrationName = treeControlObject.getIntegrationName();
		var encodedString	= hexEncode(integrationName,operationStatusMessage);

		isOperationComplete = true;

		framebottomDisplay.document.forms['UpdatePage'].details.value=encodedString;
		framebottomDisplay.document.forms['UpdatePage'].submit();
	}
	else if(operationStatusMessage.indexOf("false") > -1)
	{
		var separator	   = "<%=MCADAppletServletProtocol.HEXA_DELIT%>";
		var arrayOfStrings = operationStatusMessage.split(separator);

		var messageToShow	= arrayOfStrings[3] + "";

		alert(messageToShow);
	}
	else if(operationStatusMessage.indexOf("refresh") > -1)
	{
		treeControlObject.refresh();
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

			//Refresh the parent frame only for Where Used or Related Drawings to show the Saved-As parent.
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
			else if(arguments != null)
			{
				framebottomDisplay.document.forms['UpdatePage'].busId.value = arguments;
			}
		}
	}
}

function changeSelectionForAll(field)
{
	var isChecked	= field.checked;
	treeControlObject.changeSelectionForAll(isChecked);
	frametableDisplay.document.forms["nodeSelectionHeader"].changeSelectionForAll.checked = isChecked;
}

function startProgressBar()
{
    framebottomDisplay.document.progress.src = "images/utilProgress.gif";
}

function stopProgressBar()
{
    framebottomDisplay.document.progress.src = "images/utilSpace.gif";
}

function saveAsCancelled()
{
    var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
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
		top.opener.getAppletObject().callCommandHandler(integrationName, "cancelSaveAsOperation", true);
	}
	integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
}

function processNames()
{
	var newObjectIDNameString = null;

    var regularExpression   = framebottomDisplay.document.PatternMatching.RegularExpression.value;
    var replaceString       = framebottomDisplay.document.PatternMatching.ReplaceString.value;

    if(regularExpression == "" || replaceString == "")
	{
	    //XSSOK
        alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.InvalidEntries")%>");
		return;
	}

	var objectDetails = treeControlObject.getAllNamesForRegularExpression();

	//For type conversion
	objectDetails = objectDetails + "";
	var response  = "";

	if(objectDetails == "")
	{
	    //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectIsNotSelected")%>");
		return;
	}
	else if(objectDetails == "FALSE")
	{
	    //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.RegularExpressionNotAllowed")%>");
		return;
	}
	else
	{
		var objectDetailsArray	= objectDetails.split(unitSeparator);
		for(var i = 0; i< objectDetailsArray.length; i++)
		{
			var objectIDName = objectDetailsArray[i];
			if(objectIDName == "")
				continue;

			var objectIDNameArray = objectIDName.split(recordSeparator);
			var objectID	= objectIDNameArray[0];
			var newNameOldName		= objectIDNameArray[1];
			var newNameOldNameArray = newNameOldName.split(groupSeparator);
			var name		= newNameOldNameArray[0];
			var oldName		= newNameOldNameArray[1];
			var saveAsName	= name.replace(new RegExp(regularExpression), replaceString);

			if(i == 0)
				newObjectIDNameString = objectID + recordSeparator + saveAsName;
			else
				newObjectIDNameString = newObjectIDNameString + unitSeparator + objectID + recordSeparator + saveAsName;
		}

		response = treeControlObject.setNewSaveAsName(newObjectIDNameString);
	}
	if(response != "true" && response != "false")
	{
		alert(response);
	}
}

function populateAutoNames()
{
	var autoSeriesModelControl	= framebottomDisplay.document.AutoNaming.AutoSeriesCADModel;
	var autoSeriesNameForModel		= autoSeriesModelControl.options[autoSeriesModelControl.selectedIndex].value;

	var autoSeriesDrawingControl	= framebottomDisplay.document.AutoNaming.AutoSeriesCADDrawing;
	var autoSeriesNameForDrawing	= autoSeriesDrawingControl.options[autoSeriesDrawingControl.selectedIndex].value;

    if(autoSeriesNameForModel == "" || autoSeriesNameForDrawing == "")
	{
	    //XSSOK
        alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.InvalidEntries")%>");
		return;
	}

	var objectDetails = treeControlObject.getAllNamesForRegularExpression();
	var response = "";

	if(objectDetails == "")
	{
	    //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectIsNotSelected")%>");
		return;
	}
	else if(objectDetails == "FALSE")
	{
	    //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.AutoNameNotAllowed")%>");
		return;
	}
	else
	{
		response = treeControlObject.setSaveAsAutoName(autoSeriesNameForModel + "|" + autoSeriesNameForDrawing);
	}

	if(response != "true" && response != "false")
	{
		alert(response);
	}
}

function showPartSearchDialog(nodeId, formName)
{
	var integrationName = treeControlObject.getIntegrationName();

	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.close();
		activePartSelectionNode = null;
	}
	var url = "../common/emxFullSearch.jsp?field=TYPES=type_Part"+"&fieldNameOID=&selection=single&submitURL=../integrations/IEFSearchPartReSubmit.jsp?methodName=doPartSelect&table=ENCAffectedItemSearchResult";
    activePartSelectionNode = nodeId;
	showIEFModalDialog(url, 575,575);
}

function doPartSelect(partName, partId)
{
	if (activePartSelectionNode != null)
	{
		var nodeId						= activePartSelectionNode;
		activeDirectoryChooserControl	= null;
		var args						=  nodeId + "|" + partId + "|" + partName;

		var result = treeControlObject.setSelectedPart(args);
		if(result != "true")
		{
			alert(result);
		}
	}
}

function showCreatePartDialog(nodeId)
{
	var url = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=CreatePart&type=type_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createJPO=emxPart:createPartJPO&createMode=DEC&preProcessJavaScript=setRDO&HelpMarker=emxhelppartcreate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart";
        activePartSelectionNode = nodeId;
	showIEFModalDialog(url, 575,575, true);
}

function selectedChangeViewProgram(showIcon)
{
	if(showIcon)
	{
		frameheaderDisplay.document.imgProgress.src = "images/iconTabCheckin.gif";
	}
	else
	{
		frameheaderDisplay.document.imgProgress.src = "images/utilSpace.gif";
	}
}

function applyViewsSelected(applyViewsOnSelected)
{
	var lateralViewComboControl	= frameheaderDisplay.document.forms["views"].lateralViewsComboControl;
	var lateralViewName	= lateralViewComboControl.options[lateralViewComboControl.selectedIndex].value;

	var verticalViewComboControl	= frameheaderDisplay.document.forms["views"].verticalViewsComboControl;
	var verticalViewName			= verticalViewComboControl.options[verticalViewComboControl.selectedIndex].value;

	var selectionDetails = applyViewsOnSelected + "|" + verticalViewName + "|" + lateralViewName;

	var status = treeControlObject.selectedViews(selectionDetails);

	if(status != TRUE && status != FALSE)
	{
		alert(status);
	}
	else
	{
		selectedChangeViewProgram(false);
	}
}

function resetToAsStored()
{
	var integrationName = treeControlObject.getIntegrationName();
	top.opener.getAppletObject().callCommandHandler(integrationName, "resetSaveAsPage", "<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),refresh)%>");
}

function confirmSaveAsWithUnappliedView()
{
	var continueSaveAs		= "true";
	var headerImgProgress	= frameheaderDisplay.document.imgProgress;

	if(headerImgProgress != null && "undefined" != typeof (headerImgProgress) && headerImgProgress.src.indexOf("images/iconTabCheckin.gif") >= 0)
	{
	    //XSSOK
		var agree = confirm("<%=saveAsSelectedWithoutViewApplication%>");
		if(!agree)
			continueSaveAs = "false";
	}

	saveAsSelected(continueSaveAs);
}

function showFolderChooser(nodeId)
{
	var integrationName = treeControlObject.getIntegrationName();
	var url = "MCADFolderSearchDialogFS.jsp?nodeId=" + nodeId + "&integrationName=" + integrationName;
	showIEFModalDialog(url, 430, 400, true);
}

function clearSelectedFolder(nodeId)
{
	appletObject.callTreeTableUIObject("clearSelectedFolder", nodeId);
	treeControlObject.refresh();
}

function doSelect(objectId, objectName,nodeId,applyToChild)
{
	var args = objectId + "|" + objectName + "|" + nodeId + "|" + applyToChild ;

	appletObject.callTreeTableUIObject("setSelectedFolder", args);
	treeControlObject.refresh();
}

function globalFolderAssign()
{
	var status = appletObject.callTreeTableUIObject("anyObjectSelected", "");
	var integrationName = treeControlObject.getIntegrationName();
	var url = "MCADFolderSearchDialogFS.jsp" + "?integrationName=" + integrationName;
	showIEFModalDialog(url, 430,400, true);
}

function doGlobalSelect(objectId, objectName, applyToChild)
{
	var args = objectId + "|" + objectName + "|" + applyToChild ;

	appletObject.callTreeTableUIObject("setSelectedFolderToMultipleCADObjects", args);
	treeControlObject.refresh();
}

function getPageOptions()
{
	var refresh						= "<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),refresh)%>";

	var pageOptions = refresh;

	return pageOptions;
}
//This method is added for Save As page customization for PSA(IBM).
function getFirstNodeIDforObjectID(objectID)
{
    var nodeID = treeControlObject.getFirstNodeIDforObjectID();
	return nodeID;
}

//This method is added for Save As page customization for PSA(IBM).
function changeSelectionByObjectID(objectID, field)
{
    var response = FALSE;
	var nodeID   = treeControlObject.getFirstNodeIDforObjectID(objectID);
	if(nodeID !="")
	{
	   var selectChildNodes	= framebottomDisplay.document.forms["configOptions"].selectAllChildren.checked;
	   var selectedNodeDetails = nodeID + "|" + field + "|" + selectChildNodes;

	   var response = treeControlObject.changeNodeSelection(selectedNodeDetails);

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
</head>
<title><%=operationTitle%></title>
<frameset rows="75,*,140,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onBeforeUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="MCADSaveAsHeader.jsp?<%= queryString %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" onresize="parent.reloadTable(this)" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="MCADSaveAsFooter.jsp?<%= queryString %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />

</frameset>
</html>

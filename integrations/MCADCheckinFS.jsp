<%--  MCADCheckinFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String sIntegName	=Request.getParameter(request,"integrationName");
	MCADGlobalConfigObject globalConfigObject		= integSessionData.getGlobalConfigObject(sIntegName, integSessionData.getClonedContext(session));

    String deleteFilesOnCheckinAttrName					= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-DeleteLocalFileOnCheckin");
	String selectBackgroungCheckinAttrName			= globalConfigObject.getAttrActualName("attribute_IEF-Pref-MCADInteg-BackgroundCheckin");

	String selectBackgroundCheckinPrefType	= globalConfigObject.getPreferenceType(selectBackgroungCheckinAttrName);
	String deleteFilesOnCheckinPrefType		= globalConfigObject.getPreferenceType(deleteFilesOnCheckinAttrName);
	
	boolean isSelectBackgroundCheckinEnforced	= false;
	boolean isDeleteFilesOnCheckinEnforced	= false;
	
	if(selectBackgroundCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE) || selectBackgroundCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		isSelectBackgroundCheckinEnforced	= true;
	}
	if(deleteFilesOnCheckinPrefType.equals(MCADAppletServletProtocol.ENFORCED_PREFERENCE_TYPE) || deleteFilesOnCheckinPrefType.equals(MCADAppletServletProtocol.HIDDEN_PREFERENCE_TYPE))
	{
		isDeleteFilesOnCheckinEnforced	= true;
	}
	
	
	MCADLocalConfigObject localConfigObject		= integSessionData.getLocalConfigObject();
	String defaultExpandLevel					= localConfigObject.getDefaultExpandLevel(sIntegName);
	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);
	
	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.Checkin");
%>
<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<html>
<head>
<script language="javascript" >

<%@include file = "IEFTreeTableInclude.inc"%>

var applyRecognitionProgramRecursively = "false";
var activePartSelectionNode;

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
function showDependentDocs(nodeID, integrationName)
{
	var derivedOutputPage = "MCADDependentDocsFS.jsp?nodeid=" + nodeID + "&integrationName=" + integrationName;

	showIEFModalDialog(derivedOutputPage, 550, 400);
}

function changeNodeDependentDocSelection(selectionDetails)
{
	var response = appletObject.callTreeTableUIObject("changeNodeDependentDocSelection", selectionDetails);

	if(response != "true" && response != "false" && response != "")
		alert(response);

	return response;
}

function getDependentDocsContent(nodeID)
{
	var dependentDocsContent = appletObject.callTreeTableUIObject("getDependentDocsContent", nodeID);
	return dependentDocsContent;
}

function lockObject(nodeID)
{
	var status = treeControlObject.lockObject(nodeID);
	if(status != TRUE && status != FALSE)
	{
		alert(status);
	}
}

function changeNodeSelection(nodeId, field)
{
	var selectChildNodes = framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckin.checked;
	var selectedNodeDetails = nodeId + "|" + field.checked + "|" + selectChildNodes;
	var response = treeControlObject.changeNodeSelection(selectedNodeDetails);
	if(response != TRUE && response != FALSE)
	{
		field.checked = false;
		alert(response);
	}
}

function changeNewOrModifiedNodeSelection(nodeId, field)
{
	var selectedNodeDetails = nodeId + "|" + field.checked + "|" + false;
	var response = treeControlObject.changeNodeSelection(selectedNodeDetails);
	if(response != TRUE && response != FALSE)
	{
		field.checked = false;
		alert(response);
	}
}

function changeConflictUUIDNodeSelection(objectID, field, MatrixUUID)
{
	var selectedNodeDetails = objectID + "|" + field.checked + "|" + MatrixUUID;
	var response = treeControlObject.changeConflictUUIDNodeSelection(selectedNodeDetails);
}

function changeConflictUUIDNodeSelectionForAll(field)
{
    treeControlObject.changeConflictUUIDNodeSelectionForAll(field.checked + "");
	frametableDisplay.document.forms["conflictUUIDNodesHeader"].changeConflictUUIDNodeSelectionForAll.checked = field.checked;
}

function changeNodeCellValue(nodeId, field)
{
	var fieldValue = "";

    if(field.type == "checkbox")
    {
		fieldValue = field.checked;
    }
    if(field.type == "select-one")
    {
		fieldValue = field.options[field.selectedIndex].value;
    }
	else if(field.type == "text")
	{
		fieldValue = field.value;
	}

	var selectedNodeDetails = nodeId + "|" + field.name + "|" + field.type + "|" + fieldValue;
	var response = treeControlObject.changeNodeCellValue(selectedNodeDetails);

	if(response != "true" && response != "false" && response != "")
		alert(response);
}

function validateForm(formObject)
{
    var targetRevisionField = getFormElement(formObject.elements, "TargetRevision");
    if(targetRevisionField.value == "")
	    //XSSOK
        alert("<%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Message.TargetRevisionCantBeEmpty")%>");
}

function showFolderChooser(nodeId, encodedTNR)
{
	var integrationName = treeControlObject.getIntegrationName();
	var url = "MCADFolderSearchDialogFS.jsp?nodeId=" + nodeId + "&tnr=" + encodedTNR + "&integrationName=" + integrationName;
	showIEFModalDialog(url, 430, 400, true);
}

function clearSelectedFolder(nodeId)
{
	appletObject.callTreeTableUIObject("clearSelectedFolder", nodeId);
	treeControlObject.refresh();
}

function globalFolderAssign()
{
	var status = appletObject.callTreeTableUIObject("anyObjectSelected", "");
		if(status != "true")
		{
			var pageOptions   = getPageOptions();
			var submitStatus = treeControlObject.submitPage(pageOptions);
			alert(submitStatus);					
		}
		else
		{
	var integrationName = treeControlObject.getIntegrationName();
	var url = "MCADFolderSearchDialogFS.jsp" + "?integrationName=" + integrationName;
	showIEFModalDialog(url, 430,400, true);
}

}

function doGlobalSelect(objectId, objectName, applyToChild)
{
	var args = objectId + "|" + objectName + "|" + applyToChild ;

	appletObject.callTreeTableUIObject("setSelectedFolderToMultipleCADObjects", args);
	treeControlObject.refresh();
}

function doSelect(objectId, objectName,nodeId,applyToChild)
{
	var args = objectId + "|" + objectName + "|" + nodeId + "|" + applyToChild ;

	appletObject.callTreeTableUIObject("setSelectedFolder", args);
	treeControlObject.refresh();
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
		var args						= nodeId + "|" + partId + "|" + partName;

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

function updateTreeTableWindow(arguments)
{
	if(arguments.indexOf("refresh") > -1)
	{
		treeControlObject.refresh();
	}
}
//Event Handlers End

//Event handlers from buttons Start(Specific to TreeControl usage)
function checkinSelected()
{
    frametableDisplay.focus(); //This is bad fix for updating edit box values in form

	var pageOptions   = getPageOptions();
	var submitStatus = treeControlObject.submitPage(pageOptions);
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();

	if(submitStatus != TRUE)
	{
		alert(submitStatus);
	}
}

function ConflictUUIDSelected()
{
    frametableDisplay.focus(); //This is bad fix for updating edit box values in form

	var pageOptions   = "";
	var submitStatus = treeControlObject.submitConflictUUIDPage(pageOptions);

	if(submitStatus != TRUE && submitStatus != "")
	{
	  alert(submitStatus);
	}
}

function getPageOptionsForFooter()
{
    var checkinComment          = framebottomDisplay.document.forms["checkinComment"].checkinComment.value;
	var deleteFilesOnCheckin    = framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.checked?"true":"false";
    var createVersionOnCheckin  = framebottomDisplay.document.forms["configOptions"].createVersionOnCheckin.checked?"true":"false";
    var retainLockOnCheckin     = framebottomDisplay.document.forms["configOptions"].retainLockOnCheckin.checked?"true":"false";
	var selectBackgroungCheckin = framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.checked?"true":"false";
    var selectAllChildrenOnCheckin = framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckin.checked?"true":"false";

   var pageoption = new Array();


   pageoption[0] =  checkinComment;
   pageoption[1] =  deleteFilesOnCheckin;
   pageoption[2] =  createVersionOnCheckin;
   pageoption[3] =  retainLockOnCheckin;
   pageoption[4] =  selectBackgroungCheckin;
   pageoption[5] =  selectAllChildrenOnCheckin;



    return pageoption;
}


function getPageOptions()
{
    //XSSOK
    var checkinComment          = hexEncode("<%= sIntegName%>", framebottomDisplay.document.forms["checkinComment"].checkinComment.value);
	var deleteFilesOnCheckin    = framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.checked?"true":"false";
    var createVersionOnCheckin  = framebottomDisplay.document.forms["configOptions"].createVersionOnCheckin.checked?"true":"false";
    var retainLockOnCheckin     = framebottomDisplay.document.forms["configOptions"].retainLockOnCheckin.checked?"true":"false";
	var selectBackgroungCheckin = framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.checked?"true":"false";

    var pageOptions = checkinComment + "|" + deleteFilesOnCheckin + "|" + createVersionOnCheckin + "|" + retainLockOnCheckin + "|" + selectBackgroungCheckin;

    return pageOptions;
}

function ltrim ( s )
{
	return s.replace( /^\s*/, "" )
}

function rtrim ( s )
{
	return s.replace( /\s*$/, "" );
}

function trim ( s )
{
	return rtrim(ltrim(s));
}

function checkinCancelled()
{
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
	window.close();
}

function changeSelectionForAll(field)
{
    var isChecked	= field.checked;

	var response  = treeControlObject.changeSelectionForAll(isChecked);

	if(response != TRUE && response != FALSE && response != "")
		alert(response);

	frametableDisplay.document.forms["nodeSelectionHeader"].changeSelectionForAll.checked = isChecked;
}

function changeSelectionForModified(isSelected)
{
    response = treeControlObject.changeSelectionForModified(isSelected);

	if(response.indexOf("true|") == 0)
	{
		response = response.substring(5);
		alert(response);
	}
	else if(response && response != TRUE && response != FALSE && response != "" && response.indexOf("true") < 0)
	{
		alert(response);
	}
}

function changeRecognitionStatus(isSelected)
{
	response = treeControlObject.changeRecognitionStatus(isSelected);

	if(response != TRUE && response != FALSE)
	{
		alert(response);
	}
}

function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
    var footerPage	= treeControlObject.getFooterPage(activeTabName);

	var custview = "CustomView";

	if(currentTabName== "" || currentTabName==custview)
	{
		var footerOptions = getPageOptionsForFooter();

		var integrationFrame	= getIntegrationFrame(this);
		integrationFrame.setFooterOptions(footerOptions);
	}

	var pframeheaderDisplay = findFrame(this,"headerDisplay");
	var pframetableDisplay = findFrame(this,"tableDisplay");
	var pframebottomDisplay = findFrame(this,"bottomDisplay");

	pframeheaderDisplay.document.location	= headerPage;
	pframetableDisplay.document.location		= contentPage;
	pframebottomDisplay.document.location	= footerPage;
}

function showOnlyNodesCurrentlyUnrecognized(field)
{
	treeControlObject.showOnlyNodesCurrentlyUnrecognized(field.checked);
}

function getShowOnlyNodesCurrentlyUnrecognizedFlag()
{
	var status = treeControlObject.getShowOnlyNodesCurrentlyUnrecognizedFlag();

	return status;
}

function changeObsoleteNodeSelection(objectID, field)
{
	var selectedNodeDetails = objectID + "|" + field.checked;
	var response = treeControlObject.changeObsoleteNodeSelection(selectedNodeDetails);

	if(response != TRUE && response != FALSE && response != "")
	{
		alert(response);
	}
}

function changeObsoleteNodeSelectionForAll(field)
{
	var isChecked = field.checked;
	var response = treeControlObject.changeObsoleteNodeSelectionForAll(isChecked);
	frametableDisplay.document.forms["obsoleteNodesHeader"].changeObsoleteNodeSelectionForAll.checked = isChecked;

	if(response != TRUE && response != FALSE && response != "")
	{
		alert(response);
	}
}

function checkoutObsoleteNode(objectID, integrationName)
{
	var args = objectID + "|||";

	top.opener.getAppletObject().callCommandHandler(integrationName, 'cancelCheckinStartCheckout', args);
}

function checkoutSelectedNodes()
{
	var integrationName = treeControlObject.getIntegrationName();
	var objectsInfo		= appletObject.callTreeTableUIObject("getSelectedObsoleteObjectIDs", "");

	if(objectsInfo == null || objectsInfo == "" )
	{
	    //XSSOK
	    alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.ObjectIsNotSelected")%>");
	}
	else
	{
		top.opener.getAppletObject().callCommandHandler(integrationName, 'cancelCheckinStartCheckout', objectsInfo);
	}
}

function sortObsoleteNodesColumn(columnName)
{
	treeControlObject.sortObsoleteNodesColumn(columnName);
}

function changeDeselectCheckinForAll(field)
{
	var isCkecked = field.checked;
	var response = treeControlObject.changeDeselectCheckinForAll(isCkecked);

	frametableDisplay.document.forms["obsoleteNodesDeselectForAllHeader"].changeDeselectCheckinForAll.checked =isCkecked;

	if(response != TRUE && response != FALSE && response != "")
	{
		alert(response);
	}
}

function changeDeselectCheckin(nodeId, field)
{
	var selectedNodeDetails = nodeId + "|" + field.checked + "|" + false;

	var response = treeControlObject.changeNodeSelection(selectedNodeDetails);

	if(response != TRUE && response != FALSE)
	{
		field.checked = false;
		alert(response);
	}
}

function changeUnrecognizedNodeSelection(objectID, field)
{
	var selectedNodeDetails = objectID + "|" + field.checked;

	treeControlObject.changeUnrecognizedNodeSelection(selectedNodeDetails);
}

function changeUnrecognizedNodeSelectionForAll(field)
{
	var isChecked = field.checked;
	treeControlObject.changeUnrecognizedNodeSelectionForAll(isChecked);
	frametableDisplay.document.forms["unrecognizedNodesHeader"].changeUnrecognizedNodeSelectionForAll.checked = isChecked;
}

function changeUnrecognizedNodeCellValue(objectID, field)
{
	var fieldValue = "";
        if(field.type == "checkbox")
    {
		fieldValue = field.checked;
    }
    if(field.type == "select-one")
    {
		fieldValue = field.options[field.selectedIndex].value;
    }
	else if(field.type == "text")
	{
		fieldValue = field.value;
	}

	var selectedNodeDetails = objectID + "|" + field.name + "|" + field.type + "|" + fieldValue;
	var status = treeControlObject.changeUnrecognizedNodeCellValue(selectedNodeDetails);

    if(status != TRUE && status != FALSE)
	{
		alert(status);
	}
}
function sortConflictUUIDNodesColumn(columnName)
{
	treeControlObject.sortConflictUUIDNodesColumn(columnName);
}

function sortUnrecognizedNodesColumn(columnName)
{
	treeControlObject.sortUnrecognizedNodesColumn(columnName);
}

function recognizeNode(objectID)
{
	var inArgs = objectID;
	var response = treeControlObject.recognizeNode(inArgs);
	if(response != TRUE && response != FALSE)
	{
		alert(response);
	}
}

function selectedRecognitionProgram(programComboControl)
{
	applyRecognitionProgramRecursively = "false";
	var programLabel = programComboControl.options[programComboControl.selectedIndex].id;
	if(programLabel == "LatestRevisionVersion")
		applyRecognitionProgramRecursively = "true";

    var programName = programComboControl.options[programComboControl.selectedIndex].value;

    if(programName == "None")
        return;

    var status = treeControlObject.executeRecognitionProgram(programName);
	if(status != TRUE && status != FALSE)
	{
		alert(status);
	}
}

function deleteFilesRetainLockValidation(deleteFilesRetainLockField)
{
    var isDeleteFiles		= framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.checked;
    var isRetainLock		= framebottomDisplay.document.forms["configOptions"].retainLockOnCheckin.checked;
	var isBackgroundCheckin	= framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.checked;

    if(deleteFilesRetainLockField.name == "deleteFilesOnCheckin")
    {

		if(isBackgroundCheckin && isRetainLock && isDeleteFiles)
		{
			deleteFilesRetainLockField.checked = false;
			    //XSSOK
				alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileRetainingLockAndBackGroundCheckin")%>");
		}
		else if(isRetainLock && isDeleteFiles)
		{
			deleteFilesRetainLockField.checked = false;
            framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.disabled = false;
			framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.checked = false;
			//XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileRetainingLock")%>");
		 }
		 else if(isBackgroundCheckin && isDeleteFiles)
		{
			deleteFilesRetainLockField.checked = false;
			//XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileBackGroundCheckin")%>");
		}
		else if(deleteFilesRetainLockField.name == "deleteFilesOnCheckin" && isDeleteFiles && !isRetainLock)
		{
			framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.disabled = true;
		}
		//XSSOK
		else if(deleteFilesRetainLockField.name == "deleteFilesOnCheckin" && !isDeleteFiles && !<%=isSelectBackgroundCheckinEnforced%>)
		{
			framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.disabled = true;
		}

		//XSSOK
		if(deleteFilesRetainLockField.name == "deleteFilesOnCheckin" && !isDeleteFiles && !isRetainLock && !<%=isSelectBackgroundCheckinEnforced%>)
		{
			framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.disabled = false;
		}
    }
    else if(deleteFilesRetainLockField.name == "retainLockOnCheckin")
    {
	    if(isRetainLock && isDeleteFiles)
	    {
			deleteFilesRetainLockField.checked = false;
			//XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantRetainLockWhileDeletingFiles")%>");
	    }
	}
}

function backgroundCheckinValidation(backgroundCheckinField)
{
	var isDeleteFiles		= framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.checked;
	var isBackgroundCheckin	= framebottomDisplay.document.forms["configOptions"].selectBackgroungCheckin.checked;

	if(backgroundCheckinField.name == "selectBackgroungCheckin" && isBackgroundCheckin)
		{
			framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.checked = false;
			framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.disabled = true;
		}
		//XSSOK
		if(backgroundCheckinField.name == "selectBackgroungCheckin" && !isBackgroundCheckin && !<%=isDeleteFilesOnCheckinEnforced%>)
		{
			framebottomDisplay.document.forms["configOptions"].deleteFilesOnCheckin.disabled = false;
		}
}

function validateCheckinComment(form)
{

}

function showAlert(message, closeWindow)
{
	if(closeWindow == "true")
		closeProgressBar();

	alert(message);

	if(closeWindow == "true")
		window.close();
}

function closeWindow()
{
	if(cancelOperation)
	{
		cancelOperation = false;

		var integrationName = treeControlObject.getIntegrationName();
		top.opener.getAppletObject().callCommandHandler(integrationName, 'cancelOperation', true);				
	}
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
}

function isSelectAllChildren(arguments)
{
	var selectChildNodes = framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckin.checked;

	if(selectChildNodes)
		return "true";
	else
		return "false";
}

function toggleRevisionVersionBox(columnID, objectID)
{
	var response = treeControlObject.toggleRevisionVersionBox(columnID, objectID);
}

//Event handlers from buttons End
//Expand All / Collapse All functionality. Issue 39
function expandAllOnCheckin()
{
	var configOptions = framebottomDisplay.document.forms["configOptions"];
	var expandCheckBoxState	= configOptions.expandAllOnCheckin.checked;

	if( expandCheckBoxState)
	{
		configOptions.collapseAllOnCheckin.disabled = true;
	}
	else
	{
		configOptions.collapseAllOnCheckin.disabled = false;
	}

	//treeControlObject.setExpandAll(expandCheckBoxState + "");
}
//Expand All / Collapse All functionality. Issue 39
function collapseAllOnCheckin()
{
	var configOptions  = framebottomDisplay.document.forms["configOptions"];
	var collapseCheckBoxState = configOptions.collapseAllOnCheckin.checked;

	if( collapseCheckBoxState)
	{
		configOptions.expandAllOnCheckin.disabled = true;
	}
	else
	{
		configOptions.expandAllOnCheckin.disabled = false;
	}

	//treeControlObject.setCollapseAll(collapseCheckBoxState+"");
}
function isCollapseAllSelected()
{
	var configOptions  = framebottomDisplay.document.forms["configOptions"];
	var collapseCheckBoxState = configOptions.collapseAllOnCheckin.checked;
	if(collapseCheckBoxState)
	{
        return true;
	}
	else
	{
        return false;
	}


}
function isExpandAllSelected()
{
	var configOptions = framebottomDisplay.document.forms["configOptions"];
	var expandCheckBoxState	= configOptions.expandAllOnCheckin.checked;
	if(expandCheckBoxState)
		return true;
	else
		return false;
}

//Support Methods Start
function getExpandArguments()
{
	var selectChildNodes = framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckin.checked?"true":"false";

	var activeTabName = treeControlObject.getActiveTabName(" ");
	var pageOptions = selectChildNodes + "|";

	if(activeTabName == "Checkin" || activeTabName == "")
	{
		var expansionLevel = frameheaderDisplay.document.forms["expandOptions"].showLevel.value;
        //XSSOK
		if(expansionLevel != "<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>")
		{
			var isValid = validateLimit(expansionLevel);
			if(isValid == true)
				pageOptions = pageOptions + expansionLevel;
		}
		else
		{
			pageOptions = pageOptions + "ALL";
		}
	}
	else
	{
		pageOptions = pageOptions + "1";
	}

	return pageOptions;
}

//Support Methods End
function validateLimit(expansionLevel)
{
	var validArgs = true;
	var filterLevel = frameheaderDisplay.document.forms["expandOptions"].filterLevel.value;
	if(filterLevel != "All")
	{
		if (isNaN(expansionLevel) == true)
		{
		    //XSSOK
			alert("<%= integSessionData.getStringResource("mcadIntegration.Server.Message.OnlyAllOrNumericValueAllowed")%>");
			//XSSOK
			frameheaderDisplay.document.forms["expandOptions"].showLevel.value = "<%=defaultExpandLevel%>";
			frameheaderDisplay.document.forms["expandOptions"].showLevel.focus();
			validArgs = false;
		}
		else
		{
			var isValid = isValidNumber(expansionLevel);
			if(isValid == false)
			{
			    //XSSOK
				alert("<%= integSessionData.getStringResource("mcadIntegration.Server.Message.OnlyAllOrNumericValueAllowed")%>");
				//XSSOK
				frameheaderDisplay.document.forms["expandOptions"].showLevel.value = "<%=defaultExpandLevel%>";
				frameheaderDisplay.document.forms["expandOptions"].showLevel.focus();
				validArgs = false;
			}
		}
	}
	else
	{
		if(expansionLevel.toUpperCase() != "ALL")
		{
		    //XSSOK
			alert("<%= integSessionData.getStringResource("mcadIntegration.Server.Message.OnlyAllOrNumericValueAllowed")%>");
			frameheaderDisplay.document.forms["expandOptions"].showLevel.value = "ALL";
			frameheaderDisplay.document.forms["expandOptions"].showLevel.focus();
			validArgs = false;
		}
	}
	return validArgs;
}
//Support Methods End
</script>
</head>
<!--XSSOK-->
<title><%=operationTitle%></title>
<frameset rows="85,*,125,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onUnload="javascript:closeWindow()" >
    <!--XSSOK-->
	<frame name="headerDisplay" src="MCADCheckinHeader.jsp?<%= queryString %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" onresize="parent.reloadTable(this)" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<!--XSSOK-->
	<frame name="bottomDisplay" src="MCADCheckinFooter.jsp?<%= queryString %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />
</frameset>
</html>


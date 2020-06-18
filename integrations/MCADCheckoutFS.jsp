<%--  MCADCheckoutFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData		= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String integrationName							=Request.getParameter(request,"integrationName");
	String revConflictMessage						=Request.getParameter(request,"revConflictMessage");
	String confirmMessage							=Request.getParameter(request,"confirmMessage");
	String downloadStructure						= Request.getParameter(request,"downloadStructure");
	MCADLocalConfigObject localConfigObject			= integSessionData.getLocalConfigObject();
	String defaultExpandLevel						= localConfigObject.getDefaultExpandLevel(integrationName);
	String acceptLanguage							= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
	String checkoutMessageHeaderKey					= "mcadIntegration.Server.Heading.CheckoutMessage";
	String checkoutSelectedWithoutViewApplication	= serverResourceBundle.getString("mcadIntegration.Server.Heading.CheckoutSelectedWithoutViewApplication");

	String queryString = emxGetEncodedQueryString(integSessionData.getClonedContext(session),request);

	boolean isDownloadStructure = false;
	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.Checkout");
	
	if(MCADUtil.getBoolean(downloadStructure))
	{
		operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.DownloadStructure");
		isDownloadStructure = true;
	}
	
	String checkoutMessageHeader	= serverResourceBundle.getString(checkoutMessageHeaderKey);
	String checkoutWarningHeader	= serverResourceBundle.getString("mcadIntegration.Server.Heading.CheckoutWarning");
	
	if(isDownloadStructure)
	{
			checkoutMessageHeader = serverResourceBundle.getString("mcadIntegration.Server.Heading.DownloadStructureMessage");
			checkoutWarningHeader = serverResourceBundle.getString("mcadIntegration.Server.Heading.DownloadStructureWarning");
	}
				
%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" >

<%@include file = "IEFTreeTableInclude.inc"%>

//Indicates whether lateral view has beeb selected once
var isLateralViewSelected = false;

//Indicates whether structure has been changed in the page
var isStructureDisturbed = false;

//Confirmation dialog content
var confirmWindowContent;

//Confirmation dialog content
var confirmDeleteWindowContent;

var familyConflictWindowContent;

//To check whether message shown or not
var isConfirmMessageShown = "false";

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
function changeNodeSelection(nodeId, field)
{
    	var selectChildNodes			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked;
    var selectFirstLevelChildren	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;
	var selectedNodeDetails			= nodeId + "|" + field.checked + "|" + selectChildNodes + "|" + selectFirstLevelChildren;

	var response = treeControlObject.changeNodeSelection(selectedNodeDetails);

	if(response != TRUE && response != FALSE)
	{
		field.checked = false;
		alert(response);
	}
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

function changeNodeLockSelection(nodeId, field)
{
	var selectChildNodes			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked;
	var selectFirstLevelChildren	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;
    var selectedNodeDetails			= nodeId + "|" + field.checked + "|" + selectChildNodes + "|" + selectFirstLevelChildren;

	var response = treeControlObject.changeNodeLockSelection(selectedNodeDetails);

	if(response != TRUE && response != FALSE)
	{
		field.checked = !field.checked;
		alert(response);
	}

	if(response == FALSE)
		treeControlObject.implementSelectionLogic(nodeId, field);
}

function changeNodeLocalCheckoutSelection(nodeId, field)
{
	var selectChildNodes			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked;
	var selectFirstLevelChildren	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;
	var selectedNodeDetails			= nodeId + "|" + field.checked + "|" + selectChildNodes + "|" + selectFirstLevelChildren;

	var response = treeControlObject.changeNodeLocalCheckoutSelection(selectedNodeDetails);
	if(response != TRUE && response != FALSE)
	{
		field.checked = !field.checked;
		alert(response);
	}

	if(response == FALSE)
		treeControlObject.implementSelectionLogic(nodeId, field);
}

function changeNodeCellValue(nodeId, field)
{
	showProgressBar("progessWindowType=ActivityBar&metaMaxCount=0&fileMaxCount=0");
    var fieldValue = "";
    var filedName =  field.name;

    if(field.type == "checkbox")
    {
		fieldValue = field.checked;
    }
    else if(field.type == "select-one")
    {
		fieldValue = field.options[field.selectedIndex].value;
    }
	else if(field.type == "text")
	{
		fieldValue = field.value;
	}
	var selectFirstLevelChildren	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;
    var selectedNodeDetails			= nodeId + "|" + field.name + "|" + field.type + "|" + fieldValue + "|" + selectFirstLevelChildren;
	treeControlObject.changeNodeCellValue(selectedNodeDetails);

	if(filedName == "Version" || filedName == "Revision")
	{
		var viewsDetails = treeControlObject.getViewsDetails();
		var viewDetailsElements = viewsDetails.split('|');
		frameheaderDisplay.document.forms['views'].verticalViewsComboControl.value	= viewDetailsElements[0];
		frameheaderDisplay.document.forms['views'].lateralViewsComboControl.value	= viewDetailsElements[1];
	}
	closeProgressBar();
}

function fillCheckBoxSelectionDataTable()
{
	init();
	var selectToSelect = new Array;
	selectToSelect['Lock']				= 'LocalCheckout|picked';
	selectToSelect['LocalCheckout']		= 'picked';

	checkBoxSelectionDataTable['selectToSelect'] = selectToSelect;
	checkForRevConflict();
}

function previewObject(nodeID)
{
    var previewObjectDetails = treeControlObject.getPreviewObjectDetails(nodeID);

	var detailsElements	= previewObjectDetails.split('|');
    var previewID		= detailsElements[0];
	var previewFormat	= detailsElements[1];
	var previewFileName = detailsElements[2];

    window.open("", "previewWindow", "height=500,width=600,left=0,top=0,toolbar=0,status=0,menubar=0,scrollbars=1,resizable=1");

    framebottomDisplay.document.forms['previewForm'].BusObjectId.value = previewID;
    framebottomDisplay.document.forms['previewForm'].FormatName.value = previewFormat;
    framebottomDisplay.document.forms['previewForm'].FileName.value = previewFileName;
    framebottomDisplay.document.forms['previewForm'].target = "previewWindow";
    framebottomDisplay.document.forms['previewForm'].submit();
}

function getPageOptionsFooterOptions()
{

	var workingDirectory					= framebottomDisplay.document.forms["directoryChooser"].workingDirectory.value;
    var loadFilesOnCheckout					= "false";
	if((framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout != null) && "undefined" != typeof (framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout))
	{
		loadFilesOnCheckout = framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout.checked?"true":"false";
	}
	var selectAllChildrenOnCheckout			        = framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked?"true":"false";
	var selectFirstLevelChildrenOnCheckout	                = framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked?"true":"false";
	var applyViewToChildrenOnly				= framebottomDisplay.document.forms["configOptions"].applyViewToChildrenOnly.checked?"true":"false";

	var pageOptions = new Array();

        pageOptions[0]= workingDirectory;
	pageOptions[1]= loadFilesOnCheckout;
	pageOptions[2]= selectAllChildrenOnCheckout;
	pageOptions[3]= selectFirstLevelChildrenOnCheckout;
	pageOptions[4]= applyViewToChildrenOnly;

	return pageOptions;
}

function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
    var footerPage	= treeControlObject.getFooterPage(activeTabName);

	var footerOptions       = getPageOptionsFooterOptions();
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.setFooterOptions(footerOptions);

	var pframeheaderDisplay = findFrame(parent,"headerDisplay");
	var pframetableDisplay = findFrame(parent,"tableDisplay");
	var pframebottomDisplay = findFrame(parent,"bottomDisplay");

	pframeheaderDisplay.document.location	= headerPage;
	pframetableDisplay.document.location		= contentPage;
	pframebottomDisplay.document.location	= footerPage;
}

function updateFooterPageOption(name, value)
{
	treeControlObject.updateFooterPageOptions(name + "|" + value);
}

// Function added for showing revisioning alert considering URL encoding using French language
var messageToShow = "";
function showCheckoutMessageForRevConf(message)
{
	messageToShow = message + "";
	if(messageToShow.length > 100)
	{
                //XSSOK
		queryString  			= "messageHeader=" + "<%=checkoutWarningHeader%>";
		messageToShow 			= escape(messageToShow);
		showIEFModalDialog("./DSCErrorMessageDialogFS.jsp?showExportIcon=true&" + queryString,400,400,true);
	}
	else
		alert(message);
}
function showCheckoutMessageForConf(message)
{
    messageToShow = message + "";
    if(messageToShow.length > 100)
    {
        //XSSOK
        queryString             = "messageHeader=" + "<%=checkoutWarningHeader%>";
        messageToShow           = escape(messageToShow);
        showIEFModalDialog("./DSCErrorMessageDialogFS.jsp?showContinueBtn=true&showExportIcon=true&" + queryString,400,400,true);
    }
    else
        alert(message);
}


//Event Handlers End

//Event handlers from buttons Start(Specific to TreeControl usage)
function checkoutSelected(isConfirmed)
{
	if(arguments.length == 0 )
	{
		if(top.opener.directoryChooserStatus != null && "undefined" != typeof (top.opener.directoryChooserStatus) && top.opener.directoryChooserStatus == "opened")
		{
		
		<%
			String errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.DirectoryChooserIsStillOpen");	
			if(isDownloadStructure)
			{
				errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.DirectoryChooserIsStillOpenforDownload");	
			}			
			
		%>
                        //XSSOK
			alert("<%=errorMessage%>");
			return;
		}

		confirmCheckoutWithUnappliedView();
		return;
	}
	else if( isConfirmed != "true")
	{
		return;
	}

	var pageOptions  = getPageOptions();
	var submitStatus = treeControlObject.submitPage(pageOptions);

	if(submitStatus != TRUE && submitStatus != "")
	{
		var index = submitStatus.indexOf('|');
		if(index >= 0)
		{
			var messageStartsWith = submitStatus.substring(0, index);
			if(messageStartsWith == "CONFIRM")
			{
				var message = submitStatus.substring(index + 1);
				if(isConfirmMessageShown != "true")
				{
					message = getHtmlSafeString(message);
					showCheckoutMessageForConf(message);
					isConfirmMessageShown = "true";
				}
				else
				{
					var integrationName = treeControlObject.getIntegrationName();
					top.opener.getAppletObject().callCommandHandler(integrationName, "checkoutSelected", "");
				}
			}
			else if(messageStartsWith == "REVCONFLICT")
			{
				var message = submitStatus.substring(index + 1);
				showCheckoutMessageForRevConf(message);
			}
			else
				showCheckoutMessage(submitStatus);
		}
		else
			showCheckoutMessage(submitStatus);
	}
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
}
function doContinueButtonAction()
{
	var integrationName = treeControlObject.getIntegrationName();
    top.opener.getAppletObject().callCommandHandler(integrationName, "checkoutSelected", "");
}
function confirmCheckoutWithUnappliedView()
{
	var continueCheckout	= "true";
	var headerImgProgress	= frameheaderDisplay.document.imgProgress;

	if(headerImgProgress != null && "undefined" != typeof (headerImgProgress) && headerImgProgress.src.indexOf("images/iconTabCheckin.gif") >= 0)
	{
                //XSSOK
		var agree = confirm("<%=checkoutSelectedWithoutViewApplication%>");
		if(!agree)
			continueCheckout = "false";
	}

	checkoutSelected(continueCheckout);
}

function showCheckoutMessage(message)
{
	if(message.length > 100)
	{
		messageToShow = message + "";

		messageToShow = escape(messageToShow);
		<%
			checkoutMessageHeader	= MCADUrlUtil.hexEncode(checkoutMessageHeader);
		%>
		//XSSOK
		var queryString  = "messageHeader=" + "<%=checkoutMessageHeader%>";
		showIEFModalDialog("./MCADMessageFS.jsp?" + queryString, 400, 400, true);
	}
	else
		alert(message);
}

function getPageOptions()
{
	var workingDirectory					= framebottomDisplay.document.forms["directoryChooser"].workingDirectory.value;
    //var loadFilesOnCheckout					= framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout.checked?"true":"false";
	var loadFilesOnCheckout					= "false";
	if((framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout != null) && "undefined" != typeof (framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout))
	{
		loadFilesOnCheckout = framebottomDisplay.document.forms["configOptions"].loadFilesOnCheckout.checked?"true":"false";
	}
	var selectAllChildrenOnCheckout			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked?"true":"false";
	var selectFirstLevelChildrenOnCheckout	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked?"true":"false";
	var transactionLevel					= "true";
	var openFromWeb = "true";

	var pageOptions = workingDirectory + "|" + loadFilesOnCheckout + "|" + selectAllChildrenOnCheckout + "|" + selectFirstLevelChildrenOnCheckout + "|" + transactionLevel + "|" + openFromWeb;

    return pageOptions;
}

function checkoutCancelled()
{
    var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
    window.close();
}

function changeSelectionForAll(field)
{
	var isChecked	= field.checked;
	treeControlObject.changeSelectionForAll(isChecked);
	frametableDisplay.document.forms["nodeSelectionHeader"].changeSelectionForAll.checked = isChecked;
}

function changeSelectionForMust(isSelected)
{
    treeControlObject.changeSelectionForMust(isSelected);
}

function changeLockSelectionForAll(isLocked)
{
	var selectChildNodes			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked;
	var selectFirstLevelChildren	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;
    var selectionDetails			= isLocked + "|" + selectChildNodes + "|" + selectFirstLevelChildren;

    var response = treeControlObject.changeLockSelectionForAll(selectionDetails);

	if(response != TRUE && response != FALSE)
	{
		alert(response);
	}
}

function changeLocalCheckoutSelectionForAll(isLocalCheckout)
{
	var response = treeControlObject.changeLocalCheckoutSelectionForAll(isLocalCheckout);

	if(response != TRUE && response != FALSE)
	{
		alert(response);
	}
}

function showDirectoryChooser()
{
	var integrationName			= treeControlObject.getIntegrationName();
	var checkoutDirectoryField	= framebottomDisplay.document.forms["directoryChooser"].workingDirectory;

	integrationFrame.showDirectoryChooser(integrationName, checkoutDirectoryField, "");
}

function applyViewsSelected(applyViewsOnSelected)
{
    var lateralViewComboControl		= frameheaderDisplay.document.forms["views"].lateralViewsComboControl;
	var verticalViewComboControl	= frameheaderDisplay.document.forms["views"].verticalViewsComboControl;
	var lateralViewSelectedIndex = lateralViewComboControl.selectedIndex;
	if(lateralViewSelectedIndex == -1)
	{
		lateralViewComboControl.selectedIndex = 0;
	}
	var lateralViewName		= lateralViewComboControl.options[lateralViewComboControl.selectedIndex].value;
	var verticalViewName	= verticalViewComboControl.options[verticalViewComboControl.selectedIndex].value;

	var applyViewToChildren		= framebottomDisplay.document.forms["configOptions"].applyViewToChildrenOnly.checked;

	var selectionDetails = applyViewsOnSelected + "|" + lateralViewName + "|" +  verticalViewName + "|" + applyViewToChildren;

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
	//XSSOK
	var isDownloadStructure = "<%=isDownloadStructure%>|<%=isDownloadStructure%>";
	top.opener.getAppletObject().callCommandHandler(integrationName, "resetCheckoutPage", isDownloadStructure);
	frameheaderDisplay.document.location	= "MCADCheckoutHeader.jsp?<%=queryString%>";
	framebottomDisplay.document.location	= "MCADCheckoutFooter.jsp?<%=queryString%>";
}

function showFamilyConflictConfirmDialog(integrationName, content)
{
	familyConflictWindowContent = content;
	showIEFModalDialog('MCADFamilyConflictConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
}

function getFamilyConflictWindowContent()
{
	return familyConflictWindowContent;
}

function showCheckoutConfirmDialog(integrationName, content)
{
	confirmWindowContent = content;

	showIEFModalDialog('MCADOverWriteConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
}

function getConfirmWindowContent()
{
	return confirmWindowContent;
}

function showLocalFilesDeleteConfirmationDialog(integrationName, content)
{
	confirmDeleteWindowContent = content;

	showIEFModalDialog('MCADLocalFilesDeleteConfirmFS.jsp?integrationName=' + integrationName, 400, 400);
}

function getConfirmDeleteWindowContent()
{
	return confirmDeleteWindowContent;
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
		integrationFrame.activeDirectoryChooserControl = null;

		var integrationName = treeControlObject.getIntegrationName();
		top.opener.getAppletObject().callCommandHandler(integrationName, "cancelOperation", true);
	}
	integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
}

function selectChildrenValidation(selectChildrenField)
{
    var isSelectAllChildren			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked;
    var isSelectFirstLevelChildren	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked;

    if(selectChildrenField.name == "selectFirstLevelChildrenOnCheckout" && isSelectAllChildren && isSelectFirstLevelChildren)
    {
        selectChildrenField.checked = false;
	//XSSOK
        alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectAllChildrenAlreadyChecked")%>");
    }

    if(selectChildrenField.name == "selectAllChildrenOnCheckout" && isSelectAllChildren && isSelectFirstLevelChildren)
    {
        selectChildrenField.checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.SelectFirstLevelChildrenAlreadyChecked")%>");
	}
}
//Event handlers End

//Support Methods Start
function getExpandArguments()
{
	var selectAllChildrenOnCheckout			= framebottomDisplay.document.forms["configOptions"].selectAllChildrenOnCheckout.checked?"true":"false";
	var selectFirstLevelChildrenOnCheckout	= framebottomDisplay.document.forms["configOptions"].selectFirstLevelChildrenOnCheckout.checked?"true":"false";

	var pageOptions		= selectAllChildrenOnCheckout + "|" + selectFirstLevelChildrenOnCheckout;
	var activeTabName	= treeControlObject.getActiveTabName(" ");

	if(activeTabName == "Checkout" || activeTabName == "")
	{
		var expansionLevel	= frameheaderDisplay.document.forms["views"].showLevel.value;
		//XSSOK
		if(expansionLevel != "<%= integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>" && expansionLevel.toUpperCase() != "ALL")
		{
                        //XSSOK
			var isValid = validateExpandLevel(expansionLevel, "<%=defaultExpandLevel %>", "views", "<%= integSessionData.getStringResource("mcadIntegration.Server.Message.OnlyAllOrNumericValueAllowed")%>");
			if(isValid == true)
				pageOptions = pageOptions + "|" + expansionLevel;
		}
		else
		{
			expansionLevel= "ALL";
			pageOptions = pageOptions + "|" + expansionLevel;
		}
	}
	else
	{
		pageOptions = pageOptions + "|" + "1";
	}

	return pageOptions;
}

function checkForRevConflict()
{
        //XSSOK
	if("<%=revConflictMessage%>" != "null" && "<%=revConflictMessage%>" != "")
	{
		showCheckoutMessageForRevConf("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),revConflictMessage)%>");
	}
        //XSSOK
	else if("<%=confirmMessage%>" != "null" && "<%=confirmMessage%>" != "")
	{
                //XSSOK
		if("<%=confirmMessage%>" == "true")
			showCheckoutMessageForConf(top.opener.getConfirmMessage());
		else
			showCheckoutMessage("<%=XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),confirmMessage)%>");
		isConfirmMessageShown = "true";
	}
}

//Support Methods End
</script>

</head>
<!--XSSOK-->
<title><%=operationTitle%></title>
<frameset rows="80,*,130,0" frameborder="no" framespacing="0" onUnload="javascript:closeWindow()" onLoad="javascript:fillCheckBoxSelectionDataTable()">

	<frame name="headerDisplay" src="MCADCheckoutHeader.jsp?<%= XSSUtil.encodeForHTML(context, queryString) %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" onresize="parent.reloadTable(this)" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="MCADCheckoutFooter.jsp?<%=XSSUtil.encodeForHTML(context, queryString)  %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />
</frameset>
</html>

<%--  MCADFinalizationFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData   = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	matrix.db.Context Context				  = integSessionData.getClonedContext(session);
	
	String queryString = emxGetEncodedQueryString(Context,request);
	String objectIds						      = Request.getParameter(request,"objectIds");
	//String isLateralNavigationAllowed		      = Request.getParameter(request, "isLateralNavigationAllowed");
	String isLateralNavigationAllowed		      = "True";

	String integrationName					      = Request.getParameter(request,"integrationName");
	MCADLocalConfigObject localConfigObject	      = integSessionData.getLocalConfigObject();
	String defaultExpandLevel				      = localConfigObject.getDefaultExpandLevel(integrationName);
	String promoteMessageHeader					  = "mcadIntegration.Server.Title.Promote";

	String operationTitle	= integSessionData.getStringResource(promoteMessageHeader);
	
	String promoteChangeStructure	 = "mcadIntegration.Server.Feature.PromoteChangeStructure";
	String promoteModifiedNodes		 = "mcadIntegration.Server.Feature.PromoteModifiedNodes";
	String promoteCadTool			 = "mcadIntegration.Server.Feature.Promotecadtool";
	String promoteConfirm			 = "mcadIntegration.Server.Feature.Promoteconfirm";
	String sKeyNotAllowedInAsSavedView			 = "mcadIntegration.Server.Message.OperationNotAllowedForAsSavedView";
	
	String promoteChangeStructureMsg = integSessionData.getStringResource(promoteChangeStructure);
	String promoteModifiedNodesMsg	 = integSessionData.getStringResource(promoteModifiedNodes);
	String promoteCadToolMsg		 = integSessionData.getStringResource(promoteCadTool);
	String promoteConfirmMsg		 = integSessionData.getStringResource(promoteConfirm);
	String sMsgNotAllowedInAsSavedView		 = integSessionData.getStringResource(sKeyNotAllowedInAsSavedView);

	MCADMxUtil util								  = new MCADMxUtil(Context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String allowPromoteDrawingAttrName			  = util.getActualNameForAEFData(Context, "attribute_IEF-Pref-IEF-AllowPromoteFloatingDrawing");
	String allowPromoteDrawingLCOAttrName			  = util.getActualNameForAEFData(Context, "attribute_IEF-AllowPromoteFloatingDrawing");
	boolean allowPromoteOnDrawing				  = false;

    MCADGlobalConfigObject globalConfigObject	  = integSessionData.getGlobalConfigObject(integrationName, Context);
	if(globalConfigObject.getPreferenceType(allowPromoteDrawingAttrName).equals("ENFORCED"))
	{		
		allowPromoteOnDrawing = globalConfigObject.getPreferenceValue(allowPromoteDrawingAttrName).equalsIgnoreCase("TRUE") ? true : false;
	}
	else
	{
		allowPromoteOnDrawing = localConfigObject.isAllowPromoteOnFloatDrawing(integrationName);
	}
	
%>


<html>
<head>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="javascript" >

<%@include file = "IEFTreeTableInclude.inc"%>

var isOperationComplete = false;
var messageToShow		= "";
var isResetPage			= false;
var isVirtualCreated		= false;

var unappliedViewSelectionPresent = false;

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
function changeTabSelection(activeTabName)
{
    frames['bottomDisplay'].setShowMessageOnFooter(false);

	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
        var footerPage	= treeControlObject.getFooterPage(activeTabName);

	var footerOptions       = getPageOptions();
	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.setFooterOptions(footerOptions);

    var pframeheaderDisplay	= findFrame(parent,"headerDisplay");
	var pframetableDisplay	= findFrame(parent,"tableDisplay");
	var pframebottomDisplay	= findFrame(parent,"bottomDisplay");

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
		treeControlObject.refresh();
		response = replaceAll(response, '<br>', '\n')
		alert(response);
	}
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

	var selectedNodeDetails = nodeId + "|" + field.name + "|" + field.type + "|" + fieldValue + "|" + "<%=XSSUtil.encodeForJavaScript(Context,isLateralNavigationAllowed)%>";

	treeControlObject.changeNodeCellValue(selectedNodeDetails);
}

function selectedChangeViewProgram(showIcon)
{
	if(showIcon)
	{
		frameheaderDisplay.document.imgProgress.src = "images/iconTabCheckin.gif";
		unappliedViewSelectionPresent = true;
	}
	else
	{
		frameheaderDisplay.document.imgProgress.src = "images/utilSpace.gif";
		unappliedViewSelectionPresent = false;
	}
}

function cannotShowFinalizationPage(responseString)
{
	var integrationName = treeControlObject.getIntegrationName();
	var encodedString	= hexEncode(integrationName,responseString);


	isOperationComplete = true;
	frameheaderDisplay.document.forms['UpdatePage'].details.value=encodedString;
	frameheaderDisplay.document.forms['UpdatePage'].submit();
}

function showSignatureChooser(obejctId, fromState, toState, acceptLanguage, grayedOut)
{
	if(grayedOut !="true" && grayedOut!="TRUE")
	{
		var queryString = "objectId=" + obejctId + "&fromState=" + fromState + "&toState=" + toState +  "&isInCurrentState=true&Accept-Language=" + acceptLanguage;

		showIEFModalDialog("../iefdesigncenter/emxInfoObjectLifecycleSignatures.jsp?" + queryString, 700, 300, true);
	}
}

function finalizationSelected()
{
	var activeTabName		= treeControlObject.getActiveTabName(" ");
	
	if(activeTabName == "Promotion" || activeTabName == "")
	{
		var refTopFirstLVValue = top.parent.frames[0].document.forms['views'].lateralViewsComboControl.value;

		if(refTopFirstLVValue == "<%=MCADAppletServletProtocol.VIEW_AsSaved%>")
		{
			messageToShow = "<%=sMsgNotAllowedInAsSavedView%>";
			var messageDialogURL	= "DSCErrorMessageDialogFS.jsp?messageHeader=<%=promoteMessageHeader%>&headerImage=../common/images/iconStatusError.gif&showExportIcon=false&closeParent=true";
			showIEFModalDialog(messageDialogURL, 350, 300);
			return;
		}
	}

	if(unappliedViewSelectionPresent )
	{
		<%
			String promoteSelectedWithoutViewApplication = integSessionData.getStringResource("mcadIntegration.Server.Heading.CheckoutSelectedWithoutViewApplication");
		%>
                        //XSSOK
			if(!confirm("<%=promoteSelectedWithoutViewApplication%>"))
				return;
	}

	var selectAllChildren	= framebottomDisplay.document.forms["configOptions"].selectAllChildren.checked;

	if(isVirtualCreated == true)
	{
		selectAllChildren = selectAllChildren +"|"+"createvirtual";		
	}
        //XSSOK
        selectAllChildren		= selectAllChildren + "|" + "<%=allowPromoteOnDrawing%>"; 
	var submitStatus		= treeControlObject.submitPage(selectAllChildren);
	if(submitStatus != TRUE && submitStatus != FALSE && submitStatus != "")
	{
		if(submitStatus.indexOf("virtualstructcreated") > -1 && isVirtualCreated == false)
		{
			var stringArray		= submitStatus.split("|");
			var operation		= stringArray[1];

			isVirtualCreated = true;

			treeControlObject.refresh();
			//XSSOK
			messageToShow			= "<%=promoteChangeStructureMsg%>"+"<BR><BR>"+"<%=promoteModifiedNodesMsg%>" +":-<BR> "+operation;
			//XSSOK
			var allowPromote = "<%=allowPromoteOnDrawing%>";			
			if(allowPromote == FALSE )
			{
                                //XSSOK
				messageToShow = messageToShow +"<BR>"+ "<%=promoteCadToolMsg%>";
				//XSSOK
				var messageDialogURL	= "DSCErrorMessageDialogFS.jsp?messageHeader=<%=promoteMessageHeader%>&headerImage=../common/images/iconStatusError.gif&showExportIcon=true&closeParent=true";
				showIEFModalDialog(messageDialogURL, 350, 300);
				return;
			}
			else
			{
                                //XSSOK
				messageToShow = messageToShow +"<BR>"+"<%=promoteCadToolMsg%>"+" <BR>"+"<%=promoteConfirmMsg%>";
				//XSSOK
				var messageDialogURL	= "DSCErrorMessageDialogFS.jsp?messageHeader=<%=promoteMessageHeader%>&headerImage=../common/images/iconStatusAlert.gif&showExportIcon=true";
				showIEFModalDialog(messageDialogURL, 450, 400);
				return;
			}
		}
		else if(submitStatus.indexOf("virtualstructcreated") > -1 && isVirtualCreated == true) 
		{
			treeControlObject.refresh();			
			var integrationFrame	= getIntegrationFrame(this);
			integrationFrame.removeFooterOptions();
		}
		else 
		{
			treeControlObject.refresh();
			messageToShow			= submitStatus;
			
			if(submitStatus.indexOf("showMessageOnFooter") > -1)
			{
				var stringArrayMsg		= messageToShow.split("|");
				messageToShow		= stringArrayMsg[0];
				frames['bottomDisplay'].setShowMessageOnFooter("true");
				
			}
			//XSSOK
			var messageDialogURL	= "DSCErrorMessageDialogFS.jsp?messageHeader=<%=promoteMessageHeader%>&headerImage=images/iconError.gif&showExportIcon=true";
			showIEFModalDialog(messageDialogURL, 350, 300);
		}
	}

	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();
}

function updateTreeTableWindow(operationStatusMessage)
{
	operationStatusMessage = operationStatusMessage + "";
	if(operationStatusMessage.indexOf("true") > -1 || operationStatusMessage.indexOf("false") > -1)
	{
                //XSSOK
		var separator			= "<%=MCADAppletServletProtocol.HEXA_DELIT%>";
		var arrayOfStrings		= operationStatusMessage.split(separator);
		var operation			= arrayOfStrings[1];

		if(operationStatusMessage.indexOf("false") > -1)
		{
<%
			String messageHeader = "mcadIntegration.Server.Message.PromoteOperationFailed";
%>
			messageToShow	= arrayOfStrings[3];
			messageToShow	= messageToShow.substring(messageToShow.indexOf("<table"), messageToShow.length-1);

			if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
				top.modalDialog.contentWindow.close();

			if(operationStatusMessage.indexOf("showMessageOnFooter") > -1)
				frames['bottomDisplay'].setShowMessageOnFooter("true");
			//XSSOK
			var messageDialogURL = "DSCErrorMessageDialogFS.jsp?messageHeader=<%=messageHeader%>&headerImage=images/iconError.gif&showExportIcon=true";
			showIEFModalDialog(messageDialogURL, 500, 400);
		}
	}
	else
	{
		alert(operationStatusMessage);
	}
}

function syncFrames(nodeID) 
{
	var extraArguments = getExpandArguments();
	if(extraArguments != "")
		nodeID = nodeID + "|" + extraArguments;

	treeControlObject.storeFrameCoordinates();
    	
	var response = appletObject.callTreeTableUIObject("toggleExpand", nodeID);

	var respString = response.split("|");

	if(respString[1] == "true")
		frames['bottomDisplay'].setShowMessageOnFooter(respString[1]);

	treeControlObject.refresh();

	return;
}

function changeSelectionForAll(field)
{
	var isChecked	= field.checked;
	var response	= treeControlObject.changeSelectionForAll(isChecked);
	frametableDisplay.document.forms["nodeSelectionHeader"].changeSelectionForAll.checked = isChecked;
}

function getPageOptions()
{
    var selectAllChildrenOnCheckin = framebottomDisplay.document.forms["configOptions"].selectAllChildren.checked?"true":"false";

    var pageOptions = new Array();

	pageOptions[0] = selectAllChildrenOnCheckin;

    return pageOptions;
}

function startProgressBar()
{
    framebottomDisplay.document.progress.src = "images/utilProgress.gif";
}

function stopProgressBar()
{
    framebottomDisplay.document.progress.src = "images/utilSpace.gif";
}

function finalizationCancelled()
{
    var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();

    closeWindow();
}

function showAlert(message, closeWindow)
{
	if(closeWindow == "true")
	{
		stopProgressBar();
	}

	alert(message);

	if(closeWindow == "true")
	{
		window.close();
	}
}

function applyViewsSelected(applyViewsOnSelected)
{
	var lateralViewComboControl	= frameheaderDisplay.document.forms["views"].lateralViewsComboControl;
	var lateralViewName			= "<%=MCADAppletServletProtocol.VIEW_AS_BUILT%>";

	<%
		if (isLateralNavigationAllowed.equalsIgnoreCase("TRUE"))
		{
	%>
			var lateralViewName	= lateralViewComboControl.options[lateralViewComboControl.selectedIndex].value;
	<%
		}
	%>

	var verticalViewComboControl	= frameheaderDisplay.document.forms["views"].verticalViewsComboControl;
	var verticalViewName			= verticalViewComboControl.options[verticalViewComboControl.selectedIndex].value;

	var selectionDetails = applyViewsOnSelected + "|" + verticalViewName + "|" + lateralViewName + "|" + "<%=XSSUtil.encodeForJavaScript(Context,isLateralNavigationAllowed)%>";

	var status = treeControlObject.selectedViews(selectionDetails);

	var respString		= status.split("|");

	var res = status.search("showMessageOnFooter");

	if(res != -1)
	{
		var respString		= status.split("|");
		var showMsgOnFooter = respString[1].substring(respString[1].indexOf("=")+1);

		frames['bottomDisplay'].setShowMessageOnFooter(showMsgOnFooter);

		selectedChangeViewProgram(false);

		treeControlObject.refresh();
	}
	else
	{
		if(respString[0] != TRUE && respString[0] != FALSE)
	{
			alert(respString[0]);
	}
	else
	{
		selectedChangeViewProgram(false);
	}
}
}

function resetToAsStored()
{
	isResetPage = true;
	var integrationName = treeControlObject.getIntegrationName();
	top.opener.getAppletObject().callCommandHandler(integrationName, "resetFinalizationPage", "");
}

function closeWindow()
{
	if(!isResetPage)
	{
		if(!isOperationComplete && cancelOperation)
		{
			isOperationComplete = true;

			var integrationName = treeControlObject.getIntegrationName();
			top.opener.getAppletObject().callCommandHandler(integrationName, "cancelFinalizeOperation", true);
		}

		isResetPage = false;
	}

	var integrationFrame	= getIntegrationFrame(this);
	integrationFrame.removeFooterOptions();

	this.closeProgressBar();
}

function showMessagePage(messageContent)
{
	var messagePageURL = "MCADUpdateWithMessage.jsp?details=" + messageContent + "&refresh=false&instanceRefresh=false";

	showIEFModalDialog(messagePageURL, 500, 400);
}

var refreshFrameParent;

function setRefreshFrameForStrctureBrowser()
{
	var integrationFrame = getIntegrationFrame(this);

	var refreshFrame = refreshFrameParent.findFrame(refreshFrameParent, "structure_browser");

	integrationFrame.setActiveRefreshFrame(refreshFrame);
}

function refreshParentFrame(arguments)
{
	isResetPage = true;
	var integrationFrame = getIntegrationFrame(this);
	if(integrationFrame != null)
	{
		var refreshFrame = integrationFrame.getActiveRefreshFrame();
		if(refreshFrame != null)
		{
			var objForm		= refreshFrame.document.forms['emxTableForm'];

			var commandName	= (objForm && objForm.commandName) ? objForm.commandName.value : "";

			if (refreshFrame && commandName != "Navigate") // not refreshing navigate page
			{
				var refreshFrameURL	= refreshFrame.location.href;
				if(refreshFrame.name == "content")
				{
					refreshFrame.location.href = refreshFrameURL; //using refreshFrame.reload() causes a bug on FireFox
				}
				else if(refreshFrame.name == "structure_browser") //refreshing the Full Search
				{
					var searchHiddenForm	= null;
					var searchForm			= null;

					if(null != refreshFrame.parent && typeof refreshFrame.parent != "undefined")
					{
						searchHiddenForm	= refreshFrame.parent.document.forms['full_search_hidden'];
						searchForm			= refreshFrame.parent.document.forms['full_search'];
					}

					if(null != searchHiddenForm && typeof searchHiddenForm != "undefined" && null != searchHiddenForm.action && searchHiddenForm.action != "")
					{
						searchHiddenForm.submit();
						refreshFrameParent = refreshFrame.parent;
						window.setTimeout("setRefreshFrameForStrctureBrowser( );", 1000);
					}
					else if(null != searchForm && typeof searchForm != "undefined" && null != searchForm.action && searchForm.action != "")
					{
						searchForm.submit();
					}
					else
						refreshFrame.location.href = refreshFrame.location.href;
				}
				else
				{
					refreshFrame.location.reload();
				}
			}
		}
		else
		{
			targetFrame =top.opener.top.findFrame(top.opener.top,"detailsDisplay");

			if(targetFrame)
			{
				targetFrame.location.href = targetFrame.location.href;
			}
		}
	}
}

//Support Methods Start
function getExpandArguments()
{

	var selectChildNodes	= framebottomDisplay.document.forms["configOptions"].selectAllChildren.checked;
	var pageOptions			= selectChildNodes;
	var activeTabName		= treeControlObject.getActiveTabName(" ");

	if(activeTabName == "Promotion" || activeTabName == "")
	{
		var expansionLevel	= frameheaderDisplay.document.forms["views"].showLevel.value;
		//XSSOK
		if(expansionLevel != "<%=integSessionData.getStringResource("mcadIntegration.Server.FieldName.All")%>")
		{
		    //XSSOK
			var isValid = validateExpandLevel(expansionLevel, "<%=defaultExpandLevel %>", "views", "<%= integSessionData.getStringResource("mcadIntegration.Server.Message.OnlyAllOrNumericValueAllowed")%>");
			if(isValid == true)
				pageOptions = pageOptions + "|" + expansionLevel;
		}
		else
		{
			pageOptions = pageOptions + "|" + "ALL";;
		}
	}
	else
	{
		pageOptions = pageOptions + "|" + "1";
	}

	return pageOptions;
}
//Support Methods End
</script>
</head>
<!--XSSOK-->
<title><%=operationTitle%></title>

<%-- IR-601026-As we resize the whole window and not the particular frame, onresize is shifted to <frameset> --%>
<frameset rows="80,*,80,0" frameborder="no" framespacing="0" onLoad="javascript:init()" onBeforeUnload="javascript:closeWindow()" onresize="parent.reloadTable(this)">

	<frame name="headerDisplay" src="MCADFinalizationHeader.jsp?<%= XSSUtil.encodeForHTML(Context, queryString) %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="tableDisplay" src="IEFTreeTableContent.jsp" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="MCADFinalizationFooter.jsp?<%=XSSUtil.encodeForHTML(Context, queryString)  %>" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="listHidden" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="0" frameborder="0" scrolling="no" />
</frameset>
</html>

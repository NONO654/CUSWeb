<%--  IEFPreferencesFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context				= integSessionData.getClonedContext(session);
	String integrationName =Request.getParameter(request,"integrationName");

boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);   

	String firstIntegName = "";

	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
	Hashtable integrationNameGCONameMap     = localConfigObject.getIntegrationNameGCONameMappingForAll();

	Enumeration integrationNameElements     = integrationNameGCONameMap.keys();
    while(integrationNameElements.hasMoreElements())
	{
		//Get the first Integration name element form the Hashtable integrationNameGCONameMap
		firstIntegName = (String)integrationNameElements.nextElement();

		break;
	}

	String operationTitle	= integSessionData.getStringResource("mcadIntegration.Server.Title.Preferences");
%>

<html>
<head>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="./scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">

<%@include file = "IEFTreeTableInclude.inc"%>

var folderDetails = "";
//Event Handlers End

var frameheaderDisplay = null;
var frametableDisplay = null;
var framebottomDisplay = null;
var prevActiveTab=null;
var integname="<%= XSSUtil.encodeForJavaScript(context,integrationName) %>"
if(integname == "")
{
prevActiveTab = "Global";
}
else
{
prevActiveTab = integname;
}
var isGlobalTabFieldValueChanged ="false";
var isOtherTabFieldValueChanged ="false";

function init()
{	
	frameheaderDisplay = findFrame(this,"headerDisplay");
	frametableDisplay = findFrame(this,"tableDisplay");
	framebottomDisplay = findFrame(this,"bottomDisplay");
}

function selectAllDerivedOutputs(activeTabName, field)
{
	var headerFieldName = field.name;
	var headerFieldValue = field.checked;

	var objForm	= frametableDisplay.document.forms["preferenceForm"];
	for (var i = 0; i < objForm.elements.length; i++)
	{
		var elementName	= objForm.elements[i].name;

		if(!objForm.elements[i].disabled)
		{
			var nameSuffix		= elementName.split("_")[1];

			if(headerFieldName.indexOf(nameSuffix) != -1)
			{
				objForm.elements[i].checked = headerFieldValue;

				if(nameSuffix == "auto")
				{
						objForm.elements[i+1].checked = false;
						objForm.elements[i+2].checked = false;
				}
				else if(nameSuffix == "manual")
				{
						objForm.elements[i-1].checked	 = false;
						objForm.elements[i+1].checked = false;
				}
				else if(nameSuffix == "background")
				{
						objForm.elements[i-2].checked = false;
						objForm.elements[i-1].checked = false;
				}
			}
		}
	}

	if(headerFieldValue == true)
	{
		if(headerFieldName == "autoAll")
		{
			objForm.elements["manualAll"].checked			= false;
			objForm.elements["backgroundAll"].checked	= false;
		}
		else if(headerFieldName == "manualAll")
		{
			objForm.elements["autoAll"].checked				= false;
			objForm.elements["backgroundAll"].checked	= false;
		}
		else if(headerFieldName == "backgroundAll")
		{
			objForm.elements["autoAll"].checked		= false;
			objForm.elements["manualAll"].checked	= false;
		}
	}

	var selectedFormFieldDetails		= activeTabName + "|" + headerFieldName + "|" + headerFieldValue;
	var response = "";
	if('<%=bEnableAppletFreeUI%>' == "true")
	{
		response						= callTreeTableUIObject("selectAllDerivedOutputs", selectedFormFieldDetails);
	}
	else
	{
		response						= appletObject.callTreeTableUIObject("selectAllDerivedOutputs", selectedFormFieldDetails);
	}
	if(response == "CantBackGroundDerivedWhileBulkLoading")
	{
                //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.BackgroungwithDerivedOutput")%>");

		for (var i = 0; i < objForm.elements.length; i++)
		{
			var elementName	= objForm.elements[i].name;
			if(!objForm.elements[i].disabled)
			{
				var nameSuffix		= elementName.split("_")[1];

				if(headerFieldName.indexOf(nameSuffix) != -1)
				{
					objForm.elements[i].checked = headerFieldValue;
					if(nameSuffix == "background")
					{
						objForm.elements[i].checked = false;
						objForm.elements["backgroundAll"].checked	= false;
					}
				}
			}
		}
	}
}

function changeFormFieldValue(activeTabName, formGroupName, formFieldId, formField)
{

	var fieldValue = "";

	if(activeTabName == "Global")
		isGlobalTabFieldValueChanged = "true";
	else
		isOtherTabFieldValueChanged = "true";

	if(formField.type.toLowerCase() == "checkbox" || formField.type.toLowerCase() == "radio")
    {
		fieldValue = formField.checked;
    }
	else if(formField.type.toLowerCase() == "select-one" || formField.type.toLowerCase() == "combobox")
    {
		fieldValue = formField.options[formField.selectedIndex].value;
    }
	else if(formField.type.toLowerCase() == "text" || formField.type.toLowerCase() == "editbox" || formField.type.toLowerCase() == "hidden")
	{
		fieldValue = formField.value;
	}

	var selectedFormFieldDetails		= activeTabName + "|" + formGroupName + "|" + formFieldId + "|" + fieldValue;

	var response						= treeControlObject.changeFormFieldValue(selectedFormFieldDetails);
	if(response == "CantDeleteFilesWhileRetainingLock")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileRetainingLock")%>");
	}
	else if(response == "CantRetainLockWhileDeletingFiles")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantRetainLockWhileDeletingFiles")%>");
	}
	else if(response == "CannotSelectOnlyFirstLevelChildrenWithSelectAllChildrenEnabled")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotSelectOnlyFirstLevelChildrenWithSelectAllChildrenEnabled")%>");
	}
	else if(response == "CannotSelectAllChildrenWithSelectFirstLevelChildrenEnabled")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CannotSelectAllChildrenWithSelectFirstLevelChildrenEnabled")%>");
	}
	else if(response == "CantDeleteFilesWhileBackGroundCheckin")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileBackGroundCheckin")%>");
	}
	else if(response == "CantBackGroundCheckinWhileDeleteFiles")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantBackGroundCheckinWhileDeleteFiles")%>");
	}
	else if(response == "CantDeleteFilesWhileRetainingLockAndBackGroundCheckin")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantDeleteFilesWhileRetainingLockAndBackGroundCheckin")%>");
	}
	else if(response == "CantRetainLockWhileBulkloading")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantRetainLockWhileBulkloading")%>");
	}
	else if(response == "CantBulkloadWhileRetainLock")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.CantBulkloadWhileRetainLock")%>");
	}
	else if(response == "CantBackGroundDerivedWhileBulkLoading")
	{
		frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].checked = false;
		//XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.BackgroungwithDerivedOutput")%>");
	}
	else if(formGroupName == "DerivedOutput")
	{
		var objForm	= frametableDisplay.document.forms["preferenceForm"];
		if(formField.checked)
		{
			if((formFieldId.split("_")[1]) == ("auto"))
			{
				objForm.elements[formFieldId.split("_")[0]+"_manual"].checked = false;
				objForm.elements[formFieldId.split("_")[0]+"_background"].checked = false;
			}
			else if((formFieldId.split("_")[1]) == ("manual"))
			{
				objForm.elements[formFieldId.split("_")[0]+"_auto"].checked = false;
				objForm.elements[formFieldId.split("_")[0]+"_background"].checked = false;
			}
			else if((formFieldId.split("_")[1]) == ("background"))
			{
				objForm.elements[formFieldId.split("_")[0]+"_auto"].checked = false;
				objForm.elements[formFieldId.split("_")[0]+"_manual"].checked = false;
			}
		}

		if(response == "auto")
			objForm.elements["autoAll"].checked				= true;
		else if(response == "manual")
			objForm.elements["manualAll"].checked			= true;
		else if(response == "background")
			objForm.elements["backgroundAll"].checked	= true;
		else
		{
			objForm.elements["autoAll"].checked				= false;
			objForm.elements["manualAll"].checked			= false;
			objForm.elements["backgroundAll"].checked	= false;
		}
	}
}

function showDirectoryChooser(integrationName, formGroupName, formFieldId)
{
	var eventHandlerArguments = integrationName + "|" + formGroupName + "|" + formFieldId;
	var checkoutDirectoryField = frametableDisplay.document.forms["preferenceForm"].elements[formFieldId];	
	integrationFrame.showDirectoryChooser(integrationName, checkoutDirectoryField, eventHandlerArguments);
	isOtherTabFieldValueChanged = "true";
}

function showFolderChooser(integrationName, formGroupName, formFieldId)
{
	folderDetails = integrationName + "|" + formGroupName + "|" + formFieldId;
	var url = "MCADFolderSearchDialogFS.jsp" +"?operationTitle=<%=XSSUtil.encodeForURL(context,operationTitle)%>" + "&integrationName=" + integrationName;
	showIEFModalDialog(url, 430, 400, true);
	isOtherTabFieldValueChanged = "true";
}

function focusFolder()
{
	var formFieldDetails = folderDetails.split("|");
	frametableDisplay.document.forms['preferenceForm'].elements[formFieldDetails[2] + '_Display'].focus();
}

function doGlobalSelect(objectId, objectName, applyToChild)
{
	var fieldValue = objectId + "@" + objectName;
	var selectedFormFieldDetails = folderDetails + "|" + fieldValue;
	treeControlObject.changeFormFieldValue(selectedFormFieldDetails);

	setTimeout("focusFolder()",500);
}

function clearSelectedFolder(activeTabName, formGroupName, formFieldId, fieldValue)
{
	frametableDisplay.document.forms["preferenceForm"].elements[formFieldId+"_Display"].value = "";
	frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].value = "";
	var selectedFormFieldDetails = activeTabName + "|" + formGroupName + "|" + formFieldId + "|" +"";
	treeControlObject.changeFormFieldValue(selectedFormFieldDetails);
	frametableDisplay.document.forms["preferenceForm"].elements[formFieldId + "_Display"].focus();
        isOtherTabFieldValueChanged ="true";
}

function clearSelectedDirectory(activeTabName, formGroupName, formFieldId, fieldValue)
{
	frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].value = "";
	var selectedFormFieldDetails = activeTabName + "|" + formGroupName + "|" + formFieldId + "|" +"";
	treeControlObject.changeFormFieldValue(selectedFormFieldDetails);	
	frametableDisplay.document.forms["preferenceForm"].elements[formFieldId].focus();
}

function manageCues()
{
	var heading = "mcadIntegration.Server.Heading.Cues";
	//XSSOK
	var cuesURL = "IEFConfigUIDialogFS.jsp?pageHeading="+ heading + "&contentPage=IEFCuesListContent.jsp&firstIntegName=<%= firstIntegName%>&createIcon=buttonCreateCue.gif&modifyIcon=buttonModifyCue.gif&deleteIcon=buttonDeleteCue.gif&helpMarker=emxhelpdsccreatecue";

	showIEFModalDialog(cuesURL, 400, 450, "")
        isGlobalTabFieldValueChanged ="true";
}

function manageWSTables()
{
	var heading = "mcadIntegration.Server.Heading.WorkSpaceTables";
	//XSSOK
	var tablesURL = "IEFConfigUIDialogFS.jsp?pageHeading=" + heading + "&contentPage=IEFWSTableListContent.jsp&firstIntegName=<%= firstIntegName%>&onBeforeUnload=window.frames['contentFrame'].refreshPreferencePage()&createIcon=buttonCreateTable.gif&modifyIcon=buttonModifyTable.gif&deleteIcon=buttonDeleteTable.gif&helpMarker=emxhelpdsccreatewksptable";

	showIEFModalDialog(tablesURL, 400, 450, "")
	isGlobalTabFieldValueChanged ="true";
}

function showPrefModalDialog(fieldid , fieldValue)
{
	showIEFModalDialog(fieldValue, 450, 450, "");
	isOtherTabFieldValueChanged ="true";
}

function selectGCO(fieldId,integrationName, gcoValue)
{
	isGlobalTabFieldValueChanged = "true";
	var strFeatures = "width=300,height=350,resizable=yes";
	var chooserURL  = "IEFGCOChooserFS.jsp?integrationName=" + integrationName + "&gcoDefault=" + gcoValue + "&fieldId=" + fieldId  ;

	//window.open(chooserURL, "GCOChooser", strFeatures);
	showIEFModalDialog(chooserURL, 400, 450, "");
}

function setSelectedGCOName(fieldId, gcoName)
{
	var selectedFormFieldDetails = "Global" + "|" + "SelectGCO" + "|" + fieldId + "|" + gcoName;
	treeControlObject.changeFormFieldValue(selectedFormFieldDetails);
	treeControlObject.refresh();
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

function startProgressBar()
{
    frametableDisplay.document.progress.src = "./images/utilProgress.gif";
}

function stopProgressBar()
{
    frametableDisplay.document.progress.src = "./images/utilSpace.gif";
}

function changeTabSelection(activeTabName)
{
	var headerPage	= treeControlObject.getHeaderPage(activeTabName);
	var contentPage = treeControlObject.getContentPage(activeTabName);
    var footerPage	= treeControlObject.getFooterPage(activeTabName);
	if('<%=bEnableAppletFreeUI%>' == "true")
	{
		treeControlObject.activeTabName = activeTabName;
	}
	if(activeTabName == prevActiveTab)
		return;

    if(isGlobalTabFieldValueChanged == "true")
	{
                //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.UpdatePreferencesPageAndRelaunch")%>");
		contentPage="IEFPreferencesContent.jsp?activeTabName=Global";
	}

    if(isOtherTabFieldValueChanged == "true")
	{
	    if(activeTabName == "Global")
		{
                  //XSSOK
		  alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.UpdatePreferencesPageAndRelaunch")%>");
	      contentPage="IEFPreferencesContent.jsp?activeTabName="+prevActiveTab;		
		 }
    }
//alert("qtp contentPage "+contentPage);

	frameheaderDisplay.document.location	= headerPage;
	frametableDisplay.document.location		= contentPage;
	framebottomDisplay.document.location	= footerPage;
        prevActiveTab = activeTabName;		
}

function updatePreferences()
{	
	frametableDisplay.focus();
var response = "";
	if('<%=bEnableAppletFreeUI%>' == "true")
	{
		response = callTreeTableUIObject("updatePreferences","");
	}	
	else
	{
		response = appletObject.callTreeTableUIObject("updatePreferences", "");
	}	

	if(response != "TRUE" && response != "true" && response != "FALSE" && response != "false" && response != "")
	{
		alert(response);
	}
	if('<%=bEnableAppletFreeUI%>' == "true")
	{
		closeModalDialog();
	}
}

function updatePreferenceTables()
{
var response = "";
	if('<%=bEnableAppletFreeUI%>' == "true")
	{
		response = callTreeTableUIObject("updatePreferenceTables", "");	
	}
	else
	{
		response = appletObject.callTreeTableUIObject("updatePreferenceTables", "");
	}
        if(response != "true" && response != "false" && response != "")
	{
		alert(response);
	}
}

function closeWindow()
{	

	if('<%=bEnableAppletFreeUI%>' == "true")
	{
		window.close();
	}
	else
	{
		var integrationName = treeControlObject.getIntegrationName();
		top.opener.getAppletObject().callCommandHandler(integrationName, "cancelOperation", true);
	}
}

//Event handlers End
</script>
</head>
<title><xss:encodeForHTML><%=operationTitle%></xss:encodeForHTML></title>
<frameset rows="80,*,80" frameborder="no" framespacing="0" onLoad="javascript:init()" onBeforeUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="IEFPreferencesHeader.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="no">
	<frame name="tableDisplay"  src="IEFPreferencesContent.jsp?activeTabName=<%=XSSUtil.encodeForHTML(context,integrationName)%>" marginheight="3" marginwidth="3" border="0" scrolling="auto">
	<frame name="bottomDisplay" src="IEFPreferencesFooter.jsp" noresize="noresize" marginheight="3" marginwidth="3" border="0" scrolling="auto">
</frameset>
</html>


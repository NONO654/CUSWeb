<%--  IEFUserChooserFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<script src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context context				= integSessionData.getClonedContext(session);
	String sActionURL = "IEFUserChooserContent.jsp?&chkbxTopLevel=checked&chkbxPerson=unchecked&chkbxRole=unchecked&txtFilter=" + MCADUrlUtil.hexEncode("*");

	String selectAGCOName = integSessionData.getStringResource("mcadIntegration.Server.Message.SelectGCOForIntegration");

	String isSolutionBased = String.valueOf(MCADMxUtil.isSolutionBasedEnvironment(integSessionData.getClonedContext(session)));
	if(isSolutionBased == null)
		isSolutionBased = "false";
%>

<html>
<head>
    <link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

<script language="JavaScript">
var userNameTypeMap				= new Array();
var integrationNameGCONameMap	= new Array();
var assignedIntegrationsList	= "";
var userName					= "";
var userType					= "";

var frameheaderDisplay = null;
var frametableDisplay = null;
var framebottomDisplay = null;
var pframeheaderDisplay = null;
var pframetableDisplay = null;
var pframebottomDisplay = null;

function init()
{
	frameheaderDisplay = findFrame(this,"headerDisplay");
	frametableDisplay = findFrame(this,"tableDisplay");
	framebottomDisplay = findFrame(this,"bottomDisplay");

	pframeheaderDisplay = findFrame(parent,"headerDisplay");
	pframetableDisplay = findFrame(parent,"tableDisplay");
	pframebottomDisplay = findFrame(parent,"bottomDisplay");
}

function closeWindow()
{
	window.close();
    return;
}

function showAlert(message, closeWindow)
{
	alert(message);

	if(closeWindow == "true")
		window.close();
}


function setSelectedGCOName(integrationName, gcoName)
{
	frametableDisplay.document.forms['formSelectGCO'].elements[integrationName].value = gcoName;

	//also store it in the array
	setIntegrationNameGCONameMap(integrationName, gcoName);
}

function getAssignedIntegrationNameGCONameList(formObject)
{
	var assignedIntegrationNameGCONameList = "";

	if(assignedIntegrationsList.length > 0)
	{
		var assignedIntegrationsElements = assignedIntegrationsList.split('|');
		for(i = 0; i<assignedIntegrationsElements.length; i++)
		{
			var assignedIntegration = assignedIntegrationsElements[i];
			var assignedGCOName		= integrationNameGCONameMap[assignedIntegration];

			if(assignedIntegration != "")
			{
				if(assignedGCOName == "")
				{
                                        //XSSOK
					alert("<%= selectAGCOName %> '" + assignedIntegration + "'");
					return "false";
				}
				else
					assignedIntegrationNameGCONameList += assignedIntegration + "|" + assignedGCOName + ";";
			}
		}
	}

	return assignedIntegrationNameGCONameList;
}

function addToAssignedIntegrationsList(integrationName)
{
	assignedIntegrationsList = assignedIntegrationsList + "|" + integrationName;
}


function done()
{
        //XSSOK
	var unitSeparator	= "<%=MCADAppletServletProtocol.UNIT_SEPERATOR%>";
	//XSSOK
	var recordSeparator = "<%=MCADAppletServletProtocol.RECORD_SEPERATOR%>";

	var assignedIntegrationNameGCONameList = getAssignedIntegrationNameGCONameList();

	if(assignedIntegrationNameGCONameList == "false")
	{
		return;
	}

	  //XSSOK
	if('<%=isSolutionBased%>' == 'true')
	{
	    userName = getSelectedUserName();
	    userType = userNameTypeMap[userName];
		//check if an user is selected.
		if(userName == "")
		{
                        //XSSOK
			alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectUser")%>");
			return;
		}
	}
	
	var parametersArray = new Array;
	parametersArray["Command"]						= "updateAssignments";
	parametersArray["selectedUser"]					= userName;
	parametersArray["selectedUserType"]				= userType;
	parametersArray["assignedIntegrationsGCONames"]	= assignedIntegrationNameGCONameList;

	var queryString = getQueryString(parametersArray, unitSeparator, recordSeparator);

	var integrationFrame = getIntegrationFrame(this);

	//cannot go ahead if unable to locate integration frame.
	if( integrationFrame != null )
	{
		var response = integrationFrame.getAppletObject().callCommandHandlerSynchronously("", "sendRequestToServerForIntegrationAssignment", queryString);
		response	 = response + "";

		if(response.indexOf("true") > -1 )
		{
			window.close();
		}
		else
		{
			if(response.indexOf("false|") > -1)
			{
				alert(response.substring(6));
			}
			else
			{
				alert(response);
			}
		}
	}
}

function selectGCO(integrationName, gcoValue)
{
	var chooserURL  = "IEFGCOChooserFS.jsp?integrationName=" + integrationName + "&gcoDefault=" + gcoValue;

	showIEFModalDialog(chooserURL, 300, 350);
}

function searchForUsers(txtFilter, chkbxTopLevel, chkbxPerson, chkbxRole)
{
	var sActionURL = "IEFUserChooserContent.jsp?&chkbxTopLevel=" + chkbxTopLevel.value
					+ "&chkbxPerson=" + chkbxPerson.value + "&chkbxRole=" + chkbxRole.value + "&txtFilter="	+ hexEncodeWithoutIntegName(txtFilter.value);

	pframetableDisplay.document.location	= sActionURL;
}

function goBack()
{
	userName = "";
	pframeheaderDisplay.document.location	= "IEFUserChooserHeader.jsp?fromSelectGCOPage=true";
	pframetableDisplay.document.location		= "IEFUserChooserContent.jsp?fromSelectGCOPage=true";
	pframebottomDisplay.document.location	= "IEFUserChooserFooter.jsp";
}

function gotoNextPage()
{
  var chkbxTopLevel	= frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxTopLevel.value;
  var chkbxPerson	= frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxPerson.value;
  var chkbxRole		= frameheaderDisplay.document.forms['peopleSearchOptions'].chkbxRole.value;
  var txtFilter		= frameheaderDisplay.document.forms['peopleSearchOptions'].txtFilter.value;

  userName = getSelectedUserName();
		userType = userNameTypeMap[userName];

	//check if an user is selected.
	if(userName == "")
	{
                //XSSOK
		alert("<%=integSessionData.getStringResource("mcadIntegration.Server.Message.PleaseSelectUser")%>");
	}
	else
	{
		frameheaderDisplay.document.location = "IEFIntegrationAssignmentHeader.jsp?pageIndex=2";
		frametableDisplay.document.location  = "IEFIntegrationAssignmentSelectGCO.jsp?selectedUserType=" + userType + "&selectedUser=" + hexEncodeWithoutIntegName(userName)+"&chkbxTopLevel=" +chkbxTopLevel
					+ "&chkbxPerson=" + chkbxPerson + "&chkbxRole=" + chkbxRole + "&txtFilter="	+ txtFilter;
		framebottomDisplay.document.location = "IEFIntegrationAssignmentFooter.jsp?pageIndex=2";

	}
}

function getSelectedUserName()
{
	var userId = "";
	
	  var formObj	   = pframetableDisplay.document.forms['usersListForm'];
	  var elementsNum  = formObj.elements.length;

	  for(k=0; k<elementsNum; k++)
	  {
		var obj = formObj.elements[k];
		if(obj.checked == true )
		{
			userId = obj.value;
			break;
		}
	  }
	return userId;
}

function setIntegrationNameGCONameMap(integrationName, gcoName)
{
	integrationNameGCONameMap[integrationName] = gcoName;
}

function getIntegrationNameGCONameMap(integrationName)
{

	return integrationNameGCONameMap[integrationName];
}

</script>
</head>

<frameset rows="26%,*,13%" frameborder="no" framespacing="2" onLoad="javascript:init()" onUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="IEFUserChooserHeader.jsp" scrolling=no>
        <frame name="tableDisplay"  src="<%=XSSUtil.encodeForHTML(context, sActionURL)%>" marginheight="3">	
	<frame name="bottomDisplay" src="IEFUserChooserFooter.jsp?isSolutionBased=<%=XSSUtil.encodeForHTML(context, isSolutionBased)%>" scrolling=no >
</frameset>
</html>


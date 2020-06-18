<%--  IEFAttributeChooserFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String formName       = emxGetParameter(request, "formName");
	String formFieldName  = emxGetParameter(request, "fieldName");
%>

<html>
<head>

<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<!--XSSOK-->
<title><%= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.SelectAttribute") %></title>

<script language="JavaScript">

var userNameTypeMap	= new Array();

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

function searchForAttributes(txtFilter, chkbxBasic, chkbxAttribute)
{
	var actionURL = "IEFAttributeChooserContent.jsp?&chkbxBasic=" + chkbxBasic.value
					+ "&chkbxAttribute=" + chkbxAttribute.value + "&txtFilter="	+ txtFilter.value;

	var frametableDisplay = findFrame(parent,"tableDisplay");
	frametableDisplay.document.location	= actionURL;}

function submitForm()
{
	var frametableDisplay = findFrame(this,"tableDisplay");
	var attrib =  getSelectedRadioValue(frametableDisplay.document.forms['attributeListForm'].tableRowId);
	opener.document.<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),formName) %>.<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),formFieldName) %>.value = attrib;
	window.close();
 }

//Returns the array number of the selected radio button or -1 if no button is selected
function getSelectedRadio(buttonGroup)
{
	if (buttonGroup[0])
	{
		//If the button group is an array (one button is not an array)
		for (var i=0; i<buttonGroup.length; i++)
		{
			if (buttonGroup[i].checked)
			{
				return i;
			}
		}
	}
	else
	{
		if(buttonGroup.checked)
		{
			//If the one button is checked, return zero
			return 0;
		}
	}

	//If we get to this point, no radio button is selected
	return -1;
}

//Returns the value of the selected radio button or "" if no button is selected
function getSelectedRadioValue(buttonGroup)
{
	var i = getSelectedRadio(buttonGroup);
	if (i == -1)
	{
		return "";
    }
	else
	{
		if(buttonGroup[i])
		{
			//Make sure the button group is an array (not just one button)
			return buttonGroup[i].value;
		}
		else
		{
			//The button group is just the one button, and it is checked
			return buttonGroup.value;
		}
    }
}

</script>

</head>

<frameset rows="26%,*,13%" frameborder="no" framespacing="2" onUnload="javascript:closeWindow()">
	<frame name="headerDisplay" src="IEFAttributeChooserHeader.jsp" scrolling=no>
	<frame name="tableDisplay"  src= "IEFAttributeChooserContent.jsp?chkbxBasic=checked&chkbxAttribute=unchecked&txtFilter=*"	 marginheight="3">
	<frame name="bottomDisplay" src="IEFAttributeChooserFooter.jsp" scrolling=no >
</frameset>
</html>

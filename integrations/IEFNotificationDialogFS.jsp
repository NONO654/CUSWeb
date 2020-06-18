<%--  IEFNotificationDialogFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	MCADLocalConfigObject localConfigObject = integSessionData.getLocalConfigObject();
	Hashtable integrationNameGCONameMap		= localConfigObject.getIntegrationNameGCONameMapping();

	String integrationName = "";
	if(integrationNameGCONameMap.size() == 1)
	{
		Enumeration integrationNameElements = integrationNameGCONameMap.keys();

		integrationName = (String)integrationNameElements.nextElement();
	}
%>

<html>
<head>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
//XSSOK
var integrationName = '<%= integrationName %>';
var reminderValue	= "later";
var selectedClose	= false;

function submitForm()
{
	selectedClose = true;
	var frameformDisplay = findFrame(this,"formDisplay");
	var reminderField = frameformDisplay.document.notificationForm.reminder;
	for(var i=0; i<reminderField.length; i++)
	{
		if(reminderField[i].checked)
			reminderValue = reminderField[i].value;
	}

	var integFrame = getIntegrationFrame(this);
	var mxmcadApplet = integFrame.getAppletObject(); 
	if(integrationName == "" && reminderValue == "now")
	{
		var singleIntegrationName = mxmcadApplet.callCommandHandlerSynchronously("", "getIntegrationNameIfSingle", "");
		if(singleIntegrationName == "")
		{
			var preferredIntegration	= mxmcadApplet.callCommandHandlerSynchronously("", "getPreferredIntegrationName", "");

			if(preferredIntegration == null || preferredIntegration == "")
			{
				showIEFModalDialog("IEFIntegrationChooserFS.jsp?eventHandler=setIntegrationName", '450', '350');
			}
			else
			{
				mxmcadApplet.callCommandHandler(preferredIntegration, "setNotificationOption", reminderValue);
			}
		}
		else
		{
			mxmcadApplet.callCommandHandler(singleIntegrationName, "setNotificationOption", reminderValue);
		}
	}
	else
	{
		mxmcadApplet.callCommandHandler(integrationName, "setNotificationOption", reminderValue);
	}
}

function setIntegrationName(selectedIntegrationName)
{
	var integFrame = getIntegrationFrame(this);
	integFrame.getAppletObject().callCommandHandler(selectedIntegrationName, "setNotificationOption", reminderValue);
}

function closeModalDialog()
{
   window.close();
}

function showAlert(message, close)
{
	alert(message);
	if(close == "true")
		closeModalDialog();
}

function onWindowClose()
{
	if(selectedClose == false)
	{
		var integFrame = getIntegrationFrame(this);
		integFrame.getAppletObject().callCommandHandler(integrationName, "setNotificationOption", "later");
	}
}

</script>
</head>

<frameset rows="80,*,80" frameborder="no" framespacing="0" onUnload="javascript:onWindowClose()" onBeforeUnload="javascript:onWindowClose()">
	<frame name="headerDisplay" src="IEFNotificationDialogHeader.jsp" scrolling=no>
	<frame name="formDisplay" src="IEFNotificationDialogContent.jsp" marginheight="3">
	<frame name="bottomDisplay" src="IEFNotificationDialogFooter.jsp" scrolling=no >
</frameset>
</html>

<%--  MCADOverWriteConfirmContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.beans.*" %>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import = "com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String integrationName = Request.getParameter(request,"integrationName");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript">
	var cancelCheckoutConfirm = true;
	
	function formSubmit()
	{
		var retVal = '';		

		var fieldsArray = document.forms['overWriteConfirmForm'].elements;
		for(var i=0; i < fieldsArray.length; i++)
		{
			var field	= fieldsArray[i];
			var busID	= field.name;
			
			if(!field.checked)
				retVal += busID + '|';
		}

		var integrationFrame = getIntegrationFrame(this);	
		integrationFrame.getAppletObject().callCommandHandlerSynchronously("<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName) %>", "userConfirmedOverWrite", retVal);
		
		cancelCheckoutConfirm = false;		
		top.closeWindow();
		
	}

	function formCancel()
	{
		if(cancelCheckoutConfirm)
		{
			cancelCheckoutConfirm = false;

			var integrationFrame = getIntegrationFrame(top);
			integrationFrame.getAppletObject().callCommandHandlerSynchronously("<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName) %>", "cancelOperation", true);
		}
	}

	function selectAll(isChecked)
	{
		var fieldsArray = document.forms['overWriteConfirmForm'].elements;
		for(var i=0; i < fieldsArray.length; i++)
		{
			var field		= fieldsArray[i];
			field.checked	= isChecked;
		}
	}

	function checkSelection(selectedField)
	{
		synchNodesForSelection(selectedField);

		var isChecked	= selectedField.checked;
		var fieldsArray = document.forms['overWriteConfirmForm'].elements;

		if(isChecked)
		{
			var isEverythingSelected = true;
			for(var i=0; i < fieldsArray.length; i++)
			{
				var field = fieldsArray[i];
				if(!field.checked)
				{
					isEverythingSelected = false;
					break;
				}
			}

			if(isEverythingSelected)
			{
				var headerField		= document.forms['overWriteConfirmHeaderForm'].elements[0];
				headerField.checked	= true;
			}
		}
		else
		{
			var headerField		= document.forms['overWriteConfirmHeaderForm'].elements[0];
			headerField.checked	= false;
		}		
	}

	function synchNodesForSelection(selectedField)
	{
		var fieldsArray = document.forms['overWriteConfirmForm'].elements;
		for(var i=0; i < fieldsArray.length; i++)
		{
			var field = fieldsArray[i];

			if(field.name == selectedField.name)
				field.checked = selectedField.checked;
		}
	}
</script>
</head>

<body onUnload="javascirpt:formCancel()"  onBeforeUnload="javascirpt:formCancel()">
	<center>
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<form name="overWriteConfirmHeaderForm">
				<tr><th class="sorted" width="5%">&nbsp;<input type="checkbox" name="headerSelect" onClick="javascript:selectAll(this.checked)"></th><th class="sorted" width="25%"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.FileName")%></th><th class="sorted" width="70%"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.DirName")%></th></tr>
			</form>

			<form name="overWriteConfirmForm" method="post" target="_top" action="javascript:formSubmit()">
				<script language="JavaScript">
					document.write(top.opener.getConfirmWindowContent());
					checkSelection(document.forms['overWriteConfirmForm'].elements[0].checked);
					window.focus();
				</script>
			</form>
		</table>
	</center>
</body>
</html>

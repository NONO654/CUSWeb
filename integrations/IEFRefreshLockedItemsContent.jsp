<%--  IEFRefreshLockedItemsContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String integrationName						=Request.getParameter(request,"integrationName");
%>

<html>
<head>
<style type="text/css">
	body { background-color: white; }
	body, th, td, p, select, option { font-family: Verdana, Arial, Helvetica, Sans-Serif; font-size: 8pt; }

	th { text-align: left; color: white; background-color: #336699; font-size: 8pt;}
</style>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript">

	var cancelRefreshOperation = true;
	var pageContent			   = top.opener.lockeditemsPageContent;
	unescape(pageContent);
	
	function formSubmit()
	{
		var retVal		= '';
		var fieldsArray = document.forms['refreshLockedItemsForm'].elements;

		for(var i=0; i < fieldsArray.length; i++)
		{
			var field				= fieldsArray[i];
			var fileNamePathWithId	= field.name;
			
			if(!field.checked)
				retVal += fileNamePathWithId + '|';
		}

		var integrationFrame = getIntegrationFrame(top);
		retVal = hexEncode("<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName) %>", retVal);

		integrationFrame.getAppletObject().callCommandHandler("<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName)  %>", "refreshLockedItems", retVal);
		
		cancelRefreshOperation = false;
		top.close();
	}

	function formCancel()
	{
		if(cancelRefreshOperation)
		{
			cancelRefreshOperation = false;

			var integrationFrame = getIntegrationFrame(top);
			integrationFrame.getAppletObject().callCommandHandler("<%= XSSUtil.encodeForJavaScript(integSessionData.getClonedContext(session),integrationName)  %>", "cancelOperation", true);
		}
	}

	function selectAll(isChecked)
	{
		var fieldsArray = document.forms['refreshLockedItemsForm'].elements;
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
		var fieldsArray = document.forms['refreshLockedItemsForm'].elements;

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
				var headerField		= document.forms['refreshLockedItemsHeaderForm'].elements[0];
				headerField.checked	= true;
			}
		}
		else
		{
			var headerField		= document.forms['refreshLockedItemsHeaderForm'].elements[0];
			headerField.checked	= false;
		}		
	}

	function synchNodesForSelection(selectedField)
	{
		var fieldsArray = document.forms['refreshLockedItemsForm'].elements;
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
			<form name="refreshLockedItemsHeaderForm">
				<tr><th width="5%"><input type="checkbox" name="headerSelect" onClick="javascript:selectAll(this.checked)"></th><th width="25%"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Name")%></th><th width="70%"><%= integSessionData.getStringResource("mcadIntegration.Server.ColumnName.FileNameWithPath")%></th></tr>
			</form>

			<form name="refreshLockedItemsForm" method="post" target="_top" action="javascript:formSubmit()">

			<script language="JavaScript">		
				document.write(pageContent);
			</script>

			</form>
		</table>
	</center>
</body>

</html>

<%--  MCADFamilyConflictConfirmContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "matrix.db.*, matrix.util.*, com.matrixone.MCADIntegration.utils.*, com.matrixone.MCADIntegration.server.beans.*" %>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String integrationName = request.getParameter("integrationName");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<script language="JavaScript">
	var cancelCheckoutConfirm = true;
	
	function formSubmit()
	{
		var retVal = '';

		var fieldsArray = document.forms['familyConflictConfirmForm'].elements;
		for(var i=0; i < fieldsArray.length; i++)
		{
			var field	= fieldsArray[i];
			var name	= field.name;
			var value	= field.value;

			if(field.checked)
				retVal += value + '|';
		}

		var integrationFrame = getIntegrationFrame(top);
		//XSSOK
		integrationFrame.getAppletObject().callCommandHandler("<%= integrationName %>", "userConfirmedFamilyConflict", retVal);
		
		//cancelCheckoutConfirm = false;
		if(top.opener.treeControlObject)
			top.opener.treeControlObject.refresh();

		top.close();
	}

	function formCancel()
	{
		if(cancelCheckoutConfirm)
		{
			cancelCheckoutConfirm = false;

			var integrationFrame = getIntegrationFrame(top);
			//integrationFrame.getAppletObject().callCommandHandlerSynchronously("<%= integrationName %>", "cancelOperation", true);
		}
	}
</script>
</head>

<body onUnload="javascirpt:formCancel()"  onBeforeUnload="javascirpt:formCancel()">
	<center>
		<table border="0" cellpadding="3" cellspacing="2" width="100%">
			<form name="familyConflictConfirmForm" method="post" target="_top" action="javascript:formSubmit()">
				<script language="JavaScript">
					document.write(top.opener.getFamilyConflictWindowContent());
					window.focus();
				</script>
			</form>
		</table>
	</center>
</body>
</html>

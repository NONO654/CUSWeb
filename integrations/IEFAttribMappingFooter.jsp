<%--  IEFAttribMappingFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="com.matrixone.MCADIntegration.server.beans.IEFAttrMapping" %>
<%

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	
	String sNothingSelected = integSessionData.getStringResource("mcadIntegration.Server.Message.IEF0341130337");
	String sConfirmDelete = integSessionData.getStringResource("mcadIntegration.Server.Message.IEF0341130338");
%>

<html>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/IEFUIConstants.js"  type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/MCADUtilMethods.js"  type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/IEFUIModal.js"  type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
	
	function doAdd()
	{
	   var  url  =  "IEFAddAttribMappingFS.jsp";
	   showIEFModalDialog(url,  700,  300,  true);
	}

	function doDeploy()
    {	
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		
		tableDisplayFrame.document.forms['frmAttribMapping'].sAction.value='deploy';
		tableDisplayFrame.document.forms['frmAttribMapping'].submit();
    }

	function doDelete()
    {	
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var sCheckforSingleNode = top.frames['tableDisplay'].document.forms['frmAttribMapping'].AttributeMapList.id;
		var sCheckBoxDelete = top.frames['tableDisplay'].document.forms['frmAttribMapping'].elements['AttributeMapList'];
		
		var sDeleteAttr = "";
		
		if(sCheckBoxDelete.length == undefined)
		{
			if(sCheckBoxDelete.checked)
				sDeleteAttr = sCheckforSingleNode;
		}
		else
		{
		  for (var i = 0;i< sCheckBoxDelete.length;i++)
		  {
			if(sCheckBoxDelete[i].checked)
				sDeleteAttr = sDeleteAttr + sCheckBoxDelete[i].id + ",";		
		  }
		}
		if(sDeleteAttr == "")
		{
                        //XSSOK
			alert("<%=sNothingSelected%>")
		}
		else
		{
                        //XSSOK
			var check = confirm("<%=sConfirmDelete%>");
			if(check == true)
			{
				tableDisplayFrame.document.forms['frmAttribMapping'].sAction.value='delete';
				tableDisplayFrame.document.forms['frmAttribMapping'].attri.value=sDeleteAttr;
				tableDisplayFrame.document.forms['frmAttribMapping'].submit();
			}
		}
    }

	function doReset()
	{
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		tableDisplayFrame.document.forms['frmAttribMapping'].sAction.value='reset';
		tableDisplayFrame.document.forms['frmAttribMapping'].submit();
	}
	function doCancel()
	{
		top.close();
	}

</script>
</head>

<body>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr><td>&nbsp</td></tr>
		<tr>
			<td align="right">
				<table border="0">
					<tr>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doDelete()"><img src="../common/images/iconActionDelete.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Delete")%>"></a>&nbsp</td>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doDelete()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Delete")%></a>&nbsp&nbsp;</td>
		                        <!--XSSOK-->
					<td align="right"><a href="javascript:doAdd()"><img src="../common/images/buttonDialogAdd.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Add")%>"></a>&nbsp</td>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doAdd()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Add")%></a>&nbsp&nbsp;</td>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doDeploy()"><img src="../common/images/buttonDialogApply.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Deploy")%>"></a>&nbsp</td>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doDeploy()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Deploy")%></a>&nbsp&nbsp;</td>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doCancel()"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%>"></a>&nbsp</td>
					<!--XSSOK-->
					<td align="right"><a href="javascript:doCancel()"><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel")%></a>&nbsp&nbsp;</td>
					
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>

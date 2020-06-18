<%--  IEFConfigUIFooter1.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file = "MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String sCreate    = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Create");
	String sModify    = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Modify");
	String sDelete    = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Delete");
	String sCancel	  = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel");
	String createIcon = emxGetParameter(request, "createIcon");
	String modifyIcon = emxGetParameter(request, "modifyIcon");
	String deleteIcon = emxGetParameter(request, "deleteIcon");
%>

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">

	var progressBarCheck = 1;
	function removeProgressBar(){

		progressBarCheck++;
		var frameheaderFrame = findFrame(parent,"headerFrame");
		if (progressBarCheck < 10){
			if (frameheaderFrame && frameheaderFrame.document.progress) {
				frameheaderFrame.document.progress.src = "../common/images/utilSpacer.gif";
				} else {
				setTimeout("removeProgressBar()",500);
			}
		}

		return true;
	}

</script>

<body onLoad="removeProgressBar()">
<form name="bottomCommonForm">

<table border="0" cellspacing="0" cellpadding="0" align=right>
	<tr><td>&nbsp</td></tr>
	<tr>
		<td align="right"><a href="javascript:top.frames.contentFrame.createMethod()"><img src="images/<%= XSSUtil.encodeForURL(integSessionData.getClonedContext(session),createIcon) %>" border="0" alt="<%=sCreate%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:top.frames.contentFrame.createMethod()"><%=sCreate%></a>&nbsp&nbsp;</td>

		<td align="right"><a href="javascript:top.frames.contentFrame.modifyMethod()"><img src="images/<%= XSSUtil.encodeForURL(integSessionData.getClonedContext(session),modifyIcon) %>" border="0" alt="<%=sModify%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:top.frames.contentFrame.modifyMethod()"><%=sModify%></a>&nbsp&nbsp;</td>

		<td align="right"><a href="javascript:top.frames.contentFrame.deleteMethod()"><img src="images/<%= XSSUtil.encodeForURL(integSessionData.getClonedContext(session),deleteIcon) %>" border="0" alt="<%=sDelete%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:top.frames.contentFrame.deleteMethod()"><%=sDelete%></a>&nbsp&nbsp;</td>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.window.close()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=sCancel%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.window.close()"><%=sCancel%></a>&nbsp&nbsp;</td>
	</tr>
 </table>

</form>
</body>
</html>

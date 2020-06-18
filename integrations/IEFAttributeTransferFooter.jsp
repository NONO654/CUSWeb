<%--  IEFAttributeTransferFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file = "MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

	String sDone   = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done");
	String sCancel = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel");
%>
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

<html>
<head>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>

<body onLoad="removeProgressBar()">
<form name="bottomCommonForm">

<table border="0" cellspacing="0" cellpadding="0" align=right>
	<tr><td>&nbsp</td></tr>
	<tr>
         	<!--XSSOK-->
		<td align="right"><a href="javascript:top.frames.contentFrame.doneMethod()"><img src="../integrations/images/emxUIButtonDone.gif" border="0" alt="<%=sDone%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:top.frames.contentFrame.doneMethod()"><%=sDone%></a>&nbsp&nbsp;</td>
                <!--XSSOK-->
		<td align="right"><a href="javascript:parent.window.close()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt="<%=sCancel%>"></a>&nbsp</td>
		<!--XSSOK-->
		<td align="right"><a href="javascript:parent.window.close()"><%=sCancel%></a>&nbsp&nbsp;</td>
	</tr>
 </table>

</form>
</body>
</html>

<%--  IEFIntegrationChooserFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
String sUpdate = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Submit");
String sCancel = integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Cancel");
%>

<html>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">

<script language="javascript">
	function doDone() 
	{
	  parent.formSubmit();
	}

	function doCancel() 
	{
	  parent.window.close();
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
					<td align="right"><a href="javascript:doDone()"><img src="../common/images/buttonDialogDone.gif" border="0" alt="<%=sUpdate%>"></a>&nbsp</td>
					<!--XSSOK-->
                    <td align="right"><a href="javascript:doDone()"><%=sUpdate%></a>&nbsp&nbsp;</td>
	            <!--XSSOK-->
                    <td align="right"><a href="javascript:doCancel()"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="<%=sCancel%>"></a>&nbsp</td>
		    <!--XSSOK-->
                    <td align="right"><a href="javascript:doCancel()"><%=sCancel%></a>&nbsp&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>

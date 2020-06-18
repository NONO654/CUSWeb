<%--  IEFAddAttribMappingFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<html>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIDialog.css" type="text/css">
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/IEFUIConstants.js"  type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/MCADUtilMethods.js"  type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/IEFUIModal.js"  type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
	function doCancel()
	{
	  top.close();
	}

</script>
</head>
<%@ include file ="MCADTopInclude.inc" %>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	IEFAttrMappingBase objIEFAttrMappingBase = (IEFAttrMapping)session.getAttribute("IEFAttrMapping");
	String sMappingType = objIEFAttrMappingBase.getsMappingType();
	String sError = Request.getParameter(request,"errorMessage"); 
	sError	   = MCADUrlUtil.hexDecode(sError);
%>
<body>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr><td>&nbsp&nbsp;</td></tr>
		
		<tr>
			<td align="left"><font color="red"><%=XSSUtil.encodeForHTML(context, sError)%></font></td>
			<td align="right">
				<table border="0">
					<tr>
					    <!--XSSOK-->
						<td align="right"><a href=javascript:parent.doneMethod("<%=XSSUtil.encodeForHTML(context, sMappingType)%>")><img src="../common/images/buttonDialogDone.gif" border="0" alt="<%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done")%>"></a>&nbsp</td>
						<!--XSSOK-->
						<td align="right"><a href=javascript:parent.doneMethod("<%=XSSUtil.encodeForHTML(context, sMappingType)%>")><%=integSessionData.getStringResource("mcadIntegration.Server.ButtonName.Done")%></a>&nbsp&nbsp;</td>
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

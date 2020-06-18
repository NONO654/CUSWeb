<%--  emxAppletTimeOutErrorFooter.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file = "MCADTopInclude.inc" %>
<html>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css"><!--This is required for the font of the text-->
<link rel="stylesheet" href="../common/styles/emxUIDialog.css" type="text/css" ><!--This is required for the cell (td) back ground colour-->
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css" >
</head>

<%
String acceptLanguage		= request.getHeader("Accept-Language");
String I18NResourceBundle	= "emxIEFDesignCenterStringResource";
String strCancel			= UINavigatorUtil.getI18nString("emxIEFDesignCenter.Common.Cancel", "emxIEFDesignCenterStringResource", acceptLanguage);
%>

<script language="javascript">	
	function closeWindow()
	{
	  top.close();
	}
</script>

<body>
	<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr><td>&nbsp</td></tr>
		<tr>
			<td align="right">
				<table border="0">
					<tr>
						<td align="right" nowrap>&nbsp;&nbsp;&nbsp;<a href="javascript:closeWindow()"><img src="../integrations/images/emxUIButtonCancel.gif" border="0" alt ="<%=strCancel%>"</a></td>
						<td align="right" nowrap><a href="javascript:closeWindow()"><%=strCancel%></a></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</body>
</html>

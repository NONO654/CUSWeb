<%-- emxChartOptionsFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $$
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%
    String stringResFileId	= "emxFrameworkStringResource";
    String strLanguage = request.getHeader("Accept-Language");
    Locale locale 			= new Locale(strLanguage);
    String helpDone			= EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.FormComponent.Done");
    String helpCancel		= EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.FormComponent.Cancel");
    String title_prefix 	= EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.WindowTitle.Footer");
    String strChartOptions	= EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.WindowTitle.chartoptions");
    String title 			= title_prefix + strChartOptions;
%>
<html>
<head>
<!-- //XSSOK -->
<title><%=title%></title>
<link rel="stylesheet" href="styles/emxUIDefault.css" type="text/css" />
<link rel="stylesheet" href="styles/emxUIDialog.css" type="text/css" />
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>
</head>

<body>
<form name="editFooter" method="post">

<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
<tr>
<td align="right">
<table border="0" cellspacing="0">
<tr>
<td><a href="#" onClick="parent.optionsDisplay.submitOptions()"><img src="images/buttonDialogDone.gif" border="0" alt="<%=helpDone%>" /></a></td>
<td><a href="#" onClick="parent.optionsDisplay.submitOptions()" class="button"><%=helpDone%></a></td>
<td>&nbsp;&nbsp;</td>
<td><a href="javascript:getTopWindow().closeWindow()"><img src="images/buttonDialogCancel.gif" border="0" alt="<%=helpCancel%>" /></a></td>
<td><a onClick="javascript:getTopWindow().closeWindow()" class="button"><%=helpCancel%></a></td>
</tr>
</table>
</td>
</tr>
</table>

</form>
</body>

</html>

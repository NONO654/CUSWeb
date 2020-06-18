<%--  emxTreeNoDisplay.jsp - Tree display error page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTreeNoDisplay.jsp.rca 1.6 Wed Oct 22 15:47:55 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>

<head>
    <title></title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
</head>

<body>

<table border="0" cellspacing="2" cellpadding="0" width="100%">
<tr>
<td width="99%">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
</tr>
</table>

<table border="0" width="100%" cellspacing="2" cellpadding="4">
<tr>
<td class="pageHeader" width="99%">
<emxUtil:i18nScript localize="i18nId">emxFramework.Login.Error</emxUtil:i18nScript>
</td>
<td width="1%"><img src="images/utilSpacer.gif" width="1" height="20" alt="" /></td>
</tr>
</table>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
</tr>
</table>

<br/>
<br/>&nbsp;<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NoTreeDisplayMsg1</emxUtil:i18nScript>
<br/>
<br/>&nbsp;<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NoTreeDisplayMsg2</emxUtil:i18nScript>
<br/>&nbsp;<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NoTreeDisplayMsg3</emxUtil:i18nScript>
<br/>&nbsp;<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NoTreeDisplayMsg4</emxUtil:i18nScript>
<br/><br/>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
</tr>
</table>

</table>
</body>
</html>

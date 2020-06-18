<%--  emxFreezePaneAutoFilterFooter.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneAutoFilterFooter.jsp.rca 1.4.3.2 Wed Oct 22 15:48:48 2008 przemek Experimental przemek $
--%>

<html>

<%@include file = "emxNavigatorInclude.inc"%>

<head>
<title>
</title>

<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%> 
<%@include file = "../emxStyleDialogInclude.inc"%> 

<script language="JavaScript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js"></script>

<script type="text/javascript">

    function closeWindow() {
        turnOnProgress("utilProgressBlue.gif");
        setTimeout("getTopWindow().closeWindow()", 1000);
    }

    function doCancel() {
        getTopWindow().closeWindow();
    }

</script>

</head>

<body class="foot dialog">

<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
    <tr>
    <td align="right">
        <table border="0" cellspacing="0">
        <tr>
            <td><a href="javascript:filterStructureBrowser()"><img src="images/buttonDialogDone.gif" border="0" alt="<emxUtil:i18nScript localize="i18nId">emxFramework.Common.Done</emxUtil:i18nScript>" /></a></td>
            <td><a href="javascript:filterStructureBrowser()" class="button"><emxUtil:i18nScript localize="i18nId">emxFramework.Common.Done</emxUtil:i18nScript></a></td>
            <td>&nbsp;&nbsp;</td>
            <td><a href="javascript:doCancel()"><img src="images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18nScript localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18nScript>" /></a></td>
            <td><a href="javascript:doCancel()" class="button"><emxUtil:i18nScript localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18nScript></a></td>
        </tr>
        </table>
    </td>
    </tr>
</table>
</body>
</html>

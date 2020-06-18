<%-- emxTimelineFilterFooter.jsp
        
        Copyright (c) 1992-2018 Dassault Systemes.
        All Rights Reserved.
        This program contains proprietary and trade secret information of MatrixOne, 
        Inc.
        Copyright notice is precautionary only and does not evidence any actual or 
        intended publication of such program.

        static const char RCSID[] = $Id: emxTimelineFilterFooter.jsp.rca 1.4 Wed Oct 22 15:48:24 2008 przemek Experimental przemek $
 --%>

<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<head>
<title>
</title>

<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>

</head>

<body>

<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
    <tr>
    <td align="right">
        <table border="0" cellspacing="0">
        <tr>
            <td><a href="javascript:parent.frames[1].applyFilter()"><img src="../common/images/buttonDialogApply.gif" border="0" alt="<emxUtil:i18nScript localize="i18nId">emxFramework.Preferences.Apply</emxUtil:i18nScript>" /></a></td>
            <td><a href="javascript:parent.frames[1].applyFilter()" class="button"><emxUtil:i18nScript localize="i18nId">emxFramework.Preferences.Apply</emxUtil:i18nScript></a></td>
            <td>&nbsp;&nbsp;</td>
            <td><a href="javascript:parent.frames[1].doneFilter()"><img src="../common/images/buttonDialogDone.gif" border="0" alt="<emxUtil:i18nScript localize="i18nId">emxFramework.Common.Done</emxUtil:i18nScript>" /></a></td>
            <td><a href="javascript:parent.frames[1].doneFilter()" class="button"><emxUtil:i18nScript localize="i18nId">emxFramework.Common.Done</emxUtil:i18nScript></a></td>
            <td>&nbsp;&nbsp;</td>
            <td><a href="javascript:parent.frames[1].doCancel()"><img src="../common/images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18nScript localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18nScript>" /></a></td>
            <td><a href="javascript:parent.frames[1].doCancel()" class="button"><emxUtil:i18nScript localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18nScript></a></td>
        </tr>
        </table>
    </td>
    </tr>
</table>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>

<%-- emxComponentsCheckinTop.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinBottomCode.inc.rca 1.9 Wed Oct 22 16:18:31 2008 przemek Experimental przemek $"
--%>
<%
  request.setAttribute("contentPageIsDialog", "true");
%>
<%@include file = "emxComponentsCheckin.inc"%>
<%
  Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  String objectAction = (String)emxCommonDocumentCheckinData.get("objectAction");
%>
<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
<tr>
<td align="right">
<table border="0" cellspacing="0">
<tr>
<%
    if ( CommonDocument.OBJECT_ACTION_CREATE_MASTER.equalsIgnoreCase(objectAction) || CommonDocument.OBJECT_ACTION_CREATE_CHECKIN.equalsIgnoreCase(objectAction) || VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER.equalsIgnoreCase(objectAction))
    {
%>
        <td><a href="javascript:parent.frames[1].goBack()"><img src="../common/images/buttonDialogPrevious.gif" border="0" /></a></td>
        <td><a href="javascript:parent.frames[1].goBack()"  class="button"><emxUtil:i18n localize="i18nId">emxComponents.Button.Previous</emxUtil:i18n></a></td>
<%
    }
%>
        <td><a href="javascript:parent.frames[1].checkinFile()"><img src="../common/images/buttonDialogDone.gif" border="0" /></a></td>
        <td><a href="javascript:parent.frames[1].checkinFile()"  class="button"><emxUtil:i18n localize="i18nId">emxComponents.Button.Done</emxUtil:i18n></a></td>
        <td><a href="javascript:parent.frames[1].checkinCancel()"><img src="../common/images/buttonDialogCancel.gif" border="0" /></a></td>
        <td><a href="javascript:parent.frames[1].checkinCancel()" class="button"><emxUtil:i18n localize="i18nId">emxComponents.Common.Cancel</emxUtil:i18n></a></td>
 </tr>
</table>
</td>
</tr>
</table>

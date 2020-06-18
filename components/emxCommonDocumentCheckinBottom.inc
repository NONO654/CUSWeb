<%-- emxCommonDocumentCheckinBottom.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinBottom.inc.rca 1.5 Wed Oct 22 16:18:06 2008 przemek Experimental przemek $"
--%>
<%
  request.setAttribute("contentPageIsDialog", "true");
%>
<%@include file = "emxComponentsCheckin.inc"%>
<%

%>
<table border="0" cellspacing="0" cellpadding="0" width="100%" align="right">
 <tr>
        <td align="right" nowrap >&nbsp;<a href="javascript:parent.frames[1].checkinFile()"  ><img src="../common/images/buttonDialogDone.gif" border="0" align="absmiddle" /></a>&nbsp;<a href="javascript:parent.frames[1].checkinFile()"  ><emxUtil:i18n localize="i18nId">emxComponents.Common.Checkin</emxUtil:i18n></a>&nbsp;
        &nbsp;<a href="javascript:window.closeWindow()"  ><img src="../common/images/buttonDialogCancel.gif" border="0" align="absmiddle" /></a>&nbsp;<a href="javascript:parent.window.closeWindow()"  ><emxUtil:i18n localize="i18nId">emxComponents.Common.Cancel</emxUtil:i18n></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
 </tr>
</table>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

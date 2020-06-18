<%-- emxCommonDocumentCheckinTop.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinTop.inc.rca 1.5 Wed Oct 22 16:18:20 2008 przemek Experimental przemek $"
--%>
<%
  request.setAttribute("contentPageIsDialog", "true");
%>
<%@include file = "emxComponentsCheckin.inc"%>

<%
// Getting the display name for the page.
    String PageHeading = ComponentsUtil.i18nStringNow("emxComponents.Common.CheckinDocuments",request.getHeader("Accept-Language"));
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr>
    <td>
      &nbsp;
            <table border="0" cellspacing="0" cellpadding="0" width="96%" align="center" >
                <tr><td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" /></td></tr>
            </table>
            <table border="0" cellpadding="8" width="96%" align="center" >
                <tr>
                  <!-- //XSSOK -->
                  <td class="pageHeader" width="1%" nowrap="nowrap"><%=PageHeading%></td>
                  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="../common/images/utilSpacer.gif" width="34" height="28" name="progress" /></td>
                </tr>
            </table>

            <table border="0" cellspacing="0" cellpadding="0" width="96%" align="center" >
                <tr><td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" /></td></tr>
            </table>

            <table border="0" cellpadding="2" cellspacing="0"  align="right" width="1%">
                    <tr><td><img src="../common/images/utilSpacer.gif" width="0" height="1" /></td></tr>
                    <tr>
                  <td align="right" ><a href='javascript:openHelp("emxhelpcheckindocument","<%=suiteDir%>","en")'><img src="../common/images/buttonContextHelp.gif" width="16" height="16" border="0" /></a></td>
                </tr>
            </table>
      &nbsp;
    </td>
  </tr>
</table>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

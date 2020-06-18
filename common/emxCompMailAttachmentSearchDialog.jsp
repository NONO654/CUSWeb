<%-- emxCompMailAttachmentSearchDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxCompMailAttachmentSearchDialog.jsp.rca 1.7 Wed Oct 22 15:48:20 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">
  function doSearch() {
    if ( document.searchform.txtType.value == "" || document.searchform.txtType.value == null ) {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.EnterType</emxUtil:i18nScript>");
      document.searchform.txtType.focus();
      return;
    } else if ( document.searchform.txtName.value == "" || document.searchform.txtName.value == null ) {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.EnterName</emxUtil:i18nScript>");
      document.searchform.txtName.focus();
      return;
    } else if ( document.searchform.txtRevision.value == "" || document.searchform.txtRevision.value == null ) {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.EnterRevision</emxUtil:i18nScript>");
      document.searchform.txtRevision.focus();
      return;
    } else {
      document.searchform.submit();
      return;
    }
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }

  function clear() {
    document.searchform.txtType.value="";
    document.searchform.txtType.focus();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  // ------------------------ Page content below here  ---------------------
  String sType = emxGetParameter(request,"txtType");
  String sName = emxGetParameter(request,"txtName");
  String sRevision = emxGetParameter(request,"txtRevision");

  if (sName==null)
    sName = "*";
  if (sType==null)
    sType = "*";
  if (sRevision==null)
    sRevision = "*";
%>

<form name="searchform" id="searchform" method="post" onSubmit="doSearch(); return false" target="_parent" action="emxCompMailAttachmentResultsFS.jsp">
  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Type</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtType" id="txtType" value="<%=XSSUtil.encodeForHTMLAttribute(context, sType)%>"/>
        <input type="button" name="btnType" id="btnType" value="..." onClick=""/>
        <a href="javascript:clear()"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Clear</emxUtil:i18n></a>
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Name</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtName" id="txtName" value="<%=XSSUtil.encodeForHTMLAttribute(context, sName)%>"/>
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.Revision</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtRevision" id="txtRevision" value="<%=XSSUtil.encodeForHTMLAttribute(context, sRevision)%>"/>
      </td>
    </tr>
  </table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

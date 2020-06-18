<%--  emxpartProjectSearchDialog.jsp - The content page of the main search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  var clicked = false;   

  function doSearch() {

      if (clicked) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
      }

    var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
    document.frmPowerSearch.queryLimit.value = strQueryLimit;

    document.frmPowerSearch.txtName.value = trimWhitespace(document.frmPowerSearch.txtName.value);
    if (charExists(document.frmPowerSearch.txtName.value, '"')||charExists(document.frmPowerSearch.txtName.value, '\'')||charExists(document.frmPowerSearch.txtName.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtName.focus();
      return;
    }

    document.frmPowerSearch.txtCompany.value = trimWhitespace(document.frmPowerSearch.txtCompany.value);
    if (charExists(document.frmPowerSearch.txtCompany.value, '"')||charExists(document.frmPowerSearch.txtCompany.value, '\'')||charExists(document.frmPowerSearch.txtCompany.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtCompany.focus();
      return;
    }

    document.frmPowerSearch.txtBusinessUnit.value = trimWhitespace(document.frmPowerSearch.txtBusinessUnit.value);
    if (charExists(document.frmPowerSearch.txtBusinessUnit.value, '"')||charExists(document.frmPowerSearch.txtBusinessUnit.value, '\'')||charExists(document.frmPowerSearch.txtBusinessUnit.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtBusinessUnit.focus();
      return;
    }


      startSearchProgressBar(true);
      clicked = true;
    document.frmPowerSearch.submit();
  }

  function ClearSearch() {
    document.frmPowerSearch.txtName.value = "*";
    document.frmPowerSearch.txtCompany.value = "*";
    document.frmPowerSearch.txtBusinessUnit.value = "*";
  }

</script>

<%
  String languageStr = request.getHeader("Accept-Language");
  String parentForm  = emxGetParameter(request,"form");
  String parentField = emxGetParameter(request,"field");
  String parentFieldId = emxGetParameter(request,"fieldId");
  String projectSpaceType       = PropertyUtil.getSchemaProperty(context,"type_ProjectSpace");
  String role = emxGetParameter(request,"role");
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<form name="frmPowerSearch" method="get" action="emxpartProjectSearchResultsFS.jsp" target="_parent" onSubmit="javascript:doSearch();return false">

<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="form" value="<xss:encodeForHTMLAttribute><%=parentForm%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="field" value="<xss:encodeForHTMLAttribute><%=parentField%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="fieldId" value="<xss:encodeForHTMLAttribute><%=parentFieldId%></xss:encodeForHTMLAttribute>" />

<table border="0" cellspacing="2" cellpadding="3" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
    <!-- XSSOK -->
    <td class="inputField"><img src="../common/images/iconSmallProject.gif" border="0" alt="<%=i18nNow.getTypeI18NString(projectSpaceType, languageStr)%>" />&nbsp;<%=i18nNow.getTypeI18NString(projectSpaceType, languageStr)%></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*" /></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Company</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtCompany" size="16" value="*" /></td>
  </tr>
    <tr>
    
<td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.BusinessUnit</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtBusinessUnit" size="16" value="*" /></td>
  </tr>

</table>
<input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
style="-moz-user-focus: none" />
<input type="hidden" name="role" value="<xss:encodeForHTMLAttribute><%=role%></xss:encodeForHTMLAttribute>" />
</form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

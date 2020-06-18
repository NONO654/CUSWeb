<%--  emxComponentsOrganizationSearchDialog.jsp - The content page of the main search

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

   static const char RCSID[] = $Id: emxComponentsOrganizationSearchDialog.jsp.rca 1.1.7.6 Tue Oct 28 23:01:06 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  var clicked = false;   

  function doSearch() {

      if (clicked) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
      }

   // var strQueryLimit = parent.frames[3].document.bottomCommonForm.QueryLimit.value;
    var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
    document.frmPowerSearch.queryLimit.value = strQueryLimit;

    document.frmPowerSearch.txtName.value = trimWhitespace(document.frmPowerSearch.txtName.value);
    if (charExists(document.frmPowerSearch.txtName.value, '"')||charExists(document.frmPowerSearch.txtName.value, '\'')||charExists(document.frmPowerSearch.txtName.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtName.focus();
      return;
    }

      startSearchProgressBar(true);
      clicked = true;

    document.frmPowerSearch.submit();
  }

  function ClearSearch() {
    document.frmPowerSearch.txtName.value = "*";
  }

</script>

<%
  String languageStr = request.getHeader("Accept-Language");
  String parentForm  = emxGetParameter(request,"form");
  String parentField = emxGetParameter(request,"field");
  String parentFieldId = emxGetParameter(request,"fieldId");
  String parentFieldRev = emxGetParameter(request,"fieldRev");
  String isEdit     = emxGetParameter(request,"isEdit");
  String objectId       = emxGetParameter(request,"objectId");
  String role = emxGetParameter(request,"role");
  String selection       = emxGetParameter(request,"selection");
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="frmPowerSearch" method="get" action="emxComponentsOrganizationSearchResultsFS.jsp" target="_parent" onSubmit="javascript:doSearch(); return false">

<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="form" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentForm)%>" />
<input type="hidden" name="field" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentField)%>" />
<input type="hidden" name="fieldId" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentFieldId)%>" />
<input type="hidden" name="fieldRev" value="<%=XSSUtil.encodeForHTMLAttribute(context,parentFieldRev)%>" />
<input type="hidden" name="isEdit" value="<%=XSSUtil.encodeForHTMLAttribute(context,isEdit)%>" />
<input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,objectId)%>" />
<input type="hidden" name="role" value="<%=XSSUtil.encodeForHTMLAttribute(context,role)%>" />
<input type="hidden" name="selection" value="<%=XSSUtil.encodeForHTMLAttribute(context,selection)%>" />

<table border="0" cellspacing="2" cellpadding="3" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
      <select name="searchtype" >
        <option value="<%=DomainObject.TYPE_ORGANIZATION%>" selected ><%=i18nNow.getTypeI18NString(DomainObject.TYPE_ORGANIZATION, languageStr)%></option>
      
<%
              BusinessType busType = new BusinessType(DomainObject.TYPE_ORGANIZATION, new Vault((String)((com.matrixone.apps.common.Person.getPerson(context)).getCompany(context).getVault())));
              busType.open(context);
              BusinessTypeList busTypeList = busType.getChildren(context);
              busType.close(context);
              Iterator itr = busTypeList.iterator();
              String sTypeValue="";
              while(itr.hasNext()) {
                sTypeValue = ((BusinessType)itr.next()).getName();
%>
                <option value="<%= sTypeValue %>"><%=i18nNow.getTypeI18NString(sTypeValue, languageStr)%></option>
<%
              }
%>
      </select>

    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*" /></td>
  </tr>
</table>
</form>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

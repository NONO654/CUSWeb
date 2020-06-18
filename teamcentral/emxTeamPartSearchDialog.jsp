<%--  emxTeamPartSearchDialog.jsp - The content page of the main search

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

      static const char RCSID[] = $Id: emxTeamPartSearchDialog.jsp.rca 1.20 Wed Oct 22 16:06:11 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  function doSearch() {
    document.frmPowerSearch.txtName.value = trimWhitespace(document.frmPowerSearch.txtName.value);
    if (charExists(document.frmPowerSearch.txtName.value, '"')||charExists(document.frmPowerSearch.txtName.value, '\'')||charExists(document.frmPowerSearch.txtName.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtName.focus();
      return;
    }

    document.frmPowerSearch.txtRev.value = trimWhitespace(document.frmPowerSearch.txtRev.value);
    if (charExists(document.frmPowerSearch.txtRev.value, '"')||charExists(document.frmPowerSearch.txtRev.value, '\'')||charExists(document.frmPowerSearch.txtRev.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtRev.focus();
      return;
    }

    document.frmPowerSearch.txtDesc.value = trimWhitespace(document.frmPowerSearch.txtDesc.value);
    if (charExists(document.frmPowerSearch.txtDesc.value, '"')||charExists(document.frmPowerSearch.txtDesc.value, '\'')||charExists(document.frmPowerSearch.txtDesc.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtDesc.focus();
      return;
    }

    document.frmPowerSearch.txtOwner.value = trimWhitespace(document.frmPowerSearch.txtOwner.value);
    if (charExists(document.frmPowerSearch.txtOwner.value, '"')||charExists(document.frmPowerSearch.txtOwner.value, '\'')||charExists(document.frmPowerSearch.txtOwner.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtOwner.focus();
      return;
    }

    document.frmPowerSearch.txtOriginator.value = trimWhitespace(document.frmPowerSearch.txtOriginator.value);
    if (charExists(document.frmPowerSearch.txtOriginator.value, '"')||charExists(document.frmPowerSearch.txtOriginator.value, '\'')||charExists(document.frmPowerSearch.txtOriginator.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtOriginator.focus();
      return;
    }
    if((document.frmPowerSearch.vaultOption[2].checked==true) && (document.frmPowerSearch.selVaults.value==""))
    {
          alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.VaultOptions.PleaseSelectVault</emxUtil:i18nScript>");
          return;
    }
    else if((document.frmPowerSearch.vaultOption[2].checked==true) && (document.frmPowerSearch.selVaults.value!=""))
    {
      document.frmPowerSearch.vaultOption[2].value = document.frmPowerSearch.selVaults.value;
    }
    document.frmPowerSearch.submit();
  }

  function ClearSearch() {
    document.frmPowerSearch.txtName.value = "*";
    document.frmPowerSearch.txtRev.value = "*";
    document.frmPowerSearch.txtOwner.value = "*";
    document.frmPowerSearch.txtOriginator.value = "*";
    document.frmPowerSearch.txtWhere.value="";
  }

</script>

<%
  String languageStr = request.getHeader("Accept-Language");
  String appDirectory = (String)FrameworkProperties.getProperty(context,"eServiceSuiteTeamCentral.Directory");
  String sPartType = Framework.getPropertyValue(session, "type_Part");
  boolean findPart = false;

  String sMode = emxGetParameter(request, "mode");
  if ((sMode != null)     &&
      (!sMode.equals("")) &&
      (!sMode.equals("null")))
  {
    findPart = sMode.equals("findPart");
  }
/****************************Vault Code Start*******************************/
  // Display Vault Field as options
  String sGeneralSearchPref ="";
  String allCheck ="";
  String defaultCheck ="";
  String localCheck ="";
  String selectedVaults ="";
  String selectedVaultsValue ="";

  sGeneralSearchPref = PersonUtil.getSearchDefaultSelection(context);
  // Check the User SearchVaultPreference Radio button
  if(sGeneralSearchPref.equals(PersonUtil.SEARCH_ALL_VAULTS)) {
    allCheck="checked";
  } else if (sGeneralSearchPref.equals(PersonUtil.SEARCH_LOCAL_VAULTS)){
    localCheck="checked";
  } else if (sGeneralSearchPref.equals(PersonUtil.SEARCH_DEFAULT_VAULT)) {
    defaultCheck="checked";
  } else {
    selectedVaults="checked";
    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    selectedVaultsValue = person.getSearchDefaultVaults(context);
  }

  /******************************Vault Code End*****************************/
%>

<script>

  function showTypeSelector()
  {
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=selType&fieldNameDisplay=selTypeDisplay&formName=frmPowerSearch&ShowIcons=true&InclusionList=type_Part&ObserveHidden=false&SelectType=multiselect&SelectAbstractTypes=true";
    showModalDialog(strURL, 450, 350);
  }
  function showSelectedVaults() {
    document.frmPowerSearch.VaultSelector.disabled=false;
    document.frmPowerSearch.selVaults.value=document.frmPowerSearch.tempStore.value;
  }
  function clearSelectedVaults() {
    document.frmPowerSearch.selVaults.value="";
    document.frmPowerSearch.VaultSelector.disabled=true;
  }

  var bVaultMultiSelect = true;
  var strTxtVault = "document.forms['frmPowerSearch'].selVaults";
  var txtVault = null;
  var strSelectOption = "document.forms['frmPowerSearch'].vaultOption[3]";
  var selectOption = null;
  function showVaultSelector() {
      var strFeatures = "width=300,height=350,resizable=no,scrollbars=auto";
      txtVault = eval(strTxtVault);
      showChooser("../common/emxVaultChooser.jsp?fieldNameActual=selVaults");
  }

  </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<body onload="turnOffProgress(), getTopWindow().loadSearchFormFields()">
<form name="frmPowerSearch" method="get" action="../common/emxTable.jsp" target="searchView" onSubmit="doSearch()">

<input type="hidden" name="txtWhere" value="" />
<input type="hidden" name="ckSaveQuery" value="" />
<input type="hidden" name="txtQueryName" value="" />
<input type="hidden" name="ckChangeQueryLimit" value="" />
<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="fromDirection" value="" />
<input type="hidden" name="toDirection" value="" />
<input type="hidden" name="selType" value="<%=sPartType%>" />
<input type="hidden" name="vaultAwarenessString" value="" />

<table border="0" cellspacing="1" cellpadding="5" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
      <input READONLY type="text" readonly="readonly" value="<%=i18nNow.getTypeI18NString(sPartType,languageStr)%>" size="16" name="selTypeDisplay" onChange="JavaScript:ClearSearch()" />
      <input name="typeButton" type="button" value="..." onClick="showTypeSelector()" />
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*" /></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Revision</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtRev" size="16" value="*" /></td>
  </tr>
    <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtDesc" size="16" value="*" /></td>
  </tr>
  <!----------------------------------Vault Code Start--------------------------------------->
    <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Vault</emxUtil:i18n></td>
        <td class="inputField">
          <table border="0">
            <tr>
           <td>
                <input type="radio" <%=defaultCheck%> value="DEFAULT_VAULT" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Default</emxUtil:i18n></td>
            
            </tr>
            <tr>
              <td>
                <input type="radio"  <%=localCheck%> value="LOCAL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Local</emxUtil:i18n></td>
            </tr>
            <tr>
              <td>
                <input type="radio" <%=selectedVaults%> value="<%=selectedVaultsValue%>" name="vaultOption" onClick="javascript:showSelectedVaults();" />
              </td>
              <td>
                <emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Selected</emxUtil:i18n>
                <input type="text"  READONLY  name="selVaults" size="20" value="<%=selectedVaultsValue%>" readonly="readonly" />
                <input class="button" type="button" name="VaultSelector" size = "200" value="..." onClick="javascript:showVaultSelector();" <% if (!selectedVaults.equals("checked")) { %> disabled <% } %> />
                <input type="hidden" name="tempStore" value="<%=selectedVaultsValue%>" />
              </td>
            </tr>
            <tr>
              <td>
                <input type="radio" <%=allCheck%> value="ALL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.All</emxUtil:i18n></td>
            </tr>
          </table>
        </td>
    </tr>
<!----------------------------------Vault Code End--------------------------------------->


  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Owner</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOwner" size="16" value="*" /></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Originator</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOriginator" size="16" value="*" /></td>
  </tr>

<input type="hidden" name="mode" value="powersearch" />
<input type="hidden" name="saveQuery" value="false" />
<input type="hidden" name="changeQueryLimit" value="true" />
<input type="hidden" name="txtSearch" value="" />
<input type="hidden" name="txtFormat" value="" />
<input type="hidden" name="setRadio" value="" />

<input type="hidden" name="table" value="ENCPartSearchResult" />
<input type="hidden" name="program" value="emxPart:getPartSearchResult" />
<input type="hidden" name="toolbar" value="AEFSearchResultToolbar" />
<input type="hidden" name="header" value="<%=i18nNow.getI18nString("emxTeamCentral.ObjectSearchResults.SearchResults", "emxTeamCentralStringResource", request.getHeader("Accept-Language"))%>" />
<input type="hidden" name="selection" value="multiple" />
<input type="hidden" name="QueryLimit" value="" />
<input type="hidden" name="pagination" value="" />
<input type="hidden" name="Style" value="dialog" />
<input type="hidden" name="listMode" value="search" />
<input type="hidden" name="CancelButton" value="true" />
<input type="hidden" name="CancelLabel" value="emxTeamCentral.Button.Close" />
<input type="hidden" name="HelpMarker" value="emxhelpsearchresults" />
<input type="hidden" name="timeZone" value="" />
<input type="hidden" name="StringResourceFileId" value="emxTeamCentralStringResource" />
<input type="hidden" name="suiteKey" value="TeamCentral" />
<input type="hidden" name="SuiteDirectory" value="teamcentral" />


</table>


</form>
</body>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

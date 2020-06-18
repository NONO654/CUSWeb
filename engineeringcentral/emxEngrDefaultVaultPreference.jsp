<%--  emxEngrDefaultVaultPreference.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

</head>
<BODY onload="getTopWindow().turnOffProgress()">

<script>
  // Replace vault dropdown box with vault chooser.
  var txtVault = null;
  var bVaultMultiSelect = false;
  var strTxtVault = "document.VaultPrefForm.vault";

  function showVaultSelector() {
    txtVault = eval(strTxtVault);
    showModalDialog('../components/emxComponentsSelectSearchVaultsDialogFS.jsp?multiSelect=false&fieldName=vault&incCollPartners=true', 300, 350);
  }
</script>

  <form name="VaultPrefForm" method="post"  action="emxEngrDefaultVaultPreferencesProcess.jsp" onsubmit="javascript:submitAndUpdate(); return false">
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.Vault</emxUtil:i18n>
        </td>
        <td class="inputField">
	  <input type="text" name="vault" size="16" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=defaultVault%></xss:encodeForHTMLAttribute>">&nbsp;<input class="button" type="button" size = "200" value="..." alt="..." onClick="javascript:showVaultSelector();" />
          <a href="JavaScript:clearField('VaultPrefForm','vault')" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
        </td>
      </tr>
      <tr>
        <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.ForSession</emxUtil:i18n>
        </td>
        <td class="inputField">
        <table border="0">
          <tr>
            <td><input type="radio" value="CURRENT" name="RDOOption" />
                <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.Current</emxUtil:i18n>
            </td>
          </tr>
          <tr>
            <td><input type="radio" checked value="ALL" name="RDOOption" />
              <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Preferences.All</emxUtil:i18n>
            </td>
          </tr>
          </table>
        </td>
      </tr>
    </table>
    <input type="image" height="1" width="1" border="0" />
  </form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


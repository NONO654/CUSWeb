<%-- emxPrefSetDefaultVaults.jsp -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page

   static const char RCSID[] = "$Id: emxPrefSetDefaultVaults.jsp.rca 1.10 Wed Oct 22 15:48:48 2008 przemek Experimental przemek $"
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no" />
    <meta http-equiv="pragma" content="no-cache" />
    <script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript">
    </script>
    <script language="JavaScript" src="scripts/emxUICore.js"></script>
    <script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript">
    </script>
    <script language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript">
    </script>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
    </script>
  </head>


<%
  String languageStr = request.getHeader("Accept-Language");

  String personSetting = PersonUtil.getSearchDefaultSelection(context);

  if ( personSetting == null || personSetting.equals("") )
  {
      personSetting = EnoviaResourceBundle.getProperty(context, "emxFramework.DefaultSearchVaults");
  }

%>

<body onload="turnOffProgress()">

<form name="searchForm" method="post" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose();" action="emxPrefSetDefaultVaultsProcessing.jsp" >
  <table border="0" cellpadding="5" cellspacing="2" width="100%">

  <tr>
    <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Vault</emxUtil:i18n>&nbsp;</td>
    <td class="inputField">
      <table border="0" cellspacing="1" cellpadding="2">
      <tr>
<%
      String checked = "";
      String contextVault = "";
      if ( PersonUtil.SEARCH_DEFAULT_VAULT.equals(personSetting) )
      {
          checked = "checked";
          contextVault = PersonUtil.getDefaultVault(context);
          personSetting = contextVault;
      }
%>
        <td>
          <!-- //XSSOK -->
          <input name="searchSelection" type="radio" value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" <%=checked%> />
              <emxUtil:i18n localize="i18nId">emxFramework.Preferences.UserDefaultVault</emxUtil:i18n>&nbsp;
              </td>
      </tr>
      <tr>
<%
      checked = "";
      if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(personSetting) )
      {
          checked = "checked";
      }
%>
        <!-- //XSSOK -->
        <td><input name="searchSelection" type="radio" value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" <%=checked%> />
              <emxUtil:i18n localize="i18nId">emxFramework.Preferences.LocalVaults</emxUtil:i18n>&nbsp;
              </td>
      </tr>
      <tr>
<%
      checked = "";
      String vaults = "";
      String selVault = "";
      String selDisplayVault = "";
      if (  !contextVault.equals(personSetting) &&
            !PersonUtil.SEARCH_LOCAL_VAULTS.equals(personSetting) &&
            !PersonUtil.SEARCH_ALL_VAULTS.equals(personSetting) )
      {
           checked = "checked";
           selDisplayVault = i18nNow.getI18NVaultNames(context, personSetting, languageStr);
      }
%>
        <!-- //XSSOK -->
        <td><input type="radio" name="searchSelection" value="<%=PersonUtil.SEARCH_SELECTED_VAULTS%>" <%=checked%> />
              <emxUtil:i18n localize="i18nId">emxFramework.Preferences.SelectedVaults</emxUtil:i18n>&nbsp;

        <input type="text" name="vaultsDisplay" value="<%=selDisplayVault%>" size="15" readonly="readonly" onfocus="this.title=this.value;" onmouseover="this.title=this.value;" title="<%=selDisplayVault%>" /><input name="btnType" type="button" value="..." onclick="javascript:setSelectedVaultOption()" /></td>
        <!-- //XSSOK -->
        <input type="hidden" name="vaults" value="<%=personSetting%>" size="15" />
      </tr>
      <tr>
<%
      checked = "";
      if (  PersonUtil.SEARCH_ALL_VAULTS.equals(personSetting) )
      {
          checked = "checked";
      }
%>
        <!-- //XSSOK -->
        <td><input type="radio" name="searchSelection" value="<%=PersonUtil.SEARCH_ALL_VAULTS%>" <%=checked%> />
              <emxUtil:i18n localize="i18nId">emxFramework.Preferences.AllVaults</emxUtil:i18n>&nbsp;
              </td>
      </tr>
      </table>
    </td>
  </tr>
  </table>
</form>

<script language="JavaScript" type="text/javascript">

  // Method to select the selected vault option
  function setSelectedVaultOption(){
     document.searchForm.searchSelection[2].checked=true;
     showDialog('emxVaultChooser.jsp?fieldNameActual=vaults&fieldNameDisplay=vaultsDisplay&incCollPartners=true&allowNoSelection=true');
  }

</script>

</body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>

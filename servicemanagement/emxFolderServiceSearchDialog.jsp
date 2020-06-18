<%--  emxFolderServiceSearchDialog.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxFolderServiceSearchDialog.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "emxServiceManagementAppInclude.inc"%>

<%
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
  String objectId   	= emxGetParameter(request,"objectId");
  String relType		= emxGetParameter(request,"relType");
  String searchType		= emxGetParameter(request,"searchType");
  String ownerId		= emxGetParameter(request,"personId");
  String HelpMarker		= emxGetParameter(request,"HelpMarker");
  String selType 		= Framework.getPropertyValue(session, searchType);
  String programStr;
  String topActionbarStr;
  if (searchType.equals("type_ServiceFolder")) {
      programStr = "emxServiceFolder:getFolderSearchResult";
      topActionbarStr = "SMTFolderSearchTopActionbar";
  } else {
      programStr = "emxSERVICE:getServiceSearchResult";
 	  topActionbarStr = "SMTServiceSearchTopActionbar";
  }
   
  String mxlimit = JSPUtil.getCentralProperty(application,session,"emxFramework.Search","UpperQueryLimit");
  
  if(mxlimit == null || "null".equals(mxlimit) || "".equals(mxlimit)) {
     mxlimit = "1000";
  }

//returning to page after selecting the owner ellipis.//added
  String initOwner = "*";
  if (ownerId != null && !ownerId.equals(null) && !ownerId.equals("null") && !ownerId.equals(""))
  {
    com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
	   DomainConstants.TYPE_PERSON);
    person.setId(ownerId);
    initOwner = person.getInfo(context, person.SELECT_NAME);
  }

  final String vaultAwarenessString = (String)JSPUtil.getCentralProperty(application, session, "eServiceEngineeringCentral", "VaultAwareness");
  %>
<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  function doSearch() {
    if((document.frmPowerSearch.vaultOption[2].checked==true) && (document.frmPowerSearch.selVaults.value==""))
    {
          alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.VaultOptions.PleaseSelectVault</emxUtil:i18nScript>");
          return;
    }

    document.frmPowerSearch.txtName.value = trimWhitespace(document.frmPowerSearch.txtName.value);
    if (charExists(document.frmPowerSearch.txtName.value, '"')||charExists(document.frmPowerSearch.txtName.value, '\'')||charExists(document.frmPowerSearch.txtName.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtName.focus();
      return;
    }
    document.frmPowerSearch.txtRev.value = trimWhitespace(document.frmPowerSearch.txtRev.value);
    if (charExists(document.frmPowerSearch.txtRev.value, '"')||charExists(document.frmPowerSearch.txtRev.value, '\'')||charExists(document.frmPowerSearch.txtRev.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtRev.focus();
      return;
    }
    document.frmPowerSearch.txtDesc.value = trimWhitespace(document.frmPowerSearch.txtDesc.value);
    if (charExists(document.frmPowerSearch.txtDesc.value, '"')||charExists(document.frmPowerSearch.txtDesc.value, '\'')||charExists(document.frmPowerSearch.txtDesc.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtDesc.focus();
      return;
    }
    document.frmPowerSearch.txtOwner.value = trimWhitespace(document.frmPowerSearch.txtOwner.value);
    if (charExists(document.frmPowerSearch.txtOwner.value, '"')||charExists(document.frmPowerSearch.txtOwner.value, '\'')||charExists(document.frmPowerSearch.txtOwner.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtOwner.focus();
      return;
    }
    document.frmPowerSearch.txtOriginator.value = trimWhitespace(document.frmPowerSearch.txtOriginator.value);
    if (charExists(document.frmPowerSearch.txtOriginator.value, '"')||charExists(document.frmPowerSearch.txtOriginator.value, '\'')||charExists(document.frmPowerSearch.txtOriginator.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtOriginator.focus();
      return;
    }
   
    var strQueryLimit = 100;
    //Added to display search results page.
    if(parent.frames[3] && parent.frames[3].document.bottomCommonForm != null)
    {
        strQueryLimit = parent.frames[3].document.bottomCommonForm.QueryLimit.value;          
    }

    var searchLimit = '<%=mxlimit%>';
    var limit = 0;
    if(strQueryLimit == limit || (parseInt(strQueryLimit) > parseInt(searchLimit))  )
    {
        strQueryLimit = searchLimit;
    }  
    
    document.frmPowerSearch.queryLimit.value = strQueryLimit;
 
    if(jsIsClicked()) {
        alert("<emxUtil:i18nScript  localize="i18nId">emxWSManagement.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
    }
    
    //handle double-click issue
    if(jsDblClick())
    {
        startProgressBar(true);
        document.frmPowerSearch.submit();
    }else
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.Search.RequestProcessMessage</emxUtil:i18nScript>");
    }
  }

  function ClearSearch() {
    document.frmPowerSearch.txtName.value 		= "*";
    document.frmPowerSearch.txtRev.value 		= "*";
    doucment.frmPowerSearch.txtDesc.value		= "*";
    document.frmPowerSearch.txtOwner.value 		= "*";
    document.frmPowerSearch.txtOriginator.value = "*";
  }

  var strTxtVault = "document.forms['frmPowerSearch'].selVaults";
  var txtVault = null;

  <!----------------------------------Vault Code Start--------------------------------------->
  var strSelectOption = "document.forms['frmPowerSearch'].vaultOption[2]";
  var selectOption = null;

    function showVaultSelector()
    {
      txtVault = eval(strTxtVault);
      selectOption = eval(strSelectOption);
      if(!selectOption.checked)
       selectSelectedVaultsOption();
       showChooser("../common/emxVaultChooser.jsp?fieldNameActual=selVaults&action=createCompany");     
    }

    function clearSelectedVaults() {
      document.frmPowerSearch.selVaults.value="";
    }

    function showSelectedVaults() {
      document.frmPowerSearch.selVaults.value=document.frmPowerSearch.tempStore.value;
    }
    function selectSelectedVaultsOption() {
      document.frmPowerSearch.vaultOption[2].checked=true;
    }

<!-----------------------------------Vault Code End-------------------------------------->
  </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<!--
<table border="0" width="100%">
  <tr><td align="right" ><a href='javascript:openHelp("emxhelpsearch","<%--=appDirectory--%>","<%--=lStr--%>")'><img src="../common/images/buttonContextHelp.gif" width="16" height="16" border="0" /></a></td></tr>
</table>
-->

<body>
<form name="frmPowerSearch" method="get" action="../common/emxTable.jsp" target="_parent" onSubmit="return false">
<%
  String suiteKey    = emxGetParameter(request,"suiteKey");
  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
    suiteKey = "eServiceSuiteServiceManagement";
  }
%>
    <input type="hidden" name="objectId" value="<%=objectId%>" />
    <input type="hidden" name="relType" value="<%=relType%>" />
    <input type="hidden" name="txtWhere" value="" />
    <input type="hidden" name="ckSaveQuery" value="" />
    <input type="hidden" name="txtQueryName" value="" />
    <input type="hidden" name="ckChangeQueryLimit" value="" />
    <input type="hidden" name="queryLimit" value="" />
    <input type="hidden" name="fromDirection" value="" />
    <input type="hidden" name="toDirection" value="" />
    <input type="hidden" name="selType" value="<%=selType%>" />
    <input type="hidden" name="table" value="SMTGeneralSearchResult" />
    <input type="hidden" name="selection" value="multiple" />
    <input type="hidden" name="Row Select" value="multiple" />
    <input type="hidden" name="header" value="emxWSManagement.Common.SearchResult" />
    <input type="hidden" name="sortColumnName" value="Name" />
    <input type="hidden" name="sortDirection" value="ascending" />
    <input type="hidden" name="program" value="<%=programStr%>" />
    <input type="hidden" name="suiteKey" value="<%=suiteKey%>" />
    <input type="hidden" name="vault" value="<%=JSPUtil.getVault(context,session)%>" /> 
    <input type="hidden" name="topActionbar" value="<%=topActionbarStr%>" />
    <input type="hidden" name="bottomActionbar" value="" />
    <input type="hidden" name="CancelButton" value="true" />
    <input type="hidden" name="SubmitURL" value="../servicemanagement/emxFolderServiceSearchProcess.jsp" />
    <input type="hidden" name="SubmitButton" value="true" />
    <input type="hidden" name="HelpMarker" value="<%=HelpMarker%>" />
    <input type="hidden" name="Style" value="Dialog" />
    <input type="hidden" name="TransactionType" value="update" />
    

<table border="0" cellspacing="2" cellpadding="3" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
      <input READONLY type="text" value="<%=selType%>" size="16" name="selTypeDisplay" onFocus="this.blur()" onChange="JavaScript:ClearSearch()" />
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*" /></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Revision</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtRev" size="16" value="*" /></td>
  </tr>
    <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Description</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtDesc" size="16" value="*" /></td>
  </tr>
  <!----------------------------------Vault Code Start--------------------------------------->
    <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Vault</emxUtil:i18n></td>
        <td class="inputField">
          <table border="0">
            <tr>
           <td>
                <input type="radio" <%=defaultCheck%> value="DEFAULT_VAULT" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Default</emxUtil:i18n></td>
            
            </tr>
            <tr>
              <td>
                <input type="radio"  <%=localCheck%> value="LOCAL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Local</emxUtil:i18n></td>
            </tr>
            <tr>
              <td>
                <input type="radio" <%=selectedVaults%> value="selected" name="vaultOption" onClick="javascript:showSelectedVaults();" />
              </td>
              <td>
                <emxUtil:i18n localize="i18nId">emxWSManagement.Common.Selected</emxUtil:i18n>
                <input type="text"  READONLY  name="selVaults" size="20" value="<%=selectedVaultsValue%>" onFocus="this.blur()" />
                <input class="button" type="button" size = "200" value="..." alt="..." onClick="javascript:showVaultSelector();" />
                <input type="hidden" name="tempStore" value="<%=selectedVaultsValue%>" />
              </td>
            </tr>
            <tr>
              <td>
                <input type="radio" <%=allCheck%> value="ALL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxWSManagement.Common.All</emxUtil:i18n></td>
            </tr>
          </table>
        </td>
    </tr>
  <!----------------------------------Vault Code End--------------------------------------->
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Owner</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOwner" size="16" value="<%=initOwner%>" /></td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxWSManagement.Common.Originator</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOriginator" size="16" value="*" /></td>
  </tr>

<input type="hidden" name="saveQuery" value="false" />
<input type="hidden" name="changeQueryLimit" value="true" />
<input type="hidden" name="vaultAwarenessString" value="" />

</table>

</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

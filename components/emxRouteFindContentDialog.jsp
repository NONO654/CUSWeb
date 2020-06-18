<%--  emxRouteFindContentDialog.jsp - The content page of the main search

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

    static const char RCSID[] = $Id: emxRouteFindContentDialog.jsp.rca 1.25 Wed Oct 22 16:18:47 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
 String keyValue=emxGetParameter(request,"keyValue");
 int querylimit = 100;
 if (keyValue == null)
 {
   keyValue = formBean.newFormKey(session);
 }
 String sQueryLimit = emxGetParameter(request,"queryLimit");
 String loadPage = emxGetParameter(request, "loadPage");
 if(sQueryLimit == null){
 String mxlimit = EnoviaResourceBundle.getProperty(context,"emxComponents.Search.MaximumLimit");
 if (mxlimit == null || "null".equals(mxlimit) || "".equals(mxlimit))
 {
   mxlimit = "0";
 }
	 querylimit = Integer.parseInt(mxlimit.trim()); 
 }else{
	 querylimit = Integer.parseInt(sQueryLimit);
 }

 formBean.processForm(session,request,"keyValue");
 String sContentId = (String)session.getValue("RouteContent");
 String routeName1  =  (String) formBean.getElementValue("routeName");
 String relatedone  =  (String) formBean.getElementValue("scopeId");

 String languageStr = request.getHeader("Accept-Language");
 String appDirectory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.Directory");
 
 String sDefaultType = emxGetParameter(request,"selType");
 String sDefaultDisplayType = emxGetParameter(request,"selTypeDisplay");
 if(sDefaultType == null){
 String sDefaultSymbolicType = JSPUtil.getApplicationProperty(context,application, "emxComponents.Routes.DefaultContentType");
 if ((sDefaultSymbolicType == null) || ("".equals(sDefaultSymbolicType)))
   sDefaultSymbolicType = "type_Document";

	 sDefaultType = PropertyUtil.getSchemaProperty(context, sDefaultSymbolicType);
	 sDefaultDisplayType = i18nNow.getAdminI18NString("Type", sDefaultType, languageStr); 
 }
 
	    String nameVal = emxGetParameter(request,"txtName");
	    nameVal = (nameVal == null) ? "*" : nameVal;
	    String revisionVal = emxGetParameter(request,"txtRev");
	    revisionVal = (revisionVal == null) ? "*" : revisionVal;
	    String descriptionVal = emxGetParameter(request,"txtDesc");
	    descriptionVal = (descriptionVal == null) ? "*" : descriptionVal;
	    String ownerVal = emxGetParameter(request,"txtOwner");
	    ownerVal = (ownerVal == null) ? "*" : ownerVal;
	    String orignatorVal = emxGetParameter(request,"txtOriginator");
	    orignatorVal = (orignatorVal == null) ? "*" : orignatorVal;


/*****************************Vault Code Start*********************************/
  // Display Vault Field as options
  String sGeneralSearchPref ="";
  String allCheck ="";
  String defaultCheck ="";
  String localCheck ="";
  String selectedVaults ="";
  String selectedVaultsValue ="";
  String selectedVaultsDisplay = "";
  boolean searchPersonVaults = false;

  String selVaultsVal = emxGetParameter(request, "selVaults");
  if(selVaultsVal != null){
	  selVaultsVal = UIUtil.isNullOrEmpty(selVaultsVal) ? emxGetParameter(request,"vaultOption") : selVaultsVal;  
  }else{
	  selVaultsVal = PersonUtil.getSearchDefaultSelection(context);
	  searchPersonVaults = true;
  }
  if(selVaultsVal.equals(PersonUtil.SEARCH_ALL_VAULTS)) {
    allCheck="checked";
  }else if (selVaultsVal.equals(PersonUtil.SEARCH_LOCAL_VAULTS)){
    localCheck="checked";
  }else if (selVaultsVal.equals(PersonUtil.SEARCH_DEFAULT_VAULT)) {
    defaultCheck="checked";
  } else {
    selectedVaults="checked";
      if(searchPersonVaults){
    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    selectedVaultsValue = person.getSearchDefaultVaults(context);
  	      selectedVaultsDisplay = selectedVaultsValue;
      }else{
    	  selectedVaultsValue = selVaultsVal;
    	  selectedVaultsDisplay = emxGetParameter(request, "selVaultsDisplay");
      }
  }
  /*******************************Vault Code End*******************************/
  %>
<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }
  function doSearch() {
  //added for the   form  not to submitted more than once

	var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
  	document.frmPowerSearch.queryLimit.value = strQueryLimit;

    if (!jsDblClick()) {
            return;
  }
<%
  	if(!relatedone.equals("Organization")) {
%>
    	if((document.frmPowerSearch.vaultOption[2].checked==true) && (document.frmPowerSearch.selVaults.value=="")) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VaultOptions.PleaseSelectVault</emxUtil:i18nScript>");
          return;
    }
 <%
 }
 %>

    document.frmPowerSearch.txtName.value = trimWhitespace(document.frmPowerSearch.txtName.value);
    if (charExists(document.frmPowerSearch.txtName.value, '"')||charExists(document.frmPowerSearch.txtName.value, '\'')||charExists(document.frmPowerSearch.txtName.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtName.focus();
      return;
    }
    document.frmPowerSearch.txtRev.value = trimWhitespace(document.frmPowerSearch.txtRev.value);
    if (charExists(document.frmPowerSearch.txtRev.value, '"')||charExists(document.frmPowerSearch.txtRev.value, '\'')||charExists(document.frmPowerSearch.txtRev.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtRev.focus();
      return;
    }
    document.frmPowerSearch.txtDesc.value = trimWhitespace(document.frmPowerSearch.txtDesc.value);
    if (charExists(document.frmPowerSearch.txtDesc.value, '"')||charExists(document.frmPowerSearch.txtDesc.value, '\'')||charExists(document.frmPowerSearch.txtDesc.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtDesc.focus();
      return;
    }
    document.frmPowerSearch.txtOwner.value = trimWhitespace(document.frmPowerSearch.txtOwner.value);
    if (charExists(document.frmPowerSearch.txtOwner.value, '"')||charExists(document.frmPowerSearch.txtOwner.value, '\'')||charExists(document.frmPowerSearch.txtOwner.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtOwner.focus();
      return;
    }
    document.frmPowerSearch.txtOriginator.value = trimWhitespace(document.frmPowerSearch.txtOriginator.value);
    if (charExists(document.frmPowerSearch.txtOriginator.value, '"')||charExists(document.frmPowerSearch.txtOriginator.value, '\'')||charExists(document.frmPowerSearch.txtOriginator.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
      document.frmPowerSearch.txtOriginator.focus();
      return;
    }
    if(document.frmPowerSearch.selTypeDisplay.value == "<%=XSSUtil.encodeForJavaScript(context,sDefaultDisplayType)%>") {
      document.frmPowerSearch.table.value = "AppFolderSearchResult";
    }
        startProgressBar();
        document.frmPowerSearch.submit();
  }

  function ClearSearch() {
    document.frmPowerSearch.txtName.value = "*";
    document.frmPowerSearch.txtRev.value = "*";
    document.frmPowerSearch.txtOwner.value = "*";
    document.frmPowerSearch.txtOriginator.value = "*";
    document.frmPowerSearch.txtWhere.value="";
  }

  var bAbstractSelect = true;
  function showTypeSelector() {
    bAbstractSelect = true;
    var strURL="emxRouteFindContentTypes.jsp?fieldNameActual=selType&fieldNameDisplay=selTypeDisplay&formName=frmPowerSearch&ShowIcons=true&ObserveHidden=false&SelectType=&SelectAbstractTypes="+bAbstractSelect; // modified on 9th feb for bug 281784

  showModalDialog(strURL, 450, 350);
  }

  var bVaultMultiSelect = true;
  var strTxtVault = "document.forms['frmPowerSearch'].selVaults";
  var txtVault = null;

  var strSelectOption = "document.forms['frmPowerSearch'].vaultOption[3]";
  var selectOption = null;

  function showVaultSelector() {
      txtVault = eval(strTxtVault);
      selectOption = eval(strSelectOption);
      showChooser("../common/emxVaultChooser.jsp?fieldNameActual=selVaults&fieldNameDisplay=selVaultsDisplay");
      
     //showModalDialog("emxComponentsSelectSearchVaultsDialogFS.jsp?fieldName=selVaults", 300, 350);
    }

    function clearSelectedVaults() {
      document.frmPowerSearch.selVaults.value="";
      document.frmPowerSearch.selVaultsDisplay.value="";
    }

    function showSelectedVaults() {
      document.frmPowerSearch.selVaults.value=document.frmPowerSearch.tempStore.value;
    }
  
    function selectSelectedVaultsOption() {
      document.frmPowerSearch.vaultOption[2].checked=true;
    }

  </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>


<body>
<form name="frmPowerSearch" method="get" action="../common/emxTable.jsp" target="_parent" onSubmit="javascript:doSearch();return false">
<%
 String suiteKey    = (String)formBean.getElementValue("suiteKey");

  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
    suiteKey = "eServiceSuiteComponents";
  }

  //where should the content page get submitted
  String invokePurpose = (String)formBean.getElementValue("invokePurpose");
  if (invokePurpose == null) {
    invokePurpose = "";
  }
%>

    <input type="hidden" name="txtWhere" value=""/>
    <input type="hidden" name="ckSaveQuery" value=""/>
    <input type="hidden" name="txtQueryName" value=""/>
    <input type="hidden" name="ckChangeQueryLimit" value=""/>
    <input type="hidden" name="queryLimit" value="<%=querylimit%>"/>
    <input type="hidden" name="fromDirection" value=""/>
    <input type="hidden" name="toDirection" value=""/>
    <input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sDefaultType%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="table" value="AppGeneralSearchResult"/>
    <input type="hidden" name="selection" value="multiple"/>
    <input type="hidden" name="header" value="emxComponents.Common.Search"/>
    <input type="hidden" name="sortColumnName" value="Name"/>
    <input type="hidden" name="sortDirection" value="ascending"/>
    <input type="hidden" name="program" value="emxAppContent:getSearchResult"/>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="vault" value="<xss:encodeForHTMLAttribute><%=JSPUtil.getVault(context,session)%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="topActionbar" value=""/>
    <input type="hidden" name="bottomActionbar" value="APPRouteWizardContentSearchActionBar"/>
    <input type="hidden" name="CancelButton" value="true"/>
    <input type="hidden" name="SubmitURL" value="../components/emxContentSearchProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context,keyValue)%>&invokePurpose=<%=invokePurpose%>"/>
    <input type="hidden" name="SubmitButton" value="true"/>
    <input type="hidden" name="HelpMarker" value="emxhelpsearch"/>
    <input type="hidden" name="Style" value="Dialog"/>
    <input type="hidden" name="CancelLabel" value="emxComponents.Common.Close"/>
    <input type="hidden" name="TransactionType" value="update"/>
    <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
	<input type="hidden" name="sContentId" value="<%=sContentId%>"/>
	<input type="hidden" name="fromType" value="Route"/>
	<input type="hidden" name="loadPage" value="<xss:encodeForHTMLAttribute><%=loadPage%></xss:encodeForHTMLAttribute>"/>

    <%
    if( (relatedone.equals("Organization")) || (relatedone.equals("All")) ) {
%>
        <input type="hidden" name="scopeId" value=""/>
<%
    }else{
%>

        <input type="hidden" name="scopeId" value="<%=relatedone%>"/>
<%
}
  final String vaultAwarenessString = (String)JSPUtil.getCentralProperty(application, session, "eServiceEngineeringCentral", "VaultAwareness");
  %>

<table border="0" cellspacing="2" cellpadding="3" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
       <input type="text" readonly="readonly" size="16" name="selTypeDisplay" onchange="JavaScript:ClearSearch()" value="<xss:encodeForHTMLAttribute><%=sDefaultDisplayType%></xss:encodeForHTMLAttribute>" />
      <input type="button" value="..." onClick="showTypeSelector()" />
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="<xss:encodeForHTMLAttribute><%=nameVal%></xss:encodeForHTMLAttribute>"/></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtRev" size="16" value="<xss:encodeForHTMLAttribute><%=revisionVal%></xss:encodeForHTMLAttribute>"/></td>
  </tr>
    <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtDesc" size="16" value="<xss:encodeForHTMLAttribute><%=descriptionVal%></xss:encodeForHTMLAttribute>"/></td>
  </tr>
 <%
  	if(!relatedone.equals("Organization")) {
%>
    <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Vault</emxUtil:i18n></td>
        <td class="inputField">
          <table border="0">
            <tr>
        <td>
                <input type="radio" <%=defaultCheck%> value="DEFAULT_VAULT" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxComponents.Common.Default</emxUtil:i18n></td>

            </tr>
            <tr>
              <td>
                <input type="radio"  <%=localCheck%> value="LOCAL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxComponents.Common.Local</emxUtil:i18n></td>
            </tr>
            <tr>
              <td>
                <input type="radio" <%=selectedVaults%> value="<%=selectedVaultsValue%>" name="vaultOption" onClick="javascript:showSelectedVaults();" />
              </td>
              <td>
                <emxUtil:i18n localize="i18nId">emxComponents.Common.Selected</emxUtil:i18n>
                 <input type="text"  readonly="readonly"  name="selVaultsDisplay" size="20" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
                 <input type="hidden"  name="selVaults" value="<%=selectedVaultsValue%>" >
                <input class="button" type="button" size = "200" value="..." onClick="javascript:showVaultSelector();selectSelectedVaultsOption()" />
                <input type="hidden" name="tempStore" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
              </td>
            </tr>
            <tr>
              <td>
                <input type="radio" <%=allCheck%> value="ALL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();" />
              </td>
              <td><emxUtil:i18n localize="i18nId">emxComponents.Common.All</emxUtil:i18n></td>
            </tr>
          </table>
        </td>
    </tr>
<%
  }
%>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOwner" size="16" value="<xss:encodeForHTMLAttribute><%=ownerVal%></xss:encodeForHTMLAttribute>"/></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOriginator" size="16" value="<xss:encodeForHTMLAttribute><%=orignatorVal%></xss:encodeForHTMLAttribute>"/></td>
  </tr>

<input type="hidden" name="saveQuery" value="false"/>
<input type="hidden" name="changeQueryLimit" value="true"/>
<input type="hidden" name="vaultAwarenessString" value=""/>
</table>
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

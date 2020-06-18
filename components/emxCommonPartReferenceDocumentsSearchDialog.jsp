<%--  emxCommonPartReferenceDocumentsSearchDialog.jsp

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
    String mxlimit = JSPUtil.getCentralProperty(application,session,"emxFramework.Search","UpperQueryLimit");
    if(mxlimit == null || "null".equals(mxlimit) || "".equals(mxlimit))
    {
        mxlimit = "1000"; 
    }
%>

<script language="Javascript">
    function frmChecking(strFocus)
    {
        var strPage=strFocus;
    }

    var clicked = false;   

    function doSearch() 
    {
        if (clicked)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
            return;
        }
        //var strQueryLimit = parent.frames[3].document.bottomCommonForm.QueryLimit.value;
        var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
        // search limit validation
		//XSSOK
        var searchLimit = '<%=mxlimit%>';
        var limit = 0;  
        if(strQueryLimit == limit || (parseInt(strQueryLimit) > parseInt(searchLimit))  )
        {
            strQueryLimit = searchLimit;
        }
        document.frmPartSearch.queryLimit.value = strQueryLimit;

        if((document.frmPartSearch.vaultOption[3].checked==true) && (document.frmPartSearch.Vault.value==""))
        {
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VaultOptions.PleaseSelectVault</emxUtil:i18nScript>");
              return;
        }
        if(document.frmPartSearch.vaultOption[3].checked==true)
        {
            document.frmPartSearch.vaultOption[3].value=document.frmPartSearch.Vault.value;
        }

        startSearchProgressBar(true);
        clicked = true;

        document.frmPartSearch.submit();
        return;
    }

</script>

<%
    String languageStr = request.getHeader("Accept-Language");
    String suiteKey    = emxGetParameter(request,"suiteKey");
  

    String sDocumentType = (String)EnoviaResourceBundle.getProperty(context,"emxComponents.ReferenceDocumentTypes");

    String sPartType="*";
    String validtypes ="";
    StringList typeList = new StringList();
    StringTokenizer types = new StringTokenizer(sDocumentType,",");

    while(types.hasMoreTokens())
    {
        String typeVal = PropertyUtil.getSchemaProperty(context,types.nextToken().trim());
        if (typeVal != null && !"null".equalsIgnoreCase(typeVal) && !"".equals(typeVal))
        {
            if ("".equals(validtypes))
            {
                validtypes = typeVal+",";
            }
            else
            {
                validtypes += typeVal;
                validtypes += ",";
            }
            typeList.addElement(typeVal);
        }
    }

    String errorString = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource.properties", context.getLocale(), "emxComponents.ReferenceDocuments.InvalidType");

    if ("".equals(validtypes))
    {
        throw new MatrixException(errorString);
    }
    else
    {
        sDocumentType = validtypes;
        sPartType = (String) typeList.get(0);
    }

    String strSelectedTypes = emxGetParameter(request,"selType");
    if(strSelectedTypes != null && !"".equals(strSelectedTypes))
    {
        sPartType = strSelectedTypes;
    }
    
    // following logic is to get the list of types, internationalized names and to check
    // if the policy of any type is having a state "Release".
    
    StringBuffer strSelectedTypeDisplay = new StringBuffer();
    StringTokenizer strTokenTypes = new StringTokenizer(sPartType,",");
    String strTempType = "";
    
    boolean doNotShowReleasedRevisionOption = false;
    
    BusinessTypeList busTypeListToGetPolicies = null;
    BusinessType busType = null;
    BusinessTypeList busTypeList = null;
    PolicyList polList = null;
    Policy policy = null;
    String strPolicyProperty = "";
	String strReleaseState = "";
    StateRequirementList stateReqList = null;
    StateRequirement stateReq = null;
    int size1 = 0;
    int size2 = 0;
    
    while(strTokenTypes.hasMoreTokens())
    {
        if(strSelectedTypeDisplay.length() > 0)
        {
            strSelectedTypeDisplay.append(",");
        }
        strTempType = strTokenTypes.nextToken();
        strSelectedTypeDisplay.append(i18nNow.getTypeI18NString(strTempType,languageStr));
        
        if(!doNotShowReleasedRevisionOption)
        {
            busType = new BusinessType(strTempType,context.getVault());
            
            busTypeListToGetPolicies = new BusinessTypeList();
            busTypeListToGetPolicies.addElement(busType);
            
            busTypeList = busType.getChildren(context);
            if(busTypeList != null && busTypeList.size() > 0 )
            {
                busTypeListToGetPolicies.addAll(busTypeList);
            }
            int size = busTypeListToGetPolicies.size();
            
            for( int k = 0 ; (k < size && !doNotShowReleasedRevisionOption) ; k++)
            {
                busType = (BusinessType)busTypeListToGetPolicies.get(k);

                polList = busType.getPolicies(context);
        
                if(polList != null && (size1 = polList.size()) > 0 )
                {
                    for(int i = 0 ; (i < size1 && !doNotShowReleasedRevisionOption) ; i++)
                    {
                        policy = (Policy)polList.get(i);

						//Added for Bug: 308765
						strPolicyProperty = "emxComponents.ReleaseState."+policy.getName().replace(' ','_');
						
						try{
							strReleaseState = (String)EnoviaResourceBundle.getProperty(context,strPolicyProperty);
						}catch(FrameworkException fex){
							strReleaseState = PropertyUtil.getSchemaProperty(context
																			  ,"policy"
																			  ,policy.getName()
																			  ,"state_Release");
							if(strReleaseState == null || (strReleaseState.length() == 0))
							{
								doNotShowReleasedRevisionOption = true;
								break;
							}
						}
                    }
                }
            }
        }
    }

%>

<script>
  var bAbstractSelect = true;

  function showTypeSelector() {
	  //XSSOK
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=selType&ReloadOpener=true&fieldNameDisplay=selTypeDisp&formName=frmPartSearch&ShowIcons=true&InclusionList=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sDocumentType)%>&ObserveHidden=true&SelectType=multiselect&SelectAbstractTypes="+bAbstractSelect;
    showModalDialog(strURL, 450, 350);
  }
    
  function reload()
  {
    document.frmPartSearch.action="emxCommonPartReferenceDocumentsSearchDialog.jsp";
    document.frmPartSearch.target="_self";
    document.frmPartSearch.submit();
  }
  
  var bVaultMultiSelect = true;
  var strTxtVault = "document.forms[\"frmPartSearch\"].Vault.value";
  var txtVault = null;
  
  var strSelectOption = "document.forms['frmPartSearch'].vaultOption[3]";
  var selectOption = null;

  function showVaultSelector() {
      txtVault = eval(strTxtVault);
      selectOption = eval(strSelectOption);
      showModalDialog("../components/emxComponentsSelectSearchVaultsDialogFS.jsp?multiSelect="+bVaultMultiSelect+"&fieldName=Vault&incCollPartners=true&selectedVaults="+txtVault,300,350);
  }

  function clearSelectedVaults() {
    document.frmPartSearch.tempStore.value=document.frmPartSearch.Vault.value
    document.frmPartSearch.vaultOption[3].value="";
    document.frmPartSearch.Vault.value="";
  }

  function showSelectedVaults() {
    document.frmPartSearch.Vault.value=document.frmPartSearch.tempStore.value;
  }
  
  function selectSelectedVaultsOption() {
    document.frmPartSearch.vaultOption[3].checked=true;
  }


  function clearField(formName,fieldName)
  {
      var operand = "document." + formName + "." + fieldName+".value = \"\";";
         eval (operand);
         return;
  }

  </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<form name="frmPartSearch" method="post" action="../common/emxTable.jsp" target="_top" onsubmit="javascript:doSearch(); return false">
<input type="hidden" name="objectId" value="<%=emxGetParameter(request, "objectId")%>"/>
<input type="hidden" name="ckSaveQuery" value=""/>
<input type="hidden" name="txtQueryName" value=""/>
<input type="hidden" name="ckChangeQueryLimit" value=""/>
<input type="hidden" name="fromDirection" value=""/>
<input type="hidden" name="toDirection" value=""/>
<input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sPartType%></xss:encodeForHTMLAttribute>"/>

<table cellspacing="2" cellpadding="3" border="0" width="100%" >
<tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
      <input type="text" size="16" name="selTypeDisp" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strSelectedTypeDisplay.toString()%></xss:encodeForHTMLAttribute>"/>
      <input type="button" value="..." onclick="javascript:showTypeSelector();"/>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*"/></td>
  </tr>

   <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtDesc" size="16" value="*"/></td>
  </tr>
  
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtRev" size="16" value="*"/></td>
  </tr>  
  <tr>
      <td class="label"></td>
      <td class="inputField">

      <table  border="0" cellspacing="0" cellpadding="0" align="left">

       <tr>
          <td class="inputField">
            <input type="radio" name="revPattern" value="ALL_REVISIONS" checked /><emxUtil:i18n localize="i18nId">emxComponents.Common.ShowAllRevisions</emxUtil:i18n>
          </td>
        </tr>
        <tr>
          <td class="inputField">
            <input type="radio" name="revPattern" value="HIGHEST_REVISION" <%=((doNotShowReleasedRevisionOption)?"disabled":"")%> /><emxUtil:i18n localize="i18nId">emxComponents.Common.ShowHighestReleasedRevisions</emxUtil:i18n>
          </td>
        </tr>
        <tr>
          <td class="inputField">
            <input type="radio" name="revPattern" value="HIGHEST_AND_PRESTATE_REVS"  <%=((doNotShowReleasedRevisionOption)?"disabled":"")%> /><emxUtil:i18n localize="i18nId">emxComponents.Common.ShowHighestReleasedun-ReleasedRevisions</emxUtil:i18n>
          </td>
        </tr>

        <tr>
          <td class="inputField">
            <input type="radio" name="revPattern" value="LATEST_REVS"  /><emxUtil:i18n localize="i18nId">emxComponents.ReferenceDocumentSearch.ShowLatestRevisions</emxUtil:i18n>
          </td>
        </tr>
      </table>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOwner" size="16" value="*"/></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOriginator" size="16" value="*"/></td>
  </tr>
<%
    String companyVault = (String)session.getAttribute("emxComponents.companyVault");
    if (companyVault != null) //use person's company vault and do not allow edit
    {
%>
      <input type="hidden" name="Vault" value="<xss:encodeForHTMLAttribute><%=companyVault%></xss:encodeForHTMLAttribute>"/>
<%
    }
    else
    {
        /*********************************Vault Code Start*****************************************/
        // Display Vault Field as options
        
        String allCheck ="";
        String defaultCheck ="";
        String localCheck ="";
        String selectedVaults ="";
        String selectedVaultsValue ="";

        String sGeneralSearchPref = com.matrixone.apps.common.Person.getPropertySearchVaults(context);

        // Check the User SearchVaultPreference Radio button
        if(sGeneralSearchPref.equals("ALL_VAULTS")  || sGeneralSearchPref.equals("")) {
            allCheck="checked";
        } else if (sGeneralSearchPref.equals("LOCAL_VAULTS")){
            localCheck="checked";
        } else if (sGeneralSearchPref.equals("DEFAULT_VAULT")) {
            defaultCheck="checked";
        } else {
            selectedVaults="checked";
            com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
            selectedVaultsValue = person.getSearchDefaultVaults(context);
        }
        /***********************************Vault Code End***************************************/    
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Vault</emxUtil:i18n></td>
      <td class="inputField">
        <table border="0">
            <tr>
                <td>
                    <input type="radio" <%=allCheck%> value="ALL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();"/>
                </td>
                <td>
                    <emxUtil:i18n localize="i18nId">emxComponents.VaultOptions.All</emxUtil:i18n>
                </td>
            </tr>
            <tr>
                <td>
                    <input type="radio"  <%=localCheck%> value="LOCAL_VAULTS" name="vaultOption" onClick="javascript:clearSelectedVaults();"/>
                </td>
                <td>
                    <emxUtil:i18n localize="i18nId">emxComponents.VaultOptions.Local</emxUtil:i18n>
                </td>
            </tr>
            <tr>
                <td>
                    <input type="radio" <%=defaultCheck%> value="DEFAULT_VAULT" name="vaultOption" onClick="javascript:clearSelectedVaults();"/>
                </td>
                <td>
                    <emxUtil:i18n localize="i18nId">emxComponents.VaultOptions.Default</emxUtil:i18n>
                </td>
            </tr>
            <tr>
                <td>
                    <input type="radio" <%=selectedVaults%> value="<%=selectedVaultsValue%>" name="vaultOption" onClick="javascript:showSelectedVaults();"/>
                </td>
                <td>
                    <emxUtil:i18n localize="i18nId">emxComponents.VaultOptions.Selected</emxUtil:i18n>
                    <input type="text" name="Vault" size="20" value="<%=selectedVaultsValue%>" readonly="readonly"/>
                    <input class="button" type="button" size = "200" value="..." onClick="javascript:showVaultSelector();selectSelectedVaultsOption()"/>
                    <input type="hidden" name="tempStore" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
                </td>
            </tr>
        </table>
      </td>
    </tr>
<%
    }


%>
  

<input type="hidden" name="mode" value="powersearch"/>
<input type="hidden" name="saveQuery" value="false"/>
<input type="hidden" name="changeQueryLimit" value="true"/>
<input type="hidden" name="queryLimit" value=""/>
<input type="hidden" name="program" value="emxCommonPart:getReferenceDocumentsSearchResults"/>
<input type="hidden" name="table" value="APPRefDocumentsSearchResults"/>
<input type="hidden" name="topActionbar" value="APPRefDocumentsSearchResultsHeader"/>
<input type="hidden" name="header" value="emxComponents.ReferenceDocuments.Select"/>
<input type="hidden" name="selection" value="multiple"/>
<input type="hidden" name="SubmitURL" value="../components/emxCommonPartAddReferenceDocumentsProcess.jsp"/>
<input type="hidden" name="CancelButton" value="true"/>
<input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="HelpMarker" value="emxhelpfindselectresults"/>
<input type="hidden" name="Style" value="dialog"/>
<input type="hidden" name="listMode" value="search"/>
<input type="hidden" name="vaultAwarenessString" value="<xss:encodeForHTMLAttribute><%=vaultAwarenessString%></xss:encodeForHTMLAttribute>"/>

</table>
  </form>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

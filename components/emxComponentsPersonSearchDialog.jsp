<%--  emxComponentsPersonSearchDialog.jsp - The basics page for Person Search

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

   static const char RCSID[] = $Id: emxComponentsPersonSearchDialog.jsp.rca 1.10 Wed Oct 22 16:18:37 2008 przemek Experimental przemek $
--%>
<%
  // ----------------- Include Static Pages Here ------------------------------
%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>


<script language="javascript">

/*This function is needed to support AEF Global Search*/
  function doSearch()
  {
    if(jsIsClicked()) {
        alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
    }
    var objForm = document.editDataForm;
    objForm.target = "searchView";
    objForm.action="../common/emxTable.jsp?selection=multiple&toolbar=APPSearchResultToolbar&header=emxSpecificationCentral.Heading.SearchResult";
    if(jsDblClick()) {
        startSearchProgressBar();
        objForm.submit();
    }
  }

/* This function is added for the Enter Key functionality*/

function submitForm()
{
  bottomFrame = findFrame(getTopWindow(),"BottomFrame");
  if(bottomFrame == null)
  {
     parent.doFind();
  }
  else
  {
    bottomFrame.validateLimit();
  }
}

  function showVaultSelector()
  {
       showChooser('../common/emxVaultChooser.jsp?fieldNameActual=vaultName&fieldNameDisplay=vaultNameDisplay&action=createCompany&multiSelect=false');
  }

</script>

<%
  Enumeration enumParamNames = emxGetParameterNames(request);
  MapList companyList      = null;
  String paramName         = "";
  String paramValue        = "";
  String timeStamp         = emxGetParameter(request,"timeStamp");
  String queryLimit        = emxGetParameter(request,"queryLimit");
  String pagination        = emxGetParameter(request,"pagination");
  String previousCommand   = emxGetParameter(request,"previousCommand");
  String commandName       = emxGetParameter(request,"CommandName");
  String strSearchMode     = emxGetParameter(request,"searchmode");
  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  if(queryLimit == null || queryLimit.trim().length() == 0 ) 
  {
    queryLimit = "100";
  }
  String UserName           = emxGetParameter(request,"UserName");
  String FirstName          = emxGetParameter(request,"FirstName");
  String LastName           = emxGetParameter(request,"LastName");
  String Company            = emxGetParameter(request,"Company");

  com.matrixone.apps.common.Company contextComp = person.getCompany(context);
  String contextCompanyName = contextComp.getInfo(context,DomainObject.SELECT_NAME);
  String contextCompanyId   = contextComp.getInfo(context,DomainObject.SELECT_ID);
  
  StringList companyIdList  = new StringList();
  StringList companyNameList= new StringList();
  Iterator itr              = null;
  Map companyMap            = null;

  if(UserName == null || UserName.trim().length() == 0) 
  {
    UserName = DomainObject.QUERY_WILDCARD;
  }
  if(FirstName == null || FirstName.trim().length() == 0) 
  {
    FirstName = DomainObject.QUERY_WILDCARD;
  }
  if(LastName == null || LastName.trim().length() == 0) 
  {
    LastName = DomainObject.QUERY_WILDCARD;
  }

  if(Company == null || Company.trim().length() == 0) 
  {
    Company = contextCompanyName;
  } else {
    DomainObject companyObj = DomainObject.newInstance(context);
    companyObj.setId(Company);
    Company = companyObj.getName(context);
  }
  String selVaultOption = emxGetParameter(request,"vaultOption");

  String selVaultOptionAll = "";
  String selVaultOptionDefault = "";
  String selVaultOptionSelected = "checked";
  if(selVaultOption == null || selVaultOption.trim().length() == 0) {
    selVaultOptionAll = "";
    selVaultOptionDefault = "";
    selVaultOptionSelected = "checked";
  } else if (selVaultOption.equals("All")) {
    selVaultOptionAll = "checked";
    selVaultOptionDefault = "";
    selVaultOptionSelected = "";
  } else if (selVaultOption.equals("Default")) {
    selVaultOptionAll = "";
    selVaultOptionDefault = "checked";
    selVaultOptionSelected = "";
  } else if (selVaultOption.equals("Selected")) {
    selVaultOptionAll = "";
    selVaultOptionDefault = "";
    selVaultOptionSelected = "checked";
  }

  String selVaultName = emxGetParameter(request,"vaultName");

  if(previousCommand == null || previousCommand.trim().length() == 0) 
  {
    previousCommand = commandName;
  }
  if(!previousCommand.equals(commandName)) 
  {
    UserName = DomainObject.QUERY_WILDCARD;
    FirstName = DomainObject.QUERY_WILDCARD;
    LastName = DomainObject.QUERY_WILDCARD;
    Company = contextCompanyName;
  }
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<body onload="turnOffProgress(),getTopWindow().loadSearchFormFields()">
<form name="editDataForm" method="post" onSubmit="submitForm(); return false;">
<%
  while(enumParamNames.hasMoreElements())
  {
      paramName = (String) enumParamNames.nextElement();
      paramValue = (String)emxGetParameter(request, paramName);
      if(!paramName.equals("UserName") &&
         !paramName.equals("FirstName") &&
         !paramName.equals("LastName") &&
         !paramName.equals("Role") &&
         !paramName.equals("Company") &&
         !paramName.equals("vaultOption") &&
         !paramName.equals("vaultName") &&
         !paramName.equals("queryLimit") &&
         !paramName.equals("timeStamp") &&
         !paramName.equals("pagination") &&
         !paramName.equals("previousCommand")) 
         {
%>
            <input type="hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context,paramName)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,paramValue)%>" />
<%
         }
  }

  if("AddExisting".equalsIgnoreCase(strSearchMode))
  {
    companyMap = new HashMap();
    companyMap.put(DomainObject.SELECT_ID,contextCompanyId);
    companyMap.put(DomainObject.SELECT_NAME,contextCompanyName);
    companyList = new MapList(1);
    companyList.add(companyMap);  
  }
  else
  {
    StringList objectSelect = new StringList(2);
    objectSelect.add(DomainObject.SELECT_NAME);
    objectSelect.add(DomainObject.SELECT_ID);    
    
    companyList= com.matrixone.apps.common.Company.getCompanies(context,DomainObject.QUERY_WILDCARD,objectSelect,null);
  }
  itr = companyList.iterator();
  while(itr.hasNext())
  {
     companyMap = (Map)itr.next();
     companyIdList.add((String) companyMap.get(DomainObject.SELECT_ID));
     companyNameList.add((String) companyMap.get(DomainObject.SELECT_NAME));
  }
%>
  <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,queryLimit)%>" name ="queryLimit" />
  <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,queryLimit)%>" name ="QueryLimit" />
  <input type="hidden" name="timeStamp" value="<%=XSSUtil.encodeForHTMLAttribute(context,timeStamp)%>" />
  <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,pagination)%>" name ="pagination" />
  <input type="hidden" value ="<%=XSSUtil.encodeForHTMLAttribute(context,commandName)%>" name ="CommandName" />

<table border="0" cellpadding="5" cellspacing="2" width="100%">
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.UserName</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="UserName" size="16" value="<%=XSSUtil.encodeForHTMLAttribute(context,UserName)%>" /></td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.FirstName</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="FirstName" size="16" value="<%=XSSUtil.encodeForHTMLAttribute(context,FirstName)%>" /></td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.LastName</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="LastName" size="16" value="<%=XSSUtil.encodeForHTMLAttribute(context,LastName)%>" /></td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Company</emxUtil:i18n></td>
    <td class="inputField">
        <select name="Company" >
          <framework:optionList optionList="<%=companyNameList%>"   valueList="<%=companyIdList%>" selected="<%=Company%>" />
        </select>
    </td>
  </tr>
    <tr>
      <td nowrap="nowrap" class="label">
        <framework:i18n localize="i18nId">emxComponents.Common.Vault</framework:i18n>
      </td>
      <td nowrap="nowrap" class="field">

<%
    String vaultAwareness = EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.VaultAwareness");
    String strVaults = "";
    if(selVaultName != null && selVaultName.trim().length() != 0) 
    {
        strVaults = selVaultName;
    } else {
      strVaults = person.getVault();
    }
    if (vaultAwareness.equalsIgnoreCase("FALSE")) 
    {
%>
         <input type="radio" value="All"  <%=selVaultOptionAll%> name="vaultOption"><emxUtil:i18n localize="i18nId">emxComponents.Form.Radio.All</emxUtil:i18n><br/>
         <input type="radio" value="Default" <%=selVaultOptionDefault%> name="vaultOption" /><emxUtil:i18n localize="i18nId">emxComponents.Form.Radio.Default</emxUtil:i18n><br/>
         <input type="radio" value="Selected" <%=selVaultOptionSelected%> name="vaultOption" /><emxUtil:i18n localize="i18nId">emxComponents.Form.Radio.Selected</emxUtil:i18n>
         <input type="hidden" name="vaultName" value ="<%=XSSUtil.encodeForHTMLAttribute(context,strVaults)%>" />
         <input type="text" name="vaultNameDisplay" value ="<%=XSSUtil.encodeForHTMLAttribute(context,strVaults)%>" id="" size="20" readonly="readonly" />
         <input type="button" name="" value="..." onClick="javascript:showVaultSelector();" />
<%
    } else {
%>
      <xss:encodeForHTML><%=strVaults%></xss:encodeForHTML>
<%
    }
%>
      </td>
    </tr>

</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

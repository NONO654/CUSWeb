<%--  emxComponentsAddExistingPersonSearchDialog.jsp - The basics page for Person Search

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

   static const char RCSID[] = $Id: emxComponentsAddExistingPersonSearchDialog.jsp.rca 1.12 Wed Oct 22 16:17:47 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  DomainObject DomObj = DomainObject.newInstance(context);
  com.matrixone.apps.common.Person PersonObj = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                      DomainConstants.TYPE_PERSON);

%>

<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  function doSearch() {
    if(jsIsClicked()) {
        alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
    }
    if(document.frmPersonSearch.userName.value == "" ||
       document.frmPersonSearch.firstName.value == "" ||
       document.frmPersonSearch.lastName.value == "" ||
       (document.frmPersonSearch.companyName && document.frmPersonSearch.companyName.value == ""))
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.PleaseEnterDetails</emxUtil:i18nScript>");
    }
    else {
      //var strQueryLimit = parent.frames[3].document.bottomCommonForm.QueryLimit.value;
      var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
      document.frmPersonSearch.queryLimit.value = strQueryLimit;
      if(jsDblClick()) {
        startSearchProgressBar();
        document.frmPersonSearch.submit();
      }
    }
    return;
  }

  function ClearSearch() {
    document.frmPersonSearch.userName.value = "*";
    document.frmPersonSearch.firstName.value = "*";
    document.frmPersonSearch.lastName.value = "*";
    if(document.frmPersonSearch.companyName) {
      document.frmPersonSearch.companyName.value = "*";
    }
  }
  var strTxtVault = "document.forms['frmPersonSearch'].Vault";
  var txtVault = null;

  function showVaultSelector() {
      txtVault = eval(strTxtVault);
      showModalDialog('emxSelectVaultDialog.jsp', 300, 350);
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String objectId         = emxGetParameter(request,"objectId");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String multiSelect      = emxGetParameter(request,"multiSelect");
  String typeAlias        = emxGetParameter(request,"typeAlias");
  String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
  String defaultCompany     = emxGetParameter(request,"defaultCompany");
  String lbcAccess     = emxGetParameter(request,"lbcAccess");
  // Only one line added - Nishchal
  String keyValue = emxGetParameter(request,"keyValue");
  String callPage = emxGetParameter(request,"callPage");
  if(callPage == null || callPage.equals("null")) {
      callPage ="";
  }

  String sDefaultVault  = "";
  String compId         ="";
  String orgVault       ="";
  String personId       ="";

  if(defaultCompany == null || defaultCompany.equals("null")|| defaultCompany.equals("")) {
     com.matrixone.apps.common.Person person1 = com.matrixone.apps.common.Person.getPerson(context);
     defaultCompany = person1.getCompany(context).getName();
  }

  BusinessObject boPerson = JSPUtil.getPerson(context, session);
  boPerson.open(context);
  sDefaultVault = boPerson.getVault();
  personId      = boPerson.getObjectId();
  boPerson.close(context);

  PersonObj.setId(personId);
  compId=PersonObj.getCompanyId(context);

  BusinessObject bussObj = new  BusinessObject(compId);
  bussObj.open(context);
  orgVault = bussObj.getVault();
  bussObj.close(context);

  String actionString = "emxComponentsAddExistingPersonSearchResultsFS.jsp";
%>
<!-- //XSSOK -->
<form name="frmPersonSearch" method="post" action=<%=actionString%> target="_parent" onSubmit="doSearch(); return false;">

<table cellspacing="5" cellpadding="2" border="0" width="100%" >
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="targetSearchPage" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="multiSelect" value="<xss:encodeForHTMLAttribute><%=multiSelect%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="form" value="<xss:encodeForHTMLAttribute><%=parentForm%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="field" value="<xss:encodeForHTMLAttribute><%=parentField%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="typeAlias" value="<xss:encodeForHTMLAttribute><%=typeAlias%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="showCompanyAsLabel" value="<xss:encodeForHTMLAttribute><%=showCompanyAsLabel%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="defaultCompany" value="<xss:encodeForHTMLAttribute><%=defaultCompany%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="lbcAccess" value="<xss:encodeForHTMLAttribute><%=lbcAccess%></xss:encodeForHTMLAttribute>" />

  <!-- Nishchal  Added KeyValue -->
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%= keyValue %></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="callPage" value="<xss:encodeForHTMLAttribute><%= callPage %></xss:encodeForHTMLAttribute>"/>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.UserName</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="userName" size="16" value="*"/></td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.FirstName</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="firstName" size="16" value="*"/></td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.LastName</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="lastName" size="16" value="*"/></td>
  </tr>

<%
// Added Nishchal - Advanced Object Level Security Feature
if("emxComponentsObjectAccessUsersDialog".equalsIgnoreCase(callPage))
{
%>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Company</emxUtil:i18n></td>
    <td class="inputField">
     <select name="companyName">
     <option Value="*"><emxUtil:i18n localize="i18nId">emxComponents.Search.Star</emxUtil:i18n></option>
<%
    //Get the list of companies in the system
    StringList selectList = new StringList(1);
    selectList.add(Company.SELECT_NAME);
    MapList companyList = Company.getCompanies(context,
                                         "*",
                                         selectList,
                                         null);

    Iterator companyItr = companyList.iterator();
    while(companyItr.hasNext()) {
        Map companyMap = (Map)companyItr.next();
        String companyNameStr = (String)companyMap.get(Company.SELECT_NAME);
%>
      	<option value="<%=XSSUtil.encodeForHTMLAttribute(context, companyNameStr)%>" ><%=XSSUtil.encodeForHTML(context, companyNameStr)%> </option>
<%
     }
%>
    </select>
    </td>
 </tr>
<% 
}
else {
%>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Company</emxUtil:i18n></td>
	<!-- XSSOK -->
    <framework:ifExpr expr='<%= "true".equalsIgnoreCase(showCompanyAsLabel) %>'>
	    <td class="inputField">
	      <%=XSSUtil.encodeForHTML(context, defaultCompany)%>
	      <input type="hidden" name="companyName" value="<%=XSSUtil.encodeForHTMLAttribute(context, defaultCompany)%>"/>
	    </td>
  	</framework:ifExpr>
	<!-- XSSOK -->
  	<framework:ifExpr expr='<%= !"true".equalsIgnoreCase(showCompanyAsLabel) %>'>
     	<td class="inputField"><input type="text" name="companyName" size="16" value="<%=XSSUtil.encodeForHTMLAttribute(context, defaultCompany)%>"/></td>
  	</framework:ifExpr>
  </tr>
<%
}
%>

</table>

<input type="hidden" name="queryLimit" value=""/>

</form>

<%@include file = "emxComponentsDesignBottomInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

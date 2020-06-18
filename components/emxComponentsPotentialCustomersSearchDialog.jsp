<%-- emxComponentsPotentialSupplierSearchDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPotentialCustomersSearchDialog.jsp.rca 1.8 Wed Oct 22 16:17:52 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%

  String strTypeName = request.getParameter("typename");
  String objectId   = emxGetParameter(request,"objectId");

  if(strTypeName == null || "null".equals(strTypeName) || "".equals(strTypeName)){
    strTypeName = "Company";
  }
  if(objectId == null || "null".equals(objectId) || "".equals(objectId)){
    objectId = emxGetParameter(request,"parentOID");
  }
  String languageStr  = request.getHeader("Accept-Language");
  String strCompanyHeading = EnoviaResourceBundle.getProperty(context, "emxSupplierCentralNetStringResource", context.getLocale(), "emxSupplierSourcing.PotentialCustomers.SearchCompany"); 
  String strBUHeading = EnoviaResourceBundle.getProperty(context, "emxSupplierCentralNetStringResource", context.getLocale(), "emxSupplierSourcing.PotentialCustomers.SearchBusinessUnit");
%>
<script language="javascript">
  function doSearch() 
  {
    if(jsIsClicked()) {
        alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
    }
    if(jsDblClick()) {
        startProgressBar(true);
        document.searchform.submit();
    }
    return;
  }

  function closeWindow() 
  {
    window.closeWindow();
    return;
  }

  function clear() 
  {
    document.searchform.txtType.value="";
    document.searchform.txtType.focus();
  }
  
</script>



<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<form name="searchform" id="searchform" method="post" onSubmit="parent.frames[2].doFind(); return false;" target="_parent" action="emxComponentsPotentialCustomersSearchResultsFS.jsp">
<input type="hidden" name="typename" value="<xss:encodeForHTMLAttribute><%=strTypeName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="pagination" value=""/>
<input type="hidden" name="QueryLimit" value=""/>
  <table border="0" cellpadding="5" cellspacing="2" width="100%">
<%
    if(strTypeName.equals("Company")) {
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
      <td class="inputField"><img src="../common/images/iconSmallCompany.gif" border="0"name="Company" id="Company" alt="<emxUtil:i18n localize='i18nId'>emxComponents.Common.Company</emxUtil:i18n>"/> <emxUtil:i18n localize="i18nId">emxComponents.Common.Company</emxUtil:i18n></td>
    </tr>
<%
   } else  if(strTypeName.equals("BU")) {

%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
      <td class="inputField"><img src="../common/images/iconSmallBusinessUnit.gif" border="0"name="BU" id="BU" alt="<emxUtil:i18n localize='i18nId'>emxComponents.Common.BusinessUnit</emxUtil:i18n>"/> <emxUtil:i18n localize="i18nId">emxComponents.Common.BusinessUnit</emxUtil:i18n></td>
    </tr>
     
<%
 }
%>
    <tr>
      <td class="label">
          <emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>
      </td>
      <td class="inputField">
          <input type="text" name="txtName" id="txtName" value="*"/>
      </td>
    </tr>
  </table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

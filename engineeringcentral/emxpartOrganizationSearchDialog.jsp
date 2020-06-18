<%--  emxpartOrganizationSearchDialog.jsp - The content page of the main search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="Javascript">
  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  var clicked = false;   

  function doSearch() {

      if (clicked) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
      }

    var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
    document.frmPowerSearch.queryLimit.value = strQueryLimit;

    document.frmPowerSearch.txtName.value = trimWhitespace(document.frmPowerSearch.txtName.value);
    if (charExists(document.frmPowerSearch.txtName.value, '"')||charExists(document.frmPowerSearch.txtName.value, '\'')||charExists(document.frmPowerSearch.txtName.value, '#')){
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
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
  String isPartEdit     = emxGetParameter(request,"isPartEdit");
  String objectId       = emxGetParameter(request,"objectId");
  String role = emxGetParameter(request,"role");

  // Added for MCC EC Interoperability Feature
  String sFieldManufacturerLocationIdDisplay = emxGetParameter(request,"fieldManufacturerLocation");
  String sFieldManufacturerLocationId = emxGetParameter(request,"fieldManufacturerLocationId");
  String searchMode = emxGetParameter(request,"searchMode");
  //end 
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="frmPowerSearch" method="get" action="emxpartOrganizationSearchResultsFS.jsp" target="_parent" onSubmit="javascript:doSearch(); return false">

<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="form" value="<xss:encodeForHTMLAttribute><%=parentForm%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="field" value="<xss:encodeForHTMLAttribute><%=parentField%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="fieldId" value="<xss:encodeForHTMLAttribute><%=parentFieldId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="fieldRev" value="<xss:encodeForHTMLAttribute><%=parentFieldRev%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="isPartEdit" value="<xss:encodeForHTMLAttribute><%=isPartEdit%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="role" value="<xss:encodeForHTMLAttribute><%=role%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="searchMode" value="<xss:encodeForHTMLAttribute><%=searchMode%></xss:encodeForHTMLAttribute>" />
<%
 // Added for MCC EC Interoperability Feature
 if(sFieldManufacturerLocationId != null &&  !"null".equalsIgnoreCase(sFieldManufacturerLocationId) && !"".equals(sFieldManufacturerLocationId)) 
 {
%>
        <input type="hidden" name="fieldManufacturerLocation" value="<xss:encodeForHTMLAttribute><%=sFieldManufacturerLocationIdDisplay%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="fieldManufacturerLocationId" value="<xss:encodeForHTMLAttribute><%=sFieldManufacturerLocationId%></xss:encodeForHTMLAttribute>" />
<% 
 }
 //end
%>

<table border="0" cellspacing="2" cellpadding="3" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
<%
	if(searchMode !=null && searchMode.equals("Manufacturer"))
	{
	%>
	<td class="inputField">
      <select name="searchtype" >
      <!-- XSSOK -->
        <option selected value="<%=PropertyUtil.getSchemaProperty(context, "type_BusinessUnit")%>" ><%=PropertyUtil.getSchemaProperty(context, "type_BusinessUnit")%></option>
          <!-- XSSOK -->
       <option value="<%=PropertyUtil.getSchemaProperty(context, "type_Company")%>"><%=PropertyUtil.getSchemaProperty(context, "type_Company")%></option>
      </select>
    </td>
    </td>
	<%}else{%>
	<td class="inputField">
      <select name="searchtype" >
        <!-- XSSOK -->
        <option selected value="<%=DomainObject.TYPE_ORGANIZATION%>" ><%=i18nNow.getTypeI18NString(DomainObject.TYPE_ORGANIZATION, languageStr)%></option>
      
<%
              BusinessType busType = new BusinessType(DomainObject.TYPE_ORGANIZATION, new Vault((String)((com.matrixone.apps.common.Person.getPerson(context)).getCompany(context).getVault())));
              busType.open(context);
              BusinessTypeList busTypeList = busType.getChildren(context);
              busType.close(context);
              Iterator itr = busTypeList.iterator();
              String sTypeValue="";

              while(itr.hasNext()) {
                sTypeValue = ((BusinessType)itr.next()).getName();
				
				// Added for RCO 
				if(session.getAttribute("ExcludePlant")!=null && sTypeValue.equals(PropertyUtil.getSchemaProperty(context,"type_Plant")))
					continue;
%>
				  <!-- XSSOK -->
                <option value="<%= sTypeValue %>"><%=i18nNow.getTypeI18NString(sTypeValue, languageStr)%></option>
<%
              }
%>
      </select>

    </td>
	<%}%>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*" /></td>
  </tr>

</table>
   <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
</form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

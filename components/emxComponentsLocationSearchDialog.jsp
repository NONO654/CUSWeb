 <%--  emxComponentsLocationSearchDialog.jsp   -  Search for members in the company
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsLocationSearchDialog.jsp.rca 1.5.6.5 Wed Oct 22 16:18:12 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxJSValidationUtil.js"></script>

<%
    String fieldName = emxGetParameter(request,"fieldName");
    String fieldOId = emxGetParameter(request,"fieldOId");
    String sSelection = emxGetParameter(request,"selection");
    String sSubmitURL = emxGetParameter(request,"SubmitURL");
    String sformName   = emxGetParameter(request,"formName");
    String companyId   = emxGetParameter(request,"companyId");
    // MCC Bug fix 328078, need to show only Active Locations
    String sDefaultStates   = emxGetParameter(request,"defaultStates");
    
    if(sSelection==null)
    {
      sSelection = "multiple";
    }
%>

<script>
   function doSearch()
   {
    var varName  = trimWhitespace(document.findDialog.Name.value);
    var varAddressName = trimWhitespace(document.findDialog.txt_address.value);
    var varCityName  = trimWhitespace(document.findDialog.txt_city.value);
    var varStateName = trimWhitespace(document.findDialog.txt_state.value);
    var varPostalCodeName  = trimWhitespace(document.findDialog.txt_postalcode.value);

    if(varName=="") 
    {
       document.findDialog.Name.value ="*";
    } 
    
    if(varAddressName=="") 
    {
       document.findDialog.txt_address.value ="*";
    } 
    
    if(varCityName=="") 
    {
       document.findDialog.txt_city.value = "*";
    } 
    
    if(varStateName=="") 
    {
       document.findDialog.txt_state.value = "*";
    }
    
    if(varPostalCodeName=="") 
    {
       document.findDialog.txt_postalcode.value = "*";
    }

    if(jsDblClick()) 
    {
      startProgressBar(true);
      document.findDialog.submit();
    }
    return;
  }
</script>
<form name="findDialog" method="post" onSubmit="doSearch(); return false" target="_parent" action="../common/emxTable.jsp"">

  <table border="0" cellpadding="5" cellspacing="2" width="100%">

    <tr>
      <td width="150" nowrap  class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
      <td nowrap  width="380" class="inputField"><img src="../common/images/iconSmallLocation.gif" border="0"name="imgLocation" id="imgLocation" alt="<emxUtil:i18n localize='i18nId'>emxComponents.Common.Location</emxUtil:i18n>" /> <emxUtil:i18n localize="i18nId">emxComponents.Common.Location</emxUtil:i18n></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="Name" value="*" size="20"/></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="Address"><emxUtil:i18n localize="i18nId">emxComponents.Common.Address</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="txt_address" value="*" size="20"/></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="city"><emxUtil:i18n localize="i18nId">emxComponents.Common.City</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="txt_city" value="*" size="20"/></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="state"><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="txt_state" value="*" size="20"/></td>
    </tr>

    <tr>
     <td width="150" class="label"><label for="postalcode"><emxUtil:i18n localize="i18nId">emxComponents.Common.PostalCode</emxUtil:i18n></label></td>
     <td width="380" class="inputField"><input type="Text" name="txt_postalcode" value="*" size="20"/></td>
    </tr>

   </table>

    <input type="hidden" name="table" value="APPLocationsSearchSummary"/>
    <input type="hidden" name="program" value="emxLocation:getLocationSearchResults"/>
    <input type="hidden" name="toolbar" value=""/>
    <input type="hidden" name="header" value="emxComponents.FindLike.Common.Results"/>
    <input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=sSelection%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="companyId" value="<%=XSSUtil.encodeForHTMLAttribute(context,companyId)%>"/>
    <input type="hidden" name="SubmitURL" value="<%=XSSUtil.encodeForURL(context,sSubmitURL)%>?fieldOId=<%=XSSUtil.encodeForURL(context,fieldOId)%>&fieldName=<%=XSSUtil.encodeForURL(context,fieldName)%>&formName=<%=XSSUtil.encodeForURL(context,sformName)%>"/>
    <input type="hidden" name="SubmitButton" value="true"/>
    <input type="hidden" name="CancelButton" value="true"/>
    <input type="hidden" name="CancelLabel" value="emxComponents.Button.Close"/>
    <input type="hidden" name="HelpMarker" value="emxhelpselectuserresults"/>
    <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=request.getHeader("Accept-Language")%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="sortColumnName" value="Name"/>
    <input type="hidden" name="sortDirection" value="ascending"/>
    <input type="hidden" name="suiteKey" value="Components"/>
    <input type="hidden" name="StringResourceFileId" value="emxComponentsStringResource"/>
    <input type="hidden" name="SuiteDirectory" value="components"/>
    <input type="hidden" name="Style" value="Dialog"/>
    <input type="hidden" name="defaultStates" value="<xss:encodeForHTMLAttribute><%=sDefaultStates%></xss:encodeForHTMLAttribute>"/>

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

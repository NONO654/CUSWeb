 <%--  emxComponentsCreateRegionDialog.jsp-  Displays the screen to create a new Region

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxComponentsCreateRegionDialog.jsp.rca 1.8 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $"
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@ include file = "../emxJSValidation.inc" %>

<%
String companyId = emxGetParameter(request,"objectId");
boolean bBackPage= false;
String CREATE = "Create";

%>

<script language="Javascript">
  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

  function closeWindow() {
      window.closeWindow();
      return;
  }
  function submit() {
    var sTextValue =  trim(document.formRegion.RegionName.value ) ;
     if(sTextValue == "") {
       alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.NameAlert</emxUtil:i18nScript>");
       document.formRegion.RegionName.focus();
       return;
     }
     document.formRegion.RegionName.value   = sTextValue;
     document.formRegion.description.value = trim(document.formRegion.description.value);
    var namebadCharacters = checkForNameBadCharsList(document.formRegion.RegionName);
    if(namebadCharacters.length != 0){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInvalidName</emxUtil:i18nScript>"+namebadCharacters);
      return;
    }
    badCharacters = checkForBadChars(document.formRegion.description);
    if(badCharacters.length != 0){
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidDescription</emxUtil:i18nScript>"+badCharacters);
      return;
    }

    if(jsDblClick())
    {
      document.formRegion.submit();
      return;
    }else{
      return;
    }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>



<form name="formRegion" method="post" action="emxComponentsRegionUtil.jsp" onSubmit="submit(); return false;">
<input type="hidden" name="companyId" value="<%= XSSUtil.encodeForHTMLAttribute(context,companyId) %>" />
<input type="hidden" name="mode" value="<%=CREATE%>" />
<table border="0" width="100%" cellpadding="5">
  <tr>
    <td width="200" class="labelRequired">  <emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n> </td>
    <td width="500" class="inputField">
      <input type="text" value='' name='RegionName' size='20' maxlength='80' />
    </td>
  </tr>
 <tr>
    <td class="label" valign="top"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></td>
    <td class="inputField">
     <textarea rows="4" name="description" cols="35" wrap></textarea>
    </td>
  </tr>
</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


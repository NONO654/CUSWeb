<!--  ImportXMLStructure.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

-->
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.domain.Job"%>
<script language="javascript" src="../components/emxComponentsJSFunctions.js">
</script>

<script language="javascript">
   // function to call import
   function submitImport()
   {
      var sTextValue =  jsTrim(document.frmImportData.file.value) ;
      if (sTextValue == "")
      {
         alert("<emxUtil:i18nScript localize='i18nId'>emxRequirements.Alert.ImportFileNotSelected</emxUtil:i18nScript>");
         document.frmImportData.file.focus();
         return;
      }

      turnOnProgress(true);
      document.frmImportData.mode.value="import";
      document.frmImportData.submit();
   }
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<form name="frmImportData" method="post" enctype="multipart/form-data" action="ImportXMLStructureBG.jsp?<%=request.getQueryString()%>"  target="_parent" >
  <input type="hidden" name="mode" value="" />
  <table width="100%" border="0" cellspacing="3" cellpadding="2">
    <tr>
      <td class="labelRequired" >
         <emxUtil:i18n localize="i18nId">RIF-XML File to be imported</emxUtil:i18n>
      </td>
      <td class="inputField">
         <input type="file" name="file"></input>
      </td>
    </tr>
    <tr>
      <td class="label" >
         <emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n>
      </td>
      <td class="inputField">
         <textarea name="description" rows="5" cols="36" wrap></textarea>
      </td>
    </tr>
  </table>
</form>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<%--  emxCollectionsDuplicateDialog.jsp   - Dialog page to take input for creating a Collection.

   Copyright (c) 2004-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxCollectionsDuplicateDialog.jsp.rca 1.2.3.2 Wed Oct 22 15:47:48 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="JavaScript" src="scripts/emxUICollections.js" type="text/javascript"></script>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>


<%
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String strSelectedCollections = emxGetParameter(request,"selectedCollections");
%>
  

<script language="Javascript" >

  function cancelMethod()
  {
     parent.window.closeWindow();
  }

  function doneMethod()
  {
         var nameValue = document.editForm.collectionName.value;

         //is nameValue empty?
         if(trimWhitespace(nameValue).length == 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Collections.PleaseEnterCollectionName</emxUtil:i18nScript>");
            return;
         }
                 
         var nameCheckValue = checkForNameBadChars(nameValue,false);
         var nameCheckLength = checkForNameLength128(nameValue,false);

         //validate if values for all required fields are entered
         if(nameValue==null || nameValue=="")
         {
            alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Collections.NewCollection</emxUtil:i18nScript>");
            document.editForm.collectionName.focus();
            return;
         }
         else if (charExists(nameValue, '"')||charExists(nameValue, '#')||(nameCheckValue == false))
         {
            alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.InvalidName</emxUtil:i18nScript>");
            document.editForm.collectionName.focus();
            return;
         }else if (!nameCheckLength) {
             alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Create.NameColumn</emxUtil:i18nScript>");
             document.editForm.collectionName.focus();
             return;
          }
         else
         {
            document.editForm.submit();
         }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<BODY OnLoad="document.editForm.collectionName.focus();">
<form name="editForm" method="post" onsubmit="doneMethod(); return false" action="emxCollectionsDuplicateDialogProcess.jsp">
    <table border="0" width="100%" cellpadding="5" cellspacing="2">
            <tr>
                <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></td>
                <td class="inputField"><input type="text" name="collectionName" size="25"  onFocus="this.select()" />
                </td>
            </tr>
          <tr>
            <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Description</emxUtil:i18n></td>
            <td class="field"><textarea cols="25" rows="5" name="collectionDescription"  onFocus="this.select()"></textarea></td>
          </td>
          </tr>
    </table>
    <input type="hidden" name="selectedCollections" value="<xss:encodeForHTMLAttribute><%=strSelectedCollections%></xss:encodeForHTMLAttribute>" />
</form>
</Body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%--  emxCollectionsEditDialog.jsp   - Dialog page to take input for editing a Collection.

   Copyright (c) 2003-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxCollectionsEditDialog.jsp.rca 1.18 Wed Oct 22 15:48:25 2008 przemek Experimental przemek $
--%>
   
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.SetUtil,
                com.matrixone.apps.domain.util.XSSUtil"
%>
<%@include file = "../emxTagLibInclude.inc" %>

<script language="JavaScript" src="scripts/emxUICollections.js" type="text/javascript"></script>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>

<%
  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String strSetId = emxGetParameter(request, "relId");
  String objectName = SetUtil.getCollectionName(context, strSetId);
  String sCharSet    = Framework.getCharacterEncoding(request);

 %>

<script language="Javascript" >

  function cancelMethod()
  {
     getTopWindow().closeWindow();
  }
  var originalName = "<%=objectName%>";//XSSOK
  function doneMethod()
  {
     var nameValue = document.editForm.collectionName.value;
     nameValue = nameValue.trim();
     document.editForm.nameChanged.value = !(nameValue == originalName);
      if (!isValidLength(nameValue, 1, 127)){
         alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ErrorMsg.ValidateLength</emxUtil:i18nScript>");
         document.editForm.collectionName.focus();
         return;
       }

     var nameCheckValue = checkForNameBadChars(nameValue,false);
     var nameCheckLength = checkForNameLength128(nameValue,false);
     var namebadCharName = checkForNameBadChars(document.editForm.collectionName, true);
     var name = document.editForm.collectionName.name;
     var nameAllBadCharName = getAllNameBadChars(document.editForm.collectionName);
     var descCheckValue = checkForBadChars(document.editForm.description);

     //validate that all required fields are entered
     if(nameValue==null || nameValue=="") {
        alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Collections.NewCollection</emxUtil:i18nScript>");
        document.editForm.collectionName.focus();
        return;
     } else if (charExists(nameValue, '"')|| charExists(nameValue, '#')||(nameCheckValue == false)) {
         alert("<emxUtil:i18nScript localize="i18nId">emxFramework.FormComponent.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxFramework.FormComponent.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxFramework.FormComponent.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxFramework.FormComponent.Alert.Field</emxUtil:i18nScript>"); 
        document.editForm.collectionName.focus();
        return;
     } else if (descCheckValue.length != 0) {
         alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertInValidChars</emxUtil:i18nScript>"+descCheckValue+"<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
         document.editForm.description.focus();
         return;
     } else if (!nameCheckLength) {
         alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Create.NameColumn</emxUtil:i18nScript>");
         document.editForm.collectionName.focus();
         return;
      }else {
        document.editForm.submit();
     }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%

    long collectionCnt = SetUtil.getCount(context, objectName);

    // ----------- set up the url to do the edit and refresh itself.
    StringBuffer editURL = new StringBuffer("emxCollectionsEditProcess.jsp?objectName=");
    
    editURL.append(XSSUtil.encodeForURL(context, objectName));
    editURL.append("&jsTreeID=");
    editURL.append(XSSUtil.encodeForURL(context,jsTreeID));
    editURL.append("&suiteKey=");
    editURL.append(XSSUtil.encodeForURL(context, suiteKey));
    editURL.append("&relId=");
    editURL.append(XSSUtil.encodeForURL(context,strSetId));
    String output = MqlUtil.mqlCommand(context, "list property on set $1 ;",objectName );
    int endNameIndex = output.indexOf("value");
    String  dbDesc ="";

    if(endNameIndex > -1)
    dbDesc = output.substring(endNameIndex+6);

    if(dbDesc.equalsIgnoreCase("null")||  dbDesc==null)
    dbDesc="";
%>
<!-- \\XSSOK -->
<form name="editForm" method="post" onsubmit="doneMethod(); return false" action="<%=editURL.toString()%>">
<table border="0" width="100%" cellpadding="5" cellspacing="2">
  <tr>
    <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="collectionName" size="25" value="<%=objectName%>" onFocus="this.select()" /><!-- XSSOK -->
    <input type="hidden" name="nameChanged" value="false" />
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Common.Description</emxUtil:i18n></td>
    <td class="inputField">
        <textarea cols="25" rows="5" name="description"  onFocus="this.select()"><xss:encodeForHTML><%=dbDesc%></xss:encodeForHTML></textarea>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Collections.ItemCount</emxUtil:i18n></td>
    <td class="field"><%=collectionCnt%>&nbsp;</td>
  </tr>
</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

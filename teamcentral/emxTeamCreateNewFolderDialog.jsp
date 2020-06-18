<%--  emxTeamCreateNewFolderDialog.jsp   -   Display Create New Folder Dialg
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateNewFolderDialog.jsp.rca 1.29 Wed Oct 22 16:06:36 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String projectId                 = emxGetParameter(request,"objectId");
  String folderName                = emxGetParameter(request,"folderName");
  String templateId                = emxGetParameter(request, "templateId");
  String template                  = emxGetParameter(request, "template");
  boolean isFMAInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionFolderManagement",false,null,null);

  if(folderName == null) {
    folderName = "";
  }
%>

<script language="javascript">

  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

  function submitForm() {
    var sTextValue =  trim(document.createDialog.folderName.value ) ;
    var description =  trim(document.createDialog.folderDescription.value ) ;
    var namebadCharName = checkForUnifiedNameBadChars(document.createDialog.folderName, true );
    var nameAllBadCharName = getAllNameBadChars(document.createDialog.folderName);
    var name = document.createDialog.folderName.name;
    var namebadCharDescrption = checkForBadChars(document.createDialog.folderDescription);
    document.createDialog.folderName.value        = sTextValue;
    document.createDialog.folderDescription.value = description;
    if (namebadCharName.length != 0){
    	alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxTeamCentral.Alert.Field</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
     }
    else if (!(isAlphanumeric(sTextValue, true))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.FolderName.NameAlert</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
    }
    else if(!(isValidLength(sTextValue, 1,115))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.FolderName.NameLengthAlertMessage</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
    }
    else if(sTextValue == "") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterName</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
    }
    else if(namebadCharDescrption.length != 0) {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      document.createDialog.folderDescription.focus();
      return;
    }
    else if(description == "") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterDisp</emxUtil:i18nScript>");
      document.createDialog.folderDescription.focus();
      return;
    }
    else {
        if(jsDblClick())
        {
                startProgressBar(true);
                document.createDialog.submit();
                return;
        }else
        {
                alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
                return;
        }
    }
}

  function showDefindFolder() {
   emxShowModalDialog("emxTeamPreDefinedFolderDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, projectId)%>", 575, 575);
  }

  function closeWindow() {
      parent.window.closeWindow();
      return;
  }

  function clear() {
    if(trim(document.createDialog.folderName.value) !=null) {
      document.createDialog.folderName.value="";
    }
    return;
  }


</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="createDialog" method="post" onSubmit="return false" action="emxTeamCreateNewFolderProcess.jsp">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>"/>
  <table>
    <tr>
      <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></label>&nbsp;</td>
      <td class="field"><input type="text" name="folderName" size="20" value="<xss:encodeForHTMLAttribute><%=folderName%></xss:encodeForHTMLAttribute>"/><input type="button" name="folderButton" id="folderButton" value="..." onClick="javascript:showDefindFolder()"/>&nbsp;<a href="javascript:clear()"><emxUtil:i18n localize="i18nId">emxTeamCentral.common.Clear</emxUtil:i18n></a></td>
    </tr>
    <tr>
      <td class="labelRequired"><label for="Description"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></label></td>
      <td class="field" ><textarea name="folderDescription" value="" cols="40" rows="5" wrap></textarea></td>
    </tr>
     <tr>
      <td class="label"><label for="AccessType"><emxUtil:i18n localize="i18nId">emxTeamCentral.WorkspaceVault.AccessType</emxUtil:i18n></label></td>
         <td class="inputField">
    <table border="0">
      <tr>
        <td>
          <input type="radio" name="AccessType" id="AccessType" value="Inherited" checked>
          <emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Yes</emxUtil:i18n>
        </td>
      </tr>
      <tr>
        <td>
          <input type="radio" name="AccessType" id="AccessType" value="Specific">
          <emxUtil:i18n localize="i18nId">emxTeamCentral.Common.No</emxUtil:i18n>
        </td>
      </tr>
    </table>
  </td>
 </tr>
 <% if(isFMAInstalled){ %>
	<tr>
     <td class="label"><label for="PublishOnConnect"><emxUtil:i18n localize="i18nId">emxTeamCentral.Attribute.Publish_On_Connect</emxUtil:i18n></label></td>
        <td class="inputField">
    <table border="0">
      <tr>
        <td>
          <select name="PublishOnConnect" id="PublishOnConnect">
          <option value="True" ><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.True</emxUtil:i18n></option>
          <option value="False" selected="selected"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.False</emxUtil:i18n></option>
           </select>
        </td>
      </tr>
      
    </table>
  </td>

    </tr>
	 <%} %>
    
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


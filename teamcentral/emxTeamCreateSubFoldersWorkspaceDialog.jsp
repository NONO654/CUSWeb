<%--   emxTeamCreateSubFoldersWorkspaceDialog.jsp -- To create a subfolder for a folder object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTeamCreateSubFoldersWorkspaceDialog.jsp.rca 1.26 Wed Oct 22 16:05:57 2008 przemek Experimental przemek $";
--%>

<%@include file ="../emxUICommonAppInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String sObjectId    = emxGetParameter(request, "objectId");
  String sFolderId    = emxGetParameter(request, "folderId");
  String callPage     = emxGetParameter(request,"callPage");
  boolean isFMAInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionFolderManagement",false,null,null);

%>

<script language="javascript">

  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

  function submitform() {

    var nameValue =trim(document.createDialog.Name.value);
    var descriptionValue =trim(document.createDialog.Description.value);
    var namebadCharName = checkForUnifiedNameBadChars(document.createDialog.Name, true);
    var nameAllBadCharName = getAllNameBadChars(document.createDialog.Name);
    var name = document.createDialog.Name.name;
    var namebadCharDescrption = checkForBadChars(document.createDialog.Description);
    if (namebadCharName.length != 0){
    	alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxTeamCentral.Alert.Field</emxUtil:i18nScript>");
      document.createDialog.Name.focus();
      return;
     }
    else if ( nameValue == "" ) {
      alert ("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateSubFoldersWorkspaceDialog.AlertSubCategoryName</emxUtil:i18nScript>");
      document.createDialog.Name.focus();
      return;
    }
    else if(!(isValidLength(nameValue, 1,115))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateSubFoldersWorkspaceDialog.NameLengthAlertMessage</emxUtil:i18nScript>");
      document.createDialog.Name.focus();
      return;
    }
    else if (!(isAlphanumeric(nameValue, true))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.createDialog.Name.focus();
      return;
    }
    else if(namebadCharDescrption.length != 0) {
     alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
     document.createDialog.Description.focus();
     return;
    }
     else if(descriptionValue == "") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterDisp</emxUtil:i18nScript>");
      document.createDialog.Description.focus();
      return;   
    }
    else {
                if(jsDblClick())
                {
                        startProgressBar(true);
                        document.createDialog.action = "emxTeamCreateSubFolders.jsp?callPage=" + "<%=XSSUtil.encodeForURL(context, callPage)%>";
                        document.createDialog.submit();
                        return;
                }else
                {
                        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
                        return;
                }
    }
}
  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String strFolderId = emxGetParameter(request, "objectId");
  BusinessObject boFolder = new BusinessObject(strFolderId);
  boFolder.open(context);
  String strCategoryName = boFolder.getName();
  boFolder.close(context);
%>

<form name="createDialog" method="post" onSubmit="return false" action="emxTeamCreateSubFolders.jsp">
  <input type="hidden" name ="objectId" value="<xss:encodeForHTMLAttribute><%=strFolderId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name ="folderId" value="" />

  <table>
    <tr>
      <td  nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></label></td>
      <td nowrap  class="field"><input type="Text" name="Name" value="" size="20" />
    </tr>
    <tr>
      <td  nowrap  class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Parent</emxUtil:i18n></label></td>
      <td nowrap  class="field"><img src="images/iconSmallFolder_new.png" id=""/>&nbsp;<xss:encodeForHTML><%=strCategoryName%></xss:encodeForHTML></td>
    <tr>
      <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></label></td>
      <td class="field" ><textarea name="Description" cols="40" rows="5" wrap></textarea></td>
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
	<%if(isFMAInstalled){ %>
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
	 <% } %>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateSubFoldersWorkspaceDialog.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
    We are not passing emxTableRowId
--%>

<%@include file ="../emxUICommonAppInclude.inc" %>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%
  String sObjectId    = emxGetParameter(request, "objectId");
  String sFolderId    = emxGetParameter(request, "folderId");
  String callPage     = emxGetParameter(request,"callPage");
  String parentRowId  = emxGetParameter(request, "emxTableRowId");
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

    var nameValue =trim(document.createDialog.txtName.value);
    var descriptionValue =trim(document.createDialog.txtMessage.value);
    var namebadCharName = checkForNameBadCharsList(document.createDialog.txtName);
    var namebadCharDescrption = checkForNameBadCharsList(document.createDialog.txtMessage);
    if (namebadCharName.length != 0){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      document.createDialog.txtName.focus();
      return;
     }
    else if ( nameValue == "" ) {
      alert ("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateSubFoldersWorkspaceDialog.AlertSubCategoryName</emxUtil:i18nScript>");
      document.createDialog.txtName.focus();
      return;
    }
    else if(!(isValidLength(nameValue, 1,115))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateSubFoldersWorkspaceDialog.NameLengthAlertMessage</emxUtil:i18nScript>");
      document.createDialog.txtName.focus();
      return;
    }
    else if (!(isAlphanumeric(nameValue, true))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.createDialog.txtName.focus();
      return;
    }
    else if(namebadCharDescrption.length != 0) {
     alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
     document.createDialog.txtMessage.focus();
     return;
    }
    else {
                if(jsDblClick())
                {
                        startProgressBar(true);
                        document.createDialog.action = "../simulationcentral/smaTeamCreateSubFolders.jsp?callPage=" + "<%=callPage%>";
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
    parent.closeWindow();
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

<form name="createDialog" method="post" onSubmit="return false" action="../simulationcentral/smaTeamCreateSubFolders.jsp">
  <input type="hidden" name ="objectId" value="<%=strFolderId%>">
  <input type="hidden" name ="folderId" value="">
  <input type="hidden" name ="emxTableRowId" value="<%=parentRowId%>">

  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td  nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></label></td>
      <td nowrap  class="Field"><input type="Text" name="txtName" value="" size="20">
    </tr>
    <tr>
      <td  nowrap  class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Parent</emxUtil:i18n></label></td>
      <td nowrap  class="Field"><img src="../common/images/iconSmallFolder.gif" id=""><%=strCategoryName%></td>
    <tr> 
      <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></label></td>
      <td class="Field" ><textarea name="txtMessage" cols="40" rows="5" wrap></textarea></td>
    </tr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

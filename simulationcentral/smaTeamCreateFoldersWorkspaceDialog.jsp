<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateFoldersWorkspaceDialog.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
    We are not passing emxTableRowId
--%>

<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<%
  String sProjectId          = emxGetParameter(request, "objectId");
  String sFolderName         = emxGetParameter(request, "folderName");
  String parentRowId         = emxGetParameter(request, "emxTableRowId");

  if (sFolderName== null) {
    sFolderName = "";
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

  function submitform() {
    var foldname = trim(document.createDialog.folderName.value);
    var folderDesc = trim(document.createDialog.folderDescription.value);
    var namebadCharName = checkForNameBadCharsList(document.createDialog.folderName);
    var namebadCharDescrption = checkForNameBadCharsList(document.createDialog.folderDescription);
    if (namebadCharName.length != 0){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
     }
    else if (!(isAlphanumeric(foldname, true))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.FolderName.NameAlert</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
    } else if(foldname == null || foldname == "") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterName</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
    } else if(!(isValidLength(foldname, 1,115))){
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.FolderName.NameLengthAlertMessage</emxUtil:i18nScript>");
      document.createDialog.folderName.focus();
      return;
    } else if(folderDesc==null || namebadCharDescrption.length != 0) {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
      document.createDialog.folderDescription.focus();
      return;
    } else if(folderDesc==null || folderDesc=="") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterDisp</emxUtil:i18nScript>");
      document.createDialog.folderDescription.focus();
      return;
    } else {
        if(jsDblClick())
        {
              document.createDialog.folderName.value = foldname;
              document.createDialog.folderDescription.value = folderDesc;
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

  function closeWindow() {
	  //parent.closeWindow();
	    exitComposeShorCut();
	    return;
  }

  function clear() {
    if(trim(document.createDialog.folderName.value) !=null) {
      document.createDialog.folderName.value="";
    }
    if(trim(document.createDialog.folderDescription.value) !=null) {
      document.createDialog.folderDescription.value="";
    }
    return;
  }

  function folderlist() {
    emxShowModalDialog('../teamcentral/emxTeamPreDefinedFolderDialogFS.jsp?objectId=<%=sProjectId%>',575,575);
  }

</script>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="createDialog" method="post" onSubmit="return false" action="smaTeamCreateFolders.jsp">
  <input type="hidden" name ="ObjectId" value="<%=sProjectId%>">
  <input type="hidden" name ="emxTableRowId" value="<%=parentRowId%>">
  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td  nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></label></td>
      <td nowrap  class="Field"><input type="Text" name="folderName" value="<%=sFolderName%>" size="20">
      <input type="button" name="butClear" id="" value="..." onclick="folderlist()">&nbsp;<a href="javascript:clear()"><emxUtil:i18n localize="i18nId">emxTeamCentral.common.Clear</emxUtil:i18n></a></td>
    </tr>
    <tr>
      <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></label></td>
      <td class="Field" ><textarea name="folderDescription" cols="20" rows="5" wrap></textarea></td>
    </tr>
  </table>
</form>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


<%--
  emxTeamUnmanagedDocumentSearchDialog.jsp -- This page displays the Unmanaged Document Search Dialog.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTeamUnmanagedDocumentSearchDialog.jsp.rca 1.25 Wed Oct 22 16:06:02 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<script language="javascript">
  function doSearch() {
    // File Name can not have special characters
    var apostrophePosition = document.ContentFindFile.filename.value.indexOf("'");
    var DoublecodesPosition = document.ContentFindFile.filename.value.indexOf("\"");
    var hashPosition       = document.ContentFindFile.filename.value.indexOf("#");
    var dollarPosition     = document.ContentFindFile.filename.value.indexOf("$");
    var atPosition         = document.ContentFindFile.filename.value.indexOf("@");
    var andPosition        = document.ContentFindFile.filename.value.indexOf("&");
    var percentPosition    = document.ContentFindFile.filename.value.indexOf("%");

    var x = new Date();
    currentTimeZoneOffsetInHours = x.getTimezoneOffset()/60;
    document.ContentFindFile.timeZone.value = currentTimeZoneOffsetInHours;

    if ( DoublecodesPosition != -1 || apostrophePosition != -1 || hashPosition != -1 || dollarPosition != -1 || atPosition != -1 || andPosition != -1  || percentPosition != -1){
      alert ("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.ContentFindFile.name.focus();
    } else {
	    if(jsDblClick())
	    {
	      startSearchProgressBar();  //kf
	      document.ContentFindFile.submit();
	    }
	    else
	    {
	    	alert("<emxUtil:i18nScript localize='i18nId'>emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
	    }
    }
    return;
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }



  function selectVal(val) {

    if(val == "owner") {
      //emxShowModalDialog('emxTeamRouteWizardSelectPeopleDialogFS.jsp?callPage=Search',575,575);
      //showModalDialog('emxTeamRouteWizardSelectPeopleDialogFS.jsp?callPage=Search',775,475);
            showChooser('../components/emxCommonSearch.jsp?formName=ContentFindFile&frameName=pagecontent&searchmode=PersonChooser&suiteKey=Components&searchmenu=TMCFileSearchOwnerChooser&searchcommand=TMCFileSearchOwnerCommand&selection=multiple&fieldNameActual=owner&fieldNameDisplay=displayowner&HelpMarker=emxhelpselectuser',775,475);
      return;
    }
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script>document.onload=turnOffProgress(),getTopWindow().loadSearchFormFields()</script>

<form name="ContentFindFile" id="ContentFindFile" method="post" onSubmit="doSearch()" target="searchView" action="../common/emxTable.jsp">

<table class="list">
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.Type</emxUtil:i18n></td>
    <td class="inputField">
      <table border="0">
        <tr>
          <td>
          	<img src="../common/images/iconSmallDocument.gif" />&nbsp;
            <span class="object"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.File</emxUtil:i18n></span>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.SearchIn</emxUtil:i18n></td>
    <td class="inputField">
      <table>
        <tr>
          <td>
          	<input type="radio" name="ownedFiles" id="ownedFiles" value="true" checked />
          	<emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.FileIOwn</emxUtil:i18n>
          </td>
        </tr>
        <tr>
          <td>
          	<input type="radio" name="ownedFiles" id="ownedFiles" value="false" />
          	<emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.AllFiles</emxUtil:i18n>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.Owner</emxUtil:i18n></td>
    <td class="inputField"><input READONLY disabled = "disabled" type="text" name="displayowner" id="displayowner" value="*" /><input type="button" value="..." name="btn" id="btn" onclick='selectVal("owner")' />&nbsp;
    <input type="hidden" name="owner" id="owner" />
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.Name</emxUtil:i18n></td>
    <td class="inputField">
      <input type="text" name="filename" id="filename" value="*" />&nbsp;&nbsp;<input type="checkbox" name="matchCase" value="True" id="matchCase" checked />&nbsp;<emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.MatchCase</emxUtil:i18n>
    </td>
  </tr>
<%
    //get property for turning on the keyword search
    String keywordSearch = JSPUtil.getApplicationProperty(context,application,"emxTeamCentral.KeywordSearch");
    if("ON".equalsIgnoreCase(keywordSearch)) {
%>

      <tr>
        <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.Keywords</emxUtil:i18n></td>
        <td class="inputField"><input type="text" name="keywords" id="keywords" value="*" /></td>
      </tr>
<%
    }
%>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.CreatedAfter</emxUtil:i18n></td>
    <td class="inputField">
      <input type="text"  size="20" value="" name="createdAfter" id="createdAfter" readonly="readonly" />
      <img src="images/utilSpace.gif" width="1" height="1" border="0" />
      <a href="javascript:showCalendar('ContentFindFile','createdAfter',document.ContentFindFile.createdAfter.value)" >
      <img src="../common/images/iconSmallCalendar.gif" border="0" align="absmiddle" alt="" />
      </a>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindFiles.CreatedBefore</emxUtil:i18n></td>
    <td class="inputField"><input type="text"  size="20" value="" name="createdBefore" id="createdBefore" readonly="readonly" />
      <img src="images/utilSpace.gif" width="1" height="1" border="0" />
      <a href="javascript:showCalendar('ContentFindFile','createdBefore',document.ContentFindFile.createdBefore.value)" >
      <img src="../common/images/iconSmallCalendar.gif" border="0" align="absmiddle" alt="" /></a>
    </td>
  </tr>
 </table>
    <input type="hidden" name="table" value="TMCFilesSearchResult" />
    <input type="hidden" name="program" value="emxTeamSearch:getUnmanagedFilesSearchResult" />
    <input type="hidden" name="toolbar" value="AEFSearchResultToolbar" />
    <input type="hidden" name="header" value="emxTeamCentral.ObjectSearchResults.SearchResults" />
    <input type="hidden" name="selection" value="multiple" />
    <input type="hidden" name="QueryLimit" value="" />
    <input type="hidden" name="pagination" value="" />
    <input type="hidden" name="Style" value="dialog" />
    <input type="hidden" name="listMode" value="search" />
    <input type="hidden" name="CancelButton" value="true" />
    <input type="hidden" name="CancelLabel" value="emxTeamCentral.Button.Close" />
    <input type="hidden" name="HelpMarker" value="emxhelpsearchresults" />
    <input type="hidden" name="timeZone" value="" />
    <input type="hidden" name="StringResourceFileId" value="emxTeamCentralStringResource" />
    <input type="hidden" name="suiteKey" value="TeamCentral" />
    <input type="hidden" name="SuiteDirectory" value="teamcentral" />

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

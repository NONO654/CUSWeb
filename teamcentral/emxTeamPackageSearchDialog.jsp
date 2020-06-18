<%--  emxTeamPackageSearchDialog.jsp  - This page displays different options to the buyer to choose search criteria for Package.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxTeamPackageSearchDialog.jsp.rca 1.23 Wed Oct 22 16:06:39 2008 przemek Experimental przemek $"
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "eServiceUtil.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<%

  // to check if TeamCentral is installed
  String suiteTeamCentral      = EnoviaResourceBundle.getProperty(context,"emxFramework.UISuite.TeamCentral");
  boolean bTeam                = FrameworkUtil.isThisSuiteRegistered(context,session,suiteTeamCentral);
%>

<script language="javascript">

  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }



  function doSearch()
  {
    var x = new Date();
    currentTimeZoneOffsetInHours = x.getTimezoneOffset()/60;
    document.packageSearchForm.timeZone.value = currentTimeZoneOffsetInHours;

    document.packageSearchForm.packageName.value = trim(document.packageSearchForm.packageName.value);
    // File Name can not have special characters
    var apostrophePosition  = document.packageSearchForm.packageName.value.indexOf("'");
    var DoublecodesPosition = document.packageSearchForm.packageName.value.indexOf("\"");
    var hashPosition        = document.packageSearchForm.packageName.value.indexOf("#");
    var dollarPosition      = document.packageSearchForm.packageName.value.indexOf("$");
    var atPosition          = document.packageSearchForm.packageName.value.indexOf("@");
    var andPosition         = document.packageSearchForm.packageName.value.indexOf("&");
    var percentPosition     = document.packageSearchForm.packageName.value.indexOf("%");

    if(document.packageSearchForm.packageName.value == "")
    {
      document.packageSearchForm.packageName.focus();
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.PackageSearch.AlertPackageName</emxUtil:i18nScript>")
    } else if( DoublecodesPosition != -1 || apostrophePosition != -1 || hashPosition != -1 || dollarPosition != -1 || atPosition != -1 || andPosition != -1  || percentPosition != -1) {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.packageSearchForm.packageName.focus();
    } else {
      startSearchProgressBar();  //kf
      document.packageSearchForm.submit();
    }
    return;
  }

  function searchWorkspaceFolder()
  {
    //emxShowModalDialog('emxTeamGenericSelectFolderDialogFS.jsp?callPage=Search&formName=packageSearchForm',575,575);
    showTreeDialog('emxTeamGenericSelectFolderDialogFS.jsp?callPage=Search&formName=packageSearchForm');

  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script>document.onload=turnOffProgress(),getTopWindow().loadSearchFormFields()</script>

  <form name=packageSearchForm action="../common/emxTable.jsp" target="searchView" onSubmit="doSearch()">
    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="formBG">
      <tr>
        <td>
          <table border="0" cellpadding="5">
            <tr>
              <td width="147" class="label"> <emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Type</emxUtil:i18n>&nbsp;</td>
              <td class="inputField"><img border="0" src="../common/images/iconSmallPackage.gif" />&nbsp;&nbsp;<b><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Package</emxUtil:i18n></b>&nbsp;</td>
            </tr>
            <tr>
              <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.SearchIn</emxUtil:i18n></td>
              <td  class="inputField">
                <input type="radio" name="radioOwner" value="my" checked />
                <emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.PackagesIOwn</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="radioOwner" value="all" />
                <emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.AllPackages</emxUtil:i18n>
              </td>
            </tr>
    <%
      // show the WorkspaceFolder option only if TeamCentral is installed
      if(bTeam)
      {
    %>
            <tr>
              <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.WorkspaceFolder</emxUtil:i18n></td>
              <td class="inputField">
                <input type="text" name="WorkspaceFolder" value="*" />
                <input type="button" name="workspaceFolderButton" value="..." onClick="searchWorkspaceFolder()" />
                <input type="hidden" name="workspaceFolderId" />
              </td>
            </tr>
    <%
      }
    %>
            <tr>
              <td width="147" class="label"> <emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.PackageName</emxUtil:i18n>&nbsp;
              </td>
              <td class="inputField"><input type="text" name="packageName" value="*" /></td>
            </tr> 
            <tr>
              <td width="150" class="label"><label for="Quote Requested By Date"><emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.CreatedAfter</emxUtil:i18n></label></td>
              <td class="inputField" width="380">
                <input type="text" readonly="readonly" name = "dateBegin" value="" size="15" />
                <a href="javascript:showCalendar('packageSearchForm','dateBegin',document.packageSearchForm.dateBegin.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
              </td>
            </tr>
            <tr> 
              <td width="150" class="label"><label for="Quote Requested By Date"><emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.CreatedBefore</emxUtil:i18n></label></td>
              <td class="inputField" width="380">
                <input type="text" readonly="readonly" name = "dateEnd" value="" size="15" />
                <a href="javascript:showCalendar('packageSearchForm','dateEnd',document.packageSearchForm.dateEnd.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
<input type="hidden" name="table" value="SCSPackagesSearchResults" />
<input type="hidden" name="program" value="SourcingSearch:getPackagesSearchResult" />
<input type="hidden" name="timeZone" value="" />
<input type="hidden" name="toolbar" value="AEFSearchResultToolbar" />
<input type="hidden" name="header" value="<%=i18nNow.getI18nString("emxTeamCentral.ObjectSearchResults.SearchResults", "emxTeamCentralStringResource", request.getHeader("Accept-Language"))%>" />

<input type="hidden" name="selection" value="multiple" />
<input type="hidden" name="QueryLimit" value="" />
<input type="hidden" name="pagination" value="" />
<input type="hidden" name="Style" value="dialog" />
<input type="hidden" name="listMode" value="search" />
<input type="hidden" name="CancelButton" value="true" />
<input type="hidden" name="CancelLabel" value="emxTeamCentral.Button.Close" />
<input type="hidden" name="HelpMarker" value="emxhelpsearchresults" />
<input type="hidden" name="StringResourceFileId" value="emxTeamCentralStringResource" />
<input type="hidden" name="suiteKey" value="TeamCentral" />
<input type="hidden" name="SuiteDirectory" value="teamcentral" />

  </form>

<%

 //find like params
  String objectSymbolicName = "type_Package";
  String objectI18NString = "emxTeamCentral.FindLike.Common.Package";
  String objectIcon = "iconSmallPackage.gif";
%>

<%@include file = "emxTeamFindLikeLinkInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

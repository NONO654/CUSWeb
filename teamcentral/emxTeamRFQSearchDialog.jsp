<%--  emxTeamRFQSearchDialog.jsp  - This page displays different options to the buyer to choose search criteria for RTS.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxTeamRFQSearchDialog.jsp.rca 1.25 Wed Oct 22 16:06:18 2008 przemek Experimental przemek $"
--%>


<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "eServiceUtil.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<%
  String suiteTeamCentral      = EnoviaResourceBundle.getProperty(context,"emxFramework.UISuite.TeamCentral");
  boolean bTeam                = FrameworkUtil.isThisSuiteRegistered(context,session,suiteTeamCentral);
%>

<script language="javascript">
  function trim1 (textBox) {
      return textBox.replace(/\s/gi, "");
  }
  
  function doSearch()
  {
    var x = new Date();
    currentTimeZoneOffsetInHours = x.getTimezoneOffset()/60;
    document.rtsSearchForm.timeZone.value = currentTimeZoneOffsetInHours;

    document.rtsSearchForm.rtsName.value = trim(document.rtsSearchForm.rtsName.value);
    var apostrophePosition  = document.rtsSearchForm.rtsName.value.indexOf("'");
    var DoublecodesPosition = document.rtsSearchForm.rtsName.value.indexOf("\"");
    var hashPosition        = document.rtsSearchForm.rtsName.value.indexOf("#");
    var dollarPosition      = document.rtsSearchForm.rtsName.value.indexOf("$");
    var atPosition          = document.rtsSearchForm.rtsName.value.indexOf("@");
    var andPosition         = document.rtsSearchForm.rtsName.value.indexOf("&");
    var percentPosition     = document.rtsSearchForm.rtsName.value.indexOf("%");

    if(document.rtsSearchForm.rtsName.value == "") {
      document.rtsSearchForm.rtsName.focus();
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.RFQSearch.RFQName</emxUtil:i18nScript>");
      return;
    } else if( DoublecodesPosition != -1 || apostrophePosition != -1 || hashPosition != -1 || dollarPosition != -1 || atPosition != -1 || andPosition != -1  || percentPosition != -1) {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.rtsSearchForm.rtsName.focus();
    } else {
      startSearchProgressBar();  //kf
      document.rtsSearchForm.submit();
    }
  }

  function searchWorkspaceFolder(){
    //emxShowModalDialog('emxTeamGenericSelectFolderDialogFS.jsp?callPage=Search&formName=rtsSearchForm',575,575);
    showTreeDialog('emxTeamGenericSelectFolderDialogFS.jsp?callPage=Search&formName=rtsSearchForm');
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script>document.onload=turnOffProgress(),getTopWindow().loadSearchFormFields()</script>

  <form name="rtsSearchForm" action="../common/emxTable.jsp" target="searchView" onSubmit="doSearch()">
  <table border="0" cellpadding="5">
    <tr>
      <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Type</emxUtil:i18n></td>
      <td width="440" class="inputField">
        <table border="0">
          <tr>
            <td><img src="../common/images/iconSmallRTS.gif" width="16" height="16" /></td>
            <td><span class="object"><emxUtil:i18n localize="i18nId">emxTeamCentral.FindLike.Common.RFQ</emxUtil:i18n></span></td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.PackageSearch.SearchIn</emxUtil:i18n></td>
      <td width="440" class="inputField">
        <input type="radio" name="radioOwner" value="my" checked />
        <emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.RFQsIOwn</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="radioOwner" value="all" />
        <emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.AllRFQs</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp; </td>
    </tr>
<%
    // show the WorkspaceFolder option only if TeamCentral is installed
    if(bTeam)
    {
%>
    <tr>
      <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.WorkspaceFolder</emxUtil:i18n></td>
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
      <td class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.Name</emxUtil:i18n></td>
      <td class="inputField">
        <input type="text" name="rtsName" value="*" />
      </td>
    </tr>
    <tr>
      <td width="150" class="label"><label for="Quote Requested By Date"><emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.CreatedAfter</emxUtil:i18n></label></td>
      <td class="inputField" width="380">
        <input type="text" name = "dateBegin" value="" size="15" readonly="readonly" />
        <a href="javascript:showCalendar('rtsSearchForm','dateBegin',document.rtsSearchForm.dateBegin.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
      </td>
    </tr>
    <tr>
      <td width="150" class="label"><label for="Quote Requested By Date"><emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.CreatedBefore</emxUtil:i18n></label></td>
      <td class="inputField" width="380">
        <input type="text" name = "dateEnd" value="" size="15" readonly="readonly" />
        <a href="javascript:showCalendar('rtsSearchForm','dateEnd',document.rtsSearchForm.dateEnd.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
      </td>
    </tr>
  </table>
   <input type="hidden" name="table" value="SCSRFQsSearchResults" />
   <input type="hidden" name="program" value="SourcingSearch:getRFQsSearchResult" />
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
  String objectSymbolicName = "type_RequestToSupplier";
  String objectI18NString = "emxTeamCentral.FindLike.Common.RTS";
  String objectIcon = "iconSmallRTS.gif";
%>
<%@include file = "emxTeamFindLikeLinkInclude.inc" %>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

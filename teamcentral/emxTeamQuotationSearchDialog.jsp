<%-- emxTeamQuotationSearchDialog.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxTeamQuotationSearchDialog.jsp.rca 1.25 Wed Oct 22 16:06:29 2008 przemek Experimental przemek $"
--%>


<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "eServiceUtil.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>


<script language="javascript">

// getting issues if we have trim as name of function
  function trim1 (textBox) {
      return textBox.replace(/\s/gi, "");
  }
 
  function doSearch() {
    var x = new Date();
    currentTimeZoneOffsetInHours = x.getTimezoneOffset()/60;
    document.searchform.timeZone.value = currentTimeZoneOffsetInHours;

//Bug 305296 - Commented the trim code
// document.searchform.RFQName.value = trim1(document.searchform.RFQName.value);
    // File Name can not have special characters
    var apostrophePosition  = document.searchform.RFQName.value.indexOf("'");
    var DoublecodesPosition = document.searchform.RFQName.value.indexOf("\"");
    var hashPosition        = document.searchform.RFQName.value.indexOf("#");
    var dollarPosition      = document.searchform.RFQName.value.indexOf("$");
    var atPosition          = document.searchform.RFQName.value.indexOf("@");
    var andPosition         = document.searchform.RFQName.value.indexOf("&");
    var percentPosition     = document.searchform.RFQName.value.indexOf("%");

    if(document.searchform.RFQName.value == "")
    {
      document.searchform.RFQName.focus();
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.RFQSearch.RFQName</emxUtil:i18nScript>");
    } else if( DoublecodesPosition != -1 || apostrophePosition != -1 || hashPosition != -1 || dollarPosition != -1 || atPosition != -1 || andPosition != -1  || percentPosition != -1) {
      alert ("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
      document.searchform.RFQName.focus();
    } else {
       document.searchform.submit();
    }
    return;
  }
  
  function searchWorkspaceFolder(){    
    showTreeDialog('emxTeamGenericSelectFolderDialogFS.jsp?callPage=Search&formName=searchform');
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String targetSearchPage   = "emxTeamSupplierPartSearchResult.jsp";
  String relationStr        = Framework.getPropertyValue(session,"relationship_Supplier");
  String companyStr         =   Framework.getPropertyValue(session, "type_Company");
  Pattern relPattern        = new Pattern(relationStr);
  Pattern typePattern       = new Pattern(companyStr);
  SelectList selectStmts    = new SelectList();
  String companyName        = null;

%>

<script>document.onload=turnOffProgress(),getTopWindow().loadSearchFormFields()</script>

  <form name="searchform" action="../common/emxTable.jsp" target="searchView" onSubmit="doSearch()">
    <input type="hidden" name=targetSearchPage value="<%= targetSearchPage%>" />
    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="formBG">
      <tr>
        <td>
          <table border="0" width="100%" cellpadding="5">
            <tr>
              <td width="147" class="label"> <emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Type</emxUtil:i18n>&nbsp;</td>
              <td class="inputField"><img border="0" src="../common/images/iconSmallQuotation.gif" />&nbsp;&nbsp;<b><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Quotation</emxUtil:i18n></b>&nbsp;</td>
            </tr>
            <tr>
              <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.QuotationSearch.BuyerCompany</emxUtil:i18n></td>
              <td width="440" class="inputField">
              <select name = "company" size = "1">
<%
      // get the company name
      BusinessObject companyBus = JSPUtil.getOrganization(context, session, JSPUtil.getPerson(context,session));
      boolean close = false;
      String companyId = companyBus.getObjectId();
        if (!companyBus.isOpen()) {
        companyBus.open(context);
        close = true;
      }
      selectStmts.addName();
      ExpansionWithSelect buyerSelect     = companyBus.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                             selectStmts,new StringList(), true, true,  (short)1);

      RelationshipWithSelectList relSelList = buyerSelect.getRelationships();
      RelationshipWithSelectItr relItr = new RelationshipWithSelectItr(relSelList);

      while (relItr.next()){
        RelationshipWithSelect companyRel = relItr.obj();
        companyRel.open(context);
        Hashtable targetData = companyRel.getTargetData();
        companyName = (String)targetData.get("name");
        companyRel.close(context);
%>
                <option value="<%=XSSUtil.encodeForHTMLAttribute(context,companyName)%>" ><%=XSSUtil.encodeForHTMLAttribute(context,companyName)%></option>

<%
      }
     if (close) {
        companyBus.close(context);
      }
%>
               </select>
                &nbsp; </td>
            </tr>
            <tr>
              <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.RTS.SearchIn</emxUtil:i18n></td>
              <td width="440" class="inputField">
                <input type="radio" name="radioOwner" value="my" checked />
                <emxUtil:i18n localize="i18nId">emxTeamCentral.GenericSearch.QuotationsIOwn</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="radioOwner" value="all" />
                <emxUtil:i18n localize="i18nId">emxTeamCentral.GenericSearch.AllQuotations</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp; </td>
            </tr>            
            <tr>
              <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.RFQSearch.WorkspaceFolder</emxUtil:i18n></td>
                <td class="inputField">
                  <input type="text" name="WorkspaceFolder" value="*" />
                  <input type="button" name="workspaceFolderButton" value="..." onClick="searchWorkspaceFolder()" />
                  <input type="hidden" name="workspaceFolderId" value="" />
                </td>
           </tr>
            
            <tr>
              <td width="147" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.QuotationSearch.RFQName</emxUtil:i18n></td>
              <td width="440" class="inputField">
                <input type="text" name = "RFQName" value = "*" size="25" />
                &nbsp; </td>
            </tr>
            <tr>
              <td width="150" class="label"><label for="Quote Requested By Date"><emxUtil:i18n localize="i18nId">emxTeamCentral.QuotationSearch.CreatedAfter</emxUtil:i18n></label></td>
              <td class="inputField" width="380">
                <input type="text" name = "dateBegin" value="" size="15" readonly="readonly" />
                <a href="javascript:showCalendar('searchform','dateBegin',document.searchform.dateBegin.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
              </td>
            </tr>
            <tr>
              <td width="150" class="label"><label for="Quote Requested By Date"><emxUtil:i18n localize="i18nId">emxTeamCentral.QuotationSearch.CreatedBefore</emxUtil:i18n></label></td>
              <td class="inputField" width="380">
                <input type="text" name = "dateEnd" value="" size="15" readonly="readonly" />
                <a href="javascript:showCalendar('searchform','dateEnd',document.searchform.dateEnd.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>
     <input type="hidden" name="table" value="SCSQuotationsSearchResults" />
     <input type="hidden" name="program" value="SourcingSearch:getQuotationsSearchResult" />
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
  String objectSymbolicName = "type_RTSQuotation";
  String objectI18NString = "emxTeamCentral.FindLike.Common.Quotation";
  String objectIcon = "iconSmallQuotation.gif";
%>
<%@include file = "emxTeamFindLikeLinkInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

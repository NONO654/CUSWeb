<%--    emxECRECOLateApprovalsReportDialog.jsp   Search page for ECR ECO Late Approval Report
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxJSValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxengchgUtil.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants" %>


<%
  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);

  
  String languageStr = request.getHeader("Accept-Language");
  String header="";
  String sECRType = PropertyUtil.getSchemaProperty(context, "type_ECR");
  String sECOType = PropertyUtil.getSchemaProperty(context, "type_ECO");
  
  String RDO              = i18nNow.getI18nString("emxEngineeringCentral.Common.None", "emxEngineeringCentralStringResource",languageStr);
  String txtRDO           = "";
 
  

  %>
<script language="Javascript">


  function doSearch() {	 
    
    var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
    document.frmPowerSearch.queryLimit.value = strQueryLimit;
    document.frmPowerSearch.txtOwner.value = trimWhitespace(document.frmPowerSearch.txtOwner.value);

    if (charExists(document.frmPowerSearch.txtOwner.value, '"')||charExists(document.frmPowerSearch.txtOwner.value, '\'')||charExists(document.frmPowerSearch.txtOwner.value, '#'))
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.SpecialCharacters</emxUtil:i18nScript>");
        document.frmPowerSearch.txtOwner.focus();
        return;
    }
    
    var strTxtDays = trimWhitespace(document.frmPowerSearch.txtDays.value);
    
    if (strTxtDays == "")
    {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.LateReport.DayMustNumeric</emxUtil:i18nScript>");
        return;
    }
    if (strTxtDays != "")
    {
        if (isNaN(strTxtDays) == true)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.LateReport.DayMustNumeric</emxUtil:i18nScript>");
            document.frmPowerSearch.txtDays.value = "1";
            document.frmPowerSearch.txtDays.focus();
            return;
        }
        else if (strTxtDays > 32767)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.LateReport.DayLessThan</emxUtil:i18nScript>");
            document.frmPowerSearch.txtDays.value = "1";
            document.frmPowerSearch.txtDays.focus();
            return;
        }
        else if (strTxtDays  < 1)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.LateReport.DaysMoreThan</emxUtil:i18nScript>");
            document.frmPowerSearch.txtDays.value = "1";
            document.frmPowerSearch.txtDays.focus();
            return;
        }
        else if(strTxtDays.indexOf('.') > -1)
        {      
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.LateReport.DayMustNumeric</emxUtil:i18nScript>");
            document.frmPowerSearch.txtDays.value = "1";
            document.frmPowerSearch.txtDays.focus();
            return;
        }
        else if(strTxtDays.indexOf('-') > -1)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.LateReport.DayMustNumeric</emxUtil:i18nScript>");
            document.frmPowerSearch.txtDays.value = "1";
            document.frmPowerSearch.txtDays.focus();
            return;
        }
    }

    var allRoute = document.frmPowerSearch.selRoute.value;
    if(allRoute=="AllRoute")
    {
        document.frmPowerSearch.program.value="emxECR:getECRECOSearchResultAll";
    }
		
		var varRDO = document.frmPowerSearch.RDO.value;
    		if (varRDO.match('None')){
		
        document.frmPowerSearch.header.value="emxEngineeringCentral.Search.NoRDOLateApprovalsReportHeading";
		
      		}
    else
    {
		//XSSOK
        if(document.frmPowerSearch.selType.value=="<%=sECOType%>")
        {
            document.frmPowerSearch.header.value="emxEngineeringCentral.Search.ECOLateApprovalsReportHeading";
        }
		//XSSOK
        else if(document.frmPowerSearch.selType.value=="<%=sECRType%>")
        {
            document.frmPowerSearch.header.value="emxEngineeringCentral.Search.ECRLateApprovalsReportHeading";
        }
       
    }
   
    
    document.frmPowerSearch.objectId.value=document.frmPowerSearch.txtRDO.value;
    document.frmPowerSearch.submit();
  }

  function showRDOSearch(formName, namefield, idfield, role) 
{
    showModalDialog('emxpartRDOSearchDialogFS.jsp?form=' + formName + '&field=' + namefield + '&fieldId=' + idfield + '&role=' +role + '&searchLinkProp=SearchRDOLinks', 550,500,false);
}

  function showRDOSearchResults(formName, namefield, idfield) 
  {
      showModalDialog('emxpartRDOSearchDialogFS.jsp?form=' + formName + '&field=' + namefield + '&fieldId=' + idfield + '&searchLinkProp=SearchRDOLinks', 550,500,false);
  }
  
  function clearField() 
{
     document.frmPowerSearch.RDO.value="<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.None</emxUtil:i18nScript>";
     document.frmPowerSearch.txtRDO.value="";
}

</script>

<%
  String sMode = emxGetParameter(request, "mode");

%>


<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="frmPowerSearch" method="get" action="../common/emxTable.jsp" target="_parent" onSubmit="return false">
<%
  String sHeader     = emxGetParameter(request,"header");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals(""))
    {
        suiteKey = "eServiceSuiteEngineeringCentral";
    }
%>

 
 <input type="hidden" name="queryLimit" value="" />

 <input type="hidden" name="objectId" value="" />
 <input type="hidden" name="txtRDO" value="" />
 <input type="hidden" name="txtWhere" value="" />
 <input type="hidden" name="ckSaveQuery" value="" />
 <input type="hidden" name="txtQueryName" value="" />
 <input type="hidden" name="ckChangeQueryLimit" value="" />
 <input type="hidden" name="fromDirection" value="" />
 <input type="hidden" name="toDirection" value="" />
 <input type="hidden" name="table" value="ENCLateApprovalReportResult" />
 <input type="hidden" name="selection" value="none" />
 <input type="hidden" name="header" value='' />
 <input type="hidden" name="sortColumnName" value="Name" />
 <input type="hidden" name="sortDirection" value="ascending" />
 <input type="hidden" name="program" value="emxECR:getECRECOSearchResultActive" />
 <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
 <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>" />
 <input type="hidden" name="vault" value="<xss:encodeForHTMLAttribute><%=JSPUtil.getVault(context,session)%></xss:encodeForHTMLAttribute>" />
 <input type="hidden" name="topActionbar" value="ENCLateApprovalReportTopActionbar" />
 <input type="hidden" name="CancelButton" value="true" />
 <input type="hidden" name="HelpMarker" value="emxhelplateapprovalrpt" />
 <input type="hidden" name="Style" value="Dialog" />
 <input type="hidden" name="CancelLabel" value="emxEngineeringCentral.Common.Close" />
 <input type="hidden" name="TransactionType" value="update" />
 <input type="hidden" name="Export" value="true" />

 

<table border="0" cellspacing="2" cellpadding="3" width="100%" >

  <tr>
    <td class="label" width="40%"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
    <td class="inputField" width="60%">
        <select size="1" name="selType" >
        <!-- XSSOK -->
      		<option          value="<%=sECOType %>"><%=i18nNow.getTypeI18NString(sECOType,languageStr)%>&nbsp;&nbsp;</option>
      		<!-- XSSOK -->
            <option          value="<%=sECRType %>"><%=i18nNow.getTypeI18NString(sECRType,languageStr) %>&nbsp;&nbsp;</option>
        </select>
    </td>
  </tr>
  <tr>
    <td class="label" width="40%"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.LateReport.RouteTasks</emxUtil:i18n></td>
    <td class="inputField" width="60%">
        <select size="1" name="selRoute">
        	<!-- XSSOK -->
            <option selected value="Started"><%=i18nNow.getI18nString("emxEngineeringCentral.LateReport.Started", "emxEngineeringCentralStringResource", languageStr)%>&nbsp;</option>
            <!-- XSSOK -->
            <option          value="AllRoute"><%=i18nNow.getI18nString("emxEngineeringCentral.LateReport.AllRoute", "emxEngineeringCentralStringResource", languageStr)%>&nbsp;</option>
        </select>
    </td>
  </tr>
  <tr>
    <!--370265  Changed the labelRequired class to a non-mandatory label class Start --> 
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.DesignResponsibility</emxUtil:i18n></td>
    <!--370265  End -->
    <td class="inputField"><input type="text" size="30" name="RDO" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=RDO%></xss:encodeForHTMLAttribute>" />
        <input type="button" value="..." name="btnOrganization" onclick="javascript:showRDOSearchResults('frmPowerSearch', 'RDO', 'txtRDO')" />
        <a href="JavaScript:clearField()" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
    </td>
  </tr>
  <tr>
    <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.DaysLate</emxUtil:i18n></td>
    <td class="inputField">
        <input type="text" name="txtDays" size="8" value="1" />
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Owner</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtOwner" size="16" value="*" /></td>
  </tr>


<input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=sMode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="saveQuery" value="false" />
<input type="hidden" name="changeQueryLimit" value="true" />
<input type="hidden" name="vaultAwarenessString" value="<xss:encodeForHTMLAttribute><%=vaultAwarenessString%></xss:encodeForHTMLAttribute>" />

</table>

</form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

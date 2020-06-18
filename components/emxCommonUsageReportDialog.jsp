<%-- emxCommonUsageReportDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonUsageReportDialog.jsp.rca 1.6.6.5 Wed Oct 22 16:17:44 2008 przemek Experimental przemek $ 
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">

    function doSearch()
    {
        if(jsIsClicked()) {
            alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
            return;
        }
        
        //get the form
        var theForm = document.forms[0];

        //set form target
        theForm.target = "searchView";
		theForm.action = "../common/emxTable.jsp?editLink=true";
        theForm.submit();
    }

	function closeWindow() {
		window.closeWindow();
		return;
	}
function getPagination()
{
	return 0;
}

function getQueryLimit()
{
	return 0;
}

function setElementValue(eleName, eleValue)
{
	var ele = document.getElementById(eleName);
	if(ele != null)
	{
		ele.value = eleValue == null ? "" : eleValue;
	}
}

function findDocument()
{
	var sURL = "../common/emxFullSearch.jsp?showInitialResults=false&txtType=type_DOCUMENTS&mandatorySearchParam=txtType&field=TYPES=type_DOCUMENTS&table=AEFGeneralSearchResults&mode=Chooser&selection=single&fieldNameActual=txtDocument&fieldNameDisplay=txtDocumentDisplay&fieldNameOID=txtDocumentOID&submitURL=../common/AEFSearchUtil.jsp";
	showModalDialog(sURL,700,600);
}
function findPerson()
{
	var sURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&showInitialResults=false&txtType=type_Person&mandatorySearchParam=txtType&table=AEFGeneralSearchResults&mode=Chooser&selection=single&fieldNameActual=txtPerson&fieldNameDisplay=txtPersonDisplay&fieldNameOID=txtPersonOID&submitURL=../common/AEFSearchUtil.jsp";
	showModalDialog(sURL,700,600);
}
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
	String languageStr = request.getHeader("Accept-Language");
	String strToolbar = "APPCommonReviseUsageReportToolbar";
	
%>
<body onload="turnOffProgress(), getTopWindow().loadSearchFormFields()">
<form name="usageReport" id="usageReport" method="post" onSubmit="doSearch(); return false;" target="_parent" action="../common/emxTable.jsp" >
  	<input type="hidden" name="loginName" value="<xss:encodeForHTMLAttribute><%= emxGetParameter(request,"loginName") %></xss:encodeForHTMLAttribute>" />

    <input type="hidden" name="table" value="APPUsageReport" />
    <input type="hidden" name="Style" value="dialog" />
    <input type="hidden" name="program" value="emxCommonDownload:getUsage" />
    <input type="hidden" name="header" value="emxComponents.Download.UsageReport" />
    <input type="hidden" name="QueryLimit" value="" />
    <input type="hidden" name="pagination" value="" />
    <input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=strToolbar%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="listMode" value="search" />
    <input type="hidden" name="CancelButton" value="true" />
    <input type="hidden" name="CancelLabel" value="emxComponents.Button.Close" />
    <input type="hidden" name="HelpMarker" value="emxhelpsearchusagereport" />
    <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="sortColumnName" value="StateOfUsage" />
    <input type="hidden" name="sortDirection" value="ascending" />
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"suiteKey")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="StringResourceFileId" value="<%=XSSUtil.encodeForHTMLAttribute(context, emxGetParameter(request,"StringResourceFileId"))%>" />
    <input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"SuiteDirectory")%></xss:encodeForHTMLAttribute>" />

  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.StateOfUsage</emxUtil:i18n>
      </td>
      <td class="inputField">
		<select name="selStateOfUsage">
	<%
			String strAttrStateOfUsage    = PropertyUtil.getSchemaProperty(context, "attribute_StateofUsage");
			StringList slAttrStateOfUsage = mxAttr.getChoices(context, strAttrStateOfUsage);
			String strLanguage = request.getHeader("Accept-Language");
			MapList ml = AttributeUtil.sortAttributeRanges(context, strAttrStateOfUsage, slAttrStateOfUsage, strLanguage);
			Iterator mlItr = ml.iterator();
			for(int i=0; i<ml.size(); i++)
			{
				Map choiceMap = (Map) ml.get(i);
	%>        
				<option selected value ="<%=XSSUtil.encodeForHTMLAttribute(context, (String) choiceMap.get("choice"))%>" > <%=XSSUtil.encodeForHTMLAttribute(context, (String) choiceMap.get("translation"))%></option>
	<%
			}
	%>		
				<option value="*" ><emxUtil:i18n localize="i18nId">emxComponents.Download.All</emxUtil:i18n></option>
			</select>
		</td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Document</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtDocumentDisplay" id="txtDocumentDisplay" value="*" readonly/> 
        <input type="button" value="..." name="btntype" id="btntype" onclick="findDocument()" />
        <input type="hidden" name="txtDocument" id="txtDocument" value="" /> 
        <a class="dialogClear" href="#" onclick="javascript:setElementValue('txtDocumentDisplay', '*'), setElementValue('txtDocumentOID')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
		<input type="hidden" name="txtDocumentOID" id="txtDocumentOID" value=""/>
      </td>
    </tr>
	<tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtPersonDisplay" id="txtPersonDisplay" value="*" readonly/> 
        <input type="button" value="..." name="btntype" id="btntype" onclick="findPerson()" />
        <input type="hidden" name="txtPerson" id="txtPerson" value="" /> 
        <a class="dialogClear" href="#" onclick="javascript:setElementValue('txtPersonDisplay', '*'), setElementValue('txtPersonOID');"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
        <input type="hidden" name="txtPersonOID" id="txtPersonOID" value="" />
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.Purpose</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtPurpose" id="txtPurpose" value="*"/>
      </td>
    </tr>
  </table>
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

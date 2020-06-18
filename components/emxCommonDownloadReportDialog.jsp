<%-- emxCommonUsageReportDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDownloadReportDialog.jsp.rca 1.6.6.5 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $ 
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>

<%
	String languageStr = request.getHeader("Accept-Language");
	String strFromPage = emxGetParameter(request, "fromPage");

	String strOriginator = "*";

	String strPersonId = "";
	String strHeader = "emxComponents.Download.DownloadReport";
	String strToolbar = "APPCommonReviseDownloadReportToolbar";
	String strHelpMarker = "emxhelpsearchdownloadreport";
	boolean isMyDownlods = "MyDownloads".equalsIgnoreCase(strFromPage);
	if(isMyDownlods) {
		strOriginator = context.getUser();
		strPersonId = Person.getPerson(context).getId();
		strToolbar = "APPCommonReviseMyDownloadsToolbar";
		strHeader = "emxComponents.Download.MysDownloads";
		strHelpMarker = "emxhelpsearchmydownloads";
	}

%>

<script language="javascript">
    function doSearch() {	
		var dStartDate = document.downloadReport.txtStartDate.value;
		var dEndDate = document.downloadReport.txtEndDate.value;

		if(dStartDate != "" && dEndDate != "") {
			var dSDate = new Date(dStartDate);
			var dEDate = new Date(dEndDate);
			if(dSDate > dEDate) {
				alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Download.DateMessage</emxUtil:i18nScript>");
				return;
			}
		}

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
	function getPagination() {
	return 0;
}
	function getQueryLimit() {
	return 0;
}
	function setElementValue(eleName, eleValue) {
	var ele = document.getElementById(eleName);
		if(ele != null) {
		ele.value = eleValue == null ? "" : eleValue;
	}
}

function reviseSearch(){
    //if doSubmit use hidden content frame
    var searchViewFrame = null;
    if(pageControl.getDoSubmit()){
        searchViewFrame = findFrame(getTopWindow(),"searchContent");
    }else{
        searchViewFrame = findFrame(getTopWindow(),"searchView");
    }
    //querystring
    var querystring = escape(pageControl.getSearchContentURL());

    var qStr = pageControl.getSearchContentURL();
    qStr = qStr.substring(qStr.indexOf("title"),qStr.length);
    qStr = qStr.substring(0,qStr.indexOf("&"));
    // get searchViewUrl
    //var searchViewUrl = "../common/emxSearchView.jsp?url=" + querystring+"&"+qStr;
	var searchViewUrl = 	"emxSearch.jsp?defaultSearch=APPCommonShowDownloadReport&toolbar=APPCommonShowDownloadReportToolbar&helpMarker=<%=XSSUtil.encodeURLwithParsing(context, strHelpMarker)%>";
    
    //if hidden submit use only the
    if(pageControl.getDoSubmit()){
        searchViewUrl = pageControl.getSearchContentURL();
    }
    
    pageControl.setDoReload(true);
    searchViewFrame.location.href = searchViewUrl;
}
	function findDocument() {
		var sURL = "../common/emxFullSearch.jsp?showInitialResults=false&txtType=type_DOCUMENTS&mandatorySearchParam=txtType&field=TYPES=type_DOCUMENTS&table=AEFGeneralSearchResults&mode=Chooser&selection=single&fieldNameActual=txtDocument&fieldNameDisplay=txtDocumentDisplay&fieldNameOID=txtDocumentOID&submitURL=../common/AEFSearchUtil.jsp";
		showModalDialog(sURL,700,600);
	}
	function findPerson() {
		var sURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&showInitialResults=false&txtType=type_Person&mandatorySearchParam=txtType&table=AEFGeneralSearchResults&mode=Chooser&selection=single&fieldNameActual=txtPerson&fieldNameDisplay=txtPersonDisplay&fieldNameOID=txtPersonOID&submitURL=../common/AEFSearchUtil.jsp";
		showModalDialog(sURL,700,600);
}
</script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js" ></script>

<body onload="turnOffProgress(), getTopWindow().loadSearchFormFields()">
<form name="downloadReport" id="downloadReport" method="post" onSubmit="doSearch(); return false;" target="_parent" action="../common/emxTable.jsp" >
  <input type="hidden" name="loginName" value="<xss:encodeForHTMLAttribute><%= emxGetParameter(request,"loginName") %></xss:encodeForHTMLAttribute>"/>

    <input type="hidden" name="table" value="APPDownloadReport"/>
    <input type="hidden" name="Style" value="dialog"/>
    <input type="hidden" name="program" value="emxCommonDownload:getDownloads"/>
    <input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=strHeader%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="QueryLimit" value=""/>
    <input type="hidden" name="pagination" value=""/>
    <input type="hidden" name="toolbar" value="<xss:encodeForHTMLAttribute><%=strToolbar%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="listMode" value="search"/>
    <input type="hidden" name="CancelButton" value="true"/>
    <input type="hidden" name="CancelLabel" value="emxComponents.Button.Close"/>
    <input type="hidden" name="HelpMarker" value="<xss:encodeForHTMLAttribute><%=strHelpMarker%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="sortColumnName" value="Originator"/>
    <input type="hidden" name="sortDirection" value="ascending"/>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"suiteKey")%></xss:encodeForHTMLAttribute>"/>
    <input type=hidden name="StringResourceFileId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"StringResourceFileId")%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"SuiteDirectory")%></xss:encodeForHTMLAttribute>"/>

  <table border="0" cellpadding="5" cellspacing="2" width="530">
	<tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n>
      </td>
      <td class="inputField">
		<%
		if(isMyDownlods) {
			%>
			<%=XSSUtil.encodeForJavaScript(context, strOriginator)%>
			<input type="hidden" name="txtPerson" id="txtPerson" value="<xss:encodeForHTMLAttribute><%=strOriginator%></xss:encodeForHTMLAttribute>"/>
			<%
		} else	{
			%>
			<input type="text" name="txtPersonDisplay" id="txtPersonDisplay" readonly value="<xss:encodeForHTMLAttribute><%=strOriginator%></xss:encodeForHTMLAttribute>" />
			<input type="button" value="..." name="btntype" id="btntype" onclick = "findPerson()" />
			<a class="dialogClear" href="#" onclick="javascript:setElementValue('txtPersonDisplay', '*'),setElementValue('txtPersonOID', '')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
			<input type="hidden" name="txtPerson" id="txtPerson" value=""/>
			<%
		}
		%>
		<input type="hidden" name="txtPersonOID" id="txtPersonOID" value="<xss:encodeForHTMLAttribute><%=strPersonId%></xss:encodeForHTMLAttribute>" />
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
        <a class="dialogClear" href="#" onclick="javascript:setElementValue('txtDocumentDisplay', '*'),setElementValue('txtDocumentOID', '')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
        <input type="hidden" name="txtDocumentOID" id="txtDocumentOID" value=""/>
      </td>
    </tr>

    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.StartDate</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtStartDate" id="txtStartDate" value="" readonly/>
			<a href="javascript:showCalendar('downloadReport','txtStartDate', '')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom"/></a> <a class="dialogClear" href="#" onclick="javascript:setElementValue('txtStartDate', '')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.EndDate</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtEndDate" id="txtEndDate" value="" readonly/>
			<a href="javascript:showCalendar('downloadReport','txtEndDate', '')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom"/></a> <a class="dialogClear" href="#" onclick="javascript:setElementValue('txtEndDate', '')"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.Status</emxUtil:i18n>
      </td>
      <td class="inputField">
		<select name = "status">
<%
		String strAttrDownloadStatus    = PropertyUtil.getSchemaProperty(context, "attribute_DownloadStatus");
		StringList slAttrDownloadStatus = mxAttr.getChoices(context, strAttrDownloadStatus);
		String strLanguage = request.getHeader("Accept-Language");
		MapList ml = AttributeUtil.sortAttributeRanges(context, strAttrDownloadStatus, slAttrDownloadStatus, strLanguage);
		Iterator mlItr = ml.iterator();
		for(int i=0; i<ml.size(); i++)	{
			Map choiceMap = (Map) ml.get(i);
%>        
			<option selected value ="<%=XSSUtil.encodeForHTMLAttribute(context, (String) choiceMap.get("choice"))%>" > <%=XSSUtil.encodeForHTMLAttribute(context, (String) choiceMap.get("translation"))%></option>
<%
		}
%>
			<option value="*" selected><emxUtil:i18n localize="i18nId">emxComponents.Download.All</emxUtil:i18n></option>
		</select>
		
      </td>
    </tr>
  </table>
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

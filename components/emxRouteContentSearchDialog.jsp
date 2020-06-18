<%--  emxRouteContentSearchDialog.jsp - The content page of the main search

      Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne, Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended
      publication of such program

   static const char RCSID[] = $Id: emxRouteContentSearchDialog.jsp.rca 1.32 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="Javascript">

  function frmChecking(strFocus) {
    var strPage=strFocus;
  }

  function doSearch() {  
  	//var strQueryLimit = parent.frames[3].document.bottomCommonForm.QueryLimit.value;
  	var strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
    document.frmPowerSearch.queryLimit.value = strQueryLimit;     
    startProgressBar(true);
    document.frmPowerSearch.submit();
  }

  function ClearSearch() {
    document.frmPowerSearch.txtName.value = "*";
    document.frmPowerSearch.txtRev.value = "*";
  }

</script>

<%
  String languageStr = request.getHeader("Accept-Language");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String objectId = emxGetParameter(request,"objectId");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String portalMode  = emxGetParameter(request,"portalMode");
  String sDefaultSymbolicType = JSPUtil.getApplicationProperty(context,application, "emxComponents.Routes.DefaultContentType");
  if ((sDefaultSymbolicType == null) || ("".equals(sDefaultSymbolicType)))
  	sDefaultSymbolicType = "type_Document";

  String sDefaultType = PropertyUtil.getSchemaProperty(context, sDefaultSymbolicType);
  String sDefaultDisplayType = i18nNow.getAdminI18NString("Type", sDefaultType, languageStr);
 
  session.putValue("routeApp",suiteKey);
 
  String relType=DomainObject.RELATIONSHIP_OBJECT_ROUTE;
  String searchTypes = "";
  String mqlCmd = "print relationship \"" + relType + "\" select fromtype dump";

  // Use the list returned from mql to populate the type chooser
  try {
  	searchTypes = MqlUtil.mqlCommand(context, mqlCmd);
  }
  catch (FrameworkException fe) {
    searchTypes = " ";
  }
%>

<script>
  function showTypeSelector() {
	  var sURL    = '../common/emxTypeChooser.jsp?fieldNameDisplay=selTypeDisp&fieldNameActual=selType&formName=frmPowerSearch&SelectType=single&SelectAbstractTypes=true&InclusionList=<%= XSSUtil.encodeForURL(context,searchTypes)%>&ObserveHidden=false&ShowIcons=true';
	  showChooser(sURL,500,400);
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="frmPowerSearch" method="post" onSubmit="javascript:doSearch(); return false" action="../common/emxTable.jsp" target="_parent">
<input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sDefaultType%></xss:encodeForHTMLAttribute>" />

<table border="0" cellspacing="2" cellpadding="3" width="100%" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
      <input readonly="readonly" type="text" size="16" name="selTypeDisp" onchange="JavaScript:ClearSearch()" value="<xss:encodeForHTMLAttribute><%=sDefaultDisplayType%></xss:encodeForHTMLAttribute>"/>
      <input type="button" value="..." onclick="javascript:showTypeSelector();"/>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtName" size="16" value="*"/></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Revision</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtRev" size="16" value="*"/></td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></td>
    <td class="inputField"><input type="text" name="txtDesc" size="16" value="*"/></td>
  </tr>

<input type="hidden" name="mode" value="powersearch"/>
<input type="hidden" name="saveQuery" value="false"/>
<input type="hidden" name="Style" value="dialog"/>
<input type="hidden" name="changeQueryLimit" value="true"/>
<input type="hidden" name="multiSelect" value="<xss:encodeForHTMLAttribute><%=multiSelect%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="targetSearchPage" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
<!-- Modified for the Bug No:326829 11/16/2006 Begin -->
<input type="hidden" name="header" value="<emxUtil:i18n localize="i18nId">emxComponents.ContentSearch.Page2Heading</emxUtil:i18n>"/>
<!-- Modified for the Bug No:326829 11/16/2006 End -->
<input type="hidden" name="SubmitButton" value="true"/>
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="SubmitURL" value="../components/emxRouteAddContentProcess.jsp?fromPage=addFromTaskSummary"/>
<input type="hidden" name="program" value="emxRouteContentSearch:getContents"/>
<input type="hidden" name="table" value="APPRouteContentSearchResults"/>
<input type="hidden" name="sortColumnName" value="Name"/>
<input type="hidden" name="CancelButton" value="true"/>
<input type="hidden" name="bottomActionbar" value="APPRouteContentSearchActionBar"/>
<input type="hidden" name="HelpMarker" value="emxhelpfindcontentroute"/>
<input type="hidden" name="queryLimit" value=""/>
</table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

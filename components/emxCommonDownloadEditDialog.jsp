<%-- emxCommonDownloadEditDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDownloadEditDialog.jsp.rca 1.2.7.5 Wed Oct 22 16:18:52 2008 przemek Experimental przemek $ 
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>



<script language="javascript">

	function submitDownload() {
		if(jsIsClicked()) {
			alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
			return;
		}
		if(jsDblClick())
		{
			startSearchProgressBar();
			document.downloadForm.submit();
		}
	}


	function closeWindow() {
		window.closeWindow();
		return;
	}

</script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>


<%

	String languageStr = request.getHeader("Accept-Language");
	String strRelId = emxGetParameter(request, "relId");

	DomainRelationship domRel = new DomainRelationship(strRelId);
	Map map = domRel.getAttributeMap(context);

	String strOriginator = emxGetParameter(request, "originator");
	strOriginator = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, strOriginator);
	
	
%>

<body onload="turnOffProgress()">
<form name="downloadForm" id="downloadForm" method="post" target="_parent" action="emxCommonDownloadEditDialogProcess.jsp" >
	
	<input type="hidden" name="loginName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"loginName")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=strRelId%></xss:encodeForHTMLAttribute>" />


  <table border="0" cellpadding="5" cellspacing="2" width=100% >
	<tr>
      <td class="label" width=150>
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n>
      </td>
      <td class="inputField" width=380><%=XSSUtil.encodeForHTML(context,strOriginator)%></td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Document</emxUtil:i18n>
      </td>
      <td class="inputField"><%=XSSUtil.encodeForHTML(context,emxGetParameter(request, "documentName"))%></td>
    </tr>

    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.DownloadedComponents</emxUtil:i18n>
      </td>
      <td class="inputField"><%=XSSUtil.encodeForHTML(context, map.get("Download Files").toString())%></td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Originated</emxUtil:i18n>
      </td>
      <td class="inputField"><%=XSSUtil.encodeForHTML(context,map.get("Download Time").toString())%></td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.Status</emxUtil:i18n>
      </td>
      <td class="inputField">
	  		<select name = "status">
<%
		String strStatus    = PropertyUtil.getSchemaProperty(context, "attribute_DownloadStatus");
		StringList slStatus = mxAttr.getChoices(context, strStatus);
		String strLanguage = request.getHeader("Accept-Language");
		MapList ml = AttributeUtil.sortAttributeRanges(context, strStatus, slStatus, strLanguage);
		Iterator mlItr = ml.iterator();
		for(int i=0; i<ml.size(); i++)
		{
			Map choiceMap = (Map) ml.get(i);
%>        
			<option selected value ="<%=XSSUtil.encodeForHTMLAttribute(context,(String) choiceMap.get("choice"))%>" > <%=XSSUtil.encodeForHTML(context,(String) choiceMap.get("translation"))%></option>
<%
		}
%>
		</select>
		<script>document.downloadForm.status.value="<%=XSSUtil.encodeForJavaScript(context,map.get("Download Status").toString())%>";</script>
		</td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.ParentComponent</emxUtil:i18n>
      </td>
      <td class="inputField"><%=XSSUtil.encodeForHTML(context,emxGetParameter(request, "partName"))%></td>
	</tr>
  </table>
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

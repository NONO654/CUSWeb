<%-- emxCommonUsageCreateDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonUsageDialog.jsp.rca 1.5.7.5 Wed Oct 22 16:18:04 2008 przemek Experimental przemek $ 
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@ page import = "com.matrixone.apps.common.Download"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">

	function setWindowSize()
	{
		getTopWindow().window.resizeTo(570, 520);
	}
	function trim(strString) {
			strString = strString.replace(/^\s*/g, "");
			return strString.replace(/\s+$/g, "");
	} 
  
	function checkBadChars(ele)
	{
		if ( ! checkForNameBadChars( ele.value, false) )
		{
			alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.NotValidEntry</emxUtil:i18nScript>");
			ele.value = "";
			ele.focus();
			return false;
		}
		return true;
	}

	function updateUsage() 
	{
		if(submitUsage() == false)
		{
			return;
		}
	}
	function submitUsage() 
	{

		var tupValue = document.usageCreate.trackUsagePartId.value;
		if(tupValue == "" || tupValue == "null")
		{
			document.usageCreate.trackUsagePartId.value = document.usageCreate.partId.value;
		}
		var trackPartId = document.usageCreate.trackUsagePartId.value;
		if(trackPartId == "" || "null" == trackPartId)
		{
			alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Download.ChoosePart</emxUtil:i18nScript>");
			return;
		}
		//XSSOK
		var isTrackUsageOn = <%=Download.isTrackUsageOn(context)%>;
		if(isTrackUsageOn)
		{
			var sPurpose =  trim(document.usageCreate.txtPurpose.value);

			if ( sPurpose == "" ) 
			{
			  alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Download.UsagePurpose</emxUtil:i18nScript>");
			  document.usageCreate.txtPurpose.value = "";
			  document.usageCreate.txtPurpose.focus();
			  return false;
			}

			if ( ! checkBadChars( document.usageCreate.txtPurpose ) )
			{
				return false;
			}
		}

		if(jsIsClicked()) {
			alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
			return false;
		}
		if(jsDblClick())
		{
			startSearchProgressBar();
			document.usageCreate.submit();
		}
	}

	function closeWindow() {
		window.closeWindow();
		return;
	}

	function findPart(sObjId)
	{
		var sURL    = '../components/emxCommonSearch.jsp?formName=usageCreate';
		sURL        = sURL + '&frameName=pageContent&fieldNameActual=partId';
		sURL        = sURL + '&fieldNameDisplay=txtPart&searchmode=chooser';
		sURL        = sURL + '&suiteKey=Components&searchmenu=APPCommonUsagePartChooser';
		sURL        = sURL + '&searchcommand=APPCommonUsagePartChooserCommand';
		sURL        = sURL + '&srcDestRelName=relationship_ReferenceDocument&isTo=false';
		sURL		= sURL + '&objectId='+sObjId;
		
		showChooser(sURL, 700, 500);
	}

	function replaceAll(oldStr,findStr,repStr) {
	  var srchNdx = 0;  // srchNdx will keep track of where in the whole line
						// of oldStr are we searching.
	  var newStr = "";  // newStr will hold the altered version of oldStr.
	  while (oldStr.indexOf(findStr,srchNdx) != -1)  
	  {
		newStr += oldStr.substring(srchNdx,oldStr.indexOf(findStr,srchNdx));
						// Put it all the unaltered text from one findStr to
						// the next findStr into newStr.
		newStr += repStr;
						// Instead of putting the old string, put in the
						// new string instead. 
		srchNdx = (oldStr.indexOf(findStr,srchNdx) + findStr.length);
						// Now jump to the next chunk of text till the next findStr.           
	  }
	  newStr += oldStr.substring(srchNdx,oldStr.length);
						// Put whatever's left into newStr.             
	  return newStr;
	}

	function displayFieldsOne()
	{
		var sLoc = new String(getTopWindow().document.location);

		var iIndex = sLoc.indexOf("trackUsagePartId=");

		var lIndex = sLoc.indexOf("&", iIndex);

		if(lIndex != -1)
		{
			sLoc = sLoc.substring(0, iIndex) + "trackUsagePartId="+ document.usageCreate.partId.value + sLoc.substring(lIndex);
			
		}else
		{
			sLoc = sLoc.substring(0, iIndex) + "trackUsagePartId="+ document.usageCreate.partId.value ;
		}
		sLoc += "&checkPart=true";
		//XSSOK
		var isTrackUsageOn = <%=Download.isTrackUsageOn(context)%>;

		if(isTrackUsageOn)
		{
			getTopWindow().document.location = sLoc;
		}else
		{
			getTopWindow().document.location = document.usageCreate.downloadForwardURL.value+ "trackUsagePartId=" + document.usageCreate.partId.value;
		}
	}
	function showFields() {
		document.getElementById('rowStateOfUsage').style.display='';
		document.getElementById('rowPurpose').style.display='';
		document.getElementById('rowDocument').style.display='';
		document.getElementById('rowOriginator').style.display='';
	}
	function hideFields() {
		document.getElementById('rowStateOfUsage').style.display='none';
		document.getElementById('rowPurpose').style.display='none';
		document.getElementById('rowDocument').style.display='none';
		document.getElementById('rowOriginator').style.display='none';
	}
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
	String strDownloadForwardURL = emxGetParameter(request, "downloadForwardURL");
	String strPartId = emxGetParameter(request, "trackUsagePartId");
	String strRelId = emxGetParameter(request, "relId");
	String strDocumentId = emxGetParameter(request, "documentId");
	String strDocIds = emxGetParameter(request, "docIds");
	if(strDocumentId != null && strDocumentId.indexOf("|") != -1)
	{
		strDocIds = strDocumentId.substring(strDocumentId.indexOf("|")+1);
		strDocumentId = strDocumentId.substring(0, strDocumentId.indexOf("|"));
		if("".equals(strDocumentId))
		{
			strDocumentId = strDocIds;
		}
	}

	String requiredMsg = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.FormComponent.FieldsInRedItalicsAreRequired"); 
	String strDownloadId = emxGetParameter(request, "downloadId");
	String strPartName = "";
	String strDocumentName = emxGetParameter(request, "documentName");
	
	String strPurpose = "";
	String strStateOfUsage = "";
	boolean bRefreshContent = true;
	boolean isEdit = (strRelId == null || "".equals(strRelId) || "null".equals(strRelId)) ? false : true;
	
	if(isEdit)
	{
		DomainRelationship domRel = new DomainRelationship(strRelId);
		Map map = domRel.getAttributeMap(context);
		strPurpose = (String)map.get(Download.ATTRIBUTE_DOWNLOAD_PURPOSE);
		strStateOfUsage = (String)map.get(Download.ATTRIBUTE_STATE_OF_USAGE);
		if(!"true".equalsIgnoreCase(request.getParameter("refreshContent")))
		{
			bRefreshContent = false;
		}

		if(strPartId == null || "null".equals(strPartId) || "".equals(strPartId))
		{
			StringList sl = new StringList(3);
			sl.add("from.from["+Download.RELATIONSHIP_DOWNLOAD_CONTEXT+"].to.id");
			sl.add("from.from["+Download.RELATIONSHIP_DOWNLOAD_CONTEXT+"].to.name");
			String[] strArrRelId = {strRelId};
			MapList mapListPart = domRel.getInfo(context, strArrRelId, sl);
			Map mapPart = (Map)mapListPart.get(0);
			strPartId = (String)mapPart.get("from.from["+Download.RELATIONSHIP_DOWNLOAD_CONTEXT+"].to.id");
			strPartName = (String)mapPart.get("from.from["+Download.RELATIONSHIP_DOWNLOAD_CONTEXT+"].to.name");
		}
	}
	if(strDocumentName == null || "null".equals(strDocumentName) || "".equals(strDocumentName))
	{
		DomainObject domDocument = new DomainObject(strDocumentId);
		strDocumentName = domDocument.getName(context);
	}
	if(strPartId != null && "".equals(strPartName))
	{
		strPartName = new DomainObject(strPartId).getName(context);
	}
%>
<body onload="setWindowSize()">

<form name="usageCreate" id="usageCreate" method="post"  target="_parent" action="emxCommonUsageDialogProcess.jsp" onSubmit="return submitUsage();">
  <input type="hidden" name="loginName" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"loginName") %></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=strRelId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="documentId" value="<xss:encodeForHTMLAttribute><%=strDocumentId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="docIds" value="<xss:encodeForHTMLAttribute><%=strDocIds%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="downloadId" value="<xss:encodeForHTMLAttribute><%=strDownloadId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="downloadForwardURL" value="<xss:encodeForHTMLAttribute><%=strDownloadForwardURL%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="trackUsagePartId" value="<xss:encodeForHTMLAttribute><%=strPartId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="docIds" value="<xss:encodeForHTMLAttribute><%=strDocIds%></xss:encodeForHTMLAttribute>" />
    <!-- //XSSOK -->
    <input type="hidden" name="refreshContent" value="<%=bRefreshContent%>" />
  
	<table border="0" cellpadding="5" cellspacing="2" width="500">
	<tr><td>&nbsp;</td><td class="requiredNotice"><%=requiredMsg%></td></tr>
    <tr><!-- //XSSOK -->
		<td class="<%= (strPartId == null || "null".equals(strPartId) || "".equals(strPartId)) ? "labelRequired" : "label" %>" >
			<emxUtil:i18n localize="i18nId">emxComponents.Common.Part</emxUtil:i18n>
		</td>
		<td class="inputField">
		<%
		if(strPartId == null || "null".equals(strPartId) || "".equals(strPartId) || "true".equals(emxGetParameter(request, "checkPart")))
		{
			%>
				<input type="text" name="txtPart" id="txtPart" value="<xss:encodeForHTMLAttribute><%=strPartName%></xss:encodeForHTMLAttribute>" onChange="displayFields()" readonly/> <input type="button" value="..." name="btntype" id="btntype" onclick="findPart('<xss:encodeForJavaScript><%=strDocumentId%></xss:encodeForJavaScript>')" />
				<input type="hidden" name="partId" id="partId" value="<xss:encodeForHTMLAttribute><%=strPartId%></xss:encodeForHTMLAttribute>" onChange="displayFields()" />
			<%
		}else
		{
			out.println(strPartName);
		}
		%>
		</td>
    </tr>
	<tr id='rowDocument'>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Document</emxUtil:i18n>
      </td>
      <td class="inputField"><%=XSSUtil.encodeForHTML(context,strDocumentName)%>
      </td>
    </tr>
	<tr id='rowOriginator'>
		<td class="label">
        <emxUtil:i18n localize="i18nId">emxComponents.Common.Originator</emxUtil:i18n>
		</td>
		<td class="inputField"><%=XSSUtil.encodeForHTML(context, PersonUtil.getFullName(context))%>
		</td>
	</tr>	
    <tr id='rowStateOfUsage'>
      <td class="label" id='cellStateOfUsage1'>
        <emxUtil:i18n localize="i18nId">emxComponents.Download.StateOfUsage</emxUtil:i18n>
      </td>
      <td class="inputField" id='cellStateOfUsage2'>
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
			<option selected value ="<%=XSSUtil.encodeForHTMLAttribute(context, (String) choiceMap.get("choice"))%>" > <%=XSSUtil.encodeForHTML(context, (String) choiceMap.get("translation"))%></option>
<%
		}
		if(isEdit)
		{
			out.println("<script>document.usageCreate.selStateOfUsage.value=\""+strStateOfUsage+"\";</script>");
		}
%>
		</select>
		<script>document.usageCreate.selStateOfUsage.value="<%=XSSUtil.encodeForJavaScript(context, strStateOfUsage)%>";</script>
      </td>
    </tr>

	<tr id='rowPurpose'>
      <td class="labelRequired">
        <emxUtil:i18n localize="i18nId">emxComponents.Download.Purpose</emxUtil:i18n>
      </td>
      <td class="inputField">
        <textarea name="txtPurpose"  rows="5" cols="36" id="txtPurpose"><%=strPurpose%></textarea>
      </td>
    </tr>



	</table>
</form>
</body>

<%
	if(strPartId == null || "null".equals(strPartId) || "".equals(strPartId))
	{
		%>
		<script>hideFields();</script>
		<%
	}
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

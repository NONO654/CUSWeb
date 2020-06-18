<%--  emxMultiObjectTransferOwnershipReportDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This JSP is used for internal purpose of BPS product and this is NOT designed for consumption by any other application/product.
   BPS do not provide support for any such usage.
   This JSP will display page having options to select new Owner, Organization and Collaborative Space to whom the ownership will be transferred.
 --%>
<html>
<head>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>
<jsp:useBean id="uiFormBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<%
String reLoad   	= emxGetParameter(request,"reLoad");
String objectIds	= "";

if(UIUtil.isNullOrEmpty(reLoad)){
	String rowIds[]		= FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
	if(rowIds != null){
		for(int i = 0;i <rowIds.length; i++ ){
			objectIds += rowIds[i] +"|";
		}
	}
		objectIds 			= objectIds.substring(0, objectIds.lastIndexOf("|"));
		uiFormBean.setObjectIds(objectIds);
		String url	= "../common/emxForm.jsp?form=MultiObjectTransferOwnership&mode=edit&showPageURLIcon=false&postProcessURL=../common/emxMultiObjectTransferOwnershipProcess.jsp&findMxLink=false&formHeader=emxFramework.Command.MultiObjectTransferOwnership";    //objectIds="+ XSSUtil.encodeForURL(context, objectIds);

%>
	<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
	<script  type="text/javascript" >
		//XSSOK
		var strURL = "<%= url%>";
		getTopWindow().location.href = strURL;
	</script>
<%
} else {
HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String strLanguage = (String) requestMap.get("languageStr");
String strProgressImage = "images/utilProgressBlue.gif";
String strProcessingText = UINavigatorUtil.getProcessingText(context, strLanguage);
String close = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.Close", new Locale(strLanguage));
//String errorMessage = (String) requestMap.get("errorMessage");
String failedObjects = (String) requestMap.get("failedObjects");
String totalCount = (String) requestMap.get("totalCount");
int inttotcnt = Integer.valueOf(totalCount);
String description = (String) requestMap.get("description");
String strOdd = "odd";
StringList failedObjectsList = FrameworkUtil.split(failedObjects, "|");
StringList descriptionList = FrameworkUtil.split(description, "|");
String errorMessage	= com.matrixone.apps.domain.util.MessageUtil.getMessage(context,null,"emxFramework.TransferOwnership.ErrorMessage", new Integer[]{failedObjectsList.size(), inttotcnt},null, new Locale(strLanguage),"emxFrameworkStringResource");
%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>
<script language="JavaScript" type="text/JavaScript">
addStyleSheet("emxUIDOMLayout");
addStyleSheet("emxUIToolbar");
addStyleSheet("emxUIList");
</script>
</head>

<title><emxUtil:i18n localize="i18nId">emxFramework.Command.MultiObjectTransferOwnership</emxUtil:i18n></title>
<body  onload="turnOffProgress()">
<div id="pageHeadDiv" >
<form name="ErrorReportDialog" action="">
<table  border="0" width="100%" cellspacing="0" cellpadding="0">
	<tr>
	<td width="1%" nowrap><span class="pageHeader">&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.TransferOwnership.ReportHeader</emxUtil:i18n></span>
	</td>
	<td nowrap>
	<div id="imgProgressDiv">&nbsp;<img src="<%=strProgressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=strProcessingText%></i></div></td>
    <td width="1%"><img src="images/utilSpacer.gif" width="1" height="10" border="0" alt="" vspace="4" /></td>
</tr>
</table>
<jsp:include page="emxToolbar.jsp" flush="true">
	<jsp:param name="HelpMarker" value="false" />
	<jsp:param name="header" value="" />
	<jsp:param name="suiteDir" value="" />
	<jsp:param name="portalMode" value="" />
    <jsp:param name="PrinterFriendly" value="false"/>
    <jsp:param name="expandLevelFilter" value="false"/>
    <jsp:param name="export" value="false"/>
    <jsp:param name="editLink" value="false"/>
    <jsp:param name="customize" value="false"/>
    <jsp:param name="multiColumnSort" value="false"/>
</jsp:include>   
</form>
</div>
<div id="divPageBody" style="top: 64px;">
	<table>
		<tr>
			<td style="color:#D00;"><%= errorMessage%></td>
		</tr>
	</table>
<table class='list'>
<tr><th width="30%"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.JavaScript.Name", new Locale(strLanguage))%></th><th ><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.JavaScript.Description", new Locale(strLanguage) )%></th>
<%
for(int i = 0; i < failedObjectsList.size(); i++){
	if (i%2 == 0)
	{
	    strOdd ="even";
	}
%>
<!-- XSSOK -->
<tr class = <%=strOdd%>>
<td ><xss:encodeForHTML><%= failedObjectsList.get(i)%></xss:encodeForHTML></td>
<td ><xss:encodeForHTML><%= descriptionList.get(i)%></xss:encodeForHTML></td>
</tr>
<%
	strOdd ="odd";
}
%>
</table>
</div>

<div id="divPageFoot">
<form name="editFooter" method="post">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
	<tr>
    	<td class="pagination"></td>
		<td class="buttons">
    	<table>
          	<tr>
				<!-- //XSSOK -->
				<td><a class="footericon" href="javascript:getTopWindow().closeWindow();"><img src="images/buttonDialogCancel.gif" alt="<%=close%>" /></a></td>
				<!-- //XSSOK -->
				<td><a onClick="javascript:getTopWindow().closeWindow();"><button class="btn-primary" type="button"><%=close%></button></a></td>
        	</tr>
        </table>
        </td>
	</tr>
</table>
</form>          
</div>
</body>
</html>
<%
}
%>


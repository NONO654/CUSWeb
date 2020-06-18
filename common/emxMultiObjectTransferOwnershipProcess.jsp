<%--  emxMultiObjectTransferOwnershipProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This JSP is used for internal purpose of BPS product and this is NOT designed for consumption by any other application/product.
   BPS do not provide support for any such usage.
   This JSP is used to transfer the ownership to the new user.
--%>
<html>
<head>	
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "emxNavigatorInclude.inc"%>
<jsp:useBean id="transferOwnership" class="com.matrixone.apps.framework.ui.UITransferOwnership" scope="session"/>
<jsp:useBean id="uiFormBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<%

//start the transaction
ContextUtil.startTransaction(context, true);
HashMap requestMap 			= UINavigatorUtil.getRequestParameterMap(pageContext);
String objectIds            = uiFormBean.getObjectIds();
StringList objectIdslist	= FrameworkUtil.split(objectIds, "|");
requestMap.put("objectIds", objectIds);
StringList result = transferOwnership.process(context, requestMap);
uiFormBean.clearObjectIds();
if(result.size() > 0){		
	//to abort the transaction, even if ownership transfer of one object fails.
	String loadURL 		= "emxMultiObjectTransferOwnershipReportDialog.jsp?reLoad=true&failedObjects="+XSSUtil.encodeForURL(context, result.get(0).toString())+"&description="+XSSUtil.encodeForURL(context, result.get(1).toString())+"&totalCount=" + objectIdslist.size();
	ContextUtil.abortTransaction(context);
%>
	<script type="text/javascript" language="JavaScript">
	//XSSOK
		getTopWindow().location.href = "<%=loadURL%>";
	</script>
<% 
} else {
	ContextUtil.commitTransaction(context);
%>
	<script type="text/javascript" language="JavaScript"> 
		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.TransferOwnership.SuccessMessage</emxUtil:i18nScript>");
		getTopWindow().closeWindow();
		getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
	</script>
<%
}
%>


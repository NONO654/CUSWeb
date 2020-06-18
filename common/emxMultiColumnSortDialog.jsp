 <%-- emxMultiColumnSortDialog.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="emxNavigatorInclude.inc"%>

<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String strLanguage = request.getHeader("Accept-Language");
	String helpDone = UINavigatorUtil.getI18nString(
	        "emxFramework.FormComponent.Done",
	        "emxFrameworkStringResource", strLanguage);
	String helpCancel = UINavigatorUtil.getI18nString(
	        "emxFramework.FormComponent.Cancel",
	        "emxFrameworkStringResource", strLanguage);
	String strMultiColumnSortTitle = UINavigatorUtil.getI18nString(
	        "emxFramework.Common.Title.MultiColumnSort",
            "emxFrameworkStringResource", strLanguage);
	String timeStamp = emxGetParameter(request,"timeStamp");
	String uiType = emxGetParameter(request,"uiType");
	String HelpMarker = "emxhelpmulticolumnsort";
	//FIX-ME modify the string based on FSP after finalization
String languageStr = request.getHeader("Accept-Language");	
String processingText = UINavigatorUtil.getProcessingText(context, languageStr);	
%>

<html>
<head>
	<%@include file = "emxUIConstantsInclude.inc"%>
	<script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
	<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
	<script type="text/javascript" language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>

  <script language="JavaScript" type="text/JavaScript">
	addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIForm");
  	addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIDOMLayout");
	addStyleSheet("emxUIDialog");
    addStyleSheet("emxUIMenu");
  </script>

<script language="JavaScript" type="text/JavaScript">		
		function clickDoneButton(){
			turnOnProgress("utilProgressBlue.gif");
            setTimeout("getTopWindow().closeWindow()", 500);
			var dialogBody = findFrame(this,"formMultiColumnSortDialogDisplay");
			dialogBody.document.forms.multiColumnSortBody.submit();
		}
	</script>
</head>
<title><%=strMultiColumnSortTitle%></title>

<body class='dialog' onload="turnOffProgress();">
	<div id="pageHeadDiv" >
 <table>
       <tr>
      <td class="page-title">
        <h2><emxUtil:i18n localize="i18nId">emxFramework.Common.Title.Sortby</emxUtil:i18n></h2>
      </td>
    <td class="functions">
        <table>
            <tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>	
			</tr>
		</table>
	</td>
	</tr>
	</table>

		<jsp:include page="../common/emxToolbar.jsp" flush="true">
				<jsp:param name="helpMarker" value="<%=HelpMarker%>" />
				<jsp:param name="PrinterFriendly" value="false" />
				<jsp:param name="export" value="false" />
				<jsp:param name="uiType" value="null"/>
				<jsp:param name="multiColumnSort" value="false" />
				<jsp:param name="expandLevelFilter" value="false" />
				<jsp:param name="massPromoteDemote" value="false" />
				<jsp:param name="showClipboard" value="false" />
				<jsp:param name="triggerValidation" value="false" />
		</jsp:include>
	</div>

	<div id="divPageBody">
		<iframe name="formMultiColumnSortDialogDisplay"	src="emxMultiColumnSortDialogBody.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>&uiType=<%=XSSUtil.encodeForURL(context, uiType)%>"
				width="100%" frameborder="0" border="0" scrolling="no"></iframe>
	</div>

	<div id="divPageFoot">
		<table border="0" cellspacing="0" cellpadding="0" width="100%">
		<tr>
		    <td class="functions"></td>
			<td class="buttons">	
				<table border="0" cellspacing="0" cellpadding="0" align="right" style="padding: 10px 10px 10px 0px;">
					<tr>
						<td><a class="footericon" href="javascript:clickDoneButton()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.BackgroundProcess.Button.Done</emxUtil:i18n>" src="images/buttonDialogDone.gif" /></a></td>
						<td nowrap><a onClick="javascript:clickDoneButton()" class="button"><button class="btn-primary" type="button"><emxUtil:i18n localize="i18nId">emxFramework.BackgroundProcess.Button.Done</emxUtil:i18n></button></a></td>
						
						<td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>" src="images/buttonDialogCancel.gif" /></a></td>
						<td nowrap><a class="button" onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></button></a></td>
					</tr>
				</table>
			</td>
		</tr>
		</table>		
	</div>
</body>
</html>

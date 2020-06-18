<%-- emxComponentsCheckinDialogFS.jsp - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckinDialogFS.jsp.rca 1.14 Tue Oct 28 23:01:04 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<html>
<head>
<%
		String sAppName = EnoviaResourceBundle.getProperty(context,"emxFramework.Application.Name");
		// Getting the display name for the page.
    	String pageHeading = ComponentsUtil.i18nStringNow("emxComponents.Common.CheckinDocuments",request.getHeader("Accept-Language"));
		String sHelpMarker = "emxhelpcheckindocument";
		
  String charset = com.matrixone.apps.framework.ui.UINavigatorUtil.getCheckinEncoding(context, request);
  String queryString = request.getQueryString();
%>
	<title><%=sAppName%></title>

	<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIFilterUtility.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIActionbar.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
	<script language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>
	<script language="JavaScript" src="../emxUIPageUtility.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIBottomPageJavaScriptInclude.js"></script>
	<script language="JavaScript" type="text/JavaScript">
		addStyleSheet("emxUIDefault");    
		addStyleSheet("emxUIToolbar");    
		addStyleSheet("emxUIMenu");    
		addStyleSheet("emxUIDOMLayout");
		addStyleSheet("emxUIDialog");
	</script>
</head>
<body onload=turnOffProgress();>		
	<div id="pageHeadDiv">
		<form>
	    	<table>
				<tr>
					<td class="page-title"><h2 id="ph"><%=XSSUtil.encodeForHTML(context, pageHeading)%></h2></td>
					<td class="functions">
           				<table>
           					<tr>
         						<td class="progress-indicator"><div id="imgProgressDiv"></div></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
			<jsp:include page = "../common/emxToolbar.jsp" flush="true">
				<jsp:param name="toolbar" value=""/>
				<jsp:param name="suiteKey" value="Components"/>
				<jsp:param name="PrinterFriendly" value="false"/>
				<jsp:param name="helpMarker" value="<%=sHelpMarker%>"/>
				<jsp:param name="export" value="false"/>
			</jsp:include>
		</form>							
	</div>
			
	<div id='divPageBody'>
  		<iframe name='checkinFrame' id='checkinFrame' src="emxComponentsCheckinDialog.jsp?<%=XSSUtil.encodeForHTML(context, queryString)%>&checkinEncoding=<%=XSSUtil.encodeForHTML(context, charset)%>" width='100%' height='100%' frameborder='0' border='0' scrolling="auto"></iframe>
	</div>
	
	<div id="divPageFoot">
		<div id="divDialogButtons">
			<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
				<tr>
					<td align="right">
						<table border="0" cellspacing="0">
					  		<tr>
								<td><div id="CheckinText">
									<a onclick="javascript:window.frames['checkinFrame'].checkinFile()" class="button">
									<button class="btn-primary" type="button">
										<emxUtil:i18n localize="i18nId">emxComponents.Common.Checkin</emxUtil:i18n>
									</button></a>
									</div>
								</td>
		                		<td>&nbsp;&nbsp;</td>
								<td>
									<div id="CloseText">
									<a onclick="javascript:window.closeWindow()" class="button">
										<button class="btn-default" type="button">
											<emxUtil:i18n localize="i18nId">emxComponents.Common.Cancel</emxUtil:i18n>
										</button>
									</a>
									</div>
								</td>
					  		</tr>
						</table>
				  	</td>
				</tr>
		  	</table>
		</div>			
	</body>
</html>

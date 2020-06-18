<%-- emxChangePasswordButtons.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxChangePasswordForm.jsp.rca 1.10 Wed Oct 22 15:48:53 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<head>
<title>Change Password</title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStyleDialogInclude.inc"%>
<script type="text/javascript">
    addStyleSheet("emxUIForm");
</script>
<script language="Javascript">
//function to validate user entry
function submitForm()
{
  document.frmChangePass.target = 'pagehidden';
  document.frmChangePass.submit();
}

	function doCancel() {
		getTopWindow().closeWindow();
	}
</script>
</head>

<body onload="turnOffProgress();" leftMargin="0" topMargin="0" MARGINHEIGHT="0" MARGINWIDTH="0" class="content">
<%
  String Pageresponse = emxGetParameter(request, "pageResponse");
%>
<form name="frmChangePass" method="post" onsubmit="submitForm(); return false" action="emxChangePasswordProcess.jsp">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<table width="95%" border="0" cellpadding="2" cellspacing="1">
<tr>
	<td>&nbsp;</td><td class="requiredNotice"><emxUtil:i18n localize="i18nId">emxFramework.Commom.RequiredText</emxUtil:i18n></td>
</tr>
  <tr>
    <td class="labelRequired"><b><emxUtil:i18n localize="i18nId">emxFramework.Login.Username</emxUtil:i18n></b></td>
    <td class="inputField"><%=context.getUser()%><input type="hidden" name="txtUserName" value="<%=context.getUser()%>" /></td>
  </tr>
  <tr>
    <td class="labelRequired"><b><emxUtil:i18n localize="i18nId">emxFramework.Login.CurrentPassword</emxUtil:i18n></b></td>
    <td class="inputField"><input type="password" name="txtCurrentPassword" size="30" /></td>
  </tr>
  <tr>
    <td class="labelRequired"><b><emxUtil:i18n localize="i18nId">emxFramework.Login.NewPassword</emxUtil:i18n></b></td>
    <td class="inputField"><input type="password" name="txtNewPassword" size="30" /></td>
  </tr>
  <tr>
    <td class="labelRequired"><b><emxUtil:i18n localize="i18nId">emxFramework.Login.VerifyNewPassword</emxUtil:i18n></b></td>
    <td class="inputField"><input type="password" name="txtConfirmPassword" size="30" /></td>
  </tr>
</form>

</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>

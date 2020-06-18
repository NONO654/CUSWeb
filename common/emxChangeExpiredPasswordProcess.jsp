<%-- emxChangeExpiredPasswordProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxChangeExpiredPasswordProcess.jsp.rca 1.8 Wed Oct 22 15:48:35 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String sChangePassword = i18nNow.getI18nString("emxFramework.Common.ChangePassword", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
  String sUserName = emxGetParameter(request, "txtUsername");
  String sNewPassword = emxGetParameter(request, "txtNewPassword");
  String sConfirmPassword = emxGetParameter(request, "txtConfirmPassword");
  String sCurrentPassword = emxGetParameter(request, "txtOldPassword");

  String sResponse = i18nNow.getI18nString("emxFramework.Login.PasswordChangedSuccessfully", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
  boolean isProblem=false;
  try
  {
    context.setPassword(sCurrentPassword, sNewPassword, sConfirmPassword);
  }
  catch(Exception me)
  {
    sResponse = me.toString();
    isProblem=true;
  }
%>

<%
if(!isProblem)
{
%>
<script language="javascript">
document.location.href = "../emxLogout.jsp";
</script>

<%}else{
%>
<script language="javascript">
//XSSOK
alert("<%=sResponse.trim()%>");
document.location.href = "emxChangeExpiredPassword.jsp";
</script>
<%}%>


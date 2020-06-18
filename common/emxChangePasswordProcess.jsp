<%-- emxChangePasswordProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChangePasswordProcess.jsp.rca 1.11 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<html>
<head>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
  function gotoPasswordFrameset()
    {
    document.password.target= "pwdHiddenFrame";
    document.password.action = "emxChangePassword.jsp";
    document.password.method = "post";
    document.password.submit();
    }

</script>
</head>


<%
  String sChangePassword = i18nNow.getI18nString("emxFramework.Common.ChangePassword", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
  String sUserName = emxGetParameter(request, "txtUserName");
  String sNewPassword = emxGetParameter(request, "txtNewPassword");
  String sConfirmPassword = emxGetParameter(request, "txtConfirmPassword");
  String sCurrentPassword = emxGetParameter(request, "txtCurrentPassword");

  String sResponse = i18nNow.getI18nString("emxFramework.Login.PasswordChangedSuccessfully", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
  boolean isProblem=false;
  try
  {
	  Framework.getMainContext(session).setPassword(sCurrentPassword, sNewPassword, sConfirmPassword);
  }
  catch(Exception me)
  {
    sResponse = me.toString();
    isProblem=true;
  }
%>

<%if(!isProblem){%>
<script language="Javascript">
//XSSOK
alert("<%=sResponse%>");
getTopWindow().closeWindow();
</script>

<%}else{

if(sResponse != null){
    sResponse=sResponse.trim();
}
%>
<script language="Javascript">
//XSSOK
alert("<%=sResponse%>");
</script>

<%}%>


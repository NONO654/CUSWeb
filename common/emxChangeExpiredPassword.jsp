<%--  emxChangeExpiredPassword.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxChangeExpiredPassword.jsp.rca 1.9 Wed Oct 22 15:47:51 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<head>
<title></title>

<%@include file = "emxUIConstantsInclude.inc"%>
<script language="javascript" >

// Flag to detect the unload event from submit action or not
var submitAction = false;

function setUnloadMethod()
{
    var bodyElement = document.getElementById("changepwd");
    if (isIE && bodyElement)
    {
        bodyElement.onunload = function () { doLogout(); };
    }
    else
    {
        bodyElement.setAttribute("onbeforeunload",  "doLogout()");
    }
}

// Function to logout the user if user does not submit this form
function doLogout()
{
    if (submitAction != true)
    {
        if (isNS4) {
            window.stop();
        }

        if (isMoz) {
            //XSSOK
            document.location.href = "<%=LogoutServlet.getURL(false)%>";
        } else {
            document.location.href = "../emxLogout.jsp";
        }
    }
}

// Function to submit - and process the change password
function submitForm()
{
    submitAction = true;
    document.forms[0].submit();
}


</script>
<%@include file = "../emxStyleDefaultInclude.inc"%>
</head>
<body id="changepwd" name="changepwd" class="sign-in expired-password" onload="setUnloadMethod()">
  <div id="wrap-outer" class="wrap-outer">
    <div id="wrap-inner" class="wrap-inner">
      <div id="panel-outer" class="panel-outer">
        <div id="panel" class="panel">
          <!-- <h1>Change Expired Password</h1> -->
          <h1><emxUtil:i18n localize="i18nId">emxFramework.Common.ChangePassword</emxUtil:i18n></h1>
          <h2><emxUtil:i18nScript localize='i18nId'>emxFramework.Login.PasswrodExpiredMsg</emxUtil:i18nScript></h2>
          <div id="panelcnt" class="panel-content">
            <form name="chgExpPwdForm" method="post" onsubmit="submitForm(); return false" action="emxChangeExpiredPasswordProcess.jsp">
            <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
            <div id="panel-body" class="panel-body">
              <ul>
                <li>
                  <label><emxUtil:i18n localize="i18nId">emxFramework.Login.Username</emxUtil:i18n></label>
                  <span class="user-name"><%=context.getUser()%></span>
                </li>
                <li>
                  <label><emxUtil:i18n localize="i18nId">emxFramework.Login.CurrentPassword</emxUtil:i18n></label>
                  <span><input type="password" name="txtOldPassword" /></span>
                </li>
                <li>
                  <label><emxUtil:i18n localize="i18nId">emxFramework.Login.NewPassword</emxUtil:i18n></label>
                  <span><input type="password" name="txtNewPassword" /></span>
                </li>
                <li>
                  <label><emxUtil:i18n localize="i18nId">emxFramework.Login.VerifyNewPassword</emxUtil:i18n></label>
                  <span><input type="password" name="txtConfirmPassword" /></span>
                </li>
                <li class="buttons">
                  <button onClick="submitForm(); return false;" class="btn"><label><emxUtil:i18n localize="i18nId">emxFramework.Common.ChangePasswordLabel</emxUtil:i18n></label></button>
                </li>
              </ul>
              </div><!-- /.panel-body -->
            </form>
          </div><!-- /.panel-content -->
        </div><!-- /.panel -->
      </div><!-- /.panel-outer -->
    </div><!-- /.wrap-inner -->
  </div><!-- /.wrap-outer -->
</body>
</html>

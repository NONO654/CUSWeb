<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPasswordPopup.jsp.rca 1.6 Wed Oct 22 15:48:24 2008 przemek Experimental przemek $
--%>

<%@include file = "emxLifecycleUtils.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String sFnName = emxGetParameter(request, "callbackFunctionName");
%>

<script language="JavaScript">

  var functionName = "<xss:encodeForJavaScript><%=sFnName%></xss:encodeForJavaScript>";
  function returnDetails() {
    if (jsDblClick()) {
        parent.window.getWindowOpener().loginpassword = document.passwordForm.loginpassword.value;
        eval("parent.window.getWindowOpener()." + functionName);    
        parent.window.closeWindow();
    }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="passwordForm" onsubmit="returnDetails(); return false" action="javascript:returnDetails()" >
<script language="JavaScript">
	document.body.style.overflow = 'hidden'; //Hide the Vertical Scrollbar
</script>
<table border="0" cellpadding="3" cellspacing="2" width="100%" >
  <tr>
    <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Password</emxUtil:i18n></td>
    <td class="inputField"><input type="password" name="loginpassword" /></td>
  </tr>
</table>

<input type="hidden" name="callbackFunctionName" value="<xss:encodeForHTMLAttribute><%=sFnName%></xss:encodeForHTMLAttribute>" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLifecycleSSOAuthentication.jsp.rca 1.5 Wed Oct 22 15:47:52 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String sFnName = emxGetParameter(request, "callbackFunctionName");
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="passwordForm">
<input type="hidden" name="loginpasswd" value="externAuth" />
<input type="hidden" name="callbackFunctionName" value="<xss:encodeForHTMLAttribute><%=sFnName%></xss:encodeForHTMLAttribute>" />
</form>


<script language="JavaScript">

  var functionName = "<xss:encodeForJavaScript><%=sFnName%></xss:encodeForJavaScript>";

  parent.window.getWindowOpener().loginpassword = document.passwordForm.loginpasswd.value;
  eval("parent.window.getWindowOpener()." + functionName);
  parent.window.closeWindow();
  window.closeWindow();

</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

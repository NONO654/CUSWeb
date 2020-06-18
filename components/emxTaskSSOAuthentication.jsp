<%--  emxTaskSSOAuthentication.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTaskSSOAuthentication.jsp.rca 1.5 Wed Oct 22 16:18:49 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<script language="JavaScript">
  parent.window.getWindowOpener().passwordCallback();
  window.closeWindow();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

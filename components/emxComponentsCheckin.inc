<%-- emxComponentsCheckinTop.inc - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckin.inc.rca 1.8 Wed Oct 22 16:18:30 2008 przemek Experimental przemek $"
--%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>

<%
  //create context variable for use in pages
  matrix.db.Context context = Framework.getFrameContext(session);

  //check if user is logged in
  //create FCS Variables
    if (!Framework.isLoggedIn(request)) {
      String loginPage =  Framework.getPropertyValue("ematrix.login.page");
      context.shutdown();
%>
      <!-- //XSSOK -->
      <jsp:forward page ="<%=loginPage%>"/>
<%
      return;
    }
%>
<html>
<head>

  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
  <script language="javascript" src="../emxUIPageUtility.js"></script>
  <script type="text/javascript">
      addStyleSheet("emxUIDefault");
<%
  //Use only if Not a Dialog Page
  String isDialogPage = emxGetParameter(request,"contentPageIsDialog");
  if ("true".equalsIgnoreCase(isDialogPage)){
%>
      addStyleSheet("emxUIDialog");
<%
  } else {
%>
      addStyleSheet("emxUIForm");
<%
  }
%>
      addStyleSheet("emxUIToolbar");
      addStyleSheet("emxUIMenu");


  </script>

  <%@include file = "../emxJSValidation.inc" %>
</head>
<body>

<%!
  //
  // check for URL appended values if not found, then look in Request Headers and return the string
  //
  static public String emxGetParameter(HttpServletRequest request, String parameter)
  {
     String parameterValue = com.matrixone.apps.domain.util.Request.getParameter(request,parameter);
     return parameterValue;
  }
%>
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    i18nNow loc = new i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>

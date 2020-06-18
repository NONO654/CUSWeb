<%--  emxUITopInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.

--%><%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*, java.io.*" %>
<%@include file = "emxContentTypeInclude.inc"%><%@include file = "emxRequestWrapperMethods.inc"%>
<%
  //check if user is logged in
  //create FCS Variables
  if (!Framework.isLoggedIn(request)) {
     final String loginPage = com.matrixone.apps.domain.util.LoginUtil.setup(request,session);
    %>
    <!-- //XSSOK -->
    <jsp:forward page ="<%=loginPage%>"/>
    <%
    return;
  }
%><%
  final String acceptLanguage = request.getHeader("Accept-Language");
%><%!

  //Framwork uses 'emxUIFrameworkStringResource'
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
  static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>
<%

  matrix.db.Context context = Framework.getFrameContext(session);
%>

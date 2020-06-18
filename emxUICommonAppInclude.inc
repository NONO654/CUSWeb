<%--  emxUICommonAppInclude.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@ page import="matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.*" %>
<!DOCTYPE html><%@include file = "emxContentTypeInclude.inc"%><%@include file = "emxRequestWrapperMethods.inc"%>
<%
  //check if user is logged in
  //create FCS Variables
  if (!Framework.isLoggedIn(request)) {
    String loginPage =  Framework.getPropertyValue("ematrix.login.page");
    String reqURI = request.getRequestURI();
    if (reqURI.indexOf('/') > -1){
      reqURI = reqURI.substring(reqURI.lastIndexOf('/')+1,reqURI.length());
    }
    String pageURL = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(reqURI + "?" + request.getQueryString());
    String hostSite = emxGetParameter(request,"hostSite");
    String cancelPageURL = emxGetParameter(request,"cancelPageURL");

    String fileSite = emxGetParameter(request,"fileSite");
    if (( hostSite != null ) && ( fileSite != null ) && ( !"".equals(fileSite) )) {
    session.setAttribute("hostSite", hostSite);
    pageURL = Framework.getPagePathURL("") + "/" + pageURL;
    loginPage =  Framework.getPropertyValue("ematrix.fcslogin.page");

    request.setAttribute("pageURL",pageURL);
    request.setAttribute("cancelPageURL",cancelPageURL);
    }
    %>
     <!-- //XSSOK -->
    <jsp:forward page ="<%=loginPage%>"/>
    <%
    return;
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
    com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>
<%
  //create context variable for use in pages
  matrix.db.Context context = Framework.getFrameContext(session);

%>

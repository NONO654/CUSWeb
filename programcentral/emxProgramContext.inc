<%--
  emxProgramContext.inc

  Define the context for the Program Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
--%>

<%
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
    <jsp:forward page ="<%=loginPage%>"/>      <%-- XSSOK --%>
    <%
    return;

  }

%>


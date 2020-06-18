
<%--  emxDesignTopInclude.inc

  Top Include File for all jsp pages is Product Central Suite

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.*, java.util.*, java.io.*, java.net.URLEncoder, com.matrixone.apps.common.util.JSPUtil" errorPage="../common/eServiceError.jsp"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>

<jsp:useBean id="vaultAwarePerson" class="com.matrixone.apps.common.Person" scope="page" />
<%//Start Internationalization%>

<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="dmcplanningStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%@page import="com.matrixone.apps.domain.util.i18nNow" %>
<%!
  // Call this method to internationalize variables in java.
  // i18nStringNowUtil("key", resourceBundle, request.getHeader("Accept-Language"));
 // static public String i18nStringNowUtil(String text,String Bundle, String languageStr) {
  //  i18nNow loc = new i18nNow();
   // return (String)loc.GetString(Bundle, languageStr, text);
  //}
%>

<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
  //static public String i18nStringNow(String text, String languageStr)
  //{
   // i18nNow loc = new i18nNow();
    //return (String) loc.GetString("emxProductLineStringResource", languageStr, text);
  //}
%>

<%//End Internationalization%>




<%
  // init. Variables
  //matrix.db.Context context = null;
  String eMatrixPropertiesName = null;
  Properties eMatrixProperties = null;

  String emxTopIncDirName = Framework.getPagePathURL("");
  String useProxy = Framework.getPropertyValue("ematrix.proxy.server");
  if (useProxy != null && !useProxy.equalsIgnoreCase("null")) {
    emxTopIncDirName = useProxy + emxTopIncDirName;
  }

  // To find out whether the user has logged in or not
  if (!Framework.isLoggedIn(request)) {
    // User has not logged in

    //String emxTopIncLoginURL = emxTopIncDirName + "emxLogin.jsp";
    //String loginPage = Framework.getPropertyValue("ematrix.login.page");
    String loginPage = emxTopIncDirName + "emxLogin.jsp";

    String reqURI = request.getRequestURI();
    if (reqURI.indexOf('/') > -1){
      reqURI = reqURI.substring(reqURI.lastIndexOf('/')+1,reqURI.length());
    }
    String pageURL = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(reqURI + "?" + request.getQueryString());
    String hostSite = emxGetParameter(request,"hostSite");
    String cancelPageURL = emxGetParameter(request,"cancelPageURL");

    String fileSite = emxGetParameter(request,"fileSite");
    String sPassedSuiteDir = emxGetParameter(request,"passSuitedir");
    if ( (sPassedSuiteDir != null) && (!sPassedSuiteDir.equals("") ) ) {
      session.setAttribute("passesSuitedir",sPassedSuiteDir);
    }

    if (( hostSite != null ) && ( fileSite != null ) && ( !"".equals(fileSite) )) {
      session.setAttribute("hostSite", hostSite);
      pageURL = Framework.getPagePathURL("DMCPlanning") + "/" + pageURL;
      String FCSLoginPage =  Framework.getPropertyValue("ematrix.fcslogin.page");
      loginPage = FCSLoginPage;
      request.setAttribute("pageURL",pageURL);
      request.setAttribute("cancelPageURL",cancelPageURL);
    }

    String fcsTimeZone = emxGetParameter(request, "fcsTimeZone");
    if ( fcsTimeZone != null ) {
      session.setAttribute("timeZone", fcsTimeZone);
    }

    %>
    <%-- XSSOK--%>
    <jsp:forward page="<%=loginPage%>" />
    <%
    return;
  } else{
    // User is Logged in

    // set caching values
    response.setHeader("Cache-Control","no-store"); //HTTP 1.1
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server

      //get Directory from App. Properties Object
      //Changed for removing the application.getAttribute() call
      String suiteDir = (String)session.getAttribute("passesSuitedir");
      if(suiteDir == null || suiteDir.equals("") || suiteDir.equals("null"))
      {
        suiteDir = EnoviaResourceBundle.getProperty(context,"eServiceSuiteDMCPlanning.Directory"); //suite directory name being picked up from properties file
      } 


  }

 long startTime = System.currentTimeMillis();
%>



<%!
  //
  // check for URL appened values if not found, then look in Request Headers and return the string
  //
  static public String getParam(HttpServletRequest request, String parameter) throws MatrixException
  {
    String parameterValue = emxGetParameter(request,parameter);
    if (parameterValue == null || parameter.equalsIgnoreCase("null")) {
      parameterValue = (String)request.getAttribute(parameter);
    }
    return parameterValue;
  }

%>


<%!
  //
  // check for URL appended values if not found, then look in Request Headers and return the string
  //
  // static public String emxGetParameter(HttpServletRequest request, String parameter)
 // {
  //  String parameterValue = emxGetParameter(request,parameter);
   // return parameterValue;
 // }
%>


<%!
  //
  // check for URL appended values if not found, then look in Request Headers and return the string
  //
   //static public String[] emxGetParameterValues(HttpServletRequest request, String parameter)
  //{
   //String parameterValues[] = emxGetParameterValues(request,parameter);
   //return parameterValues;
   //}
%>
<%!
  //
  // return the list of parameter names
  //
 // static Enumeration emxGetParameterNames(HttpServletRequest req)
  //{
   // Enumeration enumParams = req.getParameterNames();
    //return (enumParams);
  //}
%>


<%!


  // Method to get property from emxProductLine.properties
  //Changed for removing the application.getAttribute() call
  public static String getProductLineProperty(ServletContext application, HttpSession session, String key, String property) throws FrameworkException, MatrixException
  {
    matrix.db.Context context = Framework.getContext(session);  
    String returnValue = null;
    try {
        String fullKey = key + "." + property;
        returnValue = EnoviaResourceBundle.getProperty(context,fullKey);
    }catch (Exception e) {
        //throw new FrameworkException(e);  
    }
    return returnValue;
  }
%>


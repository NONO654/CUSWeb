<%--  --  Supplier Central Include File
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxI18NMethods.inc"%>

<%@ page import = "matrix.db.*,
                   matrix.util.*,
                   com.matrixone.servlet.*,
                   java.util.*,
                   java.io.*,
                   java.net.*,
                   java.text.*" errorPage="emxComponentsError.jsp"%>

<%@ page import = "com.matrixone.apps.common.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>


<%!
  static String appDirectory = null;
  static String suiteDir = "";
        private static synchronized void init(HttpSession session) 
                throws matrix.util.MatrixException, FrameworkException, Exception
        {
  if (suiteDir == null || "".equals(suiteDir) || "null".equals(suiteDir) ) {
                matrix.db.Context utilContext = Framework.getFrameContext(session);
                try {
                    suiteDir = EnoviaResourceBundle.getProperty(utilContext,"eServiceSuiteComponents.Directory");
                    appDirectory = EnoviaResourceBundle.getProperty(utilContext,"eServiceSuiteComponents.Directory");
                 } finally {
                                 utilContext.shutdown();
                 }
         }
}
%>

<%
        init(session);
 final String sLanguage = request.getHeader("Accept-Language");
  String DateFrm ="";
%>
<!-- //XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= sLanguage %>' />


<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
  static public String i18nStringNow(String sText,String sLanguage)
  {
    i18nNow loc = new i18nNow();
    return (String) loc.GetString("emxComponentsStringResource", sLanguage, sText);
  }
%>

<%!
  // temp method to avoid multiple definition of getCentralProperty
  //
  @Deprecated
  public static String getAppProperty(Context context, ServletContext application, String key)
  {
    String str = null;
    try
    {
        str = EnoviaResourceBundle.getProperty(context,key);
    }catch(Exception e) { }
    return str;
  }
%>

<%--  emxSearchInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxSearchInclude.inc.rca 1.5 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $"
--%>

<%@page import="com.matrixone.servlet.Framework"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="matrix.db.Context"%>
<%@page import="java.util.Set"%>
<%@page import = "com.matrixone.apps.framework.ui.*"%>


<%
  final String acceptLanguage = request.getHeader("Accept-Language");
 %>


<%!
  private static final String FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String SUITE_PREFIX = "eServiceSuite";

  
  // Call this method to internationalize variables in java.
    /** 
     * @deprecated V6R2013.
     */
  @Deprecated
    private static String i18nStringNowUtil(String text,String Bundle, String languageStr) {
    com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }


// This method returns the value of the application property
  @Deprecated
private static String getProperty(Context context,String strKey){
 String strRetVal = "";
 try{
 	strRetVal = FrameworkProperties.getProperty(context,strKey);
    }catch(FrameworkException e){
    	}
  return strRetVal;
}


  @Deprecated
private static String getResourceBundle(Context context,ServletContext application, String strSuiteKey) {
  String strAppName = SUITE_PREFIX + strSuiteKey;
  String strResNameKey = strAppName + ".StringResourceFileId";
  return getProperty(context,strResNameKey);
}


%>

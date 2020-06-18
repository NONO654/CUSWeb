<%--  emxQuoteCommonUtilAppInclude.jsp  --  Supplier Central Include File

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCompCommonUtilAppInclude.inc.rca 1.8 Wed Oct 22 15:47:57 2008 przemek Experimental przemek $
--%>
<%@ page import="matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.taglib.*" errorPage="eServiceError.jsp" %>

<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxI18NMethods.inc"%>

<%!
  static final String appDirectory = "common";
%>

<%

  String sLanguage = request.getHeader("Accept-Language");
  String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();
%>
<!--//XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<%= sLanguage %>' />

<%!
  // Call this method to internationalize variables in java.
  @Deprecated
  static public String i18nStringNow(String text, String languageStr) throws MatrixException
  {
    i18nNow loc = new i18nNow();

    String returnString = text;
    try{
      String I18NreturnString = EnoviaResourceBundle.getFrameworkStringResourceProperty(null, text, new Locale(languageStr));          
      if ((!"".equals(I18NreturnString)) && (I18NreturnString != null)){
        returnString = I18NreturnString;
      }
    }catch(Exception e){
      // String must not have been in Property File or another Exception
      // Return the string id.
    }

    return returnString;

  }
%>



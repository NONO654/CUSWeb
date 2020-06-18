<%--  emxI18NMethods.jsp  -

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxI18NMethods.inc.rca 1.23 Wed Oct 22 16:10:02 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.apps.domain.util.*"  %>
<%!
  //
  // Get the I18N Translated String for the given Type Name
  //
    /** 
     * @deprecated V6R2013, use methods i18nNow.getTypeI18NString instead.
     */
  @Deprecated
  static public String getTypeI18NString(String typeString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(typeString ,"",languageStr,"Type");
  }

  //
  // Get the I18N Translated String for the given State Name
  //
    /** 
     * @deprecated V6R2013, use methods i18nNow.getStateI18NString instead.
     */
  @Deprecated
  static public String getStateI18NString(String policyString, String stateString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(stateString ,policyString,languageStr,"State");
  }

  //
  // Get the I18N Translated String for the given Attribute
  //
    /** 
     * @deprecated V6R2013, use methods i18nNow.getAttributeI18NString instead.
     */
  @Deprecated
  static public String getAttributeI18NString(String attrString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(attrString,"",languageStr,"Attribute");
  }

  //
  // Get the I18N Translated String for the given Basic Value
  //
    /** 
     * @deprecated V6R2013, use methods i18nNow.getBasicI18NString instead.
     */
  @Deprecated
  static public String getBasicI18NString(String basicString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(basicString,"",languageStr,"Basic");
  }

  //
  // Get the I18N Translated String for the given Attribute Range Value
  //
    /** 
     * @deprecated V6R2013, use methods i18nNow.getRangeI18NString instead.
     */
  @Deprecated
  static public String getRangeI18NString(String attrString, String rangeString, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(rangeString,attrString ,languageStr,"Range");
  }

  //
  // Get the I18N Translated String for the given Admin Type and Admin Name
  //
    /** 
     * @deprecated V6R2013, use methods i18nNow.getAdminI18NString instead.
     */
  @Deprecated
  static public String getAdminI18NString(String adminType, String adminName, String languageStr) throws MatrixException
  {
    return i18nNow.getMXI18NString(adminName,"",languageStr, adminType);
  }

  // Call this method to internationalize variables in java.
  // getI18NString(resourceBundle, "key", request.getHeader("Accept-Language"));
    /** 
     * @deprecated V6R2013, use methods i18nNow.getI18nString instead.
     */
  @Deprecated
  static public String getI18NString(String Bundle, String text, String languageStr) {
    i18nNow loc = new i18nNow();
    return (String)loc.GetString(Bundle, languageStr, text);
  }
%>

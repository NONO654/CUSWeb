<%--  emxMEPCommonInclude.inc

  Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPCommonInclude.inc 1.2.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
 --%>
<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.net.URLEncoder,
                   java.util.*,
                   java.text.*" errorPage="../common/emxNavigatorErrorPage.jsp"%>

<%@ page import = "com.matrixone.apps.manufacturerequivalentpart.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@ page import =  "com.matrixone.apps.common.*"
 %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@include file = "../emxTagLibInclude.inc"%>


<%
  final String appDirectory = (String)FrameworkProperties.getProperty(context, "eServiceSuiteManufacturerEquivalentPart.Directory");
  String sLanguage = request.getHeader("Accept-Language");
  String bundle = "emxManufacturerEquivalentPartStringResource";
  String suiteKey = emxGetParameter(request,"suiteKey");
%>
<%--XSSOK--%>
<emxUtil:localize id="i18nId" bundle="<%=bundle%>" locale='<%= sLanguage %>' />

<%!
  // Call this method to internationalize variables in java.
  // i18nStringNow("stringid", request.getHeader("Accept-Language"));
  static public String i18nStringNow(final String sText,final String sLanguage)throws Exception
  {
     return (String)com.matrixone.apps.domain.util.ContextUtil.runInAnonymousContext(
        new com.matrixone.apps.domain.util.ContextUtil.Callable() {
        	public Object call(Context ctx) throws MatrixException {
                return EnoviaResourceBundle.getProperty(ctx, "emxManufacturerEquivalentPartStringResource",ctx.getLocale(), sText);
                }});
  }
%>

<%!
  // method to get the objectid  where the emxTableRowId contains both relationship id and objectId
  // Whenever the object selects contains RELID and OBJECTID the check box value in the emxTable will be RELID|OBJECTID
  // In case of indented table it would be RELID|CHILDOBJECTID|PARENTOBJECT
  public static String[] getObjectIdFromemxTableRowId(String[] emxTableRowId)
  {
      String[] result = null;
        result = new String[emxTableRowId.length];
        for(int index=0;index<emxTableRowId.length;index++){
             result[index] = (String)((StringList) FrameworkUtil.split(emxTableRowId[index],"|")).get(1);
         }
        return result;
  }

%>

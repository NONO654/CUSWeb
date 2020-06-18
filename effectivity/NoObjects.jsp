<%--  emxBlank.jsp   - Component Frame for "Build ECO"

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxBlank.jsp.rca 1.7 Wed Oct 22 15:48:43 2008 przemek Experimental przemek $
--%>
<%
String acceptLanguage = request.getHeader("Accept-Language");
//Code to be inserted for the bundle to be read from prop file.
String bundle = "EffectivityStringResource";
%>
<%@include file = "../emxI18NMethods.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<html>
<link rel="stylesheet" type="text/css" media="screen" href="../common/styles/emxUIStructureBrowser.css" />
<link rel="stylesheet" type="text/css" media="screen" href="../effectivity/styles/emxUIExpressionBuilder.css" />
<link rel="stylesheet" type="text/css" media="screen" href="../effectivity/styles/emxUIRuleLayerDialog.css" />
<body>
<%-- XSSOK --%>
<framework:localize id="i18nId" bundle="EffectivityStringResource" locale="<%=acceptLanguage%>"/>
<div id="mx_divBody">
<table width="100%">
        <tr>
            <td class="mx_group-header" colspan="1" width="100%" align="center">
               <emxUtil:i18n localize="i18nId">Effectivity.Root.Missing</emxUtil:i18n>
    </td>
    </tr>
    </table>
    </div>
</body>
</html>

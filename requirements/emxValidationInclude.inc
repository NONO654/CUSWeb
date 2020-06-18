<%-- emxValidationInclude.inc

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../emxJSValidation.inc" %>
<script language="javascript" type="text/javaScript">
<%@page import="com.matrixone.apps.domain.util.*"%>

// The following variable was changed for bug no.281645
var checkBadChars = "BadChars";

//The following lines  enable the use of strings checkIllegaChars and checkBadChars as the BadcharTypes for some pages.This will allow obsolete files to run properly
var checkIllegalChars="BadChars";
var checkRestrictedChars = "BadChars";
var MAX_LENGTH =<%=EnoviaResourceBundle.getProperty(context, "emxComponents.MAX_FIELD_LENGTH")%>;
var ALERT_EMPTYFIELD ="<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkEmptyString")%>";
var ALERT_CHECK_LENGTH = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkEmptyString")%>";
var ALERT_INVALID_CHARS = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidChars")%>";
//Begin of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
var ALERT_INVALID_PARENTHESIS = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.InvalidParenthesis")%>";
//End of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
var ALERT_CHECK_NUMERIC = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkNumeric")%>";
var ALERT_CHECK_POSITIVE_NUMERIC ="<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkPositiveNumeric")%>";
var ALERT_CHECK_INTEGER = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.checkInteger")%>";
emxUIConstants.STR_DEC_SYM="<%=Character.toString(PersonUtil.getDecimalSymbol(context))%>";<%--XSSOK--%>
</script>
<script language="javascript" src="emxValidationInclude.js"></script>

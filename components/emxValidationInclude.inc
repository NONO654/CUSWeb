<%-- emxValidationInclude.inc

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../emxJSValidation.inc" %>
<script language="javascript" type="text/javaScript" >
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>

// The following variable was changed for bug no.281645

//The following lines  enable the use of strings checkIllegaChars and checkBadChars as the BadcharTypes for some pages.This will allow obsolete files to run properly
var checkBadChars = "BadChars";
var checkIllegalChars="BadChars";
var checkRestrictedChars = "BadChars";

var MAX_LENGTH =<%=FrameworkProperties.getProperty(context,"emxComponents.MAX_FIELD_LENGTH")%>;
var ALERT_EMPTYFIELD ="<%=i18nNow.getI18nString("emxComponents.Alert.EmptyFieldAlert",bundle,acceptLanguage)%>";
var ALERT_CHECK_LENGTH ="<%=i18nNow.getI18nString("emxComponents.Alert.checkLength",bundle,acceptLanguage)%>";
var ALERT_INVALID_CHARS ="<%=i18nNow.getI18nString("emxComponents.Alert.InvalidChars",bundle,acceptLanguage)%>";
var ALERT_CHECK_NUMERIC ="<%=i18nNow.getI18nString("emxComponents.Alert.checkNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_POSITIVE_NUMERIC ="<%=i18nNow.getI18nString("emxComponents.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
var MAX_INTEGER_VALUE=32767;
var ALERT_CHECK_INTEGER ="<%=i18nNow.getI18nString("emxComponents.Alert.checkInteger",bundle,acceptLanguage)%>";</script>
<script language="javascript" src="emxValidationInclude.js"></script>

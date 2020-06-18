<%-- ValidationInclude.inc

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../emxJSValidation.inc" %>
<script language="javascript" type="text/javaScript">
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
var checkBadChars = "BadChars";

//The following lines  enable the use of strings checkIllegaChars and checkBadChars as the BadcharTypes for some pages.This will allow obsolete files to run properly
var checkIllegalChars="BadChars";
var checkRestrictedChars = "BadChars";
var MAX_LENGTH =<%=EnoviaResourceBundle.getProperty(context,"emxComponents.MAX_FIELD_LENGTH")%>;
var ALERT_EMPTYFIELD ="<%=i18nStringNowUtil("DMCPlanning.Alert.checkEmptyString",bundle,acceptLanguage)%>";
var ALERT_CHECK_LENGTH = "<%=i18nStringNowUtil("DMCPlanning.Alert.checkLength",bundle,acceptLanguage)%>";
var ALERT_INVALID_CHARS = "<%=i18nStringNowUtil("DMCPlanning.Alert.InvalidChars",bundle,acceptLanguage)%>";
var ALERT_INVALID_PARENTHESIS = "<%=i18nStringNowUtil("DMCPlanning.Alert.InvalidParenthesis",bundle,acceptLanguage)%>";
var ALERT_CHECK_NUMERIC = "<%=i18nStringNowUtil("DMCPlanning.Alert.checkNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_POSITIVE_NUMERIC ="<%=i18nStringNowUtil("DMCPlanning.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_INTEGER = "<%=i18nStringNowUtil("DMCPlanning.Alert.checkInteger",bundle,acceptLanguage)%>";
var ALERT_CHECK_MARKETING_NAME_SPECIAL_CHAR = 
        "<%=i18nStringNowUtil("DMCPlanning.Error.CreateFeature.NoSpecialCharacterAsMarketingName",bundle,acceptLanguage)%>";
// Added for bug no. IR-052159V6R2011x
var BAD_CHAR_MARKETING_NAME ="<%=EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars")%>";
</script>
<script language="javascript" src="ValidationInclude.js"></script>

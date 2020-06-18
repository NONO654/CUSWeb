<%-- emxValidationInclude.inc

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../emxJSValidation.inc" %>
<script language="javascript" type="text/javaScript">
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>

// The following variable was changed for bug no.281645
var checkBadChars = "BadChars";

//The following lines  enable the use of strings checkIllegaChars and checkBadChars as the BadcharTypes for some pages.This will allow obsolete files to run properly
var checkIllegalChars="BadChars";
var checkRestrictedChars = "BadChars";
var MAX_LENGTH =<%=FrameworkProperties.getProperty("emxComponents.MAX_FIELD_LENGTH")%>;
var ALERT_EMPTYFIELD ="<%=i18nStringNowUtil("emxProduct.Alert.checkEmptyString",bundle,acceptLanguage)%>";
var ALERT_CHECK_LENGTH = "<%=i18nStringNowUtil("emxProduct.Alert.checkLength",bundle,acceptLanguage)%>";
var ALERT_INVALID_CHARS = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
//Begin of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
var ALERT_INVALID_PARENTHESIS = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidParenthesis",bundle,acceptLanguage)%>";
//End of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
var ALERT_CHECK_NUMERIC = "<%=i18nStringNowUtil("emxProduct.Alert.checkNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_POSITIVE_NUMERIC ="<%=i18nStringNowUtil("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_INTEGER = "<%=i18nStringNowUtil("emxProduct.Alert.checkInteger",bundle,acceptLanguage)%>";
var ALERT_CHECK_MODELPREFIX_LENGTH ="<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixTooLong",bundle,acceptLanguage)%>";
var ALERT_CHECK_MODELPREFIX_NOT_ALPHANUMERIC = "<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotAlphaNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_MODELPREFIX_NOT_ALLCAPS = "<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixCapsOnly",bundle,acceptLanguage)%>";
var ALERT_CHECK_MODELPREFIX_NOT_VALID = "<%=i18nStringNowUtil("emxProductLine.Model.ModelPrefixNotValid",bundle,acceptLanguage)%>";//Variable added for Bug No: 359806
// Added for bug no. IR-052159V6R2011x
var BAD_CHAR_MARKETING_NAME ="<%=FrameworkProperties.getProperty("emxFramework.Javascript.NameBadChars")%>";
</script>
<script language="javascript" src="emxValidationInclude.js"></script>

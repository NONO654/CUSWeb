<%--  emxFormConstantsJavascriptInclude.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormConstantsJavascriptInclude.jsp.rca 1.1.5.4 Wed Oct 22 15:48:54 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<%
out.clear();
response.setContentType("text/javascript");

Locale loc = request.getLocale();

//form component strings
String VALIDATION_METHOD_UNDEFINED = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.ValidationMethodNotDefined",  loc);
String SAVE_CHANGES = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.SaveChanges",  loc);
String MUST_ENTER_VALID_VALUE = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.MustEnterAValidValueFor",  loc);
String MUST_ENTER_VALID_NUMERIC_VALUE = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.MustEnterAValidNumericValueFor",  loc);
String MUST_ENTER_VALID_INTERGER_VALUE = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.MustEnterAValidIntegerValueFor",  loc);
String BAD_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.BadChars",  loc);
String BAD_NAME_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.BadNameChars",  loc);
String RESTRICTED_BAD_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.RestrictedBadChars",  loc);
String CUSTOM_VALIDATION_FAILED = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.CustomValidationFailed",  loc);
String NAME_FIELD_EMPTY = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.NameFieldEmpty",  loc);
String NAME_MORETHAN_127_CHARACTERS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.NameMoreThan127Characters",  loc);
String DECIMAL_SYMBOL_IS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.CurrentDecimalSymbol",  loc);
String INVALID_INPUT_MSG = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.ErrorMsg.InvalidInputMsg", loc);
String ALERT_INVALID_INPUT = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.Common.AlertInvalidInput", loc);
String REMOVE_INVALID_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.Alert.RemoveInvalidChars",loc );
String FIELD = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.FormComponent.Alert.Field", loc);

%>

  //XSSOK
  var MUST_ENTER_VALID_NUMERIC_VALUE = "<%=MUST_ENTER_VALID_NUMERIC_VALUE%>";
  //XSSOK 
  var VALIDATION_METHOD_UNDEFINED = "<%=VALIDATION_METHOD_UNDEFINED%>";
  //XSSOK 
  var SAVE_CHANGES = "<%=SAVE_CHANGES%>";
  //XSSOK 
  var MUST_ENTER_VALID_VALUE = "<%=MUST_ENTER_VALID_VALUE%>";
  //XSSOK 
  var MUST_ENTER_VALID_INTERGER_VALUE = "<%=MUST_ENTER_VALID_INTERGER_VALUE%>";
  //XSSOK 
  var BAD_CHARS = "<%=BAD_CHARS%>";
  //XSSOK 
  var BAD_NAME_CHARS = "<%=BAD_NAME_CHARS%>";
  //XSSOK 
  var RESTRICTED_BAD_CHARS = "<%=RESTRICTED_BAD_CHARS%>";
  //XSSOK 
  var CUSTOM_VALIDATION_FAILED = "<%=CUSTOM_VALIDATION_FAILED%>";
  //XSSOK 
  var NAME_FIELD_EMPTY = "<%=NAME_FIELD_EMPTY%>";
  //XSSOK 
  var NAME_MORETHAN_127_CHARACTERS = "<%=NAME_MORETHAN_127_CHARACTERS%>";
  //XSSOK 
  var DECIMAL_SYMBOL_IS = "<%=DECIMAL_SYMBOL_IS%>";
  //XSSOK 
  var INVALID_INPUT_MSG = "<%=INVALID_INPUT_MSG%>";
  //XSSOK 
  var ALERT_INVALID_INPUT = "<%=ALERT_INVALID_INPUT%>";
  //XSSOK 
  var REMOVE_INVALID_CHARS = "<%=REMOVE_INVALID_CHARS%>";
  //XSSOK 
  var FIELD = "<%=FIELD%>";
  
  

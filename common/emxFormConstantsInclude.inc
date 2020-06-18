<%--  emxFormConstantsInclude.jsp - File for declaring all constants used by form pages

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormConstantsInclude.inc.rca 1.7 Wed Oct 22 15:48:06 2008 przemek Experimental przemek $
--%>

<%
String MSG_INVALID_FORM_NAME = "The form name is invalid or do not exist";
String MSG_INVALID_OBJECTID = "Business Object ID not available...";
String MSG_CLEANUP_FORM_DATA = "Unable to cleanup the form data...";
String MSG_FETCH_FORM_DATA = "Unable to Fetch the form data...";


String SETTING_REQUIRED_FIELD = "Required";
String SETTING_RANGE_HELPER_URL = "rangeHelperURL";
String SETTING_RANGE_HELPER_IMAGE = "rangeHelperImage";
String SETTING_REGISTERED_SUITE = "Registered Suite";
String SETTING_FIELD_TYPE = "Field Type";
String SETTING_SHOW_TYPE_ICON = "Show Type Icon";
String SETTING_ALT_OID_EXPR = "Alternate OID Expression";
String SETTING_ALT_TYPE_EXPR = "Alternate Type Expression";
String SETTING_SHOW_ALT_ICON = "Show Alternate Icon";

String LABEL_PREFIX = "label_";
String TEXTBOX_PREFIX = "textbox_";
String COMBOBOX_PREFIX = "combobox_";
String LISTBOX_PREFIX = "listbox_";
String RADIOBUTTON_PREFIX = "radiobutton_";

String INPUT_TYPE_TEXTBOX = "textbox";
String INPUT_TYPE_TEXTAREA = "textarea";
String INPUT_TYPE_COMBOBOX = "combobox";
String INPUT_TYPE_LISTBOX = "listbox";
String INPUT_TYPE_RADIOBUTTON = "radiobutton";
String INPUT_TYPE_POPUP = "popup";

String FIELD_TYPE_NAME = "name";
String FIELD_TYPE_DESCRIPTION = "description";
String FIELD_TYPE_REVISION = "revision";
String FIELD_TYPE_OWNER = "owner";
String FIELD_TYPE_VAULT = "vault";
String FIELD_TYPE_TYPE = "type";
String FIELD_TYPE_BASIC = "basic";
String FIELD_TYPE_ATTRIBUTE = "attribute";

String BOOLEAN_TRUE = "true";

//form component strings
String VALIDATION_METHOD_UNDEFINED = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.ValidationMethodNotDefined", new Locale(request.getHeader("Accept-Language")));
String SAVE_CHANGES = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.SaveChanges", new Locale(request.getHeader("Accept-Language")));
String MUST_ENTER_VALID_VALUE = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.MustEnterAValidValueFor", new Locale(request.getHeader("Accept-Language")));
String MUST_ENTER_VALID_NUMERIC_VALUE = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.MustEnterAValidNumericValueFor", new Locale(request.getHeader("Accept-Language")));
String MUST_ENTER_VALID_INTERGER_VALUE = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.MustEnterAValidIntegerValueFor", new Locale(request.getHeader("Accept-Language")));
String BAD_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.BadChars", new Locale(request.getHeader("Accept-Language")));
String BAD_NAME_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.BadNameChars", new Locale(request.getHeader("Accept-Language")));
String RESTRICTED_BAD_CHARS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.RestrictedBadChars", new Locale(request.getHeader("Accept-Language")));
String CUSTOM_VALIDATION_FAILED = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.CustomValidationFailed", new Locale(request.getHeader("Accept-Language")));
String NAME_FIELD_EMPTY = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.NameFieldEmpty", new Locale(request.getHeader("Accept-Language")));
String NAME_MORETHAN_127_CHARACTERS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.NameMoreThan127Characters", new Locale(request.getHeader("Accept-Language")));
String DECIMAL_SYMBOL_IS = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.CurrentDecimalSymbol", new Locale(request.getHeader("Accept-Language")));
%>

<script language="javascript">
 
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
  
</script>



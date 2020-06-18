<%-- EffectivityConstantsInclude.inc

   Copyright (c) 1999-2015 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../emxI18NMethods.inc"%>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%@page import = "com.matrixone.apps.effectivity.EffectivitySettingsManager"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>
 
<%
String infinitySymbolStr = EffectivityFramework.INFINITY_SYMBOL_STORAGE;
String parentSeparatorStr = EffectivityFramework.PARENT_SEPARATOR;
String rangeSeparatorStorageStr = EffectivityFramework.RANGE_SEPARATOR_STORAGE;
String valueSeparatorStorageStr = EffectivityFramework.VALUE_SEPARATOR_STORAGE;
String rangeSeparatorStr = EffectivityFramework.RANGE_SEPARATOR_DIALOG;
String valueSeparatorStr = EffectivityFramework.VALUE_SEPARATOR_DIALOG;
String seriesCloseBracket = EffectivityFramework.SERIES_CLOSE_BRACKET;
EffectivityFramework ef = new EffectivityFramework();
String infinitySymbolDisp = ef.getInfinitySymbolDisplay(context);
String infinitySymbolKeyIn = ef.getInfinitySymbolKeyIn(context);

String bundle = "EffectivityStringResource";
double clientTZOffset = Double.parseDouble((String)session.getValue("timeZone"));
String acceptLanguage = request.getHeader("Accept-Language");
String strGlobalText = i18nStringNowUtil("Effectivity.Label.Global", bundle,acceptLanguage);
String strContextText = i18nStringNowUtil("Effectivity.Label.Context", bundle,acceptLanguage);
%>

<script language="javascript" type="text/javaScript">

var MX_IFRAME = "mx_iframe";
var MX_PANEL_TITLE = "mx_panelTitle";
var CLASS_PANEL_OPEN = "source-panel open";
var CLASS_PANEL_CLOSED = "source-panel closed";
var MX_DIV = "mx_div";
var PANEL_BODY = "PanelBody";

//mappings of settings
var infinitySymbol = "<%=XSSUtil.encodeForJavaScript(context, EffectivityFramework.INFINITY_SYMBOL_STORAGE)%>";
var infinitySymbolDisp = "<%=XSSUtil.encodeForJavaScript(context, infinitySymbolDisp)%>";
var infinitySymbolKeyIn = "<%=XSSUtil.encodeForJavaScript(context, infinitySymbolKeyIn)%>";
var rangeSeparator = "<%=XSSUtil.encodeForJavaScript(context, EffectivityFramework.RANGE_SEPARATOR_DIALOG)%>";
var valueSeparator = "<%=XSSUtil.encodeForJavaScript(context, EffectivityFramework.VALUE_SEPARATOR_DIALOG)%>";
var parentSeparator = "<%=XSSUtil.encodeForJavaScript(context, EffectivityFramework.PARENT_SEPARATOR)%>";
var rangeSeparatorStorage = "<%=XSSUtil.encodeForJavaScript(context, EffectivityFramework.VALUE_SEPARATOR_STORAGE)%>";
var valueSeparatorStorage = "<%=XSSUtil.encodeForJavaScript(context, EffectivityFramework.VALUE_SEPARATOR_DIALOG)%>";
var SETTING_FORMAT = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_FORMAT)%>";
var SETTING_MODE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_MODE)%>";
var SETTING_LABEL = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_LABEL)%>";
var ALLOW_RANGE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_ALLOWRANGE)%>";
var SETTING_CATEGORYTYPE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_CATEGORYTYPE)%>";
var SETTING_SEARCHTYPE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_SEARCHTYPE)%>";            
var SETTING_EXPANDPROGRAM = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_EXPANDPROGRAM)%>";
var SETTING_TABLE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_TABLE)%>";
var SETTING_SELECTION = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_SELECTION)%>";
var SETTING_RELATIONSHIP = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_RELATIONSHIP)%>";
var SETTING_KEYWORD = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_KEYWORD)%>";
var SETTING_ALLOWSINGLEDATE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_ALLOWSINGLEDATE)%>";
var SHOW_OR = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_SHOWOR)%>";
var SHOW_AND = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_SHOWAND)%>";
var SHOW_INF = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CMD_SETTING_SHOWINF)%>";
var DATE_CATEGORY = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CATEGORY_TYPE_DATE)%>";
var CONTEXTDATE_CATEGORY = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CATEGORY_TYPE_CONTEXTDATE)%>";
var MILESTONE_CATEGORY = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CATEGORY_TYPE_MILESTONE)%>";
var SEQUENCE_CATEGORY = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CATEGORY_TYPE_SEQUENCE)%>";
var RELATIONAL_CATEGORY = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager.CATEGORY_TYPE_RELATIONAL)%>";
var RELATIONAL_CRITERIA = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager._SETTING_RELATIONAL_CRITERIA)%>";
var CONFIGURATION_CONTEXT_MODE = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager._SETTING_CONFIGURATION_CONTEXT_MODE)%>";
var SETTING_TOOLBAR = "<%=XSSUtil.encodeForJavaScript(context, EffectivitySettingsManager._SETTING_TOOLBAR)%>";
var DATE_TEXT = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.EffectivityType.Date",bundle, acceptLanguage))%>";
var DATE_START_TEXT = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.Date.Start",bundle, acceptLanguage))%>";
var DATE_END_TEXT = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.Date.End",bundle, acceptLanguage))%>";
var CLOSED = "Closed";
var PANEL_TITLE = "mx_panelTitle";
var GLOBAL_TEXT = "<%=XSSUtil.encodeForJavaScript(context, strGlobalText)%>"; 
var CONTEXT_TEXT = "<%=XSSUtil.encodeForJavaScript(context, strContextText)%>";
var GLOBAL_DATE_CONTEXT = "Global";//for global Date
var CLICK_TO_CLOSE = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.ClickToClose",bundle, acceptLanguage))%>";
var CLICK_TO_OPEN = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.ClickToOpen",bundle, acceptLanguage))%>";
var FROMEFFTOOLBAR="fromEffToolbar"; 
var CLICK_TO_ADD_OPTION="<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.EmptyOption",bundle, acceptLanguage))%>";
var  EffMilestone="<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.EffectivityType.Milestone",bundle, acceptLanguage))%>";
var  EffFeatureOption="<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.EffectivityType.FeatureOption",bundle, acceptLanguage))%>";
var  CatOperators="<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Category.Operators",bundle, acceptLanguage))%>";
var CLICK_TO_EXPAND = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.ClickToExpand",bundle, acceptLanguage))%>";
var CLICK_TO_COLLAPSE = "<%=XSSUtil.encodeForJavaScript(context,i18nStringNowUtil("Effectivity.Dialog.ClickToCollapse",bundle, acceptLanguage))%>";

//Effectivity Types that are not applicable to Global context
//check categoryType instead
var DATE_EFFECTIVITY_TYPE = "Date";
var FEATURE_OPTION_EFF_TYPE = "FeatureOption";
var CONTEXTDATE_EFFECTIVITY_TYPE = "ContextDate";
var UNIT_EFFECTIVITY_TYPE = "Unit";
var PRODUCTREVISION_EFFECTIVITY_TYPE = "ProductRevision";
var MANUFACTURINGPLAN_EFFECTIVITY_TYPE = "ManufacturingPlans";
var MILESTONE_EFFECTIVITY_TYPE = "Milestone";

var CLEAR_ALL_EXPRESSION = "<%=i18nStringNowUtil("Effectivity.Confirm.ClearAll", bundle,acceptLanguage)%>";

function giveAlert(alertFlag,keyIn)
{
    if(alertFlag == "INVALID_LE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.LeftExpression.Invalid", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "RANGE_VALIDATION")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.ValidateRangeAlert", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "USER_SELECTION")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.UserSelectionRequirement", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "INVALID_DATE_RANGE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.InvalidDateRange", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "INVALID_UNIT_RANGE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.InvalidUnitRange", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "DATE_FIELD_DELETION_RESTRICT")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.RowDeletionNotPermitted", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "REQUEST_DATE_SELECTION")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.RequestDateSelection", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "END_DATE_BEFORE_START_DATE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.EndBeforeStart", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "END_DATE_SAME_START_DATE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.EndSameStart", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "INVALID_INFINITY")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.Infinity", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "ELEMENT_SELECTION")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Request.Selection", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "SEQUENCE_VALIDATION_FAILED")
    {
        alert("<%=i18nStringNowUtil("Effectivity.Validation.Failure", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "KEYIN_INFINITY_AS_SEQUENCE_VALUE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.KeyinValidation.InfinitySymbolSequence",bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "KEYIN_NOT_VALID_INTEGER_KEYWORD")
    {
        var temp = "<%=i18nStringNowUtil("Effectivity.KeyinValidation.InvalidIntKeyword",bundle,acceptLanguage)%>";
        temp += keyIn;
        alert(temp);
    }
    else if(alertFlag == "KEYIN_NO_GREATER_THAN_ZERO")
    {
        alert("<%=i18nStringNowUtil("Effectivity.KeyinValidation.NoGreaterThanZero",bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "START_RANGE_GREATER_END_RANGE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.KeyinValidation.StartLessThanEnd",bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "KEYIN_EMPTY_VALUE_ENETERED")
    {
        alert("<%=i18nStringNowUtil("Effectivity.KeyinValidation.EmptyValue",bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "USER_SELECTION_LIST")
    {
        alert("<%=i18nStringNowUtil("Effectivity.List.UserSelectionRequirement", bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "KEYIN_INFINITY_AS_START_SEQUENCE_VALUE")
    {
        alert("<%=i18nStringNowUtil("Effectivity.KeyinValidation.InfinitySymbolSequenceStart",bundle,acceptLanguage)%>");
    } 
    else if(alertFlag == "MUST_SELECT_A_CONTEXT"){
        alert("<%=i18nStringNowUtil("Effectivity.Error.SelectAContext",bundle,acceptLanguage)%>");
    }
    else if(alertFlag == "REVIEW_INVALID_EXPRESSION")
    {
        var temp = "<%=i18nStringNowUtil("Effectivity.Error.InvalidContextExpression",bundle,acceptLanguage)%>";
        temp += " " + keyIn;
        alert(temp);
    } else if (alertFlag == "VALID_EXPRESSION"){
        alert("<%=i18nStringNowUtil("Effectivity.Expression.Valid", bundle,acceptLanguage)%> ");
    } else if (alertFlag == "INVALID_EXPRESSION"){
        alert("<%=i18nStringNowUtil("Effectivity.Expression.Invalid", bundle,acceptLanguage)%> ");
    } else if (alertFlag == "CHANGE_VALUE"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.ChangeValue", bundle,acceptLanguage)%> ");
    } else if (alertFlag == "NOT_APPLICABLE_TO_SELECTED_CONTEXT"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.Panel.NotApplicable", bundle,acceptLanguage)%> ");
    } else if(alertFlag == "NO_DESIGN_VARIANT_EXISTS"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.NoDesignVariantExists", bundle,acceptLanguage)%> ");
    } else if(alertFlag == "SOME_DESIGN_VARIANT_EXISTS"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.SomeDesignVariantExists", bundle,acceptLanguage)%> ");
    } else if(alertFlag == "SEARCH_NOT_APPLICABLE"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.SearchIsNotApplicable", bundle,acceptLanguage)%> ");        
    } else if(alertFlag == "INVALID_MILESTONE_RANGE"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.Error.InvalidRange", bundle,acceptLanguage)%> ");
    } else if(alertFlag == "INVALID_INPUT_VALUE"){
        alert("<%=i18nStringNowUtil("Effectivity.Dialog.Error.InvalidSelection", bundle,acceptLanguage)%> ");
    }
}
   
</script>



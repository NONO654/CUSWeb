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
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
// The following variable was changed for bug no.281645
var checkBadChars = "BadChars";

//The following lines  enable the use of strings checkIllegaChars and checkBadChars as the BadcharTypes for some pages.This will allow obsolete files to run properly
var checkIllegalChars="BadChars";
var checkRestrictedChars = "BadChars";
var MAX_LENGTH =<%=EnoviaResourceBundle.getProperty(context,"emxComponents.MAX_FIELD_LENGTH")%>;
var ALERT_EMPTYFIELD ="<%=i18nNow.getI18nString("emxProduct.Alert.checkEmptyString",bundle,acceptLanguage)%>";
var ALERT_CHECK_LENGTH = "<%=i18nNow.getI18nString("emxProduct.Alert.checkLength",bundle,acceptLanguage)%>";
var ALERT_INVALID_CHARS = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidChars",bundle,acceptLanguage)%>";
//Begin of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
var ALERT_INVALID_PARENTHESIS = "<%=i18nNow.getI18nString("emxProduct.Alert.InvalidParenthesis",bundle,acceptLanguage)%>";
//End of add by Enovia MatrixOne, for bug 302675 dated 10 May 2005
var ALERT_CHECK_NUMERIC = "<%=i18nNow.getI18nString("emxProduct.Alert.checkNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_POSITIVE_NUMERIC ="<%=i18nNow.getI18nString("emxProduct.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
var ALERT_CHECK_INTEGER = "<%=i18nNow.getI18nString("emxProduct.Alert.checkInteger",bundle,acceptLanguage)%>";
// Added for Special character - Bug No. 361962 
var ALERT_CHECK_MARKETING_NAME_SPECIAL_CHAR = 
        "<%=i18nNow.getI18nString("emxConfiguration.Error.CreateFeature.NoSpecialCharacterAsMarketingName",bundle,acceptLanguage)%>";
// Added for bug no. IR-052159V6R2011x
var BAD_CHAR_MARKETING_NAME ="<%=EnoviaResourceBundle.getProperty(context,"emxFramework.Javascript.NameBadChars")%>";
   var LEFT_EXP  = "<%=i18nNow.getI18nString("emxFramework.Attribute.LeftExpression", bundle,acceptLanguage)%> ";
   var RIGHT_EXP  = "<%=i18nNow.getI18nString("emxFramework.Attribute.RightExpression", bundle,acceptLanguage)%> ";
   var DESCRIPTION  = "<%=i18nNow.getI18nString("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE  = "<%=i18nNow.getI18nString("emxFramework.Attribute.ErrorMessage", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE_FOR_SIMILAR_EXP  = "<%=i18nNow.getI18nString("emxProduct.Alert.SimilarLeftRightExpressions", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE_FOR_LEFT_EXP  = "<%=i18nNow.getI18nString("emxProduct.Alert.EntryForLeftExpressions", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE_FOR_RIGHT_EXP  = "<%=i18nNow.getI18nString("emxProduct.Alert.EntryForRightExpressions", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE_FOR_NAME_ENTRY  = "<%=i18nNow.getI18nString("emxProduct.Alert.EntryForName", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE_FOR_SELECTION  = "<%=i18nNow.getI18nString("emxProduct.Alert.NothingSelected", bundle,acceptLanguage)%>";
   
   var ERROR_MESSAGE_FOR_ROOT_NODE_SELECTION  = "<%=i18nNow.getI18nString("emxProduct.Alert.CannotPerform", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_ROOT_NODE_SELECTION_PCR  = "<%=i18nNow.getI18nString("emxProduct.Alert.ModelNotToBeSelected", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_FEATURE_SELECTION  = "<%=i18nNow.getI18nString("emxProduct.Alert.SelectFeature", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_OPERATOR_SELECTION  = "<%=i18nNow.getI18nString("emxProduct.Alert.ContainOperator", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_INVALID_INSERT_FEATURE  = "<%=i18nNow.getI18nString("emxProduct.MarketingChoices.InvalidInsertForTopLevelFeature", bundle,acceptLanguage)%>";
   
   var ERROR_MESSAGE_FOR_INVALID_LEFT_RIGHT_EXP  = "<%=i18nNow.getI18nString("emxProduct.LeftRightExpression.Invalid", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_INVALID_LEFT_EXP  = "<%=i18nNow.getI18nString("emxProduct.LeftExpression.Invalid", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_INVALID_RIGHT_EXP  = "<%=i18nNow.getI18nString("emxProduct.RightExpression.Invalid", bundle,acceptLanguage)%>";
   var ERROR_PROCESS_INPROGRESS  = "<%=i18nNow.getI18nString("emxConfiguration.BOMGeneration.process", bundle,acceptLanguage)%>";
   var DESCRIPTION  = "<%=i18nNow.getI18nString("emxFramework.Basic.Description", bundle,acceptLanguage)%>";
   
   
   var HEADER = "<%=i18nNow.getI18nString("emxProduct.Label.RuleExpressionDialog", bundle,acceptLanguage)%>";
   var EXP_VALUE_LEFT = "<%=i18nNow.getI18nString("emxFramework.Label.Left_Expression", bundle,acceptLanguage)%>";
   var EXP_VALUE_RIGHT = "<%=i18nNow.getI18nString("emxFramework.Label.Right_Expression", bundle,acceptLanguage)%>";
   var EXP_VALUE_COMPLETED = "<%=i18nNow.getI18nString("emxFramework.Label.CompletedRule", bundle,acceptLanguage)%> "
   //MPR
   var FEATURE_CHOICES = "<%=i18nNow.getI18nString("emxProduct.Label.WillHaveChoice", bundle,acceptLanguage)%>( ";
   
   //Quantity Rule
   var COMPUTED_FEATURE = "<%=i18nNow.getI18nString("emxProduct.Label.ForTheFeature", bundle,acceptLanguage)%>";
   var COMPUTED_QUANTITY = "<%=i18nNow.getI18nString("emxProduct.Label.IncreaseQtyBy", bundle,acceptLanguage)%>";
   var COMPUTED_LABEL = "<%=i18nNow.getI18nString("emxProduct.Label.If", bundle,acceptLanguage)%>";
   var COMPUTED_SELECTED = "<%=i18nNow.getI18nString("emxProduct.Label.AreSelected", bundle,acceptLanguage)%>";
   
   //Inclusion Rule
   var RULE_TYPE_COMPLEX_INCLUSION = "<%=i18nNow.getI18nString("emxProduct.Rule_Type.ComplexInclusion", bundle,acceptLanguage)%>";
   var RULE_TYPE_COMPLEX_EXCLUSION = "<%=i18nNow.getI18nString("emxProduct.Rule_Type.ComplexExclusion", bundle,acceptLanguage)%>";
   var COMPUTED_RULE_BEGINNING_INCLUDE = "<%=i18nNow.getI18nString("emxProduct.computedRuleBeginning.Include", bundle,acceptLanguage)%>";
   var COMPUTED_RULE_BEGINNING_EXCLUDE = "<%=i18nNow.getI18nString("emxProduct.computedRuleBeginning.Exclude", bundle,acceptLanguage)%>"; 
   var COMPUTED_RULE_ENDING = "<%=i18nNow.getI18nString("emxProduct.computedRuleEnding.isSelected", bundle,acceptLanguage)%>";
   
   var ERROR_MESSAGE_FOR_OPTION_SELECTION = "<%=i18nNow.getI18nString("emxProduct.Alert.OptionSelection", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_SELECT_OPTION = "<%=i18nNow.getI18nString("emxProduct.Alert.SelectOption", bundle,acceptLanguage)%>";
   
   var ERROR_MESSAGE_FOR_QUANTITY_USAGE = "<%=i18nNow.getI18nString("emxProduct.Alert.UsageNumeric", bundle,acceptLanguage)%>";
   var ERROR_MESSAGE_FOR_QUANTITY  = "<%=i18nNow.getI18nString("emxProduct.Alert.EntryForQuantity", bundle,acceptLanguage)%> ";
   var RULE_NAME_SELECT="<%=i18nNow.getI18nString("emxProduct.Alert.EntryForName", bundle,acceptLanguage)%> ";
   var ENTER_MARKETING_CHOICES="<%=i18nNow.getI18nString("emxProduct.Alert.MarketingChoices", bundle,acceptLanguage)%> ";
   var MARKETING_PREFERENCE_INVALID="<%=i18nNow.getI18nString("emxProduct.MarketingPreferencesLeftExpression.Invalid", bundle,acceptLanguage)%>";
   var MARKETING_CHOICES_INVALID="<%=i18nNow.getI18nString("emxProduct.MarketingPreferencesRightExpression.Invalid", bundle,acceptLanguage)%>";
   var MARKETING_PREFERENCE_CHOICES_INVALID="<%=i18nNow.getI18nString("emxProduct.MarketingPreferenceLeftRightExpression.Invalid", bundle,acceptLanguage)%> "
   var INVALID_LE_RE_BCR="<%=i18nNow.getI18nString("emxProduct.BCR.InvalidLEREInsert", bundle,acceptLanguage)%> ";
   var INVALID_RE_QR="<%=i18nNow.getI18nString("emxProduct.QR.InvalidREInsert", bundle,acceptLanguage)%> ";
   var COMPARISON_TYPE_REQUIRES="<%=i18nNow.getI18nString("emxProduct.Range.Comparison_Type.Requires", bundle,acceptLanguage)%> ";
   var COMPARISON_TYPE_CO_DEP="<%=i18nNow.getI18nString("emxProduct.Range.Comparison_Type.Co-Dependent", bundle,acceptLanguage)%> ";
   var COMPARISON_TYPE_INCOMPATIBLE="<%=i18nNow.getI18nString("emxProduct.Range.Comparison_Type.Incompatible", bundle,acceptLanguage)%> ";
   var COMPARISON_TYPE_COMPATIBLE="<%=i18nNow.getI18nString("emxProduct.Range.Comparison_Type.Compatible", bundle,acceptLanguage)%> ";
   
   var LABEL_IS="<%=i18nNow.getI18nString("emxProduct.Label.Is", bundle,acceptLanguage)%> ";
   var LABEL_WITH="<%=i18nNow.getI18nString("emxProduct.Label.with", bundle,acceptLanguage)%> ";
   var DUP_NAME_ALERT="<%=i18nNow.getI18nString("emxProduct.Rule.AlreadyExists", bundle,acceptLanguage)%> ";
   var INVALID_STATE_ALERT="<%=i18nNow.getI18nString("emxProduct.Rule.InvalidState", bundle,acceptLanguage)%> ";
   
   var ERROR_MESSAGE_FOR_MARKETING_RULE_LEFT_EXP  = "<%=i18nNow.getI18nString("emxConfiguration.ValidateRule.MarketingRules_LeftExpression", bundle,acceptLanguage)%> ";   
   var ERROR_MESSAGE_FOR_MARKETING_RULE_RIGHT_EXP  = "<%=i18nNow.getI18nString("emxConfiguration.ValidateRule.MarketingRules_RightExpression", bundle,acceptLanguage)%> ";
   var ERROR_MESSAGE_FOR_DESIGN_RULE_RIGHT_EXP  = "<%=i18nNow.getI18nString("emxConfiguration.ValidateRule.DesignRule_RightExpression", bundle,acceptLanguage)%> ";

   var LOGICAL ="<%=i18nNow.getI18nString("emxProduct.Filter.Technical", bundle,acceptLanguage)%> ";
   var CONFIGURATION ="<%=i18nNow.getI18nString("emxProduct.Filter.Marketing", bundle,acceptLanguage)%> ";
   
</script>
<script language="javascript" src="emxValidationInclude.js"></script>
<script language="javascript" src="RuleDialogCommonOperations.js"></script>
<script language="javascript" src="RuleDialogValidationsForCompletedRule.js"></script>


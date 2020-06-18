<%--  emxEngineeringChangeImpactAnalysisCreateDialog.jsp

  Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
  
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEngineeringChangeImpactAnalysisCreateDialog.jsp.rca 1.6 Wed Oct 22 16:18:07 2008 przemek Experimental przemek $
--%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

 <%-- Common Includes --%>
 <%@include file = "emxComponentsCommonInclude.inc" %>
 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
 
 <%@include file = "emxImpactAnalysisGlobalSettingInclude.inc"%>
 

 <%@page import  = "com.matrixone.apps.domain.*"%>
 <%@page import  = "com.matrixone.apps.common.*"%>
 <%@page import  = "com.matrixone.apps.common.EngineeringChange"%>
 <%@page import  = "com.matrixone.apps.common.ImpactAnalysis"%>
 



 <%

     String strTreeId        = "";
     String strSuiteKey      = "";
     String busId            = "";
     String strBaseType      = "";
     String STR_ITEM_MAX_CHAR_LENGTH                = EnoviaResourceBundle.getProperty(context, "emxFramework.MAX_FIELD_LENGTH");
     String ResFileId = "emxFrameworkStringResource";     
     String STR_ITEM_ALERT_MAX_CHAR_LENGTH          = EnoviaResourceBundle.getProperty(context,ResFileId,context.getLocale(), "emxFramework.AdminProperty.CheckLength"); 
     try {
         //getting attribute ranges from ImpactAnalysis Bean
         String[] arrAttributeRanges = new String[5];

         arrAttributeRanges[0]  = DomainConstants.ATTRIBUTE_SEVERITY;
         arrAttributeRanges[1]  = DomainConstants.ATTRIBUTE_PRIORITIZATION_BENEFIT;
         arrAttributeRanges[2]  = DomainConstants.ATTRIBUTE_RELATIVE_COST;
         arrAttributeRanges[3]  = DomainConstants.ATTRIBUTE_RELATIVE_PENALTY;
         arrAttributeRanges[4]  = DomainConstants.ATTRIBUTE_RELATIVE_RISK;

         Map attrRangeMap       = EngineeringChange.getAttributeChoices(context,arrAttributeRanges);

         MapList attrMapListSeverity                 = (MapList) attrRangeMap.get(arrAttributeRanges[0]);
         //Getting the internationalized range values
         attrMapListSeverity = EngineeringChange.getI18nValues(attrMapListSeverity, DomainConstants.ATTRIBUTE_SEVERITY, acceptLanguage);
         MapList attrMapListPrioritizationBenefit    = (MapList) attrRangeMap.get(arrAttributeRanges[1]);
         MapList attrMapListRelativeCost             = (MapList) attrRangeMap.get(arrAttributeRanges[2]);
         MapList attrMapListRelativePenalty          = (MapList) attrRangeMap.get(arrAttributeRanges[3]);
         MapList attrMapListRelativeRisk             = (MapList) attrRangeMap.get(arrAttributeRanges[4]);

         String strPolicy = EngineeringChange.POLICY;

         //Retrieves Parent ObjectId in context
         busId            = emxGetParameter(request, "objectId");
         //getting tree id from common FS
         strTreeId        = emxGetParameter(request, "jsTreeID");
         //getting suite key from common FS
         strSuiteKey      = emxGetParameter(request, "suiteKey");

          //The base type is set for the Type chooser variable.
         strBaseType = DomainConstants.TYPE_IMPACT_ANALYSIS;


 %>
 <%@include file = "../emxUICommonHeaderEndInclude.inc"%>

 <form name="ImpactAnalysisCreate" method="post" onsubmit="submitForm(); return false">
   <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
   <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=busId%></xss:encodeForHTMLAttribute>"/>
   <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <%-- Display the input fields. --%>

 <%
     /*
      *This logic defines if the name field is to be made visible to the user or not
      *These setting are based on the global settings for each module made in the
      *application property file.
      */
 %>
     <input type="hidden" name="strAutoNamer" value="<xss:encodeForHTMLAttribute><%=strAutoNamer%></xss:encodeForHTMLAttribute>" />
 <%

     if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING) ) {
 %>

     <tr>
       <td width="150" nowrap="nowrap" class="labelRequired">
         <framework:i18n localize="i18nId">
           emxFramework.Basic.Name
         </framework:i18n>
       </td>
       <td nowrap="nowrap" class="field">
         <input type="text" name="txtImpactAnalysisName" size="20" onFocus="valueCheck()"/>
           &nbsp;
 <%
           if (strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING)) {
 %>

             <input type="checkbox" name="chkAutoName" onclick="nameDisabled()"/><emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>
 <%
           }
 %>
       </td>
     </tr>

 <%

     } else {
 %>
       <input type="hidden" name="txtImpactAnalysisName" value=""/>
 <%
     }
 %>

   <tr>
     <td width="150" class="labelRequired" valign="top">
       <framework:i18n localize="i18nId"><%="emxFramework.Basic.Description"%></framework:i18n>
     </td>
     <td class="field">
       <textarea name="txtImpactAnalysisDescription" rows="5" cols="25"></textarea>
     </td>
   </tr>

   <tr>
     <td width="150" class="labelRequired" width="200" align="left">
       <framework:i18n localize="i18nId">
         <%="emxFramework.Attribute.Severity"%>
       </framework:i18n>
     </td>
     <td class="field">
       <select name="lstImpactAnalysisSeverity">
		 <!-- //XSSOK -->
         <framework:optionList optionMapList="<%= attrMapListSeverity%>" optionKey="<%= DomainConstants.SELECT_NAME%>" valueKey="<%= EngineeringChange.VALUE%>" selected = ""/>
       </select>
     </td>
   </tr>

   <tr>
     <td width="150" class="labelRequired" valign="top">
       <framework:i18n localize="i18nId"><%="emxFramework.Attribute.Quality_Impact"%></framework:i18n>
     </td>
     <td class="field">
       <textarea name="txtImpactAnalysisQualityImpact" rows="5" cols="25"></textarea>
     </td>
   </tr>

   <tr>
     <td width="150" class="label" valign="top">
       <framework:i18n localize="i18nId"><%="emxFramework.Attribute.Life_Cycle_Cost_Issues"%></framework:i18n>
     </td>
     <td class="field">
       <textarea name="txtImpactAnalysisLCCostIssues" rows="5" cols="25"></textarea>
     </td>
   </tr>

   <tr>
     <td width="150" class="label" width="200" align="left">
       <framework:i18n localize="i18nId">
         <%="emxFramework.Attribute.Prioritization_Benefit"%>
       </framework:i18n>
     </td>
     <td class="field">
       <select name="lstImpactAnalysisPrioritizationBenefit">
         <framework:optionList
         optionMapList="<%= attrMapListPrioritizationBenefit%>"
         optionKey="name"
         valueKey="name"
         selected = ""/>
       </select>
     </td>
   </tr>

   <tr>
     <td width="150" class="label" width="200" align="left">
       <framework:i18n localize="i18nId">
         <%="emxFramework.Attribute.Relative_Cost"%>
       </framework:i18n>
     </td>
     <td class="field">
       <select name="lstImpactAnalysisRelativeCost">
         <framework:optionList
         optionMapList="<%= attrMapListRelativeCost%>"
         optionKey="name"
         valueKey="name"
         selected = ""/>
       </select>
     </td>
   </tr>

   <tr>
     <td width="150" class="label" width="200" align="left">
       <framework:i18n localize="i18nId">
         <%="emxFramework.Attribute.Relative_Penalty"%>
       </framework:i18n>
     </td>
     <td class="field">
       <select name="lstImpactAnalysisRelativePenalty">
         <framework:optionList
         optionMapList="<%= attrMapListRelativePenalty%>"
         optionKey="name"
         valueKey="name"
         selected = ""/>
       </select>
     </td>
   </tr>

   <tr>
     <td width="150" class="label" width="200" align="left">
       <framework:i18n localize="i18nId">
         <%="emxFramework.Attribute.Relative_Risk"%>
       </framework:i18n>
     </td>
     <td class="field">
       <select name="lstImpactAnalysisRelativeRisk">
         <framework:optionList
         optionMapList="<%= attrMapListRelativeRisk%>"
         optionKey="name"
         valueKey="name"
         selected = ""/>
       </select>
     </td>
   </tr>

   <tr>
     <td width="150" nowrap="nowrap" class="labelRequired">
       <framework:i18n localize="i18nId">
         emxFramework.Attribute.Impact_Analysis_Effort
       </framework:i18n>
     </td>
     <td nowrap="nowrap" class="field">
       <input type="text" name="txtImpactAnalysisEffort" maxlength="5" size="20"/>
         &nbsp;
     </td>
   </tr>

   <tr>
     <td width="150" nowrap="nowrap" class="label">
       <framework:i18n localize="i18nId">
         emxFramework.Attribute.Estimate_Schedule_Impact
       </framework:i18n>
     </td>
     <td nowrap="nowrap" class="field">
       <input type="text" name="txtEstimateScheduleImpact" size="20"/>
         &nbsp;
     </td>
   </tr>

   <tr>
     <td width="150" nowrap="nowrap" class="label">
       <framework:i18n localize="i18nId">
         emxFramework.Attribute.Implementation_Effort
       </framework:i18n>
     </td>
     <td nowrap="nowrap" class="field">
       <input type="text" name="txtImplementationEffort" size="20"/>
        &nbsp;
     </td>
   </tr>

   <tr>
     <td width="150" nowrap="nowrap" class="label">
       <framework:i18n localize="i18nId">
         emxFramework.Attribute.Validation_Effort
       </framework:i18n>
     </td>
     <td nowrap="nowrap" class="field">
       <input type="text" name="txtValidationEffort" size="20"/>
         &nbsp;
     </td>
   </tr>
 <%
   /*
    *This logic defines if the Policy field is to be made visible to the user or not
    *These setting are based on the global settings for each module made in the
    *application property file.
    */

     HashMap mapPolicyList = EngineeringChange.getI18NPolicyList(context,strBaseType,acceptLanguage);
     StringList policyValueList = (StringList)mapPolicyList.get(EngineeringChange.VALUE);
   if (!bPolicyAwareness) {
       StringList il18NPolicyList = (StringList)mapPolicyList.get(DomainConstants.SELECT_NAME);
       String strPolicyName="";
       int intListSize=policyValueList.size();
     %>

  <tr>
    <td width="150" class="label" valign="top">
       <emxUtil:i18n localize="i18nId">
          emxFramework.Basic.Policy
       </emxUtil:i18n>
    </td>
<% if (intListSize>1) {
%>
      <td class="inputField">
      <select name="txtImpactAnalysisPolicy"  >
<%
      for (int i=0;i<intListSize;i++) {
%>
        <option value="<xss:encodeForHTMLAttribute><%=policyValueList.get(i)%></xss:encodeForHTMLAttribute>" ><%=il18NPolicyList.get(i)%>
        </option>

<%
       }
%>
       </select>
    </td>
  </tr>
<%
     } if(intListSize==1) {
%>
       <td class="field">
			<!-- //XSSOK -->
          <%=il18NPolicyList.get(0)%>
          <input type="hidden" name="txtImpactAnalysisPolicy" value="<xss:encodeForHTMLAttribute><%=policyValueList.get(0)%></xss:encodeForHTMLAttribute>"/>
       </td>
       </tr>

<%
      }
    } else {
  %>
     <input type="hidden" name="txtImpactAnalysisPolicy" value="<xss:encodeForHTMLAttribute><%=policyValueList.get(0)%></xss:encodeForHTMLAttribute>"/>
 <%
     }


   /*
    *This logic defines if the Vault field is to be made visible to the user or not
    *These setting are based on the global settings for each module made in the
    *application property file.
    */

   if (bShowVault) {
 %>

     <tr>
       <td width="150" class="label" valign="top">
         <framework:i18n localize="i18nId"><%="emxFramework.Basic.Vault"%></framework:i18n>


       </td>
       <td class="field">
         <input type="text" name="txtImpactAnalysisVaultDisplay" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>"/>
         <input type="hidden" name="txtImpactAnalysisVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>"/>
         <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();"/>&nbsp;
         <a class="dialogClear" name="ancClear" href="#ancClear" onclick="document.ImpactAnalysisCreate.txtImpactAnalysisVault.value='';document.ImpactAnalysisCreate.txtImpactAnalysisVaultDisplay.value=''"><emxUtil:i18n localize="i18nId">
               emxComponents.Button.Clear
             </emxUtil:i18n></a>
       </td>
     </tr>

 <%
   } else {
 %>
     <input type="hidden" name="txtImpactAnalysisVault" value="<%=strUserVault%>"/>
 <%
   }
 %>

   <tr>
     <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
     <td width="90%">&nbsp;</td>
   </tr>

   </table>
</form>

 <%
   } catch(Exception ex) {
        session.putValue("error.message", ex.getMessage());
     }
 %>
 <%@include file = "emxValidationInclude.inc" %>

 <script language="javascript" type="text/javaScript">
 //<![CDATA[
 var  formName = document.ImpactAnalysisCreate;
 var  autoNameValue = "<%= strAutoNamer %>";

 //if Autoname field is checked, focus goes to Description field

 function valueCheck()
 {

     if (autoNameValue == "<%=DomainConstants.EMPTY_STRING%>")
     {
         if (formName.chkAutoName.checked)
         {
             //formName.txtImpactAnalysisDescription.focus();
             formName.txtImpactAnalysisName.blur();
         }
     }
 }

 //for disabling the name field is autoname is checked
 function nameDisabled()
 {
     if (autoNameValue == "<%=DomainConstants.EMPTY_STRING%>")
     {

         if (formName.chkAutoName.checked)
         {
             formName.txtImpactAnalysisName.value = "<%=DomainConstants.EMPTY_STRING%>";
             formName.chkAutoName.value = "true";
             formName.txtImpactAnalysisDescription.focus();
         }
         else
         {
             formName.txtImpactAnalysisName.focus();
         }
     }
 }

 //validates dialog form for required field


 function validateForm()
 {
   var iValidForm = true;
   //XSSOK
   if(!(<%=strAutoNamer.equalsIgnoreCase("True")%>))
   {
     //XSSOK
	 if((<%=strAutoNamer.equalsIgnoreCase("False")%>))
     {
       if (iValidForm)
       {
         var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
         var field = formName.txtImpactAnalysisName;
         iValidForm = basicValidation(formName,field,fieldName,true,false,true,false,false,false,false);
     }
   }
   else
     {
       if (!formName.chkAutoName.checked)
       {
         if (iValidForm)
         {
           var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
           var field = formName.txtImpactAnalysisName;
           if(field.value.length > <%=STR_ITEM_MAX_CHAR_LENGTH%>){
				var alertMsg = "<%=STR_ITEM_ALERT_MAX_CHAR_LENGTH%>" + " " + "<%=STR_ITEM_MAX_CHAR_LENGTH%>";
				alert(alertMsg);
				iValidForm = false;
			}else{
           iValidForm = basicValidation(formName,field,fieldName,true,false,true,false,false,false,false);
         }
       }
   }
   }
   }
   //Validation for Required field,Length and Bad chararters for Description - The sixth(true/false) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
   var field = formName.txtImpactAnalysisDescription;
   iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,checkBadChars);
   }

   //Validation for Required field,Length for Quality Impact
   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Quality_Impact", bundle,acceptLanguage)%> ";
   var field = formName.txtImpactAnalysisQualityImpact;
   iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,checkBadChars);
   }

   //Validation for Bad chararters for LifeCycleCostIssues

   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Life_Cycle_Cost_Issues", bundle,acceptLanguage)%> ";
   var field = formName.txtImpactAnalysisLCCostIssues;
   iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
   }

   //Validation for Required field,Length and Bad chararters for Impact Analysis Effort
   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Impact_Analysis_Effort", bundle,acceptLanguage)%> ";
   var field = formName.txtImpactAnalysisEffort;
   //Changed for bug #365321 - validating for integers
   iValidForm = basicValidation(formName,field,fieldName,true,true,false,true,true,true,false)
   }

   //Validation for Numeric Values for Estimate Schedule Impact
   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Estimate_Schedule_Impact", bundle,acceptLanguage)%> ";
   var field = formName.txtEstimateScheduleImpact;
   iValidForm = basicValidation(formName,field,fieldName,false,true,false,true,true,false,false)
   }

   //Validation for Numeric Values for Implementation Effort
   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Implementation_Effort", bundle,acceptLanguage)%> ";
   var field = formName.txtImplementationEffort;
   iValidForm = basicValidation(formName,field,fieldName,false,true,false,true,true,false,false)
   }

   //Validation for Numeric Values for Validation Effort
   if (iValidForm)
   {
   var fieldName = "<%=i18nNow.getI18nString("emxFramework.Attribute.Validation_Effort", bundle,acceptLanguage)%> ";
   var field = formName.txtValidationEffort;
   iValidForm = basicValidation(formName,field,fieldName,false,true,false,true,true,false,false)
   }
   if (!iValidForm)
   {

     return ;
   }

   //Capturing mouse events before submitting the form
   formName.target = "jpcharfooter";
   //For displaying process clock
   parent.turnOnProgress();
   if (jsDblClick()) {
        formName.submit();
      }
 }
 //when Cancel button is pressed in Dialog Page
 function closeWindow()
  {
   //Releasing Mouse Events
   window.closeWindow();
  }

  //When Enter Key Pressed on the form
   function submitForm()
   {
    submit();
   }
 //when Done button is pressed in Dialog Page
 function submit()
 {
     strURL = "../components/emxEngineeringChangeImpactAnalysisUtil.jsp?mode=create";
     strURL = strURL + "&jsTreeID=<%= XSSUtil.encodeForURL(context, strTreeId)%>&suiteKey=<%= XSSUtil.encodeForURL(context, strSuiteKey)%>";
     formName.action = strURL;
     validateForm();
 }
 // Replace vault dropdown box with vault chooser.
 var txtVault = null;
 var bVaultMultiSelect = false;
 var strTxtVault = "document.forms['ImpactAnalysisCreate'].txtImpactAnalysisVault";
 //Displays the Vault Chooser
 function showVaultSelector()
 {
     //This function is for popping the Vault chooser.
     txtVault = eval(strTxtVault);
     showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtImpactAnalysisVault&fieldNameDisplay=txtImpactAnalysisVaultDisplay&incCollPartners=false&multiSelect=false');
 }

 //Code to set focus on the first editable field based on Autonamer check option.

     var strAutoNamer = document.ImpactAnalysisCreate.strAutoNamer.value;
 	//XSSOK
     if((<%=strAutoNamer.equalsIgnoreCase("False")%>) || strAutoNamer == "" ) {
         document.ImpactAnalysisCreate.txtImpactAnalysisName.focus();
     } else {
         document.ImpactAnalysisCreate.txtImpactAnalysisDescription.focus();
     }
 //]]>
 </script>
 <!-- to handle the error.messages-->
 <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

  <!--to include the Html body closing tag -->
 <%@include file = "../emxUICommonEndOfPageInclude.inc"%>

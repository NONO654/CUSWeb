<%--  RuleDialogComparisonOperatorForPCR.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret ination
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/BooleanCompatibilityCreateDialog.jsp 1.3.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>

<%@page import = "com.matrixone.apps.configuration.BooleanOptionCompatibility"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
 String strValidationJS = emxGetParameter(request,"validation");
%>
 <SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
  String strObjectId = emxGetParameter(request,"objectId");
  String strmode = emxGetParameter(request,"modetype");
  String strAttribRange               = "" ;
 // String strComparisonOperatorValue = emxGetParameter(request,"Comparison Operator");
  //String strCompatibilityOptionValue = emxGetParameter(request,"Compatibility Option");
  StringBuffer strBuffer = new StringBuffer();
  Enumeration enumParamNames = emxGetParameterNames(request);
  while(enumParamNames.hasMoreElements())
  {
    String paramName = (String) enumParamNames.nextElement();
    String paramValue = emxGetParameter(request,paramName);
    strBuffer.append("&");
    strBuffer.append(paramName);
    strBuffer.append("=");
    strBuffer.append(paramValue);
  }
    
  BooleanOptionCompatibility boBean = new BooleanOptionCompatibility();
  Map boCompatibilityAtributeMap = boBean.getBooleanCompatibilityDetails(context,strObjectId);
  String strComparisonOperatorValue = (String)boCompatibilityAtributeMap.get(ConfigurationConstants.ATTRIBUTE_COMPARISION_OPERATOR);
  String strCompatibilityOptionValue = (String)boCompatibilityAtributeMap.get(ConfigurationConstants.ATTRIBUTE_COMPATIBILITY_OPTION);
  %>

      <div class="comparison-operator">
            <div class="header">
                <table>
                    <tr>
                        <td class="section-title">
                          <emxUtil:i18n localize="i18nId">emxProduct.Label.ComparisonOperator</emxUtil:i18n>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="body">
                <table>
                    <tr>
                        <% if((strmode.compareTo("create")==0)){ %>
         <td>
            <select name="comparisonOperator" id="comparisonOperator" onChange='computedRule("(","left","same")'>
            <option value="Compatible"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Compatible</emxUtil:i18n></option>
            <option value="Incompatible"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Incompatible</emxUtil:i18n></option>
            <option value="Requires"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Requires</emxUtil:i18n></option>
            <option value="Co-Dependent"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Co-Dependent</emxUtil:i18n></option>
           </select>
          </td>
        <%}%>

        <%if((strmode.compareTo("edit")==0)|| (strmode.compareTo("copy")==0)){%>
          <td>
           <select name="comparisonOperator" id="comparisonOperator" onChange='computedRule("(","left")'>
            <%
                //Displaying the Ranges of the attribhute:Comparison Operator  //getting the attribute ranges of Comparison Operator
               String[] strComparisonOperator = new String[1];
               strComparisonOperator[0] = ConfigurationConstants.ATTRIBUTE_COMPARISION_OPERATOR;
               ProductLineUtil utilBean = new ProductLineUtil();
               Map comparisonOperatorValues = utilBean.getAttributeChoices(context,strComparisonOperator);
               MapList attribMap = (MapList) comparisonOperatorValues.get(ConfigurationConstants.ATTRIBUTE_COMPARISION_OPERATOR);

               String strLocale = context.getSession().getLanguage();
               /*String comparisionOperaName = "Compatible";
               for(int compOperator=0;compOperator<attribMap.size();compOperator++){
               String operatorName = (String)((HashMap)attribMap.get(compOperator)).get(ConfigurationConstants.SELECT_NAME);                           
               if(operatorName.equalsIgnoreCase(comparisionOperaName)){
                  attribMap.remove(compOperator);
                 }
               }*/
                        
               for( int i=0;i<attribMap.size(); i++){
                  strAttribRange = (String)((HashMap)attribMap.get(i)).get("name");
                  String strKey = "emxProduct.Range.Comparison_Type."+strAttribRange;               
                  
                  if (strAttribRange.equals(strComparisonOperatorValue)){%>
                     <option value="<xss:encodeForHTMLAttribute><%=strAttribRange%></xss:encodeForHTMLAttribute>"><emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,strKey)%></emxUtil:i18n></option>
                      <%}else if(!strAttribRange.equals(strComparisonOperatorValue)){%>
                     <option value="<xss:encodeForHTMLAttribute><%=strAttribRange%></xss:encodeForHTMLAttribute>"><emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,strKey)%></emxUtil:i18n></option>
                  <%}
               }%>
                     
             </select>
           </td>
         <%}
                  
         if(strmode.compareTo("edit")==0){
           String rangeValue ="";
           if (strCompatibilityOptionValue.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_UPWARD)){
                        rangeValue = ConfigurationConstants.RANGE_VALUE_UPWARD;             
           }else if (strCompatibilityOptionValue.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_DOWNWARD)){
                        rangeValue = ConfigurationConstants.RANGE_VALUE_DOWNWARD;
           }else if (strCompatibilityOptionValue.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_ALL)){
                       rangeValue = ConfigurationConstants.RANGE_VALUE_ALL;
           }else if (strCompatibilityOptionValue.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_NONE)){
                        rangeValue = ConfigurationConstants.RANGE_VALUE_NONE;
           }%>          
                    
           <td>
             <emxUtil:i18n localize="i18nId">emxFramework.Attribute.IncludeFutureRevisions</emxUtil:i18n>
             <select name="compType" id="compType" >
               <% if(rangeValue.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_UPWARD)||rangeValue.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_ALL)){%>  
                 <option value="YES"><emxUtil:i18n localize="i18nId">emxProduct.Rules.IncludeFutureRevisions.Yes</emxUtil:i18n></option>
                 <option value="NO"><emxUtil:i18n localize="i18nId">emxProduct.Rules.IncludeFutureRevisions.No </emxUtil:i18n></option>
               <%}else{%>
                 <option value="NO"><emxUtil:i18n localize="i18nId">emxProduct.Rules.IncludeFutureRevisions.No</emxUtil:i18n></option>
                 <option value="YES"><emxUtil:i18n localize="i18nId">emxProduct.Rules.IncludeFutureRevisions.Yes</emxUtil:i18n></option>
               <%}%>
             </select>
            </td>               
           <%          
            } 
            if(strmode!=null && !(strmode.compareTo("edit")==0)){%>
           <td>
             <emxUtil:i18n localize="i18nId"> emxFramework.Attribute.IncludeOtherRevisions</emxUtil:i18n>
               <select name="compType" >
                 <option value="Upward"><emxUtil:i18n localize="i18nId">emxProduct.comparisonOperator.Value.Upward</emxUtil:i18n></option>
                 <option value="All"><emxUtil:i18n localize="i18nId">emxProduct.comparisonOperator.Value.All</emxUtil:i18n></option>
                 <option value="Downward"><emxUtil:i18n localize="i18nId">emxProduct.comparisonOperator.Value.Downward </emxUtil:i18n></option>
                 <option value="None"><emxUtil:i18n localize="i18nId">emxProduct.comparisonOperator.Value.None</emxUtil:i18n></option>
               </select>
           </td>
        <%}%>
                
       </tr>
    </table>
  </div>
       <input type="hidden" name="hcompatibilityType" id="compatibilityType" value="" />
       <input type="hidden" name="hcompType" id="compType" value="" />



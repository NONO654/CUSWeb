<%--  RuleDialogComparisonOperator.jsp

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
    
  BooleanOptionCompatibility boBean = new BooleanOptionCompatibility();
  Map boCompatibilityAtributeMap = boBean.getBooleanCompatibilityDetails(context,strObjectId);
  String strComparisonOperatorValue = (String)boCompatibilityAtributeMap.get(ConfigurationConstants.ATTRIBUTE_COMPARISION_OPERATOR);
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
                                <option value="Incompatible"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Incompatible</emxUtil:i18n></option>
                                <option value="Requires"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Requires</emxUtil:i18n></option>
                                <option value="Co-Dependent"><emxUtil:i18n localize="i18nId">emxProduct.Range.Comparison_Type.Co-Dependent</emxUtil:i18n></option>
                            </select>
                         </td>
                        <%}%>
                        <% if((strmode.compareTo("edit")==0)|| (strmode.compareTo("copy")==0)){%>
                         <td>
                           <select name="comparisonOperator" id="comparisonOperator" onChange='computedRule("(","left","same")'>
                            <%
                               //Displaying the Ranges of the attribhute:Comparison Operator
                               //getting the attribute ranges of Comparison Operator
                                String[] strComparisonOperator = new String[1];
                                strComparisonOperator[0] = ConfigurationConstants.ATTRIBUTE_COMPARISION_OPERATOR;
                                ProductLineUtil utilBean = new ProductLineUtil();
                                Map comparisonOperatorValues = utilBean.getAttributeChoices(context,strComparisonOperator);
                                MapList attribMap = (MapList) comparisonOperatorValues.get(ConfigurationConstants.ATTRIBUTE_COMPARISION_OPERATOR);
    
                                String strLocale = context.getSession().getLanguage();
                                String comparisionOperaName = "Compatible";
                                for(int compOperator=0;compOperator<attribMap.size();compOperator++){
                                 String operatorName = (String)((HashMap)attribMap.get(compOperator)).get(ConfigurationConstants.SELECT_NAME);                           
                                 if(operatorName.equalsIgnoreCase(comparisionOperaName)){
                                       attribMap.remove(compOperator);
                                   }
                                }
                            
                                for( int i=0;i<attribMap.size(); i++){
                                    strAttribRange = (String)((HashMap)attribMap.get(i)).get("name");
                                    String strKey = "emxProduct.Range.Comparison_Type."+strAttribRange;               
                                    if (strAttribRange.equals(strComparisonOperatorValue)){%>
                                     <option value="<xss:encodeForHTMLAttribute><%=strAttribRange%></xss:encodeForHTMLAttribute>" selected><emxUtil:i18n localize="i18nId"><%=strKey%></emxUtil:i18n></option>
                                    <%}else if(!strAttribRange.equals(strComparisonOperatorValue)){%>
                                     <option value="<xss:encodeForHTMLAttribute><%=strAttribRange%></xss:encodeForHTMLAttribute>"><emxUtil:i18n localize="i18nId"><%=strKey%></emxUtil:i18n></option>
                                    <%}
                                  }%>
                           </select>
                         </td>
                        <%}%>
                    </tr>
                </table>
            </div>
        </div><!-- /#divComparisonOperator-->
 
     <input type="hidden" name="hcompatibilityType" id="compatibilityType" value="<xss:encodeForHTMLAttribute><%=strComparisonOperatorValue%></xss:encodeForHTMLAttribute>" />



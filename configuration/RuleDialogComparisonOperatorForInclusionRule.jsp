<%--  RuleDialogComparisonOperatorForInclusionRule.jsp

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

<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
 String strValidationJS = emxGetParameter(request,"validation");
%>
 <SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
  String strAttribRange               = "" ;
  String strRelId = emxGetParameter(request,"relId");
  
  String strComparisonOperatorValue ="";
  
  if(strRelId!=null && strRelId.length()!=0){
	  DomainRelationship domRelId = new DomainRelationship(strRelId);
	  strComparisonOperatorValue = domRelId.getAttributeValue(context,ConfigurationConstants.ATTRIBUTE_RULE_TYPE); 
  }
  
  //getting the attribute ranges of Rule Type
  String[] arrRuleType = new String[1];
  arrRuleType[0] = ConfigurationConstants.ATTRIBUTE_RULE_TYPE;
  ProductLineUtil utilBean = new ProductLineUtil();
  Map ruleTypeValues = utilBean.getAttributeChoices(context,arrRuleType);
    
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
				   <select name="comparisonOperator" id="comparisonOperator" onchange="computedRule('','right','same')">
                   <%
                     MapList attribMap = (MapList) ruleTypeValues.get(ConfigurationConstants.ATTRIBUTE_RULE_TYPE);
                                for( int i=0;i<attribMap.size(); i++){
                                strAttribRange = (String)((HashMap)attribMap.get(i)).get(DomainConstants.SELECT_NAME);
                                String strTempRange = "emxProduct.Rule_Type.Complex"+strAttribRange;
                        
                                                          
                            if (strAttribRange.equals(strComparisonOperatorValue))
                              {%>
                                <option value="<xss:encodeForHTMLAttribute><%=strAttribRange%></xss:encodeForHTMLAttribute>" selected ><emxUtil:i18n localize="i18nId"><%=strTempRange%></emxUtil:i18n></option>
                             <%
                              }else if(!strAttribRange.equals(strComparisonOperatorValue)){
                             %>
                                <option value="<xss:encodeForHTMLAttribute><%=strAttribRange%></xss:encodeForHTMLAttribute>"><emxUtil:i18n localize="i18nId"><%=strTempRange%></emxUtil:i18n></option>
                             <%
                            }
                     } // end of for 
                   %>
                </select>
            </tr>
        </table>
        </div>
        </div><!-- /#divComparisonOperator-->
 
     <input type="hidden" name="hcompatibilityType" id="compatibilityType" value="<xss:encodeForHTMLAttribute><%=strComparisonOperatorValue%></xss:encodeForHTMLAttribute>" />



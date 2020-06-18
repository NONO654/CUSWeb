<%--  RuleDialogRightExpressionForPCR.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/BooleanCompatibilityCreateDialog.jsp 1.3.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%-- Validation Includes --%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
 String strValidationJS = emxGetParameter(request,"validation");
%>
 <SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>
<%
	String strREText = emxGetParameter(request,"strREText");
	String strREValue = emxGetParameter(request,"strREValue");
	String strLabel="";
	String ruleExpressionLength = EnoviaResourceBundle.getProperty(context,"emxConfiguration.RuleDialogExpression.Expression.Length");

	strLabel = "emxFramework.Label.Right_Expression"; 
%>
 <div class="expression clearfix">
     <div class="header">
       <table>
        <tr>
           <td class="section-title">
             <emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,strLabel)%></emxUtil:i18n>
           </td>
           <td class="buttons">
           <div id="RuleRight">
             <img onclick="showRuleDialog(<%=XSSUtil.encodeForHTMLAttribute(context,ruleExpressionLength)%>,'RExp','RuleRight','rightEx')" src="../common/images/iconSmallNewWindow.png" />
           </div>
           </td>
        </tr>
       </table>
     </div><!-- /.header -->
        
     <div class="body">
       <div class="operators">
         <table>
           <tr>
             <td>
                <input type="button" name="or" value="OR" onclick='operatorInsert("OR","right"),computedRule("OR","right","same")' />
             </td>
           </tr>
         </table>
       </div><!-- /.operators -->
    
    <div class="object-manipulation clearfix">
       <div class="button"><a href="#" onclick="removeExp('right'),computedRule('','right','same')" class="button-remove" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.Remove</emxUtil:i18n>"></a></div>
       <div class="button"><a href="#" onclick="insertFeatureOptions('right','same'),computedRule('','right','same')" class="button-insert" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.Insert</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
       <div class="button"><a href="#"  onclick="moveUp('right'),computedRule('','right','same')" class="button-move-up" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.MoveUp</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
       <div class="button"><a href="#" onclick="moveDown('right'),computedRule('','right','same')" class="button-move-down" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.MoveDown</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
       <div class="button separator"><img src="../common/images/utilSpacer.gif" border="0" /></div>
       <div class="button"><a href="#" onClick="clearAll('right'),computedRule('','right','same')" class="button-clear" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.ClearExpression</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
    </div><!-- /.object-manipulation -->

    <div class="terms" onscroll="OnDivScroll();">
       <select size="10" name="RightExpression" multiple id="RExp"></select>
    </div><!-- /.terms -->
   </div><!-- /.body -->

    
    <input type="hidden" name="hrightExpObjIds" id="hrightExpObjIds" value="" />
    <input type="hidden" name="hrightExpObjTxt" id="hrightExpObjTxt" value="" />
    <input type="hidden" name="hrightExpObjIdsForEdit" id="hrightExpObjIdsForEdit" value="<xss:encodeForHTMLAttribute><%=strREValue%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hrightExpObjTxtForEdit" id="hrightExpObjTxtForEdit" value="<xss:encodeForHTMLAttribute><%=strREText%></xss:encodeForHTMLAttribute>" />


    <input type="hidden" name="hrightExpRCVal" id="hrightExpRCVal" value = "" />
    <input type="hidden" name="hrightExpFeatTypeVal" id="hrightExpFeatTypeVal" value = "" />

 </div><!-- /.expression -->
 <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


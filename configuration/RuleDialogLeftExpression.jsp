<%-- RuleDialogLeftExpression.jsp --%>

<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%-- Validation Includes --%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
    String strRule = emxGetParameter(request, "ruleType");
    String strValidationJS = emxGetParameter(request,"validation");
    
    String strLabel = "";

    //To handle the LE and RE heading for MPR check the Rule Type..
    if(strRule!=null && strRule.equalsIgnoreCase("MarketingPreferenceRule")){
        strLabel = "emxFramework.Label.MarketingPreferenceCondition"; 
    }else{
        strLabel = "emxFramework.Label.Left_Expression"; 
    }
    
    //reading  rule Expression Length from properties file
    String ruleExpressionLength = EnoviaResourceBundle.getProperty(context,"emxConfiguration.RuleDialogExpression.Expression.Length");

%>
<SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>
    <div class="expression clearfix">
        <div class="header">
         <table>
          <tr>
           
           <td class="section-title">
             <emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,strLabel)%></emxUtil:i18n>
           </td>
           
           <td class="functions">
            <table>
             <tr>
              <td>
               <input name="leftExpCheckBox" id="leftExpCheckBox" type="checkbox" />
                <emxUtil:i18n localize="i18nId">emxProduct.Label.InsertwithFeatureOption</emxUtil:i18n>
              </td>
             </tr>
            </table>
           </td>
           
           <td class="buttons">
           <div id="RuleLeft">
             <img onclick="showRuleDialog(<%=XSSUtil.encodeForHTMLAttribute(context,ruleExpressionLength)%>,'LExp','RuleLeft','leftEx')" src="../common/images/iconSmallNewWindow.png" />
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
                 <input type="button" name="l-paren" value="(" onclick='operatorInsert("(","left"),computedRule("(","left","same")' />
                  <input type="button" name="and" value="AND" onclick='operatorInsert("AND","left"),computedRule("AND","left","same")' />
                  <input type="button" name="or" value="OR" onclick='operatorInsert("OR","left"),computedRule("OR","left","same")' />
                  <input type="button" name="not" value="NOT" onclick='operatorInsert("NOT","left"),computedRule("NOT","left","same")' />
                  <input type="button" name="r-paren" value=")" onclick='operatorInsert(")","left"),computedRule(")","left","same")' />
               </td>
            </tr>
          </table>
         </div><!-- /.operators -->
    
         <div class="object-manipulation clearfix">
           
            <div class="button"><a href="#" onclick="removeExp('left'),computedRule('','left','same')" class="button-remove" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.Remove</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#" onclick="insertFeatureOptions('left','same'),computedRule('','left','same')" class="button-insert" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.Insert</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#"  onclick="moveUp('left'),computedRule('','left','same')" class="button-move-up" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.MoveUp</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#" onclick="moveDown('left'),computedRule('','left','same')" class="button-move-down" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.MoveDown</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button separator"><img src="../common/images/utilSpacer.gif" border="0" /></div>
            <div class="button"><a href="#" onClick="removeFeature('left'),computedRule('','left','same')" class="button-remove-feature" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.RemoveFeature</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#" onClick="removeFeatureOption('left'),computedRule('','left','same')" class="button-remove-option" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.RemoveOption</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#" onClick="clearAll('left'),computedRule('','left','same')" class="button-clear" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.ClearExpression</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
         </div><!-- /.object-manipulation -->

         <div class="terms" onscroll="OnDivScroll();">
          <select size="10" name="LeftExpression" multiple id="LExp"></select>
         </div><!-- /.terms -->
       </div><!-- /.body -->
    
        
    <input type="hidden" name="hleftExpObjIds" id="hleftExpObjIds" value="" />
    <input type="hidden" name="hleftExpObjTxt" id="hleftExpObjTxt" value="" />
    <input type="hidden" name="hleftExpObjIdsForEdit" id="hleftExpObjIdsForEdit" value="" />
    <input type="hidden" name="hleftExpObjTxtForEdit" id="hleftExpObjTxtForEdit" value="" />
    
    <input type="hidden" name="hleftExpRCVal" id="hleftExpRCVal" value = "" />
    <input type="hidden" name="hleftExpFeatTypeVal" id="hleftExpFeatTypeVal" value = "" />

</div><!-- /.expression -->

<script>
   document.RuleForm.leftExpCheckBox.checked=true;
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



<%-- RRuleDialogLeftExpressionForPCR.jsp--%>

<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%-- Validation Includes --%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
	String strValidationJS = emxGetParameter(request,"validation");
	
	String strLabel = "";
	strLabel = "emxFramework.Label.Left_Expression"; 
	
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
                  <input type="button" name="or" value="OR" onclick='operatorInsert("OR","left"),computedRule("OR","left","same")' />
               </td>
            </tr>
          </table>
         </div><!-- /.operators -->
    
         <div class="object-manipulation clearfix">
            <div class="button"><a href="#" onclick="removeExp('left'),computedRule('','left','same')" class="button-remove" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.Remove</emxUtil:i18n>"></a></div>
            <div class="button"><a href="#" onclick="insertFeatureOptions('left','same'),computedRule('','left','same')" class="button-insert" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.Insert</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#"  onclick="moveUp('left'),computedRule('','left','same')" class="button-move-up" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.MoveUp</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button"><a href="#" onclick="moveDown('left'),computedRule('','left','same')" class="button-move-down" title="<emxUtil:i18n localize="i18nId">emxProduct.RuleTitle.MoveDown</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></div>
            <div class="button separator"><img src="../common/images/utilSpacer.gif" border="0" /></div>
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
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



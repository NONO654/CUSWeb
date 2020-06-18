<%--
  RuleDialogCompletedRule.jsp
  
--%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
 String strValidationJS = emxGetParameter(request,"validation");
%>
 <SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
String ruleExpressionLength = EnoviaResourceBundle.getProperty(context,"emxConfiguration.RuleDialogExpression.Expression.Length");
 %>

    <div id="RuleComplete" class="completed-rule">
      <div class="header">
        <table>
          <tr>
              <td class="section-title">
                 <emxUtil:i18n localize="i18nId">emxFramework.Label.CompletedRule</emxUtil:i18n>
              </td>
              <td class="buttons">
              <div id="RuleCompleteIcon">
                  <img onclick="showRuleCompleteDialog(<%=XSSUtil.encodeForHTMLAttribute(context,ruleExpressionLength)%>)" src="../common/images/iconSmallNewWindow.png" />
              </div> 
              </td>
         </tr>
       </table>
     </div>
           
     <div class="body">
          <div id="divRuleText">
         
     </div><!-- /#divRuleText -->
    </div>
   </div><!-- /.completed-rule -->

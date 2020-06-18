<%--
  RuleDialogBasicsForBCR.jsp
  
--%>


<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import = "java.util.Map"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import = "java.util.Locale"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@page import="com.matrixone.apps.common.util.AttributeUtil"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
String strmode = emxGetParameter(request,"modetype");
String strValidationJS = emxGetParameter(request,"validation");
%>
<SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
String strDefaultPolicy             = "" ;
String strEditPolicy                = "" ;
  String defaultRDO=PersonUtil.getDefaultOrganization(context, context.getUser());
  //String defaultRDO = "";
  String strName = "";
  String strEditRDO = "";
  String strContextObjectType = "";
  
  strName = emxGetParameter(request,"name");
  strEditRDO = emxGetParameter(request,"designResponsibility");
  //strDescriptionValue = emxGetParameter(request,"description");
  strContextObjectType = emxGetParameter(request, "ContextType");
  
    String[] strPolicies                = new String[10];
    int itemp                           = 0  ;
    
    // gets the Policy
    MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,
                                                                            ConfigurationConstants.TYPE_BOOLEAN_COMPATIBILITY_RULE,
                                                                            false);
%>

<script type="text/javascript" language="javascript">

     var txtQRRDO = null;
     var bRDOMultiSelect = false;
     var strTxtDR = "document.forms.['Basicform'].txtDR";
     var strDRValue ="document.forms.['Basicform'].txtDR.value";
     var strTxtVault = "document.forms.['Basicform'].txtVault";
     var strVaultValue ="document.forms.['Basicform'].txtVault.value";
     var vMode = "<%=XSSUtil.encodeForJavaScript(context,strmode)%>";
     var editValue = "<%=XSSUtil.encodeForJavaScript(context,com.matrixone.apps.domain.util.XSSUtil.encodeForHTML(context,strName))%>";
     function doValidateClear()
     {
         var choice = confirm("<%=i18nNow.getI18nString("emxProduct.DesignResponsibilityClear.ConfirmMessage", bundle,acceptLanguage)%> ");
         if (choice)
         {
           document.RuleForm.txtDRDisplay.value="";
           document.RuleForm.hDRId.value="";
           return true;
         }
     }
</script>
<%
for (ListIterator btlIt = policyList.listIterator(); btlIt.hasNext();) {
    strDefaultPolicy = (String) ((HashMap) policyList.get(itemp))
    .get(DomainConstants.SELECT_NAME);
    String strtm  = strDefaultPolicy;
    if (strtm != null)
    strPolicies[itemp] = strtm;
    btlIt.next();
}
%>

   <div class="body scrollable" id="divBasicsBody">
       
         <table class="form" >
          
          <tr>
              <td class="label required">
                <emxUtil:i18n localize="i18nId">emxFramework.Basic.Name </emxUtil:i18n>
              </td>
              <td class="inputField">
                 <% if ((strmode.compareTo("edit")==0)) {%>
                    <input type="text" name="txtRuleName" id="txtRuleName" onchange="isDuplicateName(vMode,editValue)" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>" />
                 <%}else{%>
                    <input type="text" name="txtRuleName" id="txtRuleName" value="" onchange="isDuplicateName(vMode)" disabled>
                    <input type="checkbox" name="autoName" onClick="checkName()" checked><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
                 <%} %>
                 <input type="hidden" name="hiddenRuleName" value="" />
               </td>
          </tr>
                 
          <tr>
              <td class="label" >
                <emxUtil:i18n localize="i18nId">emxProduct.Label.RuleType</emxUtil:i18n>
              </td>
              <td class="input">
                 <select name="ruleClassification" id="ruleClassification" onchange="modifyRuleClassification()">
                  <%
                  HashMap blankMap = new HashMap();
                  boolean showDesignRuleUX = (boolean) JPO.invoke(context, "emxPLCCommonBase", null, "showDesignRuleUX", JPO.packArgs(blankMap), Boolean.class );
                  String strAttrRuleClassification    = PropertyUtil.getSchemaProperty(context, "attribute_RuleClassification");
                  StringList slAttrRuleClassification = mxAttr.getChoices(context, strAttrRuleClassification);
                  String strLanguage = request.getHeader("Accept-Language");
                  MapList ml = AttributeUtil.sortAttributeRanges(context, strAttrRuleClassification, slAttrRuleClassification, strLanguage);
                  for(int i=0; i<ml.size(); i++)
                  {
                  Map choiceMap = (Map) ml.get(i);
                  %>        
                   <% if(((String) choiceMap.get("choice")).equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_CONFIGURATION)){
                	   if(strContextObjectType!=null && !mxType.isOfParentType(context, strContextObjectType,ConfigurationConstants.TYPE_LOGICAL_STRUCTURES)){%>
                		   <option  value ="<xss:encodeForHTMLAttribute><%=(String) choiceMap.get("choice")%></xss:encodeForHTMLAttribute>" selected > <%=XSSUtil.encodeForHTML(context,(String) choiceMap.get("translation"))%></option>
                	   <%}%>
                    <%}else if(showDesignRuleUX && ((String) choiceMap.get("choice")).equalsIgnoreCase("Logical") && !UINavigatorUtil.isCloud(context)){%>
                        <option  value ="<xss:encodeForHTMLAttribute><%=(String) choiceMap.get("choice")%></xss:encodeForHTMLAttribute>" > <%=XSSUtil.encodeForHTML(context,(String) choiceMap.get("translation"))%></option>
                    <%}
                  }
                  %>
                 </select>
               </td>
           </tr>
           
          <tr>
            <td class="label"><emxUtil:i18n localize="i18nId">emxProduct.Basic.Mandatory</emxUtil:i18n></td> 
              <td  class="input">
                <select name="mandatory" id="mandatory">
                    <option value="Yes"><emxUtil:i18n localize="i18nId">emxProduct.attribute.Mandatory.Range.Yes</emxUtil:i18n></option>
                    <option value="No" selected ><emxUtil:i18n localize="i18nId">emxProduct.attribute.Mandatory.Range.No</emxUtil:i18n></option>
                </select>
              </td>
           </tr>
             
                <tr>
                    <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n></td>
                    <td class="inputField">
                      <textarea name="txtDescription"></textarea>
                    </td>
                </tr>
    
                <tr>
                    <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Attribute.ErrorMessage</emxUtil:i18n></td>
                    <td class="inputField">
                       <textarea name="txtErrorMsg"></textarea>
                    </td>
                </tr>
                
                <tr>
                   <td class="label"><emxUtil:i18n localize="i18nId">emxProduct.Heading.DesignResponsibility</emxUtil:i18n></td>
                     <td class="inputField">
                   <table >
                        <tr>
                           <td>
                             <input type="text" name="txtDRDisplay" id="txtDRDisplay" readonly value="<xss:encodeForHTMLAttribute><%=(strEditRDO==null || strEditRDO.length()==0)?defaultRDO: strEditRDO%></xss:encodeForHTMLAttribute>" /></td>
                           <td>
                             <input type="hidden" name="hDRId" id="hDRId" value="" />
                             <input type="button" name="btnRD" value="..." onClick="javascript:showDRSelector(txtDRDisplay,txtDRId);" />
                             <input type="hidden" name="txtDRId" value="" />
                           </td>
                        </tr>
                      </table>
                   </td>
               </tr>
               
              <tr>
               <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Policy</emxUtil:i18n></td>
                 <td class="input">
                 <select name="selPolicy" id="selPolicy"></select> 
                  <%
                    String strNamev = null;
                    String strIdv = null;
                    boolean bSelected = false;
                    boolean bDefault = false;
                    boolean isedit = false;
                    int iTempvar = 0;
       
                    for (iTempvar = 0; iTempvar < strPolicies.length;)
                    {
                        if (strPolicies[iTempvar] != null)
                        {
                          strNamev = strPolicies[iTempvar];
                          strIdv = strPolicies[iTempvar];
                          if (strNamev.compareTo(strEditPolicy) == 0)
                                bSelected = true;
                          if (iTempvar == 0)
                                bDefault = true;
                          String languageStr = context.getSession().getLanguage();
                          String formattedPolicy = i18nNow.getAdminI18NString("Policy", strNamev, languageStr);
                          %>
                          <script language="JavaScript">
                              var vselcontext = document.getElementById('selPolicy');
                              vselcontext.options['<%=iTempvar%>']=new Option("<%=XSSUtil.encodeForJavaScript(context,formattedPolicy)%>", '<%=XSSUtil.encodeForJavaScript(context,strIdv)%>', false, false);
							  //XSSOK
                              if(<%=bSelected%> && <%=isedit%>){
                              vselcontext.options['<%=iTempvar%>']=new Option("<%=XSSUtil.encodeForJavaScript(context,formattedPolicy)%>", '<%=XSSUtil.encodeForJavaScript(context,strIdv)%>', true, true);
                              }
                              //XSSOK
                              if(!<%=isedit%> && <%=bDefault%>){
                                 vselcontext.options['<%=iTempvar%>']=new Option("<%=XSSUtil.encodeForJavaScript(context,formattedPolicy)%>", '<%=XSSUtil.encodeForJavaScript(context,strIdv)%>', true, true);
                              }
                          </script> 
                      <%}
                        iTempvar++;
                    }
                   %>  
                </td>
               </tr>

            </table>
        
    <input type="hidden" name="hfeatureType" value = "" />
    <input type="hidden" name="hMandatory"  id="hMandatory" value = "" />
     </div>

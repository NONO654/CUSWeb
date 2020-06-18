<%--
  RuleDialogBasicsForMPR.jsp
  
--%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import = "java.util.Map"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.configuration.BooleanOptionCompatibility"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
String strmode = emxGetParameter(request,"modetype");
String strValidationJS = emxGetParameter(request,"validation");
%>
<SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
String strDefaultPolicy             = "" ;
String strEditPolicy                = "" ;

	String strEditRDO = "";
	String[] strPolicies                = new String[10];
	String defaultRDO=PersonUtil.getDefaultOrganization(context, context.getUser());
	int itemp                           = 0  ;
	String strName = "";
	String strObjectId = "";
	// gets the Policy
	MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,
	                                                                        ConfigurationConstants.TYPE_MARKETING_PREFERENCE,
	                                                                        false);

if((strmode.compareTo("edit")==0) || (strmode.compareTo("copy")==0)){
    
	//getting the BCR Object Id
    strObjectId = emxGetParameter(request, "objectId");
    BooleanOptionCompatibility boBean = new BooleanOptionCompatibility();
    Map boCompatibilityAtributeMap = boBean.getBooleanCompatibilityDetails(context,strObjectId);
    
    strName               = (String)boCompatibilityAtributeMap.get(DomainConstants.SELECT_NAME);
}
%>

<script type="text/javascript" language="javascript">

     var txtQRRDO = null;
     var bRDOMultiSelect = false;
     var strTxtDR = "document.forms.['Basicform'].txtDR";
     var strDRValue ="document.forms.['Basicform'].txtDR.value";
     var strTxtVault = "document.forms.['Basicform'].txtVault";
     var strVaultValue ="document.forms.['Basicform'].txtVault.value";
     var editValue = "<%=XSSUtil.encodeForJavaScript(context,strName)%>";
     var vMode = "<%=XSSUtil.encodeForJavaScript(context,strmode)%>";
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
                 <% if((strmode.compareTo("edit")==0)) {%>
                 <input type="text" name="txtRuleName" id="txtRuleName" onchange="isDuplicateName(vMode,editValue)" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>" />
                 <%}else{%>
                 <input type="text" name="txtRuleName" id="txtRuleName" value="" onchange="isDuplicateName(vMode)" disabled />
				 <input type="hidden" name="hiddenRuleName" value="" />
                 <input type="checkbox" name="autoName" onClick="checkName()" checked /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
                 <%} %>
              </td>
          </tr>
                 
          <tr>
            <td class="label"><emxUtil:i18n localize="i18nId">emxProduct.Basic.Mandatory</emxUtil:i18n></td> 
              <td  class="input">
                <select name="mandatory" id="mandatory">
                    <option value="No" selected><emxUtil:i18n localize="i18nId">emxProduct.attribute.Mandatory.Range.No</emxUtil:i18n></option>
                    <option value="Yes"><emxUtil:i18n localize="i18nId">emxProduct.attribute.Mandatory.Range.Yes</emxUtil:i18n></option>
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
        
    <input type="hidden" name="hfeatureType" value="" />
    <input type="hidden" name="hMandatory"  id="hMandatory" value="" />
    <input type="hidden" name="hRuleId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
     </div>

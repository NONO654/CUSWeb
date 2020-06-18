<%--
  RuleDialogBasicsForQuantityRule.jsp
  --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import = "java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
String strmode = emxGetParameter(request,"modetype");
String strValidationJS = emxGetParameter(request,"validation");
String strName = emxGetParameter(request,"name");
%>

<SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>
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
String strContextObjectId="";
String strDefaultPolicy             = "" ;
String strEditPolicy                = "" ;
String defaultRDO = "";
String defaultRDOId = "";
String strEditRDO = "";
String strEditQuantity = "";
String strEditVault = "";

if ((strmode.compareTo("create")==0)){
    strContextObjectId  = emxGetParameter(request,"objectId");
}else if ((strmode.compareTo("edit")==0)){
	strEditQuantity = emxGetParameter(request,"Quantity");
	strEditRDO = emxGetParameter(request,"Design Responsibility");
    strContextObjectId  = emxGetParameter(request,"parentOID");
    String strRulId=emxGetParameter(request,"objectId");
    DomainObject domObj=new DomainObject(strRulId);   
    strEditVault=domObj.getInfo(context, ConfigurationConstants.SELECT_VAULT);
}else if ((strmode.compareTo("copy")==0)){
    strContextObjectId  = emxGetParameter(request,"productID");             
}
  
	ProductLineCommon plcBean = new ProductLineCommon();
	defaultRDOId = plcBean.getDefaultRDO(context,strContextObjectId);

	 if (defaultRDOId != null && !"".equals(defaultRDOId)){
	 DomainObject domdefaultRdo = new DomainObject(defaultRDOId);
	 defaultRDO = domdefaultRdo.getInfo(context,DomainConstants.SELECT_NAME);   
	 }else{
	     defaultRDO = "";
	 }
	 
	String formattedstrEditVault ="";
	
	String[] strPolicies                = new String[10];
	
	int itemp                           = 0  ;
	
	
	// gets the Policy
	MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,
	                                                                        ConfigurationConstants.TYPE_QUANTITY_RULE,
	                                                                        false);
matrix.db.Vault defaultVault=context.getVault();
String formattedDefaultVault=i18nNow.getI18NVaultNames(context, defaultVault.toString(),request.getHeader("Accept-Language") );

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
                  <input type="text" name="txtRuleName" id="txtRuleName" value="" onchange="isDuplicateName(vMode)" />
                  <input type="checkbox" name="autoName" onClick="checkName()" /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
                  <%} %>
                  
                 </td>
                </tr>
                 
                <tr>
                    <td class="label required"><emxUtil:i18n localize="i18nId">emxFramework.Label.Usage_Quantity</emxUtil:i18n></td>
                    <td class="inputField"><input type="text" name="txtquantity" id="txtquantity" onchange="displayComputedRule('<%=strmode%>')" value="<xss:encodeForHTMLAttribute><%=strEditQuantity %></xss:encodeForHTMLAttribute>" /></td>
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
                             <a class="dialogClear" href="#" onclick="javascript:doValidateClear();">
                                <emxUtil:i18n localize="i18nId">emxProduct.Button.Clear</emxUtil:i18n>
                             </a>
                           </td>
                        </tr>
                      </table>
                   </td>
               </tr>


               <tr>
                  <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Vault</emxUtil:i18n></td>
                    <td class="inputField">
                  <table >
                         <tr>
                          <td>
                            <input type="text" name="txtVaultDisplay" readonly value="<xss:encodeForHTMLAttribute><%=(formattedstrEditVault==null || formattedstrEditVault.length()==0)?formattedDefaultVault: formattedstrEditVault%></xss:encodeForHTMLAttribute>" />
                          </td>
                          <td>
                            <input type="hidden" name="hVaultID" value="<xss:encodeForHTMLAttribute><%=(strEditVault==null || strEditVault.length()==0)?defaultVault.toString(): strEditVault%></xss:encodeForHTMLAttribute>" />
                            <input type="button" name="btnVault" value="..." onClick="javascript:showVaultSelector();" /> 
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
                              //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
                              vselcontext.options['<%=iTempvar%>']=new Option("<%=formattedPolicy%>", '<%=strIdv%>', false, false);
                              //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
                              if(<%=bSelected%> && <%=isedit%>){
                              //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
                              vselcontext.options['<%=iTempvar%>']=new Option("<%=formattedPolicy%>", '<%=strIdv%>', true, true);
                              }
                            //XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
                              if(!<%=isedit%> && <%=bDefault%>){
                            	//XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.
                                 vselcontext.options['<%=iTempvar%>']=new Option("<%=formattedPolicy%>", '<%=strIdv%>', true, true);
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
    <input type="hidden" name="hMandatory" value="" />
    
     </div>

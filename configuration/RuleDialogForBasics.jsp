<%--
  RuleDialogForBasics.jsp
  
--%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import = "java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import = "java.util.Locale"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
String strValidationJS = emxGetParameter(request,"validation");
%>
<SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
//Edit details
String formattedstrEditVault ="";
String strEditVault = "";
String strDefaultPolicy = "";
String strEditPolicy                = "" ;

MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,
                                                                       ConfigurationConstants.TYPE_BOOLEAN_COMPATIBILITY_RULE,
                                                                       false);
String[] strPolicies                = new String[10];
int itemp                           = 0  ;
Locale Local = request.getLocale();

for (ListIterator btlIt = policyList.listIterator(); btlIt.hasNext();) {
    strDefaultPolicy = (String) ((HashMap) policyList.get(itemp))
    .get(DomainConstants.SELECT_NAME);
    String strtm  = strDefaultPolicy;
    if (strtm != null)
    strPolicies[itemp] = strtm;
    btlIt.next();
}
 
matrix.db.Vault defaultVault=context.getVault();
String formattedDefaultVault=i18nNow.getI18NVaultNames(context, defaultVault.toString(),request.getHeader("Accept-Language") );

%>

<html>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
   <title>Rule Builder</title>
   <link rel="stylesheet" type="text/css" media="screen" href="../configuration/styles/emxUIExpressionBuilder.css" />
   <link rel="stylesheet" type="text/css" media="screen" href="../common/styles/emxUIStructureBrowser.css" />
   <link rel="stylesheet" type="text/css" media="screen" href="../configuration/styles/emxUIRuleLayerDialog.css" />
        
       <div class="mx_form" name="basics" style = "width: 100%;">
         <table border="0" class="mx_form" cellpadding="0" cellspacing="0" width="100%">
		  <tr>
		      <td class="label required"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Name </emxUtil:i18n></td>
		          <td class="inputField">
			           <input type="text" name="txtRuleName" value="" />
			           <input type="checkbox" name="autoName" /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
		      </td>
		  </tr>
	      <tr>
	          <td class="label required"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n></td>
	          <td class="inputField"><textarea name="txtDescription"></textarea></td>
	      </tr>
          <tr>
              <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Vault</emxUtil:i18n></td>
              <td class="inputField">
	              <table border="0" cellpadding="0" cellspacing="0">
	               <tr>
	                 <td>
	                    <input type="text" name="txtBCVaultDisplay" readonly value="<xss:encodeForHTMLAttribute><%=(formattedstrEditVault==null || formattedstrEditVault.length()==0)?formattedDefaultVault: formattedstrEditVault%></xss:encodeForHTMLAttribute>" />
	                 </td>
	                    <input type="hidden" name="txtBCVault" size="15" value="<xss:encodeForHTMLAttribute><%=(strEditVault==null || strEditVault.length()==0)?defaultVault.toString(): strEditVault%></xss:encodeForHTMLAttribute>" />
	                 <td>
	                    <input type="button" name="btnVault" value="..." onClick="javascript:showVaultSelector();" /><a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.RuleForm.txtBCVault.value='';">
	                 </td>
	               </tr>
	              </table>
              </td>
          </tr>
          
          <tr>
             <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Policy</emxUtil:i18n></td>
               <td class="inputField">
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
                          String formattedPolicy = i18nNow.getTypeI18NString (strNamev,Local.toString()).trim();
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
   </div>
       <input type="hidden" name="hfeatureType" value="" />
    <input type="hidden" name="hRuleType" value="" />
    <input type="hidden" name="hMandatory" value="" />
 </html>

 



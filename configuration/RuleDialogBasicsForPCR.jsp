<%--
  RuleDialogBasicsForPCR.jsp
  --%>


<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import = "java.util.HashMap"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>

<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>
<script language="javascript" src="../configuration/scripts/HashMap.js"></script>
<%
String strmode = emxGetParameter(request,"modetype");
String strValidationJS = emxGetParameter(request,"validation");
String strName = "";
strName = emxGetParameter(request,"name");
%>

<SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>
<script type="text/javascript" language="javascript">
     var editValue = "<%=XSSUtil.encodeForJavaScript(context,strName)%>";
     var vMode = "<%=XSSUtil.encodeForJavaScript(context,strmode)%>";
</script>
<%
	String strDefaultPolicy             = "" ;
	String strEditPolicy                = "" ;
	String[] strPolicies                = new String[10];
	int itemp                           = 0  ;
	
	// gets the Policy
	MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,
	                                                                        ConfigurationConstants.TYPE_PRODUCT_COMPATIBILITY_RULE,
	                                                                        false);
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
				 <input type="hidden" name="hiddenRuleName" value="" />
                 <input type="checkbox" name="autoName" onClick="checkName()" /><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
                 <%} %>
                 
              </td>
          </tr>
                 

                <tr>
                    <td class="label required"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n></td>
                    <td class="inputField">
                      <textarea name="txtDescription" id="txtDescription" ></textarea>
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
     </div>

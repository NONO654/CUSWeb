
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><HTML>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxConfigurationStringResource" locale='<%=XSSUtil.encodeForHTMLAttribute(context,request.getHeader("Accept-Language"))%>' />

  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
                                
      function doLoad() {
        if (document.forms[0].elements.length > 0) {
          var objElement = document.forms[0].elements[0];
                                                                
          if (objElement.focus) objElement.focus();
          if (objElement.select) objElement.select();
        }
      }
    </SCRIPT>
  </HEAD>
 <%
        String ruledisplay="";
		String ruledisplayFullNameSelected="";
		String ruledisplayMarketingNameSelected="";
		// Added for IR Mx361175
		String ruledisplayMarketingNameAndRevisionSelected = "";
                
		ruledisplay=PersonUtil.getRuleDisplayPreference(context);
        if( (ruledisplay == null) || (ruledisplay.equals("null")) || (ruledisplay.equals("")))
        {  
        	ruledisplayMarketingNameAndRevisionSelected = "checked";
        }
        else if(ruledisplay.equals(ConfigurationConstants.RULE_DISPLAY_FULL_NAME))
        {
        	ruledisplayFullNameSelected="checked";
        }
        // Modified condition for IR Mx361175
        else if(ruledisplay.equals(ConfigurationConstants.RULE_DISPLAY_MARKETING_NAME))
        {
            ruledisplayMarketingNameSelected="checked";
        }
        // Added else block for IR Mx361175
         else if(ruledisplay.equals(ConfigurationConstants.RULE_DISPLAY_MARKETING_NAME_REV)){
        	ruledisplayMarketingNameAndRevisionSelected = "checked";
        }
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="emxPrefRuleDisplayProcessing.jsp">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxProduct.Preferences.RuleDisplay</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                                <td><input type="radio" name="prefRuleDisplay" id="prefRuleDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.RULE_DISPLAY_MARKETING_NAME %></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=ruledisplayMarketingNameSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.RuleDisplayPreference.MarketingName</emxUtil:i18n></td>
                        </tr>
                        <!-- Start -Added for IR Mx361175  -->
                        <tr>
                        <td><input type="radio" name="prefRuleDisplay" id="prefRuleDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.RULE_DISPLAY_MARKETING_NAME_REV %></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=ruledisplayMarketingNameAndRevisionSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.RuleDisplayPreference.MarketingNameandRev</emxUtil:i18n></td>
                        </tr>
                        <!-- End -Added for IR Mx361175  -->
                        <tr>
                        <td><input type="radio" name="prefRuleDisplay" id="prefRuleDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.RULE_DISPLAY_FULL_NAME %></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=ruledisplayFullNameSelected%></xss:encodeForHTMLAttribute>><emxUtil:i18n localize="i18nId">emxProduct.RuleDisplayPreference.FullName</emxUtil:i18n></td>
                        </tr>
                        
                </table>
            </td>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>


<%--  emxPrefProductConfiguratorMode.jsp   - The Dialog Page for setting the Product Configurator Mode

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
   static const char RCSID[] = $Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/emxPrefProductConfiguratorMode.jsp 1.2.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$
--%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><HTML>

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
        String sProductConfiguratorModeDisplay="";
		String productConfiguratorModeInteractiveSelected="";
		String productConfiguratorModeNonInteractiveSelected="";
                
		sProductConfiguratorModeDisplay=PersonUtil.getProductConfigurationModePreference(context);
		if( (sProductConfiguratorModeDisplay.equals("")) || (sProductConfiguratorModeDisplay.equals("InteractiveMode")))
        {  
            productConfiguratorModeInteractiveSelected="checked";
        }        
        else
        {
            productConfiguratorModeNonInteractiveSelected="checked";
        }                
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="emxPrefProductConfiguratorModeProcessing.jsp">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxProduct.Preferences.ProductConfiguratorMode</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                                <td><input type="radio" name="prefProductConfiguratorMode" id="prefProductConfiguratorMode" value="InteractiveMode" <xss:encodeForHTMLAttribute><%=productConfiguratorModeInteractiveSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.ProductConfiguratorModePreference.InteractiveMode</emxUtil:i18n></td>
                        </tr>
                        <tr>
                        <td><input type="radio" name="prefProductConfiguratorMode" id="prefProductConfiguratorMode" value="NonInteractiveMode" <xss:encodeForHTMLAttribute><%=productConfiguratorModeNonInteractiveSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.ProductConfiguratorModePreference.NonInteractiveMode </emxUtil:i18n></td>
                        </tr>
                </table>
            </td>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>


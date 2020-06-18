<%--
  emxPrefFeatureNameDisplay.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<HTML>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<!-- XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.-->
<emxUtil:localize id="i18nId" bundle="emxConfigurationStringResource" locale='<%=request.getHeader("Accept-Language")%>' />

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
        String featuredisplay="";
		String featuredisplayObjectNameSelected="";
		String featuredisplayMarketingNameSelected="";
                
        featuredisplay=PersonUtil.getFeatureNameDisplayPreference(context);
        if( (featuredisplay == null) || (featuredisplay.equalsIgnoreCase("null")) || (featuredisplay.equalsIgnoreCase("")) || (featuredisplay.equalsIgnoreCase(ConfigurationConstants.FEATURE_DISPLAY_OBJECT_NAME)))
        {
           featuredisplayObjectNameSelected="checked";
        }
        else
        {
            featuredisplayMarketingNameSelected="checked";
        }
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="emxPrefFeatureNameDisplayProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxProduct.Preferences.FeatureNameDisplay</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                                <td><input type="radio" name="prefFeatureDisplay" id="prefFeatureDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.FEATURE_DISPLAY_MARKETING_NAME%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=featuredisplayMarketingNameSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.FeatureDisplayPreference.MarketingName</emxUtil:i18n></td>
                        </tr>
                        <tr>
                        <td><input type="radio" name="prefFeatureDisplay" id="prefFeatureDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.FEATURE_DISPLAY_OBJECT_NAME%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=featuredisplayObjectNameSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.FeatureDisplayPreference.ObjectName</emxUtil:i18n></td>
                        </tr>
                </table>
            </td>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>


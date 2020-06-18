<%--
  PreferenceTreeNameDisplay.jsp

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>



<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><HTML>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>

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
        String treedisplayPref="";
    	String treedisplayObjectNameRevSelected="";
        String treedisplayMarketingNameAndRevSelected="";
        String treedisplayMarketingNameTypeRevSelected="";
                
		treedisplayPref=PersonUtil.getTreeDisplayPreference(context);		
		
       if( (treedisplayPref == null) || (treedisplayPref.equalsIgnoreCase("null")) || (treedisplayPref.equalsIgnoreCase("")))
        {
        	//treedisplayFullNameSelected="checked";
         }
       else if(treedisplayPref.equalsIgnoreCase(ConfigurationConstants.TREE_DISPLAY_OBJECT_NAME_REV)){
    	   treedisplayObjectNameRevSelected="checked";  
       }
        else if((treedisplayPref.equalsIgnoreCase(ConfigurationConstants.TREE_DISPLAY_MARKETING_NAME_TYPE_REV)))
        {
        	treedisplayMarketingNameTypeRevSelected="checked";
         }
        else if((treedisplayPref.equalsIgnoreCase(ConfigurationConstants.TREE_DISPLAY_MARKETING_NAME_REV)))
        {
        	treedisplayMarketingNameAndRevSelected="checked";
         }      
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="PreferenceTreeNameDisplayProcessing.jsp">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxProduct.Preferences.TreeNameDisplay</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                        <td><input type="radio" name="prefTreeNameDisplay" id="prefTreeNameDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.TREE_DISPLAY_OBJECT_NAME_REV%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=treedisplayObjectNameRevSelected%></xss:encodeForHTMLAttribute>><emxUtil:i18n localize="i18nId">emxProduct.TreeDisplayPreference.ObjectNameRev</emxUtil:i18n></td>
                        </tr>
                        
                        <tr>
                        <td><input type="radio" name="prefTreeNameDisplay" id="prefTreeNameDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.TREE_DISPLAY_MARKETING_NAME_REV%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=treedisplayMarketingNameAndRevSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.TreeDisplayPreference.MarketingNameRev</emxUtil:i18n></td>
                        </tr>
                        
                        <tr>
                        <td><input type="radio" name="prefTreeNameDisplay" id="prefTreeNameDisplay" value="<xss:encodeForHTMLAttribute><%=ConfigurationConstants.TREE_DISPLAY_MARKETING_NAME_TYPE_REV%></xss:encodeForHTMLAttribute>" <xss:encodeForHTMLAttribute><%=treedisplayMarketingNameTypeRevSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxProduct.TreeDisplayPreference.MarketingNameTypeRev</emxUtil:i18n></td>
                        </tr>
                </table>
            </td>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>


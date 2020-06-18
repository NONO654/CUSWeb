<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
      are added under respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview HAT1 ZUD 19 Apr 2017 : TSK3278161 - R419: Deprecation of functionalities to clean up.( "Specification Structure" preference should remove derived requirement options)
--%>
<HTML>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsUtil"%>

<emxUtil:localize id="i18nId" bundle="emxRequirementsStringResource" locale='<%=request.getHeader("Accept-Language")%>' />

  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no">
    <META http-equiv="pragma" content="no-cache">
    <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
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
    	
  %>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" action="emxPrefExtendedSpecTreeProcessing.jsp">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
          	<emxUtil:i18n localize="i18nId">emxRequirements.Heading.StructureCompare</emxUtil:i18n>
          </TD>
          <td class="inputField">
            <table>
                <tr>
	                <td>
	                	<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_STRUCTURE_COMPARE_INC_SUB_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_STRUCTURE_COMPARE_INC_SUB_REQ) ? "checked" : ""%> />
	                	<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeSubRequirements</emxUtil:i18n>
	                </td>
                </tr>
				<%-- <tr> // ++ HAT1 ZUD TSK3278161 ++ 
                	<td>
                		<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_STRUCTURE_COMPARE_INC_DERIVED_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_STRUCTURE_COMPARE_INC_DERIVED_REQ) ? "checked" : "" %> />
                		<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeDerivedRequirements</emxUtil:i18n>
                	</td>
                </tr> // -- HAT1 ZUD TSK3278161 --  
                --%> 
            </table>
          </td>
        </TR>
        <TR>
          <TD width="150" class="label">
          	<emxUtil:i18n localize="i18nId">emxRequirements.Heading.RequirementTestCaseTraceability</emxUtil:i18n>
          </TD>
          <td class="inputField">
            <table>
                <tr>
	                <td>
	                	<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_REPORT_REQ_TESTCASE_INC_SUB_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_TESTCASE_INC_SUB_REQ) ? "checked" : ""%>  />
	                	<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeSubRequirements</emxUtil:i18n>
	                </td>
                </tr>
                <%-- <tr> // ++ HAT1 ZUD TSK3278161 ++ 
                	<td>
                		<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_REPORT_REQ_TESTCASE_INC_DERIVED_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_TESTCASE_INC_DERIVED_REQ) ? "checked" : "" %> />
                		<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeDerivedRequirements</emxUtil:i18n>
                	</td>
                </tr> // -- HAT1 ZUD TSK3278161 --  
                --%>  
            </table>
          </td>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.RequirementFeatureTraceability</emxUtil:i18n>
          </TD>
          <td class="inputField">
            <table>
                <tr>
	                <td>
	                	<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_REPORT_REQ_FEATURE_INC_SUB_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_FEATURE_INC_SUB_REQ) ? "checked" : ""%> />
	                	<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeSubRequirements</emxUtil:i18n>
	                </td>
                </tr>
                <%-- <tr>  // ++ HAT1 ZUD TSK3278161 ++ 
                	<td>
                		<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_REPORT_REQ_FEATURE_INC_DERIVED_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_FEATURE_INC_DERIVED_REQ) ? "checked" : "" %> />
                		<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeDerivedRequirements</emxUtil:i18n>
                	</td>
                </tr>// -- HAT1 ZUD TSK3278161 --  
                --%>  
            </table>
          </td>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.DeleteChildren</emxUtil:i18n>
          </TD>
          <td class="inputField">
            <table>
                <tr>
	                <td>
	                	<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_DELETE_CHILDREN_INC_SUB_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_DELETE_CHILDREN_INC_SUB_REQ) ? "checked" : ""%> />
	                	<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeSubRequirements</emxUtil:i18n>
	                </td>
                </tr>
                <%-- <tr>  // ++ HAT1 ZUD TSK3278161 ++ 
                	<td>
                		<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_DELETE_CHILDREN_INC_DERIVED_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_DELETE_CHILDREN_INC_DERIVED_REQ) ? "checked" : "" %> />
                		<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeDerivedRequirements</emxUtil:i18n>
                	</td>
                </tr> // -- HAT1 ZUD TSK3278161 --  
                --%>  
            </table>
          </td>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.ReserveUnreserve</emxUtil:i18n>
          </TD>
          <td class="inputField">
            <table>
                <tr>
	                <td>
	                	<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_RESERVE_INC_SUB_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_RESERVE_INC_SUB_REQ) ? "checked" : ""%> />
	                	<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeSubRequirements</emxUtil:i18n>
	                </td>
                </tr>
                <%-- <tr>   // ++ HAT1 ZUD TSK3278161 ++ 
                	<td>
                		<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_RESERVE_INC_DERIVED_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_RESERVE_INC_DERIVED_REQ) ? "checked" : "" %> />
                		<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeDerivedRequirements</emxUtil:i18n>
                	</td>
                </tr>  // -- HAT1 ZUD TSK3278161 --  
                --%>   
            </table>
          </td>
        </TR>
        <%if(RequirementsUtil.isVPMInstalled(context)) {%>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.RFLPTraceability</emxUtil:i18n>
          </TD>
          <td class="inputField">
            <table>
                <tr>
	                <td>
	                	<input type="checkbox" name="<xss:encodeForHTMLAttribute><%=RequirementsCommon.PREF_RFLP_INC_SUB_REQ%></xss:encodeForHTMLAttribute>" <%=RequirementsCommon.getBooleanPreference(context, RequirementsCommon.PREF_RFLP_INC_SUB_REQ) ? "checked" : ""%> />
	                	<emxUtil:i18n localize="i18nId">emxRequirements.Label.IncludeSubRequirements</emxUtil:i18n>
	                </td>
                </tr>
            </table>
          </td>
        </TR>
        <% } %>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>


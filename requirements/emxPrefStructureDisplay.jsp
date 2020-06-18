<%-- @quickreview T25 OEP 	12:12:10  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet
     @quickreview T25 OEP 	12:12:18  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview OEP DJH 	13:02:28  IR-218082V6R2014 Removing code for Default View section, since now we only have a single view. 
     @quickreview T25 DJH 	13:10:18  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview JX5		14:05:06  IR-297423-3DEXPERIENCER2015x On "Preferences" window, In "Structure Display" sub section "Requirement" drop down list does not display "Granted" option for selection. 
     @quickreview HAT1 ZUD	17:04:19  HL ENOVIA_GOV_RMT Deprecation of functionalities to clean up - Structure display preference has a wrong label, this needs to be corrected.Replacing emxRequirements.Heading.DefaultSpecListFilter with emxRequirements.Heading.DefaultReqListFilter. 	
     @quickreview      ZUD	18:09:18  IR-628688-3DEXPERIENCER2019x : TVTZ:Ja/Ch/Fr/Ge:R2019x:3DSpace:Untranslated text_All 
--%>
<HTML>
<%@ page import="com.matrixone.apps.requirements.ui.*,java.text.*"%> 
<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxRequirementsStringResource" locale='<%= request.getHeader("Accept-Language")%>' />
<jsp:useBean id="tableBean" class="com.matrixone.apps.requirements.ui.UITableRichText" scope="page"/> 
  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
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
      function getSelectedSpecListFilter(Element)
      {
    	  selectedSpecListFilter = Element;
      }
      function getSelectedReqListFilter(Element)
      {
    	  selectedReqListFilter = Element;
      }
      function getSelectedSpecFilter(Element)
      {
    	  selectedSpecFilter = Element;
      }
      
      function getSelectedReqFilter(Element)
      {
    	  selectedReqFilter = Element;
      }    
      function getSelectedSpecTable(Element)
      {
    	  selectedSpecTable = Element;
      }
      function getSelectedReqTable(Element)
      {
    	  selectedReqTable = Element;
      }
      
    </SCRIPT>
  </HEAD>
 <%
        String structuredisplay="";
		String structuredisplaySBSelected="";
		String structuredisplaySCESelected="";
                
		structuredisplay = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_StructureDisplay"); //PersonUtil.getRuleDisplay(context);
        if( (structuredisplay == null) || (structuredisplay.equals("null")) || (structuredisplay.equals("")) || (structuredisplay.equals("sb")))
        {  
        	structuredisplaySBSelected="checked";
        }
        else if(structuredisplay.equals("sce"))
        {
        	structuredisplaySCESelected="checked";
        }
  %>
  <BODY onload="doLoad(), turnOffProgress()">
  	<style type="text/css">
.sceheader{
	background-color: #31659C;
	color: white;
	font-weight: bold; 
}
TD.label{
	width: 60%;
}

	</style>
    <FORM method="post" action="emxPrefStructureDisplayProcessing.jsp">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>    	
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
<%
if(RequirementsUtil.isSCEUsed(context, new String[]{})){
%>
        <tr>
			<td class='sceheader' colspan='3'><emxUtil:i18n localize="i18nId">emxRequirements.SCE.Settings.Heading.DefaultEditor</emxUtil:i18n>:</td>
		  </tr>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.SCE.Settings.Heading.EditorSrtucture</emxUtil:i18n>
          </TD>
          <td class="inputField">
                <table>
                        <tr>
                        <td><input type="radio" name="prefStructureDisplay" id="prefStructureDisplay" value="sb" <xss:encodeForHTMLAttribute><%=structuredisplaySBSelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.ActionLink.SpecStructureBrowser</emxUtil:i18n></td>
                        </tr>
                        <tr>
                        <td><input type="radio" name="prefStructureDisplay" id="prefStructureDisplay" value="sce" <xss:encodeForHTMLAttribute><%=structuredisplaySCESelected%></xss:encodeForHTMLAttribute> /><emxUtil:i18n localize="i18nId">emxRequirements.SCE.Title</emxUtil:i18n></td>
                        </tr>
                        
                </table>
            </td>
        </TR>
<%
}
%>
        <TR>
          <tr>
			<td class='sceheader' colspan='3'><emxUtil:i18n localize="i18nId">emxRequirements.SCE.Settings.Heading.DefaultFilters</emxUtil:i18n>:</td>	
		  </tr>
		  <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.DefaultSpecListFilter</emxUtil:i18n>
          </TD>
          	<td class="inputField"><%-- Filter:  --%>  
          	<%
          	String selectedSpecListFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultSpecListFilter");
          	%>
				<select class="combo" name="selectedSpecListFilter" id="selectedSpecListFilter"  onchange="getSelectedSpecListFilter(this.options[this.selectedIndex].value)">
							<option <%="emxRequirementSpecification:getOwnedSpecsAndGroups".equals(selectedSpecListFilter)? "selected=\"selected\" " : ""%> value="emxRequirementSpecification:getOwnedSpecsAndGroups">  <emxUtil:i18n localize="i18nId">emxRequirements.Filter.Owned</emxUtil:i18n></option><%--XSSOK--%>
							<option <%="emxRequirementSpecification:getOwnedRequirementSpecifications".equals(selectedSpecListFilter)? "selected=\"selected\" " : ""%> value="emxRequirementSpecification:getOwnedRequirementSpecifications"><emxUtil:i18n localize="i18nId">emxRequirements.Filter.OwnedSpec</emxUtil:i18n></option><%--XSSOK--%>
							<option <%="emxRequirementSpecification:getAllSpecsAndGroups".equals(selectedSpecListFilter)? "selected=\"selected\" " : ""%> value="emxRequirementSpecification:getAllSpecsAndGroups"><emxUtil:i18n localize="i18nId">emxRequirements.Filter.All</emxUtil:i18n></option><%--XSSOK--%>
							<option <%="emxRequirementSpecification:getAllRequirementSpecifications".equals(selectedSpecListFilter)? "selected=\"selected\" " : ""%> value="emxRequirementSpecification:getAllRequirementSpecifications"><emxUtil:i18n localize="i18nId">emxRequirements.Filter.AllSpec</emxUtil:i18n></option><%--XSSOK--%>
				</select>
			</td>   
        </TR>
        <TR>
	        <TD width="150" class="label">
	            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.DefaultReqListFilter</emxUtil:i18n>
	          </TD>
	          	<td class="inputField"> 
	          	<%
	          	String selectedReqListFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultReqListFilter");
	          	%>
					<select class="combo" name="selectedReqListFilter" id="selectedReqListFilter"  onchange="getSelectedReqListFilter(this.options[this.selectedIndex].value)">
								<option  <%="emxRequirement:getOwnedRequirements".equals(selectedReqListFilter)? "selected=\"selected\" " : ""%> value="emxRequirement:getOwnedRequirements">  <emxUtil:i18n localize="i18nId">emxRequirements.Filter.Owned</emxUtil:i18n></option><%--XSSOK--%>
								<option  <%="emxRequirement:getGrantedRequirements".equals(selectedReqListFilter)? "selected=\"selected\" " : "" %> value="emxRequirement:getGrantedRequirements"><emxUtil:i18n localize="i18nId">emxRequirements.Filter.Granted</emxUtil:i18n></option><%--XSSOK--%>
								<option  <%="emxRequirement:getAllRequirements".equals(selectedReqListFilter)? "selected=\"selected\" " : ""%> value="emxRequirement:getAllRequirements"><emxUtil:i18n localize="i18nId">emxRequirements.Filter.All</emxUtil:i18n></option><%--XSSOK--%>
					</select>
				</td>  
		</TR>
		<tr>
			<td class='sceheader' colspan='3'><emxUtil:i18n localize="i18nId">emxRequirements.Heading.ExpandFilterOptions</emxUtil:i18n>:</td>
		  </tr>
		  <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxRequirements.Heading.ExpandFilterOptions</emxUtil:i18n>
          </TD>
          <%
          	String selectedexpandFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_expandFilter");
          if(selectedexpandFilter == null || selectedexpandFilter.isEmpty()){
        	  selectedexpandFilter = "All";
          }
          	%>
          <td class="inputField">
				<select name="emxExpandFilter" title="" style="width:50px;" id="emxExpandFilter" onchange="submitToolbarForm('javascript:selectMoreLevel()','popup','emxExpandFilter','812','500','structureBrowser','','','false','false','combobox','emxExpandFiltermxcommandcode')">
					<option <%=selectedexpandFilter.equals("1")? " selected='selected' " : ""%> value="1">1</option>
					<option <%=selectedexpandFilter.equals("2")? " selected='selected' " : ""%> value="2">2</option>
					<option <%=selectedexpandFilter.equals("3")? " selected='selected' " : ""%> value="3">3</option>
					<option <%=selectedexpandFilter.equals("4")? " selected='selected' " : ""%> value="4">4</option>
					<option <%=selectedexpandFilter.equals("5")? " selected='selected' " : ""%> value="5">5</option>
					<option <%=selectedexpandFilter.equals("All")? " selected='selected' " : ""%> value="All"><emxUtil:i18n localize="i18nId">emxRequirements.Filter.All</emxUtil:i18n></option>
				</select> 
			<br>
			<%
			String selectedExpandTypes = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_expandTypes");
	          if(selectedExpandTypes == null|| selectedExpandTypes.isEmpty()){
	        	  selectedExpandTypes = "SubRequirements,TestCases,Parameters";
	          }
			%>
			<input type="checkbox" <%=selectedExpandTypes.contains("SubRequirements")? " checked='yes' " : ""%> id="SubRequirements" name="SubRequirements" value="SubRequirements"> "<%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Label.SubRequirements")%>" <br>
			<input type="checkbox" <%=selectedExpandTypes.contains("TestCases")? " checked='yes' " : ""%> id="TestCases" name="TestCases" value="TestCases">"<%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Tree.TestCase")%>"<br>
			<input type="checkbox" <%=selectedExpandTypes.contains("Parameters")? " checked='yes' " : ""%> id="Parameters" name="Parameters" value="Parameters">"<%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Label.Parameters")%>"<br>
			</td>
		</TABLE>
    </FORM>
  </BODY>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</HTML>


<%--
  RuleDialogContextSelectorforPCR.jsp
  
--%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>

<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.configuration.RuleProcess"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>

<%
 String strValidationJS = emxGetParameter(request,"validation");
 String stateExclude=RuleProcess.getPolicyStateToExludeForRuleContext(context);
%>
 <SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
	String strmode = emxGetParameter(request,"modetype");
	String strContextObjectId = "";
	String strContextObjectType = emxGetParameter(request, "ContextType");
	
	String strContextNameDispaly= emxGetParameter(request, "ContextName");
	
    strContextObjectType = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, strContextObjectType, true);
	 
	 if ((strmode.compareTo("create")==0)){
	     strContextObjectId  = emxGetParameter(request,"objectId");
	 }
	 
	 if ((strmode.compareTo("edit")==0)){
	     strContextObjectId  = emxGetParameter(request,"parentOID");
	 }
	 
	 if ((strmode.compareTo("copy")==0)){
	     strContextObjectId  = emxGetParameter(request,"productID");             
	 }	 
  %>
 
 <script type="text/javascript" language="javascript">

 
 function setContext(){
     var sURL='../common/emxFullSearch.jsp?field=TYPES=type_HardwareProduct,type_SoftwareProduct,type_ServiceProduct,type_Model:CURRENT!=<%=XSSUtil.encodeForURL(context,stateExclude)%>&table=FTRSearchFeaturesTable&selection=single&formName=RuleForm&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?&mode=Chooser&chooserType=RuleContext&fieldNameActual=product&fieldNameDisplay=product';
     showChooser(sURL, 850, 630);
 } 

</script>  

   <div class="body" id="divFeatureSelectorBody">
    <div id="divFilter">
      <table>
	       <tr>
	         <td class="label"><emxUtil:i18n localize="i18nId">emxProduct.Basic.Context</emxUtil:i18n></td>
	       <td class="input">
	         <select name="product" id="product" onchange="selectorTable();">
	             <option value="<xss:encodeForHTMLAttribute><%=strContextObjectId%></xss:encodeForHTMLAttribute>" id="<%=strContextObjectType%>"><%=strContextNameDispaly%></option>
	          </select>
	       </td>
	       <td class="input" title="<emxUtil:i18n localize="i18nId">emxFramework.Basic.Search</emxUtil:i18n>"><a><img src="../common/images/iconActionSearch.gif" border="0" onclick="javascript:setContext();" /></a></td>
	       <td class="input">
	             <input 
	               name="filter" type="button" 
	               value="<emxUtil:i18n localize="i18nId">emxFramework.Label.Filter</emxUtil:i18n>" 
	               onclick="selectorTableFilter();" />
	       </td>
	      </tr>
      </table>
     </div>   
     <div id="divSourceList" ></div>    
  </div>



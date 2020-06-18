<%--
  RuleDialogContextSelectorForInclusionRule.jsp
  
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
%>
 <SCRIPT language="javascript" src="./scripts/<xss:encodeForHTMLAttribute><%=strValidationJS%></xss:encodeForHTMLAttribute>"></SCRIPT>

<%
    String strRule = emxGetParameter(request, "ruleType");
    String strmode = emxGetParameter(request,"modetype");
    String strContextObjectId = "";
    String strContextObjectType = emxGetParameter(request, "ContextType");
    String strContextParentType = emxGetParameter(request, "ContextParentType");
    String stateExclude=RuleProcess.getPolicyStateToExludeForRuleContext(context);
    String strContext = emxGetParameter(request,"context");
    String strContextNameDispaly="";
    
     strContextObjectType = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, strContextObjectType, true);
     strContextParentType = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, strContextParentType, true);
    
     if ((strmode.compareTo("create")==0)){
    	 if(strRule.equalsIgnoreCase("InclusionRule") && strContext!=null && strContext.equalsIgnoreCase("GBOM")){
             //context ID will be its parent ID(LF/PRD)-----
             strContextObjectId  = emxGetParameter(request,"parentOID");
             if(strContext.equalsIgnoreCase("GBOM")){
            	 strContextNameDispaly= emxGetParameter(request, "ContextParentNameDispaly");
             }else{
            	 strContextNameDispaly= emxGetParameter(request, "ContextName");
             }
         }else  if(strRule.equalsIgnoreCase("InclusionRule") && strContext==null){
             //context ID will be its parent ID(LF/PRD)-----
        	 strContextObjectId  = emxGetParameter(request,"parentOID");
             strContextNameDispaly=RuleProcess.getDisplayExpression(context,strContextObjectId,null).toString();
             
             //Map featureInfo=domFeature.getInfo(context,selectParObjList);
             //strContextNameDispaly= featureInfo.get(DomainObject.SELECT_TYPE)+" "+featureInfo.get(DomainObject.SELECT_NAME)+" "+featureInfo.get(DomainObject.SELECT_REVISION);
             //strContextNameDispaly= emxGetParameter(request, "ContextName");
         }else{
        	strContextObjectId  = emxGetParameter(request,"objectId");
        	strContextNameDispaly= emxGetParameter(request, "ContextName");
         }
     }
     
     if ((strmode.compareTo("edit")==0)){
         if(strRule.equalsIgnoreCase("InclusionRule") && strContext!=null && strContext.equalsIgnoreCase("GBOM")){
             //context ID will be its parent ID(LF/PRD)-----
             strContextObjectId  = emxGetParameter(request,"parentOID");
             if(strContext.equalsIgnoreCase("GBOM")){
                 strContextNameDispaly= emxGetParameter(request, "ContextParentNameDispaly");
             }else{
                 strContextNameDispaly= emxGetParameter(request, "ContextName");
             }
         }else  if(strRule.equalsIgnoreCase("InclusionRule") && strContext==null){
             //context ID will be its parent ID(LF/PRD)-----
             strContextObjectId  = emxGetParameter(request,"parentOID");
             
             //Map featureInfo=domFeature.getInfo(context,selectParObjList);
             //strContextNameDispaly= featureInfo.get(DomainObject.SELECT_TYPE)+" "+featureInfo.get(DomainObject.SELECT_NAME)+" "+featureInfo.get(DomainObject.SELECT_REVISION);
             strContextNameDispaly=RuleProcess.getDisplayExpression(context,strContextObjectId,null).toString();
             //strContextNameDispaly= emxGetParameter(request, "ContextName");
         }else{
            strContextObjectId  = emxGetParameter(request,"objectId");
            strContextNameDispaly= emxGetParameter(request, "ContextName");
         }
     }
     
     if ((strmode.compareTo("copy")==0)){
         strContextObjectId  = emxGetParameter(request,"productID");             
     }
     
     
     String strFeatureTypeList = EnoviaResourceBundle.getProperty(context,"emxConfiguration.RuleDialog.ExpandPattern");
     ArrayList aLFeatureType = new ArrayList();
     StringTokenizer stFeatureTypes = new StringTokenizer(strFeatureTypeList,",");
     while(stFeatureTypes.hasMoreElements()){
           String tempFeatureType = stFeatureTypes.nextToken();
           //Check for PV use case..
           //If context PV.. we need to use PFL rel instead of LF rel..
           //Skip Logical Feature rel type
           if(strContextObjectType!=null 
                   && (strContextParentType.equalsIgnoreCase("type_ProductVariant"))
             )
           
           {
               if(!tempFeatureType.equalsIgnoreCase("relationship_LOGICALSTRUCTURES")){
                   aLFeatureType.add(tempFeatureType);   
            }
           }else{
               if(!tempFeatureType.equalsIgnoreCase("relationship_ProductFeatureList")){
                   aLFeatureType.add(tempFeatureType);   
               }   
           }
       }
  %>
 
 <script type="text/javascript" language="javascript">
  
 function setContext(){
     var sURL='../common/emxFullSearch.jsp?field=TYPES=type_Products,type_CONFIGURATIONFEATURES,type_ProductLine,type_Model:CURRENT!=<%=XSSUtil.encodeForURL(context,stateExclude)%>&table=FTRSearchFeaturesTable&showInitialResults=false&selection=single&formName=RuleForm&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?&mode=Chooser&chooserType=RuleContext&fieldNameActual=product&fieldNameDisplay=product';
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
            <option value="<xss:encodeForHTMLAttribute><%=strContextObjectId%></xss:encodeForHTMLAttribute>" id="<xss:encodeForHTMLAttribute><%=strContextObjectType%></xss:encodeForHTMLAttribute>"><%=XSSUtil.encodeForHTML(context,strContextNameDispaly)%></option>
          </select>
       </td>
       <td class="input" title="<emxUtil:i18n localize="i18nId">emxFramework.Basic.Search</emxUtil:i18n>"><a><img src="../common/images/iconActionSearch.gif" border="0" onclick="javascript:setContext();" /></a></td>
       
       <%--
       <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Feature</emxUtil:i18n> </td>
       <td class="input">
          <select name="featureType" id="featureType">
              <%for(int i=0;i<aLFeatureType.size();i++){%>
                <option value= "<xss:encodeForHTMLAttribute><%=aLFeatureType.get(i)%></xss:encodeForHTMLAttribute>"> 
                 <emxUtil:i18n localize='i18nId'>emxConfiguration.RuleDialog.ExpandPattern.Range.<%=XSSUtil.encodeForHTML(context,((String)aLFeatureType.get(i)).replace("relationship_",""))%></emxUtil:i18n>
                </option>
              <%}%>
          </select>
       </td>
       --%>
       
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



<%-- ProductConfigurationValidation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import = "java.util.Enumeration"%>
<%@page import="javax.json.*" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>	
<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>

<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
    String mode = emxGetParameter(request,"mode");
	ServletContext svltContext = getServletConfig().getServletContext();
	java.io.InputStream inputStream=null;
	String pcCreateMode =  EnoviaResourceBundle.getProperty(context,"emxConfiguration.ProductConfiguration.UIMode");
	try{
		 inputStream = svltContext.getResourceAsStream("/configuration/ProductConfigurationDisplay.xsl");
	}catch (Exception e){
		throw new FrameworkException(e.getMessage());
	}
	// If block of code is unused, not getting called. Need to revisit the code for deprecation.
    if(mode.equals("checkValidity"))
     {
        ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
        //JSONObject json = new JSONObject();
        JsonObjectBuilder jsonObjBuild = Json.createObjectBuilder();
        if(pConf != null)
            {
        	   pConf.validateAllRules(context);
        	   //json.put("html", pConf.getHTMLForOptionsDisplay(context,inputStream,"edit"));
        	   jsonObjBuild.add("html", pConf.getHTMLForOptionsDisplay(context,inputStream,"edit"));
        	   
        	   IProductConfigurationFeature []pSelectionsRemaining = new IProductConfigurationFeature[1];
        	   boolean areRequiredSelectionsDone = true;
        	   boolean isValid = true;
        	   StringList validationStatus = new StringList();
        	   areRequiredSelectionsDone = pConf.checkRequiredSelectionsDone(context, pSelectionsRemaining,validationStatus);
        	   String validationMessage="";
        	   if(!areRequiredSelectionsDone)
        	   {
        		   IProductConfigurationFeature pSelectionRemaining = pSelectionsRemaining[0];
        		   if(pSelectionsRemaining != null && !validationStatus.contains(ConfigurationConstants.RANGE_VALUE_KEY_IN))
                   {
        			  
        			    validationMessage = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.SelectAtleastOne",acceptLanguage);
        			    validationMessage = validationMessage+" "+pSelectionRemaining.getDisplayName();
        			     
                   }else if(pSelectionsRemaining != null && validationStatus.contains(ConfigurationConstants.RANGE_VALUE_KEY_IN))
                   {
                	   validationMessage = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.KeyInChanged.ReviewSelections",acceptLanguage);
                       validationMessage = validationMessage+" "+pSelectionRemaining.getDisplayName();
                   }
        		   //json.put("message", validationMessage);
        		   jsonObjBuild.add("message", validationMessage);
        	   }
        	   else
        	   {
        	    isValid = pConf.isValidProductConfiguration(context);
        	   	if(isValid)
        		   {
        		    validationMessage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductConfiguration.MarketingRuleEvaluation.Success",acceptLanguage);
        		    //json.put("message", validationMessage);
        		    jsonObjBuild.add("message", validationMessage);
        		  }else if(!isValid)
        		  {
          		    validationMessage = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductConfiguration.MarketingRuleEvaluation.Failure",acceptLanguage);
          		    //json.put("message", validationMessage);
          		    jsonObjBuild.add("message", validationMessage);
          		  }
                      
        	   }
            }
        JsonObject json = jsonObjBuild.build();
        out.clear();
        out.write(json.toString());
        out.flush();
     }
    else if(mode.equals("validate"))
    {
    	String tableRowId = emxGetParameter(request, "emxTableRowId");
    	String productConfigurationId = null;
    	if(tableRowId == null)
    		   productConfigurationId = emxGetParameter(request, "objectId");
    	else
    	{
    		int index = tableRowId.indexOf("|");
    		productConfigurationId = tableRowId.substring(index+1);
    	}
        
    	ProductConfiguration pConf = new ProductConfiguration(ProductConfiguration.NONINTERACTIVE_MODE);
    	pConf.setUserAction(ProductConfiguration.ACTION_PC_EDIT);
        pConf.setId(productConfigurationId);
    	boolean effectiveFeaturesExist = true;
    	try
    	{
    		pConf.initContext(context);
    		if(!"Solver".equals(pcCreateMode))
    		pConf.loadContextStructure(context,pConf.getContextId(),pConf.getParentProductId());
    	}catch(Exception epn)
    	{
    		effectiveFeaturesExist = false;
    	}
    	

if(!"Solver".equals(pcCreateMode))
{
        pConf.loadDetails(context);
        pConf.loadSelectedOptions(context);
    	MapList ineffectiveList = pConf.getIneffectiveFeatureList();
    	boolean ineffectiveSelectedFeaturesExist = ineffectiveList.isEmpty() ? false :true;
        boolean isValid = pConf.validateProductConfiguration(context);
        String strType=pConf.getType();
        String strName=pConf.getName();
        if(isValid)
        {
        	//String validationMsg = i18nNow.getI18nString( "emxProduct.Alert.ConfigurationValidatedSuccessfully",bundle, acceptLanguage);
        	String validationMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductConfiguration.MarketingRuleEvaluation.Success",acceptLanguage);     
        	%>
        	 <script language="javascript" type="text/javaScript">
              alert("<%=XSSUtil.encodeForJavaScript(context,validationMsg)%>");
              refreshTablePage();
               </script>
 		<%}
        else
        {
       	session.setAttribute("productconfiguration", pConf);
       	%>
       	<SCRIPT language="javascript" type="text/javaScript">
       	   //XSSOK
       	   var inEffectiveFeatures = "<%=ineffectiveSelectedFeaturesExist%>";
       	   //XSSOK
           var effectiveFeatures = "<%=effectiveFeaturesExist%>";
           var varName = "<%=XSSUtil.encodeForJavaScript(context,strName)%>";
           var varType = "<%=XSSUtil.encodeForJavaScript(context,strType)%>";
       	if(inEffectiveFeatures == "false" && effectiveFeatures == "false" )
        {
       		alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.ProductConfiguration.SelectedOptions.IneffectiveObsolete</emxUtil:i18nScript>");
       		showModalDialog('ProductConfigurationViewFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationMarketingRuleValidationReportFSInstance&suiteKey=Configuration&pcType='+varType+'&pcName='+varName, 940, 770);
       	}else if(inEffectiveFeatures == "true")
       	{
           alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.ValidatePC.IneffectiveFeaturesNotLoaded.Alert</emxUtil:i18nScript>");
           showModalDialog('ProductConfigurationViewFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationMarketingRuleValidationReportFSInstance&suiteKey=Configuration&pcType='+varType+'&pcName='+varName, 940, 770);
        }else 
        {
          showModalDialog('ProductConfigurationViewFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationMarketingRuleValidationReportFSInstance&suiteKey=Configuration&pcType='+varType+'&pcName='+varName, 940, 770);
        } 
           </SCRIPT>
       	<%
         }
        
   }
else{
	String attrValidationStatus = pConf.getInfo(context, "attribute["+ConfigurationConstants.ATTRIBUTE_VALIDATION_STATUS+"]");
	if(ConfigurationConstants.RANGE_VALUE_VALIDATION_PASSED.equalsIgnoreCase(attrValidationStatus))	{
    	String validationMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductConfiguration.MarketingRuleEvaluation.Success",acceptLanguage);     
    	%>
    	 <script language="javascript" type="text/javaScript">
          alert("<%=XSSUtil.encodeForJavaScript(context,validationMsg)%>");
          refreshTablePage();
         </script>
	<%
	}else if(ConfigurationConstants.RANGE_VALUE_VALIDATION_FAILED.equalsIgnoreCase(attrValidationStatus)){
	%>
		<script language="javascript" type="text/javaScript">
		showModalDialog("ProductConfiguratorFS.jsp?contextId=<%=pConf.getParentProductId()%>&pcId=<%=productConfigurationId%>&strAction=view", 940, 770);
		</script>	
	<% 
	}else
	{
		String validationMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.ProductConfiguration.MarketingRuleEvaluation.NotValidated",acceptLanguage);
    	%>
   	 	 <script language="javascript" type="text/javaScript">
         var result = confirm("<%=XSSUtil.encodeForJavaScript(context,validationMsg)%>","");
         if(result==true)
         {
        	 showModalDialog("ProductConfiguratorFS.jsp?contextId=<%=pConf.getParentProductId()%>&pcId=<%=productConfigurationId%>&strAction=edit", 940, 770);
        	 refreshTablePage();
         }
        </script>
	<%	
	}
}
    }
   %>    

   

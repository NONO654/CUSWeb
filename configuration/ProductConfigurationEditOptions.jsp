<%-- ProductConfigurationEditOptions.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.*" %>
<%@page import="com.matrixone.apps.productline.*" %>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import = "matrix.db.State"%>
<%@page import="java.util.Enumeration"%>
<%@page import= "java.util.List"%>
<%@page import = "java.util.TimeZone"%>
<%@page import = "java.text.DateFormat"%>
<%@page import = "java.text.SimpleDateFormat"%>
<%@page import = "com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@page import = "java.util.Calendar"%>
<%@page import="javax.json.*" %>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>

<%
String strMode = emxGetParameter(request, "mode");

String pcUIMode =  EnoviaResourceBundle.getProperty(context,"emxConfiguration.ProductConfiguration.UIMode");

//If block of code is unused, not getting called. Need to revisit the code for deprecation.
if(strMode != null && strMode.equals("Apply"))
{
	try
	{
	ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
	pConf.applyEditOptions(context);
		   /* JSONObject returnCode = new JSONObject();
		   returnCode.put("code", "EDIT_SUCCESSFUL"); */
		   JsonObjectBuilder jsonObjBuild = Json.createObjectBuilder();
		   jsonObjBuild.add("code", "EDIT_SUCCESSFUL");
		   JsonObject returnCode = jsonObjBuild.build();
		   
	out.clear();
		   out.print(returnCode.toString());
	out.flush();
}
	catch(Exception ex)
	{
		/* JSONObject returnCode = new JSONObject();
		returnCode.put("code", "EDIT_ERROR");
		returnCode.put("message", ex.getMessage()); */
		JsonObjectBuilder jsonObjectBuild = Json.createObjectBuilder();
		jsonObjectBuild.add("code", "EDIT_ERROR");
		jsonObjectBuild.add("message", ex.getMessage());
		JsonObject  returnCode = jsonObjectBuild.build();
		out.clear();
		out.print(returnCode.toString());
		out.flush();
	}
}
else
{
	
	if (pcUIMode != null && "Solver".equals(pcUIMode)) 
	{
		String pcId = emxGetParameter(request, "objectId");
		String startDate = ConfigurationConstants.EMPTY_STRING;
		DomainObject domPC = new DomainObject(pcId);
		StringList pcSelects = new StringList();
		pcSelects.add("to["+ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
		pcSelects.add("to["+ConfigurationConstants.RELATIONSHIP_FEATURE_PRODUCT_CONFIGURATION+"].from.id");
		pcSelects.add("attribute["+ConfigurationConstants.ATTRIBUTE_START_EFFECTIVITY+"]");
		
		Map pcMap = domPC.getInfo(context, pcSelects);
		String contextId = (String)pcMap.get("to["+ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
		String strProductContextId = (String)pcMap.get("to["+ConfigurationConstants.RELATIONSHIP_FEATURE_PRODUCT_CONFIGURATION+"].from.id");
		String attrStartEffectivityDate = (String)pcMap.get("attribute["+ConfigurationConstants.ATTRIBUTE_START_EFFECTIVITY+"]");
		if(!attrStartEffectivityDate.equals("")){
	 		SimpleDateFormat attrDateFormat = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
	 		Date attrStartDate = attrDateFormat.parse(attrStartEffectivityDate);
	 		SimpleDateFormat displayDateFormat = new SimpleDateFormat("MMM d, yyyy");
	 		startDate = displayDateFormat.format(attrStartDate);
		}
		
		String currentPCState = domPC.getInfo(context,DomainConstants.SELECT_CURRENT);
		
		
		if(!currentPCState.equals(ProductLineConstants.STATE_PRODUCT_CONFIGURATION_PRELIMINARY))
		{
	    	String strInvalidState = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.ProductConfigurationActiveState",context.getSession().getLanguage());
	    	
	    	if (currentPCState.equals(ProductLineConstants.STATE_ACTIVE)) {
	    		strInvalidState = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.ProductConfigurationActiveState",context.getSession().getLanguage());
	    	}
	    	else if (currentPCState.equals(ProductLineConstants.STATE_INACTIVE)) {
	    		strInvalidState = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.ProductConfigurationInactiveState",context.getSession().getLanguage());
	    	}
%>
  	        <script language="javascript" type="text/javaScript">
  	        	alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidState)%>");
  	        </script>
<%
		}
		else 
		{
%>
		<script>
		 showModalDialog('ProductConfiguratorFS.jsp?contextId=<%=contextId%>&pcId=<%=pcId%>&strAction=edit&strProductContextId=<%=strProductContextId%>&txtStartEffectivity=<%= XSSUtil.encodeForURL(context, startDate) %>', 940, 680,true,"MediumTall");
		 </script>
<%
		}
	}
	else 
	{
	try
	{
	String productConfigurationId = emxGetParameter(request, "objectId");	
    String strProductConfigurationMode = ConfigurationConstants.PRODUCT_CONFIGURATION_INTERACTIVE_MODE;
	    ProductConfiguration pConf = ProductConfigurationFactory.newInstance(context);
    pConf.setId(productConfigurationId);
	    DomainObject domPC = new DomainObject(productConfigurationId);
	    String currentState = domPC.getInfo(context,DomainConstants.SELECT_CURRENT);
	    List lstPCStates = domPC.getStates(context);
	    
	    //Logic to restrict the "Edit Options" beyond "Generate BOM" state.
	   // if(!currentState.getName().equals(ProductLineConstants.STATE_PRODUCT_CONFIGURATION_PRELIMINARY))
		for(int icnt=0;icnt<lstPCStates.size();icnt++)
	    {
			Boolean bActive = false;
	        State stState = (State)lstPCStates.get(icnt);
	        String strState = stState.getName();
	        if(strState.equals(ProductLineConstants.STATE_ACTIVE))
	        {
	            bActive = true;
	        }
	        if(strState.equals(currentState))
	        {
	            if(bActive)
        {
    	   String strInvalidState = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Error.ProductConfigurationActiveState",context.getSession().getLanguage());%>
    	         <script language="javascript" type="text/javaScript">
    	        alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidState)%>");
    	        </script>
    	        <%throw new FrameworkException(strInvalidState);
				}else{
	pConf.setId(productConfigurationId);
	pConf.setUserAction(ProductConfiguration.ACTION_PC_EDIT);
	boolean effectiveFeaturesExist = true;
	try
	{
		pConf.initContext(context);	
		pConf.loadContextStructure(context,pConf.getContextId(),pConf.getParentProductId());
	}catch(Exception epn)
	{
		effectiveFeaturesExist = false;
	}
	pConf.loadDetails(context);
	pConf.loadSelectedOptions(context);
	MapList ineffectiveList = pConf.getIneffectiveFeatureList();
	boolean ineffectiveSelectedFeaturesExist = ineffectiveList.isEmpty() ? false :true;
	session.setAttribute("productconfiguration",pConf);
	String applyURL = "ProductConfigurationEditOptions.jsp?mode=Apply";
	%>
      
    <SCRIPT language="javascript" type="text/javaScript">
    //XSSOK
    var inEffectiveFeatures = "<%=ineffectiveSelectedFeaturesExist%>";
    //XSSOK
    var effectiveFeatures = "<%=effectiveFeaturesExist%>";
    
	if(inEffectiveFeatures == "false" && effectiveFeatures == "false" ){
		alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.ProductConfiguration.SelectedOptions.IneffectiveObsolete</emxUtil:i18nScript>");
		showModalDialog('ProductConfigurationFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationEditOptionsContentFSInstance&suiteKey=Configuration&objectId=<%=XSSUtil.encodeForURL(context,productConfigurationId)%>&productConfigurationMode=<%=XSSUtil.encodeForURL(context,strProductConfigurationMode)%>&applyURL=<%=XSSUtil.encodeForURL(context,applyURL)%>', 940, 680,true,"MediumTall");
	}else if(inEffectiveFeatures == "true")
	{
     alert("<emxUtil:i18nScript localize="i18nId">emxConfiguration.EditPC.IneffectiveFeaturesNotLoaded.Alert</emxUtil:i18nScript>");
     showModalDialog('ProductConfigurationFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationEditOptionsContentFSInstance&suiteKey=Configuration&objectId=<%=XSSUtil.encodeForURL(context,productConfigurationId)%>&productConfigurationMode=<%=XSSUtil.encodeForURL(context,strProductConfigurationMode)%>&applyURL=<%=XSSUtil.encodeForURL(context,applyURL)%>', 940, 680,true,"MediumTall");
    }else 
    {
     showModalDialog('ProductConfigurationFS.jsp?FSmode=featureSelect&PRCFSParam2=edit&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationEditOptionsContentFSInstance&suiteKey=Configuration&objectId=<%=XSSUtil.encodeForURL(context,productConfigurationId)%>&productConfigurationMode=<%=XSSUtil.encodeForURL(context,strProductConfigurationMode)%>&applyURL=<%=XSSUtil.encodeForURL(context,applyURL)%>', 940, 680,true,"MediumTall");
    }
    
    </SCRIPT>
	<%
				}
			}
	    }
	}
catch(Exception ex)
{
	//out.clear();
	ex.printStackTrace();
	}

}
	
}
%>

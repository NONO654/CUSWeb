<%-- ProductConfigurationDesignValidation.jsp
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

<%@page import="com.matrixone.apps.domain.*" %>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import = "java.util.Enumeration"%>
<%@page import = " java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
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
   String productConfigurationId = emxGetParameter(request, "objectId");  
   StringBuffer sb=new StringBuffer();
   sb.append("to[");
   sb.append(ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION);
   sb.append("].from.id");
   String contextId=sb.toString();
   sb.delete(0,sb.length());
   
   sb.append("to[");
   sb.append(ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION);
   sb.append("].from.type");
   String contexType=sb.toString();
   sb.delete(0,sb.length());
   
   sb.append("to[");
   sb.append(ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION);
   sb.append("].from.name");
   String contextName=sb.toString();
   sb.delete(0,sb.length());
   
   sb.append("to[");
   sb.append(ConfigurationConstants.RELATIONSHIP_PRODUCT_CONFIGURATION);
   sb.append("].from.to[");
   sb.append(ConfigurationConstants.RELATIONSHIP_LOGICAL_FEATURES);
   sb.append("].from.id");
   String contextLFId=sb.toString();
   
   DomainObject obj=new DomainObject(productConfigurationId);
       StringList selectableList=new StringList();    
       selectableList.addElement(contextId);
       selectableList.addElement(contexType);
       selectableList.addElement(contextName);
       selectableList.addElement(contextLFId);

    String parentObjId="";
    Map temMap= (Map)obj.getInfo(context,selectableList);
    String contextObjId=(String)temMap.get(contextId);
    String contextObjname=(String)temMap.get(contextName);
    String contextType=(String)temMap.get(contexType);
    String parentId =(String)temMap.get(contextLFId);
    if(contextType.equalsIgnoreCase(ConfigurationConstants.TYPE_LOGICAL_FEATURE)){
    	parentObjId=parentId;
    }
  if(mode.equals("validate"))
    {
    	String tableRowId = emxGetParameter(request, "emxTableRowId");
    	//String productConfigurationId = null;
    	if(tableRowId == null)
    		   productConfigurationId = emxGetParameter(request, "objectId");
    	else
    	{
    		int index = tableRowId.indexOf("|");
    		productConfigurationId = tableRowId.substring(index+1);
    	}
      
        ProductConfiguration pConf = new ProductConfiguration(productConfigurationId,ProductConfiguration.NONINTERACTIVE_MODE);    
        //ProductConfiguration pConf = ProductConfigurationFactory.newInstance(context);
        pConf.setId(productConfigurationId);
        pConf.loadContextLogicalStructure(context,contextObjId,parentObjId); 
        StringList conflictingRules = new StringList();
        conflictingRules = pConf.validateDesignRules(context);
    	
    	session.putValue("conflictRules",conflictingRules);    
        if(conflictingRules.size()==0)
        {
        	String validationMsg = i18nNow.getI18nString(
                    "emxProduct.Alert.DesignRuleEvaluationSuccessful",
                    bundle, acceptLanguage);
        	%>
        	 <script language="javascript" type="text/javaScript">
              alert("<%=XSSUtil.encodeForJavaScript(context,validationMsg)%>");
              refreshTablePage();
               </script>
 		<%}
        else
        {
       //	session.setAttribute("productconfiguration", pcInstance);
       	%>
       	<SCRIPT language="javascript" type="text/javaScript">      
       	
        var submitURL="../common/emxIndentedTable.jsp?suiteKey=Configuration&table=FTREvaluateDesignRuleTable&showTabHeader=true&header=emxConfiguration.Heading.DesignRule.Table&HelpMarker=false&program=emxProductConfiguration:getNonValidateRuleConnected&objectId=<%=XSSUtil.encodeForJavaScript(context,productConfigurationId)%>&contextId=<%=XSSUtil.encodeForJavaScript(context,contextObjId)%>&contextObjname=<%=XSSUtil.encodeForJavaScript(context,contextObjname)%>&jpoAppServerParamList=session:conflictRules";
         // showModalDialog(submitURL,940, 770);
           showModalDialog(submitURL,575,575,"true","Large");
           
           setTimeout(refreshTablePage,2000);
           </SCRIPT>
       	<%
         }
        
   }%>    
   

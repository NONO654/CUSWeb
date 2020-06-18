<%--
  VariantCreatePreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
                 
<%
  try
  {	  
	 String strLanguage = context.getSession().getLanguage();      
     String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     String strCreationType = emxGetParameter(request, "CreationType");
     String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
     String strVariantNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariantNotAllowed", strLanguage);
     String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureCreateOptionNotAllowed", strLanguage);
 	 String strObjectId = emxGetParameter(request, "objectId"); 
 	 String strUIContext = emxGetParameter(request, "UIContext");
 	 String strType = "";
     
     if(strTableRowIds != null && strTableRowIds.length > 1)
     {
        %>
    	<script language="javascript" type="text/javaScript">
           alert("<%=strRowSelectSingle%>");                
   		</script>
   		<%
     }else if(strUIContext!= null && strUIContext.equals("Classification")){

  		%>
         <body>   
        <form name="FTRVariantCreateForm" method="post">
 	     <script language="javascript" type="text/javaScript">          
 	           	 var submitURL = "../common/emxCreate.jsp?type=type_Variant&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=refreshCaller&vaultChooser=true&form=type_CreateVariant&header=emxConfiguration.Form.Heading.CreateVariant&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariant&HelpMarker=emxhelpvariantcreate&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&policy=policy_PerpetualResource";
 	          	 getTopWindow().showSlideInDialog(submitURL, "true");
 	     </script>
 	     </form>
        </body>
        <%
     }
     else if(strTableRowIds != null && strTableRowIds.length == 1)
     {
    	StringList lstVariantChildTypes = new StringList();
    	StringList lstVBGChildTypes = new StringList();
    	StringList lstVariantValueChildTypes = new StringList();
    	StringList lstVBOChildTypes = new StringList();
    	StringList lstCFChildTypes = new StringList();
    	StringList lstCOChildTypes = new StringList();
    	boolean isObjectFrozen = false;
    	String[] arrTableRowId = strTableRowIds[0].toString().split("\\|");
    	strObjectId = arrTableRowId[1];
    	if(ProductLineCommon.isNotNull(strObjectId))
    	{
    		DomainObject domObj = DomainObject.newInstance(context, strObjectId);
    		StringList strSelect = new StringList();
    		strSelect.add(DomainConstants.SELECT_TYPE);
    		Map variantMap = domObj.getInfo(context, strSelect);
    		strType = (String) variantMap.get(DomainConstants.SELECT_TYPE);
    		lstVariantChildTypes = ProductLineUtil.getChildrenTypes(context,ConfigurationConstants.TYPE_VARIANT);
    		lstVariantChildTypes.add(ConfigurationConstants.TYPE_VARIANT);
    		lstVBGChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYGROUP);
    		lstVariantValueChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIANTVALUE);
    		lstVBOChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYOPTION);
    		lstCFChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
    		lstCOChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
    		
    		isObjectFrozen = ConfigurationUtil.isFrozenState(context, strObjectId);
    	}
    	if(isObjectFrozen)
    	{
    		%>
        	<script language="javascript" type="text/javaScript">
               alert("<%=strInvalidStateCheck%>");                
       		</script>
       		<%
    	}
    	else if(lstVariantChildTypes.contains(strType) || lstVBGChildTypes.contains(strType) || lstVariantValueChildTypes.contains(strType) || lstVBOChildTypes.contains(strType) || lstCFChildTypes.contains(strType) || lstCOChildTypes.contains(strType))
    	{
    		%>
        	<script language="javascript" type="text/javaScript">
               alert("<%=strVariantNotAllowed%>");                
       		</script>
       		<%
    	}
    	else
    	{
	        %>
	         <body>   
             <form name="FTRVariantCreateForm" method="post">
		     <script language="javascript" type="text/javaScript">          
		           	 var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&type=type_Variant&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=none&vaultChooser=true&form=type_CreateVariant&header=emxConfiguration.Form.Heading.CreateVariant&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariant&HelpMarker=emxhelpvariantcreate&policy=policy_PerpetualResource&postProcessURL=../configuration/VariantCreatePostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>";
		          	 getTopWindow().showSlideInDialog(submitURL, "true");
		     </script>
		     </form>
             </body>
	        <%
        }
     }else{
 		%>
        <body>   
       <form name="FTRVariantCreateForm" method="post">
	     <script language="javascript" type="text/javaScript">          
	           	 var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&type=type_Variant&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=refreshCaller&vaultChooser=true&form=type_CreateVariant&header=emxConfiguration.Form.Heading.CreateVariant&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariant&HelpMarker=emxhelpvariantcreate&policy=policy_PerpetualResource";
	          	 getTopWindow().showSlideInDialog(submitURL, "true");
	     </script>
	     </form>
       </body>
       <%
     }
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

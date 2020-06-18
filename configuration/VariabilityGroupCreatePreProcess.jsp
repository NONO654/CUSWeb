<%--
  VariabilityGroupCreatePreProcess.jsp
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
     String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
     String strVariabilityGroupNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariabilityGroupNotAllowed", strLanguage);
     String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureCreateOptionNotAllowed", strLanguage);
 	 String strObjectId = emxGetParameter(request, "objectId");
 	String strUIContext = emxGetParameter(request, "UIContext");
     
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
  	           	 var submitURL = "../common/emxCreate.jsp?type=type_VariabilityGroup&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=refreshCaller&vaultChooser=true&form=type_CreateVariabilityGroup&header=emxConfiguration.Form.Heading.CreateVariabilityGroup&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariabilityGroup&HelpMarker=emxhelpvariabilitygroupcreate&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&policy=policy_PerpetualResource";
  	          	 getTopWindow().showSlideInDialog(submitURL, "true");
  	     </script>
  	     </form>
         </body>
         <%
      
     }
     else if(strTableRowIds != null && strTableRowIds.length == 1)
     {
    	String strType = "";
    	StringList lstVariabilityGroupChildTypes = new StringList();
    	StringList lstVariantChildTypes = new StringList();
    	StringList lstVariabilityOptionChildTypes = new StringList();
    	StringList lstVariantValuesChildTypes = new StringList();
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
    		Map variabilityGroupMap = domObj.getInfo(context, strSelect);
    		strType = (String) variabilityGroupMap.get(DomainConstants.SELECT_TYPE);
    		lstVariabilityGroupChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYGROUP);
    		lstVariantChildTypes = ProductLineUtil.getChildrenTypes(context,ConfigurationConstants.TYPE_VARIANT);
    		lstVariantChildTypes.add(ConfigurationConstants.TYPE_VARIANT);
    		lstVariabilityOptionChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYOPTION);
    		lstVariantValuesChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIANTVALUE);
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
    	else if(lstVariabilityGroupChildTypes.contains(strType) || lstVariantChildTypes.contains(strType) || lstVariabilityOptionChildTypes.contains(strType) || lstVariantValuesChildTypes.contains(strType) || lstCFChildTypes.contains(strType) || lstCOChildTypes.contains(strType))
    	{
    		%>
        	<script language="javascript" type="text/javaScript">
               alert("<%=strVariabilityGroupNotAllowed%>");                
       		</script>
       		<%
    	}
    	else
    	{
	        %>
	         <body>   
             <form name="FTRVariabilityGroupCreateForm" method="post">
		     <script language="javascript" type="text/javaScript">          
		           	 var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&type=type_VariabilityGroup&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=none&vaultChooser=true&form=type_CreateVariabilityGroup&header=emxConfiguration.Form.Heading.CreateVariabilityGroup&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariabilityGroup&HelpMarker=emxhelpvariabilitygroupcreate&policy=policy_PerpetualResource&postProcessURL=../configuration/VariabilityGroupCreatePostProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>";
		          	 getTopWindow().showSlideInDialog(submitURL, "true");
		     </script>
		     </form>
             </body>
	        <%
        }
     }else{
	        %>
	         <body>   
            <form name="FTRVariabilityGroupCreateForm" method="post">
		     <script language="javascript" type="text/javaScript">          
		           	 var submitURL = "../common/emxCreate.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&type=type_VariabilityGroup&showApply=true&showPolicy=false&typeChooser=false&autoNameChecked=false&nameField=both&submitAction=refreshCaller&vaultChooser=true&form=type_CreateVariabilityGroup&header=emxConfiguration.Form.Heading.CreateVariabilityGroup&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&createJPO=ConfigurationFeature:createVariabilityGroup&HelpMarker=emxhelpvariabilitygroupcreate&policy=policy_PerpetualResource";
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

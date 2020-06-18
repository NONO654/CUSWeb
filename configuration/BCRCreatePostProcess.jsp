<%--
  BCRCreatePostProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/BooleanCompatibilityUtil.jsp 1.19.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.configuration.ProductLine"%>  
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import=" com.matrixone.apps.configuration.Model"%>
<%@page import=" com.matrixone.apps.configuration.Product"%>
<%@page import=" com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page   import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
boolean bFlag=false;
try
 {
  String strType = emxGetParameter(request, "ruleType");
  String strRevision = "";
  String strOwner = "";
  
  //Values from the Basic Component
  String strName = emxGetParameter(request, "txtRuleName");
  //strName = strHiddenRuleName;
  String strRuleclassification = emxGetParameter(request, "ruleClassification");
  String strDescription = emxGetParameter(request, "txtDescription");
  String strErrorMessage = emxGetParameter(request, "txtErrorMsg");
  String strMandatory = emxGetParameter(request, "mandatory");
  String strDesignResponsibility = emxGetParameter(request, "hDRId");
  String strVault = emxGetParameter(request, "hVaultID");
 
  String strPolicy = emxGetParameter(request, "selPolicy");
  
  //Values from Context Selector Component
  String strFeatureType = emxGetParameter(request, "featureTypeValue");
  
  //Values from Left Expression Component
  String strLeftExpressionText = emxGetParameter(request, "hleftExpObjTxt");
  String strLeftExpressionObjIds = emxGetParameter(request, "hleftExpObjIds");
  
  //Values from Right Expression Component
  String strRightExpressionText = emxGetParameter(request, "hrightExpObjTxt");
  String strRightExpressionObjIds = emxGetParameter(request, "hrightExpObjIds");
    
  //Values from Comparison Operator Component
  String strComparisonOperator = emxGetParameter(request, "comparisonOperator");
  
  //Values from Completed Rule Component are not used for processing
 
	  String strPdtId = emxGetParameter(request, "ProductId");
	  String strContextType = emxGetParameter(request, "hContextType");
	  
      Map bcrExpMap = new HashMap();
      bcrExpMap.put("leftExpObjectExp",strLeftExpressionText);
      bcrExpMap.put("leftExpObjectIds",strLeftExpressionObjIds);
      bcrExpMap.put("rightExpObjectExp",strRightExpressionText);
      bcrExpMap.put("rightExpObjectIds",strRightExpressionObjIds);
     
     	  
      Map objAttributeMap = new HashMap();
      objAttributeMap.put("Rule Type",strRuleclassification);
      objAttributeMap.put("Comparison Operator",strComparisonOperator);
      objAttributeMap.put("Design Responsibility",strDesignResponsibility);
      objAttributeMap.put("Error Message",strErrorMessage);
      objAttributeMap.put("Description",strDescription);
      objAttributeMap.put("Feature Type",strFeatureType);
      objAttributeMap.put("Rule Classification",strRuleclassification);
      
      Map relAttributeMap = new HashMap();
      //IR-151491V6R2013
      relAttributeMap.put(ConfigurationConstants.ATTRIBUTE_MANDATORYRULE,strMandatory);
      
      //if(strContextType!=null && strContextType.equals(ConfigurationConstants.TYPE_PRODUCT_LINE))
    	if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCT_LINE))
      {
    	  ProductLine boBean = new ProductLine(strPdtId);
          boBean.createAndConnectBooleanCompatibilityRule(context,
                                                                           strType,strName,strRevision,strPolicy,   
                                                                           strVault,strOwner, strDescription, 
                                                                           bcrExpMap,objAttributeMap,relAttributeMap);
      }
      else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_MODEL))
      {
          Model boBean = new Model(strPdtId);
          boBean.createAndConnectBooleanCompatibilityRule(context,
                                                                           strType,strName,strRevision,strPolicy,   
                                                                           strVault,strOwner, strDescription, 
                                                                           bcrExpMap,objAttributeMap,relAttributeMap);
      }
      else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCTS))
      {
    	  Product boBean = new Product(strPdtId);
          boBean.createAndConnectBooleanCompatibilityRule(context,
                                                                           strType,strName,strRevision,strPolicy,   
                                                                           strVault,strOwner, strDescription, 
                                                                           bcrExpMap,objAttributeMap,relAttributeMap);
      }
      else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_LOGICAL_STRUCTURES))
      {
    	  LogicalFeature boBean = new LogicalFeature(strPdtId);
          boBean.createAndConnectBooleanCompatibilityRule(context,
                                                                           strType,strName,strRevision,strPolicy,   
                                                                           strVault,strOwner, strDescription, 
                                                                           bcrExpMap,objAttributeMap,relAttributeMap);
      }
      else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURES))
      {
    	  ConfigurationFeature boBean = new ConfigurationFeature(strPdtId);
          boBean.createAndConnectBooleanCompatibilityRule(context,
                                                                           strType,strName,strRevision,strPolicy,   
                                                                           strVault,strOwner, strDescription, 
                                                                           bcrExpMap,objAttributeMap,relAttributeMap);
      }
 }
 catch (Exception e)
 {
    bFlag=true;
    session.putValue("error.message", e.getMessage());
 }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    if (bFlag)
    {
%>
    <!--Javascript to bring back to the previous page-->
    <script language="javascript" type="text/javaScript">
    history.back();
    </script>
<%
    }else{%>
    <script language="javascript" type="text/javaScript">
   
   // getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    getTopWindow().getWindowOpener().editableTable.loadData();
     getTopWindow().getWindowOpener().rebuildView();
    window.getTopWindow().closeWindow();
    </script>
<%}
%>

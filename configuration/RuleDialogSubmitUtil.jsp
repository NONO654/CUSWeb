<%--
  RuleDialogValidationUtil.jsp

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
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page	import="matrix.util.StringList"%>
<%@page import="java.util.List"%>
<%@page   import="java.util.HashMap"%>
<%@page import="java.util.Map"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
boolean bFlag=false;
try
 {

  //TO DO: Create,Edit and Copy modes need to be in different JSPs.
		
  //retrieve the mode passed
  String strMode = emxGetParameter(request, "mode");
  String strType = emxGetParameter(request, "ruleType");
  String strRevision = "";
  String strOwner = "";
  
  //Values from the Basic Component
  String strName = emxGetParameter(request, "txtRuleName");
  String strRuleclassification = emxGetParameter(request, "ruleClassification");
  String strDescription = emxGetParameter(request, "txtDescription");
  String strErrorMessage = emxGetParameter(request, "txtErrorMsg");
  String strDesignResponsibility = emxGetParameter(request, "txtDRDisplay");
  String strVault = emxGetParameter(request, "txtBCVault");
  String strPolicy = emxGetParameter(request, "selPolicy");
  String strRuleId = emxGetParameter(request, "hRuleId");
  
  //Values from Context Selector Component
  String strFeatureType = emxGetParameter(request, "featureTypeValue");
  
  //Values from Left Expression Component
  String strLeftExpressionText = emxGetParameter(request, "hleftExpObjTxt");
  String strLeftExpressionObjIds = emxGetParameter(request, "hleftExpObjIds");
  
//Values from Right Expression Component
  String strRightExpressionText = emxGetParameter(request, "hrightExpObjTxt");
  String strRightExpressionObjIds = emxGetParameter(request, "hrightExpObjIds");
  
  //Old values for Edit
  String strOldLEId = emxGetParameter(request, "hleftExpObjIdsForEdit");
  String strOldLEText = emxGetParameter(request, "hleftExpObjTxtForEdit");
   
  //Old values for Edit
  String strOldREId = emxGetParameter(request, "hrightExpObjIdsForEdit");
  String strOldREText = emxGetParameter(request, "hrightExpObjTxtForEdit");
    
  //Values from Comparison Operator Component
  String strCompatibilityStringInCreate = emxGetParameter(request, "comparisonOperator");
  String strCompatibilityStringInEdit = emxGetParameter(request, "hcompatibilityType");
  
  //Values from Completed Rule Component are not used for processing
 
  if(strMode.equals("create"))
  {
	  String strPdtId = emxGetParameter(request,"ProductId");
      Map bcrExpMap = new HashMap();
      bcrExpMap.put("leftExpObjectExp",strLeftExpressionText);
      bcrExpMap.put("leftExpObjectIds",strLeftExpressionObjIds);
      bcrExpMap.put("rightExpObjectExp",strRightExpressionText);
      bcrExpMap.put("rightExpObjectIds",strRightExpressionObjIds);
      bcrExpMap.put("compatibilityType",strCompatibilityStringInCreate);
     	  
      Map objAttributeMap = new HashMap();
      objAttributeMap.put("strRuleType",strRuleclassification);
      objAttributeMap.put("strDesignResponsibility",strDesignResponsibility);
      objAttributeMap.put("strErrorMessage",strErrorMessage);
      objAttributeMap.put("strDescription",strDescription);
      objAttributeMap.put("strFeatureType",strFeatureType);
      
      Map relAttributeMap = new HashMap();
     
      ProductLine boBean = new ProductLine(strPdtId);
      boBean.createAndConnectBooleanCompatibilityRule(context,
                                                                       strType,strName,strRevision,strPolicy,   
                                                                       strVault,strOwner, strDescription, 
                                                                       bcrExpMap,objAttributeMap,relAttributeMap);
      
  }
  else if(strMode.equals("edit"))
  {
      String strPdtId = emxGetParameter(request,"ProductId");
      
      Map bcrExpMap = new HashMap();
      bcrExpMap.put("leftExpObjectExp",strLeftExpressionText);
      bcrExpMap.put("leftExpObjectIds",strLeftExpressionObjIds);
      bcrExpMap.put("rightExpObjectExp",strRightExpressionText);
      bcrExpMap.put("rightExpObjectIds",strRightExpressionObjIds);
      
      bcrExpMap.put("OldLEId",strOldLEId);
      bcrExpMap.put("OldLEText",strOldLEText);
      bcrExpMap.put("OldREId",strOldREId);
      bcrExpMap.put("OldREText",strOldREText);
      
      bcrExpMap.put("compatibilityType",strCompatibilityStringInEdit);
      bcrExpMap.put("RuleId",strRuleId);
      
      StringList lstFeatureSelects = new StringList(DomainConstants.SELECT_ID);
      lstFeatureSelects.add(DomainConstants.SELECT_NAME);
      lstFeatureSelects.add(DomainConstants.SELECT_TYPE);
      lstFeatureSelects.add(DomainConstants.SELECT_REVISION);
      lstFeatureSelects.add(DomainConstants.SELECT_POLICY);
      lstFeatureSelects.add(DomainConstants.SELECT_VAULT);
      lstFeatureSelects.add(DomainConstants.SELECT_OWNER);
      lstFeatureSelects.add(DomainConstants.SELECT_DESCRIPTION);
      
      DomainObject domRuleId = new DomainObject(strRuleId);
      Map mapRuleInfo = domRuleId.getInfo(context,(StringList) lstFeatureSelects);
          
      Map objAttributeMap = new HashMap();
      objAttributeMap.put("strFeatureType",strFeatureType);
      objAttributeMap.put("strRuleType",mapRuleInfo.get(DomainConstants.SELECT_TYPE));
      objAttributeMap.put("strDesignResponsibility",strDesignResponsibility);
      objAttributeMap.put("strErrorMessage",strErrorMessage);
 
      Map relAttributeMap = new HashMap();
      
      ProductLine boBean = new ProductLine(strPdtId);
      boBean.editBooleanCompatibilityRule(context,
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_NAME),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_VAULT),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
    		                                                (String)mapRuleInfo.get(DomainConstants.SELECT_DESCRIPTION), 
                                                            bcrExpMap,
                                                            objAttributeMap,
                                                            relAttributeMap);
  }
  else if(strMode.equals("copy"))
  {
	  
	  
	  
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
    }
%>

<%--
  MPREditPostProcess.jsp

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
<%@page import=" com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page	import="matrix.util.StringList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import=" com.matrixone.apps.configuration.Model"%>
<%@page import=" com.matrixone.apps.configuration.Product"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
boolean bFlag=false;
String strPdtId="";
String strRuleId="";
try
 {
  //TO DO: Create,Edit and Copy modes need to be in different JSPs.
  
  //Values from the Basic Component
  String strName = emxGetParameter(request, "txtRuleName");
  String strDescription = emxGetParameter(request, "txtDescription");
  String strDesignResponsibility = emxGetParameter(request, "txtDRDisplay");
  String strVault = emxGetParameter(request, "hVaultID");
  strRuleId = emxGetParameter(request, "hRuleId");
  
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
  String strDesignResponsibilityID = emxGetParameter(request, "hDRId");

  //New values if present
  String strMandatoryInEdit = emxGetParameter(request, "hMandatory");
  //Values from Completed Rule Component are not used for processing
 
      strPdtId = emxGetParameter(request,"ProductId");
      Map mprExpMap = new HashMap();
      mprExpMap.put("leftExpObjectExp",strLeftExpressionText);
      mprExpMap.put("leftExpObjectIds",strLeftExpressionObjIds);
      mprExpMap.put("rightExpObjectExp",strRightExpressionText);
      mprExpMap.put("rightExpObjectIds",strRightExpressionObjIds);
      
      mprExpMap.put("OldLEId",strOldLEId);
      mprExpMap.put("OldLEText",strOldLEText);
      mprExpMap.put("OldREId",strOldREId);
      mprExpMap.put("OldREText",strOldREText);
      
      
      mprExpMap.put("RuleId",strRuleId);
      
      StringList lstFeatureSelects = new StringList(DomainConstants.SELECT_ID);
      lstFeatureSelects.add(DomainConstants.SELECT_NAME);
      lstFeatureSelects.add(DomainConstants.SELECT_TYPE);
      lstFeatureSelects.add(DomainConstants.SELECT_REVISION);
      lstFeatureSelects.add(DomainConstants.SELECT_POLICY);
      lstFeatureSelects.add(DomainConstants.SELECT_VAULT);
      lstFeatureSelects.add(DomainConstants.SELECT_OWNER);
      //lstFeatureSelects.add(DomainConstants.SELECT_DESCRIPTION);
      
      DomainObject domRuleId = new DomainObject(strRuleId);
      Map mapRuleInfo = domRuleId.getInfo(context,(StringList) lstFeatureSelects);
          
      Map objAttributeMap = new HashMap();
      objAttributeMap.put("Rule Type",mapRuleInfo.get(DomainConstants.SELECT_TYPE));
      objAttributeMap.put("Design Responsibility ID",strDesignResponsibilityID);
      objAttributeMap.put("Design Responsibility",strDesignResponsibility);
      
      String strContextType = emxGetParameter(request, "hContextType");

      Map relAttributeMap = new HashMap();
      //IR-151491V6R2013
      relAttributeMap.put(ConfigurationConstants.ATTRIBUTE_MANDATORYRULE,strMandatoryInEdit);
      
      //if(strContextType!=null && strContextType.equals(ConfigurationConstants.TYPE_PRODUCT_LINE))
      if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCT_LINE))
      {
          ProductLine boBean = new ProductLine(strPdtId);
          boBean.editMarketingPreferenceRule(context,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
                                                                strName,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
                                                                strVault,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
                                                                strDescription, 
                                                                mprExpMap,
                                                                objAttributeMap,
                                                                relAttributeMap);
      }
      else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_MODEL))
      {
          Model boBean = new Model(strPdtId);
          boBean.editMarketingPreferenceRule(context,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
                                                                strName,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
                                                                strVault,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
                                                                strDescription, 
                                                                mprExpMap,
                                                                objAttributeMap,
                                                                relAttributeMap);
      }
      else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCTS))
      {
          Product boBean = new Product(strPdtId);
          boBean.editMarketingPreferenceRule(context,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
                                                                strName,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
                                                                 strVault,
                                                                (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
                                                                strDescription, 
                                                                mprExpMap,
                                                                objAttributeMap,
                                                                relAttributeMap);
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
    var contextOID = '<%=XSSUtil.encodeForJavaScript(context,strPdtId)%>';
    var ruleID = '<%=XSSUtil.encodeForJavaScript(context,strRuleId)%>';          
    var url= "../configuration/CreateRuleDialog.jsp?modetype=edit&commandName=FTRMarketingPreferenceRuleSettings&ruleType=MarketingPreferenceRule&SuiteDirectory=configuration&suiteKey=configuration&parentOID="+contextOID+"&relId=null&suiteKey=configuration&objectId="+ruleID+"&submitURL=../configuration/MPREditPostProcess.jsp?mode=edit|objectId="+ruleID+"";
    getTopWindow().location.href = url;
    //history.back();
    </script>
<%
    }else{%>
    <script language="javascript" type="text/javaScript">
    getTopWindow().getWindowOpener().editableTable.loadData();
    getTopWindow().getWindowOpener().rebuildView();
    window.getTopWindow().closeWindow();
    </script>
<%}
%>

<%--
  RuleDialogPreProcessUtil.jsp

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

<%@page import="com.matrixone.apps.configuration.BooleanOptionCompatibility"%>
<%@page import=" com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.configuration.ConfigurableRulesUtil"%>
<%@page import="com.matrixone.apps.configuration.MarketingPreference"%>
<%@page import="com.matrixone.apps.configuration.InclusionRule"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
boolean bFlag=false;
try
 {
	String strMode = emxGetParameter(request, "mode");
	if(strMode!=null && strMode.equalsIgnoreCase("format"))
	 {  
	     out.clear();
	     String strcheckedRelIds = emxGetParameter(request,"checkedRelIds");
	     String strParentIds = emxGetParameter(request,"checkedParentIds");
	     String strChkdObjectIds = emxGetParameter(request,"checkedObjectIds");
	     String featureOptionDetails = emxGetParameter(request,"featureOptionDetails");

	     com.matrixone.apps.configuration.BooleanOptionCompatibility bcr = new BooleanOptionCompatibility();
	     
	     try
	    {
	        Map mapExpr = bcr.formatExpression(context,strcheckedRelIds,strParentIds,strChkdObjectIds,featureOptionDetails);
	        String strActualString = (String)mapExpr.get(bcr.ACTUAL_VALUE);
	        String strDisplayString = (String)mapExpr.get(bcr.DISPLAY_VALUE);
	        String strRelType = (String)mapExpr.get(bcr.RELATIONSHIP_TYPE);
	        
	        StringBuffer sb = new StringBuffer();
	        sb.append("ActualDisplay=");
	        sb.append(strActualString);
	        sb.append(",");
	        sb.append("DisplayString=");
	        sb.append(strDisplayString);
	        sb.append(",");
	        sb.append("RelationshipType=");
	        sb.append(strRelType);
	        sb.append("#");
	        out.write(sb.toString());
	    }
	     catch(Exception exp ){
	         System.out.println( " exp " +exp);
	    }
	 }else if(strMode!=null && strMode.equalsIgnoreCase("formatPCR")){
         out.clear();
         String strcheckedRelIds = emxGetParameter(request,"checkedRelIds");
         String strChkdObjectIds = emxGetParameter(request,"checkedObjectIds");
         String strParentIds = emxGetParameter(request,"checkedParentIds");
         com.matrixone.apps.configuration.BooleanOptionCompatibility bcr = new BooleanOptionCompatibility();
         try
        {
            Map mapExpr = bcr.formatExpressionForPCR(context,strcheckedRelIds,strParentIds,strChkdObjectIds);
            String strActualString = (String)mapExpr.get(bcr.ACTUAL_VALUE);
            String strDisplayString = (String)mapExpr.get(bcr.DISPLAY_VALUE);
            String strRelType = (String)mapExpr.get(bcr.RELATIONSHIP_TYPE);
            
            StringBuffer sb = new StringBuffer();
            sb.append("ActualDisplay=");
            sb.append(strActualString);
            sb.append(",");
            sb.append("DisplayString=");
            sb.append(strDisplayString);
	        sb.append(",");
	        sb.append("RelationshipType=");
	        sb.append(strRelType);
	        sb.append("#");
	        out.write(sb.toString());
        }
         catch(Exception exp ){
             System.out.println( " exp " +exp);
        }
     
	 }else if(strMode!=null && strMode.equalsIgnoreCase("formatMPR")){
         out.clear();
         String strcheckedRelIds = emxGetParameter(request,"checkedRelIds");
         String strParentIds = emxGetParameter(request,"checkedParentIds");
         String strChkdObjectIds = emxGetParameter(request,"checkedObjectIds");
         String featureOptionDetails = emxGetParameter(request,"featureOptionDetails");
        
         MarketingPreference mpr = new MarketingPreference();
         try
        {
            Map mapExpr = mpr.formatExpressionForMPR(context,strcheckedRelIds,strParentIds,strChkdObjectIds,featureOptionDetails);
            String strActualString = (String)mapExpr.get(mpr.ACTUAL_VALUE);
            String strDisplayString = (String)mapExpr.get(mpr.DISPLAY_VALUE);
            String strRelType = (String)mapExpr.get(mpr.RELATIONSHIP_TYPE);
            
            StringBuffer sb = new StringBuffer();
            sb.append("ActualDisplay=");
            sb.append(strActualString);
            sb.append(",");
            sb.append("DisplayString=");
            sb.append(strDisplayString);
	        sb.append(",");
	        sb.append("RelationshipType=");
	        sb.append(strRelType);
	        sb.append("#");
	        out.write(sb.toString());
        }
         catch(Exception exp ){
             System.out.println( " exp " +exp);
        }
     
     }else if(strMode!=null && strMode.equalsIgnoreCase("formatInclusionRule")){
         out.clear();
         String strcheckedRelIds = emxGetParameter(request,"checkedRelIds");
         String strParentIds = emxGetParameter(request,"checkedParentIds");
         String strChkdObjectIds = emxGetParameter(request,"checkedObjectIds");
         String featureOptionDetails = emxGetParameter(request,"featureOptionDetails");
       
         InclusionRule iRule = new InclusionRule();
         try
        {
            Map mapExpr = iRule.formatExpressionForInclusionRule(context,strcheckedRelIds,strParentIds,strChkdObjectIds,featureOptionDetails);
            String strActualString = (String)mapExpr.get(iRule.ACTUAL_VALUE);
            String strDisplayString = (String)mapExpr.get(iRule.DISPLAY_VALUE);
            String strRelType = (String)mapExpr.get(iRule.RELATIONSHIP_TYPE);
            
            StringBuffer sb = new StringBuffer();
            sb.append("ActualDisplay=");
            sb.append(strActualString);
            sb.append(",");
            sb.append("DisplayString=");
            sb.append(strDisplayString);
	        sb.append(",");
	        sb.append("RelationshipType=");
	        sb.append(strRelType);
	        sb.append("#");
	        out.write(sb.toString());
        }
         catch(Exception exp ){
             System.out.println( " exp " +exp);
        }
     }else if(strMode!=null && strMode.equalsIgnoreCase("SBRootNodeInfo")){
         out.clear();
         String strChkdObjectIds = emxGetParameter(request,"rootNodeID");
         ConfigurableRulesUtil ruleUtil = new ConfigurableRulesUtil();
         try
        {
            Map mapExpr = ruleUtil.getContextInfo(context,strChkdObjectIds);
            String contextType = (String)mapExpr.get(ConfigurationConstants.SELECT_TYPE);
            String isRootNodeProduct = (String)mapExpr.get("isRootNodeProduct");
            String isOfTypeFeatures = (String)mapExpr.get("isOfTypeFeatures");
            String isOfTypePV = (String)mapExpr.get("isOfTypePV");
            String isOfInvalidState = (String)mapExpr.get("isOfInvalidState");
            StringBuffer sb = new StringBuffer();
            sb.append("type=");
            sb.append(contextType);
            sb.append(",");
            sb.append("isOfTypeFeatures=");
            sb.append(isOfTypeFeatures);
            sb.append(",");
            sb.append("isOfTypePV=");
            sb.append(isOfTypePV);
            sb.append(",");
            sb.append("isOfInvalidState=");
            sb.append(isOfInvalidState);
            sb.append(",");
            sb.append("isRootNodeProduct=");
            sb.append(isRootNodeProduct);
            sb.append(";");
            out.write(sb.toString());
        }
         catch(Exception exp ){
             System.out.println( " exp " +exp);
        }
     
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

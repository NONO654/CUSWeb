<%--
 InclusionRuleEditPostProcess.jsp

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
<%@page import="com.matrixone.apps.configuration.Product"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%> 
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%> 
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page	import="matrix.util.StringList"%>
<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.configuration.InclusionRule"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
 
<%
boolean bFlag=false;

  String strRelId = emxGetParameter(request, "hRelId");
  //Checking the parent Feature/Product is in frozen state
  boolean stateFrozen = false;
  InclusionRule incRule = new InclusionRule();
  if(strRelId!=null)
  stateFrozen = incRule.isFeatureinFrozenState(context,strRelId);
  if(stateFrozen){
	  %>
      <script language="javascript" type="text/javaScript">
            alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.AddModifyInclusionRule</emxUtil:i18n>");
            parent.closeWindow();
      </script>
   <%
	  
  }
  else{

  try
  {
  String strType = emxGetParameter(request, "ruleType");
  String strRevision = "";
  String strOwner = "";
  String strReturnResult = "";
  
  //Values from Context Selector Component
  String immdParentOID = emxGetParameter(request, "parentFeatureId");
  
  String strLevel = emxGetParameter(request, "hRowLevel");  
  String strFeatureType = emxGetParameter(request, "featureType");
  String strRelationshipType = PropertyUtil.getSchemaProperty(context,strFeatureType);
  
  //Values from Right Expression Component
  String strRightExpressionText = emxGetParameter(request, "hrightExpObjTxt");
  String strRightExpressionObjIds = emxGetParameter(request, "hrightExpObjIds");
  
  //Old values for Edit
  String strOldREId = emxGetParameter(request, "hrightExpObjIdsForEdit");
  String strOldREText = emxGetParameter(request, "hrightExpObjTxtForEdit");
    
  String strContextType = emxGetParameter(request, "hContextType");
  String strRuleId = emxGetParameter(request, "hRuleId");
  
  String strObjId = emxGetParameter(request, "hmObjId");
  
  //Values from Comparison Operator Component
  String strCompatibilityStringInEdit = emxGetParameter(request, "comparisonOperator");
  
  String strName ="" ;
  String strDescription="" ;
  String strVault ="" ;
  String strPolicy ="" ;
  
  //Values from Completed Rule Component are not used for processing
 
    String strPdtId = emxGetParameter(request,"ProductId");
    String strParentOId = emxGetParameter(request,"hParentOID");
      Map bcrExpMap = new HashMap();
      
      bcrExpMap.put("rightExpObjectExp",strRightExpressionText);
      bcrExpMap.put("rightExpObjectIds",strRightExpressionObjIds);
      
      bcrExpMap.put("OldREId",strOldREId);
      bcrExpMap.put("OldREText",strOldREText);
      
      bcrExpMap.put("leftExpObjectExp","");
      bcrExpMap.put("OldLEId","");
     
     
      bcrExpMap.put("RuleId",strRuleId);
      
      StringList lstFeatureSelects = new StringList(DomainConstants.SELECT_ID);
      lstFeatureSelects.add(DomainConstants.SELECT_NAME);
      lstFeatureSelects.add(DomainConstants.SELECT_TYPE);
      lstFeatureSelects.add(DomainConstants.SELECT_REVISION);
      lstFeatureSelects.add(DomainConstants.SELECT_POLICY);
      lstFeatureSelects.add(DomainConstants.SELECT_VAULT);
      lstFeatureSelects.add(DomainConstants.SELECT_OWNER);
           
      Map objAttributeMap = new HashMap();
      Map relAttributeMap = new HashMap();
      
      objAttributeMap.put("Comparison Operator",strCompatibilityStringInEdit);
      
      //Edit existing Rule
     if((strRuleId!=null && !strRuleId.equals("")) || ((strRuleId!=null && !strRuleId.equals(""))))
      {
    	 
    	 //We do not have any Left Expression Component in Inclusion Rule.
    	 //Hence we didint set any values for hleftExpObjIdsForEdit,hleftExpObjTxtForEdit
    	 //For below API we need to set these values with Physical Ids.
    	 
    	 DomainObject domObjRuleId = new DomainObject(strRuleId);
    	 String strLeftExprVal = domObjRuleId.getAttributeValue(context,ConfigurationConstants.ATTRIBUTE_LEFT_EXPRESSION);
         
    	 bcrExpMap.put("leftExpObjectIds",strLeftExprVal);
    	 bcrExpMap.put("OldLEId",strLeftExprVal);
    	 
    	 bcrExpMap.put("relId",strRelId);
    	 DomainObject domRuleId = new DomainObject(strRuleId);
         Map mapRuleInfo = domRuleId.getInfo(context,(StringList) lstFeatureSelects);
         //Get the Context Type
         
          relAttributeMap.put("RelationshipType",strRelationshipType);
         
    	 //If context is PL
    	//if(strContextType!=null && strContextType.equals(ConfigurationConstants.TYPE_PRODUCT_LINE)){
    		 if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCT_LINE)){
    		ProductLine boBean = new ProductLine(strPdtId);
            strReturnResult = boBean.editComplexInclusionRule(context,
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_NAME),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_VAULT),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
                                                        bcrExpMap,
                                                        objAttributeMap,
                                                        relAttributeMap);
    	}else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCTS)){
    		//If context is Product
            Product boBean = new Product(strPdtId);
            strReturnResult = boBean.editComplexInclusionRule(context,
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_NAME),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_VAULT),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
                                                        bcrExpMap,
                                                        objAttributeMap,
                                                        relAttributeMap);
        }else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURES)){
        	
            //If context is CF
            ConfigurationFeature boBean = new ConfigurationFeature(strPdtId);
            strReturnResult = boBean.editComplexInclusionRule(context,
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_ID),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_TYPE),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_NAME),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_REVISION),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_POLICY),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_VAULT),
                                                       (String)mapRuleInfo.get(DomainConstants.SELECT_OWNER),
                                                        bcrExpMap,
                                                        objAttributeMap,
                                                        relAttributeMap);
        	
        	
        	
        }
      }else
      {
    	//Create 1st time
    	//We dont have the Rel ID between the Selected Obj and its Parent Obj.
    	//To extract 
    	if( ("".equals(strRelId)) || ("null".equals(strRelId))|| strRelId == null){
    		/* StringList RelationshipSelect = new StringList(ConfigurationConstants.SELECT_RELATIONSHIP_ID); 
            StringList sLRelationshipWhere = new StringList();
            sLRelationshipWhere.addElement("to.id" + "==" + strObjId);
            sLRelationshipWhere.addElement("&&");
            sLRelationshipWhere.addElement("from.id" + "==" + immdParentOID); */
            
            //Use Query connection
            /* StringBuffer sb= new StringBuffer();
            sb.append(ConfigurationConstants.RELATIONSHIP_CONFIGURATION_STRUCTURES);
            sb.append(",");
            sb.append(ConfigurationConstants.RELATIONSHIP_LOGICAL_STRUCTURES);
            sb.append(",");
            sb.append(ConfigurationConstants.RELATIONSHIP_MANUFACTURING_STRUCTURES);

            ProductLineCommon PL = new ProductLineCommon();
            MapList mLRelId = PL.queryConnection(context,
            		    sb.toString(),
                        RelationshipSelect,
                        sLRelationshipWhere.toString()); */
                
            MapList mLRelId = new MapList(); 
            StringList strSelect = new StringList();
            strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
            strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].id");
            strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
            strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].to.id");
            
            DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
            DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].id");
            DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
            DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].to.id");
            
            DomainObject ProductORCFObject = new DomainObject(immdParentOID);
            Map mapOfRelIds                = ProductORCFObject.getInfo(context, strSelect);
            
            DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
            DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].id");
            DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
            DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].to.id");
            
            StringList listOfConfFeatRelIds    = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
            StringList listOfConfOptionsRelIds = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].id");
            StringList listOfConfFeatIds       = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
            StringList listOfConfOptionsIds    = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS +"].to.id");
            
            if(listOfConfFeatRelIds != null)
            {
    	        for(int j = 0; j < listOfConfFeatRelIds.size(); j++)
    	        {
    	        	if(strObjId.equals(listOfConfFeatIds.get(j)))
    	        	{
    	        		Map mapOfObject = new HashMap();
    	        		mapOfObject.put("RelInfo", ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES);
    	        		mapOfObject.put("id[connection]", listOfConfFeatRelIds.get(j));
    	        		
    	        		mLRelId.add(mapOfObject);
    	        	}
    	        }
            }
            else if(listOfConfOptionsRelIds != null)
            {
    	        for(int j = 0; j < listOfConfOptionsRelIds.size(); j++)
    	        {
    	        	if(strObjId.equals(listOfConfOptionsIds.get(j)))
    	        	{
    	        		Map mapOfObject = new HashMap();
    	        		mapOfObject.put("RelInfo", ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS);
    	        		mapOfObject.put("id[connection]", listOfConfOptionsRelIds.get(j));
    	        		
    	        		mLRelId.add(mapOfObject);
    	        	}
    	        }
            }  
            
            for(int i=0;i<mLRelId.size();i++){
                strRelId = (String)((Map)(mLRelId.get(i))).get(DomainObject.SELECT_RELATIONSHIP_ID);   
            }
    	}
    	    
        bcrExpMap.put("relId",strRelId);
        bcrExpMap.put("leftExpObjectIds",strRelId);
        bcrExpMap.put("OldLEText",strRelId);
        relAttributeMap.put("RelationshipType",strRelationshipType);
        
    	//If context is PL
        if(strContextType!=null && strContextType.equals(ConfigurationConstants.TYPE_PRODUCT_LINE)){
            
            ProductLine boBean = new ProductLine(strPdtId);
            strReturnResult = boBean.createAndConnectComplexInclusionRule(context,
                                                                   strType,
                                                                   strName,
                                                                   strRevision,
                                                                   strPolicy,   
                                                                   strVault,
                                                                   strOwner,
                                                                   strRelId,
                                                                   strDescription, 
                                                                   bcrExpMap,
                                                                   objAttributeMap,
                                                                   relAttributeMap);
        	
        	
        }else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_PRODUCTS)){
            //If context is Product
        	 Product boBean = new Product(strPdtId);
             strReturnResult = boBean.createAndConnectComplexInclusionRule(context,
                                                                    strType,
                                                                    strName,
                                                                    strRevision,
                                                                    strPolicy,   
                                                                    strVault,
                                                                    strOwner,
                                                                    strRelId,
                                                                    strDescription, 
                                                                    bcrExpMap,
                                                                    objAttributeMap,
                                                                    relAttributeMap);
        } else if(mxType.isOfParentType(context,strContextType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURES)){
            
            //If context is CF
        	 ConfigurationFeature boBean = new ConfigurationFeature(strPdtId);
             strReturnResult = boBean.createAndConnectComplexInclusionRule(context,
                                                                    strType,
                                                                    strName,
                                                                    strRevision,
                                                                    strPolicy,   
                                                                    strVault,
                                                                    strOwner,
                                                                    strRelId,
                                                                    strDescription, 
                                                                    bcrExpMap,
                                                                    objAttributeMap,
                                                                    relAttributeMap);
        }
   
      }
      
   //starting for SB cell refresh
     Map objectMap = new HashMap();
     objectMap.put("id[level]", strLevel);
     objectMap.put("tomid["+ ConfigurationConstants.RELATIONSHIP_LEFT_EXPRESSION+ "].from.type", "Inclusion Rule");
     
     if(!ProductLineCommon.isNotNull(strRuleId)){
    	 strRuleId = strReturnResult; //in case rule is newly getting created.
     }
     
     objectMap.put("tomid["+ ConfigurationConstants.RELATIONSHIP_LEFT_EXPRESSION+ "].from.id", strRuleId);
     objectMap.put("type", strContextType);
     objectMap.put("id", strPdtId);
     objectMap.put("id[connection]", strRelId);
     objectMap.put("objectId", strParentOId);
    
     String IRHyperlink = InclusionRule.getInclusionRuleLink(context, objectMap);
     String  strRightExpressionTextencode=XSSUtil.encodeForXML(context,strRightExpressionText);
     if(strRightExpressionText != null && !strRightExpressionText.equals("")){    	
    	 strRightExpressionText = "<c>\""+strRightExpressionTextencode+"\"</c>";    
         strRightExpressionText = strRightExpressionText.replaceAll("\"", "\\\"");    
     }
     else{    	
    	 strRightExpressionText = "<c>"+strRightExpressionTextencode+"</c>";
     }
     
     %>
     <script language="javascript" type="text/javaScript">
     var level = "<%=XSSUtil.encodeForJavaScript(context,strLevel)%>";      
     var ruleType = '<%=XSSUtil.encodeForJavaScript(context,IRHyperlink)%>';     
     var ruleExpression = '<%=XSSUtil.encodeForJavaScript(context,strRightExpressionText)%>';
           
     </script>
     <%
     //ending for SB cell refresh
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
    
    var colMapObj = getTopWindow().getWindowOpener().colMap;    
    var RuleTypeColumn = colMapObj.getColumnByName("Rule Type");
    var RuleExpressionColumn = colMapObj.getColumnByName("Rule Expression");
    
    if(level != "null"){
    	getTopWindow().getWindowOpener().editableTable.updateXMLByRowId(level,ruleType,RuleTypeColumn.index);    
        getTopWindow().getWindowOpener().editableTable.updateXMLByRowId(level,ruleExpression,RuleExpressionColumn.index);        
    }
    else{
        getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    }    
    
    window.getTopWindow().closeWindow();
    </script>
<%}
  }
%>


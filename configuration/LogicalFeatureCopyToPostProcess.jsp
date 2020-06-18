<%--
  LogicalFeatureCopyToPostProcess.jsp
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
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.matrixone.apps.domain.util.mxType " %>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
  try
  { 
     String xml = "";    
     String strFeatureType = "";
     String strTargetObjId = "";
     MapList selectedFeatureList = new MapList();
     String relType = "relationship_LogicalFeatures";
     boolean booelanDesignResp = false;
     ConfigurationUtil util = new ConfigurationUtil();
     String strLanguage = context.getSession().getLanguage();
     String strContextNotSupportedForEquipmentFeature = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForEquipmentFeature",strLanguage);
     String strAlertMessageCopy = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAlreadyConnected", strLanguage);
     String strProductAsLogicalFeatureCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.ProductAsLogicalFeatureCheck",strLanguage);
     String strRDODifferentConfirmation = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.DifferentRDO", strLanguage);
     String strLeafLevelCopyCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.LeafLevel.CopyFrom", strLanguage);
     String strPartialCopied = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.PartialCopyOperation", strLanguage);
     boolean isDifferentDesignResp = true;
     boolean isError=false;
     
     String isFromPropertyPage = emxGetParameter(request, "isFromPropertyPage");
     
     Enumeration e = emxGetParameterNames(request);
     HashMap reqMap = new HashMap();
     
     while(e.hasMoreElements()){
     	String key = e.nextElement().toString();
     	String value = emxGetParameter(request, key);
     	reqMap.put(key, value);
     }
     
     if(isFromPropertyPage == null || "".equals(isFromPropertyPage))
    	 reqMap.put("isFromPropertyPage", "false");
     
     String selectedTableRowsID = (String)reqMap.get("emxTableRowId");     
     String strObjIdContext = emxGetParameter(request, "objectId");
     String userConfirmationOnDiffRDO = (String)reqMap.get("RDO");
     
     if(selectedTableRowsID.indexOf("|") > 0){
            StringTokenizer strTokenizer = new StringTokenizer(selectedTableRowsID , "|");
            strTokenizer.nextToken();    
            strTargetObjId = strTokenizer.nextToken().toString();
      }
      else{
            StringTokenizer strTokenizer = new StringTokenizer(selectedTableRowsID , "|");                       
            strTargetObjId = strTokenizer.nextToken().toString();                         
      }    
     String[] selectedTableIDList = (String[])session.getAttribute("selectedValues");  
     DomainObject domTargetObj = new DomainObject(strTargetObjId);
     
     StringList objectSelectList = new StringList();
     objectSelectList.addElement(DomainConstants.SELECT_TYPE);  
     objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);
     Hashtable parentInfoTable = (Hashtable) domTargetObj.getInfo(context, objectSelectList);
     String strLeafLeavel = (String)parentInfoTable.get(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);  
     
     String strParentType = (String)parentInfoTable.get("type");
      if(strParentType != null && !"".equals(strParentType) && strParentType.equalsIgnoreCase(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE))
    {
    	  out.clear();
          out.write(strContextNotSupportedForEquipmentFeature);        
          out.flush();        
    }
      else if(strParentType != null && !"".equals(strParentType) && !strTargetObjId.equals(strObjIdContext) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_PRODUCTS))
      {
      	   out.clear();    	  
           out.write(strProductAsLogicalFeatureCheck);
           out.flush();               
      }
      else if(strLeafLeavel.equalsIgnoreCase(ConfigurationConstants.RANGE_VALUE_LEAFLEVEL_YES))
      {
    	  out.clear();    	  
          out.write(strLeafLevelCopyCheck);
          out.flush();
      }
      else
      {
    	  for(int iCount=0; iCount < selectedTableIDList.length; iCount++){
    	        StringTokenizer sttableRowId = new StringTokenizer(selectedTableIDList[iCount].toString(), "|");
    	                       
    	        String strSourceRelId=sttableRowId.nextToken();
    	        String strFeatureId = sttableRowId.nextToken();
    	        sttableRowId.nextToken();
    	        String strFeatureLevelId = sttableRowId.nextToken();
    	        
    	        HashMap featureMap = new HashMap();
    	        featureMap.put("OId",strFeatureId);
    	        featureMap.put("LevelId",strFeatureLevelId);
    	        featureMap.put("SourceRelId",strSourceRelId);
    	        selectedFeatureList.add(featureMap);
    	    }
    	  //Check For different Design Resposibility
    	     String strSelectedFeatures[] = new String[selectedFeatureList.size()];
    	     for(int i=0;i<selectedFeatureList.size();i++)
    	     {
    	         Map mpselectedFeature = (Map)selectedFeatureList.get(i);
    	         strSelectedFeatures[i]=(String)mpselectedFeature.get("OId");
    	     }
    	     
    	     if(userConfirmationOnDiffRDO != null && userConfirmationOnDiffRDO.equals("YES")){
    	    	 booelanDesignResp = true;
    	     }
    	     else{
    	    	 isDifferentDesignResp =  util.isRDODifferent(context,strSelectedFeatures,strTargetObjId);
    	    	 if(isDifferentDesignResp)
        	     {
    	    		 booelanDesignResp = false;
        	    	 out.clear();
        	         out.write("CONFIRM::"+strRDODifferentConfirmation);
        	         out.flush();
        	     }
    	     }
    	     
    	     if(booelanDesignResp || !isDifferentDesignResp){
    	    //part of process to clone multilevel structure
    	    selectedFeatureList.sort("LevelId","ascending","String");
    	    
    	      if(reqMap.get("share").equals("on")){
    	         DomainObject domFeatureObj = new DomainObject(strTargetObjId);
    	         String strObjectPattern = ConfigurationConstants.TYPE_LOGICAL_STRUCTURES;
    	         String strRelPattern = ConfigurationConstants.RELATIONSHIP_LOGICAL_FEATURES;
    	         StringList objectSelects = new StringList(DomainConstants.SELECT_ID);
    	         StringList listSubFeats = new StringList();
    	         StringBuffer sb=new StringBuffer();   
    	         String prevXML="";
    	         
    	         MapList targetSubFeatureList = domFeatureObj.getRelatedObjects(context, strRelPattern, strObjectPattern, objectSelects, null, false,
    	                  true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING, 0);
    	         
    	         listSubFeats.add(strTargetObjId);

    	          for(int i=0;i<targetSubFeatureList.size();i++)
    	          {
    	              Map mapFeatureObj = (Map) targetSubFeatureList.get(i);
    	              if(mapFeatureObj.containsKey(objectSelects.get(0)))
    	              {
    	                  Object idsObject = mapFeatureObj.get(objectSelects.get(0));
    	                  if(idsObject.getClass().toString().contains("StringList")){
    	                      listSubFeats.addAll((StringList)idsObject);
    	                  }
    	                  else{
    	                      listSubFeats.add((String)idsObject);
    	                  }
    	              }
    	          }
    	         boolean isExistingLFSelected=false;
    	         for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
    	             String featureToShare = ((HashMap)selectedFeatureList.get(iCount)).get("OId").toString();
    	             String strSourceRelId=(String)((HashMap)selectedFeatureList.get(iCount)).get("SourceRelId");
    	             DomainObject sharedFeatureObj = new DomainObject(featureToShare);
                     strFeatureType = sharedFeatureObj.getInfo(context, "type");
                     if(!isExistingLFSelected && (listSubFeats.contains(featureToShare))){
                    	 isExistingLFSelected=true;
					 }
                     if(strFeatureType.equalsIgnoreCase(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE) && !strParentType.equalsIgnoreCase(ConfigurationConstants.TYPE_LOGICAL_FEATURE) ){
                        isError=true;
                    	out.clear();
                        out.write(strContextNotSupportedForEquipmentFeature);
                        out.flush();
                        break;
                     }                     
                     else if (!listSubFeats.contains(featureToShare)){
                         
//                          strAlertMessageCopy = "\'" + sharedFeatureObj.getInfo(context, DomainConstants.SELECT_TYPE) + " "+
//                          sharedFeatureObj.getInfo(context, DomainConstants.SELECT_NAME) +" "+
//                          sharedFeatureObj.getInfo(context, DomainConstants.SELECT_REVISION)+ "\'" + " " + strAlertMessageCopy ;
//                          isError=true;
//                           out.clear();
//                           out.write(strAlertMessageCopy);
//                           out.flush();
//                            break;                           
//                     }                     
//                      else{
    	                 //TODO need to pass existing values in XML instead of sending default values
    	                  Map paramMap = new HashMap();
    	                  paramMap.put("newObjectId", featureToShare);
    	                  paramMap.put("objectId", strTargetObjId);
    	                  paramMap.put("featureType",new DomainObject(featureToShare).getInfo(context, "type"));
    	                  paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
    	                  paramMap.put("languageStr",context.getSession().getLanguage());
    	                  paramMap.put("relId",""); 
    	                  paramMap.put("SourceRelId",strSourceRelId);
    	                  paramMap.put("Effectivity",(String)reqMap.get("Effectivity"));
    	                  prevXML= LogicalFeature.getXMLForSBCreate(context, paramMap, relType);                                
                          prevXML= prevXML.replace("\\","");
                          sb.append(prevXML);
                          sb.append("^");    	             
    	             }
    	             
    	         } 
    	         if(!isError){
    	         out.clearBuffer();
    	         if(isExistingLFSelected){
            		 out.write("ALERT_DUP::"+strPartialCopied+"#");
          	     }
                 xml=sb.toString();
                 if(xml.length()>0){
                 xml=xml.substring(0, xml.length() - 1);
                 out.write(xml);
                 }
                 out.flush();
    	         }
    	      }
    	      else if(reqMap.get("clone").equals("on")){
    	          DomainObject parentClonedObject;   
    	          DomainObject childClonedObject;
    	          HashMap connectedOIDMap = new HashMap();
    	          String parentOID = "";
    	          String childOID = "";
    	          Map cloneIdMap = new HashMap();
    	          StringBuffer sb=new StringBuffer();   
    	          String prevXML="";
    	          ArrayList<String> topLevelSourceLFList = new ArrayList<String>();
    	          ArrayList<String> topLevelCloneLFList = new ArrayList<String>();
    	          HashMap<String,String> sourceCloneObjIdMap = new HashMap<String,String>(); 
    	             for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
    	                 
    	                 HashMap featureMap = (HashMap)selectedFeatureList.get(iCount);
    	                 String featureToClone = (String)featureMap.get("OId");
    	                 String strFeatureLevelId = (String)featureMap.get("LevelId");
    	                 String strSourceRelId=(String)featureMap.get("SourceRelId");
    	                 String strPartFamily=new LogicalFeature(featureToClone).getPartFamilyLinkForXML(context);
    	                 if(!connectedOIDMap.containsKey(strFeatureLevelId)){
    	                     parentClonedObject = LogicalFeature.getCloneWithSelectedRelationships(context, featureToClone, reqMap);
    	                     parentOID = parentClonedObject.getInfo(context, "id");
    	                     strFeatureType = parentClonedObject.getInfo(context, "type");
    	                     cloneIdMap.put(featureToClone,parentOID);
    	                     if(strFeatureType.equalsIgnoreCase(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE) && !strParentType.equalsIgnoreCase(ConfigurationConstants.TYPE_LOGICAL_FEATURE) ){    	                      
    	                    	 isError=true; 
    	                    	 out.clear();
    	                          out.write(strContextNotSupportedForEquipmentFeature);
    	                          out.flush(); 
    	                        break;
    	                     }
    	                     else
    	                     {
    	                    	 Map paramMap = new HashMap();
                                 paramMap.put("newObjectId", parentOID);
                                 paramMap.put("objectId", strTargetObjId);
                                 paramMap.put("featureType",parentClonedObject.getInfo(context, "type"));
                                 paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
                                 paramMap.put("languageStr",context.getSession().getLanguage());
                                 paramMap.put("relId","");
                                 paramMap.put("SourceRelId",strSourceRelId);
                                 paramMap.put("PartFamilyDisplay",strPartFamily);
                                 paramMap.put("Effectivity",(String)reqMap.get("Effectivity"));
                                 prevXML= LogicalFeature.getXMLForSBCreate(context, paramMap, relType);                                
                                 prevXML= prevXML.replace("\\","");
                                 sb.append(prevXML);
                                 sb.append("^");
                                 connectedOIDMap.put(strFeatureLevelId, parentOID);  
                                 topLevelSourceLFList.add(featureToClone);
                                 topLevelCloneLFList.add(parentOID);
    	                     }
    	                    
    	                 }
    	                 else{
    	                     parentOID = connectedOIDMap.get(strFeatureLevelId).toString();
    	                     sourceCloneObjIdMap.put(featureToClone, parentOID);
    	                    }    	              
    	                 for(int j=iCount+1; j < selectedFeatureList.size(); j++) {
    	                     HashMap childMap = (HashMap)selectedFeatureList.get(j);
    	                     String strNextObjLevelId = (String)childMap.get("LevelId");
    	                     String strNextObjId = (String)childMap.get("OId");  
    	                     
    	                     if(!connectedOIDMap.containsKey(strNextObjLevelId) && strNextObjLevelId.startsWith(strFeatureLevelId+",") 
    	                             && strNextObjLevelId.split(",").length == strFeatureLevelId.split(",").length+1){    	                      
    	                          childClonedObject = LogicalFeature.getCloneWithSelectedRelationships(context, strNextObjId, reqMap);
    	                          childOID = childClonedObject.getInfo(context, "id");
    	                          cloneIdMap.put(strNextObjId,childOID);    	                        
    	                          DomainRelationship.connect(context, parentOID, ConfigurationConstants.RELATIONSHIP_LOGICAL_FEATURES, childOID, true);
    	                          connectedOIDMap.put(strNextObjLevelId, childOID);    	                
    	                     }                        
    	                 } 
    	              
    	             }  
    	             
    	             // Copy Effectivity on Clone Logical Features only if Effectivity checkbox is selected.
    	             String strEffectivity = (String)reqMap.get("Effectivity");
    	             if("on".equalsIgnoreCase(strEffectivity)){
    	                LogicalFeature.copyEffectivityOnClone(context, topLevelSourceLFList, topLevelCloneLFList, sourceCloneObjIdMap);
    	             }
    	                //For Design Variants
    	                 String strAll = (String)reqMap.get("All");
                         String strdesignvariant = (String)reqMap.get("Design Variants");
    	                 ArrayList includedOption = util.getIncludeData(context,"Logical Feature");
    	                 
    	             if( ((strAll != null && !strAll.equalsIgnoreCase("") && strAll.equalsIgnoreCase("on") ) || (strdesignvariant != null && !strdesignvariant.equalsIgnoreCase("") && strdesignvariant.equalsIgnoreCase("on") )) 
    	                     && includedOption.contains("Design Variants")) {
    	                	 LogicalFeature.copyDesignVariants(context,selectedFeatureList,cloneIdMap);
    	                 } 
    	             if(!isError){
    	             out.clearBuffer();
                     xml=sb.toString();
                     xml=xml.substring(0, xml.length() - 1);
                     out.write(xml);
                     out.flush();
    	             }
    	         }
    	     }
         }           
     }
     catch(Exception e)
     {    
 	 	out.clearBuffer();    	
	 	out.write(e.getMessage());
        out.flush();
 	 }
     %>
     
     

<%--
  ConfigurationFeatureCopyToPostProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Enumeration"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<%

  try
  { 
	 String xml = "";	 
	 String relType = "";	 
	 String strTargetObjId = "";
	 String strFeatureType = "";
	 String strTargetObjContextId = "";
	 String strLanguage = context.getSession().getLanguage();
	 MapList selectedFeatureList = new MapList();
	 boolean booelanDesignResp = false;
     ConfigurationUtil util = new ConfigurationUtil();
     String strVariantValueCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.VariantValueCheck",strLanguage);
     String strVariabilityOptionCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.VariabilityOptionCheck",strLanguage);
     String strKeyInTypeCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.KeyInTypeCheck",strLanguage);
     String strAlertMessageCopy =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAlreadyConnected", strLanguage);
     String strRDODifferentConfirmation = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.DifferentRDO", strLanguage);
     String strContextNotSupportedForVariantValue = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForVariantValue", strLanguage);
	 String strContextNotSupportedForVariabilityOption = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForVariabilityOption", strLanguage);
	 String strVariantNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariantNotAllowed", strLanguage);
	 String strVariabilityGroupNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariabilityGroupNotAllowed", strLanguage);
	 String strContextNotSupportedForConfOption = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForConfOption", strLanguage);
	 String strConfFeatNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.ConfFeatNotAllowed", strLanguage);
	 String strCannotShareOptions = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.CannotShareOptions", strLanguage);
	 String strPartialCopied = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.PartialCopyOperation", strLanguage);
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
     String userConfirmationOnDiffRDO = (String)reqMap.get("RDO");
     
   	 if(selectedTableRowsID.indexOf("|") > 0){
   		    StringTokenizer strTokenizer = new StringTokenizer(selectedTableRowsID , "|");
            strTokenizer.nextToken();    
            strTargetObjId = strTokenizer.nextToken().toString();
            //strTokenizer.nextToken();
            strTargetObjContextId = strTokenizer.nextToken().toString();
      }
      else{
     	    StringTokenizer strTokenizer = new StringTokenizer(selectedTableRowsID , "|");                       
     	    strTargetObjId = strTokenizer.nextToken().toString();                         
     	    strTargetObjContextId = strTargetObjId;
      }
    
     
 	 String[] selectedTableIDList = (String[])session.getAttribute("selectedValues");    	 
 	 
 	DomainObject domTargetObj = new DomainObject(strTargetObjId);
 	
 	StringList objectSelectList = new StringList();
    objectSelectList.addElement(ConfigurationConstants.SELECT_TYPE);
    objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE);
    Hashtable parentInfoTable = (Hashtable) domTargetObj.getInfo(context, objectSelectList);
    
    String strParentType = (String)parentInfoTable.get("type");
    String strParentKeyInType = (String)parentInfoTable.get("attribute[Key-In Type]");
    boolean isDifferentDesignResp = true;
    boolean isError=false;
    
    StringList vbgSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP);
    StringList vboSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYOPTION);
    StringList vrSubTypes  = ProductLineUtil.getChildrenTypes(context, ConfigurationConstants.TYPE_VARIANT);
    vrSubTypes.add(ConfigurationConstants.TYPE_VARIANT);
    StringList vrvSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIANTVALUE);
    StringList cfSubTypes  = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
    StringList CFTypes = new StringList();
    for(int i =0;i<cfSubTypes.size();i++){
   	 CFTypes.add(cfSubTypes.get(i));
    }
    //To remove Variant/Variability Group and their Sub Type from the list of Configuration Feature Sub Types. 
    CFTypes.removeAll(vrSubTypes);
    CFTypes.removeAll(vbgSubTypes);
    
    StringList coSubTypes  = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
    StringList COTypes = new StringList();
    for(int i =0;i<coSubTypes.size();i++){
   	 COTypes.add(coSubTypes.get(i));
    }
    //To remove Variant Value/Variability Option and their Sub Type from the list of Configuration Option Sub Types.
    COTypes.removeAll(vboSubTypes);
    COTypes.removeAll(vrvSubTypes);
    if(strParentType != null && !"".equals(strParentType) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_VARIANTVALUE))
    {
    	out.clear();
        out.write(strVariantValueCheck);
        out.flush();
    }
    else if(strParentType != null && !"".equals(strParentType) && mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_VARIABILITYOPTION))
    {
    	out.clear();
        out.write(strVariabilityOptionCheck);
        out.flush();
    }
    else{
    	for(int iCount=0; iCount < selectedTableIDList.length; iCount++){
            StringTokenizer sttableRowId = new StringTokenizer(selectedTableIDList[iCount], "|");
                           
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
       
          if(reqMap.get("share").toString().equals("on")){
        	              
             String strObjectPattern = ConfigurationConstants.TYPE_CONFIGURATION_FEATURES;
             String strRelPattern = ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+","+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS+","+
                                     ConfigurationConstants.RELATIONSHIP_MANDATORY_CONFIGURATION_FEATURES+","+ConfigurationConstants.RELATIONSHIP_CANDIDTAE_CONFIGURATION_FEATURES+","+
                                     ConfigurationConstants.RELATIONSHIP_COMMITTED_CONFIGURATION_FEATURES+","+ConfigurationConstants.RELATIONSHIP_VARIES_BY+","+
                                     ConfigurationConstants.RELATIONSHIP_INACTIVE_VARIES_BY;
             StringList objectSelects = new StringList(ConfigurationConstants.SELECT_ID);
             StringList listSubFeats = new StringList();
            
             
             MapList targetSubFeatureList = domTargetObj.getRelatedObjects(context, strRelPattern, strObjectPattern, objectSelects, null, false,
                      true, (short)1, ConfigurationConstants.EMPTY_STRING, ConfigurationConstants.EMPTY_STRING, 0);
             
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
              StringBuffer sb=new StringBuffer();   
 	         String prevXML=""; 
 	         boolean isExistingCFSelected=false;
             for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
                 String featureToShare = ((HashMap)selectedFeatureList.get(iCount)).get("OId").toString();
                 DomainObject sharedFeatureObj = new DomainObject(featureToShare);
                 strFeatureType = sharedFeatureObj.getInfo(context, "type");
                 String strSourceRelId=(String)((HashMap)selectedFeatureList.get(iCount)).get("SourceRelId");
                 boolean typeShareObj = new DomainObject(featureToShare).isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
                 boolean isSelectObj = new DomainObject(featureToShare).isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
                 boolean isTargetObj = domTargetObj.isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
                 
                 boolean isAllowed = false;
                 if(typeShareObj){
				    	isAllowed = false;
				    	isError = true;
				    	out.clear();
	                    out.write(strCannotShareOptions);
	                    out.flush();  
				    	
				    	break;
				 }
                 else if((isSelectObj && !isTargetObj) || (!isSelectObj  && !isTargetObj) || (!isSelectObj && isTargetObj)){
						isAllowed = true;
					}
                 if(!isExistingCFSelected && (listSubFeats.contains(featureToShare))){
						isExistingCFSelected=true;
				 }
				 if(isAllowed){
		                 if(strParentKeyInType != null && !"".equals(strParentKeyInType) && !strParentKeyInType.equalsIgnoreCase("Blank") && !mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION)){
		                     isError=true;
		                	 out.clear();
		                     out.write(strKeyInTypeCheck);
		                     out.flush();                    
		                    break;
			             }
			             else if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_VARIANTVALUE) && !mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_VARIANT) ){
			                 isError=true;
			            	 out.clear();
		                     out.write(strContextNotSupportedForVariantValue);
		                     out.flush(); 
			                break;
			             }
			             else if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_VARIABILITYOPTION) && !mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_VARIABILITYGROUP) ){
			                 isError=true;
			            	 out.clear();
		                     out.write(strContextNotSupportedForVariabilityOption);
		                     out.flush(); 
			                break;
			             }
			             else if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION) && !mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE) ){
			                 isError=true;
			            	 out.clear();
		                     out.write(strContextNotSupportedForConfOption);
		                     out.flush(); 
			                break;
			             }
			             else if(!listSubFeats.contains(featureToShare)){
// 		                     strAlertMessageCopy = "\'" + sharedFeatureObj.getInfo(context, ConfigurationConstants.SELECT_TYPE) + " "+
// 		                     sharedFeatureObj.getInfo(context, ConfigurationConstants.SELECT_NAME) +" "+
// 		                     sharedFeatureObj.getInfo(context, ConfigurationConstants.SELECT_REVISION)+ "\'" + " " + strAlertMessageCopy ;
// 		                     isError=true;
// 		                     out.clear();
// 		                     out.write(strAlertMessageCopy);
// 		                     out.flush();
// 		                    break;                
// 			             }
// 			             else{
			            	  // To Connect the Copied Variant/Variability Group/Configuration Fetaure with Product Line/Model Version.
                         	  String strRelName = ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES;
                         	  String[] arrToId = new String[1];
                         	  arrToId[0] = featureToShare;
                         	  Map map = DomainRelationship.connect(context, new DomainObject(strTargetObjId), strRelName, true, arrToId);
                         	  String relId = (String) map.get(featureToShare);
                         	  
                         	  // To set default value for Configuration Selection Criteria(Must/May) attribute as "May" for Variability Group always. 
                          	  if(vbgSubTypes.contains(strFeatureType))
                          	  {
                            	    DomainRelationship.setAttributeValue(context, relId, ConfigurationConstants.ATTRIBUTE_CONFIGURATION_SELECTION_CRITERIA, ConfigurationConstants.RANGE_VALUE_MAY);
                          	  }
		                      Map paramMap = new HashMap();
		                      paramMap.put("newObjectId", featureToShare);
		                      paramMap.put("objectId", strTargetObjId);
		                      paramMap.put("featureType",new DomainObject(featureToShare).getInfo(context, "type"));
		                      paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
		                      paramMap.put("languageStr",context.getSession().getLanguage());
		                      paramMap.put("relId",relId);
		                      paramMap.put("objectCreation","Existing");
		                      paramMap.put("SourceRelId",strSourceRelId);
		                      paramMap.put("Effectivity",(String)reqMap.get("Effectivity"));
		                      
		                      if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){
		                          relType = "relationship_ConfigurationFeatures";
		                      }
		                      else{
		                    	  if(vrvSubTypes.contains(strFeatureType)){
			                         	relType = "relationship_VariantValues";
			                      }
		                    	  else if(vboSubTypes.contains(strFeatureType)){
			                    		relType = "relationship_GroupedVariabilityCriteria";
			                      }
			                      else if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION)){
		                                 relType = "relationship_ConfigurationOptions";
		                          }
		                      } 
		                      prevXML= ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);                                
		                      prevXML= prevXML.replace("\\","");
		                      sb.append(prevXML);
		                      sb.append("^");
		                                      
			             }
				}else{
					  String strObjType = domTargetObj.getInfo(context, DomainConstants.SELECT_TYPE);
	              	  if(vrSubTypes.contains(strObjType)){
           	  	  	   throw new Exception(strVariantNotAllowed);
	              	  }else if(vbgSubTypes.contains(strObjType)){
	              		   throw new Exception(strVariabilityGroupNotAllowed);
	              	  }else if(CFTypes.contains(strObjType)){
	              		   throw new Exception(strConfFeatNotAllowed);
	              	  }
	            }
             } 
            
             if(!isError){
             out.clearBuffer();
             if(isExistingCFSelected){
        		 out.write("ALERT_DUP::"+strPartialCopied+"#");
      	     }
             xml=sb.toString();
             if(xml.length()>0){
             	xml=xml.substring(0, xml.length() - 1);
             	xml = xml.replaceAll("pending", "committed");
             	out.write(xml);
             }
             out.flush();
             }
          }
          else if(reqMap.get("clone").toString().equals("on")){
              DomainObject parentClonedObject;   
              DomainObject childClonedObject;
              HashMap connectedOIDMap = new HashMap();
              String parentOID = "";
              String childOID = "";
              String childType = "";
              StringBuffer sb=new StringBuffer();   
 	          String prevXML="";
 	         ArrayList<String> topLevelSourceCFList = new ArrayList<String>();
             ArrayList<String> topLevelCloneCFList = new ArrayList<String>();
             HashMap<String,String> sourceCloneObjIdMap = new HashMap<String,String>(); 
             
                 for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
                     
                     HashMap featureMap = (HashMap)selectedFeatureList.get(iCount);
                     String featureToClone = (String)featureMap.get("OId");
                     String strFeatureLevelId = (String)featureMap.get("LevelId");
                     String strSourceRelId=(String)featureMap.get("SourceRelId");
                     boolean isSelectObj = new DomainObject(featureToClone).isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
                     boolean isTargetObj = domTargetObj.isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
                     
                     boolean isAllowed = false;
    				 if((isSelectObj && !isTargetObj) || (!isSelectObj && !isTargetObj) || (!isSelectObj && isTargetObj)){
    						isAllowed = true;
    					}
    				 
                     if(isAllowed){
                    	 
                    	//START - Find context object type to set appropriate Effectivity
   						DomainObject domContextObj = new DomainObject(strTargetObjContextId);
   						String strContextObjType = domContextObj.getInfo(context, ConfigurationConstants.SELECT_TYPE);
   						StringList prdSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCTS);
   						//END
   						ConfigurationGovernanceCommon cfgGovCommonObj = new ConfigurationGovernanceCommon();
                    	 
		                     if(!connectedOIDMap.containsKey(strFeatureLevelId)){
		                         parentClonedObject = ConfigurationFeature.getCloneWithSelectedRelationships(context, featureToClone, reqMap);
		                         parentOID = parentClonedObject.getInfo(context, "id");
		                         strFeatureType = parentClonedObject.getInfo(context, "type");
		                         
		                         if(strParentKeyInType != null && !"".equals(strParentKeyInType) && !strParentKeyInType.equalsIgnoreCase("Blank") && !COTypes.contains(strFeatureType)){
		                        	 isError=true;
		                        	 out.clear();
		                             out.write(strKeyInTypeCheck);
		                             out.flush();         
		                             break;
		                         }
		                         else if(vrvSubTypes.contains(strFeatureType) && !vrSubTypes.contains(strParentType)){
		                        	 isError=true;
		                        	 out.clear();
		                             out.write(strContextNotSupportedForVariantValue);
		                             out.flush();         
		                             break;
		                         }
		                         else if(vboSubTypes.contains(strFeatureType) && !vbgSubTypes.contains(strParentType)){
		                        	 isError=true;
		                        	 out.clear();
		                             out.write(strContextNotSupportedForVariabilityOption);
		                             out.flush();         
		                             break;
		                         }
		                         else if(COTypes.contains(strFeatureType) && !CFTypes.contains(strParentType) ){
		                        	 isError=true;
		                        	 out.clear();
		                             out.write(strContextNotSupportedForConfOption);
		                             out.flush();         
		                             break;
		                         }
		                         else{
		                        	 // To Connect the Copied Variant/Variability Group/Configuration Feature with Product Line/Model Version.
		                             String strRelName = ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES;
		                             if(vrvSubTypes.contains(strFeatureType)){
		                             	strRelName = ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES;
		                             }
		                             else if(vboSubTypes.contains(strFeatureType)){
			                            strRelName = ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA;
			                         }
		                             else if(COTypes.contains(strFeatureType)){
			                            strRelName = ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS;
			                         }
		                             String[] arrToId = new String[1];
		                             arrToId[0] = parentOID;
		                             Map map = DomainRelationship.connect(context, new DomainObject(strTargetObjId), strRelName, true, arrToId);
		                             String relId = (String) map.get(parentOID);
		                             
		                             //START - To set appropriate effectivity on clone
		                            	//check rel type
		                            	if(strRelName.equalsIgnoreCase(ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES) || strRelName.equalsIgnoreCase(ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA)){
		                            		//Check Context
		                            		if(prdSubTypes.contains(strContextObjType)){
		                            			//call Modeler API to Set context product effectivity
		                            			cfgGovCommonObj.setProductEffectivity(context, relId, strTargetObjContextId);
		                            		}else{
		                            			//Call Modeler API to Set Dummy effectivity
		                            			cfgGovCommonObj.setGlobalEffectivity(context, relId);
		                            		}
		                            	}		                            	
		                            	//END
		                             
		                             // To set default value for Configuration Selection Criteria(Must/May) attribute as "May" for Variability Group always. 
		                          	 if(vbgSubTypes.contains(strFeatureType))
		                          	 {
		                            	    DomainRelationship.setAttributeValue(context, relId, ConfigurationConstants.ATTRIBUTE_CONFIGURATION_SELECTION_CRITERIA, ConfigurationConstants.RANGE_VALUE_MAY);
		                          	 }
		                        	 Map paramMap = new HashMap();
		                             paramMap.put("newObjectId", parentOID);
		                             paramMap.put("objectId", strTargetObjId);
		                             paramMap.put("featureType",parentClonedObject.getInfo(context, "type"));
		                             paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
		                             paramMap.put("languageStr",context.getSession().getLanguage());
		                             paramMap.put("relId",relId);                         
		                             paramMap.put("objectCreation","New");
		                             paramMap.put("parentOID",strTargetObjId);
		                             paramMap.put("SourceRelId",strSourceRelId);
		                             paramMap.put("Effectivity",(String)reqMap.get("Effectivity"));
		                             if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){
		                                 relType = "relationship_ConfigurationFeatures";
		                             }
		                             else{
		                            	 if(vrvSubTypes.contains(strFeatureType)){
		 		                         	relType = "relationship_VariantValues";
		 		                    	 }else if(vboSubTypes.contains(strFeatureType)){
		 		                    		relType = "relationship_GroupedVariabilityCriteria";
		 		                    	 }else if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION)){
			                                    relType = "relationship_ConfigurationOptions";
			                             }
		                             }                        
		                             prevXML= ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);                                
		                             prevXML= prevXML.replace("\\","");
		                             sb.append(prevXML);
		                             sb.append("^");
		                             connectedOIDMap.put(strFeatureLevelId, parentOID);
		                             topLevelSourceCFList.add(featureToClone);
		                             topLevelCloneCFList.add(parentOID);
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
		                                 &&  strNextObjLevelId.split(",").length == strFeatureLevelId.split(",").length+1){
		                          
		                              childClonedObject = ConfigurationFeature.getCloneWithSelectedRelationships(context, strNextObjId, reqMap);
		                              childOID = childClonedObject.getInfo(context, "id");
		                              childType = childClonedObject.getInfo(context, "type");
		                              
		                              Map relMap = new HashMap();
			                          String[] arrToID = new String[1];
			                          arrToID[0] = childOID;
		                              if(vrvSubTypes.contains(childType)){
		                            	  //DomainRelationship.connect(context, parentOID, ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES, childOID, true);
		                            	  relMap = DomainRelationship.connect(context, new DomainObject(parentOID), ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES, true, arrToID);
		 		                      }
		                              else if(vboSubTypes.contains(childType)){
		 		                    	  //DomainRelationship.connect(context, parentOID, ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA, childOID, true);
		                            	  relMap = DomainRelationship.connect(context, new DomainObject(parentOID), ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA, true, arrToID);
		 		                      }
		 		                      else if(mxType.isOfParentType(context,childType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION)){
		                                  //DomainRelationship.connect(context, parentOID, ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS, childOID, true);
		 		                    	 relMap = DomainRelationship.connect(context, new DomainObject(parentOID), ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS, true, arrToID);
		                              }
		                              
		                              String strRelId = (String) relMap.get(childOID);
		                            //START - To set appropriate effectivity on clone
		                            	//check rel type
		                            	if(vrvSubTypes.contains(childType) || vboSubTypes.contains(childType)){
		                            		//Check Context
		                            		if(prdSubTypes.contains(strContextObjType)){
		                            			//call Modeler API to Set context product effectivity
		                            			cfgGovCommonObj.setProductEffectivity(context, strRelId, strTargetObjContextId);
		                            		}else{
		                            			//Call Modeler API to Set Dummy effectivity
		                            			cfgGovCommonObj.setGlobalEffectivity(context, strRelId);
		                            		}
		                            	}		                            	
		                            	//END
		                              
		                              connectedOIDMap.put(strNextObjLevelId, childOID);
		                         }                        
		                     }
                     }else{
                    	 String strObjType = domTargetObj.getInfo(context, DomainConstants.SELECT_TYPE);
   	              	  if(vrSubTypes.contains(strObjType)){
                	  	  	   throw new Exception(strVariantNotAllowed);
   	              	  }else if(vbgSubTypes.contains(strObjType)){
   	              		   throw new Exception(strVariabilityGroupNotAllowed);
   	              	  }else if(CFTypes.contains(strObjType)){
	              		   throw new Exception(strConfFeatNotAllowed);
	              	  }
	            	}
                 }
                 
                 // Copy Effectivity on Clone Configuration Options only if Effectivity checkbox is selected.
                 /* String strEffectivity = (String)reqMap.get("Effectivity");
                 if("on".equalsIgnoreCase(strEffectivity)){
                       ConfigurationFeature.copyEffectivityOnClone(context, topLevelSourceCFList, topLevelCloneCFList, sourceCloneObjIdMap);
                 } */
                 
                 if(!isError){
                 out.clearBuffer();
                 xml=sb.toString();
                 if(xml.length()>0){
                 	xml=xml.substring(0, xml.length() - 1);
                 	xml = xml.replaceAll("pending", "committed");
                 	out.write(xml);
                 	}
                 out.flush();
                 }
             }
    	}
    } 		         
       
    }
    catch(Exception e)
    {    	
    		String msg = e.toString();
    		if(msg.contains("java.lang.Exception:")){
	    		msg = msg.replace("java.lang.Exception:","");
	    		out.clearBuffer();    	
	    	 	out.write(msg);    	 	
	            out.flush();
    		}
    		else{	
    	 		out.clearBuffer();    	
    	 		out.write(msg);    	 	
            	out.flush();
    		}
    }
    %>
     
    

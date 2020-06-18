<%--
  ConfigurationFeatureCopyFromPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
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
<%@page import="matrix.util.StringList"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon"%>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%

  try{ 
	 String xml = "";	 
	 boolean flagValidationFailed = false;
	 String strFeatureType = "";
     MapList selectedFeatureList = new MapList();
	 String relType = "";	 
	 String strLanguage = context.getSession().getLanguage();
	 String strKeyInTypeCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.KeyInTypeCheck",strLanguage);
	 String strContextNotSupportedForVariantValue = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForVariantValue", strLanguage);
	 String strContextNotSupportedForVariabilityOption = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForVariabilityOption", strLanguage);
	 String strContextNotSupportedForConfOption = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForConfOption", strLanguage);
	 String strAlertMessageCopy = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAlreadyConnected", strLanguage);
	 String strVariantNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariantNotAllowed", strLanguage);
	 String strVariabilityGroupNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.VariabilityGroupNotAllowed", strLanguage);
	 String strConfFeatNotAllowed = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.ConfFeatNotAllowed", strLanguage);
	 String strCannotShareOptions = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.CannotShareOptions", strLanguage);
	 String strPartialCopied = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.PartialCopyOperation", strLanguage);
     Enumeration e = emxGetParameterNames(request);
     HashMap reqMap = new HashMap();
     
     while(e.hasMoreElements()){
     	String key = e.nextElement().toString();
     	String value = emxGetParameter(request, key);
     	reqMap.put(key, value);
     }
	 
	
     String tableRowsIDs = (String)reqMap.get("emxTableRowId");
     String contextObjId = (String) reqMap.get("objIdContext");//context obj
     String strTargetObjId = (String) reqMap.get("objectId");//destination obj
     DomainObject domTargetObj = new DomainObject(strTargetObjId);
     boolean booelanDesignResp = false;   
     StringList objectSelectList = new StringList();
     objectSelectList.addElement(ConfigurationConstants.SELECT_TYPE);
     objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE);
     Hashtable parentInfoTable = (Hashtable) domTargetObj.getInfo(context, objectSelectList);     
     String strParentType = (String)parentInfoTable.get("type");
     String strParentKeyInType = (String)parentInfoTable.get("attribute[Key-In Type]");     
     StringTokenizer sttableRowIds = new StringTokenizer(tableRowsIDs, "&emxTableRowId=");
     //creating String array of selected feature to check RDO mismatch
     String[] strSelectedFetureArr = new String[sttableRowIds.countTokens()];     
     int count = 0;
     while(sttableRowIds.hasMoreElements()){
         StringTokenizer sttableRowId = new StringTokenizer(sttableRowIds.nextToken(), "|");
                        
         String strSourceRelId=sttableRowId.nextToken();
         String strFeatureId = sttableRowId.nextToken();
         sttableRowId.nextToken();
         String strFeatureLevelId = sttableRowId.nextToken();
         
         HashMap featureMap = new HashMap();
         featureMap.put("OId",strFeatureId);
         strSelectedFetureArr[count] = strFeatureId;
         featureMap.put("LevelId",strFeatureLevelId);
         featureMap.put("SourceRelId",strSourceRelId);
         selectedFeatureList.add(featureMap);
         count++;
     }
     
     StringList vbgSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP);
     StringList vboSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYOPTION);
     StringList vrSubTypes  = ProductLineUtil.getChildrenTypes(context, ConfigurationConstants.TYPE_VARIANT);
     vrSubTypes.add(ConfigurationConstants.TYPE_VARIANT);
     StringList vrvSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIANTVALUE);
     StringList cfSubTypes  = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
     StringList coSubTypes  = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
     StringList CFTypes = new StringList();
     for(int i =0;i<cfSubTypes.size();i++){
    	 CFTypes.add(cfSubTypes.get(i));
     }
     //To remove Variant/Variability Group and their Sub Type from the list of Configuration Feature Sub Types. 
     CFTypes.removeAll(vbgSubTypes);
     CFTypes.removeAll(vrSubTypes);

     StringList COTypes = new StringList();
     for(int i =0;i<coSubTypes.size();i++){
    	 COTypes.add(coSubTypes.get(i));
     }
     //To remove Variant Value/Variability Option and their Sub Type from the list of Configuration Option Sub Types.
     COTypes.removeAll(vboSubTypes);
     COTypes.removeAll(vrvSubTypes);
     boolean isDifferentDesignResp =  ConfigurationUtil.isRDODifferent(context,strSelectedFetureArr,strTargetObjId);    
     if(isDifferentDesignResp)
     {
         %>
             <script>
              var alertMsg = "<%=i18nNow.getI18nString("emxConfiguration.Alert.DifferentRDO",bundle,acceptLanguage)%>"
              var msg = confirm(alertMsg);                  
              if(!msg)
              {
            	  //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
            	  getTopWindow().closeWindow();
              }                  
              else
             {
                 <%   
                      booelanDesignResp =true;   
                 %>
             }                   
              </script>
              <%
     }
     else{
         booelanDesignResp =true;
     }
     
     if(booelanDesignResp){
    	//part of process to clone multilevel structure
         selectedFeatureList.sort("LevelId","ascending","String");
                 
         if(reqMap.get("share").toString().equals("on")){      
             String strObjectPattern = ConfigurationConstants.TYPE_CONFIGURATION_FEATURES;
             String strRelPattern = ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+","+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS+","+
                                     ConfigurationConstants.RELATIONSHIP_MANDATORY_CONFIGURATION_FEATURES+","+ConfigurationConstants.RELATIONSHIP_CANDIDTAE_CONFIGURATION_FEATURES+","+
                                     ConfigurationConstants.RELATIONSHIP_COMMITTED_CONFIGURATION_FEATURES;
             StringList objectSelects = new StringList(ConfigurationConstants.SELECT_ID);
             StringList listSubFeats = new StringList();             
             MapList targetSubFeatureList = domTargetObj.getRelatedObjects(context, strRelPattern, strObjectPattern, objectSelects, null, false,
                     true, (short)1, ConfigurationConstants.EMPTY_STRING, ConfigurationConstants.EMPTY_STRING, 0);             
             //creating list of all subfeatures connected at first level, including the target object id itself too      
             listSubFeats.add(strTargetObjId);
             String parentOID = "";
             
             for(int i=0;i<targetSubFeatureList.size();i++){
                 Map mapFeatureObj = (Map) targetSubFeatureList.get(i);
                 
                 if(mapFeatureObj.containsKey(ConfigurationConstants.SELECT_ID)){
                     Object idsObject = mapFeatureObj.get(ConfigurationConstants.SELECT_ID);
                     
                     if(idsObject.getClass().toString().contains("StringList")){
                         listSubFeats.addAll((StringList)idsObject);
                     }
                     else{
                         listSubFeats.add((String)idsObject);
                     }
                 }
             }
             boolean isExistingCFSelected=false;
             for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
                 String featureToShare = ((HashMap)selectedFeatureList.get(iCount)).get("OId").toString();
             	 String strSourceRelId =(String) ((HashMap)selectedFeatureList.get(iCount)).get("SourceRelId");
                 DomainObject sharedFeatureObj = new DomainObject(featureToShare);
                 strFeatureType = sharedFeatureObj.getInfo(context, "type");
                 //check to see if select feature to share, is already connected or not
                 boolean typeShareObj = sharedFeatureObj.isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
				 boolean typeTargetObj = domTargetObj.isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
				 boolean isAllowed = false;
				    if(typeShareObj){
				    	isAllowed = false;
				    	flagValidationFailed = true;
				    	%>
                        <script language="javascript" type="text/javaScript">
                              alert("<%=XSSUtil.encodeForJavaScript(context,strCannotShareOptions)%>");
                        </script>
                       <%
				    	break;
				    }
				    else if((typeTargetObj && typeShareObj) || (!typeTargetObj && !typeShareObj) || (!typeTargetObj && typeShareObj)){
						isAllowed = true;
					}
				if(!isExistingCFSelected && (listSubFeats.contains(featureToShare))){
					isExistingCFSelected=true;
			    }	
				if(isAllowed){
                 
		                 if(strParentKeyInType != null && !"".equals(strParentKeyInType) && !strParentKeyInType.equalsIgnoreCase("Blank") && !COTypes.contains(strFeatureType)){
		                         %>
		                         <script language="javascript" type="text/javaScript">
		                               alert("<%=XSSUtil.encodeForJavaScript(context,strKeyInTypeCheck)%>");
		                         </script>
		                        <%
		                        flagValidationFailed = true;
		                        break;
		                 }
		                 else if(vrvSubTypes.contains(strFeatureType) && !vrSubTypes.contains(strParentType) ){
		                     %>
		                     <script language="javascript" type="text/javaScript">
		                           alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForVariantValue)%>");
		                           //getTopWindow().window.location.href = getTopWindow().window.location.href;
		                           findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		                     </script>
		                    <%
		                    flagValidationFailed = true;
		                    break;
		                 }
		                 else if(vboSubTypes.contains(strFeatureType) && !vbgSubTypes.contains(strParentType) ){
		                     %>
		                     <script language="javascript" type="text/javaScript">
		                           alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForVariabilityOption)%>");
		                           //getTopWindow().window.location.href = getTopWindow().window.location.href;
		                           findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		                     </script>
		                    <%
		                    flagValidationFailed = true;
		                    break;
		                 }
		                 else if(COTypes.contains(strFeatureType) && !CFTypes.contains(strParentType) ){
                             %>
                             <script language="javascript" type="text/javaScript">
                                   alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForConfOption)%>");      
                                   findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
                             </script>
                            <%
                            flagValidationFailed = true;
                            break;
                         }
		                 else if(!listSubFeats.contains(featureToShare)){
		                     //if selected feature is already connected                 
		                     //strAlertMessageCopy = "\'" + sharedFeatureObj.getInfo(context, ConfigurationConstants.SELECT_TYPE) + " "+
		                     //sharedFeatureObj.getInfo(context, ConfigurationConstants.SELECT_NAME) +" "+
		                     //sharedFeatureObj.getInfo(context, ConfigurationConstants.SELECT_REVISION)+ "\'" + " " + strAlertMessageCopy ;
		                  
		                     //%>
		                       // <script language="javascript" type="text/javaScript">                                                            
		                         //   alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessageCopy)%>");            
		                           // getTopWindow().window.location.href = getTopWindow().window.location.href;
		                           //findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		                        //</script>
		                     //<% 
		                     //flagValidationFailed = true;
		                     //break;             
		                // }
		                 //else{
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
		                     paramMap.put("featureType", strFeatureType);
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
		                    	 }else if(vboSubTypes.contains(strFeatureType)){
		                    		relType = "relationship_GroupedVariabilityCriteria";
		                    	 }else if(mxType.isOfParentType(context,strFeatureType,ConfigurationConstants.TYPE_CONFIGURATION_OPTION)){
	                                 relType = "relationship_ConfigurationOptions";
	                             }
		                     }
		                     
		                     
		                     xml = ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);
		                     xml = xml.replaceAll("pending", "committed");
		                     boolean isProductContext = new DomainObject(strTargetObjId).isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
		                     %>
		                         <script language="javascript" type="text/javaScript">
		                         
		                                var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
		                                var detailsDisplayFrame = findFrame(getTopWindow().window.getWindowOpener().parent.getTopWindow(),"detailsDisplay");                               
		                                detailsDisplayFrame.emxEditableTable.addToSelected(strXml);
		                                
		                                // Code will get call for Model Version - To add the Created object in Structure Tree
		                                var isProductContext = "<%=isProductContext%>";
		                                if("true" == isProductContext){
		                                  var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");          
		                                  contentFrame.addMultipleStructureNodes("<%=featureToShare%>", "<%=strTargetObjId%>", '', '', false);
		                                }
		                         </script>
		                     <%              
		                 }   
             	}else{
	              	  %>
	                  <script language="javascript" type="text/javaScript">                     
	                  findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
	                  </script>
	              	  <% 
                  	  flagValidationFailed=true;
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
             if(flagValidationFailed == false){
             %>
                 <script language="javascript" type="text/javaScript">
                    //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    var isExistingCFSelected="<%=isExistingCFSelected%>";
                    if(isExistingCFSelected=="true"){
                       alert("<%=strPartialCopied%>");
                    }                   
                    getTopWindow().closeWindow();
                 </script>
             <% 
             }
         }
         else if(reqMap.get("clone").toString().equals("on")){
                DomainObject parentClonedObject;   
                DomainObject childClonedObject;
                HashMap connectedOIDMap = new HashMap();
                String parentOID = "";
                String childOID = "";
                String childType = "";
                ArrayList<String> topLevelSourceCFList = new ArrayList<String>();
                ArrayList<String> topLevelCloneCFList = new ArrayList<String>();
                HashMap<String,String> sourceCloneObjIdMap = new HashMap<String,String>(); 
                //for loop to connect the top level features via markup xml and the child features with top level features
                for(int iCount=0; iCount< selectedFeatureList.size(); iCount++){
                
                    HashMap featureMap = (HashMap)selectedFeatureList.get(iCount);
                    String featureToClone = (String)featureMap.get("OId");
                    String strFeatureLevelId = (String)featureMap.get("LevelId");
                    String strSourceRelId = (String)featureMap.get("SourceRelId");
                    boolean typeCloneObj = new DomainObject(featureToClone).isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
  					boolean typeTargetObj = domTargetObj.isKindOf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
  					boolean isAllowed = false;
  					if((typeTargetObj && typeCloneObj) || (!typeTargetObj && !typeCloneObj) || (!typeTargetObj && typeCloneObj)){
  						isAllowed = true;
  					}
  					
  					if(isAllowed){		
                   
  						//START - Find context object type to set appropriate Effectivity
  						DomainObject domContextObj = new DomainObject(contextObjId);
  						String strContextObjType = domContextObj.getInfo(context, ConfigurationConstants.SELECT_TYPE);
  						StringList prdSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCTS);
  						//END
  						ConfigurationGovernanceCommon cfgGovCommonObj = new ConfigurationGovernanceCommon();
                   
		                    if(!connectedOIDMap.containsKey(strFeatureLevelId)){                            
		                            parentClonedObject = ConfigurationFeature.getCloneWithSelectedRelationships(context, featureToClone, reqMap);                            
		                            parentOID = parentClonedObject.getInfo(context, "id");
		                            strFeatureType = parentClonedObject.getInfo(context, "type");                            
		                            if(strParentKeyInType != null && !"".equals(strParentKeyInType) && !strParentKeyInType.equalsIgnoreCase("Blank") && !COTypes.contains(strFeatureType)){
		                                %>
		                                <script language="javascript" type="text/javaScript">                                  
		                                      alert("<%=XSSUtil.encodeForJavaScript(context,strKeyInTypeCheck)%>");
		                                </script>
		                               <%
		                               flagValidationFailed = true;
		                               break;
		                            }
		                            else if(vrvSubTypes.contains(strFeatureType) && !vrSubTypes.contains(strParentType) ){
		                                %>
		                                <script language="javascript" type="text/javaScript">
		                                      alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForVariantValue)%>");      
		                                      findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		                                </script>
		                               <%
		                               flagValidationFailed = true;
		                               break;
		                            }
		                            else if(vboSubTypes.contains(strFeatureType) && !vbgSubTypes.contains(strParentType) ){
		                                %>
		                                <script language="javascript" type="text/javaScript">
		                                      alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForVariabilityOption)%>");      
		                                      findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		                                </script>
		                               <%
		                               flagValidationFailed = true;
		                               break;
		                            }
		                            else if(COTypes.contains(strFeatureType) && !CFTypes.contains(strParentType) ){
		                                %>
		                                <script language="javascript" type="text/javaScript">
		                                      alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForConfOption)%>");      
		                                      findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		                                </script>
		                               <%
		                               flagValidationFailed = true;
		                               break;
		                            }
		                            else{
		                            	// To Connect the Copied Variant/Variability Group/Configuration Feature with Product Line/Model Version.
		                            	String strRelName = ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES;
		                            	if(vrvSubTypes.contains(strFeatureType)){
		                            		strRelName = ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES;
		                            	}else if(vboSubTypes.contains(strFeatureType)){
		                            		strRelName = ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA;
		                            	}else if(COTypes.contains(strFeatureType)){
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
		                            			cfgGovCommonObj.setProductEffectivity(context, relId, contextObjId);
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
		                                paramMap.put("featureType",strFeatureType);
		                                paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
		                                paramMap.put("languageStr",context.getSession().getLanguage());
		                                paramMap.put("relId", relId);
		                                paramMap.put("objectCreation","New");
                    					paramMap.put("SourceRelId",strSourceRelId);
                    					paramMap.put("Effectivity",(String)reqMap.get("Effectivity"));
                    					paramMap.put("parentOID", strTargetObjId);
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
		                                
		                                xml = ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);
		                                xml = xml.replaceAll("pending", "committed");
		                                boolean isProductContext = new DomainObject(strTargetObjId).isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
		                                %>
		                                    <script language="javascript" type="text/javaScript">
		                                           var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";                                           
		                                           var detailsDisplayFrame = findFrame(getTopWindow().window.getWindowOpener().parent.getTopWindow(),"detailsDisplay");                                                                                                   
		                                           detailsDisplayFrame.emxEditableTable.addToSelected(strXml);
		                                           
		                                           // Code will get call for Model Version - To add the Created object in Structure Tree
		   		                                   var isProductContext = "<%=isProductContext%>";
		   		                                   if("true" == isProductContext){
		   		                                      var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");          
		   		                                      contentFrame.addMultipleStructureNodes("<%=parentOID%>", "<%=strTargetObjId%>", '', '', false);
		   		                                   }
		                                    </script>
		                                <% 
		                                connectedOIDMap.put(strFeatureLevelId, parentOID);
		                                topLevelSourceCFList.add(featureToClone);
		                                topLevelCloneCFList.add(parentOID);
		                            }   
		                    }
		                    else{
		                        parentOID = connectedOIDMap.get(strFeatureLevelId).toString();
		                        sourceCloneObjIdMap.put(featureToClone, parentOID);
		                    }
		                    // to preserve the hierarchy if there is any in selected features
		                    for(int j=iCount+1; j < selectedFeatureList.size(); j++) {
		                        HashMap childMap = (HashMap)selectedFeatureList.get(j);
		                        String strNextObjLevelId = (String)childMap.get("LevelId");
		                        String strNextObjId = (String)childMap.get("OId");
		                     
		                        if(!connectedOIDMap.containsKey(strNextObjLevelId) && strNextObjLevelId.startsWith(strFeatureLevelId+",") 
		                                && strNextObjLevelId.split(",").length == strFeatureLevelId.split(",").length+1){                     
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
		                            			cfgGovCommonObj.setProductEffectivity(context, strRelId, contextObjId);
		                            		}else{
		                            			//Call Modeler API to Set Global effectivity
		                            			cfgGovCommonObj.setGlobalEffectivity(context, strRelId);
		                            		}
		                            	}		                            	
		                            	//END		                             
		                             
		                             connectedOIDMap.put(strNextObjLevelId, childOID);
		                        }                        
		                    }
 
                }else{
	              	  %>
	                  <script language="javascript" type="text/javaScript">                     
	                  findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
	                  </script>
	              	  <% 
                  	  flagValidationFailed=true;
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
/*                 String strEffectivity = (String)reqMap.get("Effectivity");
                if("on".equalsIgnoreCase(strEffectivity)){
                      ConfigurationFeature.copyEffectivityOnClone(context, topLevelSourceCFList, topLevelCloneCFList, sourceCloneObjIdMap);
                } */
                
                if(flagValidationFailed == false){
                 %>
                     <script language="javascript" type="text/javaScript">                     
                        //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                        getTopWindow().closeWindow();
                     </script>
                 <% 
                 }        
     		}
    	 } 
     }
     catch(Exception e)
     {    
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

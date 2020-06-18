<%--
  LogicalFeatureCopyFromPostProcess.jsp
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
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="matrix.util.StringList"%>

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
     String relType = "relationship_LogicalFeatures";
     boolean booelanDesignResp = false;
     ConfigurationUtil util = new ConfigurationUtil();
     String strLanguage = context.getSession().getLanguage();
     String strContextNotSupportedForEquipmentFeature = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForEquipmentFeature",strLanguage);
     String strAlertMessageCopy = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAlreadyConnected",strLanguage);
     String strPartialCopied = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.PartialCopyOperation", strLanguage);
     Enumeration e = emxGetParameterNames(request);
     HashMap reqMap = new HashMap();
     
     while(e.hasMoreElements()){
     	String key = e.nextElement().toString();
     	String value = emxGetParameter(request, key);
     	reqMap.put(key, value);
     }
     
     String tableRowsIDs = (String)reqMap.get("emxTableRowId");   
    String strTargetObjId = (String)reqMap.get("objectId");//destination obj
 
     DomainObject domFeatureObj = new DomainObject(strTargetObjId);     
     StringList objectSelectList = new StringList();
     objectSelectList.addElement(DomainConstants.SELECT_TYPE);
     Hashtable parentInfoTable = (Hashtable) domFeatureObj.getInfo(context, objectSelectList);
     String strParentType = (String)parentInfoTable.get("type");      
     StringTokenizer sttableRowIds = new StringTokenizer(tableRowsIDs, "&emxTableRowId=");
          
     while(sttableRowIds.hasMoreElements()){
         StringTokenizer sttableRowId = new StringTokenizer(sttableRowIds.nextToken(), "|");
                        
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
     boolean isDifferentDesignResp =  util.isRDODifferent(context,strSelectedFeatures,strTargetObjId);
     if(isDifferentDesignResp)
     {

         %>
             <script>
              var alertMsg = "<%=i18nNow.getI18nString("emxConfiguration.Alert.DifferentRDO",bundle,acceptLanguage)%>"
              var msg = confirm(alertMsg);                  
              if(!msg)
              {
            	//  parent.location.href = "../common/emxCloseWindow.jsp";
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
         String strObjectPattern = ConfigurationConstants.TYPE_LOGICAL_STRUCTURES;
         String strRelPattern = ConfigurationConstants.RELATIONSHIP_LOGICAL_FEATURES;
         StringList objectSelects = new StringList(DomainConstants.SELECT_ID);
         StringList listSubFeats = new StringList();
         
         MapList targetSubFeatureList = domFeatureObj.getRelatedObjects(context, strRelPattern, strObjectPattern, objectSelects, null, false,
                 true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING, 0);
         
         //creating list of all subfeatures connected at first level, including the target object id itself too      
         listSubFeats.add(strTargetObjId);
         
         for(int i=0;i<targetSubFeatureList.size();i++){
             Map mapFeatureObj = (Map) targetSubFeatureList.get(i);
             
             if(mapFeatureObj.containsKey(DomainConstants.SELECT_ID)){
                 Object idsObject = mapFeatureObj.get(DomainConstants.SELECT_ID);
                 
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
             String strSourceRelId = (String)((HashMap)selectedFeatureList.get(iCount)).get("SourceRelId");
             DomainObject sharedFeatureObj = new DomainObject(featureToShare);
             strFeatureType = sharedFeatureObj.getInfo(context, "type");
             if(!isExistingLFSelected && (listSubFeats.contains(featureToShare))){
            	 isExistingLFSelected=true;
			 }
             if(strFeatureType.equalsIgnoreCase(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE) && !strParentType.equalsIgnoreCase(ConfigurationConstants.TYPE_LOGICAL_FEATURE) ){
                 %>
                 <script language="javascript" type="text/javaScript">
                       alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForEquipmentFeature)%>");
                       parent.window.location.href = parent.window.location.href; 
                       parent.window.getWindowOpener().location.href = parent.window.getWindowOpener().location.href; 
                 </script>
                <%
                flagValidationFailed = true;
                break;
             }
             //check to see if select feature to share, is already connected or not
             else if(!listSubFeats.contains(featureToShare)){
            	 //if selected feature is already connected                
//                 strAlertMessageCopy = "\'" + new DomainObject(featureToShare).getInfo(context, DomainConstants.SELECT_TYPE) + " "+
//                 new DomainObject(featureToShare).getInfo(context, DomainConstants.SELECT_NAME) +" "+
//                 new DomainObject(featureToShare).getInfo(context, DomainConstants.SELECT_REVISION)+ "\'" + " " + strAlertMessageCopy ;
//                 
//                %>
//                    <script language="javascript" type="text/javaScript">                 
//                        alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessageCopy)%>");            
//                        parent.window.location.href = parent.window.location.href; 
//                        parent.window.getWindowOpener().location.href = parent.window.getWindowOpener().location.href;                             
//                    </script>
//                 <% 
//                 flagValidationFailed = true;
//                 break;
             
//             }
//             else{

                 //TODO need to pass existing values in XML instead of sending default values
                 Map paramMap = new HashMap();
                 paramMap.put("newObjectId", featureToShare);
                 paramMap.put("objectId", strTargetObjId);
                 paramMap.put("featureType",strFeatureType);
                 paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
                 paramMap.put("languageStr",context.getSession().getLanguage());
                 paramMap.put("relId","");
                 paramMap.put("SourceRelId",strSourceRelId);
                 paramMap.put("Effectivity",(String)reqMap.get("Effectivity"));
                                  
                 xml = LogicalFeature.getXMLForSBCreate(context, paramMap, relType);
                 %>
                     <script language="javascript" type="text/javaScript">
                            var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";                        
                          getTopWindow().window.getWindowOpener().parent.emxEditableTable.addToSelected(strXml);        
                     </script>
                 <% 
             
             }
         }  
         
         if(flagValidationFailed == false){
         %>
             <script language="javascript" type="text/javaScript">            
             //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
             var isExistingLFSelected="<%=isExistingLFSelected%>";
             if(isExistingLFSelected=="true"){
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
            Map cloneIdMap = new HashMap();
            ArrayList<String> topLevelSourceLFList = new ArrayList<String>();
            ArrayList<String> topLevelCloneLFList = new ArrayList<String>();
            HashMap<String,String> sourceCloneObjIdMap = new HashMap<String,String>(); 
            //for loop to connect the top level features via markup xml and the child features with top level features
            for(int iCount=0; iCount< selectedFeatureList.size(); iCount++){
            
                HashMap featureMap = (HashMap)selectedFeatureList.get(iCount);
                String featureToClone = (String)featureMap.get("OId");
                String strFeatureLevelId = (String)featureMap.get("LevelId");
                String strSourceRelId = ((HashMap)selectedFeatureList.get(iCount)).get("SourceRelId").toString();
                
                String strPartFamily=new LogicalFeature(featureToClone).getPartFamilyLinkForXML(context);
                if(!connectedOIDMap.containsKey(strFeatureLevelId)){
                    parentClonedObject = LogicalFeature.getCloneWithSelectedRelationships(context, featureToClone, reqMap);
                    parentOID = parentClonedObject.getInfo(context, "id");
                    cloneIdMap.put(featureToClone,parentOID);
                    

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
                    
                    xml = LogicalFeature.getXMLForSBCreate(context, paramMap, relType);
                    %>
                        <script language="javascript" type="text/javaScript">
                              var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";                                    
                              getTopWindow().window.getWindowOpener().parent.emxEditableTable.addToSelected(strXml);
                        </script>
                    <% 
                    connectedOIDMap.put(strFeatureLevelId, parentOID);      
                    topLevelSourceLFList.add(featureToClone);
                    topLevelCloneLFList.add(parentOID);
                    
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
            
            %>
                <script language="javascript" type="text/javaScript">                          
                //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                getTopWindow().closeWindow();
                </script>
            <% 
        }
     }
     session.removeAttribute("selectedValues");
       
     }
     catch(Exception e)
     {
            session.removeAttribute("selectedValues"); 
            session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

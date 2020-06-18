<%--
  ManufacturingFeatureCopyToPostProcess.jsp
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
<%@page import="com.matrixone.apps.common.util.FormBean"%> 
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.ManufacturingFeature"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@ page import="java.util.*"%>
<%@ page import="com.matrixone.apps.domain.util.mxType " %>
<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>


<%@page import="matrix.db.BusinessObject"%><script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%
boolean bIsError = false;
String action = "";
String msg = "";

  try
  { 
     String xml = "";    
     boolean flagValidationFailed = false;
     String strFeatureType = "";
     String strTargetObjId = "";
     MapList selectedFeatureList = new MapList();
     String relType = "relationship_ManufacturingFeatures";
     boolean booelanDesignResp = false;
     ConfigurationUtil util = new ConfigurationUtil();
     String strLanguage = context.getSession().getLanguage();
     String strContextNotSupportedForEquipmentFeature = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForEquipmentFeature",strLanguage);
     String strAlertMessageCopy = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureAlreadyConnected",strLanguage);
     com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();  
     formBean.processForm(session,request);
     String selectedTableRowsID = (String)formBean.getElementValue("emxTableRowId");
     
     if(selectedTableRowsID.indexOf("|") > 0){
            StringTokenizer strTokenizer = new StringTokenizer(selectedTableRowsID , "|");
            strTokenizer.nextToken();    
            strTargetObjId = strTokenizer.nextToken().toString();
      }
      else{
            StringTokenizer strTokenizer = new StringTokenizer(selectedTableRowsID , "|");                       
            strTargetObjId = strTokenizer.nextToken().toString();                         
      }
    
     
     Map selectedMap = (Map)session.getAttribute("selectedValues");      
     StringList selectedTableIDList = (StringList)selectedMap.get("selectedTableIDList");
     DomainObject domTargetObj = new DomainObject(strTargetObjId);
     
     StringList objectSelectList = new StringList();
     objectSelectList.addElement(DomainConstants.SELECT_TYPE);  
     Hashtable parentInfoTable = (Hashtable) domTargetObj.getInfo(context, objectSelectList);
     
     String strParentType = (String)parentInfoTable.get("type");
       
          for(int iCount=0; iCount < selectedTableIDList.size(); iCount++){
                StringTokenizer sttableRowId = new StringTokenizer(selectedTableIDList.get(iCount).toString(), "|");
                               
                String strRelId = sttableRowId.nextToken();
                String strFeatureId = sttableRowId.nextToken();
                String strFeatureParentId = sttableRowId.nextToken();
                String strFeatureLevelId = sttableRowId.nextToken();
                
                HashMap featureMap = new HashMap();
                featureMap.put("OId",strFeatureId);
                featureMap.put("LevelId",strFeatureLevelId);
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
                          
                          //parent.location.href = "../common/emxCloseWindow.jsp";
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
            
              if(selectedMap.get("share").equals("on")){
                 DomainObject domFeatureObj = new DomainObject(strTargetObjId);
                 String strObjectPattern = ConfigurationConstants.TYPE_LOGICAL_STRUCTURES;
                 String strRelPattern = ConfigurationConstants.RELATIONSHIP_MANUFACTURING_FEATURES;
                 StringList objectSelects = new StringList(DomainConstants.SELECT_ID);
                 StringList listSubFeats = new StringList();
                 
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
                  
                 for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
                     String featureToShare = ((HashMap)selectedFeatureList.get(iCount)).get("OId").toString();
                     DomainObject sharedFeatureObj = new DomainObject(featureToShare);
                     strFeatureType = sharedFeatureObj.getInfo(context, "type");
                     
                                      
                      if (listSubFeats.contains(featureToShare)){
                         
                         strAlertMessageCopy = "\'" + sharedFeatureObj.getInfo(context, DomainConstants.SELECT_TYPE) + " "+
                         sharedFeatureObj.getInfo(context, DomainConstants.SELECT_NAME) +" "+
                         sharedFeatureObj.getInfo(context, DomainConstants.SELECT_REVISION)+ "\'" + " " + strAlertMessageCopy ;
                            %>
                        <script language="javascript" type="text/javaScript">                 
                            alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessageCopy)%>");
                        </script>
                          <% 
                           break;
                           
                    }
                     
                     else{
                         //TODO need to pass existing values in XML instead of sending default values
                         Map paramMap = new HashMap();
                          paramMap.put("newObjectId", featureToShare);
                          paramMap.put("objectId", strTargetObjId);
                          paramMap.put("featureType",new DomainObject(featureToShare).getInfo(context, "type"));
                          paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
                          paramMap.put("languageStr",context.getSession().getLanguage());
                          paramMap.put("relId","");
                          
                          
                          xml = ManufacturingFeature.getXMLForSBCreate(context, paramMap, relType);
                          %>
                              <script language="javascript" type="text/javaScript">
                                     var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                                     var pagecontentFrame = findFrame(getTopWindow(),"pagecontent");
                                     var FeatureSelectionFrame = findFrame(pagecontentFrame,"FeatureSelection");
                                     FeatureSelectionFrame.emxEditableTable.addToSelected(strXml);
                              </script>
                          <% 
                     }
                     
                 }  
                 
              }
              else if(selectedMap.get("clone").equals("on")){
                  DomainObject parentClonedObject;   
                  DomainObject childClonedObject;
                  HashMap connectedOIDMap = new HashMap();
                  String parentOID = "";
                  String childOID = "";
                  Map cloneIdMap = new HashMap();
                                      
                     for(int iCount=0; iCount < selectedFeatureList.size(); iCount++){
                         
                         HashMap featureMap = (HashMap)selectedFeatureList.get(iCount);
                         String featureToClone = (String)featureMap.get("OId");
                         String strFeatureLevelId = (String)featureMap.get("LevelId");
                         
                         if(!connectedOIDMap.containsKey(strFeatureLevelId)){
                             parentClonedObject = ManufacturingFeature.getCloneWithSelectedRelationships(context, featureToClone, selectedMap);
                             parentOID = parentClonedObject.getInfo(context, "id");
                             strFeatureType = parentClonedObject.getInfo(context, "type");
                             cloneIdMap.put(featureToClone,parentOID);
                    
                          
                             
                                 Map paramMap = new HashMap();
                                 paramMap.put("newObjectId", parentOID);
                                 paramMap.put("objectId", strTargetObjId);
                                 paramMap.put("featureType",parentClonedObject.getInfo(context, "type"));
                                 paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
                                 paramMap.put("languageStr",context.getSession().getLanguage());
                                 paramMap.put("relId","");
                                                     
                                 xml = ManufacturingFeature.getXMLForSBCreate(context, paramMap, relType);
                                 %>
                                     <script language="javascript" type="text/javaScript">
                                            var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                                            var pagecontentFrame = findFrame(getTopWindow(),"pagecontent");
                                            var FeatureSelectionFrame = findFrame(pagecontentFrame,"FeatureSelection");
                                            FeatureSelectionFrame.emxEditableTable.addToSelected(strXml);
                                     </script>
                                 <% 
                                 connectedOIDMap.put(strFeatureLevelId, parentOID);
                                 
                             
                             
                         }
                         else{
                             parentOID = connectedOIDMap.get(strFeatureLevelId).toString();
                         }
                         
                         for(int j=iCount+1; j < selectedFeatureList.size(); j++) {
                             HashMap childMap = (HashMap)selectedFeatureList.get(j);
                             String strNextObjLevelId = (String)childMap.get("LevelId");
                             String strNextObjId = (String)childMap.get("OId");
                          
                             if(!connectedOIDMap.containsKey(strNextObjLevelId) && strNextObjLevelId.startsWith(strFeatureLevelId) 
                                     && strNextObjLevelId.length() == strFeatureLevelId.length()+2){
                              
                                  childClonedObject = ManufacturingFeature.getCloneWithSelectedRelationships(context, strNextObjId, selectedMap);
                                  childOID = childClonedObject.getInfo(context, "id");
                                  cloneIdMap.put(strNextObjId,childOID);
                                  DomainRelationship.connect(context, parentOID, ConfigurationConstants.RELATIONSHIP_MANUFACTURING_FEATURES, childOID, true);
                                  connectedOIDMap.put(strNextObjLevelId, childOID);
                             }                        
                         }                  
                     }                      
                        
                 }
             }
                    
     }catch(Exception e)
     {
            bIsError=true;
            session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%--
  LogicalFeatureAddExistingPostProcess.jsp
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

<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import = "java.util.Enumeration" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
  try
  {
     String strObjId = emxGetParameter(request, "objectId");
     String parentOID = emxGetParameter(request, "parentOID");
     String parentForIRule = emxGetParameter(request, "parentForIRule");
     
     String isModel = emxGetParameter(request,"isModel");     
     ConfigurationUtil util = new ConfigurationUtil();
     boolean booelanDesignResp = false;     
     String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
     %>
     <script language="javascript" type="text/javaScript">
     var parentWindowToRefresh=null;
     </script>
     <%
     if(strContextObjectId==null){
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
     //If the selection are made in Search results page then     
     else{
    	 
         // Set RPE variable to skip the Cyclic condition Check
         PropertyUtil.setGlobalRPEValue(context,"CyclicCheckRequired","False");
         String strSelectedFeatures[] = new String[strContextObjectId.length];
         StringList strObjectIdList = new StringList();
         Object objSelectedObject = "";
         String strSelectedObject = "";
         String xml = "";
         Map paramMap = new HashMap();         
         paramMap.put("objectId", strObjId);
         paramMap.put("parentOID", parentForIRule);
         paramMap.put("objectCreation","Existing");
         for(int i=0;i<strContextObjectId.length;i++)
         {
             StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");             
             //Extracting the Object Id from the String.
             for(int j=0;j<strTokenizer.countTokens();j++)
             {
                  objSelectedObject = strTokenizer.nextElement();
                  strSelectedObject = objSelectedObject.toString();
                  strSelectedFeatures[i]=strSelectedObject;
                  strObjectIdList.addElement(strSelectedObject);
                  break;
             }             
         }
         
         // check for Cyclic Condition
         boolean isCyclic = false; 
         for(int i =0 ;i<strObjectIdList.size();i++)
         {
             isCyclic = util.multiLevelRecursionCheck(context,strObjId,(String)strObjectIdList.get(i),ConfigurationConstants.RELATIONSHIP_LOGICAL_FEATURES);
             if(isCyclic)
                 break;
         }
         if(isCyclic){
             
             %>
             <script language="javascript" type="text/javaScript">
                   alert("<emxUtil:i18n localize='i18nId'>emxConfiguration.Add.CyclicCheck.Error</emxUtil:i18n>");  
             </script>
            <%
         } else {
         
         //Check For different Design Resposibility
         boolean isDifferentDesignResp =  util.isRDODifferent(context,strSelectedFeatures,strObjId);         
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
        	 for(int i=0;i<strSelectedFeatures.length;i++)
             {
                 paramMap.put("newObjectId", strSelectedFeatures[i]);
                 
                 if("true".equals(isModel)){                 
                     Model confModel = new Model(parentOID);
                     confModel.connectCandidateLogicalFeature(context, (String)paramMap.get("newObjectId"));
                     %>
                     <script language="javascript" type="text/javaScript">
                             //window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
                              parentWindowToRefresh=window.parent.getTopWindow().getWindowOpener().parent;
                     </script>
                     <%                 
                 }               
                 else{
                     xml = LogicalFeature.getXMLForSB(context, paramMap,"relationship_LogicalFeatures");
                     %>
                         <script language="javascript" type="text/javaScript">
                                var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
								var contentFrame = null;
                                contentFrame = findFrame(window.parent.getTopWindow(),"FTRContextLFLogicalFeatures");                                
                                if(contentFrame == "undefined" || contentFrame == null){
                                	contentFrame = findFrame(window.parent.getTopWindow(),"FTRSystemArchitectureLogicalFeatures");
                                }
                                if(contentFrame == "undefined" || contentFrame == null){
                                	contentFrame = findFrame(window.parent.getTopWindow(),"detailsDisplay");
                                }

                                if(contentFrame !== null && contentFrame !== undefined){
                                	if(typeof contentFrame.emxEditableTable.addToSelected !== 'undefined' && 
                                            typeof contentFrame.emxEditableTable.addToSelected === 'function'){
                                		contentFrame.emxEditableTable.addToSelected(strXml);
                                	}
                                } 
                              //  window.parent.getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strXml); 
                         </script>
                     <%
                 }               
             }        	 
         } 
         %>
         <script language="javascript" type="text/javaScript">
                getTopWindow().window.closeWindow();
                if(parentWindowToRefresh!=null){
                	parentWindowToRefresh.location.href=parentWindowToRefresh.location.href;
                }
         </script>
     <%
     }
     }
     }catch(Exception e)
     {
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%--
  ConfigurationFeatureAddExistingPostProcess.jsp
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
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ManufacturingFeature"%>
<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>


<%@page import="java.util.HashMap"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
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
     String jsTreeID = emxGetParameter(request, "jsTreeID");
     String strObjId = emxGetParameter(request, "objectId");
     String parentOID = emxGetParameter(request, "parentOID");
     String isModel = emxGetParameter(request,"isModel");     
     String uiType = emxGetParameter(request,"uiType");     
     String suiteKey = emxGetParameter(request, "suiteKey");
     String timeStamp = emxGetParameter(request,"timeStamp");          
     String strLanguage = context.getSession().getLanguage();
     String parentForIRule = emxGetParameter(request, "parentForIRule");
     ConfigurationUtil util = new ConfigurationUtil();   
     String strParams = (String)session.getAttribute("params");    
     String strURL = null;
     boolean booelanDesignResp = false;  
     String strArrSelectedTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
     
     if(strArrSelectedTableRowId==null){
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
     //If the selection are made in Search results page then     
     else{
         // Set RPE variable to skip the Cyclic condition Check
         PropertyUtil.setGlobalRPEValue(context,"CyclicCheckRequired","False");
    	 
         String strSelectedFeatures[] = new String[strArrSelectedTableRowId.length];
         Object objSelectedObject = "";
         String strSelectedObject = "";
         String strtemp = "";
         String xml = "";
         String strFeatureType = "";
         String relType = "";
         HashMap paramMap = new HashMap();
         
         DomainObject parentObj = new DomainObject(strObjId); 
         
         StringList objectSelectList = new StringList();
         objectSelectList.addElement(DomainConstants.SELECT_TYPE);
         objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE);
         Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
         
         StringList strObjectIdList = new StringList();
         String strParentType = (String)parentInfoTable.get(ConfigurationConstants.SELECT_TYPE);
         String strParentKeyInType = (String)parentInfoTable.get((ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE));
         
         for(int i=0;i<strArrSelectedTableRowId.length;i++)
         {   //TODO- Use emxFramework split()
             StringTokenizer strTokenizer = new StringTokenizer(strArrSelectedTableRowId[i] ,"|");
             
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
             isCyclic = util.multiLevelRecursionCheck(context,strObjId,(String)strObjectIdList.get(i),ConfigurationConstants.RELATIONSHIP_MANUFACTURING_FEATURES);
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
         
         if(booelanDesignResp)
         {
             for(int i=0;i<strSelectedFeatures.length;i++)
             {
            	   paramMap.put("newObjectId", strSelectedFeatures[i]);
             
            	                 strFeatureType = new DomainObject(strSelectedFeatures[i]).getInfo(context, "type");
             
	                if("true".equals(isModel)){                 
	                     Model confModel = new Model(parentOID);
	                     confModel.connectCandidateManufacturingFeature(context, (String)paramMap.get("newObjectId"));
	                     //TODO change below refresh page type to "find frame"
	                     %>
	                     <script language="javascript" type="text/javaScript">
	                             //alert(window.parent.getTopWindow().getWindowOpener().parent.name); --coming as FTRModelCandidateConfigurationFeatures
	                             //window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
	                             var parentWindowToRefresh=window.parent.getTopWindow().getWindowOpener().parent;       
	                     </script>
	                     <%                 
	                 }  
	                 else
	                 {
	                     strFeatureType = "type_ManufacturingFeature";
	                     paramMap.put("objectId", strObjId);
	                     relType = "relationship_ManufacturingFeatures";                
	                     
	                     paramMap.put("featureType",strFeatureType);
	                     paramMap.put("languageStr", strLanguage);
	                     paramMap.put("relId","");
	                     paramMap.put("objectCreation","Existing");
	                     paramMap.put("parentOID", parentForIRule);
	                     xml = ManufacturingFeature.getXMLForSBCreate(context, paramMap, relType);
	                     %>
	                         <script language="javascript" type="text/javaScript">
	                                var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";     
	                                window.parent.getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strXml); 
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
    	    bIsError=true;
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%--
  LogicalFeatureMergeReplaceSearchProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program  
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@ page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.Map"%>

<html>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%
  String strMode = emxGetParameter(request,"mode");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String regisateredSuite = emxGetParameter(request,"SuiteDirectory"); 
  
  try{

      String timeStamp = emxGetParameter(request,"timeStamp");
      String strStep = emxGetParameter(request,"Step");
      String strObjectId = emxGetParameter(request,"objectId");
      String initSource = emxGetParameter(request, "initSource");
      String strProductId = emxGetParameter(request, "prodId");

      boolean hasSubfeatures = false;
      DomainObject domObj = new DomainObject(strObjectId);
      String objType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
      LogicalFeature logicalFeatureBean = new LogicalFeature();
      if(strMode.equalsIgnoreCase("MergeReplace"))
      {
      if(strStep!=null && strStep.equals("EditGBOM"))
      {
          session.removeAttribute("TableTimeStamp");
          session.removeAttribute("UpdatedCells");
          session.setAttribute("TableTimeStamp",timeStamp);
          String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");            
          StringList strLstSelFeaId  = new StringList();
           //variable to store rel and obj ids
          if (initSource == null)
               initSource = "";
           
          if(strTableRowIds != null && strTableRowIds.length > 0)
           {
               String objectId = strObjectId;
               // adding object id in String buffer for chking common group condition
               strLstSelFeaId.add(strObjectId);               
               // Specify URL to come in middle of frameset
               //Use bean method for get URL
               Map urlData = new HashMap();
               urlData.put("suiteKey",XSSUtil.encodeForURL(context,suiteKey));
               urlData.put("initSource",XSSUtil.encodeForURL(context,initSource));
               urlData.put("jsTreeID",XSSUtil.encodeForURL(context,jsTreeID));
               urlData.put("objectId",XSSUtil.encodeForURL(context,objectId));
               urlData.put("regisateredSuite",XSSUtil.encodeForURL(context,regisateredSuite));
               urlData.put("strProductId",XSSUtil.encodeForURL(context,strProductId));
                              
               String contentURL = logicalFeatureBean.URLforMergeReplace(context, urlData , "PreGBOMTable");
               
               for(int i =0; i<strTableRowIds.length;i++)
               {
                   contentURL += "&emxTableRowId="+ XSSUtil.encodeForURL(context,strTableRowIds[i]);
                   StringTokenizer strObjIdTZ = new StringTokenizer(strTableRowIds[i],"|");                   
                   strLstSelFeaId.add(strObjIdTZ.nextToken());
               }               
               
               boolean isFtrValidForPF = false;
               for(Object strFeatureId : strLstSelFeaId){
                   isFtrValidForPF  = logicalFeatureBean.validateAddingForGBOMOrDV(context,strObjectId,(String)strFeatureId,true,true);
                   if(isFtrValidForPF) break;
                   else{
                       isFtrValidForPF  = logicalFeatureBean.validateAddingForGBOMOrDV(context,(String)strFeatureId,strObjectId,true,true);
                       if(isFtrValidForPF) break;
                   }
               }
               //Check if selected Logical Feature is  obsolete
                            
               boolean isLogicalFeatureObsolete = false;
               String[] lstLogicalFeatureId = new String[strLstSelFeaId.size()];
               for(int i =0;i<strLstSelFeaId.size();i++)
               {
            	   Object strFeatureId = strLstSelFeaId.get(i);
            	   lstLogicalFeatureId[i]=(String)strFeatureId;
               }           
                   DomainObject doDestObj = new DomainObject();
                   StringList selectables = new StringList();
                   selectables.addElement(DomainConstants.SELECT_CURRENT);
                   MapList mpListState = doDestObj.getInfo(context,lstLogicalFeatureId,selectables);
               for(int i=0;i<mpListState.size();i++)
               {
            	   Map mpState = (Map)mpListState.get(1);
            	   String currentState = (String)mpState.get(DomainConstants.SELECT_CURRENT);
                   if (currentState.equalsIgnoreCase(ConfigurationConstants.STATE_OBSOLETE))
                   {
                       isLogicalFeatureObsolete = true;break;
                   }
                   
               }
               if(isLogicalFeatureObsolete){
                   %>
                   <Script>
                    alert("<%=i18nNow.getI18nString("emxProduct.Alert.AddObsoleteLogicalFeature",bundle,acceptLanguage)%>");
                   </Script>
                   <%
                   
               }
                   
               
               else if(isFtrValidForPF){
                    %>
                    <Script>
                     alert("<%=i18nNow.getI18nString("emxProduct.Alert.MultiplePartFamilies",bundle,acceptLanguage)%>");
                    </Script>
                    <%
               }
               else{
                   
                   
                   contentURL += "&noOfTargetFeatures=" +strTableRowIds.length;               
                   
                   if(ConfigurationConstants.TYPE_EQUIPMENT_FEATURE.equalsIgnoreCase(objType))
                   {
                       hasSubfeatures = logicalFeatureBean.canMergeAndReplace(context,strLstSelFeaId);                                                                                                                        
                   }
                  if(hasSubfeatures){
                      %>
                      <Script>
                       alert("<%=i18nNow.getI18nString("emxConfiguration.Alert.EquipmentFeature.MergeAndReplaceInvalid",bundle,acceptLanguage)%>");
                      </Script>
                      <%
                  
                  }else {
                       %>
                       <Script>
                        showModalDialog("<%=contentURL%>", 780, 500,true, 'Large');
                       </Script>
                       <%                       
                   }
               
                }
               
           }
           else
           {
               %>
               <Script>
               alert("<%=i18nNow.getI18nString("emxProduct.Alert.MustSelectAtLeastOne",bundle,acceptLanguage)%> <%=i18nNow.getI18nString("emxFramework.Basic.Feature",bundle,acceptLanguage)%>.");                
               </Script>
               <%
           }
      }
      }
  }
  catch(Exception e)
  {
    if(session.getAttribute("error.message") == null){
       session.putValue("error.message", e.toString());
    }

  }
  %>
 </html>
  



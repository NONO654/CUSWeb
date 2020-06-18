<%--
  ConfigurationFeatureCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ManufacturingFeature"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>

<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  boolean bIsError = false;
  try
  {
	  com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
      formBean.processForm(session,request);
      String strUIContext = (String)formBean.getElementValue("UIContext");
      String strObjIdContext = emxGetParameter(request, "parentOID");
      String strLanguage = context.getSession().getLanguage();
      
      HashMap paramMap = new HashMap();      
      String strNewFeatureId = (String)formBean.getElementValue("newObjectId");
      String strJsTreeID = (String)formBean.getElementValue("jsTreeID");
      String objId = (String)formBean.getElementValue("objectId");      
      String featureType = (String)formBean.getElementValue("type");
      
      paramMap.put("newObjectId", strNewFeatureId);
      paramMap.put("languageStr",(String)formBean.getElementValue("languageStr"));
      paramMap.put("PartFamilyDisplay", (String)formBean.getElementValue("PartFamily"));
      paramMap.put("relId",(String)formBean.getElementValue("relId"));
      paramMap.put("objectCreation","New");
      paramMap.put("objectId", objId);
      paramMap.put("featureType", featureType);      
      paramMap.put("parentOID", strObjIdContext);
      String relType;
      
      relType = "relationship_ManufacturingFeatures";
      
      String xml = ManufacturingFeature.getXMLForSBCreate(context, paramMap, relType);
      if(strUIContext!=null && strUIContext.equalsIgnoreCase("MyDesk")){
          %>
          <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                 var contentFrameObj = findFrame(parent.window.getTopWindow().getTopWindow(),"content");
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
          
          
      }           
      else if (strUIContext!=null && strUIContext.equalsIgnoreCase("ManufacturingFeature")){
          %>
          <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                 var contentFrameObj = findFrame(getTopWindow(),"FTRMFContextManufacturingFeatures");
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
          
          
      }
      else if (strUIContext!=null && strUIContext.equalsIgnoreCase("LogicalFeature")){
          %>
          <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                 var contentFrameObj = findFrame(getTopWindow(),"FTRContextLFManufacturingFeatures");
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
          
          
      }
          
            
      else{
          %>
          <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                 var contentFrameObj = findFrame(getTopWindow(),"FTRSystemArchitectureManufacturingFeatures");
               //the following code is required when we do launch (product-->logical structures-->manufacturing features-->click on the launch icon on the toolbar)
                 if(contentFrameObj == null){
                	 contentFrameObj = findFrame(getTopWindow(),"content");                 	   
                 }    
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
          
      }
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

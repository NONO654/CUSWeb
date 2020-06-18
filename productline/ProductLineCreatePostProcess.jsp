<%--
  ProductLineCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>


<%@page import="com.matrixone.apps.productline.ProductLine"%><script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  boolean bIsError = false;
  try
  {
      HashMap paramMap = new HashMap();   
      String relType;
      String strLanguage = context.getSession().getLanguage();
      com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
      formBean.processForm(session,request);      
      String strNewFeatureId = (String)formBean.getElementValue("newObjectId");
      String strJsTreeID = (String)formBean.getElementValue("jsTreeID");
      String objId = (String)formBean.getElementValue("objectId");
      String strObjIdContext = emxGetParameter(request, "parentOID");
      String featureType = (String)formBean.getElementValue("TypeActual");
      String strUIContext = (String)formBean.getElementValue("UIContext");
      String strParentID = (String)formBean.getElementValue("ConfigurationFeatureOID");;
      paramMap.put("newObjectId", strNewFeatureId);
      paramMap.put("languageStr",(String)formBean.getElementValue("languageStr"));

      paramMap.put("relId",(String)formBean.getElementValue("relId"));
      paramMap.put("objectCreation","Existing");
      paramMap.put("objectId", objId);  
      paramMap.put("parentOID", strObjIdContext);
      relType =  "relationship_SubProductLines";
     
      
        
      String xml = ProductLine.getXMLForSBCreate(context, paramMap, relType);
  
      if(strUIContext != null && strUIContext.equals("myDesk")){
          %>
          <script language="javascript" type="text/javaScript">
                  var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                  var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"content");                              
                  contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
          <% 
      }
      else if(strUIContext != null && !"".equals(strUIContext) && strUIContext.equalsIgnoreCase("GlobalActions")){
          %>
             <script language="javascript" type="text/javaScript">
                var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                contentFrameObj.document.location.href= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewFeatureId)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,strJsTreeID)%>";                
             </script>
          <%
      }
      else{
          %>
          <script language="javascript" type="text/javaScript">
                  var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";                 
                  var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"detailsDisplay");                  
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

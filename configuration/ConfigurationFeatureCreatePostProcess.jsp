<%--
  ConfigurationFeatureCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.security.DomainCombiner"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  try
  {
	  HashMap paramMap = new HashMap();   
	  String relType;
	  com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
      formBean.processForm(session,request);
        
      String strNewFeatureId = (String)formBean.getElementValue("newObjectId");
      String strJsTreeID = (String)formBean.getElementValue("jsTreeID");
      String objId = (String)formBean.getElementValue("objectId");
      String strObjIdContext = emxGetParameter(request, "parentOID");
      String featureType = (String)formBean.getElementValue("TypeActual");
      String strUIContext = (String)formBean.getElementValue("UIContext");
      String  contextObjID = emxGetParameter(request,"contextObjID");
      
      // To get the relationship id between newly created Configuration Feature/Configuration Option and Object under which it is created.
      matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
	  ContextUtil.commitTransaction(ctx);
      DomainObject domObj = new DomainObject(strNewFeatureId);
      StringList lstCFSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
      StringList lstCOSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
      String relId = "";
      if(lstCFSubTypes.contains(featureType) && !strUIContext.equalsIgnoreCase("GlobalActions")){
    	  StringList lstObjSelect = new StringList();
    	  lstObjSelect.add("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].from.id");
    	  lstObjSelect.add("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].id");
    	  DomainConstants.MULTI_VALUE_LIST.add("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].from.id");
    	  DomainConstants.MULTI_VALUE_LIST.add("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].id");
	      Map cfMap = (Map) domObj.getInfo(context, lstObjSelect);
	      DomainConstants.MULTI_VALUE_LIST.remove("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].from.id");
    	  DomainConstants.MULTI_VALUE_LIST.remove("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].id");
	      StringList lstCFFromIds = (StringList) cfMap.get("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].from.id");
	      StringList lstCFRelIds  = (StringList) cfMap.get("to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].id");
	      relId = lstCFRelIds.get(lstCFFromIds.indexOf(objId));
      }
      else if(lstCOSubTypes.contains(featureType))
      {
    	  relId = domObj.getInfo(context, "to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_OPTIONS+"].id");
      }
      
      paramMap.put("newObjectId", strNewFeatureId);
      paramMap.put("languageStr",(String)formBean.getElementValue("languageStr"));
      paramMap.put("SelectionType",(String)formBean.getElementValue("Selection Type"));      
      paramMap.put("KeyInType", (String)formBean.getElementValue("Key-In Type"));
      paramMap.put("relId", relId);
      paramMap.put("objectCreation","New");
      paramMap.put("objectId", objId);  
      paramMap.put("parentOID", strObjIdContext);
      if(featureType != null && !"".equals(featureType) && mxType.isOfParentType(context, featureType, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE))
      {
          relType = "relationship_ConfigurationFeatures"; 
      }       
      else
      {
          relType = "relationship_ConfigurationOptions";
      }
  		
      String xml = ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);
      if(strUIContext != null && strUIContext.equals("myDesk")){
    	  xml = xml.replaceAll("pending", "committed");
    	  %>
          <script language="javascript" type="text/javaScript">
          
          		  var relType = "<%=relType%>";
          		  var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
          		  if(relType == "relationship_ConfigurationFeatures")
          		  {
                    var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"content");                              
                    contentFrameObj.emxEditableTable.addToSelected(strXml); 
          		  }
          		  else 
          		  {
          			var cfId            = "<%=objId%>";
                    var detailsFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"content");               
                    var oXML            = detailsFrameObj.oXML;
         	       	var selectedRow     = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + cfId + "']");
         	        var rowId           = selectedRow[0].getAttribute("id");
         	        var selectSBrows    = [];
         	        selectSBrows.push(rowId);
         	        detailsFrameObj.emxEditableTable.addToSelected(strXml, selectSBrows);
          		  }
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
    	  
    	  xml = xml.replaceAll("pending", "committed");
    	  boolean isProductContext = false;
    	  if(ProductLineCommon.isNotNull(contextObjID)){
    	    isProductContext = new DomainObject(contextObjID).isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
    	  }else{
    		isProductContext = new DomainObject(objId).isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
    	  }
    	  %>
          <script language="javascript" type="text/javaScript">
                  <%-- var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                  var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"detailsDisplay");                              
                  contentFrameObj.emxEditableTable.addToSelected(strXml); --%>
                  
                  var cfId       = "<%=objId%>";
                  var detailsFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"detailsDisplay");               
                  var oXML            = detailsFrameObj.oXML;
       	       	  var selectedRow     = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + cfId + "']");
       	          var rowId           = selectedRow[0].getAttribute("id");
       	          var strXml          = "<%=XSSUtil.encodeForJavaScript(context,xml)%>";
       	          var selectSBrows    = [];
       	          selectSBrows.push(rowId);
       	          detailsFrameObj.emxEditableTable.addToSelected(strXml, selectSBrows);
       	          
       	          // Code will get call for Model Version - To add the Created object in Structure Tree
                  var isProductContext = "<%=isProductContext%>";
                  if("true" == isProductContext){
                    var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");          
                    contentFrame.addMultipleStructureNodes("<%=strNewFeatureId%>", "<%=objId%>", '', '', false);
                  }
          </script>
          <% 
      }       
  }
  catch(Exception e)
  {
	  String strErrorMessage = e.getMessage();
	  if(strErrorMessage.contains("1500789")){
		  strErrorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.NotUniqueMsg", new Locale(request.getHeader("Accept-Language")));
	  }
	  session.putValue("error.message", strErrorMessage);
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

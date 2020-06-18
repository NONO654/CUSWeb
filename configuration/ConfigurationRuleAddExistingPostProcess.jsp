<%--
  ConfigurationRuleAddExistingPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.Model"%>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
</head>
<%
  try
  {
     //this will be Configuration Rule
     String strModelId = emxGetParameter(request, "objectId");
     String strObjIds[]=null;
     ProductLineUtil utilBean = new ProductLineUtil();
     
     StringList selList = new StringList();
     selList.add("to[" + ConfigurationConstants.RELATIONSHIP_PRODUCTS + "].from.physicalid");
      
     
     DomainObject domProduct  = new DomainObject(strModelId);
	 Map ModelId = domProduct.getInfo(context,selList);
		
		
     String physicalId ="";
     
     if(ModelId != null && ModelId.size() > 0){
			physicalId = (String)ModelId.get("to[" + ConfigurationConstants.RELATIONSHIP_PRODUCTS + "].from.physicalid");
	        if (physicalId== null)
	           	physicalId = (String)ModelId.get("to[" + ConfigurationConstants.RELATIONSHIP_MAIN_PRODUCT + "].from.physicalid");
		}

     //get the selected Objects from the Full Search Results page
     String[] strContextObjectId    = emxGetParameterValues(request, "emxTableRowId");     
     
     //If the selection is empty given an alert to user
     if(strContextObjectId==null){   
     %>
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%
     }
     //If the selection are made in Search results page then     
     else{
         
         Map mapIds = (Map)utilBean.getObjectIdsRelIds(strContextObjectId);
         strObjIds= (String[])mapIds.get("ObjId");
         
         Model mdl = new Model(physicalId);
         mdl.addCfgRules(context,strObjIds);
         %>
         <script language="javascript" type="text/javaScript"> 
         getTopWindow().getWindowOpener().editableTable.loadData();
         getTopWindow().getWindowOpener().rebuildView();
         getTopWindow().window.closeWindow();  
         </script>
      <% 
     }
  }catch(Exception e)
  {     
        %>
        <script language="javascript" type="text/javaScript">
         alert("<%=XSSUtil.encodeForJavaScript(context,e.getMessage())%>");                 
        </script>
        <%    
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

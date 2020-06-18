<%--
  ConfigurationRuleDisconnectPostProcess.jsp
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
<%@page import="com.dassault_systemes.enovia.configuration.modeler.Model"%>
<head></head>
<%
  try
  {
     //this will be context ID
     String strContextId = emxGetParameter(request, "objectId");
     //get the selected Objects 
     String[] arrTableRowIds    = emxGetParameterValues(request, "emxTableRowId");
     //If the selection is empty given an alert to user
     
     if(arrTableRowIds==null){   
     %>    

       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%
     }
     //If the selection are made in Search results page then     
     else{
    	 
         String []arrRelIds =null;
               
         //get the Object  ids of the table row ids passed    
          Map relIdMap = ProductLineUtil.getObjectIdsRelIds(arrTableRowIds); 
          arrRelIds = (String[])relIdMap.get("RelId");
          Model mdl = new Model(strContextId);
          mdl.removeCfgRules(context,arrRelIds);
         %>
              <script language="javascript" type="text/javaScript">
//            <![CDATA[
                                        
                      parent.editableTable.loadData();
                      parent.rebuildView();
//            ]]>
              </script>

              <% 
          }
  }catch(Exception e){
      %>
      <script language="javascript" type="text/javaScript">
       alert("<%=XSSUtil.encodeForJavaScript(context,e.getMessage())%>");                 
      </script>
      <%
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

<%--
  MPRDeletePostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.configuration.MarketingPreference"%>
<html>
<head>
  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
</head>
<%
  try
  {
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
    	 
         ProductLineUtil utilBean = new ProductLineUtil();
         String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
         String arrRelIds[] = null;
         Map valuesMap= new java.util.HashMap();
         valuesMap = utilBean.getObjectIdsRelIds(arrTableRowIds);
         arrRelIds = (String[])valuesMap.get("RelId");
         StringList slMPRToRemove= new StringList(arrRelIds);
         MarketingPreference.delete(context,slMPRToRemove);
         %>

         <script language="javascript" type="text/javaScript">
//         <![CDATA[
                 parent.editableTable.loadData();
                      parent.rebuildView(); 
//         ]]>
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

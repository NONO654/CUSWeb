<%--
  ConfigurationRuleDeletePostProcess.jsp
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
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.Product"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>

<html>
<head></head>
<%
  try
  {
     //get the selected Objects from the Full Search Results page
     String[] arrTableRowIds    = emxGetParameterValues(request, "emxTableRowId");
     String strProdId = emxGetParameter(request, "objectId");
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
    	 
         ProductLineUtil utilBean = new ProductLineUtil();
         String strObjIds[] = null;
         Map mapIds= new java.util.HashMap();
         mapIds = utilBean.getObjectIdsRelIds(arrTableRowIds);
         strObjIds= (String[])mapIds.get("ObjId");  
         
         /* Model mdl = new Model(strModelId);
         mdl.deleteCfgRules(context,strObjIds); */

         // creating rule Ids array
         String[] ruleIds = new String[strObjIds.length];
		 for(int i=0; i<strObjIds.length; i++){
			 ruleIds[i] = strObjIds[i].substring(0, strObjIds[i].indexOf("|"));
         }
         
		 // getting physical ids of rules
		 StringList selectables = new StringList();
		 selectables.add(ConfigurationConstants.SELECT_PHYSICAL_ID);
         MapList rulePIdsList = DomainObject.getInfo(context, ruleIds, selectables);

         // creating rule physical ids array
         String[] rulePIds = new String[rulePIdsList.size()];
         for(int i=0; i<rulePIdsList.size(); i++){
        	 Map ruleMap = (Map)rulePIdsList.get(i);
        	 rulePIds[i] = ruleMap.get(ConfigurationConstants.SELECT_PHYSICAL_ID).toString();
         }
         
         // removing rules
         Product prod = new Product(strProdId);
         prod.removeCfgRules(context, rulePIds,true);
         
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
	  emxNavErrorObject.addMessage(e.getMessage());
	 }
  
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

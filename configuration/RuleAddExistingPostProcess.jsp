<%--
  RuleAddExistingPostProcess.jsp
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
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%><html>

<head>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>  
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
</head>
<%
  try
  {
     String strObjId = emxGetParameter(request, "objectId");
     String strRelName = emxGetParameter(request,"relName");
     if(strRelName!=null){
         strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
     }
     String[] strContextObjectId    = emxGetParameterValues(request, "emxTableRowId");     
     if(strContextObjectId==null){   
     %>
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%
     }else{
       String strObjIds[]=null;
       ProductLineUtil utilBean = new ProductLineUtil();
       Map mapIds = (Map)utilBean.getObjectIdsRelIds(strContextObjectId);
       strObjIds= (String[])mapIds.get("ObjId");
  	   ContextUtil.startTransaction(context, true);
  	   try {
		   DomainObject doFromType = new DomainObject(strObjId);
		   Map retRuleMap = new HashMap();
		   RelationshipType relationshipType = new RelationshipType(strRelName);
		   retRuleMap = doFromType.addRelatedObjects(context,relationshipType,true, strObjIds);
		   Vector strRuleRelIds = new Vector(retRuleMap.values());
		   DomainRelationship domRel;
		   for (Iterator ruleRelIDIttr = strRuleRelIds.iterator(); ruleRelIDIttr.hasNext();) {
			    String strRuleRelId = (String) ruleRelIDIttr.next();
				domRel = new DomainRelationship(strRuleRelId);
	            PropertyUtil.setGlobalRPEValue(context,"RuleContext", "Create");
	            domRel.setAttributeValue(context,ConfigurationConstants.ATTRIBUTE_MANDATORYRULE,ConfigurationConstants.RANGE_VALUE_NO);
	            PropertyUtil.setGlobalRPEValue(context,"RuleContext", "FALSE");
			}
	        ContextUtil.commitTransaction(context);
  	   }catch (Exception e) {
		   ContextUtil.abortTransaction(context);
		   throw new FrameworkException(e.getMessage());
  	   }
         %>
         <script language="javascript" type="text/javaScript"> 
         getTopWindow().getWindowOpener().editableTable.loadData();
         getTopWindow().getWindowOpener().rebuildView();
         getTopWindow().window.closeWindow();  
         </script>
      <%     
     }
  }catch(Exception e) {     
        %>
        <script language="javascript" type="text/javaScript">
         alert("<%=XSSUtil.encodeForJavaScript(context,e.getMessage())%>");     
         var fullSearchReference = findFrame(getTopWindow(), "structure_browser");
    	 fullSearchReference.setSubmitURLRequestCompleted();
        </script>
        <%    
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

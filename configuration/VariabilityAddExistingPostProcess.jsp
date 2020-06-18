<%--
  VariabilityAddExistingPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.dassault_systemes.enovia.governance.modeler.GovernanceModelerCommon"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%
  try
  {  
     String strObjId = emxGetParameter(request, "objectId");
     String parentOID = emxGetParameter(request, "parentOID");
     String isModel = emxGetParameter(request,"isModel");
     String strLanguage = context.getSession().getLanguage();
     String parentForIRule = emxGetParameter(request, "parentForIRule");
     String strFullSearchSelection = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FullSearch.Selection",strLanguage);
     String strArrSelectedTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
     String[] lstObjectIdsToConnect = new String[strArrSelectedTableRowId.length];
%>
     <script language="javascript" type="text/javaScript">
        var objToAddArray = new Array();
     </script>
<%
     if(strArrSelectedTableRowId != null && strArrSelectedTableRowId.length < 0)
     {
    	 %>
         <script language="javascript" type="text/javaScript">
               alert("<%=XSSUtil.encodeForJavaScript(context,strFullSearchSelection)%>");
         </script>
        <%
     }
     else
     {
    	 for(int i = 0; i < strArrSelectedTableRowId.length; i++)
    	 {
    		 String[] strTableRowId = strArrSelectedTableRowId[i].toString().split("\\|");
    		 lstObjectIdsToConnect[i] = strTableRowId[1].trim();
%>
    		 <script language="javascript" type="text/javaScript">
    	        objToAddArray[<%=i%>] = "<%=strTableRowId[1].trim()%>";
    	     </script>
<%
    	 }
     }
     
     DomainObject domObj = DomainObject.newInstance(context, strObjId);
     String strType = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
     StringList PLSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCT_LINE);
     StringList MDSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_MODEL);
     StringList PRDSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCTS);
	 if(PLSubTypes.contains(strType) || PRDSubTypes.contains(strType))
	 {
		 // Connect the Variants / Variability Groups to Product Line / Model Version
		 GovernanceModelerCommon govModCom = new GovernanceModelerCommon();
		 //govModCom.connect() : This modeler API takes only single object to connect. So called BPS API to connect multiple objects to Product Line/Model Version.
		 Map map = DomainRelationship.connect(context, domObj, ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES, true, lstObjectIdsToConnect);
		 
		 // Below code is to set Configuration Selection Criteria (Must/May) attribute value as "May" on Configuration Features relationship for Variability Group always.
		 Iterator iterator = map.keySet().iterator();
		 while(iterator.hasNext())
		 {
			 String strVariantObjId = (String)iterator.next();
			 DomainObject variantObj = new DomainObject(strVariantObjId);
			 
			 // To set default value for Configuration Selection Criteria(Must/May) attribute as "May" for Variability Group.
			 if(variantObj.isKindOf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP))
			 {
				  String relId = (String) map.get(strVariantObjId);
		    	  DomainRelationship.setAttributeValue(context, relId, ConfigurationConstants.ATTRIBUTE_CONFIGURATION_SELECTION_CRITERIA, ConfigurationConstants.RANGE_VALUE_MAY);
			 }
		 }
		 boolean isProductContext = PRDSubTypes.contains(strType);
		 %>
		 <script language="javascript" type="text/javaScript">
		     var detailsFrameObj = window.parent.getTopWindow().getWindowOpener().parent;                      
	         detailsFrameObj.editableTable.loadData();
	         detailsFrameObj.rebuildView();
	         
	         // Code to get call for Model Version - To Add Object in Structure Tree
	         var isProductContext = "<%=isProductContext%>";
	         if("true" == isProductContext)
	         {
	        	 for(var i = 0; i < objToAddArray.length; i++)
	        	 {
	        		 var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
	                 contentFrame.addMultipleStructureNodes(objToAddArray[i], "<%=strObjId%>", '', '', false);
	        	 }
	         }
	         
	         getTopWindow().closeWindow();
	         getTopWindow().getWindowOpener().closeWindow();
	         </script>
		 <%
	 }
	 else if(MDSubTypes.contains(strType))
	 {
		 // Connect the Variants / Variability Groups to Model
		 com.dassault_systemes.enovia.configuration.modeler.Model model = new com.dassault_systemes.enovia.configuration.modeler.Model(strObjId);
		 model.connectCandidateVariantsAndVariabilityGroup(context, lstObjectIdsToConnect);	
		 %>
		 <script language="javascript" type="text/javaScript">
	         window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
	         getTopWindow().closeWindow();
	         getTopWindow().getWindowOpener().closeWindow();        
		 </script>
		 <%
	 }
  }
  catch(Exception e)
  {
     session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

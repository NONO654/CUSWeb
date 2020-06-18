<%--
  VariabilityRemoveProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.enovia.governance.modeler.GovernanceModelerCommon"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<%

  try
  {	  
	  String strLanguage = context.getSession().getLanguage();     
	  String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureRemoveOptionNotAllowed", strLanguage);
	  String strRemoveOnOptionsUnsupported = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.RemoveOnOptionsUnsupported", strLanguage);
	  String strCannotRemoveMandatoryOrCommitted = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.CannotRemoveMandatoryOrCommitted", strLanguage);
	  
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  String strParentId = emxGetParameter(request, "objectId");
	  String strParentType = new DomainObject(strParentId).getType(context);
	  
	  StringList VRSubTypes = ProductLineUtil.getChildrenTypes(context, ConfigurationConstants.TYPE_VARIANT);
	  VRSubTypes.add(ConfigurationConstants.TYPE_VARIANT);
	  StringList VGSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP);
	  
      StringList strObjectIdList = new StringList();
      StringList strParentIdList = new StringList();
      StringTokenizer strTokenizer = null;
      MapList mLstParentChildDetails = new MapList();
      StringList strRelIds = new StringList();
      %>
      <script language="javascript" type="text/javaScript">
      		var arrObjToRemove = new Array();
      </script>
      <%
      for(int i=0;i<arrTableRowIds.length;i++)
      {
         Map parentChid = new HashMap();
         if(arrTableRowIds[i].indexOf("|") > 0){
               strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");  
               String strRelID = strTokenizer.nextToken();
               String strObjId = strTokenizer.nextToken();
               String strParentObjId = strTokenizer.nextToken();
               strRelIds.add(strRelID);
               strObjectIdList.add(strObjId);
               strParentIdList.add(strParentObjId);
               parentChid.put("ParentOID",strParentObjId);
               parentChid.put("ChildOID",strObjId);
               parentChid.put("RelId",strRelID);
               %>
               <script language="javascript" type="text/javaScript">
                    arrObjToRemove["<%=i%>"]="<%=strObjId%>";
               </script>
               <%  
           }
           else
           {
               strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
               String strObjId = strTokenizer.nextToken();
               String strParentObjId = strTokenizer.nextToken();
               strObjectIdList.add(strObjId);
               strParentIdList.add(strParentObjId);
               parentChid.put("ParentOID",strParentObjId);
               parentChid.put("ChildOID",strObjId);
               %>
               <script language="javascript" type="text/javaScript">
                    arrObjToRemove["<%=i%>"]="<%=strObjId%>";
               </script>
               <%  
           }
           mLstParentChildDetails.add(parentChid);
          }
      
          boolean isSelectedVVType = ConfigurationUtil.isListContainsTypeOfKind(context, strObjectIdList,ConfigurationConstants.TYPE_VARIANTVALUE);
          boolean isSelectedVOType = ConfigurationUtil.isListContainsTypeOfKind(context, strObjectIdList,ConfigurationConstants.TYPE_VARIABILITYOPTION);
          boolean isSelectedCOType = ConfigurationUtil.isListContainsTypeOfKind(context, strObjectIdList,ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
          
          if(arrTableRowIds!=null && arrTableRowIds[0].endsWith("|0")){
      	     %>
      	        <script language="javascript" type="text/javaScript">
      	              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
      	        </script>
      	     <%
          }
          else if(isSelectedVVType || isSelectedVOType || isSelectedCOType)
          {
              %>
              <script language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strRemoveOnOptionsUnsupported)%>");
              </script>
             <%
          }
          else
          {
	          boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strParentIdList);
	          ConfigurationFeature.canRemoveDesignVariantFromProduct(context,mLstParentChildDetails);
	          
	          if(bInvalidState)
	          {
	              %>
	              <script language="javascript" type="text/javaScript">
	                    alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
	              </script>
	             <%
	          }
	          else if(mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_MODEL))
	          {
	        	  // Call for Modeler API to Removal of selected Variants / Variability Groups from Model Context. 
	              Model confModel = new Model(strParentId);
	        	  MapList mapList = DomainRelationship.getInfo(context, (String[])strRelIds.toArray(new String[strRelIds.size()]), new StringList(DomainConstants.SELECT_NAME));
	        	  Boolean isCommittedOrMandatoryRel = false;		  
	        	  if(mapList.size() > 0)
	        	  {
	        		  for(int i = 0; i < mapList.size(); i++)
	        		  {
	        			  Map map = (Map) mapList.get(i);
	        			  String strRelName = (String) map.get(DomainConstants.SELECT_NAME);
	        			  if(ConfigurationConstants.RELATIONSHIP_COMMITTED_CONFIGURATION_FEATURES.equalsIgnoreCase(strRelName) || ConfigurationConstants.RELATIONSHIP_MANDATORY_CONFIGURATION_FEATURES.equalsIgnoreCase(strRelName)){
	        				  isCommittedOrMandatoryRel = true;
	        				  break;
	        			  }
	        		  }
	        	  }
	        	  
	        	  if(isCommittedOrMandatoryRel)
	        	  {
	        		  %>
		              <script language="javascript" type="text/javaScript">
		                    alert("<%=XSSUtil.encodeForJavaScript(context,strCannotRemoveMandatoryOrCommitted)%>");
		              </script>
		             <%
	        	  }
	        	  else
	        	  {
	        		 confModel.removeCandidateConfigurationFeatures(context, strObjectIdList); 
	        		 %>
		             <script language="javascript" type="text/javaScript">
		                  var contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");
		                  parent.location.href = parent.location.href;
		             </script>
		             <%
	        	  }   
	          }
	          else
	          {
	            // Call for Modeler API to Removal of selected Variants / Variability Groups from Product Line/Model Version Context. 
	        	com.dassault_systemes.enovia.governance.modeler.GovernanceModelerCommon govModComm = new com.dassault_systemes.enovia.governance.modeler.GovernanceModelerCommon();
	            govModComm.disconnect(context, (String[])strRelIds.toArray(new String[strRelIds.size()]));
	            boolean isProductContext = new DomainObject(strParentId).isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
	            %>
	            <script language="javascript" type="text/javaScript">
		        // This code is used to remove the selected Variants / Variability Groups from Structure Browser on Remove Action.
		        if(arrObjToRemove.length > 0)
		        {
		             var contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");
			         var oXML            = contentFrameObj.oXML;
			         var selctedRowIds   = new Array(arrObjToRemove.length - 1);
			         for(var i = 0; i < arrObjToRemove.length; i++)
			         {	  
				        var selectedRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + arrObjToRemove[i] + "']");
				      	var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
				      	var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
				      	var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
				      	var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
				      	var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
				      	selctedRowIds[i] = rowIds;
				      	
				        // Code will get call for Model Version - To add the Created object in Structure Tree
			            var isProductContext = "<%=isProductContext%>";
			            if("true" == isProductContext){
			               var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");  
			               contentFrame.deleteObjectFromTrees(arrObjToRemove[i], false);
			            }
			      	 }
			         // Remove the selected nodes from SB
			      	 contentFrameObj.emxEditableTable.removeRowsSelected(selctedRowIds);
			         
			    }         
		        </script>
		        <%
	          }
         }
  }
  catch(Exception e)
  {
	    String strErrorMsg = e.getMessage();
	      	    
  	    if(strErrorMsg.contains("Severity")){
  	    	strErrorMsg = strErrorMsg.substring(strErrorMsg.indexOf("#5000001:")+10, strErrorMsg.indexOf("Severity:"));
	    }
  	    session.putValue("error.message", strErrorMsg);
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
  

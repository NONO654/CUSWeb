<%--
  VariabilityDeleteProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@include file = "../components/emxMQLNotice.inc"%>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
	String action = "";
	String msg = "";
	boolean bIsError = false;
	String strMode = emxGetParameter(request,"mode");
	
	if(null!=strMode && strMode.equalsIgnoreCase("deleteCF")){
		//delete CF Ajax Call implementation-------
	  	try{
			 String OIDsToDelete = emxGetParameter(request,"OIDsToDelete");
		     if(OIDsToDelete!=null){
		      java.util.StringTokenizer stTk = new java.util.StringTokenizer(OIDsToDelete,"[,],,");
		      StringList sLOIDsToDelete = new StringList();
		      while(stTk.hasMoreElements()) {
		        	sLOIDsToDelete.addElement(stTk.nextToken().toString().trim());
		      }
		      StringList listSelect = new StringList();
		      listSelect.add(DomainConstants.SELECT_TYPE);
		      listSelect.add(DomainConstants.SELECT_ID);
		      String[] oidsArray = new String[sLOIDsToDelete.size()];
		      MapList objMapList = DomainObject.getInfo(context, (String[])sLOIDsToDelete.toArray(oidsArray), listSelect);
		      
		      StringList lstVariantChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIANT);
		      StringList lstVariantValueChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIANTVALUE);
		      StringList lstVariabilityGroupChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYGROUP);
		      StringList lstVariabilityOptionChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_VARIABILITYOPTION);
		      StringList lstConfFeatChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
		      StringList lstConfOptionChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context,ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
		      
		      StringList lstVariantIds = new StringList();
		      StringList lstVariantValuesIds = new StringList();
		      StringList lstVariabilityGroupsIds = new StringList();
		      StringList lstVariabilityOptionsIds = new StringList();
		      StringList lstConfFeatIds = new StringList();
		      StringList lstConfOptionsIds = new StringList();
		      for(int i = 0; i < objMapList.size(); i++)
		      {
		    	  Map map = (Map) objMapList.get(i);
		    	  String strObjectId = (String )map.get(DomainConstants.SELECT_ID);
		    	  String strObjType  = (String )map.get(DomainConstants.SELECT_TYPE);
		    	  if(lstVariantChildTypes.contains(strObjType))
		    	  {
		    		  lstVariantIds.add(strObjectId);
		    	  }
		    	  else if(lstVariantValueChildTypes.contains(strObjType))
		    	  {
		    		  lstVariantValuesIds.add(strObjectId);
		    	  }
		    	  else if(lstVariabilityGroupChildTypes.contains(strObjType))
		    	  {
		    		  lstVariabilityGroupsIds.add(strObjectId);
		    	  }
		    	  else if(lstVariabilityOptionChildTypes.contains(strObjType))
		    	  {
		    		  lstVariabilityOptionsIds.add(strObjectId);
		    	  }
		    	  else if(lstConfFeatChildTypes.contains(strObjType))
		    	  {
		    		  lstConfFeatIds.add(strObjectId);
		    	  }
		    	  else if(lstConfOptionChildTypes.contains(strObjType))
		    	  {
		    		  lstConfOptionsIds.add(strObjectId);
		    	  }
		    		 
		      }
		      
		      if(lstVariantIds.size() > 0)
		      {
		    	  com.dassault_systemes.enovia.configuration.modeler.Variant variant = new com.dassault_systemes.enovia.configuration.modeler.Variant();
		    	  variant.deleteVariants(context, (String[])lstVariantIds.toArray(new String[lstVariantIds.size()]));
		      }
		      if(lstVariantValuesIds.size() > 0)
		      {
		    	  com.dassault_systemes.enovia.configuration.modeler.VariantValue variantValue = new com.dassault_systemes.enovia.configuration.modeler.VariantValue();
		    	  variantValue.deleteVariantValues(context, (String[])lstVariantValuesIds.toArray(new String[lstVariantValuesIds.size()]));
		      }
		      if(lstVariabilityGroupsIds.size() > 0)
		      {
		    	  com.dassault_systemes.enovia.configuration.modeler.VariabilityGroup variabilityGroup = new com.dassault_systemes.enovia.configuration.modeler.VariabilityGroup();
		    	  variabilityGroup.deleteVariabilityGroups(context, (String[])lstVariabilityGroupsIds.toArray(new String[lstVariabilityGroupsIds.size()]));
		      }
		      if(lstVariabilityOptionsIds.size() > 0)
		      {
		    	  com.dassault_systemes.enovia.configuration.modeler.VariabilityOption variabilityOptions = new com.dassault_systemes.enovia.configuration.modeler.VariabilityOption();
		    	  variabilityOptions.deleteVariabilityOptions(context, (String[])lstVariabilityOptionsIds.toArray(new String[lstVariabilityOptionsIds.size()]));
		      }
		      if(lstConfOptionsIds.size() > 0)
		      {
		    	  ConfigurationFeature.delete(context, lstConfOptionsIds);       
		      }
		      if(lstConfFeatIds.size() > 0)
		      {
		    	  ConfigurationFeature.delete(context, lstConfFeatIds);       
		      }
		      action = "removeandrefresh";
		      out.println("action=");
			  out.println(action);
			  out.println(",");
			  out.println("msg=");
			  out.println(msg);
			  out.println(";");
		     }
	    }catch(Exception e){
		      
		      msg = e.toString();
		      if (msg!=null && msg.indexOf("Check trigger blocked event")>= 0) {
	    			action = "checkTrigger";
	    			out.println("action=");
	    			out.println(action);
	    			out.println(",");
	    			out.println("msg=");
	    			out.println(msg);
	    			out.println(";");
	    		}
		   else{
		   action = "error";
	       if(msg.contains("Severity")){
		         msg = msg.substring(msg.indexOf("#5000001:")+10, msg.indexOf("Severity:"));
		      }else{
		    	 msg = msg.substring(msg.indexOf("#5000001:")+10);
		      }
	       out.println("action=");
		   out.println(action);
		   out.println(",");
		   out.println("msg=");
		   out.println(msg);
		   out.println(";");
	       }
	    }
		
		//delete CF Ajax Call implementation-------
	}else{// First Time without mode passed
		
  	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	String strLanguage = context.getSession().getLanguage();
	StringList strObjectIdList = new StringList();
	String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureDeleteOptionNotAllowed",strLanguage);
    String UnsavedMarkUp = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.UnsavedMarkUp",strLanguage);
    
      
	if(arrTableRowIds[0].endsWith("|0"))
	{
       %>
       <script language="javascript" type="text/javaScript">
               alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
       </script>
       <%
    }
	else
	{
	       String strObjectID = "";
	       StringTokenizer strTokenizer = null;
	       
	       //Iterate selected object list and get object to delete 
	       //put in JS array to be used later
	       %>
 	       <script language="javascript" type="text/javaScript">
     	       var cBoxArray = new Array();
 	       </script>
 	       <%
 	        StringList lstRelIds = new StringList();
 	        for(int i=0;i<arrTableRowIds.length;i++){
		 	            strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
		 	            if(arrTableRowIds[i].indexOf("|") > 0){
		 	            	  lstRelIds.add((String) strTokenizer.nextToken());
		 	                  strObjectID = strTokenizer.nextToken() ;                                 
		 	                  strObjectIdList.add(strObjectID);
		 	              }else{
		 	                  strObjectID = strTokenizer.nextToken() ;
		 	                  strObjectIdList.add(strObjectID);                           
		 	              }
		 	            %>
		 	            <script language="javascript" type="text/javaScript">
		 	            cBoxArray["<%=i%>"]="<%=strObjectID%>";
		 	            </script>
		 	            <%
 	        }	        	
 	        boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjectIdList);  
 	        Boolean isCommittedOrMandatoryRel = false;	
 	        boolean isModelContext = false;
 	        String strCannotDeleteMandatoryOrCommitted = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.CannotDeleteMandatoryOrCommitted", strLanguage);
 	        String strObjId = emxGetParameter(request,"objectId");
 	        if(ProductLineCommon.isNotNull(strObjId)){
	 	        DomainObject domObj = new DomainObject(strObjId);
	 	        isModelContext = domObj.isKindOf(context, ConfigurationConstants.TYPE_MODEL);
	        }
 	        if(isModelContext)
 	        {
		 	  	MapList mapList = DomainRelationship.getInfo(context, (String[])lstRelIds.toArray(new String[lstRelIds.size()]), new StringList(DomainConstants.SELECT_NAME));  
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
 	        }
 	        if(isCommittedOrMandatoryRel)
	 	  	{
		        %>
	            <script language="javascript" type="text/javaScript">
	                  alert("<%=XSSUtil.encodeForJavaScript(context,strCannotDeleteMandatoryOrCommitted)%>");
	            </script>
		        <%
	        }
 	        else if(bInvalidState == true)
	 	  	{
		        %>
	            <script language="javascript" type="text/javaScript">
	                  alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
	            </script>
		        <%
	        }
	 	  	else
	        {   
	 	  		boolean hasDV=false;
		        try{
		        	ConfigurationFeature.canDeleteDesignVariantFromProduct(context,strObjectIdList);        		
		        } catch(Exception e){
		        	hasDV = true;
		        } 
		        
		        if(!hasDV){
		        //get Context Object type to determine if it is Product Context, only case where Tree also need to refresh on delete CF
		        boolean isNonPRDContext = false;
		        String parentOID = (String)emxGetParameter(request, "objectId");
		        DomainObject parentObj  = new DomainObject(parentOID);
		        String strType = "";
		        if(ProductLineCommon.isNotNull(parentOID)){
		        	   strType = parentObj.getInfo(context, DomainConstants.SELECT_TYPE);
		        }
		        StringList lstPLChildTypes    = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTLINE);
		        StringList lstModelChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_MODEL);
		        if(parentOID==null || (parentOID!=null && (strType.equals(ProductLineConstants.TYPE_PRODUCT_VARIANT)||lstPLChildTypes.contains(strType)||lstModelChildTypes.contains(strType)))){
		         	isNonPRDContext=true;
		        }
		        %>
		            
		        <script language="javascript" type="text/javaScript">
		        
		        var VarIsNonPRDContext = "<%=isNonPRDContext%>";
		        var contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");
		        if(contentFrameObj == null || contentFrameObj == undefined)
		        {
		          	contentFrameObj = findFrame(getTopWindow(),"content");
		        }
		        
		        //if SB is having any markup
		        if(contentFrameObj.isDataModified())
		        {
		        	alert("<%=UnsavedMarkUp%>");
		        }
		        else
		        {
		        	
		            	//START AJAX CALL -->
		                var RemMPRelIDs = '<%=strObjectIdList.toString()%>';
			            var urlParams = "mode=deleteCF&OIDsToDelete="+RemMPRelIDs;
			            var vRes = emxUICore.getDataPost("../configuration/VariabilityDeleteProcess.jsp", urlParams);
						var iIndex = vRes.indexOf("action=");
						var iLastIndex = vRes.indexOf(",");
						var action = vRes.substring(iIndex + "action=".length, iLastIndex);
						var iIndex2 = vRes.indexOf("msg=");
						var iLastIndex2 = vRes.indexOf(";");
						var msg = vRes.substring(iIndex2+ "msg=".length, iLastIndex2);
						msg = msg.trim();
						action = action.trim();
		            	//END AJAX CALL -->		
		            	var isModelContext = '<%=isModelContext%>';
		            	
		            	if("true" == isModelContext && "removeandrefresh"===action)
		            	{
		            		parent.location.href = parent.location.href;
		            	}
		            	else if("removeandrefresh"===action)
		            	{
			                var oXML                = contentFrameObj.oXML;
			                var selctedRowIds       = new Array(cBoxArray.length - 1);
			                for(var i = 0; i < cBoxArray.length; i++)
			                {	  
				      		      var selectedRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + cBoxArray[i] + "']");
				      		      var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
				      		      var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
				      		      var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
				      		      var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
				      		      var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
				      		      selctedRowIds[i] = rowIds;
			      	         }
			      	         contentFrameObj.emxEditableTable.removeRowsSelected(selctedRowIds);//delete node from SB
			      	         if("false"===VarIsNonPRDContext){//only incase of Product Context Tree need to refreshed to remove selected Objects
                                 var parentRefresh   = getTopWindow().window;
			      	             for(var i = 0; i < cBoxArray.length; i++){
			      	        		 var objectId = cBoxArray[i];
			      	        		 parentRefresh.deleteObjectFromTrees(objectId, false);
			      	             }
			      	          }//delete node from Tree
			             }
		            	 else if("checkTrigger"===action)
		                 {
			      	           if((msg !== null)||(msg.length > 0))
			      	           {
				      	           window.location.href = "../components/emxMQLNotice.jsp";
			      	           }
			             }
		                 else if((msg !== " ") && (msg !== "") && (msg !== null) && (msg.length > 0))
		                 {
			      	           alert(msg);
		      	         }
		        	}//if SB is not having any markup
		           </script> 
	        <%        	
		        }else{ %>
		        <script language="javascript" type="text/javaScript">
		        alert("<emxUtil:i18n localize='i18nId'>emxConfiguration.Alert.CanNotRemoveDeleteVariesBy</emxUtil:i18n>");
		        </script>
	        <%        	
	          }//Product remove CF alert if used in DV
	        }
       }//if selected note is not Root node
 }//First Time without mode passed   
%>


<%--
  FullSearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%> 
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%> 
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.configuration.ProductConfiguration"%> 
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Enumeration" %>
<%@page import="com.matrixone.apps.domain.util.mxType " %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%
  boolean bIsError = false;
// Modified for IR IR-030496V6R2011WIM
String action = "";
String msg = "";
String strMode = emxGetParameter(request,"mode");
String strvariabilityMode = emxGetParameter(request,"variabilityMode");
String strContext = emxGetParameter(request,"context"); //moved this line from try block to here for IR-015198V6R2011x

  try
  {
     String strObjId = emxGetParameter(request, "objectId");
     // strTypeAhead for IR-087027V6R2012
     String strTypeAhead = emxGetParameter(request,"typeAhead");
     String strRelName = emxGetParameter(request,"relName");
     String strFunctionality = emxGetParameter(request,"functionality"); 
     String strIsUNTOper = emxGetParameter(request,"isUNTOper");   
     String strRuleDisplay               = "";
	 
     if (strFunctionality!=null){
         strMode = "wizard";
     }
     //get the selected Objects from the Full Search Results page
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
     //If the selection is empty given an alert to user
     
     if(strContextObjectId==null){   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
     //If the selection are made in Search results page then     
     else{
         
        if(strMode.equalsIgnoreCase("Chooser"))
	    {
	         try{
	             //gets the mode passed
	              String strSearchMode = emxGetParameter(request, "chooserType");
	 			 if (strSearchMode.equals("Milestone"))
	             {
		             String fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                 String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	                 String strMilestoneIds[] = new String[strContextObjectId.length];
	                 
	                 StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	                 strMilestoneIds[0] = strTokenizer.nextToken();
	                 
	                 StringList strSelects = new StringList();
	                 strSelects.addElement(DomainObject.SELECT_NAME);
	                 strSelects.addElement("physicalid");
	                 
	                 MapList MilestoneDetails = DomainObject.getInfo(context,strMilestoneIds,strSelects);
	                 
	                 StringBuffer strBufContextObjectName = new StringBuffer();
	                 strBufContextObjectName.append("[");
	                 StringBuffer strBufContextObjectId = new StringBuffer();
                   	 strBufContextObjectName.append(((Map)MilestoneDetails.get(0)).get(DomainObject.SELECT_NAME).toString());
                   	 strBufContextObjectName.append("]");
                   	 strBufContextObjectId.append(((Map)MilestoneDetails.get(0)).get("physicalid").toString());
	                 %>
	                 <script language="javascript" type="text/javaScript">
	                 var vfieldNameActual="";
	               	  var vfieldNameDisplay="";
	                   if(getTopWindow().getWindowOpener()){
	                   		vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                   		vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                   }else{
	                   	   	vfieldNameActual = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                       	vfieldNameDisplay = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                   }
	                   vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strBufContextObjectName.toString())%>" ;
	                   vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strBufContextObjectId.toString())%>" ;
	                   </script>
	                     <%if (strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){ %>
	                      <script language="javascript" type="text/javaScript">
	                   		  //getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
	                   		  getTopWindow().closeWindow();
	                   	   </script>
	                   <%}%>
	              <%
				 } else if (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser"))
	              {   	                  
	                  //added for the CR no. 371091 
	                  String strModeValue = emxGetParameter(request, "value");
	                  
	                  String fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	                  
	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
	                  DomainObject objContext = new DomainObject(strObjectId);
	                  
	                  StringList selectables = new StringList();
	                  selectables.add(DomainConstants.SELECT_NAME);
	                  selectables.add(DomainConstants.SELECT_REVISION);
	                  selectables.add(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);
	                  
	                  Map mapUsedResult = objContext.getInfo(context, selectables);
	                  
	                  String strObjName = (String)mapUsedResult.get(DomainConstants.SELECT_NAME);
	                  String strObjRev = (String)mapUsedResult.get(DomainConstants.SELECT_REVISION);
	                  String isLeafLevel=(String)mapUsedResult.get(ConfigurationConstants.SELECT_ATTRIBUTE_LEAF_LEVEL);
	                  
	                  StringBuffer sBObjNameRev = new StringBuffer();
	                  sBObjNameRev.append(strObjName);
	                  sBObjNameRev.append(" ");
	                  sBObjNameRev.append(strObjRev);
	                  
	                  String strContextObjectName = sBObjNameRev.toString();
	                  
	                  
	                  //String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	                  
	                  %>
	                  <script language="javascript" type="text/javaScript">

		                  var vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
		                  var vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
		                 //Start for IR-087027V6R2012
		                    if(!vfieldNameActual || !vfieldNameDisplay[0]){
		                    	   vfieldNameActual = getTopWindow().frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
		                    	    vfieldNameDisplay = getTopWindow().frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                        }
	                     
		                  //End for IR-087027V6R2012
		                   
	                      vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
	                      vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                     
	                     //commented for the CR no. 371091               	                   			                    
	                     // getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
	                  
	                  </script>
	                  <!-- added for the CR no. 371091 start -->
		              <%
		              if(strModeValue != null && !"".equalsIgnoreCase(strModeValue) && !"null".equalsIgnoreCase(strModeValue))
		              {
		               if(strModeValue.equalsIgnoreCase("BasedOn"))
		               {
		                  
		                 String strObjType = objContext.getInfo(context,DomainConstants.SELECT_TYPE);
		                 if(mxType.isOfParentType(context,strObjType,com.matrixone.apps.productline.ProductLineConstants.TYPE_PRODUCTS))
		                 {
		                   
		           	  %>    
		                    <script language="javascript" type="text/javaScript">	                     		                  
		                   
		                      if(getTopWindow().getWindowOpener().document.getElementById("txtProductContext").value != "")
		                    	  getTopWindow().getWindowOpener().document.getElementById("txtProductContext").value = ""; 
		                      //Clear Milestone Field
		                      if(getTopWindow().getWindowOpener().document.getElementById("txtMilestone").value != "")
		                    	  getTopWindow().getWindowOpener().document.getElementById("txtMilestone").value = ""; 
		                      if(getTopWindow().getWindowOpener().document.getElementById("strMilestoneId").value != "")
		                    	  getTopWindow().getWindowOpener().document.getElementById("strMilestoneId").value = ""; 
		                        
		                      obj = getTopWindow().getWindowOpener().document.getElementById("btnProductContext"); 
		                      obj.disabled = true;
		                      obj = getTopWindow().getWindowOpener().document.getElementById("btnMilestone"); 
		                      if(obj.disabled)
				                  obj.disabled = false;

		                   </script>   
		           	 <% 
		                 }else
		                 {
		             %>
		                 <script language="javascript" type="text/javaScript">  
		                  
			                  obj = getTopWindow().getWindowOpener().document.getElementById("btnProductContext"); 	                 
			                  if(obj.disabled)
			                  obj.disabled = false;
			                  //Clear Milestone Field
			                  if(getTopWindow().getWindowOpener().document.getElementById("txtMilestone").value != "")
			                	  getTopWindow().getWindowOpener().document.getElementById("txtMilestone").value = ""; 
		                      if(getTopWindow().getWindowOpener().document.getElementById("strMilestoneId").value != "")
		                    	  getTopWindow().getWindowOpener().document.getElementById("strMilestoneId").value = ""; 
		                      obj = getTopWindow().getWindowOpener().document.getElementById("btnMilestone"); 
		                      obj.disabled = true;  
			                         
		                 </script>
		                     	                     
		             <%      
		                 }
		                 if(mxType.isOfParentType(context,strObjType,com.matrixone.apps.productline.ProductLineConstants.TYPE_PRODUCT_VARIANT)){
		                 %>
		                 <script language="javascript" type="text/javaScript">  
	                      obj = getTopWindow().getWindowOpener().document.getElementById("btnMilestone"); 
		                  obj.disabled = true;
	                      </script>
	                      <%}
		               }
		               if(strModeValue.equalsIgnoreCase("ConfigurationFeatureCopyFrom")){
		            	   String contextObjId = emxGetParameter(request, "objIdContext");
		            	   
		            	   %>
		            	   <script language="javascript" type="text/javaScript">		                                   
		                      getTopWindow().getWindowOpener().getTopWindow().frames['portalDisplay'].frames['FTRConfigurationFeatureCopySecondStep'].document.location.href =
		                    	  "../common/emxIndentedTable.jsp?suiteKey=Configuration&selection=multiple&expandProgram=ConfigurationFeature:getVariabilityStructureForCopyFromCopyTo&table=FTRCopyConfigurationFeatureTable&portalMode=true&HelpMarker=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&variabilityMode=<%=strvariabilityMode%>&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&submitURL=../configuration/ConfigurationFeatureCopyFromFSDialog.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjId)%>&objIdContext=<%=XSSUtil.encodeForURL(context,contextObjId)%>&selectedObjectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>";          	 
		                   </script>		                      
		            	   <%
		               }
		               if(strModeValue.equalsIgnoreCase("LogicalFeatureCopyFrom")){
		            	   String contextObjId=emxGetParameter(request, "objIdContext");
		            	   if(isLeafLevel.equalsIgnoreCase("Yes")){
		            		   
		            		   %>
		       		 	       <script language="javascript" type="text/javaScript">
		       		 	       alert("Not Allow on Leaf Level");
		       		 	       </script>
		       		 	       <% 
		            	   }else{
		            		   String strAppendURL= "";
			            	   //strAppendURL= "StructureEffectivity|Effectivity"; //Before Decoupling
			            	   strAppendURL= "VariantEffectivity|Effectivity"; //After Decoupling
		            	   %>
		            	   <script language="javascript" type="text/javascript">
		            	   getTopWindow().getWindowOpener().getTopWindow().frames['portalDisplay'].frames['FTRLogicalFeatureCopySecondStep'].document.location.href =
		                    	  "../common/emxIndentedTable.jsp?suiteKey=Configuration&selection=multiple&expandProgram=LogicalFeature:getLogicalFeatureStructure&table=FTRCopyLogicalFeatureTable"
		                    			  +"&appendURL=<%=strAppendURL%>&HelpMarker=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&submitURL=../configuration/LogicalFeatureCopyFromFSDialog.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjId)%>&objIdContext=<%=XSSUtil.encodeForURL(context,contextObjId)%>&selectedObjectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>";
		            	   </script>
		            	   <%
		            	   }
		               }
		               if(strModeValue.equalsIgnoreCase("ConfigurationFeatureCopyTo")){
		            	   %>
		            	   <script language="javascript" type="text/javascript">		            		            	  
		            	   getTopWindow().getWindowOpener().getTopWindow().frames['portalDisplay'].frames['FTRConfigurationFeatureCopySecondStep'].document.location.href =
		            		   "../common/emxIndentedTable.jsp?suiteKey=Configuration&selection=single&expandProgram=ConfigurationFeature:getVariabilityStructureForCopyFromCopyTo&table=FTRCopyConfigurationFeatureTable&selection=single&mode=edit&toolbar=FTRConfigurationFeatureCopyToStepTwoMenu&massUpdate=false&HelpMarker=false&variabilityMode=<%=strvariabilityMode%>&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>"; 	
		            	   </script>
		            	   <%
		               }
		               if(strModeValue.equalsIgnoreCase("LogicalFeatureCopyTo")){
		            	   String strAppendURL= "";
		            		  //strAppendURL= "StructureEffectivity|Effectivity"; //Before Decoupling
		            		  strAppendURL= "VariantEffectivity|Effectivity"; //After Decoupling
		            	   %>
		            	   <script language="javascript" type="text/javascript">		            		            	  
		            	   getTopWindow().getWindowOpener().getTopWindow().frames['portalDisplay'].frames['FTRLogicalFeatureCopySecondStep'].document.location.href =
		            		   "../common/emxIndentedTable.jsp?suiteKey=Configuration&selection=single&expandProgram=LogicalFeature:getLogicalFeatureStructure&table=FTRCopyLogicalFeatureTable"
		            				   +"&appendURL=<%=strAppendURL%>&selection=single&mode=edit&toolbar=FTRLogicalFeatureCopyToStepTwoMenu&massUpdate=false&HelpMarker=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>";	                    	
		            	   </script>
		            	   <%
		               }

		              }
		            //if block for IR-087027V6R2012
		              if (strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){
	                 %>
	                  <script language="javascript" type="text/javaScript">  
	                  	                  
	                  //getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
	                  getTopWindow().closeWindow();
	                  </script>
	                  
	                  <!-- added for the CR no. 371091 end -->
	               <%
		              }
	              }

					//Boolean compatibility

				if (strSearchMode.equals("RuleContext"))
						
					{   
	                  String fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	                  String strObjectId = strTokenizer.nextToken() ; 
	    
	                  DomainObject objContext = new DomainObject(strObjectId);
	                  //String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
					  String strContextObjectName ="";
					  String strContextType = objContext.getType(context);

						HashMap requestMap = new HashMap();
				 		strRuleDisplay = PersonUtil.getRuleDisplay(context);
						//Modified  for  IR Mx376196
						if(strRuleDisplay.equalsIgnoreCase(ConfigurationConstants.RULE_DISPLAY_FULL_NAME))
						{
						    requestMap.put("context",context);
							requestMap.put("id",strObjectId.trim());	
    					    strContextObjectName =  (String)JPO.invoke(context,"emxRule",null,"getTNRForObject", JPO.packArgs (requestMap),String.class);	
						}//Modified  for  IR Mx376196
						else if(strRuleDisplay.equalsIgnoreCase(ConfigurationConstants.RULE_DISPLAY_MARKETING_NAME))
						{
							requestMap.put("context",context);
							requestMap.put("id",strObjectId);	
				            strContextObjectName=  (String)JPO.invoke(context,"emxRule",null,"getMarketingName",JPO.packArgs (requestMap),String.class);
					    //start  for  IR Mx376196
						}else {
							requestMap.put("context",context);
                            requestMap.put("id",strObjectId);   
                            strContextObjectName=  (String)JPO.invoke(context,"emxRule",null,"getMarketingNameRev",JPO.packArgs (requestMap),String.class);
                        //End  for  IR Mx376196
						}
						
	                      %>
						  
	                      <script language="javascript" type="text/javaScript">
	               		  var vField="<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>";
						   var vfieldNameActual = getTopWindow().getWindowOpener().document.getElementById(vField);
						   
							  var vIndex=vfieldNameActual.length;
							
                              var strContextObjectId="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";
							  var isValPresent = false;
							  for(var i=0;i<vIndex;i++)
					          {
								  
								if(strContextObjectId == (vfieldNameActual.options[i].value))
								  {
									  isValPresent = true;
										break;
								  }
							  }

							if(isValPresent == false)
								{
									vfieldNameActual.length++;
									
									vfieldNameActual.options[vIndex].value="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>"; 
									vfieldNameActual.options[vIndex].text="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>";
									vfieldNameActual.options[vIndex].selected="true";
									vfieldNameActual.options[vIndex].id="<%=XSSUtil.encodeForJavaScript(context,strContextType)%>";
									
							    }  
	                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
	                          getTopWindow().closeWindow();
	                      </script>

				
	                  <%
	              }
       
	         }   
	          catch (Exception e){
	              session.putValue("error.message", e.getMessage());  
	          }
	     }
		 else if(strMode.equals("AddExisting")){
			 ENOCsrfGuard.validateRequest(context, session, request, response);
		     if((strIsUNTOper!= null && strIsUNTOper.equalsIgnoreCase("true")) 
   		 	        && com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appInstallTypeUnitTracking",false,null,null)){
   		 		if(strRelName!=null)
					{
						strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
					}
   		 	    String strMesg = ProductLineUtil.checkAndConnectBuilds(context, strObjId, strRelName, strContextObjectId);
   		 	    if(strMesg != null && strMesg.length()>0) {
   		 	       %>
   		 	       <script language="javascript" type="text/javaScript">
   		 	       alert("<%=XSSUtil.encodeForJavaScript(context,strMesg)%>");
   		 	       </script>
   		 	       <% 
   		 	    }
   		 	 %>
					<script language="javascript" type="text/javaScript">
					window.parent.getTopWindow().getWindowOpener().location.href = window.parent.getTopWindow().getWindowOpener().location.href;
					window.getTopWindow().closeWindow();
					</script>   
	          <%	
   		 	    
   		 	}else {

   		 	    Object objToConnectObject = "";
		        String strToConnectObject = "";
			    String strSelectedFeatures[] = new String[strContextObjectId.length];
				if(strRelName!=null){
				strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
				}
		        String strFromSide = emxGetParameter(request,"from");
		        boolean From = true;
				if (strFromSide!=null && strFromSide.equals("false"))
				{
		            From = false; 
		        }	
				

			        for(int i=0;i<strContextObjectId.length;i++)
					{
						StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
						
						//Extracting the Object Id from the String.
						for(int j=0;j<strTokenizer.countTokens();j++)
						 {
				             objToConnectObject = strTokenizer.nextElement();
				             strToConnectObject = objToConnectObject.toString();
				             strSelectedFeatures[i]=strToConnectObject;
				             break;
				         }	
		          if(strContext==null){  						
						//Code for connecting the objects 						
						//Modifications done on 13th May 2008 for bug Id 353652, boolean is true to maintain History
						if(From==false){
							// Get the type of objects
							DomainObject doObjectID = new DomainObject(strToConnectObject);
							String strType = doObjectID.getInfo(context,DomainObject.SELECT_TYPE);
							// Connect it with relationship
							// Connect it with relationship Start: IR-096601V6R2012 
                            DomainRelationship newRelObj= ProductLineCommon.connectWithReturnId(context,strObjId,strRelName,strToConnectObject,true);
							if(ProductLineCommon.isOfParentRel(context, strRelName, ConfigurationConstants.RELATIONSHIP_QUANTITY_RULE))
							{
								ProductConfiguration.deltaUpdateBOMXMLAttributeOnPC(context,strObjId,"QuantityUpdate");
							}
                            //if object are rules then inherit to Model & Products
                            if(strType!=null && (strType.equals(ConfigurationConstants.TYPE_BOOLEAN_COMPATIBILITY_RULE) || strType.equals(ConfigurationConstants.TYPE_MARKETING_PREFERENCE) || strType.equals(ConfigurationConstants.TYPE_RULE_EXTENSION) || strType.equals(ConfigurationConstants.TYPE_FIXED_RESOURCE)))
                            {
                                //1.updating mandatory attribute to "NO" in case of rules,as the beiing mandatory is related to COntext specific
                                //2.commenting out the rule inheritenance, when mandatory = NO, there is no rule inheritence
                                //ConfigurableRulesUtil.commonRuleInheritance(context,new String[]{strObjId,strToConnectObject,strRelName,ConfigurationConstants.RANGE_VALUE_YES});
                                PropertyUtil.setGlobalRPEValue(context,"RuleContext", "Create");
                                //DomainRelationship.setAttributeValue(context,strNewRel,ConfigurationConstants.ATTRIBUTE_MANDATORYRULE,ConfigurationConstants.RANGE_VALUE_NO);
                                newRelObj.setAttributeValue(context,ConfigurationConstants.ATTRIBUTE_MANDATORYRULE,ConfigurationConstants.RANGE_VALUE_NO);
                                PropertyUtil.setGlobalRPEValue(context,"RuleContext", "FALSE");
                                //END: IR-096601V6R2012 
							}
						}else{
							DomainRelationship.connect(context,strToConnectObject,strRelName,strObjId,true);
						}
                       //till here

						%>
						<script language="javascript" type="text/javaScript">
						window.parent.getTopWindow().getWindowOpener().location.href = window.parent.getTopWindow().getWindowOpener().location.href;
						window.getTopWindow().closeWindow();
						</script>   
						<%	
			        }
				  }
				
   		 }		

		} 

     else if(strMode.equalsIgnoreCase("searchDelete"))
     {	
         try{
         String strObjType = "";
         String strObjIds[] = new String[strContextObjectId.length];
         ENOCsrfGuard.validateRequest(context, session, request, response);
            for(int i=0;i<strContextObjectId.length;i++)
			{
	          //str_TableRowIDs=str_TableRowIDs + strContextObjectId[i]+"|";
              StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] , "||");
	          String strObjectID = strTokenizer.nextToken();
	          strObjIds[i]= strObjectID;
	          DomainObject domObjId = new DomainObject(strObjectID);
	          strObjType = domObjId.getInfo(context,DomainObject.SELECT_TYPE);
			} 
            
            if(strObjType.equalsIgnoreCase(ConfigurationConstants.TYPE_PRODUCT_CONFIGURATION))
	        {
            	
	             // Deleting objects from database
	             ProductConfiguration.deleteObjects(context,strObjIds);
// Modified for IR IR-030496V6R2011WIM
                 action = "remove"; 
	             %>
	             <script language="javascript" type="text/javaScript">
	             //parent.location.href = parent.location.href;
	             </script>
	             <% 
	         }	
	         
         }	    
         catch (Exception e){
        	 bIsError=true;
             session.putValue("error.message", e.getMessage());  
         }
         } 
     }
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
    //emxNavErrorObject.addMessage(e.toString().trim());
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
//Added this block for IR-015198V6R2011x
//null checks added in if condition for IR-065502V6R2011x 
if(strMode!=null && strMode.equals("AddExisting") && strContext!=null && strContext.equalsIgnoreCase("Part"))
{
	%>
       <script language="javascript" type="text/javaScript">
        //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
        getTopWindow().closeWindow();
        //nextgenUI  has been changed for asexsisting part in GBOm of product,feature,gbomparttable
        //we can't use findframe with details display, becuse of addesisiting in gbomparttable comes here and it is popup portal page which doen't have "details dsiplay iframe "
                                           
        getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
       
       
       
       </script>
       
    <%
}
// Modified for IR IR-030496V6R2011WIM
//IR-037276V6R2011- IF there is no exception in above delete opearation then refresh Page.
if(!bIsError && strMode.equalsIgnoreCase("searchDelete"))
    {       
      action = "remove";
      msg = "";
      out.clear();
      response.setContentType("text/xml");
    %>
    <mxRoot>
        <!-- XSSOK -->    
        <action><![CDATA[<%= action %>]]></action>
        <!-- XSSOK -->
        <message><![CDATA[    <%= msg %>    ]]></message>    
    </mxRoot>
    <%
    }
 %>

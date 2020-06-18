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

<%@page import="com.matrixone.apps.common.util.FormBean"%> 
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%> 
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%> 
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%> 
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.db.Context"%> 
<%@page import="com.matrixone.apps.productline.Image"%>
<%@page import = "com.matrixone.apps.productline.TestCase"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  boolean bIsError = false;
  boolean isRefreshTree = false;
// Modified for IR IR-030496V6R2011WIM
String action = "";
String msg = "";
String strMode = emxGetParameter(request,"mode");
  try
  {
     String strObjId = emxGetParameter(request, "objectId");
     String strContext = emxGetParameter(request,"context");
     String strRelName = emxGetParameter(request,"relName");   
     String strIsUNTOper = emxGetParameter(request,"isUNTOper");   
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
     String strToConnectObjectType = "";
     String[] selectedBuildIds = null;
     //IR-077450V6R2012
     String strTypeAhead = emxGetParameter(request,"typeAhead");
     
     String strAppendRevision = emxGetParameter(request,"appendRevision");
   
     if(strContextObjectId==null)
		 {   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
 
     else
		 {	
		 if(strMode.equals("AddExisting")){
			%>
	        <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
	        <%			 
      	 	boolean isConnected = false;	
      		if(strIsUNTOper != null && strIsUNTOper.equalsIgnoreCase("true")){
      			if(strRelName != null){
 					strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
 				}
      		 	if(com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,
  		 	       		"appInstallTypeUnitTracking",false,null,null)){
      		 		ContextUtil.pushContext(context);
	      			String strMesg = ProductLineUtil.checkAndConnectBuilds(context, strObjId, strRelName, strContextObjectId);
	      			ContextUtil.popContext(context);
	      		 	if(strMesg != null && strMesg.length()>0){
	 %>
	      		 	       <script language="javascript" type="text/javaScript">
	      		 	       alert("<%=XSSUtil.encodeForJavaScript(context,strMesg)%>");
	      		 	       </script>
	 <% 
	      		 	}
      		 	}else{
      		 		selectedBuildIds = new String[strContextObjectId.length];
      		 		for(int i=0; i<strContextObjectId.length; i++){
      		 			StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
      		 			selectedBuildIds[i] = (String) strTokenizer.nextElement();      		 			
      		 		}
      		 		DomainRelationship.connect(context,new DomainObject(strObjId),strRelName, true, selectedBuildIds);
      		 	}
     %>
				<script language="javascript" type="text/javaScript">
					var detailsDisplay = openerFindFrame(getTopWindow(),"PLCProductBuildTreeCategory");
					if (detailsDisplay == null) {
						detailsDisplay = openerFindFrame(getTopWindow(),"detailsDisplay");                        
			        }
					detailsDisplay.editableTable.loadData();
					detailsDisplay.rebuildView();
				    window.getTopWindow().closeWindow();	
		    	//IR-026772V6R2011 end
				</script>   
	 <%	
      		 	    
      		}else{
		        Object objToConnectObject = "";
		        String strToConnectObject = "";
				DomainRelationship gbomFromRaltionship =new DomainRelationship();
			    String strSelectedFeatures[] = new String[strContextObjectId.length];
				if(strRelName!=null)
				{
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
		          if(strContext==null)
					 {  						
						//Code for connecting the objects 
						//Modifications to fix 353652 - starts

						DomainObject domToConnectObject = new DomainObject(strToConnectObject);
						strToConnectObjectType = domToConnectObject.getInfo(context,DomainObject.SELECT_TYPE);
			//Mx378395			
	                    StringList relSelects = new StringList(DomainRelationship.SELECT_ID);   
                        StringList objSelects = new StringList(DomainConstants.SELECT_ID);
                        String objectWhere = DomainConstants.SELECT_ID + "=="+ strObjId;
	                        
					    //Modifications to fix 357231 - starts 
						if (mxType.isOfParentType(context, strToConnectObjectType,ProductLineConstants.TYPE_PORTFOLIO))
						{						    
                            MapList mpRelatedObjects = domToConnectObject.getRelatedObjects(context
                                    ,ProductLineConstants.RELATIONSHIP_PORTFOLIO
                                    ,"*"
                                    ,objSelects
                                    ,relSelects
                                    ,false
                                    ,true
                                    ,(short)0
                                    ,objectWhere
                                    ,null
                                    ,0);	
                            if(mpRelatedObjects != null && mpRelatedObjects.size() == 0){
							 DomainRelationship.connect(context,strToConnectObject,strRelName,strObjId,From);
                            }else{
                            	isConnected =  true;
                            	String strAlertMessage = i18nStringNowUtil("emxProduct.Alert.ObjectAlreadyConnectedToPortfolio",bundle,acceptLanguage);
                                
                            %>
                            <script language="javascript" type="text/javaScript">
                                   var strAlertMessage = "<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>";
                                   alert(strAlertMessage);
                            </script>
                            <%
                            
                            }

						}
						else if(mxType.isOfParentType(context, strToConnectObjectType,ProductLineConstants.TYPE_TEST_CASE))
						{						    
						    ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
						    DomainRelationship.connect(context,strObjId,strRelName,strToConnectObject,From);
						    ContextUtil.popContext(context);
						}
					    // added to fix IR-013980
                        else if(mxType.isOfParentType(context, strToConnectObjectType,ProductLineConstants.TYPE_PERSON))
                        {                           
	                            DomainRelationship.connect(context,strToConnectObject,strRelName,strObjId,From);
                        }
						else
						{
						    DomainRelationship.connect(context,strObjId,strRelName,strToConnectObject,From);	
						    if(strRelName.equals(ProductLineConstants.RELATIONSHIP_PRODUCTLINE_MODELS))
						    {
						    	isRefreshTree = true;
						    }
						    if(strRelName.equalsIgnoreCase(ProductLineConstants.RELATIONSHIP_IMAGES))
						    {
						        
						        /* The setSequenceOrder method is called with the required parameters
					             * to set the attribute value of relationship
					             */
					            Image img = new Image();
					            img.setSequenceOrder(context, strObjId,strRelName, strRelName, strToConnectObject);
						      
					            //Added for IR-012154V6R2011WIM STARTS
	                            DomainObject domObject = DomainObject.newInstance(context, strObjId);
	                            String strPrimaryImageId = domObject.getInfo(context, "from[" + ProductLineConstants.RELATIONSHIP_PRIMARY_IMAGE + "].to.id");
	                            if (strPrimaryImageId == null) {
	                                Image image = new Image();
	                                image.setAsPrimaryImage (context, strToConnectObject,strObjId); 
	                            }
	                            //Added for IR-012154V6R2011WIM ENDS
						    }
						    /*
						    // Modified for Bug no. IR-043826V6R2011
						    The above Code marked as IR-012154V6R2011WIM STARTS - END
						    is moved inside the if condition because this was causing problem
						    when a user does AddExisting from inside the Portfolio >> Content.
						    */
						}
					    //Modifications to fix 357231 - ends
		      			//Modifications to fix 353652 - ends
			        }
		          if(isRefreshTree)
		          {%>
		        	<script language="javascript" type="text/javaScript">
		        	    // Refreshing the top corner tree structure.
			        	var objTreeBarFrame = getTopWindow().getWindowOpener().getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "emxUITreeBar");  
	                    if(objTreeBarFrame != null && objTreeBarFrame.document != null){
	                    var strUrl = objTreeBarFrame.document.location.href;
	                    if(strUrl.indexOf("structureLoaded=")>-1){
	                            var structLoadParam = strUrl.substring(strUrl.indexOf("structureLoaded="),strUrl.length);
	                            structLoadParam = structLoadParam.substring(0,structLoadParam.indexOf("&")+1);
	                            strUrl = strUrl.replace(structLoadParam,"");
	                        }
	                    objTreeBarFrame.document.location.href = strUrl;
	                    }
	                    // refreshing the list window.
	                    //took out the parent reference ofr nextgenui Changes for addexsisting model,..
	                    /* window.parent.getTopWindow().getWindowOpener().location.href = window.parent.getTopWindow().getWindowOpener().location.href;
	                    window.getTopWindow().closeWindow(); */
	                    
	                    //var listFrame = getTopWindow().getWindowOpener().parent;
	                    
	                    var parentWindowURL       = window.parent.getTopWindow().getWindowOpener().parent.location.href;
	                    var parentWindowToRefresh;
	                    if(parentWindowURL.includes("emxIndentedTable.jsp")){
	                          parentWindowToRefresh = window.parent.getTopWindow().getWindowOpener().parent;
	                    }else{
	                    	  parentWindowToRefresh = window.parent.getTopWindow().getWindowOpener();
	                    }
	                    parentWindowToRefresh.editableTable.loadData();
	                    parentWindowToRefresh.rebuildView();
                        window.parent.getTopWindow().closeWindow();
		        	</script>
		          <%
		          }else if(!isConnected){
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
		 
		if (strMode.equalsIgnoreCase("Chooser"))
			 {
			 String strSearchMode = emxGetParameter(request, "chooserType");
				 if (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser"))
	              {   
	                  
		              String fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	                  
	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	                  if("true".equalsIgnoreCase(strAppendRevision)){
	                	  strContextObjectName = strContextObjectName + " " + objContext.getInfo(context,DomainConstants.SELECT_REVISION);
	                  }
	                  %>
	                  <script language="javascript" type="text/javaScript">
	                //Start for //IR-077450V6R2012
	                  var vfieldNameActual="";
	                	  var vfieldNameDisplay="";
	                    if(getTopWindow().getWindowOpener()){
	                       vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                       vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                    }else{
	                    	   vfieldNameActual = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                                  vfieldNameDisplay = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                          }
                       
                        
	                      vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
	                      vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                      </script>
	                      <%if (strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){ %>
	                       <script language="javascript" type="text/javaScript">
	                    
	                      //getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
	                      getTopWindow().closeWindow();
	                    </script>
	                    <%}//End for  //IR-077450V6R2012 %>
	               <%
	              } else if (strSearchMode.equals("PersonChooser"))
	              {
	                  String fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;

	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);

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
                       
	                      vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
	                      vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
	                      
	                      </script>
                          <%if (strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){ %>
                           <script language="javascript" type="text/javaScript">
                        
                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
                      getTopWindow().closeWindow();
                        </script>
                        <%}//End for  //IR-077450V6R2012 %>
					<%
				    }
	              else if (strSearchMode.equals("SlideInFormChooser"))
                 {   
                      
                      String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                      String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                      
                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
                      DomainObject objContext = new DomainObject(strObjectId);
                      String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
                      %>
                      <script language="javascript" type="text/javaScript">

                      var openerObj = getTopWindow().getWindowOpener();
                      if(openerObj != null){
                    	  var vfieldNameActual = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          var vfieldNameDisplay = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");

                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;

                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                          getTopWindow().closeWindow();
                      }
                      else{
                    	  var vfieldNameActual = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          var vfieldNameDisplay = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");

                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                      }
                        </script>
                   <%
                  }
	              else if (strSearchMode.equals("RDO") || strSearchMode.equals("PartFamily") || strSearchMode.equals("Program"))
	                 {         	  
	            		           	    
	            	  String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                      String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                      String fieldNameOID = fieldNameActual + "OID";
                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
                      DomainObject objContext = new DomainObject(strObjectId);
                      String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
                      %>
                      <script language="javascript" type="text/javaScript">

                      var vfieldNameActual = "";
                      var vfieldNameDisplay = "";
                      var vfieldNameOID = "";
                      var flag = "false";
                      var openerObj = getTopWindow().getWindowOpener();

                      if(openerObj != null){                          
                          vfieldNameActual = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          vfieldNameDisplay = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                      }

                      if(vfieldNameDisplay[0]){                    	  
                          vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                          vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                          flag = "true";
                      }
                      else{                    	  
                          vfieldNameActual = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          vfieldNameDisplay = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                          
                          if(vfieldNameDisplay[0]){                        	
                        	  vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                              vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                          }
                          else{
	                        	vfieldNameDisplay = self.parent.frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                            vfieldNameActual = self.parent.frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
	                            vfieldNameOID = self.parent.frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameOID)%>");
	                       	    if(vfieldNameDisplay[0]){		                      
	                       	    	vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
	                                vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                                vfieldNameOID[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                       	    }
	                       	    else{			                       	                       	                        	  
		                        	  vfieldNameDisplay = self.getTopWindow().frames['slideInFrame'].frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
		                        	  vfieldNameActual = self.getTopWindow().frames['slideInFrame'].frames['formEditDisplay'].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
		                        	  vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
		                              vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                       	    }
                          }
                          
                      }

                      if(flag == "true"){
                          //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                    	  getTopWindow().closeWindow();
                      }                      
                      </script>
                      <%
                  }
		     }
		 
		
		if (strMode.equalsIgnoreCase("ProductandProductConfigurationChooser"))
		{
			 String strSearchMode = emxGetParameter(request, "chooserType");
	                  
			 String fieldName = emxGetParameter(request, "fieldName");
			 String fieldNameActual = emxGetParameter(request, "fieldNameActual");
             String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
			 String buildNumberVal			= emxGetParameter(request, "buildNumber");
			 String	shortHandNotVal			= emxGetParameter(request, "shortHandNotation");
             StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
             String strObjectId = strTokenizer.nextToken() ; 
             DomainObject objContext = new DomainObject(strObjectId);
             
             String strProductId = null;
             String strProductName = null;
             String strProductfieldNameActual = null;
             String strProductfieldNameDisplay = null;             
			 String strBuildUnitNumber			= null;
			 String strShorthandNotation		= null;
             
             if (strSearchMode.equalsIgnoreCase("ProductConfiguration")){
                 strProductId = objContext.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.id");
                 strProductName = objContext.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_PRODUCT_CONFIGURATION+"].from.name");
				 DomainObject objectProduct		= new DomainObject(strProductId);

                 String strModelId					= objectProduct.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_PRODUCTS+"].from.id");
                 String strModelName					= objectProduct.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_PRODUCTS+"].from.name");
                 if(strModelId == null || "".equals(strModelId)){
                	 strModelId	= objectProduct.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.id");
                	 strModelName = objectProduct.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.name");
                 }

                 strProductfieldNameActual = "ProductOID";
                 strProductfieldNameDisplay = "ProductDisplay";
				 DomainObject objectModel		= new DomainObject(strModelId);
				 strBuildUnitNumber				= objectModel.getAttributeValue(context, ProductLineConstants.ATTRIBUTE_LAST_BUILD_UNIT_NUMBER);
				 strShorthandNotation			= objectModel.getAttributeValue(context, ProductLineConstants.ATTRIBUTE_PREFIX);
		     }
			 
			 else if(strSearchMode.equalsIgnoreCase("Product")){
			 
				 strProductId					= objContext.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_PRODUCTS+"].from.id");
                 strProductName					= objContext.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_PRODUCTS+"].from.name");
                 if(strProductId == null || "".equals(strProductId)){
                	 strProductId					= objContext.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.id");
                     strProductName					= objContext.getInfo(context,"to["+ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.name");
                 }
                 
				 strProductfieldNameActual		= "ProductOID";
                 strProductfieldNameDisplay		= "ProductDisplay";

				 DomainObject objectModel		= new DomainObject(strProductId);
				 
				 strBuildUnitNumber				= objectModel.getAttributeValue(context, ProductLineConstants.ATTRIBUTE_LAST_BUILD_UNIT_NUMBER);
                 strShorthandNotation			= objectModel.getAttributeValue(context, ProductLineConstants.ATTRIBUTE_PREFIX);
				
				 
				
             }
                   
             String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
              int iUnitNumber= new Integer(strBuildUnitNumber);
			  if ("".equals(strBuildUnitNumber))
					 strBuildUnitNumber			= "1";
				 else
					 strBuildUnitNumber			= String.valueOf(iUnitNumber + 1);
				
				strShorthandNotation			= strShorthandNotation.concat(strBuildUnitNumber);
             
             %>
             <script language="javascript" type="text/javaScript">
             
                 var vfieldName = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldName)%>");
                 var vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                 var vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
				 var vfieldBuildNumber			= getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,buildNumberVal)%>");
				 var vfieldShortHandNot			= getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,shortHandNotVal)%>");

                 
                 if ("<%=XSSUtil.encodeForJavaScript(context,strSearchMode)%>" =="ProductConfiguration"){                 
	                 var vProductfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<xss:encodeForJavaScript><%=strProductfieldNameActual%></xss:encodeForJavaScript>");
	                 var vProductfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<xss:encodeForJavaScript><%=strProductfieldNameDisplay%></xss:encodeForJavaScript>");
	                 vProductfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strProductName)%>" ;
	                 vProductfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strProductId)%>" ;
                 }
                
                 if(vfieldName[0]){
                	 vfieldName[0].value = "<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                 }                 
                 vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                 vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                 if(vfieldBuildNumber[0] != undefined){
				 vfieldBuildNumber[0].value				="<%=XSSUtil.encodeForJavaScript(context,strBuildUnitNumber)%>" ;
				 }
				 if(vfieldShortHandNot[0] != undefined){
				 vfieldShortHandNot[0].value			="<%=XSSUtil.encodeForJavaScript(context,strShorthandNotation)%>" ;
				 }
                
               
                 //getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
                 getTopWindow().closeWindow();
             
            </script>
          	<%
		}
		 if(strMode.equalsIgnoreCase("searchDelete"))
		  {	
			   %>
	           <%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
	           <%			 
			     PropertyUtil.setGlobalRPEValue(context,"ContextRemoveCheckForMCF","TRUE");
		         String str_TableRowIDs = "";
		         String strObjType = "";
		         String strObjIds[] = new String[strContextObjectId.length];
		            for(int i=0;i<strContextObjectId.length;i++)
					{
			          
		              String str = strContextObjectId[0];              
		              str_TableRowIDs=str_TableRowIDs + strContextObjectId[i]+"||";
		              //str_TableRowIDs =(String)strContextObjectId.toString();
		              StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] , "||");
			          String strObjectID = strTokenizer.nextToken();
			          strObjIds[i]= strObjectID;
			          DomainObject domObjId = new DomainObject(strObjectID);
			          strObjType = domObjId.getInfo(context,DomainObject.SELECT_TYPE);
					} 
		          
			        if(mxType.isOfParentType(context, strObjType,ProductLineConstants.TYPE_PRODUCTLINE))
			         {
						//Instantiating ProductLineCommon.java
			             ProductLineCommon ProductLinecommonBean = new ProductLineCommon();
			             ProductLinecommonBean.deleteObjects(context,strObjIds,false);
// Modified for IR IR-030496V6R2011WIM
			             action = "remove";
			             %>	
			             <script language="javascript" type="text/javaScript">
			              //parent.location.href = parent.location.href;
			             </script>
			             <% 
			             
			         }
			         else if(mxType.isOfParentType(context, strObjType,ProductLineConstants.TYPE_PRODUCTS))
			         {
			             
			             Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");
			             productBean.delete(context,strObjIds,strMode);
// Modified for IR IR-030496V6R2011WIM
                         action = "remove";
			             %>			            
			             <script language="javascript" type="text/javaScript">
			             //parent.location.href = parent.location.href;
			             </script>
			             <% 
			             
			         }
			         else if(mxType.isOfParentType(context, strObjType,ProductLineConstants.TYPE_BUILDS))
			         {
						 //Instantiating ProductLineCommon.java
			             ProductLineCommon commonBean = new ProductLineCommon();
			             commonBean.deleteObjects(context,strObjIds,true);
// Modified for IR IR-030496V6R2011WIM
                         action = "remove";
			             %>			            
			             <script language="javascript" type="text/javaScript">
			             //parent.location.href = parent.location.href;
			             </script>
			             <% 
			         }
			         else if(mxType.isOfParentType(context, strObjType,ProductLineConstants.TYPE_MODEL))
			         {
			             com.matrixone.apps.productline.Model modelBean = (com.matrixone.apps.productline.Model)DomainObject.newInstance(context,ProductLineConstants.TYPE_MODEL,"ProductLine");
			             String parentObjectID = null;
			             modelBean.delete(context,strObjIds,parentObjectID);
// Modified for IR IR-030496V6R2011WIM
                         action = "remove";
			             %>			            
			             <script language="javascript" type="text/javaScript">
			             //parent.location.href = parent.location.href;
			             </script>
			             <% 
			         }
			         else if(mxType.isOfParentType(context, strObjType,ProductLineConstants.TYPE_TEST_CASE))
			         {
						 boolean canDelete = false;
						 String strParentOID = null;
						 //Instantiate the common and util beans
						  ProductLineCommon commonBean = new ProductLineCommon();
			             //Checking if the selected Test Cases can be deleted
			             canDelete = TestCase.canDeleteTestCases(context,strObjIds,strParentOID,"delete");
			             if(canDelete) {
			                 //Call the deleteObjects method of ProductLineCommon to delete the selected object
			                 commonBean.deleteObjects(context,strObjIds,false);
// Modified for IR IR-030496V6R2011WIM
	                         action = "remove";
			             }
			             %>			            
			             <script language="javascript" type="text/javaScript">
			             //parent.location.href = parent.location.href;
			             </script>
			             <% 
			         }
			    }
		 
       if(strMode.equalsIgnoreCase("RDO")){
             
             String strContextObjectId1[]=emxGetParameterValues(request,"emxTableRowId");

             StringTokenizer st = new StringTokenizer(strContextObjectId1[0], "|");
             String Id1= st.nextToken();
             boolean isRel=false;

            String objType=null;
             
             try{
                 
                 DomainObject domObj=new DomainObject(Id1);

                 objType=domObj.getInfo(context,"type");
                 
                 
             }catch(Exception e){

                 isRel=true;
                 
             }

          if(objType !=null && (objType.equals(ProductLineConstants.TYPE_PRODUCT_LINE)||objType !=null && objType.equals(ProductLineConstants.TYPE_HARDWARE_PRODUCT)||objType !=null && objType.equals(ProductLineConstants.TYPE_SOFTWARE_PRODUCT)||objType !=null && objType.equals(ProductLineConstants.TYPE_SERVICE_PRODUCT)||objType !=null &&  objType.equals(ProductLineConstants.TYPE_PRODUCT_VARIANT)||objType !=null && objType.equals(ProductLineConstants.TYPE_PRODUCT_VERSION)) && objType !=null && (strObjId!=null)&&(!isRel)){%>
           <script language="javascript" type="text/javaScript">
                alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.DoNotSelectProductLine</emxUtil:i18n>");
                
                </script>
                <%}
       
            if(isRel || strObjId==null){
             

               
               //The Below code will give you Selected Entities where you need to assign RDO.
               
               String strSelectedObjectIds[]=emxGetParameterValues(request,"emxTableRowId");
               
               //This variabe will contain selected Object Ids                 
               String emxTableRowId = "";
               
               
              String strSelectedObjectsId="";         
              
               
               for(int i=0;i<strSelectedObjectIds.length;i++){
                   
                  StringTokenizer strTokenizer = new StringTokenizer(strSelectedObjectIds[i] , "|");
                  int intNoOfTokens = strTokenizer.countTokens();
                  
                  //If called from a flat Table without context.
                  //Added by A69, for the fix of hit coming from a flat Table without context
                  if(intNoOfTokens==1 || strSelectedObjectIds[i].startsWith("|")){                           
                     strSelectedObjectsId = strTokenizer.nextToken();
                     strSelectedObjectIds[i] = strSelectedObjectsId;
                      
                  }//If called from a Table with Context.                     
                  else{                       
                     strSelectedObjectsId = strTokenizer.nextToken();                                        
                     strSelectedObjectsId = strTokenizer.nextToken();
                     strSelectedObjectIds[i] = strSelectedObjectsId;
                 }
                  
               }
              //The below loop will generate a string in which all the slected Object Ids are appended with a '|' 
              for(int i=0;i<strSelectedObjectIds.length;i++){
                 if(i==(strSelectedObjectIds.length-1)){
                    emxTableRowId = emxTableRowId+strSelectedObjectIds[i];                      
                 }else{
                    emxTableRowId = emxTableRowId+strSelectedObjectIds[i]+"|";                      
                 }                   
              }
             
        try{
        StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                  String strSelectedObjectId = strTokenizer.nextToken();
                  Map requestMap=new HashMap();              
                
                 
                  requestMap.put("emxTableRowIds",emxTableRowId);
                  
                  
                  String SelectedObjectIds = "";
                  Object objToConnectObject = "";
                  String strToConnectObject = "";
                  
                //Extracting the Object Id from the String.
                    for(int j=0;j<strTokenizer.countTokens();j++){
                        SelectedObjectIds = SelectedObjectIds + objToConnectObject.toString()+"|";
                        break;
                     }
                                        
                  String strTargetURL ="../common/emxFullSearch.jsp?field=TYPES=type_Organization&table=PLCDesignResponsibilitySearchTable&Registered Suite=ProductLine&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/MassAssignRDOUtil.jsp?calledFrom=newSearch";
                
                  session.setAttribute("requestMap",requestMap);
                  %>
                  <script language="javascript" type="text/javaScript">
                  var url="<xss:encodeForURL><%=strTargetURL%></xss:encodeForURL>";
                  showChooser(url, 850, 630);                     
                  </script>
                  <%
        }

        catch (Exception e){
             session.putValue("error.message", e.getMessage());  
         }
     
          }
       }
       
       if(strMode.equalsIgnoreCase("CommonChooser")){
	    	 
	       String fieldNameActual = emxGetParameter(request, "fieldNameActual");
           String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");             
           String strSearchMode = emxGetParameter(request, "chooserType");  
          
           StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
           String strObjectId = strTokenizer.nextToken() ; 
                      
           DomainObject objContext = new DomainObject(strObjectId);
           String strContextObjectName = objContext.getInfo(context,ProductLineConstants.SELECT_NAME);
                   
         %>
                 <script language="javascript" type="text/javaScript">
                 var typeAhead = "<%=XSSUtil.encodeForJavaScript(context,strTypeAhead)%>";
                 var targetWindow = null;
                 if(typeAhead == "true") {
                	 targetWindow = window.parent;
                 } else {
                     targetWindow = getTopWindow().getWindowOpener();
                 }
                 var vfieldNameActual;
                 var vfieldNameDisplay;
                 
                 if(targetWindow.document.forms.length== 2){
                    
                    vfieldNameActual =targetWindow.document.forms[0].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>"];
                    vfieldNameDisplay = targetWindow.document.forms[0].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>"];
                 }else
                 {
                     vfieldNameActual =targetWindow.document.forms[2].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>"];
                   vfieldNameDisplay = targetWindow.document.forms[2].elements["<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>"];

                 }     
                     vfieldNameDisplay.value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;                      
                     vfieldNameActual.value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";                       
                     
                     if(typeAhead != "true")
                     //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                     getTopWindow().closeWindow();
                 </script>
         <%
	     }
     }     
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.toString());
    //emxNavErrorObject.addMessage(e.toString().trim());
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
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

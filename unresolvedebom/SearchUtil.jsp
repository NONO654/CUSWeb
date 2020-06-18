<%--  SearchUtil.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants"%>
<%@page import="com.matrixone.apps.unresolvedebom.CFFUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%
  boolean bIsError = false;
  try
  {
     String strMode = emxGetParameter(request,"mode"); 
     String jsTreeID = emxGetParameter(request, "jsTreeID");
     String strObjId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "objectId"));
     String uiType = emxGetParameter(request,"uiType");
     String strMode1 = emxGetParameter(request,"context");
     String suiteKey = emxGetParameter(request, "suiteKey");
     String regisateredSuite = emxGetParameter(request,"SuiteDirectory");
     String strRelName = emxGetParameter(request, "relName");
     //get the selected Objects from the Full Search Results page
     String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
     //If the selection is empty given an alert to user
     
     if(strContextObjectId==null){   
     %>    
       <script language="javascript" type="text/javaScript">
           alert('<emxUtil:i18n localize='i18nId'>emxEngineeringCentral.Common.PleaseSelectAnItem</emxUtil:i18n>');
       </script>
     <%}
     //If the selection are made in Search results page then     
     else{
         
     	if(strMode.equalsIgnoreCase("Chooser"))
	    {
	         try{
	             //gets the mode passed
	             //XSSOK
	              String strSearchMode = emxGetParameter(request, "chooserType");
	              // if the chooser is in the Custom JSP
	              //XSSOK
	              if (strSearchMode.equals("CustomChooser"))
	              {   
	                  String fieldNameActual = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
	                  String fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameDisplay"));
	                  
	                      StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
	                      String strObjectId = strTokenizer.nextToken() ; 
	    
	                      DomainObject objContext = new DomainObject(strObjectId);
	                      String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	                      %>
	                      <script language="javascript" type="text/javaScript">
			      //XSSOK
			      			var vfieldNameActual = null;
			      			var vfieldNameDisplay = null;
			      			if(!(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)){
			      				vfieldNameActual = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=fieldNameActual%>");
				  //XSSOK
	                          vfieldNameDisplay = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=fieldNameDisplay%>");
				  			
			      			}
			      			else{
			      				vfieldNameActual = getTopWindow().document.getElementById("<%=fieldNameActual%>");
			      				vfieldNameDisplay = getTopWindow().document.getElementById("<%=fieldNameDisplay%>");
			      			}
					//XSSOK
	                          vfieldNameDisplay.value ="<%=strContextObjectName%>" ;
				  //XSSOK
	                          vfieldNameActual.value ="<%=strObjectId%>" ;
	                          getTopWindow().closeWindow();   
	                      </script>
	                  <%
	              }
	
	              // if the chooser is in the Form
	              else if (strSearchMode.equals("FormChooser"))
	              {   
	                  String fieldNameActual = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
	                  String fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameDisplay"));
	                  
	                  java.util.StringTokenizer strTokenizer = new java.util.StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
					  DomainObject objContext = new DomainObject(strObjectId);
					  //Code added for Applicability functionality	
					  String productBuildList = null ;
					  String relatedCompanyName = null;
					  String relatedCompanyId = null;
					  String strRelationshipCompanyProduct =com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"relationship_CompanyProduct");
					  matrix.util.StringList productSelectables = new matrix.util.StringList(1);
					  productSelectables.add("from["+ProductLineConstants.RELATIONSHIP_PRODUCT_BUILD+"].to.id");
					  productSelectables.add("to["+strRelationshipCompanyProduct+"].from.name");
					  productSelectables.add("to["+strRelationshipCompanyProduct+"].from.id");

					  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
	                  %>
	                  <script language="javascript" type="text/javaScript">
	                      //XSSOK
	                      var vfieldNameActual = null;
	                      var vfieldNameDisplay = null;
	                      if(!(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)){
	                    	  vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=fieldNameActual%>");
	                    	  vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=fieldNameDisplay%>");
	                      }
	                      else{
	                    	  vfieldNameActual =  getTopWindow().document.getElementsByName("<%=fieldNameActual%>");
	      	                  vfieldNameDisplay = getTopWindow().document.getElementsByName("<%=fieldNameDisplay%>");
	                      }
	                     
					//
			      //XSSOK
	                      vfieldNameDisplay[0].value ="<%=strContextObjectName%>" ;
			      //XSSOK
	                      vfieldNameActual[0].value ="<%=strObjectId%>" ;
                          getTopWindow().closeWindow();   
	                  
	                    </script>
	               <%
	              }
	              // if the chooser is in the Form
	              else if (strSearchMode.equals("PersonChooser"))
	              {
	                  String fieldNameActual = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
	                  String fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameDisplay"));

	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ;

	                  DomainObject objContext = new DomainObject(strObjectId);
	                  String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);

					%>
	                  <script language="javascript" type="text/javaScript">
			      //XSSOK
			      		var vfieldNameActual = null;
			      		var vfieldNameDisplay = null;
			      		if(!(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)){
			      			vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=fieldNameActual%>");
			      			vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=fieldNameDisplay%>");
			      		}
			      		else{
	                      vfieldNameActual = getTopWindow().document.getElementsByName("<%=fieldNameActual%>");
			      //XSSOK
	                      vfieldNameDisplay = getTopWindow().document.getElementsByName("<%=fieldNameDisplay%>");
						}
			      //XSSOK
	                      vfieldNameDisplay[0].value ="<%=strContextObjectName%>" ;
			      //XSSOK
	                      vfieldNameActual[0].value ="<%=strContextObjectName%>" ;
                          getTopWindow().closeWindow();

	                    </script>
					<%
					}else if (strSearchMode.equals("ECOChooser"))
					{
						//Added for BOM Filtering 
					    String fieldNameActual = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
		                String fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameDisplay"));
		                StringBuffer actualValue = new StringBuffer();
		                StringBuffer displayValue = new StringBuffer();
		                for(int i=0;i<strContextObjectId.length;i++){
		                    StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] , "|");
		                    String strObjectId = strTokenizer.nextToken() ;		                    
			                DomainObject objContext = new DomainObject(strObjectId);
			                String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
			                actualValue.append(strObjectId);
			                displayValue.append(strContextObjectName);
							if(i!=strContextObjectId.length-1){
							    actualValue.append(",");
							    displayValue.append(",");
		                    }		                    
		                }		                
		                %>
		                <script language="javascript" type="text/javaScript">
		                
		                //Added for clearing Context Change while submitting ECO for filtering Start
		                
                        var vPUEUEBOMContextChangeFilter_actual = null;
		                if(!(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)){
		                	vPUEUEBOMContextChangeFilter_actual = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter_actualValue");
		                	if (vPUEUEBOMContextChangeFilter_actual && (vPUEUEBOMContextChangeFilter_actual.value!=null || vPUEUEBOMContextChangeFilter_actual.value!="")) {
								
								var vPUEUEBOMContextChangeFilter_Display = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter");
								
								var vPUEUEBOMContextChangeFilter_OID=getTopWindow().getWindowOpener().getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter_OID");

	                        	vPUEUEBOMContextChangeFilter_Display.value = "";
	                        	
	                        	vPUEUEBOMContextChangeFilter_actual.value = "";
	                        	
	                        	vPUEUEBOMContextChangeFilter_OID.value = "";
	                        }
		                	 var vfieldNameActual = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=fieldNameActual%>");
							 var vfieldNameDisplay = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("<%=fieldNameDisplay%>");
		                }
		                else{
		                	vPUEUEBOMContextChangeFilter_actual = getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter_actualValue");
								if (vPUEUEBOMContextChangeFilter_actual && (vPUEUEBOMContextChangeFilter_actual.value!=null || vPUEUEBOMContextChangeFilter_actual.value!="")) {
								
								var vPUEUEBOMContextChangeFilter_Display = getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter");
								
								var vPUEUEBOMContextChangeFilter_OID=getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter_OID");

	                        	vPUEUEBOMContextChangeFilter_Display.value = "";
	                        	
	                        	vPUEUEBOMContextChangeFilter_actual.value = "";
	                        	
	                        	vPUEUEBOMContextChangeFilter_OID.value = "";
	                        }
							var vfieldNameActual = getTopWindow().document.getElementById("<%=fieldNameActual%>");
							 var vfieldNameDisplay = getTopWindow().document.getElementById("<%=fieldNameDisplay%>");
		                }
                        	
							//                       		
						
						//Added for clearing Context Change while submitting ECO for filtering End
						
		                
				//XSSOK
		               

				//XSSOK
                       

			//XSSOK
                        vfieldNameDisplay.value ="<%=displayValue%>" ;
			//XSSOK
                        vfieldNameActual.value ="<%=actualValue%>" ;
                        /*Also set Actual value*/
			//XSSOK
						<%-- getTopWindow().opener.clearValues("<%=fieldNameDisplay%>"); --%>
                        
						getTopWindow().closeWindow();
                        </script>
                    <%
					}
					else if (strSearchMode.equals("PCFilter"))
					{
						//Added for BOM Filtering 
					    String fieldNameActual = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
		                String fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "hiddenNameField"));
		                StringBuffer actualValue = new StringBuffer();
		                StringBuffer displayValue = new StringBuffer();
		                for(int i=0;i<strContextObjectId.length;i++){
		                    StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] , "|");
		                    String strObjectId = strTokenizer.nextToken() ;		                    
			                DomainObject objContext = new DomainObject(strObjectId);
			                String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
			                actualValue.append(strObjectId);
			                displayValue.append(strContextObjectName);
							if(i!=strContextObjectId.length-1){
							    actualValue.append(",");
							    displayValue.append(",");
		                    }		                    
		                }		                
		                %>
		                <script language="javascript" type="text/javaScript">						
		                
				//XSSOK
		                var vfieldNameActual = null;
			      		var vfieldNameDisplay = null;
			      		if(!(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN)){
			      			vfieldNameActual = getTopWindow().getWindowOpener().document.getElementById("<%=fieldNameActual%>");
			      			vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementById("<%=fieldNameDisplay%>");
			      		}
			      		else{
	                      vfieldNameActual = getTopWindow().document.getElementById("<%=fieldNameActual%>");
			      //XSSOK
	                      vfieldNameDisplay = getTopWindow().document.getElementById("<%=fieldNameDisplay%>");
						}
                        vfieldNameDisplay.value ="<%=displayValue%>" ;
			//XSSOK
                        vfieldNameActual.value ="<%=actualValue%>" ;
                        /*Also set Actual value*/
			                       
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
	            
		        Object objToConnectObject = "";
		        String strToConnectObject = "";
				strRelName = PropertyUtil.getSchemaProperty(context,strRelName);
		        String strFromSide = emxGetParameter(request, "from");
		        boolean From = true;
		        if (strFromSide.equals("false")){
		        	//XSSOK
		            From = false;    
		        }		        
		            
			        for(int i=0;i<strContextObjectId.length;i++){
						StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");

						//Extracting the Object Id from the String.
						for(int j=0;j<strTokenizer.countTokens();j++){
				             objToConnectObject = strTokenizer.nextElement();
				             strToConnectObject = objToConnectObject.toString();
				             break;
				         }	
						//Code for connecting the objects 
						DomainRelationship.connect(context,strObjId,strRelName,strToConnectObject,From);	
			        }
					%>
					<script language="javascript" type="text/javaScript">
					window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
					window.getTopWindow().closeWindow();
					</script>   
		        
		<%			
		} 
     	
     	if ( "ConfigurationContext".equals(strMode) ) {
     		CFFUtil.addConfigurationContext( context, strObjId, BOMMgtUtil.getListFromSelectedTableRowIds(strContextObjectId, 1) );
%>
			<script language="javascript" type="text/javaScript">
				getTopWindow().closeWindow();
			</script>
<%
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


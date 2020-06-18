<%--
  FOEffectivitySearchUtil.jsp
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

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import ="java.util.Enumeration" %>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
  try
  {
     String strTypeAhead = emxGetParameter(request,"typeAhead");
     String strTableRowId = null;
 	 StringTokenizer strTokenizer = null;
 	 String strObjectId = null;
 	 DomainObject objContext = null;
     Map mapSelectedObject = null;
     String strObjName = null;
     String strObjRev = null;
     String strMilestoneDisplayName = null;
     StringBuffer appendValueName = new StringBuffer();
     StringBuffer appendValueID = new StringBuffer();
     String contextInfo = null;
     String[] contextInfoSplit = null;
     String contextName = null;
     String contextPhyId = null;
     String msPhyId = null;
     
     StringList selectables = new StringList();
     selectables.add(DomainConstants.SELECT_NAME);
	 selectables.add(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
     selectables.add(DomainConstants.SELECT_REVISION);
     
     //get the selected Objects from the Full Search Results page
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
     
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
       try{
                 String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                 String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                 StringList selectedContext = new StringList();
                 String effType = emxGetParameter(request, "effType");
                 boolean isContextSelected = false;
                 
                 for(int z=0; z< strContextObjectId.length; z++ ){
                	 strTableRowId = strContextObjectId[z];
                	 strTokenizer = new StringTokenizer(strTableRowId , "|");
                	 strObjectId = strTokenizer.nextToken(); 
                	 objContext = new DomainObject(strObjectId);
                	 
                	 mapSelectedObject = objContext.getInfo(context, selectables);
                	 
                	 strObjName = (String)mapSelectedObject.get(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
                	 if(strObjName==null || strObjName.trim().length()==0){
                		 strObjName = (String)mapSelectedObject.get(DomainConstants.SELECT_NAME);
                	 }
                     strObjRev = (String)mapSelectedObject.get(DomainConstants.SELECT_REVISION);
                     
                     if(effType != null && effType.equals("MilestoneEffectivity")){
                    	 strMilestoneDisplayName = strObjName;
                    	 
                    	 contextInfo = LogicalFeature.getMilestoneContext(context, strObjectId);
                         contextInfoSplit = contextInfo.split("\\|");	 
                         
                         if(contextInfoSplit.length == 4){
                        	 contextName = contextInfoSplit[0];
                        	 contextPhyId = contextInfoSplit[1];
                        	 msPhyId = contextInfoSplit[2];
                        	 if(selectedContext.contains(contextPhyId)){
                        		 isContextSelected = true;
                        	 }
                        	 
                        	 selectedContext.add(contextPhyId);                        	                         	 
                         }
                    	 
                    	 if(z > 0){
                        	 appendValueName.append(" <br /> ");                        	 
                        	 appendValueName.append(contextName);
                        	 appendValueName.append("{");
                        	 appendValueName.append(strMilestoneDisplayName);
                        	 appendValueName.append("}");
                        	 appendValueID.append(",");
                        	 appendValueID.append(contextPhyId+"|"+msPhyId);
                         }
                         else{
                        	 appendValueName.append(contextName);
                        	 appendValueName.append("{");
                        	 appendValueName.append(strMilestoneDisplayName);
                        	 appendValueID.append(contextPhyId+"|"+msPhyId);
                        	 appendValueName.append("}");
                         }         
                     }
                     else{
                    	 strMilestoneDisplayName = strObjName+" "+strObjRev;
                    	 
                       	 appendValueName.append(strMilestoneDisplayName);
                       	 appendValueID.append(strObjectId);                       	                      
                     }
                     if(isContextSelected){
                      String oneMilestone = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Message.Alert.SelectOneMilestone",context.getSession().getLanguage());
                      throw new FrameworkException(oneMilestone);
                     }
                 }
                 %>
                 <script language="javascript" type="text/javaScript">
                 	var vfieldNameActual ="";
                 	var vfieldNameDisplay ="";
                 	var vTypeAhead= "<%=XSSUtil.encodeForJavaScript(context,strTypeAhead)%>";
					//XSSOK
                    if(<%=isContextSelected%>){
                    	//alert("<emxUtil:i18n localize="i18nId">emxConfiguration.Message.Alert.SelectOneMilestone</emxUtil:i18n>");
                    }
                    else{
                    	if(vTypeAhead!=null && vTypeAhead=="true"){	
    				  		vfieldNameActual = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
    	              		vfieldNameDisplay = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");  						  				      
    			  		}
    			  		else{
    			  			vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
    			  			vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
    			  		}
                 
    			  		if(vfieldNameDisplay[0].value.length == 0){
    				  		vfieldNameDisplay[0].value = "<%=XSSUtil.encodeForJavaScript(context,appendValueName.toString())%>" ;
                         	vfieldNameActual[0].value = "<%=XSSUtil.encodeForJavaScript(context,appendValueID.toString())%>" ;
    			  		}
    			  		//refactor below code; take it in for loop to test if Option already selected
                  		else if(vfieldNameDisplay[0].value.indexOf("<%=XSSUtil.encodeForJavaScript(context,strMilestoneDisplayName)%>") == -1){
                   	  		vfieldNameDisplay[0].value = "<%=XSSUtil.encodeForJavaScript(context,appendValueName.toString())%>" ;
                         	vfieldNameActual[0].value = "<%=XSSUtil.encodeForJavaScript(context,appendValueID.toString())%>" ;
                     	}
                     	else{
                     		alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FOAlreadySelected</emxUtil:i18n>");
                     	}  
                    }                    
			  		                  
                 </script>
<%                   
              if ((strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")) && !isContextSelected){
%>
                 <script language="javascript" type="text/javaScript">  
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
  }
  catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

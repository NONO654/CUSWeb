<%--
  ConfigurationFeatureRemoveProcess.jsp
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
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>


<%@page import="com.matrixone.apps.domain.DomainObject"%><script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
boolean bIsError = false;
String action = "";
String msg = "";

  try
  {	  
	  String strLanguage = context.getSession().getLanguage();     
	  String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureRemoveOptionNotAllowed", strLanguage);
	  
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  String strParentId = emxGetParameter(request, "parentOID");
               
	  String strParentType = new DomainObject(strParentId).getType(context);
	  
	  boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strParentId);
	        
      if(arrTableRowIds!=null && arrTableRowIds[0].endsWith("|0")){
	     %>
	        <script language="javascript" type="text/javaScript">
	              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
	        </script>
	     <%
      } 
      else if(bInvalidState == true){
              %>
              <script language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
              </script>
             <%
      }else{
    	   boolean unsavedData= false;
    	   for(int i=0;i<arrTableRowIds.length;i++) {
    		   StringList emxTableRowIds = FrameworkUtil.split(arrTableRowIds[i], "|");
    		   if(emxTableRowIds.size()==3 && !((String)emxTableRowIds.get(1)).isEmpty()){
    			   unsavedData=true;
    			   break;
    			   }
    	   }
    	   if(unsavedData == true){
    		        %>
    	            <script language="javascript" type="text/javaScript">
    	  	            alert("<emxUtil:i18n localize='i18nId'>emxFeature.Alert.UnsavedMarkUp</emxUtil:i18n>");
    	  	        </script>
    	            <%
    	   }else{ 
    	  if(strParentType.equals(ConfigurationConstants.TYPE_MODEL)){
              StringList strObjectIdList = new StringList();
              String strObjectID = "";
              StringTokenizer strTokenizer = null;
              
              for(int i=0;i<arrTableRowIds.length;i++)
              {
                  if(arrTableRowIds[i].indexOf("|") > 0){
                        strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");  
                        strTokenizer.nextToken();
                        strObjectID = strTokenizer.nextToken() ;                            
                        strObjectIdList.add(strObjectID);
                    }
                    else{
                        strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                        strObjectID = strTokenizer.nextToken() ;
                        strObjectIdList.add(strObjectID);                           
                    }
              }
              
              Model confModel = new Model(strParentId);
              confModel.removeCandidateManufacturingFeatures(context, strObjectIdList);
              
              %>
              <SCRIPT language="javascript" type="text/javaScript">              
                   parent.location.href = parent.location.href;                  
              </script>
              <%
          }
          else{
            %>
            <script language="javascript" type="text/javaScript">            
                parent.editableTable.cut();
            </script>
            <% 
          }
      }
      }
      
  
  }catch(Exception e)
     {
    	    bIsError=true;
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

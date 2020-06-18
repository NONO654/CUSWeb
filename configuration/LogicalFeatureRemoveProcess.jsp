
<%--
  LogicalFeatureRemoveProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.*"%>
<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.StringTokenizer"%>

    <script language="Javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
    <script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
    <script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
StringList strObjectIdList = new StringList();
StringList strParentIdList = new StringList();
  try
  {	  
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  String strParentId = emxGetParameter(request, "parentOID");      
      String strParentType = new DomainObject(strParentId).getType(context);
      //String isModel = emxGetParameter(request,"isModel");
               
      if(arrTableRowIds[0].endsWith("|0")){
     %>
        <script language="javascript" type="text/javaScript">
              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");      
        </script>
     <%
      }
      else{
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
      
      StringTokenizer strTokenizer = null;
      
      for(int i=0;i<arrTableRowIds.length;i++)
      {
          if(arrTableRowIds[i].indexOf("|") > 0){
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
              strTokenizer.nextToken();
              strObjectIdList.add(strTokenizer.nextToken());
              strParentIdList.add(strTokenizer.nextToken());
            }
            else{
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                 strObjectIdList.add(strTokenizer.nextToken());     
                 strParentIdList.add(strTokenizer.nextToken());                           
            }
      }
      boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strParentIdList);
      if(bInvalidState)
      {
          %>
          <script language="javascript" type="text/javaScript">
                alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.LogicalFeatureReleased</emxUtil:i18n>");  
          </script>
       <%
      } 
      else if(mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_MODEL)){              
          
          Model confModel = new Model(strParentId);
          confModel.removeCandidateLogicalFeatures(context, strObjectIdList);
          
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
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

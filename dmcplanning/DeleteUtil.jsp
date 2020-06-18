
<%--
  DeleteUtil.jsp

  Utilities that are needed to Delete Model from Master compostion tab in model

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature" %>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<form name="formName" method="post">
<%
  String strMode = emxGetParameter(request,"mode");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String strObjId = emxGetParameter(request, "objectId");
  String action = "";
  String msg = "";
  String strContext = emxGetParameter(request,"context");
  String strErrorMsg = "";
  String strLanguage = context.getSession().getLanguage();
  boolean bIsError = false;

  try
  {
	 if(strMode.equalsIgnoreCase("Delete"))
	 {
		 // To Do
	     if (strContext.equalsIgnoreCase("ModelTemplate")){
	    	 String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	    	 StringList slList = FrameworkUtil.split(arrTableRowIds[0], "|");
	    	 String levelId = ((String)slList.get(slList.size()-1)).trim();
	    	 StringList levelSplit = FrameworkUtil.split(levelId, ",");
	    	 
	         if(levelSplit.size()==2)
	         {
	             String strObjIds[] = new String[arrTableRowIds.length];;
	             DomainObject domMF;
	             StringList strMasterFeatureIDs = new StringList();
	             StringList strModelIDs = new StringList();
	             String strRelID="";
	             String strMasterFeatureId="";
	             String strFeatureManagemendMode= "";
	             String strType = "";
	             
		         for(int i=0;i<arrTableRowIds.length;i++)
		         {
		                StringTokenizer strTokenizer = new StringTokenizer(arrTableRowIds[i] ,"|");
		                strRelID=strTokenizer.nextToken(); //Realationship ID
		                strMasterFeatureId=strTokenizer.nextToken(); //Selected Managed Revision ID
		                DomainObject domSelectedObject = new DomainObject(strMasterFeatureId);
		                //if(domSelectedObject.getInfo(context,DomainObject.SELECT_TYPE).equals(ManufacturingPlanConstants.TYPE_MODEL)){
		                if(mxType.isOfParentType(context, domSelectedObject.getInfo(context,DomainObject.SELECT_TYPE),ManufacturingPlanConstants.TYPE_MODEL)){
		                	strModelIDs.add(strMasterFeatureId);     	
		                }else{
		                	strMasterFeatureIDs.add(strMasterFeatureId);
		                }
		                
		         }
		         boolean bDeleted = true;
		         boolean bReturnVal = true;
		         try{
			         // call the method to delete the Model
			         if(strModelIDs.size()>0){
			        	 String arrObjectIds[] = new String [strModelIDs.size()];
			        	 for(int i=0;strModelIDs.size()>i;i++){
			        		 arrObjectIds[i]=(String)strModelIDs.get(i);
			        	 }
	                     com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
	                     com.matrixone.apps.productline.Model modelBean = (com.matrixone.apps.productline.Model)DomainObject.newInstance(context,ManufacturingPlanConstants.TYPE_MODEL,"ProductLine");
	                     // Calling the delete method of the Model bean
				         bReturnVal= modelBean.delete(context,arrObjectIds,strObjId);
			         }
		        	 // call the method to delete the Master Features
			         bDeleted = MasterFeature.deleteMasterFeature(context,strMasterFeatureIDs);
		         }catch(Exception e){
                     throw e;
		         }
		         
	        %>
	        <script language="javascript" type="text/javaScript">
	         parent.location.href = parent.location.href;
	        </script>
	        <%}
	         else{
	             %>
	            <script language="javascript" type="text/javaScript">
	                alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Error.RevisionNode</emxUtil:i18n>");
	            </script>
	           <%
	         }
	         
	         
	     }  
	 }
    } catch(Exception e)
    {
    	//TODO-- ?
        session.putValue("error.message", e.getMessage());
    }// End of main Try-catck block
%>
  </form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>  
</html>


<%--
   ToggleUtil.jsp
	  Utilities that are required for doing Toggle Functionality.

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
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature" %>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<form name="formName" method="post">
<%
  String strMode = emxGetParameter(request,"mode");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String strObjId = emxGetParameter(request, "objectId");
  String uiType = emxGetParameter(request,"uiType");
  String action = "";
  String strErrorMsg = "";
  
  String strLanguage = context.getSession().getLanguage();
  
  String strContext = emxGetParameter(request,"context");

  boolean bIsError = false;
  boolean featureDeleted = true;

  try
  {
	 if(strMode.equalsIgnoreCase("Toggle"))
	 {
		 // Following block is used to get the selected Obkect from the master Feature category ofthe Model and Toggle the Feature Allocation Type
		 // of the Managed Revision of the Master Feature.
	     if (strContext.equalsIgnoreCase("ManagedRevision")){
	         String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	         // check if the selected row is root node, if yes then throw exception that 
	         // Toggle cannot be done on Root Node.
	         if(!arrTableRowIds[0].endsWith("|0"))
	         {
	             StringTokenizer st = new StringTokenizer(arrTableRowIds[0], "|");
	             String strRelID=st.nextToken(); //Realationship ID
	             String strManagedRevisionId=st.nextToken(); //Selected Managed Revision ID
	             String strMasterFeatureId=st.nextToken(); //Selected Associated Master Feature ID
	
	             DomainObject domSelectedObj = new DomainObject(strManagedRevisionId);
	             String strObjType = domSelectedObj.getInfo(context,DomainObject.SELECT_TYPE);
	        	 
	             DomainObject domTemp = new DomainObject(strRelID);
	             // check if the selected row is Master Feature, if yes then throw exception that 
	             // Toggle cannot be done on Master Feature.
	             if(!strObjType.equalsIgnoreCase(ManufacturingPlanConstants.TYPE_MASTER_FEATURE))
	             {
		             try{
		            	 // get the Feature Allocation Type attribute Value of the Managed Revision
		            	 DomainRelationship domRel = new DomainRelationship(strRelID);
		                 String strManagementMode =(String)domRel.getAttributeValue(context,ManufacturingPlanConstants.ATTRIBUTE_FEATURE_ALLOCATION_TYPE);
		                 		                 
		                 if(strMasterFeatureId!=null && !strMasterFeatureId.equalsIgnoreCase("")){
		                	 // Get All the Managed Revisions of the Master Features
		                	 // If any of the Managed Revision is Already Mandatory Feature Allocation Type then do not allow the Toggle 
		                	 // From Standard or Optional to Mandatory
		                     DomainObject domMF = new DomainObject(strMasterFeatureId);
		                     StringList strManagedRevisionFAT = (StringList)domMF.getInfoList(context,
		                              "from["+ManufacturingPlanConstants.RELATIONSHIP_MANAGED_REVISION+"].attribute["+ManufacturingPlanConstants.ATTRIBUTE_FEATURE_ALLOCATION_TYPE+"]");
		                     if((strManagementMode.equalsIgnoreCase("Optional")||strManagementMode.equalsIgnoreCase("Standard"))  
	                                 && strManagedRevisionFAT.contains("Mandatory")){
		                    	 strErrorMsg = (EnoviaResourceBundle.getProperty(context,"DMCPlanning",
		                                 "DMCPlanning.Error.Toggle.MultipleMandatory",strLanguage))
		                                 .trim();            
		                    	 throw new FrameworkException(strErrorMsg);
		                     }// Allow Toggle from Mandatory, hence when Toggle from Mandatory then it will always be Optional
		                     else if(strManagementMode.equalsIgnoreCase("Mandatory")){ 
		                    	 MasterFeature.setAllocationType(context,strRelID,"Optional");
	                         }// If toggle from Optional/Standard then set the value to Mandatory if the condition satisfy.
	                         else{  
	                        	 MasterFeature.setAllocationType(context,strRelID,"Mandatory");
	                         }
		                 }
		                    %>
		                     <script language="javascript" type="text/javaScript">
		                          alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Alert.Toggle.Successful</emxUtil:i18n>");
		                          parent.location.href = parent.location.href;
		                     </script>
		                    <%
		             } catch(Exception e){
	                     session.putValue("error.message", e.toString());
	                     throw e;
	            	 }
	             }
	             else{
	                 %>
	                 <script language="javascript" type="text/javaScript">
	                     alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Alert.CannotToggleMasterFeature</emxUtil:i18n>");
	                 </script>
	                <%
	             }
	         }
	         else{
	             %>
	            <script language="javascript" type="text/javaScript">
	                alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Error.RootNode</emxUtil:i18n>");
	            </script>
	           <%
	         }
	     }  
	 }
	}catch(Exception e)
    {
	   String strErrorMessage = e.getMessage();	  
      %>
      <script language="javascript" type="text/javaScript">
      //XSSOK
      var error = "<%=strErrorMessage%>";
      alert(error);
      </script>
     <%
	}// End of main Try-catck block
%>
</form>
</html>

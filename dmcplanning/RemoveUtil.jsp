
<%--
  RemoveUtil.jsp
  Utilities that are needed to Remove Model from Master compostion tab in model

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
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature" %>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
  String strMode = emxGetParameter(request,"mode");
  String strObjId = emxGetParameter(request, "objectId");
  String strContext = emxGetParameter(request,"context");
 
  try
  {
	 if(strMode.equalsIgnoreCase("Remove"))
	 {
	     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
         StringList slList = FrameworkUtil.split(arrTableRowIds[0], "|");
         String levelId = ((String)slList.get(slList.size()-1)).trim();
         StringList levelSplit = FrameworkUtil.split(levelId, ",");
         
         if(levelSplit.size()==2)
         {   String strRelID="";
	         String strManagedRevisionId="";
	         String strMasterFeatureId= "";
	         String strlevelId = "";
	         
	         StringList sListObjectToRemove = new StringList(arrTableRowIds.length);
		     if (strContext.equalsIgnoreCase("ModelTemplate")){
		    	 
		    	 com.matrixone.apps.dmcplanning.Model model = new com.matrixone.apps.dmcplanning.Model(strObjId);
		         for(int i=0;i<arrTableRowIds.length;i++)
		         {
		                StringTokenizer strTokenizer = new StringTokenizer(arrTableRowIds[i] ,"|");
		                strRelID=strTokenizer.nextToken(); //Realationship ID
		                strManagedRevisionId=strTokenizer.nextToken(); //Selected Managed Revision ID
		                strMasterFeatureId= strTokenizer.nextToken(); //parent ID - Master Feature
		                strlevelId = strTokenizer.nextToken(); // level ID
		                sListObjectToRemove.add(strManagedRevisionId);
 		         }
		         model.disconnectModelTemplate(context,sListObjectToRemove);
	             %>
	             <script language="javascript" type="text/javaScript">
	             parent.location.href = parent.location.href;
	             </script>
	            <%
		        }
	     }
		 else{
		     %>
		    <script language="javascript" type="text/javaScript">
		        alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Error.RevisionNode</emxUtil:i18n>");
		    </script>
		   <%
		 }
	  }
    }catch(Exception e)
    {
    	//Modified for IR-043763V6R2011
      //throw new FrameworkException(e.getMessage());
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

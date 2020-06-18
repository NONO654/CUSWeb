<%-- emxComponentsDeletePlant.jsp -- This page deletes Plant from database.

  Copyright (c) 1992-2018 Enovia Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsDeletePlant.jsp.rca 1.2.3.2 Wed Oct 22 16:17:53 2008 przemek Experimental przemek $";
--%>


<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="plant" scope="page" class="com.matrixone.apps.common.Plant"/>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

 String[] tableRowIds			= request.getParameterValues("emxTableRowId");
 if(UINavigatorUtil.isMobile(context)){
	 tableRowIds = FrameworkUtil.getSplitTableRowIds(tableRowIds);
 }
 String selectedIds			= "";

    for(int i = 0; i < tableRowIds.length; i++){
        if(i==0) {
            selectedIds = tableRowIds[i];
        } else {
            selectedIds += "," + tableRowIds[i];
        }
    }
    
 plant.deletePlants(context, "emxPlant","deletePlants",selectedIds);

%>

 <script language="Javascript">
 
 try
{
	var structTree = getTopWindow().objStructureTree;
	if(structTree != null) {
<%
		int count = tableRowIds.length;
		for (int i = 0; i < count; i++ ){
%>      
			structTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, tableRowIds[i])%>", false);
	       	    	   		        
<%		}
%>		
  			structTree.refresh();
  	}
}catch(e){}
     	window.parent.location.href=window.parent.location.href;
     	
//     getTopWindow().refreshTablePage();
 </script>

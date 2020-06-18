<%--  emxComponentsConfigurableTablePeopleDisconnectProcess.jsp   -  This page disconnects the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsConfigurableTablePeopleDisconnectProcess.jsp.rca 1.8 Wed Oct 22 16:18:25 2008 przemek Experimental przemek $
--%>


<%@page import="com.matrixone.apps.common.Plant"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	String accessUsers 		= "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
	if( !PersonUtil.hasAnyAssignment(context, accessUsers)) {
		return;
	}
  	String userID         	= emxGetParameter(request,"rowIds");
  	String selectedPeople[] = userID.split(",");  
  	String moveOption 		= emxGetParameter(request,"PersonMoveOption");
  	String currentOrgId   	= emxGetParameter(request,"parentOID");
  	String newOrgOID		= emxGetParameter(request,"CompanyNameOID");  
  	final String KEEP_CREDENTIALS = "KEEP_CREDENTIALS"; 
  	String keepCredential 	= "";
  	if(selectedPeople.length > 0)
  	{
    	try{
			//if moveoption is keep then set the KEEP_CREDENTIALS value as true if reset then false
    		if("keep".equals(moveOption)){
    			keepCredential = "true";
    		}else{
    			keepCredential = "false";
    		}
    		PropertyUtil.setRPEValue(context, KEEP_CREDENTIALS, keepCredential, true);
		  	
			//Changing the curent org od employee to new org.
			com.matrixone.apps.common.Organization orgObj = new com.matrixone.apps.common.Organization(currentOrgId);
        	orgObj.changePersonsOrg(context, selectedPeople, currentOrgId, newOrgOID);

		  	session.setAttribute("company.hashtable", new Hashtable());
      	}catch(Exception Ex){
          	session.putValue("error.message", Ex.toString());
		}finally{
			PropertyUtil.unsetRPEValue(context, KEEP_CREDENTIALS, true);
		}
  	}

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript"> 
      getTopWindow().refreshTablePage();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


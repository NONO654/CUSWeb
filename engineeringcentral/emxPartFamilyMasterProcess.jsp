<%--  emxPartFamilyMasterProcess.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file ="emxEngrFramesetUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.engineering.PartFamily"%>

<%
                  String[] tableRowId = (String[])session.getAttribute("tableRowIds");
                  String objectId = (String)emxGetParameter(request,"objectId");
                  String actionType = (String)emxGetParameter(request, "actionType");
                  String key = (String)emxGetParameter(request, "key");
			            session.removeAttribute("tableRowIds");
			            session.removeAttribute("emxTableRowId");
	 								    if ((actionType.equals("unassignedMaster")) || (actionType.equals("assignedMaster")))  {
	
	 										String[] methodArgs = new String[1];
	 										String strPartId= "";
	 																	
	 										PartFamily partlist = new PartFamily();
	 										partlist.setReferenceType(context,tableRowId,"emxPartFamily","setReferenceType",key);
	 								}	
	 							      else if(actionType.equals("unassignedReference")) {
											String[] methodArgs = new String[1];
											String strPartId= "";
											PartFamily partlist = new PartFamily();
	 										partlist.removeReferenceFromMaster(context,tableRowId,objectId,"emxPartFamily","removeReferenceFromMaster");
	
	 							}
	 							//write script to refresh below page
	%> 				
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	 						<script>
									//getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
									var frameRefresh = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
									frameRefresh.getTopWindow().refreshTablePage();	
									parent.closeWindow();
		          </script>
	 									

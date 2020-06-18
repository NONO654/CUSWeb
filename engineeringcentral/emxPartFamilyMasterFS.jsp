<%--  emxPartFamilyMasterFS.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
		 
		 <%@include file="../emxUIFramesetUtil.inc"%>
		 <%@include file="emxEngrFramesetUtil.inc"%>
		 
		 <%
		     String objectId = (String)emxGetParameter(request, "objectId");
		     String pageHeading = emxGetParameter(request,"pageHeading");
		     String actionType = (String)emxGetParameter(request, "actionType");
		     
		     if(pageHeading == null) {
		       pageHeading = "emxEngineeringCentral.Common.InProcess";
		     }
		 
		     String[] tableRowId = emxGetParameterValues(request, "emxTableRowId");
		     		     
		     session.setAttribute("emxTableRowId",tableRowId);
		     
		     String ContentURL = "emxPartFamilyMasterDialog.jsp?objectId="+objectId+"&actionType="+actionType;
		     framesetObject fs = new framesetObject();
		    
		     //---Setting the app Directory
		     fs.setDirectory(appDirectory);
		     
		        
		     //---Setting String resourse Property File
		     fs.setStringResourceFile("emxEngineeringCentralStringResource");
		     
		     //---Setting Help Marker
		     String helpMarker = "";
		     
		     fs.initFrameset(pageHeading,helpMarker,ContentURL,true,true,false,false);
		     
		     
		 			fs.createCommonLink("emxEngineeringCentral.Common.Done",
		 														"doDone()",
		 														"role_GlobalUser",
		 														false,
		 														true,
		 														"common/images/buttonDialogDone.gif",
		 														false,
		 													5);
		     
		     fs.createCommonLink("emxEngineeringCentral.Button.Cancel",
		 		                      "getTopWindow().closeWindow()",
		 		                      "role_GlobalUser",
		 		                      false,
		 		                      true,
		 		                      "common/images/buttonDialogCancel.gif",
		 		                      false,
		                         5);
		     
		     fs.writePage(out);
 %>
		 
		 
		 

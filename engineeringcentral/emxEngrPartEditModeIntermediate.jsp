<%--emxEngrPartEditModeIntermediate.jsp --
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%--
 * @quickreview 
  * 
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.constants.*"%>

<%

	try {
		
		String redirectedURL=null;
		String objectId =emxGetParameter(request, "objectId");	
		//get change controlled value assigned to the part
		Map programMap = new HashMap();
		programMap.put("objectId",objectId);
		String changeControlledValue = JPO.invoke(context, "enoPartManagement", null, "getReviseChangeControlled", JPO.packArgs(programMap), String.class);
		
		String selectedWorkUnderOID="";
		String strChangePhyId="";
		DomainObject domNewObj = DomainObject.newInstance(context, objectId);
		String strPolicy = (domNewObj.getPolicy(context)).toString();
		String changeid= domNewObj.getAttributeValue(context, PartMgtConstants.ChangeId);
		 if(PartMgtConstants.POLICY_EC_PART.equalsIgnoreCase(strPolicy) ||PartMgtConstants.POLICY_CONFIGURED_PART.equalsIgnoreCase(strPolicy)){
		 if(UIUtil.isNotNullAndNotEmpty(changeid)){
			 strChangePhyId =domNewObj.getAttributeValue(context,PartMgtConstants.ChangeId);
		 }
		}
		String parentObjectId=emxGetParameter(request, "parentOID");
		boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
		String csrfTokenName = "";
		String csrfTokenValue = "";
		if(csrfEnabled)
		{
		  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
		  csrfTokenName = (String)csrfTokenMap.get(ENOCsrfGuard.CSRF_TOKEN_NAME);
		  csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
		}
		StringBuilder strURL = new StringBuilder(200);
		
		DomainObject  partObject = DomainObject.newInstance(context,objectId);	
		String relationshipName=PropertyUtil.getSchemaProperty(context,"relationship_Template");
		String objectSelectable = EngineeringConstants.SELECT_FROM_LEFTBRACE.concat(relationshipName).concat(EngineeringConstants.SELECT_RIGHTBRACE);
		 //Checking whether the Template is applied to the Part object
         String isTemplateApplied = partObject.getInfo(context,objectSelectable);
		 		
		 strURL.append("../common/emxForm.jsp?formHeader=emxEngineeringCentral.Part.EditPart&mode=edit&HelpMarker=emxhelpparteditdetails&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&objectId=")
		.append(objectId).append("&parentOID=")
		.append(parentObjectId).append("&csrfTokenName=").append(csrfTokenName).append("&")
		.append(csrfTokenName).append("=").append(csrfTokenValue);
		 //when the part object is connected to Template, call the GLS edit form
		 if(EngineeringConstants.TRUE.equalsIgnoreCase(isTemplateApplied))
	     {
			  try{
			 
	              FrameworkLicenseUtil.checkLicenseReserved( context,EngineeringConstants.PRODUCT_LICENSE_CPN, DomainConstants.EMPTY_STRING);
			   }catch(MatrixException ex){
				   emxNavErrorObject.addMessage(ex.toString().trim());  
			   }
			  strURL.append("&form=TemplatePreviewForm&SuiteDirectory=cpn&postProcessJPO=enoPartSpecs:partEditPostProcess&formFieldsOnly=true");	
	     }else{
			/* When the part object is not connected to Template, call the ENG edit form with be below license checks
			*/
	
			strURL.append("&form=type_Part&preProcessJavaScript=preProcessInEditPart&postProcessJPO=emxPart:partEditPostProcess&SuiteDirectory=engineeringcentral&selectedWorkUnder="+strChangePhyId+"&changeControlled="+changeControlledValue);

	     }
			
		 if (partObject.isKindOf(context, EngineeringConstants.TYPE_MANUFACTURING_PART))
		 {
			  strURL = new  StringBuilder(200);
			  strURL.append("../common/emxForm.jsp?form=type_Part&formHeader=emxEngineeringCentral.Part.EditPart&mode=edit&HelpMarker=emxmfgparteditdetails&submitAction=refreshCaller&EditMode=MFG&preProcessJavaScript=preProcessInEditMFGPart&suiteKey=EngineeringCentral&postProcessJPO=emxMBOMUIUtil:editMFGPostProcess")
			 .append("&StringResourceFileId=emxEngineeringCentralStringResource")
			 .append("&objectId=").append(objectId).append("&parentOID=")
			 .append(parentObjectId).append("&csrfTokenName=").append(csrfTokenName).append("&")
			 .append(csrfTokenName).append("=").append(csrfTokenValue);
	     }
			 

		/*Postprocess URL is called to refresh the page to view form on clicking "Done" button in edit form*/
		strURL.append("&fromEditPartPage=true&postProcessURL=../engineeringcentral/emxEngrPartPortalRefresh.jsp&cancelProcessURL=../engineeringcentral/emxEngrPartPortalRefresh.jsp");
			
		 
		 strURL.append("&submitAction=refreshCaller&portalMode=true&isSelfTargeted=true");
		 redirectedURL=strURL.toString();
	%>	

	  <script>
	   
		
		var encodedURL = "<%=XSSUtil.encodeForJavaScript(context,redirectedURL)%>";	
		var frame = window.frameElement;  // Get the <iframe> element of the window
      
		if (frame) {   // If the window is in an <iframe>, change its source
		    frame.src = encodedURL;
		}
	 </script>
	 
	<%	 
	
	}catch(Exception e){
	  	   emxNavErrorObject.addMessage(e.toString().trim());  
           
	 }
	%>
	<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
	


<%--  emxCreatePartRevisionPostProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxEngrFramesetUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="matrix.db.Context"%>
<%@page import = "com.matrixone.apps.engineering.EngineeringConstants" %>
<%@page import = "com.matrixone.apps.engineering.Part" %>
<%@page import = "com.dassault_systemes.enovia.partmanagement.modeler.impl.PartCollaborationService" %>
<%@page import = "com.dassault_systemes.enovia.partmanagement.modeler.interfaces.services.IPartCollaborationService" %>
<%@page import = "com.dassault_systemes.enovia.partmanagement.modeler.interfaces.validator.IPartValidator" %>



<%
  
  String sErrMsgCode    = "";
  
  String copyObjectId = emxGetParameter(request,"copyObjectId");
  Part part = new Part(copyObjectId);
  
  String newRevId = emxGetParameter(request,"newObjectId");
  Part revPart = new Part(newRevId);

  context = (Context)request.getAttribute("context");
  
  boolean isMFGInstalled = EngineeringUtil.isMBOMInstalled(context);
	
  String portalCmdName=emxGetParameter(request,"portalCmdName");
  portalCmdName = (portalCmdName == null) ? "" : portalCmdName;
  String frameName=emxGetParameter(request,"frameName");
  frameName = (frameName == null) ? "" : frameName;
%>

<%@include file = "emxEngrStartUpdateTransaction.inc"%>

<%
try {
	if (isMFGInstalled) 
	{
		//A64+ Added for Planning MBOM -> start
		revPart.setEndItem(context);
		String strPolicy = revPart.getInfo(context, DomainConstants.SELECT_POLICY);
		
		if(UIUtil.isNotNullAndNotEmpty(strPolicy) && strPolicy.equals(DomainConstants.POLICY_EC_PART)) {
			String sEndItem = emxGetParameter(request, "EndItem");
			
			//Added PR Inter-face changes
			if(UIUtil.isNotNullAndNotEmpty(sEndItem) && "Yes".equalsIgnoreCase(sEndItem)) {
				String prevProductId= part.getInfo (context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_GBOM")+"].from.id");
				String NewProductId = revPart.getInfo (context, "to["+PropertyUtil.getSchemaProperty(context, "relationship_GBOM")+"].from.id");
				if(UIUtil.isNotNullAndNotEmpty(prevProductId) &&  !(prevProductId.equals(NewProductId))){
				  DomainRelationship.connect(context,new DomainObject(prevProductId),PropertyUtil.getSchemaProperty(context, "relationship_GBOM"),revPart);
				}
			}
		}
		
		
		if(UIUtil.isNotNullAndNotEmpty(strPolicy) && strPolicy.equals(DomainConstants.POLICY_EC_PART)) {
			String planningReq = emxGetParameter(request, "PlanningRequired");
			
			//Added PR Inter-face changes
			if(UIUtil.isNotNullAndNotEmpty(planningReq)) {
				revPart.setPlanningReq(context, planningReq);
				//Added for Manufacturing Plan -Start
				//commented for IR-308242-3DEXPERIENCER2015x
				/* if("Yes".equalsIgnoreCase(planningReq)){
				  revPart.addManufacturingPlan(context);
				} */
				//Added for Manufacturing Plan - End
			}
		}
		
		
		//A64- Added for Planning MBOM -> End
    }
    
    //Added for MCC EC Interoperability Feature
    //Below code will  be used to automatically enable revised EC parts when the Parent part's MCC Update setting is Unset i.e. interface is not associated
    boolean mccInstall = FrameworkUtil.isSuiteRegistered(context,"appVersionMaterialsComplianceCentral",false,null,null);
    if(mccInstall) {
    	String attrEnableCompliance =PropertyUtil.getSchemaProperty(context,"attribute_EnableCompliance");
        String sEnableCompliance = part.getInfo (context, "attribute["+attrEnableCompliance+"]");

         //check if  "Enable Compliance" attribute present on the part. if it does not contain the attribute i.e. interface is not associated then the value for attribute to be return as blank ""
        if("".equals(sEnableCompliance)) {   //check that values for this property will be "Yes"
            String strEnableForMCC = FrameworkProperties.getProperty(context, "emxMaterialsCompliance.EnableMCCForNewECParts");

            if(strEnableForMCC !=null && strEnableForMCC.equalsIgnoreCase("Yes")) {
                //associate the Compliance interface to a new revise part
                MqlUtil.mqlCommand(context,"modify bus $1 add interface $2",newRevId,"Material Compliance");
                //getting default value for "Enable Compliance" attribute & set it
                AttributeType attrEnableComplianceType = new AttributeType(attrEnableCompliance);
                revPart.setAttributeValue(context,attrEnableCompliance,attrEnableComplianceType.getDefaultValue(context));
            }
        }
    }
    
    
    /* Added for auto collaboration to update the modify operation after the revise operation .st  */
    
    try{
	    	 
	 			IPartCollaborationService iPartCollabService = new PartCollaborationService();
			
			    ArrayList<String> list = new ArrayList<String>();
			    list.add(newRevId);
				
				iPartCollabService.setCollaboratToDesign(true);
				iPartCollabService.performCollabOperation(context, list, IPartValidator.OPERATION_MODIFY);
				
    } catch (Exception e) {
    	throw e;
    }
   
    /* auto collaboration .en */
    
%>

   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
   <script language="javascript">
   
   function updateCountAndRefreshTreeTest(appDirectory,openerObj,parentOIDs)
   {
       var objectIds   = getObjectsToBeModified(openerObj,parentOIDs);
       
       for(var objectId in objectIds) {
       
           var updatedLabel    = getUpdatedLabel(appDirectory,objectId,openerObj);
       
           openerObj.changeObjectLabelInTree(objectId, updatedLabel, true, false, false);
       }
   }
//XSSOK
   if("<%=portalCmdName%>"){
   		var varFrame = findFrame(getTopWindow(), "<%=portalCmdName%>");
   		updateCountAndRefreshTreeTest("<%=appDirectory%>",varFrame);
  
   		//XSSOK
   		var refreshURL = varFrame.location.href;
        	refreshURL = refreshURL.replace("persist=true",""); 
        	varFrame.location.href = refreshURL;
   }
   //XSSOk
   else if("<%=frameName%>"){
   		var varFrame = findFrame(getTopWindow(), "<%=frameName%>");
   		updateCountAndRefreshTreeTest("<%=appDirectory%>",varFrame);
  
   		//XSSOK
   		var refreshURL = varFrame.location.href;
        	refreshURL = refreshURL.replace("persist=true",""); 
        	varFrame.location.href = refreshURL;
   }
   else{
	   updateCountAndRefreshTreeTest("<%=appDirectory%>", getTopWindow().getWindowOpener());
	   
	   //XSSOK
	   getTopWindow().getWindowOpener().refreshTable();
   }
       
   </script>
<% 
} catch(Exception e) {
%>
  <%@include file = "emxEngrAbortTransaction.inc"%>
<%
  session.putValue("error.message",e.toString());
%>
    <script language="javascript">
    var refreshURL = getTopWindow().location.href; 
    refreshURL = refreshURL.replace("persist=true",""); 
    getTopWindow().location.href = refreshURL;
    </script>
<%
}
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%
  session.setAttribute("emxEngErrorMessage", sErrMsgCode);
%>


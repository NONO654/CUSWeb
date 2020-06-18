
<%--
  HideSubTypesProcess.jsp

 Creates Preference TO Hide OOTB useless inherited Types.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program


<%-- 
@Fullreview KIE1 ZUD   16:02:24  :  HL Hide OOTB useless inherited Types.
@quickreview     ZUD   16:05:18  : 	IR-442635-3DEXPERIENCER2017x: Error during import of 3DXML files
@quickreview KIE1 ZUD  17:02:16  : IR-481848-3DEXPERIENCER2018x: MIG17x|Case3|: Activation of Hidden sub-types from preferences on migration server is KO.
@quickreview      ZUD  17:03:15  : HF-487988-3DEXPERIENCER2017x_FD01: R419-FUN058633: Indexation Is not Working Properly, for Hide / Unhiding OOTB Reqvirement subtypes    	 
--%>

<%@page import="com.matrixone.apps.requirements.*"%>
<%@page import="com.matrixone.search.index.ConfigModeler"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    // check if change has been submitted or just refresh mode
    // Get language

    		String[] subTypes = new String[9];
			subTypes[0] = "Customer Requirement Specification";
			subTypes[1] = "Customer Response Requirement Specification";
			subTypes[2] = "Feature Requirement Specification";
			subTypes[3] = "Product Requirement Specification";
			subTypes[4] = "Sub System Requirement Specification";
			subTypes[5] = "System Requirement Specification";
			subTypes[6] = "Customer Specification";
			subTypes[7] = "Customer Requirement";
			subTypes[8] = "User Requirement";
    		
    		String[] toHideSubTypes = new String[9];

			String  CustomerRequirementSpecification		= emxGetParameter(request, "CustomerRequirementSpecification");		
			String	CustomerResponseRequirementSpecification= emxGetParameter(request, "CustomerResponseRequirementSpecification");
			String 	FeatureRequirementSpecification			= emxGetParameter(request, "FeatureRequirementSpecification");
			String 	ProductRequirementSpecification			= emxGetParameter(request, "ProductRequirementSpecification");		
			String	SubSystemRequirementSpecification		= emxGetParameter(request, "SubSystemRequirementSpecification");
			String 	SystemRequirementSpecification			= emxGetParameter(request, "SystemRequirementSpecification");
			String	CustomerSpecification					= emxGetParameter(request, "CustomerSpecification");
			String 	CustomerRequirement						= emxGetParameter(request, "CustomerRequirement");
			String	UserRequirement							= emxGetParameter(request, "UserRequirement");
			
			toHideSubTypes[0] = CustomerRequirementSpecification;
			toHideSubTypes[1] = CustomerResponseRequirementSpecification;
			toHideSubTypes[2] = FeatureRequirementSpecification;
			toHideSubTypes[3] = ProductRequirementSpecification;
			toHideSubTypes[4] = SubSystemRequirementSpecification;
			toHideSubTypes[5] = SystemRequirementSpecification;
			toHideSubTypes[6] = CustomerSpecification;
			toHideSubTypes[7] = CustomerRequirement;
			toHideSubTypes[8] = UserRequirement;
			ConfigModeler cm;
			
			
			try
			{
				cm = new ConfigModeler(context);
				for (int i = 0; i < toHideSubTypes.length; i++)
				{
                                        
					// added user-agent in context for performing mql operations.
					 ContextUtil.pushContext(context);
					 String subType = "";
					 String checked = "";
					 if(toHideSubTypes[i] != null && toHideSubTypes[i] != "")
					 {
						 checked = "checked";
						 subType = toHideSubTypes[i].trim();
						 MqlUtil.mqlCommand(context, "modify type $1 $2", subType, "!hidden");
						 MqlUtil.mqlCommand(context, "modify type $1 property $2 value $3", subType, "CustomerExposition", "Programmer");
						 // ZUD API to set Indexation of SUB-Types/Customized types
						 boolean bChanged = cm.addBOType("*", subType, subType+"_Field","");
						
					 }else
					 {
						 checked = "false";
						 subType = subTypes[i].trim();
						 MqlUtil.mqlCommand(context, "modify type $1 $2", subType, "hidden");
						 MqlUtil.mqlCommand(context, "modify type $1 property $2 value $3", subType, "CustomerExposition", "ProgrammerOnly");
						
						 
					 }	
					// removed user-agent for setting admin property
					 ContextUtil.popContext(context);
					 PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_"+subType.replaceAll(" ", ""), checked);
				}
				cm.commit(context);
				
			}catch(Exception e)
			{
				
			}	
	
%>    
<script>   
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

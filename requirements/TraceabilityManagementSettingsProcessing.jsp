<%--
  TraceabilityManagementSettingsProcessing.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
--%>

<%--
	@quickreview HAT1 ZUD 14:12:22	 :  HL Requirement Specification Dependency.
    @quickreview HAT1 ZUD 15:04:24   : IR-364538-3DEXPERIENCER2016x- FUN048478:By default no option selected in Traceability Management section in Preferences tab. Modification to check null value.
--%>


<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    // check if change has been submitted or just refresh mode
    // Get language

    String TraceabilityManagementSettings = emxGetParameter(request, "TraceabilityManagementSettings");
	try{
		
		ContextUtil.startTransaction(context, true);
		if(TraceabilityManagementSettings.equalsIgnoreCase("AlwaysPrompt"))
		{
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTraceabilityMgtSettings", TraceabilityManagementSettings.trim());
		    
    		String AlwaysPromptTargets      = emxGetParameter(request, "AlwaysPromptTargets");
    		String AlwaysPromptRelationship = emxGetParameter(request, "AlwaysPromptRelationship");
    		
            //HAT1 ZUD IR-364538-3DEXPERIENCER2016x
	    	if(null == AlwaysPromptTargets || AlwaysPromptTargets.equalsIgnoreCase("null") || AlwaysPromptTargets.equalsIgnoreCase(""))
	    	{
	    		AlwaysPromptTargets = "";
	    	}
	    	
            //HAT1 ZUD IR-364538-3DEXPERIENCER2016x
	    	if(null == AlwaysPromptRelationship || AlwaysPromptRelationship.equalsIgnoreCase("null") || AlwaysPromptRelationship.equalsIgnoreCase(""))
	    	{
	    		AlwaysPromptRelationship = "";
	    	}
	    	
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptTargets", AlwaysPromptTargets.trim());
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptRelationship", AlwaysPromptRelationship.trim());
		
		}
		
		else if(TraceabilityManagementSettings.equalsIgnoreCase("NeverPrompt") || TraceabilityManagementSettings.equalsIgnoreCase("AlwaysCreateDelete"))
		{
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTraceabilityMgtSettings", TraceabilityManagementSettings.trim());
			
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptTargets", "");
			PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptRelationship", "");
		}
	
	}
	catch (Exception ex) {
	    ContextUtil.abortTransaction(context);
	
	    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
	    {
	        emxNavErrorObject.addMessage("prefStructureDisplay:" + ex.toString().trim());
	    }
	}
	finally
	{
	    ContextUtil.commitTransaction(context);
	}

%>    
<script>   
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


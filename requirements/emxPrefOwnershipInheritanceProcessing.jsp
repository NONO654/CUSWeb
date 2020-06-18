<%--
  emxPrefOwnershipInheritanceProcessing.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

     @quickreview qyg      17:07:12  :  preference for Ownership Inheritance
--%>


<%@page import="com.matrixone.apps.requirements.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%!
void setPreferenceParameter(Context context, HttpServletRequest request, String pref) throws FrameworkException{
	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), pref, "true".equalsIgnoreCase(emxGetParameter(request, pref)) + "");
}
%>
<%
	try{
		if(RequirementsUtil.isAdmin(context)) {
			RequirementsUtil.allowPropagateAccess(context, "true".equalsIgnoreCase(emxGetParameter(request, "pref_RMTAllowPropagateAccess")));
			RequirementsUtil.allowInheritAccess(context, "true".equalsIgnoreCase(emxGetParameter(request, "pref_RMTAllowInheritAccess")));
		}
		else {
			if(RequirementsUtil.isPropagateAccessAllowed(context)) {
				setPreferenceParameter(context, request, "pref_PropagateAccess_RequirementGroup");
				setPreferenceParameter(context, request, "pref_PropagateAccess_RequirementSpecification");
				setPreferenceParameter(context, request, "pref_PropagateAccess_Chapter");
				setPreferenceParameter(context, request, "pref_PropagateAccess_Requirement");
				
				setPreferenceParameter(context, request, "pref_ResetPropagateAccessOnClone");
				setPreferenceParameter(context, request, "pref_ResetPropagateAccessOnMajorRevise");
			}
			if(RequirementsUtil.isInheritAccessAllowed(context)) {
				setPreferenceParameter(context, request, "pref_InheritAccess_RequirementGroup");
				setPreferenceParameter(context, request, "pref_InheritAccess_RequirementSpecification");
				setPreferenceParameter(context, request, "pref_InheritAccess_Chapter");
				setPreferenceParameter(context, request, "pref_InheritAccess_Requirement");
				setPreferenceParameter(context, request, "pref_InheritAccess_Comment");
				
				setPreferenceParameter(context, request, "pref_ResetInheritAccessOnClone");
				setPreferenceParameter(context, request, "pref_ResetInheritAccessOnMajorRevise");
			}
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

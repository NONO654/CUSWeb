<%-- @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. 
	 @quickreview HAT1 ZUD 19 Apr 2017 : TSK3278161 - R419: Deprecation of functionalities to clean up.( "Specification Structure" preference should remove derived requirement options)
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsUtil"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<%
    try
    {
        ContextUtil.startTransaction(context, true);
        RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_STRUCTURE_COMPARE_INC_SUB_REQ, request);

        // HAT1 ZUD: TSK3278161
        //RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_STRUCTURE_COMPARE_INC_DERIVED_REQ, request);

        RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_TESTCASE_INC_SUB_REQ, request);

        // HAT1 ZUD: TSK3278161
        //RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_TESTCASE_INC_DERIVED_REQ, request);

        RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_FEATURE_INC_SUB_REQ, request);

        // HAT1 ZUD: TSK3278161
        //RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_REPORT_REQ_FEATURE_INC_DERIVED_REQ, request);

        RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_DELETE_CHILDREN_INC_SUB_REQ, request);

        // HAT1 ZUD: TSK3278161
        //RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_DELETE_CHILDREN_INC_DERIVED_REQ, request);
        //RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_RESERVE_INC_DERIVED_REQ, request);

        RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_RESERVE_INC_SUB_REQ, request);

        if(RequirementsUtil.isVPMInstalled(context)){
        	RequirementsCommon.setBooleanPreference(context, RequirementsCommon.PREF_RFLP_INC_SUB_REQ, request);
        }
    }
    catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage(ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


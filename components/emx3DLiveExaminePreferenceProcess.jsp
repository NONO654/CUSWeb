<%--  
	emx3DLiveExaminePreferenceProcess.jsp
	Copyright (c) 1992-2018 Dassault Systemes.
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    String Channel3D = (String)emxGetParameter(request,"3DLiveExamineChannel");

    // if change has been submitted then process the change
    if (Channel3D != null) {
        try {
            ContextUtil.startTransaction(context, true);
            PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_3DLiveExamineToggle", Channel3D);
            ContextUtil.commitTransaction(context);
        } catch (Exception ex) {
            ContextUtil.abortTransaction(context);
	
            if(ex.toString()!=null && (ex.toString().trim()).length()>0) {
                emxNavErrorObject.addMessage("emxPrefLanguage:" + ex.toString().trim());
            }
        }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


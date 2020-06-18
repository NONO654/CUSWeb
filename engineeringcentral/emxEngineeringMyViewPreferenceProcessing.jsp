<%--  emxEngineeringMyViewPreferenceProcessing.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    String ndays = emxGetParameter(request,"NumberOfDays");

    // if change has been submitted then process the change
    if (ndays != null)
    {
        try
        {
            ContextUtil.startTransaction(context, true);

            // Set vault Preference
            session.setAttribute("ENCDatePreference",ndays);
            PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_MyViewPreference", ndays);
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);
	
            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxPrefLanguage:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


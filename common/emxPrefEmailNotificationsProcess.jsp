<%--  emxPrefEmailNotificationsProcessing.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefEmailNotificationsProcessing.jsp.rca 1.7 Wed Oct 22 15:48:39 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String frequency = emxGetParameter(request, "frequency");
	String language = emxGetParameter(request, "language");
	
    try {
        ContextUtil.startTransaction(context, true);
        PersonUtil.setEmailNotificationsPreference(context, frequency);
     	
        // if change has been submitted then process the change
        if (language != null){
        	PersonUtil.setLanguage(context, language);
        }
    }
    catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString() != null && (ex.toString().trim()).length() > 0) {
            emxNavErrorObject.addMessage("emxPrefEmailNotifications:" + ex.toString().trim());
        }
    }
    finally {
        ContextUtil.commitTransaction(context);
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>



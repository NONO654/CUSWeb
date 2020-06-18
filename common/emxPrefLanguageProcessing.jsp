<%--  emxPrefLanguage.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefLanguageProcessing.jsp.rca 1.5 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    // check if change has been submitted or just refresh mode
    // Get language
    String language = emxGetParameter(request, "language");

    // if change has been submitted then process the change
    if (language != null)
    {
        try
        {
            ContextUtil.startTransaction(context, true);

            // Set vault Preference
            PersonUtil.setLanguage(context, language);
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


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


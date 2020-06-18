<%--  emxPrefTimeZoneProcessing.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefTimeZoneProcessing.jsp.rca 1.5 Wed Oct 22 15:48:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String prefTimeZone = emxGetParameter(request, "timeZoneList");
    String prefUseDayLight = emxGetParameter(request, "useDayLight");

    try
    {
        ContextUtil.startTransaction(context, true);
        if(prefTimeZone != null && prefTimeZone.trim().length() != 0)
            PersonUtil.setTimeZonePreference(context,prefTimeZone.trim());
        if(prefUseDayLight != null && prefUseDayLight.trim().length() != 0)
            PersonUtil.setDaylightSavingPreference(context,prefUseDayLight.trim());
        else
            PersonUtil.setDaylightSavingPreference(context,"No");
    }
    catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefTimeZone:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }

%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


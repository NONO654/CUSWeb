<%--  emxPrefDate.jsp -
   Copyright (c) 1992- 2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefDateProcessing.jsp.rca 1.4 Wed Oct 22 15:48:06 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
    // check if change has been submitted or just refresh mode
    // Get Short Date Format
    String newDateFormat = Request.getParameter(request, "DateFormat");
    String newTimeDisplay = Request.getParameter(request, "TimeDisplay");

    if (newTimeDisplay == null )
    {
        newTimeDisplay = "";
    }

    try
    {
        ContextUtil.startTransaction(context, true);
        // if change has been submitted then process the change
        if ((new Integer(newDateFormat)) != null &&
            newDateFormat.length() > 0)
        {
            int iCurrentDateFormat = PersonUtil.getDateFormat(context);
            int iNewDateFormat = (new Integer(newDateFormat)).intValue();

            if ( (new Integer(iCurrentDateFormat)) != null &&
                    iCurrentDateFormat != iNewDateFormat )
            {
                PersonUtil.setDateFormat(context, newDateFormat);
            }
        }

        String currentTimeDisplay = PersonUtil.getTimeDisplay(context);
        if ( currentTimeDisplay != null ||
            !(currentTimeDisplay.equals(newTimeDisplay)) )
        {
            PersonUtil.setTimeDisplay(context, newTimeDisplay);
        }
    }
    catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefDateProcessing:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }

%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>



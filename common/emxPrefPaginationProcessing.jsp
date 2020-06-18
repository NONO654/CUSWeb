<%--  emxPrefPaginationProcessing.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefPaginationProcessing.jsp.rca 1.5 Wed Oct 22 15:47:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    // check if change has been submitted or just refresh mode
    // Get language
    String prefPagination = emxGetParameter(request, "prefPagination");
    String prefPaginationRange = emxGetParameter(request, "txtPageRange");

        try
        {
                int range = Integer.parseInt(prefPaginationRange);
                if(range < 0)
                {
                    prefPaginationRange="";
                }
        }
        catch(NumberFormatException nfe)
        {
            prefPaginationRange="";
        }
        if( (prefPagination == null) || ("".equals(prefPagination)) )
        {
            prefPagination="";
        }
    // if change has been submitted then process the change
        try
        {
            ContextUtil.startTransaction(context, true);
            if(prefPagination !=null)
                PersonUtil.setPaginationPreference(context,prefPagination.trim());
            if(prefPaginationRange !=null)
                PersonUtil.setPaginationRangePreference(context,prefPaginationRange.trim());
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxPrefPagination:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }

%>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


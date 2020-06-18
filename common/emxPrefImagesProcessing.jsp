<%--  emxPrefImagesInTablesFormsProcessing.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefImagesProcessing.jsp.rca 1.1.1.1.5.4 Wed Oct 22 15:48:27 2008 przemek Experimental przemek $
--%>


<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
        // check if change has been submitted or not
        String strPrefShowImagesTables = emxGetParameter(request, "prefShowImagesTables");
        String strPrefShowImagesForms = emxGetParameter(request,"prefShowImagesForms");

        if( (strPrefShowImagesTables == null) || ("".equals(strPrefShowImagesTables)) )
        {
            strPrefShowImagesTables="";
        }
        if( (strPrefShowImagesForms == null) || ("".equals(strPrefShowImagesForms)) )
        {
            strPrefShowImagesForms="";
        }
        // if change has been submitted then process the change
        try
        {
            ContextUtil.startTransaction(context, true);
            if(strPrefShowImagesTables !=null)
                PersonUtil.setImagesTablesPreference(context,strPrefShowImagesTables.trim());
            if(strPrefShowImagesForms !=null)
                PersonUtil.setImagesFormsPreference(context,strPrefShowImagesForms.trim());
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("emxprefShowImages:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


<%--  emxPrefToggleBrowserToolbarProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxPrefToggleBrowserToolbarProcess.jsp.rca 1.1.1.5 Wed Oct 22 15:48:48 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String prefShowToolbar = emxGetParameter(request, "showToolbar");
    if((prefShowToolbar == null) || ("".equals(prefShowToolbar.trim()))){
        prefShowToolbar="";
    }
    // if change has been submitted then process the change
    ContextUtil.startTransaction(context, true);
    if(prefShowToolbar !=null){
        try{
            PersonUtil.setToolbarPreference(context,prefShowToolbar.trim());
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);
            if(ex.toString()!=null && (ex.toString().trim()).length()>0){
                emxNavErrorObject.addMessage("Error in Setting the Toggle Toolbar Preference:" + ex.toString().trim());
            }
        }
        ContextUtil.commitTransaction(context);
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>


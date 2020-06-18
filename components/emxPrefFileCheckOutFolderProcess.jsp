<%-- emxPrefFileCheckOutFolderProcessing.jsp -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page

--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
    String defaultCheckoutFolder = emxGetParameter(request,"defaultCheckoutFolder");

    // if change has been submitted then process the change
    if (defaultCheckoutFolder != null)
    {
    	//defaultCheckoutFolder = FrameworkUtil.findAndReplace (defaultCheckoutFolder , "/", "\\");
    	
        try
        {
            ContextUtil.startTransaction(context, true);
                     
            PropertyUtil.setAdminProperty(context, DomainConstants.TYPE_PERSON, context.getUser(), "preference_DefaultCheckoutDirectory", defaultCheckoutFolder);
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


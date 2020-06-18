<%--
  emxPrefFeatureNameDisplayProcessing.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
    // check if change has been submitted or just refresh mode
    // Get language
    String prefFeatureDisplay = emxGetParameter(request, "prefFeatureDisplay");
        if( (prefFeatureDisplay == null) || ("".equals(prefFeatureDisplay)) )
        {
            prefFeatureDisplay="";
        }
    // if change has been submitted then process the change
        try
        {
            ContextUtil.startTransaction(context, true);
            if(prefFeatureDisplay !=null)
                PersonUtil.setFeatureNameDisplayPreference(context,prefFeatureDisplay.trim());
        }
        catch (Exception ex) {
            ContextUtil.abortTransaction(context);

            if(ex.toString()!=null && (ex.toString().trim()).length()>0)
            {
                emxNavErrorObject.addMessage("prefFeatureDisplay:" + ex.toString().trim());
            }
        }
        finally
        {
            ContextUtil.commitTransaction(context);
        }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

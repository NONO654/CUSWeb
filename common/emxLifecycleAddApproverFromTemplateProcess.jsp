<%--  emxLifecycleAddApproverFromTemplateProcess.jsp   -   Process page for Add Approver From Template functionality

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFromTemplateProcess.jsp.rca 1.3.3.2 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import=" com.matrixone.apps.common.*" %>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%
    String strObjectId 			= emxGetParameter(request, "objectId");
    String[] strStateNewRoutes 	= emxGetParameterValues(request, "stateNewRoute");
    StringList slSplitedStrings = null;

    try {

        //strStateNewRoutes = {StateName|RouteTemplateId, StateName|RouteTemplateId, StateName|RouteTemplateId}
        if(strStateNewRoutes != null){
	        for (int i = 0; i < strStateNewRoutes.length; i++) {
	            // StateName|RouteTemplateId
	            slSplitedStrings = FrameworkUtil.split(strStateNewRoutes[i], "|");
	            
		        String strStateName 		= (String)slSplitedStrings.get(0); //Get the state name
	    	    String strRouteTemplateId 	= (String)slSplitedStrings.get(1); //Get the Route Template Id
	    	    
		        Lifecycle lifecycle = new Lifecycle();
	    	    lifecycle.addApproverTaskFromTemplate(context, strObjectId, strStateName, strRouteTemplateId);
	        }
        }
    } catch (Exception ex) {
        emxNavErrorObject.addMessage(ex.getMessage());
        ex.printStackTrace();
    }
    %>        
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

	        <script language="JavaScript">
	        <!--
	            getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	            getTopWindow().closeWindow();
	        //-->
	    	</script> 

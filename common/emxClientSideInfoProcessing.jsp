<%-- emxClientSideInfoProcessing.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxClientSideInfoProcessing.jsp.rca 1.5 Wed Oct 22 15:49:02 2008 przemek Experimental przemek $
--%>


                
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
try{

    UINavigatorUtil.processClientSideData(context, pageContext);
	Boolean emxCommonAppInitialized = (Boolean)session.getAttribute("emxCommonAppInitialized");
    
    if (!emxCommonAppInitialized.booleanValue())
    {
    	String url = UINavigatorUtil.notificationURL(context, request, null, null, false);
        String agentName = UINavigatorUtil.notificationAgentName(context);
        String languages = UINavigatorUtil.notificationLanguages(context);
        com.matrixone.apps.domain.util.MailUtil.setMailConfigurations(context, agentName, url, languages);
        session.setAttribute("emxCommonAppInitialized", Boolean.valueOf(true));
    }
    
} catch (Exception ex) {
    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
		System.out.println(ex.toString().trim());
		emxNavErrorObject.addMessage("An error occurred while processing your request");
	}
}

%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

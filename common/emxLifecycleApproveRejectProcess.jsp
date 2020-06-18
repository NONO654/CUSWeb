<%--  emxLifecycleApproveRejectProcess.jsp   -   The process page for Approve/Reject command functionality on Tasks/Signature tab in adv. lifecycle page

   Dassault Systemes, 1993  2007. All rights reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleApproveRejectProcess.jsp.rca 1.2.3.2 Wed Oct 22 15:48:21 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.common.*"%>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%
String strLanguage = request.getHeader("Accept-Language");
String i18NReadAndUnderstand = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),
		"emxFramework.UserAuthentication.ReadAndUnderstand");


    try {
        // Get the required parameters from the request object.
        // These are busObjId, approvalAction, signature, txtareaCmtApp and taskId.
        // Context is set in request object in table edit process page

        String sBusId = (String) emxGetParameter(request, "objectId");
        String strSignatureName = (String) emxGetParameter(request,"signature");
        String strTaskId = (String) emxGetParameter(request, "taskId");
        String strState = (String)emxGetParameter(request, "state");
        String sApprovalAction = (String) emxGetParameter(request,"approvalAction");
        String sSignComment = (String) emxGetParameter(request,"txtareaCmtApp");
        String sRouteTaskUser = (String) emxGetParameter(request,"routeTaskUser");
        String strAlertMessage = "";

        Lifecycle lifecycle = new Lifecycle();
        lifecycle.completeTaskOrSignature(context,
                                                    sBusId,
                                                    strState,
                                                    strSignatureName,
                                                    strTaskId,
                                                    sApprovalAction,
                                                    sSignComment);
        if (UIUtil.isNotNullAndNotEmpty(strTaskId))
        {
        	String isResponsibleRoleEnabled = DomainConstants.EMPTY_STRING;
        	try{
       			isResponsibleRoleEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.ResponsibleRoleForSignatureMeaning.Preserve");
        	}
        	catch(Exception e){
        		isResponsibleRoleEnabled = "false";
        	}
       		String isFDAEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");
        	if(UIUtil.isNotNullAndNotEmpty(isFDAEnabled) && isFDAEnabled.equalsIgnoreCase("true"))
        	{
        		if(UIUtil.isNotNullAndNotEmpty(isResponsibleRoleEnabled) && isResponsibleRoleEnabled.equalsIgnoreCase("true") && UIUtil.isNotNullAndNotEmpty(sRouteTaskUser) && sRouteTaskUser.startsWith("role_"))
        	{
        		i18NReadAndUnderstand = MessageUtil.getMessage(context, null, "emxFramework.UserAuthentication.ReadAndUnderstandRole", new String[] {
        				  PropertyUtil.getSchemaProperty(context, sRouteTaskUser)}, null, context.getLocale(),
        				  "emxFrameworkStringResource");
        		MqlUtil.mqlCommand(context, "Modify bus $1 add history $2 comment $3",false, strTaskId,sApprovalAction,i18NReadAndUnderstand);
        	}
        	else
        MqlUtil.mqlCommand(context, "Modify bus $1 add history $2 comment $3",false, strTaskId,sApprovalAction,i18NReadAndUnderstand);
        }
        	
        }
%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>       
<%
    } catch (Exception ex) {
         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>

<%
	String fromPage = (String) emxGetParameter(request,"fromPage");
%>
<script language="JavaScript">
		var fromPage = "<%=XSSUtil.encodeForJavaScript(context, fromPage)%>";
    	 var portalFrame = getTopWindow();
     try { 
    		 portalFrame = openerFindFrame(getTopWindow(),"detailsDisplay");
         } catch(e) {}
    	   
         if(getTopWindow().getWindowOpener().getTopWindow() && getTopWindow().getWindowOpener().getTopWindow().RefreshHeader) {
             getTopWindow().getWindowOpener().getTopWindow().RefreshHeader();
         }else if(getTopWindow().RefreshHeader){
			getTopWindow().RefreshHeader();            
		 }
         if(portalFrame!=null) {
           portalFrame.document.location.href = portalFrame.document.location.href;
         } 
         
	if(getTopWindow().getWindowOpener().getTopWindow() && "LifecycleApproveRejectDialog"==fromPage){
		getTopWindow().getWindowOpener().getTopWindow().closeWindow();
	}
		window.closeWindow();
	</script>


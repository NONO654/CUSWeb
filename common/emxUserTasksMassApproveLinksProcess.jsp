<%-- This file is for Opening the Window on clicking the Top links in Content Page.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<script language="javascript" src="./scripts/emxUICore.js"></script>
<script language="javascript" src="./scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript" src="./scripts/emxUIConstants.js"></script>
<%
	String fromPage   = emxGetParameter(request, "fromPage");
	String objectId   = emxGetParameter(request, "objectId");
	String parentOID   = emxGetParameter(request, "parentOID");
	String timeStamp	= emxGetParameter(request, "timeStamp");
    session.removeAttribute("VerificationCount");	
    String action = "";
    
	boolean requireAuthentication = "true".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.EnableFDA"));
	boolean showUserName = "true".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.ShowUserNameForFDA"));
    
    if(fromPage.equals("AEFLifecycleMassApproveTask")) {
        boolean signatureApprovalPasswordConfirmation = "true".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxFramework.LifeCycle.ApprovalPasswordConfirmation"));
		action = "emxTableEdit.jsp?program=emxLifecycle:getCurrentAssignedTaskSignaturesOnObject&table=AEFMyTaskMassApprovalSummary&selection=multiple&header=emxComponents.LifecycleTasks.Heading.ApproveAssignedTasks&postProcessURL=emxLifecycleTasksMassApprovalProcess.jsp&HelpMarker=emxhelpmassapprove&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=" + XSSUtil.encodeForURL(context, objectId) + "&parentOID=" + XSSUtil.encodeForURL(context, parentOID);
        if(requireAuthentication || signatureApprovalPasswordConfirmation) {
            String taskAndSignatureTypes = (String) matrix.db.JPO.invoke(context, "emxLifecycle", null, "getTypesToMassApprove", new String[]{objectId}, String.class);
            if("Both".equals(taskAndSignatureTypes)) {
                requireAuthentication = true;
            } else if("IT".equals(taskAndSignatureTypes) && requireAuthentication) {
                requireAuthentication = true;
            } else if("Signature".equals(taskAndSignatureTypes) && signatureApprovalPasswordConfirmation) {
                requireAuthentication = true;
                showUserName = false;
            } else {
                requireAuthentication = false;
            }
            
        }
    } else if(fromPage.equals("APPUserTaskMassApproval")) {
        action = "emxTableEdit.jsp?program=emxLifecycle:getAllAssignedTasks&table=AEFMyTaskMassApprovalSummary&selection=multiple&header=emxComponents.Common.TaskMassApproval&postProcessURL=emxLifecycleTasksMassApprovalProcess.jsp&HelpMarker=emxhelpmytaskmassapprove&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=component";
    } else if(fromPage.equals("APPEditAllMultiTasks")) {
        action = "emxTableEdit.jsp?HelpMarker=emxhelpeditalltasks2&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=" + XSSUtil.encodeForURL(context, objectId) + "&parentOID=" + XSSUtil.encodeForURL(context, parentOID) + "&timeStamp=" + XSSUtil.encodeForURL(context, timeStamp);
    } else if(fromPage.equals("APPMultiTaskComplete")) {
        String[] taskIds = emxGetParameterValues(request, "emxTableRowId");
        String taskIdsKey = "APPMultiTaskComplete:" + System.currentTimeMillis();
        action = "../components/emxMultitaskCompleteProcess.jsp?taskIdsKey=" + taskIdsKey;
        session.setAttribute(taskIdsKey, taskIds);
    }
%>
    <body>
    	<form name="TaskMassApproveForm" id="TaskMassApproveForm" method="post">
<%
	if(requireAuthentication) {
%>
		<!-- //XSSOK -->
		<input type="hidden" id="pageAction" name="pageAction" value='<%=action%>' />
		<!-- //XSSOK -->
		<input type="hidden" id="showUserName" name="showUserName" value='<%=showUserName%>' />
		<script language="Javascript" >
    		var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
			TaskMassApproveForm.action = "emxRoutesFDAUserAuthenticationDialog.jsp";
			window.resizeTo(400,400);
			TaskMassApproveForm.submit();	        
  	   </script>
<%	        
	    } else { 
%>
				<!-- //XSSOK -->
				<script language="Javascript" >
		    		var TaskMassApproveForm=document.getElementById("TaskMassApproveForm");
					//XSSOK
					TaskMassApproveForm.action = "<%=action%>";
					TaskMassApproveForm.submit();	        
				</script>			
<%	        
	        } 	   
%>
		</form>
	</body>


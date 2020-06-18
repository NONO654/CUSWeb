<%--  emxTaskCompletePreProcess.jsp - For validating Inbox Task actions

  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
 --%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.*,com.matrixone.apps.common.*,com.matrixone.apps.framework.ui.UIUtil" %>
<html>
<body>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%
	String pageAction 	  					=  "";
	String submitLabel						=  "";
	String objectId       					= emxGetParameter(request,"objectId");
	String action       					= emxGetParameter(request,"action");
	String fromSummaryPage       			= emxGetParameter(request,"summaryPage");
	InboxTask taskObject  					= (InboxTask)DomainObject.newInstance(context, objectId);
	boolean canTaskCompleted  				= false;
	boolean isTaskCompleted  				= false;
	boolean showCommentsReqAlert			= false;
	boolean showReviewerCommentsReqAlert	= false;
	boolean showFDAWindow					= false;
	boolean notShowFDAWindow				= false;
	boolean isFDAWindow					    = false;
	boolean isRouteStopped					    = false;
	boolean hasRole							= true;
	boolean isTaskToBeAccepted = false;
	
	boolean flag=false;
	try{
	  ContextUtil.pushContext(context);
	  flag = true;
	  canTaskCompleted = taskObject.canCompleteTask(context);
	} finally {
		if(flag)
      		ContextUtil.popContext(context);
	}
	
	if(canTaskCompleted) {
		String reviewComments               = PropertyUtil.getSchemaProperty(context, "attribute_ReviewersComments");
		String reviewCommentsNeeded         = PropertyUtil.getSchemaProperty(context, "attribute_ReviewCommentsNeeded");

		String SELECT_ROUTE_ID              	= "from[" + DomainConstants.RELATIONSHIP_ROUTE_TASK + "].to.id";
		String SELECT_TASK_ASSIGNEE_NAME    	= "from[" + DomainConstants.RELATIONSHIP_PROJECT_TASK + "].to.name";
		String SELECT_ROUTE_ACTION          	= "attribute[" + DomainConstants.ATTRIBUTE_ROUTE_ACTION + "]";
		String SELECT_ROUTE_APPROVAL_STATUS 	= "attribute[" + DomainConstants.ATTRIBUTE_APPROVAL_STATUS + "]";
		String SELECT_TASK_COMMENTS         	= "attribute[" + DomainConstants.ATTRIBUTE_COMMENTS + "]";
	    String SELECT_REVIEW_COMMENTS       	= "attribute["+reviewComments+"]";
		String SELECT_REVIEW_COMMENTS_NEEDED	= "attribute["+reviewCommentsNeeded+"]";
		String SELECT_REVIEW_TASK	= "attribute[" + DomainConstants.ATTRIBUTE_REVIEW_TASK + "]";
		
		String SELECT_ROUTE_STATUS              	= "from[" + DomainObject.RELATIONSHIP_ROUTE_TASK + "].to.attribute[" + DomainObject.ATTRIBUTE_ROUTE_STATUS + "]";

		String SELECT_TASK_STATE            = "current";
		String SELECT_TASK_OWNER            = "owner";

		StringList taskSelectList = new StringList(10);
		taskSelectList.add(SELECT_ROUTE_ID);
		taskSelectList.add(SELECT_TASK_ASSIGNEE_NAME);
		taskSelectList.add(InboxTask.SELECT_ROUTE_TASK_USER);
		taskSelectList.add(SELECT_ROUTE_ACTION);
		taskSelectList.add(SELECT_ROUTE_APPROVAL_STATUS);
		taskSelectList.add(SELECT_TASK_COMMENTS);
		taskSelectList.add(SELECT_TASK_STATE);
		taskSelectList.add(SELECT_TASK_OWNER);
	    taskSelectList.add(SELECT_REVIEW_COMMENTS);
		taskSelectList.add(SELECT_REVIEW_COMMENTS_NEEDED);
		taskSelectList.add(SELECT_ROUTE_STATUS);

		ContextUtil.pushContext(context);
		Map taskMap = taskObject.getInfo(context,taskSelectList);
		ContextUtil.popContext(context);

		String strRouteId        = (String)taskMap.get(SELECT_ROUTE_ID );
		String taskRouteAction   = (String)taskMap.get(SELECT_ROUTE_ACTION );
		String strCurrentState   = (String)taskMap.get(SELECT_TASK_STATE );
		String approvalStatus    = (String)taskMap.get(SELECT_ROUTE_APPROVAL_STATUS );
		String comments          = (String)taskMap.get(SELECT_TASK_COMMENTS );
		String strTaskAssignee   = (String)taskMap.get(SELECT_TASK_ASSIGNEE_NAME );
		String sTaskOwner        = (String)taskMap.get(SELECT_TASK_OWNER );
	    String strReviewCommentsNeeded = (String)taskMap.get(SELECT_REVIEW_COMMENTS_NEEDED);
		String strReviewComments = (String)taskMap.get(SELECT_REVIEW_COMMENTS);
		String strReviewTask = (String)taskMap.get(SELECT_REVIEW_TASK);
		String strRouteStatus = (String)taskMap.get(SELECT_ROUTE_STATUS);
		String strRouteTaskUser = (String)taskMap.get(InboxTask.SELECT_ROUTE_TASK_USER);
		//To check if the task is assigned to user group
		if(sTaskOwner.equals(PropertyUtil.getSchemaProperty(context,"role_USERGROUPOWNER"))){
             isTaskToBeAccepted = true;
        }
		//Due to Resume Process implementation there can be tasks which are not connected to route and hence we cannot find
		//the route id from these tasks. Then the route id can be found by first finding the latest revision of the task
		//and then querying for the route object.
		if (strRouteId == null) {
			DomainObject dmoLastRevision = new DomainObject(taskObject.getLastRevision(context));
			strRouteId = dmoLastRevision.getInfo(context, SELECT_ROUTE_ID);
		}

		String showComments          = EnoviaResourceBundle.getProperty(context,"emxComponents.Routes.ShowCommentsForTaskApproval");
		String ignoreComments        = EnoviaResourceBundle.getProperty(context,"emxComponentsRoutes.InboxTask.IgnoreComments");
		String isFDAEnabled 		 = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");
        String stateComplete 		 = PropertyUtil.getSchemaProperty(context, "policy", DomainConstants.POLICY_INBOX_TASK, "state_Complete");
		
	    showComments = UIUtil.isNullOrEmpty(showComments) ? "true" : showComments;
	    ignoreComments = UIUtil.isNullOrEmpty(ignoreComments) ? "false" : ignoreComments;

		boolean isCommentsRequired = "true".equalsIgnoreCase(showComments);
		boolean ignoreRejectComments = "true".equalsIgnoreCase(ignoreComments);
		boolean hasComments = !UIUtil.isNullOrEmpty(comments);
        boolean hasReviewerCommnets = !UIUtil.isNullOrEmpty(strReviewComments);
        boolean isPromote = (("Yes".equals(strReviewTask) && UIUtil.isNotNullAndNotEmpty(comments)));
        isTaskCompleted = (stateComplete.equals(strCurrentState));

		boolean isCompleteAction = "Complete".equals(action);
        boolean isApproveAction = "Approve".equals(action);
        boolean isRejectAction = "Reject".equals(action);
        boolean isAbstainAction = "Abstain".equals(action);
        boolean isPromoteAction = "PromoteTask".equals(action);
        boolean isDemoteAction = "DemoteTask".equals(action);		
        isRouteStopped = "Stopped".equals(strRouteStatus);
		
        if(!"true".equals(fromSummaryPage)) {
		if(isCompleteAction) {
        	submitLabel = "emxFramework.State.Inbox_Task.Complete";
        } else if(isApproveAction) {
        	submitLabel = "emxFramework.Range.Approval_Status.Approve";
        } else if(isRejectAction) {
        	submitLabel = "emxFramework.Range.Approval_Status.Reject";
        } else if(isAbstainAction) {
        	submitLabel = "emxFramework.Range.Approval_Status.Abstain";
        }
        }
        if(isRouteStopped) {
        	showCommentsReqAlert = false;
        }
        else if(isCompleteAction) {
		    showCommentsReqAlert = !hasComments;
		    StringBuffer buffer = new StringBuffer();
			buffer.append("../components/emxTaskCompleteProcess.jsp?");
			buffer.append("routeId=").append(XSSUtil.encodeForURL(context,strRouteId)).append('&');
			buffer.append("taskId=").append(XSSUtil.encodeForURL(context,objectId)).append('&');
			buffer.append("approvalStatus=None").append('&');
			buffer.append("getCommentsFromTaskId=true");
		    pageAction = buffer.toString();
		    
		} else if(isApproveAction || isRejectAction || isAbstainAction) {
		    showCommentsReqAlert = ((isApproveAction || isAbstainAction) && isCommentsRequired && !hasComments)  ||
		                            (isRejectAction && !ignoreRejectComments && !hasComments);
		    showFDAWindow = !showCommentsReqAlert && "true".equalsIgnoreCase(isFDAEnabled);
			isFDAWindow   = "true".equalsIgnoreCase(isFDAEnabled) && showCommentsReqAlert;

		    StringBuffer buffer = new StringBuffer();
			buffer.append("../components/emxTaskCompleteProcess.jsp?");
			buffer.append("routeId=").append(XSSUtil.encodeForURL(context,strRouteId)).append('&');
			buffer.append("taskId=").append(XSSUtil.encodeForURL(context,objectId)).append('&');
			buffer.append("approvalStatus=").append(XSSUtil.encodeForURL(context,action)).append('&');
			buffer.append("getCommentsFromTaskId=true");
			if (UIUtil.isNotNullAndNotEmpty(strRouteTaskUser)) {
        		hasRole  = PersonUtil.hasAssignment(context,PropertyUtil.getSchemaProperty(context, strRouteTaskUser));
			}else {
				hasRole = false;
			}
        	String isResponsibleRoleEnabled = DomainConstants.EMPTY_STRING;
        	try{
        		isResponsibleRoleEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.ResponsibleRoleForSignatureMeaning.Preserve");
        	

            if(UIUtil.isNotNullAndNotEmpty(isFDAEnabled) && isFDAEnabled.equalsIgnoreCase("true") && UIUtil.isNotNullAndNotEmpty(isResponsibleRoleEnabled) && isResponsibleRoleEnabled.equalsIgnoreCase("true")
            	&& UIUtil.isNotNullAndNotEmpty(strRouteTaskUser) && strRouteTaskUser.startsWith("role_"))
            {
            	if(hasRole)
            		buffer.append("&routeTaskUser=").append(XSSUtil.encodeForURL(context,strRouteTaskUser));
            	else
            	{
            		showFDAWindow = false;
            		notShowFDAWindow = true;
            	}
           	}
        	}
        	catch(Exception e)
        	{
        		isResponsibleRoleEnabled = "false";
        	}
			
        	
		    pageAction = buffer.toString();
		    
		} else if(isPromoteAction || isDemoteAction || isPromote) {
		    showReviewerCommentsReqAlert = !hasReviewerCommnets;
		    String isCommentRequired              = EnoviaResourceBundle.getProperty(context,"emxComponents.Routes.EnforceOwnerReviewComments");
		    if("false".equals(isCommentRequired)){
				showReviewerCommentsReqAlert = false;
		    }
		    
		    StringBuffer buffer = new StringBuffer();
			buffer.append("../components/emxChangeTaskStateProcess.jsp?");
			buffer.append("promote=").append(isPromoteAction ? "Promote" : "Demote").append('&');
			buffer.append("taskId=").append(XSSUtil.encodeForURL(context,objectId)).append('&');
			buffer.append("routeId=").append(XSSUtil.encodeForURL(context,strRouteId)).append('&');
		    pageAction = buffer.toString();
		}
		if(showCommentsReqAlert) {
			StringBuffer buffer = new StringBuffer();
			buffer.append("../common/emxForm.jsp?form=APPInboxTaskEditForm&mode=edit");
			buffer.append("&formHeader=emxComponents.TaskDetails.EditTaskDetails");
			buffer.append("&HelpMarker=emxhelptaskproperties&showPageURLIcon=false");
			buffer.append("&Export=false&findMxLink=false&summaryPage=").append(fromSummaryPage);
			if(!isPromote)buffer.append("&postProcessJPO=emxInboxTask:updateTaskDetails");
			buffer.append("&submitAction=refreshCaller&suiteKey=Components&objectBased=false");
			if(!"true".equals(fromSummaryPage))buffer.append("&submitLabel=").append(submitLabel);
			buffer.append("&postProcessURL=").append(pageAction).append("&objectId=").append(XSSUtil.encodeForURL(context,objectId));
			pageAction = buffer.toString();
		} else {
		pageAction = showFDAWindow ? com.matrixone.apps.domain.util.XSSUtil.encodeForURL(pageAction) : pageAction;
	}
	}
%>
<script language="Javascript" >
	var canProceed = true;
	//XSSOK
	var showSlidein = <%=showCommentsReqAlert%>;
	<framework:ifExpr expr="<%=!canTaskCompleted%>">
		canProceed = false;
		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.CanNotPromoteTask</emxUtil:i18nScript>");
	</framework:ifExpr>	  	
	//XSSOK
	<framework:ifExpr expr="<%=isTaskCompleted%>">
	    canProceed = false;
	    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.LifeCycle.CannotPerformeOperationOnCompletedTasks</emxUtil:i18nScript>");
    </framework:ifExpr>	
<framework:ifExpr expr="<%=isTaskToBeAccepted%>">
	    canProceed = false;
	    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.LifeCycle.CannotPerformeOperationOnToBeAcceptedTasks</emxUtil:i18nScript>");
    </framework:ifExpr>	

	//XSSOK
	<framework:ifExpr expr="<%=isFDAWindow%>">
		canProceed = false;
		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.ErrorProvideComments</emxUtil:i18nScript>");
	</framework:ifExpr>
	<framework:ifExpr expr="<%=isRouteStopped%>">
		canProceed = false;
		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Task.RouteStopped</emxUtil:i18nScript>");
	</framework:ifExpr>
		//XSSOK
	<framework:ifExpr expr="<%=canTaskCompleted%>">
		//XSSOK	
		<framework:ifExpr expr="<%=showReviewerCommentsReqAlert%>">
			canProceed = false;
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.EditReviewComments</emxUtil:i18nScript>");
		</framework:ifExpr>
		//XSSOK
		<framework:ifExpr expr="<%=showFDAWindow%>">
			canProceed = false;
			//XSSOK
			showModalDialog("../common/emxRoutesFDAUserAuthenticationDialog.jsp?pageAction=<%=pageAction%>", null, null, true, 'Small');
		</framework:ifExpr>
		
		<framework:ifExpr expr="<%=notShowFDAWindow%>">
		canProceed = false;
		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDetails.AlertNotResposibleRole</emxUtil:i18nScript>");
		</framework:ifExpr>
		if(canProceed) {
			var contentFrame = findFrame(parent, "listHidden");
			if(contentFrame == null || contentFrame == 'undefined')
				contentFrame = findFrame(parent, "formViewHidden");
			if(showSlidein) {
				//XSSOK
			contentFrame.getTopWindow().showSlideInDialog("<%=pageAction%>");
			} else {
				//XSSOK
				submitWithCSRF("<%=pageAction%>", contentFrame);
		}
		}
	</framework:ifExpr>	  	
  </script>
  </body>
  </html>


<%--  emxLifecycleTaskReassignProcess.jsp   -   Process page for the reassign functionality in Approvals table under adv. lifecycle page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskReassignProcess.jsp.rca 1.6.3.2 Wed Oct 22 15:48:24 2008 przemek Experimental przemek $
--%>
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.common.*"%>
<%@page import="com.matrixone.apps.common.Person" %>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<!-- Page display code here -->
<%
    try {
          ContextUtil.startTransaction(context, true);

          String taskInfo                   =   emxGetParameter(request, "taskInfo");
          String sTaskNewAssignee           =   emxGetParameter(request, "txtAssignee");
          String sNotificationComment       =   emxGetParameter(request, "notificationComment");
          String strSearchType              =   emxGetParameter(request, "searchType");

          String objectId ="";
          String strStateName ="";
          String strSignatureName ="";
          String taskId ="";
          String strNotificationComment="";
          StringList arrTaskInfo= null;

          boolean isBusinessObject = false;

          arrTaskInfo = FrameworkUtil.split(taskInfo,",");
          Lifecycle lifecycle = new Lifecycle();

           for(int i=0; i<arrTaskInfo.size();i++){
                 String tempParentId  = (String) arrTaskInfo.get(i);
                 StringList slParam   =  FrameworkUtil.split(tempParentId,"^");
                 objectId             = (String) slParam.get(0); //Object Id
                 strStateName         = (String) slParam.get(1); // State Name
                 strSignatureName     = (String) slParam.get(2); //Signature Name
                 taskId               = (String) slParam.get(3); //Task Id
                 //check for the active task
                 if(!UIUtil.isNullOrEmpty(taskId)){
                   isBusinessObject = "true".equalsIgnoreCase(MqlUtil.mqlCommand(context, "print bus $1 select $2 dump",true,taskId,"exists"));
                 }
              
                 //If task is active then send the comment otherwise comment will not be send
                 if (isBusinessObject){
                     strNotificationComment=sNotificationComment;
                 }
                 else{
                     strNotificationComment="";
                 }
                 //Call the reassign method
                 int retValue = lifecycle.reassignTask(context,
                                objectId,
                                strStateName,
                                taskId,
                            	strSearchType,
                                sTaskNewAssignee,
                                strNotificationComment);

                 //If error in the method then abort the transaction
                 if(retValue == 1){
                     ContextUtil.abortTransaction(context);
                     break;
                 }

          }
         ContextUtil.commitTransaction(context);

    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);
         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

    <script language="javascript">
        // Refresh the parent page
       parent.window.location.href = parent.window.location.href;
    </script>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>

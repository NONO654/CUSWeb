<%--  emxLifecycleTasksMassApprovalProcess.jsp   -   Process page which performs the operation from mass approval dialog page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTasksMassApprovalProcess.jsp.rca 1.6.3.2 Wed Oct 22 15:48:41 2008 przemek Experimental przemek $
--%>
<%@ page import = "matrix.db.*, matrix.util.*,
                   com.matrixone.util.*,
                   com.matrixone.servlet.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.domain.util.*, 
                   com.matrixone.apps.domain.*, 
                   java.io.*, 
                   java.util.*"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
    // Context is set in request object in table edit process page
    Context context = (Context)request.getAttribute("context");

    // get the timeStamp from the incoming HttpRequest 
    String timeStamp = (String) emxGetParameter(request,"timeStamp"); 
 
    // define the table bean 
%> 
    <jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/> 
<% 
    HashMap tableDataMap = null;
	String strAlertMessage   = null;

    try {
        // get the tableDataMap and the requestMap from the table bean 
        tableDataMap = (HashMap) tableBean.getTableData(timeStamp);
        MapList objectList = (MapList) tableBean.getObjectList(tableDataMap);
        Map requestMap = (Map) tableBean.getRequestMap(tableDataMap); 
        
        String strValidApprovalStatusAction = null;
        String strApprovalStatusAction = null;
        String strComments       = null;
        String strSerialNumber   = null;
        String strSignature      = null;
        String strLanguage       = (String) requestMap.get("languageStr"); 
        double dblClientTimezone = Double.parseDouble((String) requestMap.get("timeZone")); 
        StringBuffer strAlertMsgs = new StringBuffer(64);
        
        Map mapCurrObject        = null;
        String strTaskId         = null;
        String strParentObjectId = null;
        String isFDAEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");
        String i18NReadAndUnderstand = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),
		"emxFramework.UserAuthentication.ReadAndUnderstand");
        
        final String SELECT_ATTRIBUTE_ROUTE_ACTION = "attribute["+DomainObject.ATTRIBUTE_ROUTE_ACTION +"]";
        
        final String ACTION_NO_ACTION = "No Action";
        final String ACTION_ACCEPT    = "Accept";
        final String ACTION_IGNORE    = "Ignore";
        final String ACTION_APPROVE   = "Approve";
        final String ACTION_REJECT    = "Reject";
        final String ACTION_ABSTAIN   = "Abstain";
        final String ACTION_COMPLETE  = "Complete";
        
        final String VALID_APPROVAL_STATUS_IT_ACCEPT    = "IT-Accept";
        final String VALID_APPROVAL_STATUS_IT_APPROVE   = "IT-Approve";
        final String VALID_APPROVAL_STATUS_IT_COMPLETE  = "IT-Complete";
        final String VALID_APPROVAL_STATUS_WBS_COMPLETE = "WBS-Complete";
        final String VALID_APPROVAL_STATUS_SIGN_APPROVE = "Sign-Approve";
        
        i18nNow loc = new i18nNow();
        final String RESOURCE_BUNDLE = "emxComponentsStringResource";
        
        final String ALERT_COMMENTS_ARE_MANDATORY           = (String)loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.Alert.CommentsAreMandatory");
        final String ALERT_COMMENTS_BUT_NOT_APPROVAL_STATUS = (String)loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.Alert.CommentsButNoApprovalStatus");
        final String ALERT_SELECT_ATLEAST_ONE_OBJECT 		= (String)loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.EditAllTasks.SelectOneObj");
        final String ALERT_APPROVAL_STATUS_INVALID 		= (String)loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.Alert.ApprovalStatusInvalid");
        
	    int count = 0;
	    boolean ignoreCommentsForITApproveAction = false;
	    boolean ignoreCommentsForITRejectAction = false;
	    try {
            //If this is IT-Approve Task and action is approve, comments are not mandatory when
            //emxComponents.Routes.ShowCommentsForTaskApproval=false

            //If this is IT-Approve Task and action is reject, comments are not mandatory when
            //emxComponentsRoutes.InboxTask.IgnoreComments=true
		   
	        ignoreCommentsForITApproveAction = "false".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxComponents.Routes.ShowCommentsForTaskApproval"));
	        ignoreCommentsForITRejectAction = "true".equalsIgnoreCase(EnoviaResourceBundle.getProperty(context, "emxComponentsRoutes.InboxTask.IgnoreComments"));		    
	    } catch(Exception e) {}
	    
        
		ContextUtil.startTransaction(context,true);
        for (Iterator itrObjectList = objectList.iterator(); itrObjectList.hasNext();) {
            mapCurrObject = (Map)itrObjectList.next();
            
            strSerialNumber              = (String)mapCurrObject.get("serialNumber");
            strValidApprovalStatusAction = (String)mapCurrObject.get("ValidApprovalStatusAction");
            strTaskId                    = (String)mapCurrObject.get(DomainObject.SELECT_ID);
            strParentObjectId            = (String)mapCurrObject.get("parentObjectId");
            
            strApprovalStatusAction = emxGetParameter(request, "Approval Status" + strSerialNumber);
            strComments             = emxGetParameter(request, "Comments" + strSerialNumber);
			            
            if (strApprovalStatusAction == null || "".equals(strApprovalStatusAction) || "null".equals(strApprovalStatusAction)){
                throw new Exception(ALERT_APPROVAL_STATUS_INVALID);
            }
        
            if (strValidApprovalStatusAction == null || "".equals(strValidApprovalStatusAction) || "null".equals(strValidApprovalStatusAction)) {
               count++;
               continue;
            }
            
            //
            // Perform the validation checks
            //
            if (strComments == null || "".equals(strComments)) {
            	if (ACTION_NO_ACTION.equals(strApprovalStatusAction)) {
                    //Skip this task
                    count++;
                    continue;
                }
                //Added or conditions for IR-014366V6R2011
                else if (ACTION_ACCEPT.equals(strApprovalStatusAction)|| VALID_APPROVAL_STATUS_SIGN_APPROVE.equals(strValidApprovalStatusAction)) { 
                    // No comments for Accept operation
                    // Do Nothing
                }
                else if (ACTION_COMPLETE.equals(strApprovalStatusAction) && 
                        (VALID_APPROVAL_STATUS_WBS_COMPLETE.equals(strValidApprovalStatusAction))) { // No comments for Accept operation
                    // Do Nothing, No comments reqd. while completing WBS task
                }
                else if(VALID_APPROVAL_STATUS_IT_APPROVE.equals(strValidApprovalStatusAction) || 
	                       ((ACTION_APPROVE.equals(strApprovalStatusAction) && ignoreCommentsForITApproveAction) ||
    	    	            (ACTION_ABSTAIN.equals(strApprovalStatusAction) && ignoreCommentsForITApproveAction) || 
        	                (ACTION_REJECT.equals(strApprovalStatusAction) && ignoreCommentsForITRejectAction))) 
                {
                    //If this is IT-Approve Task and action is approve, comments are not mandatory when
                    //emxComponents.Routes.ShowCommentsForTaskApproval=false

                    //If this is IT-Approve Task and action is reject, comments are not mandatory when
                    //emxComponentsRoutes.InboxTask.IgnoreComments=true
                    
                }
               
        
                else {
                    throw new Exception(ALERT_COMMENTS_ARE_MANDATORY);
                }
            }else {
                if (ACTION_NO_ACTION.equals(strApprovalStatusAction)) {
                    throw new Exception(ALERT_COMMENTS_BUT_NOT_APPROVAL_STATUS);
                }
            }
            
            strAlertMessage = null;
            //
            // Perform the actions
            //
            if (ACTION_NO_ACTION.equals(strApprovalStatusAction)) {
		        //Do nothing, skip this object
		        count++;
		        continue;
		    }
			if (VALID_APPROVAL_STATUS_IT_ACCEPT.equals(strValidApprovalStatusAction)) {
			    if (ACTION_ACCEPT.equals(strApprovalStatusAction)) {
			    	MyInboxTask.accept(context, strTaskId);
			    }
			}
			else if (VALID_APPROVAL_STATUS_IT_APPROVE.equals(strValidApprovalStatusAction)) {
			    if (ACTION_APPROVE.equals(strApprovalStatusAction)) {
			        strAlertMessage = MyInboxTask.approve(context, strTaskId, strComments, strLanguage, dblClientTimezone);
		        	if(UIUtil.isNotNullAndNotEmpty(isFDAEnabled) && isFDAEnabled.equals("true"))
				MqlUtil.mqlCommand(context, "Modify bus $1 add history $2 comment $3",false, strTaskId,strApprovalStatusAction,i18NReadAndUnderstand);
			    }
			    else if (ACTION_REJECT.equals(strApprovalStatusAction)) {
			        strAlertMessage = MyInboxTask.reject(context, strTaskId, strComments, strLanguage, dblClientTimezone);
			    	if(UIUtil.isNotNullAndNotEmpty(isFDAEnabled) && isFDAEnabled.equals("true"))
						MqlUtil.mqlCommand(context, "Modify bus $1 add history $2 comment $3",false, strTaskId,strApprovalStatusAction,i18NReadAndUnderstand);
			    }
			    else if (ACTION_ABSTAIN.equals(strApprovalStatusAction)) {
			        strAlertMessage = MyInboxTask.abstain(context, strTaskId, strComments, strLanguage, dblClientTimezone);
			    }
			}
			else if (VALID_APPROVAL_STATUS_IT_COMPLETE.equals(strValidApprovalStatusAction)) {
			    if (ACTION_COMPLETE.equals(strApprovalStatusAction)) {
			        strAlertMessage = MyInboxTask.complete(context, strTaskId, strComments, strLanguage, dblClientTimezone);
			    }
			}
			else if (VALID_APPROVAL_STATUS_WBS_COMPLETE.equals(strValidApprovalStatusAction)) {
			    if (ACTION_COMPLETE.equals(strApprovalStatusAction)) {
			        strAlertMessage = MyProjectTask.complete(context, strTaskId);
			    }
			}
			else if (VALID_APPROVAL_STATUS_SIGN_APPROVE.equals(strValidApprovalStatusAction)) {
			    strSignature = (String)mapCurrObject.get("name");
			    
			    if (ACTION_APPROVE.equals(strApprovalStatusAction)) {
			    	MySignature.approve(context, strParentObjectId, strSignature, strComments);
			    }
			    else if (ACTION_REJECT.equals(strApprovalStatusAction)) {
			        MySignature.reject(context, strParentObjectId, strSignature, strComments);
			    }
			    else if (ACTION_IGNORE.equals(strApprovalStatusAction)) {
			        MySignature.ignore(context, strParentObjectId, strSignature, strComments);
			    }
			}
			
			// Alert message
			if (strAlertMessage != null && !"".equals(strAlertMessage)) {
			    throw new Exception(strAlertMessage);
			}
        }//~for each object parameter
        
        //if non selected count equals the total count then show alert that select atleast one object
        if(count == objectList.size()){
            throw new Exception(ALERT_SELECT_ATLEAST_ONE_OBJECT);
        }
        // Show alerts
        if (strAlertMsgs.length() != 0) {
            throw new Exception(strAlertMsgs.toString());
        }
		ContextUtil.commitTransaction(context);
  } catch (Exception ex) {

		String strExceptionMessage = ex.getMessage().trim();
        if (UIUtil.isNullOrEmpty(strExceptionMessage)) {
            strExceptionMessage = ex.toString().trim();     
        }
		strAlertMessage = strExceptionMessage;
		ContextUtil.abortTransaction(context);		
		%>
		<script type="text/javascript"> 
	<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</script>
	<%}%>
<%!
/**
 * The &lt;code&gt;MyInboxTask&lt;/code&gt; class contains ... methods related to Inbox task
 *
 * @version AEF 11.0.0.0 - Copyright (c) 2005, MatrixOne, Inc.
 */
private static final class MyInboxTask {
    /**
     * Accepts Inbox Task 
     *
     * @param context The Matrix Context object
     * @param strTaskId The id of the task
     * @throws Exception if operation fails
     */
    public static void accept(Context context, String strTaskId) throws Exception {
        // Arguments check
        if (context == null) {
            throw new Exception("Invalid context");
        }
        if (strTaskId == null) {
            throw new Exception("Invalid strTaskId");
        }
        
        com.matrixone.apps.common.InboxTask inboxTaskObject = (com.matrixone.apps.common.InboxTask)DomainObject.newInstance(context, DomainConstants.TYPE_INBOX_TASK);
        inboxTaskObject.setId(strTaskId);
        inboxTaskObject.acceptTask(context);
    }
    
    /**
     * Approves inbox tasks (which are of type Approve)
     * 
     * @param context The Matrix Context object
     * @param strTaskId The id of the task object
     * @param strComments The comments for the task
     * @param strLanguage The language string for forming messages from string resource files
     * @param clientTZOffset The timezone offset of client
     * @return Error message if any
     * @throws Exception if operation fails
     */
    public static String approve(Context context, String strTaskId, String strComments, String strLanguage, double clientTZOffset) throws Exception {
        return performAction(context, "Complete", strTaskId, strComments, strLanguage, clientTZOffset);
    }
    
    /**
     * Rejects inbox tasks (which are of type Approve)
     * 
     * @param context The Matrix Context object
     * @param strTaskId The id of the task object
     * @param strComments The comments for the task
     * @param strLanguage The language string for forming messages from string resource files
     * @param clientTZOffset The timezone offset of client
     * @return Error message if any
     * @throws Exception if operation fails
     */
    public static String reject(Context context, String strTaskId, String strComments, String strLanguage, double clientTZOffset) throws Exception {
        return performAction(context, "Reject", strTaskId, strComments, strLanguage, clientTZOffset);
    }
    
    /**
     * Abstains inbox tasks (which are of type Approve)
     * 
     * @param context The Matrix Context object
     * @param strTaskId The id of the task object
     * @param strComments The comments for the task
     * @param strLanguage The language string for forming messages from string resource files
     * @param clientTZOffset The timezone offset of client
     * @return Error message if any
     * @throws Exception if operation fails
     */
    public static String abstain(Context context, String strTaskId, String strComments, String strLanguage, double clientTZOffset) throws Exception {
        return performAction(context, "Abstain", strTaskId, strComments, strLanguage, clientTZOffset);
    }

    /**
     * Completes inbox tasks (which are not of type Approve)
     * 
     * @param context The Matrix Context object
     * @param strTaskId The id of the task object
     * @param strComments The comments for the task
     * @param strLanguage The language string for forming messages from string resource files
     * @param clientTZOffset The timezone offset of client
     * @return Error message if any
     * @throws Exception if operation fails
     */
    public static String complete(Context context, String strTaskId, String strComments, String strLanguage, double clientTZOffset) throws Exception {
        return performAction(context, "Complete", strTaskId, strComments, strLanguage, clientTZOffset);
    }
    
    /**
     * Performs different operation on inbox tasks
     * 
     * @param context The Matrix Context object
     * @param strAction The action to be taken on the task (Complete, Reject, Abstain)
     * @param strTaskId The id of the task object
     * @param strComments The comments for the task
     * @param strLanguage The language string for forming messages from string resource files
     * @param clientTZOffset The timezone offset of client
     * @return Error message if any
     * @throws Exception if operation fails
     */
    private static String performAction(Context context, String strAction, String strTaskId, String strComments, String strLanguage, double clientTZOffset) throws Exception {
        // Arguments check
        if (context == null) {
            throw new Exception("Invalid context");
        }
        if (strTaskId == null) {
            throw new Exception("Invalid strTaskId");
        }
        if ( !("Complete".equals(strAction) || "Reject".equals(strAction) || "Abstain".equals(strAction)) ) {
            throw new Exception("Invalid strAction '" + strAction + "'");
        }
        
        final String RESOURCE_BUNDLE = "emxComponentsStringResource";
        i18nNow loc = new i18nNow();
        
        String sSubject  = loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.common.TaskDeletionNotice");
        String sMessage1 = loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.common.TaskDeletionMessage3");
        String sMessage2 = loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.common.TaskDeletionMessage2");
        String sMessage3 = loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.Task.RouteStopped");
		String sMessage4 = loc.GetString(RESOURCE_BUNDLE, strLanguage, "emxComponents.Task.TaskCompleted"); 
        
        HashMap appMap = new HashMap();
        appMap.put("emxComponents.common.TaskDeletionNotice", sSubject);
        appMap.put("emxComponents.common.TaskDeletionMessage3", sMessage1);
        appMap.put("emxComponents.common.TaskDeletionMessage2", sMessage2);
        appMap.put("emxComponents.Task.RouteStopped", sMessage3);
		appMap.put("emxComponents.Task.TaskCompleted", sMessage4);  
        com.matrixone.apps.common.UserTask userTask = new com.matrixone.apps.common.UserTask();
        String strMessage = userTask.doInboxTaskAction(context, strTaskId, appMap, strComments, strAction, clientTZOffset);
        
        if ("Abstain".equals(strAction)) {
            // Complete the task, this will by default set Approval Status as Approve, but we want it to be Abstain.
            // Since the behavior of the route and inbox task is similar for Approve and Abstain action, we are reusing the
            // functionality written for Approve task.
            DomainObject dmoTask = new DomainObject(strTaskId);
            dmoTask.setAttributeValue(context, DomainObject.ATTRIBUTE_APPROVAL_STATUS, "Abstain");
        }
        return strMessage;
    }
}//~class MyInboxTask


/**
 * The &lt;code&gt;MyProjectTask&lt;/code&gt; class contains methods related to WBS tasks
 *
 * @version AEF 11.0.0.0 - Copyright (c) 2005, MatrixOne, Inc.
 */
private static final class MyProjectTask {
    /**
     * Completes the project task
     * 
     * @param context The Matrix Context object
     * @param strTaskId The id of the task
     * @return Error message if any
     * @throws Exception if operation fails
     */
    public static String complete(Context context, String strTaskId) throws Exception {
        //   Arguments check
       if (context == null) {
           throw new Exception("Invalid context");
       }
       if (strTaskId == null) {
           throw new Exception("Invalid strTaskId");
       }
       
       com.matrixone.apps.common.UserTask userTask = new com.matrixone.apps.common.UserTask();
       String strMessage = userTask.doWBSTaskAction(context, strTaskId, "Complete");
       return strMessage;
   }
}//~class MyProjectTask

/**
 * The &lt;code&gt;MySignature&lt;/code&gt; class contains methods related to signatures
 *
 * @version AEF 11.0.0.0 - Copyright (c) 2005, MatrixOne, Inc.
 */
private static final class MySignature {
    /**
     * Approves the signature
     * 
     * @param context The Matrix Context object
     * @param strObjectId The id of the task object
     * @param strSignature The signature name
     * @param strComments The comments for the signature action
     * @throws Exception if operation fails
     */
    public static void approve(Context context, String strObjectId, String strSignature, String strComments) throws Exception {
        performAction(context, strObjectId, strSignature, "Approve", strComments);
    }
    
    /**
     * Rejects the signature
     * 
     * @param context The Matrix Context object
     * @param strObjectId The id of the task object
     * @param strSignature The signature name
     * @param strComments The comments for the signature action
     * @throws Exception if operation fails
     */
    public static void reject(Context context, String strObjectId, String strSignature, String strComments) throws Exception {
        performAction(context, strObjectId, strSignature, "Reject", strComments);    
    }
    
    /**
     * Ignores the signature
     * 
     * @param context The Matrix Context object
     * @param strObjectId The id of the task object
     * @param strSignature The signature name
     * @param strComments The comments for the signature action
     * @throws Exception if operation fails
     */
    public static void ignore(Context context, String strObjectId, String strSignature, String strComments) throws Exception {
        performAction(context, strObjectId, strSignature, "Ignore", strComments);
    }
    
    /**
     * Performs different actions on signature
     *
     * @param context The Matrix Context object
     * @param strObjectId The id of the task object
     * @param strSignature The signature name
     * @param strAction The action to be taken on signature
     * @param strComments The comments for the signature action
     * @throws Exception if operation fails
     */
    private static void performAction(Context context, String strObjectId, String strSignature, String strAction, String strComments) throws Exception {
        // Argument check
        if (context == null) {
            throw new Exception("Invalid context");
        }
        if (strObjectId == null || "".equals(strObjectId.trim())) {
            throw new Exception("Invalid strObjectId");
        }
        if (strSignature == null || "".equals(strSignature.trim())) {
            throw new Exception("Invalid strSignature");
        }
        if ( !("Approve".equals(strAction) || "Reject".equals(strAction) || "Ignore".equals(strAction)) ) {
            throw new Exception("Invalid strAction '" + strAction + "'");
        }
        if (strComments == null) {
            strComments = "";
        }
        String sAct = strAction.toLowerCase();
   //     String strMQL = strAction.toLowerCase() + " bus " + strObjectId + " signature \"" + strSignature + "\" comment \"" + strComments + "\"";
        String strMQL = "$1 bus $2 signature $3 comment $4";
        MqlUtil.mqlCommand(context, strMQL, false,sAct,strObjectId,strSignature,strComments);
    }
}//~class MySignature
%>

<script language="javascript" type="text/javascript" >
//earlier only taskchannelframe was getting refreshed
//so refreshing entire portalframe. same is used in
//emxLifecycleApproveRejectProjess.jsp 
if("<%=UIUtil.isNotNullAndNotEmpty(strAlertMessage)%>" != "true"){

	try { 
		 portalFrame = openerFindFrame(getTopWindow(),"detailsDisplay");
	    } catch(e) {}
		   
	   if(portalFrame!=null) {
	  portalFrame.document.location.href = portalFrame.document.location.href;
  }else{
	  getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
	  } 	
	  	
}
</script>



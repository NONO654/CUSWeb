<%--  emxLifecycleRemoveApproverProcess.jsp    -  Performs the task to invoke Remove Selected Approver functionality.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleRemoveApproverProcess.jsp.rca 1.6.3.2 Wed Oct 22 15:48:16 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>


<!-- Java script functions -->

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%@ page import = "com.matrixone.apps.common.Lifecycle" %>
<!-- Page display code here -->

<%
    try {
	    String jsTreeID = emxGetParameter(request,"jsTreeID");
	    String suiteKey = emxGetParameter(request,"suiteKey");
	    
	    // Get the id of the object in context
	    String strParentobjectId = emxGetParameter(request,"objectId");
	    
	    // Get all the selected tasks/signatures
	    String[] emxTableRowIds= emxGetParameterValues(request,"emxTableRowId");
	    
	    final String POLICY_INBOX_TASK_STATE_COMPLETE = PropertyUtil.getSchemaProperty(context, "Policy", DomainObject.POLICY_INBOX_TASK, "state_Complete");
	    final String SELECT_REL_ATTRIBUTE_ROUTE_NODE_ID = DomainRelationship.getAttributeSelect(DomainObject.ATTRIBUTE_ROUTE_NODE_ID);
	    final String SELECT_ATTRIBUTE_ROUTE_NODE_ID = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_NODE_ID + "]";
	    final String SELECT_REL_ATTRIBUTE_ROUTE_TASK_USER = DomainRelationship.getAttributeSelect(DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
	    final String SELECT_ROUTE_ID_FROM_TASK = "from[" + DomainObject.RELATIONSHIP_ROUTE_TASK + "].to.id";
	    final String STRING_SUBJECT = "${TYPE} &{NAME} " + EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.DeleteRoute.DeleteNotification", context.getLocale()); 
	    
	    String emxTableRowId = "";
	    String strSignatureName = null;
	    String strParentState = null;
	    String strTaskId = null;
	    String strCurrentTaskState = null;
	    DomainObject dmoRoute = null;
	    MapList mlDefinedTasksOnRoute = null;
        StringList slParameters = null;
        Lifecycle lifecycle = new Lifecycle();
	    
        ContextUtil.startTransaction(context, true);
        
        // Iterator on each selected task/signature
	    for(int i=0;i<emxTableRowIds.length;i++) {
	        emxTableRowId = emxTableRowIds[i];
	        
	        // <object>^<state>^<signature>^<taskid> => [<object>, <state>, <signature>, <taskid>] (list)
	        slParameters = FrameworkUtil.split(emxTableRowId,"^");
	        if (slParameters == null || slParameters.isEmpty() || slParameters.size() < 4) {
	            continue;
	        }
	        
            strParentState = (String)slParameters.get(1);
            strSignatureName = (String)slParameters.get(2);
            strTaskId = (String)slParameters.get(3);
            
            // Signatures cannot be removed
	        if( strSignatureName != null && !"".equals(strSignatureName.trim()) && !"null".equals(strSignatureName.trim())){
	            throw new Exception(FrameworkUtil.i18nStringNow("emxFramework.Alert.InvalidActionForSignatures", lStr));
	        }
	        else {
	            // Skip the invalid task id
	            if(strTaskId == null || "".equals(strTaskId.trim()) || "null".equals(strTaskId.trim()) ) {
	                continue;
	            }
                lifecycle.removeApproverTask(context, strParentobjectId, strParentState, strSignatureName, strTaskId);
	        }//if non-signature type
	    }//for
%>
		<script language="javascript">
			if(getTopWindow().findFrame(getTopWindow(),"AEFLifecycleApprovals")){
				getTopWindow().findFrame(getTopWindow(),"AEFLifecycleApprovals").location.href = getTopWindow().findFrame(getTopWindow(),"AEFLifecycleApprovals").location.href;
			}else{
				window.parent.location.href = window.parent.location.href;
			}
		</script>
<%        
		ContextUtil.commitTransaction(context);

    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);
		String sErrorMsg = ex.getMessage();
		if (sErrorMsg.contains("#5000001")){
			int pos = sErrorMsg.indexOf("#5000001:");
			if (pos > -1){
				sErrorMsg = sErrorMsg.substring(pos+9).trim(); 
			}
		}
%>
		
        <script language="javascript">
        	//XSSOK
			alert("<%=FrameworkUtil.findAndReplace(sErrorMsg ,"\n", "\\\n")%>");
        </script>
<%
    } 
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

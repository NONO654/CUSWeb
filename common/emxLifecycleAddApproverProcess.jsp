<%--  emxLifecycleAddApproverProcess.jsp   -   Process page for Add Approver fuctionality

    Dassault Systemes, 1993  2007. All rights reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverProcess.jsp.rca 1.5.3.2 Wed Oct 22 15:48:29 2008 przemek Experimental przemek $
--%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import = "com.matrixone.apps.common.Lifecycle" %>
<script language="javascript">
	function refreshParent() {
		var lifeCycleFrame = getTopWindow().opener.getTopWindow().findFrame(getTopWindow().opener.getTopWindow(), "AEFLifecycleBasic");
		var approvalsTab = getTopWindow().opener;
		if(lifeCycleFrame) {
			lifeCycleFrame.location.href = lifeCycleFrame.location.href;
		}
		if(approvalsTab) {
			approvalsTab.location.href =approvalsTab.location.href;
		}
		if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader) {
			getTopWindow().opener.getTopWindow().RefreshHeader();
		}
	}
	function closeWindow() {
		getTopWindow().closeWindow();
	}
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<%
	boolean isError = false;
	String strActionType = emxGetParameter(request, "actionType");
	String strParentObjectState = emxGetParameter(request, "state");
	String strApprover = emxGetParameter(request, "approver");
	String strInstructions = emxGetParameter(request, "instructions");
	String strParentObjId = emxGetParameter(request, "objectId");
		
	String strTitle = emxGetParameter(request, "title");
	String strRouteAction = emxGetParameter(request, "action");

	String strDueDateOption = emxGetParameter(request, "dueDateOption");
	String strDueDate = emxGetParameter(request, "dueDate");//milliseconds
	String strDueDateOffset = emxGetParameter(request, "dueDateOffset");
	String strDueDateOffsetFrom = emxGetParameter(request, "dueDateOffsetFrom");
	// To get enovia preference Due date //
	String strDueDatePref = emxGetParameter(request, "dueDate_Date");
	String strStartTimePref = emxGetParameter(request, "dueDate_Time");
	double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
	String strDueDateTimePref = "";
	if(UIUtil.isNotNullAndNotEmpty(strDueDatePref)){
		strDueDateTimePref = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDateTime(context,strDueDatePref,strStartTimePref,clientTZOffset,request.getLocale());
	}
	 
	String strAllowDelegation = emxGetParameter(request, "allowDelegation");
	String strRequiresOwnerReview = emxGetParameter(request, "requiresOwnerReview");

	//Begin Bug #345799: Type Ahead Implementation
	String strHiddenValue =  emxGetParameter(request, "approverType");
	String StrApproverType = "";
	StringList slHiddenValue = FrameworkUtil.split(strHiddenValue, "-");
	if (slHiddenValue != null && slHiddenValue.size() > 0) {
	    StrApproverType = (String)slHiddenValue.get(0);	    
	}
	//End Bug #345799: Type Ahead Implementation
	
	try {
        Lifecycle lifecycle = new Lifecycle();
        lifecycle.addApproverTask(context,
                strParentObjId,
                strParentObjectState,
                StrApproverType,
                strApprover,
                strInstructions,
                strTitle,
                strRouteAction,
                strDueDateOption,
                strDueDateTimePref,
                strDueDateOffset,
                strDueDateOffsetFrom,
                strAllowDelegation,
                strRequiresOwnerReview);
%>
              
  <!-- Bug #345799: Type Ahead Implementation -->
<%
				//
				// Get the type ahead saved limit from emxSystem.properties
				//
				String strTypeAheadSaveLimit = null;
				try {
				    strTypeAheadSaveLimit = FrameworkProperties.getProperty(context, "emxFramework.TypeAhead.SavedValuesLimit");
				    Integer.parseInt(strTypeAheadSaveLimit);
				}
				catch (Exception exp) {
				    strTypeAheadSaveLimit = "10";
				}
%>	
				<!-- //XSSOK -->
				<emxUtil:saveTypeAheadValues context="<%=context%>" form="formAddApprover" field="approver" displayFieldValue="<%=XSSUtil.encodeForXML(context, strApprover)%>" hiddenFieldValue="<%=XSSUtil.encodeForXML(context, strHiddenValue)%>" count="<%=strTypeAheadSaveLimit%>"/>
                
                <emxUtil:commitTypeAheadValues context="<%=context%>" />
	<!-- Bug #345799: Type Ahead Implementation -->
              
		
<%
    } catch (Exception ex) {
        isError = true;
        emxNavErrorObject.addMessage(ex.getMessage());
        ex.printStackTrace();
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>
    <script language="javascript">
			if (getTopWindow().turnOffProgress) {
				getTopWindow().turnOffProgress();
			}
    </script>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<%@include file="../emxUICommonEndOfPageInclude.inc"%>

	<script language="javascript">
<%
	// The page to close or not is decided here. The process JPO can give error alerts which
	// will be visible if these above includes files code is executed. Therefore the window
	// is closed here at the end of page. If there is any exception in page we shall not close
	// the dialog window.
	if ("Done".equals(strActionType)) {
	    if (!isError) {
%>
			refreshParent();
			closeWindow();
<%
	    }
	}
	else {
%>
		refreshParent();
<%
	}
%>
	</script>

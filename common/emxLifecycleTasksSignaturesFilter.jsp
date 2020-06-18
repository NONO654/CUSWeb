<%--  emxLifecycleTasksSignaturesFilter.jsp   -   It will present the filter page for the Tasks/Signature tab under advance lifecycle page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTasksSignaturesFilter.jsp.rca 1.4.3.3 Tue Oct 28 22:59:39 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<script type="text/javascript">
       addStyleSheet("emxUIToolbar");
       addStyleSheet("emxUIDefault");
       addStyleSheet("emxUIList");
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<!-- Page display code here -->

<%
    try {
        // Get the table id
        String strTableId = emxGetParameter(request, "tableID");
        
        // Get the request parameters from table bean and find the object id
        HashMap mapReqParam = tableBean.getRequestMap(strTableId);
        String strObjectId = (String)mapReqParam.get("objectId");
        //Added for bug 358111
		langStr = request.getHeader("Accept-Language");
        
        // Find the type of object
        DomainObject dmoObject = new DomainObject(strObjectId);
        String strType = dmoObject.getInfo(context, DomainObject.SELECT_TYPE);
        boolean isConfigurableParameterProvided = isConfigurableParameterProvided(context, strType);
%>
<form name="formFilter"
	action="emxLifecycleTasksSignaturesFilterProcess.jsp"
	target="listHidden" method="post"><%
		// Append all the request parameters
		Enumeration requestParameters = emxGetParameterNames(request);
		String strParamName = null;
		String strParamValue = null;
		while (requestParameters.hasMoreElements()) {
			strParamName = (String)requestParameters.nextElement();
			strParamValue = emxGetParameter(request, strParamName);
%> <input type="hidden" name="<%=XSSUtil.encodeForHTML(context, strParamName)%>"
	value="<xss:encodeForHTMLAttribute><%=strParamValue%></xss:encodeForHTMLAttribute>" /> <%		 
		}
		
		// Get some strings
		final String RESOURCE_BUNDLE 							= "emxFrameworkStringResource";
		Locale locale 											= context.getLocale();
		final String STRING_SHOW 								= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.FilterLabel.Show");
		final String STRING_APPROVAL_STATUS						= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.FilterLabel.ApprovalStatus");
		final String STRING_INCLUDE 							= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.FilterLabel.Include");
		final String STRING_FILTER_MY_APPROVAL					= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.MyApprovals");
		final String STRING_FILTER_ALL_APPROVALS				= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.AllApprovals");
		final String STRING_FILTER_ALL 							= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.All");
		final String STRING_FILTER_PENDING 						= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.Pending");
		final String STRING_FILTER_COMPLETED	 				= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.Completed");
		final String STRING_FILTER_CURRENT_OBJECT 				= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.CurrentObject");
		final String STRING_FILTER_CURRENT_AND_RELATED_TASKS	= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Filter.CurrentAndRelatedTasks");
		final String STRING_FILTER 								= EnoviaResourceBundle.getProperty(context, RESOURCE_BUNDLE, locale, "emxFramework.LifecycleTasks.Button.Filter");		
		
		// Draw the filter bar
%>
<div id="divToolbar" class="toolbar-container">
<div id="divToolbar" class="toolbar-frame">
<table style="width:auto">
	<tr>
		<td style="padding-right: 5px;"><%=XSSUtil.encodeForHTML(context, STRING_SHOW) %>:</td>
		<td style="padding-right: 5px;">
			<select name="showFilter">
				<option value="All Approvals" selected><%=XSSUtil.encodeForHTML(context, STRING_FILTER_ALL_APPROVALS) %></option>
				<option value="My Approvals"><%=XSSUtil.encodeForHTML(context, STRING_FILTER_MY_APPROVAL) %></option>
			</select>
		</td>
		<td style="padding-right: 5px;"><%=XSSUtil.encodeForHTML(context, STRING_APPROVAL_STATUS) %>:</td>
		<td style="padding-right: 5px;">
			<select name="approvalStatusFilter">
				<option value="All" selected><%=XSSUtil.encodeForHTML(context, STRING_FILTER_ALL) %></option>
				<option value="Pending"><%=XSSUtil.encodeForHTML(context, STRING_FILTER_PENDING) %></option>
				<option value="Completed"><%=XSSUtil.encodeForHTML(context, STRING_FILTER_COMPLETED) %></option>
			</select>
		</td>
<%
		if (isConfigurableParameterProvided) {
%>
		<td><%=STRING_INCLUDE %>:</td>
		<td><select name="includeFilter">
			<option value="Current Object"><%=XSSUtil.encodeForHTML(context, STRING_FILTER_CURRENT_OBJECT) %></option>
			<option value="Current and Related Tasks" selected><%=XSSUtil.encodeForHTML(context, STRING_FILTER_CURRENT_AND_RELATED_TASKS) %></option>
		</select></td>
<%
		}
%>
		<td><input type="submit" value="<xss:encodeForHTMLAttribute><%=STRING_FILTER%></xss:encodeForHTMLAttribute>" /></td>
	</tr>
</table>
</div>
</div>
</form>
<%
            // Do something here
    } catch (Exception ex) {
         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
         ex.printStackTrace();
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>

<%!
	/**
	 * Checks if the configurable parameters for the Task/Signature table page functionality is provided
	 * There are 3 configurable parameters for the type of the object namely relationship,
	 * direction and level. These will be stored as property in central properties file.
	 * The template for forming this property key is as follows
	 * <type>.relatedObjects.parameters=<symbolic relationship name>|<direction>|<level>,...
	 * 
	 * @param context The Matrix Context object
	 * @param strType The type of the object
	 * @return true if the configurable parameters are provided otherwise false is returned
	 * @throws Exception if operation fails
	 */
	public static boolean isConfigurableParameterProvided(Context context, String strType) throws Exception {
		try {
		    com.matrixone.apps.common.Lifecycle lifecycle = new com.matrixone.apps.common.Lifecycle();
	        Map mapConfParams = lifecycle.getConfigurableParameters(context, strType);
	        
	        return (mapConfParams != null);
		}
	    catch(Exception exp) {
	        exp.printStackTrace();
	        throw exp;
	    }
	}
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
<script language="javascript">
	window.document.body.style.marginLeft = "0px";
	window.document.body.style.marginRight = "0px";
</script>

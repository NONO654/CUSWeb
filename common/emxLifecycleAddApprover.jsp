<%--  emxLifecycleAddApprover.jsp   -   <description>

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApprover.jsp.rca 1.11.3.2 Wed Oct 22 15:48:45 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.lifecycle.LifeCyclePolicyDetails"%>


<!-- Bug #345799: Type Ahead Implementation -->
  <script language="javascript" src="../common/scripts/emxTypeAhead.js"></script>
<!-- Bug #345799: Type Ahead Implementation -->


<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<%
	String strParentObjectId = emxGetParameter(request, "objectId");
%>
<!-- Java script functions -->

<script language="JavaScript">

    function submitForm() {
    	var objForm = document.formAddApprover;

        //checking for not selecting Approver
        if(objForm.approver.value == ""){
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Alert.SelectApprover</emxUtil:i18nScript>");
              objForm.approver.focus();
              return;
        }
        //Checking for empty Title and Bad Characters
        if(trim(objForm.title.value).length  == 0){
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Alert.EnterTitle</emxUtil:i18nScript>");
              objForm.title.focus();
              return;
        }
        var namebadCharDescrption = checkForBadChars(objForm.title);
        if (namebadCharDescrption.length != 0){
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
              objForm.title.focus();
              return;
        }

        //Checking for empty Instructions and Bad Characters
        if(trim(objForm.instructions.value).length  == 0){
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Alert.EnterInstructions</emxUtil:i18nScript>");
              objForm.instructions.focus();
              return;
        }
        var namebadCharDescrption = checkForBadChars(objForm.instructions);
        if (namebadCharDescrption.length != 0){
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxFramework.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
              objForm.instructions.focus();
              return false;
        }

    	//Check for due date
    	var arrDueDateOption = objForm.elements["dueDateOption"];

    	// If due date is selected
    	for (var i = 0; i < arrDueDateOption.length; i++) {
    		var objDueDateOption = arrDueDateOption[i];

    		if (objDueDateOption.checked) {
    			if (objDueDateOption.value == "dueDateSet") {
    				if (objForm.dueDate_Date.value == "") {
    					alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.EnterDueDate</emxUtil:i18nScript>");
    					calendarIcon_onclick('formAddApprover','dueDate_Date');
			    		return;
    				}
    				else {
    					// Add the selected time into selected date
    					var theDueDate = new Date();
    					theDueDate.setTime(objForm.dueDate_Date_msvalue.value);
    					theDueDate.setHours(0);
    					theDueDate.setMinutes(0);
    					theDueDate.setSeconds(0);

    					var strHourMins = objForm.dueDate_Time.value;//HH:mm
    					var arrHourMins = strHourMins.split(":");

    					theDueDate.setHours(arrHourMins[0]);
    					theDueDate.setMinutes(arrHourMins[1]);

			    		if (!validateDueDate(theDueDate.getTime())) {
			    			alert("<emxUtil:i18nScript localize="i18nId">emxFramework.RouteDueDate.PastDate</emxUtil:i18nScript>");
			    			calendarIcon_onclick('formAddApprover','dueDate_Date');
			    			return;
			    		}

			    		// Set the value to be submitted
			    		objForm.dueDate.value = theDueDate.getTime();
			    	}
    			}
    			else if (objDueDateOption.value == "dueDateOffsetSet") {
    				if (objForm.dueDateOffset.value == "" || isNaN(objForm.dueDateOffset.value) || !(1 <= objForm.dueDateOffset.value && objForm.dueDateOffset.value <= 365 )) {
						alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.EnterDueDateOffset</emxUtil:i18nScript>");
    					objForm.dueDateOffset.focus();
    					return;
    				}
    			}
    			else if (objDueDateOption.value == "assigneeSetDueDateSet") {
    				// Do nothing
    			}
    		}
    	}

    	if (getTopWindow().turnOnProgress) {
        	getTopWindow().turnOnProgress();
        }
        
		//Begin Bug #345799: Type Ahead Implementation        
		// While saving the Approver display and hidden value, type ahead
		// ensures that hidden value is unique. Therefore we shall append
		// display name (say) to make it unique, and this will be splitted 
		// appropriately in process page.
		var strDisplayValue = objForm.approver.value;
		var strHiddenValue = document.querySelector('input[name=searchType]:checked').value;
		
		if (strHiddenValue.indexOf("-") == -1) {
			objForm.approverType.value = strHiddenValue + "-" + strDisplayValue;
		}
		//End Bug #345799: Type Ahead Implementation
        
    	objForm.submit();
    }

    function apply_onclick() {
        var objForm = document.formAddApprover;
        objForm.actionType.value = "Apply";
        submitForm();
    }

    function done_onclick() {
        var objForm = document.formAddApprover;
        objForm.actionType.value = "Done";
        submitForm();
    }

    function cancel_onclick() {
    	getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        getTopWindow().closeWindow();
    }

    function clear_onclick(strFieldName) {
        var objForm = document.formAddApprover;
        if (strFieldName != "") {
            var element = objForm.elements[strFieldName];
            if (element) {
                element.value = "";
            }
        }
    }

    function showSearchWindow(){
    	if(document.querySelector('input[name=searchType]:checked').value == "Person"){
    		showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Person:current=policy_Person.state_Active&submitURL=../components/emxCommonSelectObject.jsp&frameName=pagecontent&formName=formAddApprover&fieldNameActual=approverType&fieldNameDisplay=approver&table=IssueAssigneeList&selection=single&showInitialResult=true");	
    	}else if(document.querySelector('input[name=searchType]:checked').value == "Role"){
    		var strURL = '../common/emxIndentedTable.jsp?selection=multiple&expandLevelFilterMenu=false&customize=false&Export=false&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=false&displayView=details&showPageURLIcon=false&showRMB=false&showClipboard=false&objectCompare=false&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&cancelButton=true&submitURL=../components/emxComponentsChangeAssigneeProcess.jsp&header=emxComponents.AddRoles.SelectRoles&program=emxRoleUtil:getRolesSearchResults&toolbar=APPRoleSearchToolbar&suiteKey=Components&table=APPRoleSummary&fieldNameActual=approverType&fieldNameDisplay=approver&fromPage=addApprover';
    		showModalDialog(strURL);	
    	}else if(document.querySelector('input[name=searchType]:checked').value == "Group"){
    		var strURL = "../common/emxIndentedTable.jsp?table=APPGroupSummary&program=emxGroupUtil:getGroupSearchResults&editLink=false&toolbar=APPGroupSearchToolbar&selection=single&objectCompare=false&HelpMarker=emxhelpselectgroup&header=emxComponents.AddGroups.SelectGroups&displayView=details&multiColumnSort=false&fieldNameActual=approverType&fieldNameDisplay=approver&suiteKey=Components&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&customize=false&submitURL=../components/emxComponentsChangeAssigneeProcess.jsp";
    		showModalDialog(strURL);
    	}else if(document.querySelector('input[name=searchType]:checked').value == "UserGroup"){
    		if(<%=UINavigatorUtil.isCloud(context)%>){
    			showModalDialog("../common/emxFullSearch.jsp?showInitialResults=true&table=AEFUserGroupsChooser&selection=single&form=AEFSearchUserGroupsForm&field=TYPES=type_Group:CURRENT=policy_Person.state_Active&submitURL=../components/emxCommonSelectObject.jsp&frameName=pagecontent&formName=formAddApprover&fieldNameActual=approverType&fieldNameDisplay=approver&HelpMarker=emxhelpsearch&source=usersgroup&rdfQuery=type:foaf:Group");
    		}else{
    			showModalDialog("../common/emxFullSearch.jsp?showInitialResults=true&table=AEFUserGroupsChooser&selection=single&form=AEFSearchUserGroupsForm&field=TYPES=type_Group:CURRENT=policy_Person.state_Active&submitURL=../components/emxCommonSelectObject.jsp&frameName=pagecontent&formName=formAddApprover&fieldNameActual=approverType&fieldNameDisplay=approver&HelpMarker=emxhelpsearch");
        	}
    	}
    }

    function validateDueDate(milliSecondsValue)
    {
        var toDayDate = new Date();
        toDayDate.setDate(toDayDate.getDate());

        var enteredDate = new Date();
        enteredDate.setTime(milliSecondsValue);

        if (enteredDate.getFullYear() < 1950) {
            enteredDate.setFullYear(enteredDate.getFullYear() + 100);
        }

        if (Date.parse(enteredDate.toGMTString()) < Date.parse(toDayDate.toGMTString()) ) {
            return false;
        }
        else {
            return true;
        }
    }

    function submitNewAssignee(objSearchWindow, strAssigneeName, strAssigneeType) {

    	// We no more need this window
    	if (objSearchWindow) {
    		objSearchWindow.closeWindow();
    	}

    	document.formAddApprover.approver.value = strAssigneeName;
    	document.formAddApprover.approverType.value = strAssigneeType;

    }

    function clearDueDate_onclick() {
    	var objForm = document.forms["formAddApprover"];
    	if (objForm) {
    		if (objForm.elements["dueDate_Date"]) {
    			objForm.elements["dueDate_Date"].value = "";
    		}
    		if (objForm.elements["dueDate_Date_msvalue"]) {
    			objForm.elements["dueDate_Date_msvalue"].value = "";
    		}
    		if (objForm.elements["dueDate"]) {
    			objForm.elements["dueDate"].value = "";
    		}
    		if (objForm.elements["dueDate_Time"]) {
    			objForm.elements["dueDate_Time"].selectedIndex = 0;
    		}
    	}
    }

    //
    // When clicked on the dueDateOption radio button, the values in other unchecked due date field should be cleared
    //
    function dueDateOption_onclick(objDueDateOption) {
    	var objForm = document.forms["formAddApprover"];
    	if (!objForm || !objDueDateOption) {
    		return;
    	}

   		if (objDueDateOption.checked) {
   			if (objDueDateOption.value == "dueDateSet") {
   				objForm.dueDateOffset.value = "";
   			}
   			else if (objDueDateOption.value == "dueDateOffsetSet") {
   				clearDueDate_onclick();
   			}
   			else if (objDueDateOption.value == "assigneeSetDueDateSet") {
   				objForm.dueDateOffset.value = "";
   				clearDueDate_onclick();
   			}
   		}
    }
    
    function getSelectedDueDateOption() {
    	var objForm = document.forms["formAddApprover"];
    	if (!objForm) {
    		throw "No form formAddApprover present in document.";
    	}

    	//Check for due date
    	var arrDueDateOption = objForm.elements["dueDateOption"];
    	if (!arrDueDateOption) {
    		throw "Expecting array of element with name dueDateOption";
    	}

    	// If due date is selected
    	for (var i = 0; i < arrDueDateOption.length; i++) {
    		var objDueDateOption = arrDueDateOption[i];

    		if (objDueDateOption.checked) {
    			return objDueDateOption.value;
    		}
    	}
    	
    	throw "No dueDateOption selected.";
    }
    
    function calendarIcon_onclick(strFormName, strFieldName) {
    	
    	if (getSelectedDueDateOption() != "dueDateSet") {
    		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NotCalendarOption</emxUtil:i18nScript>");
    		return;
    	}
    	
    	showCalendar(strFormName, strFieldName,'', true);
    }
    
    function dueDate_Time_onfocus(objElement) {
    	if (getSelectedDueDateOption() != "dueDateSet") {
    		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NotCalendarOption</emxUtil:i18nScript>");
    		objElement.blur();
    		return;
    	}
    }
    
    function dueDateOffset_onfocus(objElement) {
    	if (getSelectedDueDateOption() != "dueDateOffsetSet") {
    		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NotDeltaOption</emxUtil:i18nScript>");
    		objElement.blur();
    		return;
    	}
    }
    
    function dueDateOffsetFrom_onfocus(objElement) {
    	if (getSelectedDueDateOption() != "dueDateOffsetSet") {
    		alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.NotDeltaOption</emxUtil:i18nScript>");
    		objElement.blur();
    		return;
    	}
    }
//-->
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<!-- Page display code here -->

<form name="formAddApprover"  id="formAddApprover" method="post"
								action="emxLifecycleAddApproverProcess.jsp" target="pagehidden">
	<input type="hidden" name="actionType" value="" />
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strParentObjectId%></xss:encodeForHTMLAttribute>"/>

	<table border="0" cellpadding="3" cellspacing="2" width="100%">
		<tr>
			<td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.Common.State</emxUtil:i18n></td>
			<td class="inputField">
	            <select name="state">
				<%
				com.matrixone.apps.domain.DomainObject dmoObject = new com.matrixone.apps.domain.DomainObject(strParentObjectId);
				String strCurrentParentState = dmoObject.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_CURRENT);
				String strPolicyName = dmoObject.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_POLICY);
				String sLanguage = request.getHeader("Accept-Language");
				//Find all the states of the object
				State state = null;
				String strState = "";
				StateList stateList = LifeCyclePolicyDetails.getStateList(context, dmoObject, strPolicyName);				
				StateItr stateItr = new StateItr(stateList);
				boolean isPastState = false;
	            boolean isLastState = false;
	            int nCountOfStates = 0;
				while (stateItr.next()) {
				    state = stateItr.obj();
	                strState = state.getName();
	                isPastState = isPastState(strState, strCurrentParentState, stateList);
	                isLastState = isLastState(strState, stateList);
	                if(!isPastState && !isLastState){
	                %>
	                    <!-- //XSSOK -->
	                    <option value="<%=strState%>"><%=i18nNow.getStateI18NString(strPolicyName, strState, sLanguage)%></option>
	                <%
		                nCountOfStates++;
	                }
	            }
				if (nCountOfStates == 0) {
	            %>
                    <option value=""><%=i18nNow.getI18nString( "emxFramework.Common.AdHoc", "emxFrameworkStringResource", sLanguage)%></option>
                <%				    
				}
				%>
	            </select>
			</td>
		</tr>

		<tr>
			<td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxFramework.LifecycleTasks.Action</emxUtil:i18n></td>
			<td class="inputField">
	            <select name="action">
					<option value="Approve"><%=i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_ROUTE_ACTION, "Approve", sLanguage)%></option>
					<option value="Comment"><%=i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_ROUTE_ACTION, "Comment", sLanguage)%></option>
					<option value="Notify Only"><%=i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_ROUTE_ACTION, "Notify Only", sLanguage)%></option>
	            </select>
			</td>
		</tr>

		<tr>
			<td></td>
			<td>
				<br/>
					<input type="radio" name="searchType" id="searchType" value="Person" checked/> <emxUtil:i18n localize="i18nId">emxFramework.Type.Person</emxUtil:i18n>
					<!-- &nbsp;<emxUtil:i18n localize="i18nId">emxFramework.Common.Role</emxUtil:i18n>  <input type="radio" name="searchType" id="searchType" value="Role"/>
					&nbsp;<emxUtil:i18n localize="i18nId">emxFramework.Common.Group</emxUtil:i18n> <input type="radio" name="searchType" id="searchType" value="Group"/> -->
					<input type="radio" name="searchType" id="searchType" value="UserGroup"/> <emxUtil:i18n localize="i18nId">emxFramework.Type.Group</emxUtil:i18n>
				<br/>
			</td>

		</tr>
		<tr>
	 		<td class="labelRequired" width="150"><emxUtil:i18n localize="i18nId">emxFramework.Common.Approver</emxUtil:i18n></td>
			<td class="Field">
				<input type="hidden" name="approverType" value="" />
				<input type="text" readonly="readonly" name="approver" value="" />
				
			<!-- Bug #345799: Type Ahead Implementation -->			
				<emxUtil:displayTypeAheadValues
				    context="<%=context%>"
    				form="formAddApprover"
    				field="approver"
    				displayField="approver"
    				hiddenField="approverType"
    				program="emxTypeAheadPersonSearch"
    				function="getApproversIncludePersonsRolesGroups"/>
			<!-- Bug #345799: Type Ahead Implementation -->
				
				
				
				<input type="button" name="" id="" value="..." onClick="javascript:showSearchWindow()" />
				<a href="JavaScript:clear_onclick('approver')" ><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
			</td>
	  	</tr>
	  	
	  	<tr>
	 		<td class="labelRequired" width="150"><emxUtil:i18n localize="i18nId">emxFramework.Common.Title</emxUtil:i18n></td>
	 			<td class="Field">
	            	<input type="text" name="title" value="" />&nbsp;
	            </td>
	  	</tr>

		<tr>
	 		<td class="labelRequired" width="150"><emxUtil:i18n localize="i18nId">emxFramework.Common.Instructions</emxUtil:i18n></td>
	 		<td class="Field" ><textarea name="instructions" cols="30" rows="5" wrap></textarea></td>
	  	</tr>

	  	<tr>
	 		 <td class="labelRequired" width="150" rowspan="4"><emxUtil:i18n localize="i18nId">emxFramework.Common.DueDate</emxUtil:i18n></td>
	 		 <td class="inputField">
	 		 	<input onclick="dueDateOption_onclick(this)" type="radio" name="dueDateOption" value="dueDateSet"/>
	 		 	<!-- This Field value will be updated after submit is clicked -->
	            <input readonly type="hidden" name="dueDate" value="" />
	            <!-- Date chooser -->
	            <input readonly type="text" name="dueDate_Date" value="" size="10" />&nbsp;
	            <a href="javascript:calendarIcon_onclick('formAddApprover','dueDate_Date')" ><img src="../common/images/iconSmallCalendar.gif" border="0" valign="absmiddle" name="calendarIcon" /></a>&nbsp;
	            <input type="hidden" name="dueDate_Date_msvalue" value="" />
	            <!-- Time chooser -->
	            <select name="dueDate_Time" onfocus="dueDate_Time_onfocus(this)">
<%
				GregorianCalendar calendar = new GregorianCalendar();
				calendar.set(Calendar.HOUR, 4);
				calendar.set(Calendar.MINUTE, 30);
				calendar.set(Calendar.SECOND, 0);
				calendar.set(Calendar.AM_PM, Calendar.PM);
				Date dtOffset = new Date();

				SimpleDateFormat sdfValue = new SimpleDateFormat("hh:mm:ss a");//12 hrs format
				SimpleDateFormat sdfDisplay = new SimpleDateFormat("hh:mm a");//12 hrs format

				for (int i = 0; i < 48; i++) {
				    calendar.add(Calendar.MINUTE, 30);
				    dtOffset = calendar.getTime();
%>
					<option value="<xss:encodeForHTMLAttribute><%=sdfValue.format(dtOffset)%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=sdfDisplay.format(dtOffset)%></xss:encodeForHTML></option>
<%
				}
%>
	            </select>
	            <a href="javascript:clearDueDate_onclick()"><emxUtil:i18n localize="i18nId">emxFramework.Common.Clear</emxUtil:i18n></a>
		     </td>
	  	</tr>
	  	<tr>
	 		 <td class="inputField">
				<emxUtil:i18n localize="i18nId">emxFramework.Common.Advanced</emxUtil:i18n>
		     </td>
	  	</tr>
	  	<tr>
	 		 <td class="inputField">
	            <input onclick="dueDateOption_onclick(this)" type="radio" name="dueDateOption" value="dueDateOffsetSet"/>
            	<input type="text" name="dueDateOffset" value="" size="3" onfocus="dueDateOffset_onfocus(this)" />&nbsp;
            	<emxUtil:i18n localize="i18nId">emxFramework.Common.DaysFrom</emxUtil:i18n>
            	<select name="dueDateOffsetFrom" onfocus="dueDateOffsetFrom_onfocus(this)">
<%
				String strRangeValue = "";
				String stri18nRangeValue = "";
				AttributeType attributeDueDateOffsetFrom = new AttributeType(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM);
				attributeDueDateOffsetFrom.open(context);

				for (StringItr itrChoices = new StringItr(attributeDueDateOffsetFrom.getChoices(context)); itrChoices.next();) {
				    strRangeValue = itrChoices.obj();
				    stri18nRangeValue = i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM, strRangeValue, lStr);
%>
					<option value="<%=XSSUtil.encodeForHTMLAttribute(context, strRangeValue)%>"><%=stri18nRangeValue%></option>
<%
				}
				attributeDueDateOffsetFrom.close(context);
%>
            	</select>
		     </td>
	  	</tr>
	  	<tr>
	 		 <td class="inputField">
				<input onclick="dueDateOption_onclick(this)" type="radio" name="dueDateOption" value="assigneeSetDueDateSet" checked/>
				<emxUtil:i18n localize="i18nId">emxFramework.Common.AssigneeDueDate</emxUtil:i18n>
		     </td>
	  	</tr>
	  	<tr>
	 		 <td class="label" width="150"><emxUtil:i18n localize="i18nId">emxFramework.Common.OtherOptions</emxUtil:i18n></td>
	 		 <td class="inputField">
	 		 	<input type="checkbox" name="allowDelegation" value="True" checked/><emxUtil:i18n localize="i18nId">emxFramework.Common.AllowDelegation</emxUtil:i18n><br/>
	 		 	<input type="checkbox" name="requiresOwnerReview" value="True"/><emxUtil:i18n localize="i18nId">emxFramework.Common.RequiresOwnersReview</emxUtil:i18n>
		     </td>
	  	</tr>
	</table>
</form>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<%!

/**
 * Returns if the given state is the past state with respect to the list of states
 * @param strState The state to be checked if it is past
 * @param strObjectCurrentState The current state of the object
 * @param stateList List of all the state of the object in ascending order
 * @return true if the strState comes before strObjectCurrentState in stateList
 * @throws Exception if operation fails
 */
public static boolean isPastState(String strState, String strObjectCurrentState, StateList stateList) throws Exception {
    if (strState == null || "".equals(strState)) {
        throw new Exception("Invalid value for strState");
    }
    if (strObjectCurrentState == null || "".equals(strObjectCurrentState)) {
        throw new Exception("Invalid value for strObjectCurrentState");
    }
    if (stateList == null) {
        throw new Exception("Null stateList");
    }

    int nGivenStateIndex = -1;
    int nCurrentStateIndex = -1;
    int nCurrentIndex = 0;

    for (StateItr itrStates = new StateItr(stateList); itrStates.next(); nCurrentIndex++) {
        State state = itrStates.obj();
        if (strState.equals(state.getName())) {
            nGivenStateIndex = nCurrentIndex;

            if (nCurrentStateIndex != -1) {
                break;
            }
        }

        if (strObjectCurrentState.equals(state.getName())) {
            nCurrentStateIndex = nCurrentIndex;

            if (nGivenStateIndex != -1) {
                break;
            }
        }
    }//for

    if (nGivenStateIndex == -1) {
        throw new Exception("Given state is not found in stateList");
    }
    if (nCurrentStateIndex == -1) {
        throw new Exception("Current state is not found in stateList");
    }
    if (nGivenStateIndex < nCurrentStateIndex) {
        return true;
    }
    else {
        return false;
    }
}

/**
 * Returns if the given state is the last state with respect to the list of states
 * @param strState The state to be checked if it is past
 * @param stateList List of all the state of the object in ascending order
 * @return true if the strState is last in stateList
 * @throws Exception if operation fails
 */
public static boolean isLastState(String strState, StateList stateList) throws Exception {
    if (strState == null || "".equals(strState)) {
        throw new Exception("Invalid value for strState");
    }
    if (stateList == null || stateList.size() == 0) {
        throw new Exception("Null/Empty stateList");
    }

    int nLength = stateList.size();
    int nLastStateIndex = nLength -1;
    State lastState = (State)stateList.get(nLastStateIndex);
    if (strState.equals(lastState.getName())) {
        return true;
    }
    else {
        return false;
    }
}

%>

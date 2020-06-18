<%--  emxLifecycleAddApproverFromTemplate.jsp   -    Dialog page for Add Approver From Template functionality

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleAddApproverFromTemplate.jsp.rca 1.5.3.2 Wed Oct 22 15:48:19 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.*" %>
<%@ page import="com.matrixone.apps.framework.lifecycle.LifeCyclePolicyDetails"%>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>


<%
    try {
        String keyValue=emxGetParameter(request,"keyValue");
        String strObjectId = emxGetParameter(request, "objectId");
        if(keyValue == null){
          keyValue = formBean.newFormKey(session);
        }
        formBean.processForm(session,request,"keyValue");
        String template           =  (String) formBean.getElementValue("templateName");
        if("null".equals(template) || template == null) {
            template = "";
        }
       
 %>
<script language="javascript">

function submitForm() {

        var form = document.formManageRouteApproval;
        var divForm = document.getElementById("divFormManageRouteApproval");
        var strHTMLBuffer = "";
        divForm.innerHTML = "";

        // Convert the data in formManageRouteApprovalData to be more useful for process page
        var nCount = 1;
        while (true) {

            // Search an element with value templateId_<nCount>
            var element = null;
            var strKey = "templateId_"+nCount;
        
            var strStateName = "";
            var strRouteTemplateId = "";

            for (var i = 0; i < form.elements.length; i++) {
                if (form.elements[i].value == strKey) {
                    element = form.elements[i];
                }
            }

            if (element == null) {
                break;
            }
            else {
                // Generate the hidden element in div tag
                strStateName = element.name;
                strRouteTemplateId = form.elements[strKey+"OID"].value;

                if (strRouteTemplateId != "") {
                    strHTMLBuffer += "<input type='hidden'name='stateNewRoute' value='" + strStateName + "|" + strRouteTemplateId + "' />";
                }
            }

            // Next count
            nCount++;
        }//while true

        divForm.innerHTML = strHTMLBuffer;
		
        form.submit();
    }
    
function clear_onclick(strFieldName) {
        var form = document.formManageRouteApproval;
        if (strFieldName != "") {
            var element = form.elements[strFieldName];
            if (element) {
                element.value = "";
                var inputFormField = form.elements[strFieldName+"OID"];
                if(inputFormField){
                	inputFormField.value = "";
                }
            }
        }
}

function showSearchWindow() {
		 var strFeatures = "width=600,height=500,resizable=yes";
		 var strURL="../components/emxRouteWizardSearchTemplateDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>";
		
		 var win = window.open(strURL, "RouteTemplate", strFeatures);
 }
 
function routeTemplateChooser_onclick(strFieldHiddenName, strFieldDisplayName, strFieldHiddenObjId) {
 
     var  strURL ="../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:CURRENT=policy_RouteTemplate.state_Active&table=RouteTemplateSummary&showInitialResults=true&includeOIDprogram=emxRouteTemplate:getRouteTemplateIncludeIDs&formInclusionList=ROUTE_TEMPLATE_AVAILABILITY_TYPE&form=BPSRouteTemplateSearch&submitURL=../common/AEFSearchUtil.jsp&selection=single&fieldNameActual="+strFieldHiddenObjId+"&fieldNameDisplay="+strFieldDisplayName;
        showModalDetailsPopup(strURL);
    }
    
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
 <form name="formManageRouteApproval"  id="formManageRouteApproval" method="post" action="emxLifecycleAddApproverFromTemplateProcess.jsp">
	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
	<table border="0" cellpadding="3" cellspacing="2" width="100%">
	<%
	DomainObject dmoObject = new DomainObject(strObjectId);
	String strCurrentParentState = dmoObject.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_CURRENT);
	String strPolicyName = dmoObject.getInfo(context, com.matrixone.apps.domain.DomainObject.SELECT_POLICY);
	State state = null;
	String strState = "";
	int  nCount = 0; 
	StateList stateList = LifeCyclePolicyDetails.getStateList(context, dmoObject, strPolicyName);
	StateItr stateItr = new StateItr(stateList);
	boolean isPastState = false;
    boolean isLastState = false;
    
	while (stateItr.next()) {
	    state = stateItr.obj();
              strState = state.getName();
              isPastState = isPastState(strState, strCurrentParentState, stateList);
              isLastState = isLastState(strState, stateList);
              if(!isPastState && !isLastState){
                  nCount++;
              %>
              <tr>
                  <td class="label" width="150"><label for="<%=XSSUtil.encodeForHTML(context, strState)%>"><%=XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(strPolicyName, strState, lStr))%></label></td>
                  <td class="Field">
				  <input type="text" readonly="readonly" name="templateId_<%=nCount%>" value="" size="20" />
                  <input type="hidden" name="templateId_<%=nCount%>OID" value="" />
				  <!--The mapping between state and the route template value-->
                  <input type="hidden" name="<%=XSSUtil.encodeForHTML(context, strState)%>" value="templateId_<%=nCount%>" />
				  <!--The route template chooser button-->
                  <input type="button" name="routeTemplateChooser" value="..." onClick="javascript:routeTemplateChooser_onclick('templateId_<%=nCount%>', 'templateId_<%=nCount%>', 'templateId_<%=nCount%>')" />
                  <a href="JavaScript:clear_onclick('template_<%=nCount%>'); clear_onclick('templateId_<%=nCount%>');" ><%=XSSUtil.encodeForHTML(context, getI18NString("emxFrameworkStringResource", "emxFramework.Common.Clear", lStr))%></a>
			</td>
                </tr>  
              <%
              }
              else if (isLastState) {
%>
				<tr>
                  	<td class="label" width="150"><label for="<%=XSSUtil.encodeForHTML(context, strState)%>"><%=XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(strPolicyName, strState, lStr))%></label></td>
					<td class="Field"><%=XSSUtil.encodeForHTML(context, getI18NString("emxFrameworkStringResource", "emxFramework.Common.NotAllowedForLastState", lStr))%></td>
				</tr>
<%        	          
              }
    }
			  %>
	</table>
	  <div id="divFormManageRouteApproval"></div>
 </form>
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



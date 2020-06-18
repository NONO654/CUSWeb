<%--  emxRouteManageApprovalsDialog.jsp   -   Dialog page for Manage Route Approvals functionality

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteManageApprovalsDialog.jsp.rca 1.4.3.2 Wed Oct 22 16:18:10 2008 przemek Experimental przemek $
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.framework.lifecycle.LifeCyclePolicyDetails"%>
<%
    // Find the required parameters
    String strObjectId = emxGetParameter(request, "objectId");
%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript">
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
                    strHTMLBuffer += "<input type='hidden' name='stateNewRoute' value='" + strStateName + "|" + strRouteTemplateId + "' />";
                }
            }

            // Next count
            nCount++;
        }//while true

        divForm.innerHTML = strHTMLBuffer;

        form.submit();
    }

    function apply_onclick() {
        var form = document.formManageRouteApproval;
        form.actionType.value = "Apply";
        submitForm();
    }

    function done_onclick() {
        var form = document.formManageRouteApproval;
        form.actionType.value = "Done";
        if(jsDblClick()){
			submitForm();
		}else {
			alert("<emxUtil:i18nScript  localize="i18nId">emxFramework.Submit.Progress</emxUtil:i18nScript>");
			return;
		} 
    }

    function cancel_onclick() {
        getTopWindow().closeWindow();
    }

    function routeTemplateChooser_onclick(strFieldHiddenName, strFieldDisplayName, strFieldHiddenObjId) {
     
        var strURL ="../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:CURRENT=policy_RouteTemplate.state_Active&table=RouteTemplateSummary&showInitialResults=true&includeOIDprogram=emxRouteTemplate:getRouteTemplateIncludeIDs&formInclusionList=ROUTE_TEMPLATE_AVAILABILITY_TYPE&form=BPSRouteTemplateSearch&submitURL=../common/AEFSearchUtil.jsp&selection=single&fieldNameActual="+strFieldHiddenObjId+"&fieldNameDisplay="+strFieldDisplayName;
        showModalDialog(strURL);
    }

    function clear_onclick(strFieldName) {
        var form = document.formManageRouteApproval;
        if (strFieldName != "") {
            var element = form.elements[strFieldName];
            if (element) {
                element.value = "";
            }
        }
    }

</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<form name="formManageRouteApproval" method="post" action="emxRouteManageApprovalsProcess.jsp">
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="actionType" value="" />

    <table class="list">
        <tr>
            <th><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.States","emxComponentsStringResource", lStr))%></th>
            <th><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.ExistingRoutes","emxComponentsStringResource", lStr))%></th>
            <th><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.NewRoute","emxComponentsStringResource", lStr))%></th>
        </tr>
<%
            DomainObject domainObject = new DomainObject(strObjectId);

            // Find required object information
            StringList slBusSelect = new StringList(DomainObject.SELECT_CURRENT);
            slBusSelect.add(DomainObject.SELECT_POLICY);
            Map mapObjectInfo = domainObject.getInfo(context, slBusSelect);

            String strObjectCurrentState = (String)mapObjectInfo.get(DomainObject.SELECT_CURRENT);
            String strPolicyName = (String)mapObjectInfo.get(DomainObject.SELECT_POLICY);
            String strCurrentState = "";
            String strDisplayRemove = i18nNow.getI18nString("emxComponents.Button.Remove","emxComponentsStringResource", lStr);
            String strNotAllowedForPastStates = i18nNow.getI18nString("emxComponents.common.NotAllowedForPastStates","emxComponentsStringResource", lStr);
            String strNotAllowedForLastState = i18nNow.getI18nString("emxComponents.common.NotAllowedForLastState","emxComponentsStringResource", lStr);

            // Find all the states of the object
            StateList stateList = LifeCyclePolicyDetails.getStateList(context,domainObject,strPolicyName);
            // Find the routes for each state
            Map mapStateBasedRoutes = getStateBasedRoutes(context, strObjectId);

            StateItr stateItr = new StateItr(stateList);
            StateItr stateItrForPastStates = new StateItr(stateList);
            MapList mlRoutesPerState = new MapList();
            Map mapCurrent = null;
            String strRouteName = "";
            String strRouteId = "";
            boolean isRouteFinished = false;
            boolean isPastState = false;
            boolean isLastState = false;
            State state = null;
            int nCount = 0;   // Used to generate the names for route template text box
			int nCountPastStates=0; //Used to count the past states
            boolean bRowSpanPut= false; //Used to put the row span only once
            // count the number of past states.
            while (stateItrForPastStates.next()) {
                state = stateItrForPastStates.obj();
                strCurrentState = state.getName();
                isPastState = isPastState(strCurrentState, strObjectCurrentState, stateList);
                if(isPastState){
                    nCountPastStates++;
                    
                }
            }
            //Count ends
            
            // Iterate on each state
            while (stateItr.next()) {


                state = stateItr.obj();
                strCurrentState = state.getName();

                isPastState = isPastState(strCurrentState, strObjectCurrentState, stateList);
                
                isLastState = isLastState(strCurrentState, stateList);
%>
                <tr>
                    <td class="inputField" nowrap>
<%
                        // Show the current state in bold
                        if (strObjectCurrentState.equals(strCurrentState)) {
%>
                            <b><%=XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(strPolicyName, strCurrentState, lStr))%></b>
<%
                        }
                        else {
%>
                            <%=XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(strPolicyName, strCurrentState, lStr))%>
<%
                        }
%>
                    </td>
                    <td class="inputField" nowrap>
<%
                        // Get the list of routes for the current state in the loop
                        mlRoutesPerState = (MapList)mapStateBasedRoutes.get(strCurrentState);
                        if (mlRoutesPerState == null) {
                            mlRoutesPerState = new MapList();
                            mapStateBasedRoutes.put(strCurrentState, mlRoutesPerState);
                        }

                        // Print all the route names and the Remove checkboxes
                        for (Iterator itrMaps = mlRoutesPerState.iterator(); itrMaps.hasNext();) {
                            mapCurrent = (Map)itrMaps.next();

                            strRouteName = (String)mapCurrent.get(DomainObject.SELECT_NAME);
                            strRouteId = (String)mapCurrent.get(DomainObject.SELECT_ID);
                            isRouteFinished = "true".equalsIgnoreCase((String)mapCurrent.get("isFinished"));
%>
                            <a href="javascript:emxShowModalDialog('../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context, strRouteId)%>',800,600);"><%=XSSUtil.encodeForXML(context, strRouteName)%></a>
<%
                            // Show the checkbox only if the route is not finished and this is not the past and last state of the object
                            if (!isRouteFinished && !isPastState && !isLastState) {
%>
                                <input type="checkbox" name="removeRoute" value="<%=XSSUtil.encodeForHTMLAttribute(context, strRouteId)%>" /> <%=XSSUtil.encodeForHTMLAttribute(context, strDisplayRemove)%>
<%
                            }
%>
                            <br/>
<%
                        }
%>
                    </td>
<%
                            // Show the Route Template chooser only if this is not the past and last state of the object
                            if (!isPastState && !isLastState) {
                                nCount++;
%>           
                    			<td class="inputField" nowrap>
                                <!--The route template text box-->
                                <input type="text" readonly="readonly" name="templateId_<%=nCount%>" value="" size="20" />
                                <input type="hidden" name="templateId_<%=nCount%>OID" value="" />

                                <!--The mapping between state and the route template value-->
                                <input type="hidden" name="<%=XSSUtil.encodeForHTML(context, strCurrentState)%>" value="templateId_<%=nCount%>" />

                                <!--The route template chooser button-->
                                <input type="button" name="routeTemplateChooser" value="..." onClick="javascript:routeTemplateChooser_onclick('templateId_<%=nCount%>', 'templateId_<%=nCount%>', 'templateId_<%=nCount%>')" />
                                <a href="JavaScript:clear_onclick('templateId_<%=nCount%>'); clear_onclick('templateId_<%=nCount%>');" ><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.Clear","emxComponentsStringResource", lStr))%></a>
                                    </td>
<%
                            }
                            else if(isPastState && !bRowSpanPut){
                                bRowSpanPut=true;
                            %>
                                  <td class="inputField" nowrap rowspan="<%=nCountPastStates %>"><%=XSSUtil.encodeForHTML(context, strNotAllowedForPastStates)%></td>
                            <%}
                            else if(isLastState){%>
                                <td class="inputField" nowrap><%=XSSUtil.encodeForHTML(context, strNotAllowedForLastState)%></td>
                            <%}
%>
                
                </tr>
<%
            }//while for states
%>
    </table>

    <!--This div tag is used to generate some hidden input fields for mapping of state and the name of the selected route template-->
    <div id="divFormManageRouteApproval"></div>
</form>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<%!

/**
 * Finds the route for the given object for its given states.
 * @param context The matrix Context object
 * @param strObjectId The id of the object
 * @return The MapList object which contains the Maps having the state name and the corresponding routes information
 * @throws Exception If operation fails.
 */
public static Map getStateBasedRoutes(Context context, String strObjectId) throws Exception {
    if (context == null) {
        throw new Exception("Invalid context");
    }
    if (strObjectId == null || "".equals(strObjectId)) {
        throw new Exception("Invalid object id");
    }

    final String SELECT_ATTRIBUTE_ROUTE_STATUS = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_STATUS + "]";
    final String SELECT_ATTRIBUTE_ROUTE_BASE_STATE = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_BASE_STATE + "]";
    final String SELECT_ATTRIBUTE_ROUTE_BASE_POLICY = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_BASE_POLICY + "]";
    Map mapResult = new HashMap();
    String strRelationshipPattern = DomainObject.RELATIONSHIP_OBJECT_ROUTE;
    String strTypePattern = "*";
    StringList slObjectSelects = new StringList();
    StringList slRelationshipSelects = new StringList();
    boolean isGetTo = false;
    boolean isGetFrom = true;
    short nRecurseToLevel = (short)1;
    String strObjectWhere = "";
    String strRelationshipWhere = "";
    Map mapForState = null;
    String strStateName = "";
    String strPolicyName = "";
    String strRouteStatus = "";
    MapList mlRoutes = new MapList();

    slObjectSelects.add(DomainObject.SELECT_ID);
    slObjectSelects.add(DomainObject.SELECT_NAME);
    slObjectSelects.add(SELECT_ATTRIBUTE_ROUTE_STATUS);

    slRelationshipSelects.add(SELECT_ATTRIBUTE_ROUTE_BASE_STATE);
    slRelationshipSelects.add(SELECT_ATTRIBUTE_ROUTE_BASE_POLICY);

    DomainObject domainObject = new DomainObject(strObjectId);
    MapList mlResult = domainObject.getRelatedObjects(context,
                                                                strRelationshipPattern,
                                                                strTypePattern,
                                                                slObjectSelects,
                                                                slRelationshipSelects,
                                                                isGetTo,
                                                                isGetFrom,
                                                                nRecurseToLevel,
                                                                strObjectWhere,
                                                                strRelationshipWhere);
    for (Iterator itrMaps = mlResult.iterator(); itrMaps.hasNext();) {
        Map mapCurrent = (Map)itrMaps.next();

        strRouteStatus = (String)mapCurrent.get(SELECT_ATTRIBUTE_ROUTE_STATUS);

        // Find the real state name
        strPolicyName = (String)mapCurrent.get(SELECT_ATTRIBUTE_ROUTE_BASE_POLICY);
        strStateName = (String)mapCurrent.get(SELECT_ATTRIBUTE_ROUTE_BASE_STATE);
        strPolicyName = PropertyUtil.getSchemaProperty(context, strPolicyName); // From symbolic to real name
        strStateName = PropertyUtil.getSchemaProperty(context, "policy", strPolicyName, strStateName); // From symbolic to real name

        // Get the existing list of routes for this state if any
        mlRoutes = (MapList)mapResult.get(strStateName);
        if (mlRoutes == null) {
            mlRoutes = new MapList();
            mapResult.put(strStateName, mlRoutes);
        }

        //Find if the route is finished
        if ("Finished".equals(strRouteStatus)) {
            mapCurrent.put("isFinished", "true");
        }
        else {
            mapCurrent.put("isFinished", "false");
        }

        mlRoutes.add(mapCurrent);
    }//for

    return mapResult;
}

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

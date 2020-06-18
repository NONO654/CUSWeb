<%--  emxRouteManageApprovalsProcess.jsp   -   Process page for Manage Route Approvals functionality

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteManageApprovalsProcess.jsp.rca 1.5.3.2 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%
    // Get request parameters
    String strObjectId = emxGetParameter(request, "objectId");
    String strActionType = emxGetParameter(request, "actionType");
    String[] strRemoveRoutes = emxGetParameterValues(request, "removeRoute");
    String[] strStateNewRoutes = emxGetParameterValues(request, "stateNewRoute");

    String strNotificationBody = i18nNow.getI18nString("emxComponents.Common.RouteDeleteNotification.Body", "emxComponentsStringResource", lStr);
    String strNotificationSubject = i18nNow.getI18nString("emxComponents.Common.RouteDeleteNotification.Subject", "emxComponentsStringResource", lStr);

    try {
        ContextUtil.startTransaction(context, true);

        removeStateRoutes(context, strObjectId, strRemoveRoutes, strNotificationSubject, strNotificationBody);

        addStateRoutes(context, strObjectId, strStateNewRoutes, request.getSession());

        ContextUtil.commitTransaction(context);
    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);

         if (ex.getMessage() != null && ex.getMessage().length() > 0) {
            emxNavErrorObject.addMessage(ex.getMessage());
         }
         else {
            emxNavErrorObject.addMessage(ex.toString());
         }
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    //Post process action
    if ("Apply".equals(strActionType)) {
%>
        <form name="formRouteManageApprovalsDialog" method="post" action="emxRouteManageApprovalsDialog.jsp">
            <input type="hidden" name="initSource" value="" />
            <input type="hidden" name="warn" value="false" />
            <input type="hidden" name="suiteKey" value="Components" />
            <input type="hidden" name="portalMode" value="false" />
            <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="contentPageIsDialog" value="true" />
            <input type="hidden" name="usepg" value="false" />
        </form>
        <script language="JavaScript">
        <!--
            document.formRouteManageApprovalsDialog.submit();
        //-->
        </script>
<%
    }
    else {
%>
        <script language="JavaScript">
        <!--
            getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
            getTopWindow().closeWindow();
        //-->
        </script>
<%
    }
%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>

<%!
/**
 * Removes the state based routes for an object
 * @param context The Matrix Context object
 * @param strObjectId The object id
 * @param strRemoveRoutes The string array having route object ids to be removed
 * @return -
 * @throws Exception if operation fails
 */
public static void removeStateRoutes (Context context, String strObjectId, String[] strRemoveRoutes, String strNotificationSubject, String strNotificationBody) throws Exception {
    // Arguments check
    if (context == null) {
        throw new Exception("Invalid context");
    }
    if (strObjectId == null || "".equals(strObjectId) || "null".equals(strObjectId)) {
        throw new Exception("Invalid object id");
    }
    if (strRemoveRoutes == null) {
        return;
    }

    String strRouteId = "";
    String strRouteName = "";
    String strCurrentUserFullName = PersonUtil.getFullName(context);
    String strCompleteSubject = "";
    strNotificationBody = FrameworkUtil.findAndReplace(strNotificationBody, "<name>", strCurrentUserFullName);

    com.matrixone.apps.common.Route route = new com.matrixone.apps.common.Route();

    // Iterate over each route object and delete it
    for (int i = 0; i < strRemoveRoutes.length; i++) {
        strRouteId = strRemoveRoutes[i];

        route.setId(strRouteId);
        strRouteName = route.getInfo(context, DomainObject.SELECT_NAME);
        strCompleteSubject = FrameworkUtil.findAndReplace(strNotificationSubject, "<name>", strRouteName);

        route.deleteRouteObject(context, strNotificationBody,strCompleteSubject);

    }//for each route
}

/**
 * Adds the state based routes for an object using the route templates. If the routes are
 * being added to the current state of the object then they are started.
 * @param context The Matrix Context object
 * @param strObjectId The object id
 * @param strStateNewRoutes The string array having values in the form of <state name>|<route template id>
 * @return -
 * @throws Exception if operation fails
 */
public static void addStateRoutes(Context context, String strObjectId, String[] strStateNewRoutes, HttpSession session) throws Exception {

    // Arguments check
    String sTypeInboxTask = PropertyUtil.getSchemaProperty("type_InboxTask");
    String relTaskSubRoute = PropertyUtil.getSchemaProperty("relationship_TaskSubRoute");
    String attrDueDateOffset      = PropertyUtil.getSchemaProperty(context, "attribute_DueDateOffset");
    String attrDueDateOffsetFrom  = PropertyUtil.getSchemaProperty(context, "attribute_DateOffsetFrom");
    String attrAssigneeDueDate    = PropertyUtil.getSchemaProperty(context, "attribute_AssigneeSetDueDate");
    
    String OFFSET_FROM_ROUTE_START_DATE  = "Route Start Date";
    String OFFSET_FROM_TASK_CREATE_DATE  = "Task Create Date";
    
    String selDueDateOffset       = "attribute["+attrDueDateOffset+"]";
    String selDueDateOffsetFrom   = "attribute["+attrDueDateOffsetFrom+"]";
    String selAssigneeDueDate     = "attribute["+attrAssigneeDueDate+"]";
    String selRouteNodeRelId      = DomainObject.SELECT_RELATIONSHIP_ID;
    String selSequence            = "attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]";
    StringBuffer sWhereExp              = new StringBuffer(100);
    
    if (context == null) {
        throw new Exception("Invalid context");
    }
    if (strObjectId == null || "".equals(strObjectId) || "null".equals(strObjectId)) {
        throw new Exception("Invalid object id");
    }
    if (strStateNewRoutes == null) {
        return;
    }

    String strStateAndRouteTemplate = "";
    String strStateName = "";
    String strStateNameSymbolic = "";
    String strRouteTemplateId = "";
    String strRouteId = "";
    StringList slSplitedStrings = null;
    String[] strObjectIds = new String[] {strObjectId};  // used while adding this object as content to the route
    HashMap mapObjectToState = new HashMap();           // used while adding this object as content to the route
    com.matrixone.apps.common.Route route = (com.matrixone.apps.common.Route)DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE);
    DomainRelationship dmoRelationship = null;
    Map mapRelAttributes = new HashMap();

    DomainObject domainObject = new DomainObject(strObjectId);
    String strPolicyName = domainObject.getInfo(context, DomainObject.SELECT_POLICY);
    String strPolicyNameSymbolic = FrameworkUtil.getAliasForAdmin(context,"Policy", strPolicyName, true); // Use cache
    String strCurrentStateOfObject = domainObject.getInfo(context, DomainObject.SELECT_CURRENT);
    StringList relSelects = new StringList();
    mapRelAttributes.put(DomainObject.ATTRIBUTE_ROUTE_BASE_POLICY, strPolicyNameSymbolic);

    // Do for each state|routeTemplateId
    for (int i = 0; i < strStateNewRoutes.length; i++) {
        strStateAndRouteTemplate = strStateNewRoutes[i];

        slSplitedStrings = FrameworkUtil.split(strStateAndRouteTemplate, "|");
        strStateName = (String)slSplitedStrings.get(0);
        strStateNameSymbolic = FrameworkUtil.reverseLookupStateName(context, strPolicyName, strStateName);
        strRouteTemplateId = (String)slSplitedStrings.get(1);

        // Create a route from this route template
        strRouteId = createRouteFromTemplate(context, strRouteTemplateId);

        // Add this object as content to this route
        mapObjectToState.put(strObjectId, strStateName);
        route.setId(strRouteId);
        if(domainObject.getType(context).equals(sTypeInboxTask)){
      		 dmoRelationship = DomainRelationship.connect(context, domainObject, relTaskSubRoute, route);
       	}else{
        dmoRelationship = DomainRelationship.connect(context, domainObject, DomainObject.RELATIONSHIP_OBJECT_ROUTE, route);
        mapRelAttributes.put(DomainObject.ATTRIBUTE_ROUTE_BASE_STATE, strStateNameSymbolic);
        dmoRelationship.setAttributeValues(context, mapRelAttributes);
       	}
        // Start the route if this is the current state of the object
        if (strCurrentStateOfObject.equals(strStateName)) {                     
            relSelects.addElement(selDueDateOffset);
            relSelects.addElement(selDueDateOffsetFrom);
            relSelects.addElement(selRouteNodeRelId);            
            relSelects.addElement(selAssigneeDueDate);
            relSelects.addElement(route.SELECT_TITLE);
            relSelects.addElement(route.SELECT_SCHEDULED_COMPLETION_DATE);
            relSelects.addElement(selSequence);
            sWhereExp.setLength(0);
            sWhereExp.append("("+selDueDateOffset+ " !~~ \"\")");            
            sWhereExp.append( " && (" +selDueDateOffsetFrom + " ~~ \""+OFFSET_FROM_ROUTE_START_DATE+"\")");
            sWhereExp.append(" || ("+selSequence + " == \"1\")");
            MapList routeFirstOrderOffsetList = route.getFirstOrderOffsetTasks(context, route, relSelects, sWhereExp.toString());
            
            route.setDueDatesFromOffset(context,session, routeFirstOrderOffsetList); 
            route.promote(context);
            
        }
    }
}

/**
 * Creates a route object from given route template object
 * @param context The Matrix Context object
 * @param strRouteTemplateId The object id of the route template
 * @return The id of the created Route object
 * @throws Exception if operation fails
 */
public static String createRouteFromTemplate(Context context, String strRouteTemplateId) throws Exception {

     // For Bug 347000
     final String STRING_ROUTE_CANNOT_BE_ADDED_INVALID_ROUTE_TEMPLATE = i18nNow.getI18nString("emxComponents.UserManagedApprovals.RouteCannotBeAddedInvalidRouteTemplate", "emxComponentsStringResource", context.getSession().getLanguage());
     
     // Arguments check
    if (context == null) {
        throw new Exception("Invalid context");
    }
    if (strRouteTemplateId == null || "".equals(strRouteTemplateId) || "null".equals(strRouteTemplateId)) {
        throw new Exception("Invalid strRouteTemplateId");
    }

    com.matrixone.apps.common.Person objPerson = com.matrixone.apps.common.Person.getPerson(context);
    com.matrixone.apps.common.Route route = (com.matrixone.apps.common.Route)DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE);
    String strRouteId = null;
    String strRouteName = null;

    // Create route object
    strRouteName = FrameworkUtil.autoName(context,
                                                                    "type_Route",
                                                                    new Policy(DomainObject.POLICY_ROUTE).getFirstInSequence(context),
                                                                    "policy_Route",
                                                                    null,
                                                                    null,
                                                                    true,
                                                                    true);
    route.createObject(context, DomainConstants.TYPE_ROUTE, strRouteName, null, DomainObject.POLICY_ROUTE, null);
    strRouteId = route.getId();

    // Connect route to the owner
    route.connect(context, new RelationshipType(DomainObject.RELATIONSHIP_PROJECT_ROUTE), true, objPerson);

    // Connect route to the route template
    route.connectTemplate(context, strRouteTemplateId);

    // Copy essential attribute values from Route Template to Route object
    final String ATTRIBUTE_AUTO_STOP_ON_REJECTION = PropertyUtil.getSchemaProperty(context, "attribute_AutoStopOnRejection");
    final String SELECT_ATTRIBUTE_AUTO_STOP_ON_REJECTION = "attribute[" + ATTRIBUTE_AUTO_STOP_ON_REJECTION + "]";
    final String ATTRIBUTE_PRESERVE_TASK_OWNER = PropertyUtil.getSchemaProperty(context, "attribute_PreserveTaskOwner");
        // Get default value and choices for the attribute
    AttributeType attrAutoStopOnRejection = new AttributeType(ATTRIBUTE_AUTO_STOP_ON_REJECTION);
    String strDefaultAutoStopOnRejection = attrAutoStopOnRejection.getDefaultValue(context);    		
    StringList slChoices = attrAutoStopOnRejection.getChoices(context);
        // Copy the attribute value
    com.matrixone.apps.common.RouteTemplate routeTemplate = new com.matrixone.apps.common.RouteTemplate(strRouteTemplateId);
    String strAutoStopOnRejection = routeTemplate.getInfo(context, SELECT_ATTRIBUTE_AUTO_STOP_ON_REJECTION);
    String preserveTaskOwner = routeTemplate.getInfo(context, "attribute[" + ATTRIBUTE_PRESERVE_TASK_OWNER + "]");
    if (!slChoices.contains(strAutoStopOnRejection)) {
        strAutoStopOnRejection = strDefaultAutoStopOnRejection;
    }
    route.setAttributeValue(context, ATTRIBUTE_AUTO_STOP_ON_REJECTION, strAutoStopOnRejection);
    route.setAttributeValue(context, ATTRIBUTE_PRESERVE_TASK_OWNER, preserveTaskOwner);
	// Copy route base purpose from route templ
	final String ATTRIBUTE_ROUTE_BASE_PURPOSE = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose");
    final String SELECT_ATTRIBUTE_ROUTE_BASE_PURPOSE = "attribute[" + ATTRIBUTE_ROUTE_BASE_PURPOSE + "]";
    String strAttrRouteBasePurpose = routeTemplate.getInfo(context, SELECT_ATTRIBUTE_ROUTE_BASE_PURPOSE);
    route.setAttributeValue(context, ATTRIBUTE_ROUTE_BASE_PURPOSE, strAttrRouteBasePurpose);


    // Find all the attributes on Route Node relationship and form select list
    Map mapRelAttributes = DomainRelationship.getTypeAttributes(context, DomainObject.RELATIONSHIP_ROUTE_NODE);
    StringList slRelSelects = new StringList();
    for (Iterator itrAttributes = mapRelAttributes.keySet().iterator(); itrAttributes.hasNext();) {
        slRelSelects.add(DomainRelationship.getAttributeSelect((String)itrAttributes.next()));
    }//for

    // Form the bus select
    StringList slBusSelects = new StringList(DomainObject.SELECT_ID);
    slBusSelects.add(DomainObject.SELECT_TYPE);

    // Expand and find the route template tasks, users
    DomainObject dmoRouteTemplate = new DomainObject(strRouteTemplateId);

    /*Context context, java.lang.String relationshipPattern, java.lang.String typePattern, StringList objectSelects, StringList relationshipSelects, boolean getTo, boolean getFrom, short recurseToLevel, java.lang.String objectWhere, java.lang.String relationshipWhere*/
    String typeProxyGroup = PropertyUtil.getSchemaProperty(context, "type_GroupProxy");  
    String strTypePattern = DomainObject.TYPE_PERSON + "," + DomainObject.TYPE_ROUTE_TASK_USER+","+typeProxyGroup;
    String strRelPattern = DomainObject.RELATIONSHIP_ROUTE_NODE;
    boolean getTo = false;
    boolean getFrom = true;
    short nRecurseToLevel = (short)1;
    String strObjectWhere = null;
    String strRelWhere = null;

    MapList mlTasks = dmoRouteTemplate.getRelatedObjects(context,
                                                                                strRelPattern,
                                                                                strTypePattern,
                                                                                slBusSelects,
                                                                                slRelSelects,
                                                                                getTo,
                                                                                getFrom,
                                                                                nRecurseToLevel,
                                                                                strObjectWhere,
                                                                                strRelWhere);


    Map mapTask = null;
    DomainRelationship dmoRelationship = null;
    DomainObject fromObject = route;
    DomainObject toObject = null;
    String strUserId = null;
    String strUserType = null;
    String strRouteTaskUser = null;
    String strTaskTitle = null;
    String strAttributeName = null;
    String strAttributeValue = null;
    String strRouteNodeID = null;
    Map mapRelAttributesToSet = null;
    final String SELECT_REL_ATTRIBUTE_ROUTE_TASK_USER = DomainRelationship.getAttributeSelect(DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
    final String SELECT_REL_ATTRIBUTE_TITLE = DomainRelationship.getAttributeSelect(DomainObject.ATTRIBUTE_TITLE);

    // We could have found all the user objects and connect them simultaneously. But there might be multiple tasks to a same user. In this scenario, when all the users are connected,
    // we will not know for which relationship attributes are to be updated. So find one user (i.e. task) and complete it, then go for next user (i.e. task).

    for (Iterator itrTasks = mlTasks.iterator(); itrTasks.hasNext();) {

        // Get each task in route template
        mapTask = (Map)itrTasks.next();

        // Begin : Bug 347000 : Code modification
        // Check if all the tasks are assigned
        strUserType = (String)mapTask.get(DomainObject.SELECT_TYPE);
        strRouteTaskUser = (String)mapTask.get(SELECT_REL_ATTRIBUTE_ROUTE_TASK_USER);
        if (DomainObject.TYPE_ROUTE_TASK_USER.equals(strUserType)) {
            if (strRouteTaskUser == null || "".equals(strRouteTaskUser.trim())) {
                throw new Exception(STRING_ROUTE_CANNOT_BE_ADDED_INVALID_ROUTE_TEMPLATE);
            }
        }
        
        //Check if the task has title
        strTaskTitle = (String)mapTask.get(SELECT_REL_ATTRIBUTE_TITLE);
        if (strTaskTitle == null || "".equals(strTaskTitle.trim())) {
            throw new Exception(STRING_ROUTE_CANNOT_BE_ADDED_INVALID_ROUTE_TEMPLATE);            
        }
        // End : Bug 347000 : Code modification
        
        // Create the same tasks for route object
        strUserId = (String)mapTask.get(DomainObject.SELECT_ID);
        toObject = new DomainObject(strUserId);
        dmoRelationship = DomainRelationship.connect(context, fromObject, DomainObject.RELATIONSHIP_ROUTE_NODE, toObject);

        // Copy all the attributes from route template Route Node relationship to Route
        mapRelAttributesToSet = new HashMap();
        for (Iterator itrAttributes = mapRelAttributes.keySet().iterator(); itrAttributes.hasNext();) {
            strAttributeName = (String)itrAttributes.next();
            strAttributeValue = (String)mapTask.get(DomainRelationship.getAttributeSelect(strAttributeName));
            mapRelAttributesToSet.put(strAttributeName, strAttributeValue);
        }//for

        dmoRelationship.setAttributeValues(context, mapRelAttributesToSet);
    }//for

    // Update the route node relationship ids on the relationship attribute
    strRelPattern = DomainObject.RELATIONSHIP_ROUTE_NODE;
    strTypePattern = "*";
    slBusSelects = new StringList();
    slRelSelects = new StringList(DomainRelationship.SELECT_ID);
    getTo = false;
    getFrom = true;
    nRecurseToLevel = (short)1;
    strObjectWhere = "";
    strRelWhere = "";

    MapList mlRouteNodeRelInfo = route.getRelatedObjects(context, strRelPattern,
                                    strTypePattern,
                                    slBusSelects,
                                    slRelSelects,
                                    getTo,
                                    getFrom,
                                    nRecurseToLevel,
                                    strObjectWhere,
                                    strRelWhere);
    Map mapRouteNodeRelInfo = null;
    String strRouteNodeRelId = null;
    DomainRelationship dmlRouteNode = null;
    for (Iterator itrRouteNodeRelInfo = mlRouteNodeRelInfo.iterator(); itrRouteNodeRelInfo.hasNext();) {
        mapRouteNodeRelInfo = (Map)itrRouteNodeRelInfo.next();
        strRouteNodeRelId = (String)mapRouteNodeRelInfo.get(DomainRelationship.SELECT_ID);

        dmlRouteNode = new DomainRelationship(strRouteNodeRelId);
        strRouteNodeRelId = MqlUtil.mqlCommand(context, "print connection $1 select $2 dump", strRouteNodeRelId, "physicalid");
        dmlRouteNode.setAttributeValue(context, DomainObject.ATTRIBUTE_ROUTE_NODE_ID, strRouteNodeRelId);
    }

    return strRouteId;
}
%>

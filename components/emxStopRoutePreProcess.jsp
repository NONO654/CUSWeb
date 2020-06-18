<%--  emxStopRoutePreProcess.jsp   -   PreProcess page for Manual-Stop functionality

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxStopRoutePreProcess.jsp.rca 1.3.3.2 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<!-- Java script functions -->

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<!-- Page display code here -->

<%
    //
    // Java code with error handling
    //
    try {
        String strRouteId = emxGetParameter(request, "objectId");
        boolean isStateBased=isStateBased(context, strRouteId);
        boolean isSubRouteStateBased=false;
        com.matrixone.apps.common.Route rtObj   = new com.matrixone.apps.common.Route();
        rtObj.setId(strRouteId);
        MapList mlSubRoutes = rtObj.getAllSubRoutes(context);
        Iterator it=mlSubRoutes.iterator();
        while(it.hasNext())
        {
            Hashtable hashTable=(Hashtable)it.next();
            String routeId=(String)hashTable.get(DomainObject.SELECT_ID);
            isSubRouteStateBased=isStateBased(context, routeId);
        	if(isSubRouteStateBased)
        		break;
        }      
        if (isStateBased) {
        	if(isSubRouteStateBased){
%>
            <SCRIPT LANGUAGE="JavaScript">
            <!--
                 emxShowModalDialog("emxRouteStopDemoteConnectedObjectDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strRouteId)%>&demoteObjectKey=RouteAndSubRoute",570,320);
            //-->
            </SCRIPT>
<%
        	}else{
%>    
			<SCRIPT LANGUAGE="JavaScript">
            <!--
                 emxShowModalDialog("emxRouteStopDemoteConnectedObjectDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strRouteId)%>&demoteObjectKey=OnlyRoute",570,320);
            //-->
            </SCRIPT>
<%
        }
        }
        else {
        	if(isSubRouteStateBased){
%>
                <SCRIPT LANGUAGE="JavaScript">
                <!--
                     emxShowModalDialog("emxRouteStopDemoteConnectedObjectDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strRouteId)%>&demoteObjectKey=OnlySubRoute",570,320);
                //-->
                </SCRIPT>
    <%
        	}else{
%>
            <SCRIPT LANGUAGE="JavaScript">
            <!--
                 
                 submitWithCSRF("emxStopRouteProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context, strRouteId)%>&demoteObjectKey=none", window);
            //-->
            </SCRIPT>
<%
        }
        }


            // Do something here
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
 * Checks whether the connected route is state based
 * @param context The Matrix Context object
 * @param strRouteId The id of Route
 * @returns a boolean value
 * @throws Exception if operation fails
 */
private static boolean isStateBased(Context context, String strRouteId) throws Exception {
    if (context == null) {
        throw new Exception("Invalid context");
    }
    if (strRouteId == null || "".equals(strRouteId) || "null".equals(strRouteId)) {
        throw new Exception("Invalid strRouteId");
    }

    DomainObject domainObject = new DomainObject(strRouteId);

    StringList slBusSelects = new StringList();

    StringList slRelSelects = new StringList();
    slRelSelects.add(DomainRelationship.getAttributeSelect(DomainObject.ATTRIBUTE_ROUTE_BASE_STATE));

    String strRelPattern = DomainObject.RELATIONSHIP_OBJECT_ROUTE;
    String strTypePattern = "*";
    boolean getTo = true;
    boolean getFrom = false;
    short nRecurseToLevel = (short)1;
    String strObjectWhere = null;
    String strRelWhere = null;

    MapList mlObjects = domainObject.getRelatedObjects(context,
                                                     strRelPattern,
                                                     strTypePattern,
                                                     slBusSelects,
                                                     slRelSelects,
                                                     getTo,
                                                     getFrom,
                                                     nRecurseToLevel,
                                                     strObjectWhere,
                                                     strRelWhere);

    boolean isStateBased = false;
    Map mapInfo = null;
    String strRouteBaseState = null;
    for (Iterator itrTasks = mlObjects.iterator(); itrTasks.hasNext();) {
        mapInfo = (Map)itrTasks.next();

        strRouteBaseState = (String)mapInfo.get(DomainRelationship.getAttributeSelect(DomainObject.ATTRIBUTE_ROUTE_BASE_STATE));

        if ( !(strRouteBaseState == null || "".equals(strRouteBaseState) || "Ad Hoc".equalsIgnoreCase(strRouteBaseState))) {
            isStateBased = true;
            break;
        }
    }
    return isStateBased;
}

%>

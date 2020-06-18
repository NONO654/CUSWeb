<%--  emxTeamEditRouteTaskProcess.jsp   -   Edit Details of Tasks
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxEditRouteTemplateTaskProcess.jsp.rca 1.8 Wed Oct 22 16:18:36 2008 przemek Experimental przemek $"
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>

<%
  RouteTemplate routeTemplate = (RouteTemplate)DomainObject.newInstance(context,DomainObject.TYPE_ROUTE_TEMPLATE);
  DomainRelationship domainRel = DomainRelationship.newInstance(context);
  String routeId          = emxGetParameter(request,"routeId");
  String taskId           = emxGetParameter(request,"taskId");
  String routeNodeId      = emxGetParameter(request,"routeNodeId");

  String taskCreated      = emxGetParameter(request,"taskCreated");
  String allowDelegation  = emxGetParameter(request,"allowDelegation");
  String comboAssignee    = emxGetParameter(request,"comboAssignee");
  String txtOldAssigneeId = emxGetParameter(request,"txtOldAssigneeId");
  String routeAction      = emxGetParameter(request,"routeAction");
  String instructions     = emxGetParameter(request,"instructions");
  String comments         = emxGetParameter(request,"comments");

  String sNewAssigneeId = comboAssignee.substring(0, comboAssignee.indexOf("#"));
  String sNewAsigneeName = comboAssignee.substring(comboAssignee.indexOf("#") + 1);

  //the details are in the Route Node Rel
  routeTemplate.setId(routeId);
  String templateState = routeTemplate.getInfo(context,DomainObject.SELECT_CURRENT);
  domainRel = DomainRelationship.newInstance(context,routeNodeId);
  Map taskMap = domainRel.getAttributeMap(context);
  String taskDueDate = (String)taskMap.get(routeTemplate.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
  String taskAllowDelegation = (String)taskMap.get(routeTemplate.ATTRIBUTE_ALLOW_DELEGATION);
  String taskAction= (String)taskMap.get(routeTemplate.ATTRIBUTE_ROUTE_ACTION);
  String taskInstructions = (String)taskMap.get(routeTemplate.ATTRIBUTE_ROUTE_INSTRUCTIONS);

  DomainObject assigneeObject = DomainObject.newInstance(context,sNewAssigneeId);

  //set route task user attribute
  String sSymbolicRouteTaskUser = "";
  if ((DomainObject.TYPE_ROUTE_TASK_USER).equals(assigneeObject.getType(context)))
  {
    try{
         sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "role", sNewAsigneeName, true);
         if (sSymbolicRouteTaskUser == null || "".equals(sSymbolicRouteTaskUser) || "null".equals(sSymbolicRouteTaskUser)) {
            sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sNewAsigneeName, true);
         }
       } catch (FrameworkException fe){

       }
  } else {
      sSymbolicRouteTaskUser = "";
  }

  HashMap attrMap = new HashMap();
  attrMap.put(DomainObject.ATTRIBUTE_ROUTE_TASK_USER,sSymbolicRouteTaskUser);
  attrMap.put(DomainObject.ATTRIBUTE_ALLOW_DELEGATION,allowDelegation);
  attrMap.put(DomainObject.ATTRIBUTE_ROUTE_ACTION,routeAction);
  attrMap.put(DomainObject.ATTRIBUTE_ROUTE_INSTRUCTIONS,instructions);
  attrMap.put(DomainObject.ATTRIBUTE_COMMENTS,comments);

  if(templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE)) {
  attrMap.put("Assignee",sNewAssigneeId);
    Map revisedInfo = routeTemplate.revise(context,routeNodeId,attrMap);
    routeId = (String)revisedInfo.get("ObjectId");
    routeNodeId = (String)revisedInfo.get("RelationshipId");
  } else {
    domainRel.setAttributeValues(context, attrMap);
    if(!txtOldAssigneeId.equals(sNewAssigneeId)) {
       assigneeObject.open(context);
       domainRel.modifyTo(context, routeNodeId, assigneeObject);
       //routeTemplate.changeOwner(context, sNewAsigneeName);
       assigneeObject.close(context);
    }
  }
%>

<script language="javascript">
  parent.window.getWindowOpener().parent.window.getWindowOpener().location.reload();
  //parent.window.getWindowOpener().parent.window.getWindowOpener().parent.parent.location.href = "emxTaskSummaryFS.jsp?routeId=<%=routeId%>";
  parent.window.getWindowOpener().parent.window.location.href="emxRouteTaskDetailsFS.jsp?routeId=<%=XSSUtil.encodeForURL(context, routeId)%>&taskId=<%=XSSUtil.encodeForURL(context, taskId)%>&routeNodeId=<%=XSSUtil.encodeForURL(context, routeNodeId)%>&taskCreated=<%=XSSUtil.encodeForURL(context, taskCreated)%>";
  window.closeWindow();
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

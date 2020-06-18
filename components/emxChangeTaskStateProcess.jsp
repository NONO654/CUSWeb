   <%--  emxChangeTaskStateProcess.jsp   -  Promoting Task to Complete State
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,
    Inc.  Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxChangeTaskStateProcess.jsp.rca 1.10 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $
 --%>

 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@include file = "emxRouteInclude.inc"%>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<%
     String attrReviewComments         = PropertyUtil.getSchemaProperty(context, "attribute_ReviewersComments");
     String attrReviewCommentsNeeded   = PropertyUtil.getSchemaProperty(context, "attribute_ReviewCommentsNeeded");
     String attrTaskCommentsNeeded     = PropertyUtil.getSchemaProperty(context, "attribute_TaskCommentsNeeded");
     String taskId                     =           emxGetParameter(request, "taskId");

     String frompage           = emxGetParameter(request, "frompage");


     String reviewTask         = "";
     String reviewComments     = "";
     String strReviewTask      ="No";
     String routeNodeId        ="";

     Route route = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
     DomainRelationship domainRel = DomainRelationship.newInstance(context);

    //Getting the attributes from the Task Object
     StringList selectStmt = new StringList();
     selectStmt.addElement("attribute[" + DomainObject.ATTRIBUTE_REVIEW_TASK + "]");
     selectStmt.addElement("attribute[" + attrReviewComments + "]");
     selectStmt.addElement("attribute[" + route.ATTRIBUTE_ROUTE_NODE_ID + "]");

     BusinessObject task = new BusinessObject(taskId);
     BusinessObjectWithSelect boSelect = null;
     boSelect = task.select(context, selectStmt);

     reviewTask         = boSelect.getSelectData("attribute[" + DomainObject.ATTRIBUTE_REVIEW_TASK + "]");
     reviewComments     = boSelect.getSelectData("attribute[" + attrReviewComments + "]");
     routeNodeId        = boSelect.getSelectData("attribute[" + route.ATTRIBUTE_ROUTE_NODE_ID + "]");

     String routeId = emxGetParameter(request, "routeId");

     if (!"".equals(routeId)) {
       route.setId(routeId);
       //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
       routeNodeId = route.getRouteNodeRelId(context, routeNodeId);
      }

     String inboxTask = emxGetParameter(request, "InboxTask");
     String taskStatus = emxGetParameter(request, "approvalStatus");
     String promote = emxGetParameter(request, "promote");
     String ReviewComments = emxGetParameter(request,"ReviewerComments");

     String strApprovalStatusAttr = PropertyUtil.getSchemaProperty(context, "attribute_ApprovalStatus" );
   // open the task
   task.open(context);
   String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_InboxTask");
   if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
     MailUtil.setTreeMenuName(context, treeMenu );
   }

   // promote task object
   if ("Promote".equalsIgnoreCase(promote)) {
      task.promote(context);
      if(ReviewComments != null)
      {
       AttributeList attrList1 = new AttributeList();
       attrList1.addElement(new Attribute(new AttributeType(attrReviewComments), ReviewComments));
       task.setAttributes(context,attrList1);
      }
      InboxTask.setTaskTitle(context, routeId);

     if (!"".equals(routeId)) {
      treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.emxTreeAlternateMenuName.type_Route");
      if(  treeMenu  != null && !"null".equals( treeMenu  ) && !"".equals( treeMenu )) {
            MailUtil.setTreeMenuName(context, treeMenu );
      }
     }
   }
   else // Demote The Task Object
   {
      task.demote(context);
      AttributeList attrList1 = new AttributeList();
      attrList1.addElement(new Attribute(new AttributeType(attrReviewCommentsNeeded), "Yes"));
      attrList1.addElement(new Attribute(new AttributeType(attrTaskCommentsNeeded), "Yes"));
      attrList1.addElement(new Attribute(new AttributeType(attrReviewComments), ReviewComments));
      task.setAttributes(context,attrList1);

      try{
        domainRel             = new DomainRelationship(routeNodeId);
        Map attrMap           = new Hashtable();

        attrMap.put(attrReviewCommentsNeeded,"Yes");
        domainRel.setAttributeValues(context, routeNodeId, attrMap);
      }
      catch(Exception ex){
     }

   }
   task.close(context);
 %>
   <form name="newForm" target="_parent">
   <body>
 <%
 if( (inboxTask != null)&&(inboxTask.equals("true")) ) {
 %>
       <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=taskId%></xss:encodeForHTMLAttribute>" />
       <input type="hidden" name="taskId" value="<xss:encodeForHTMLAttribute><%=taskId%></xss:encodeForHTMLAttribute>" />
       <input type="hidden" name="taskCreated" value="yes" />
       <input type="hidden" name="InboxTask" value="<xss:encodeForHTMLAttribute><%=inboxTask%></xss:encodeForHTMLAttribute>" />
 <%
     } else {
 %>
       <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
       <input type="hidden" name="taskCreated" value="no" />
       <input type="hidden" name="InboxTask" value="<xss:encodeForHTMLAttribute><%=inboxTask%></xss:encodeForHTMLAttribute>" />
       <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=taskId%></xss:encodeForHTMLAttribute>" />
 <%
     }
 %>
</body>
   </form>

   <script language="javascript">

   <%
			    frompage = com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(frompage) ? "" : frompage;
   				if(frompage.equalsIgnoreCase("RouteTask"))
                {
   %>

     document.newForm.action = "emxRouteTaskDetailsFS.jsp";
     document.newForm.submit();
     <%}else if(frompage.equalsIgnoreCase("TaskDetails")){
                 %>

                document.newForm.action = "emxTaskDetailsFS.jsp";
            document.newForm.submit();
     <%} else {%>
     		parent.location.href = parent.location.href;
     <%
      }
     %>
  </script>

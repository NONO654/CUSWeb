<%--  emxTeamDeleteTask.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxDeleteTask.jsp.rca 1.17 Wed Oct 22 16:17:59 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.framework.ui.UIUtil"%>
<script language="javascript" src="../components/emxComponentsJSFunctions.js"></script>

<%
boolean isResponsibleRoleEnabled=com.matrixone.apps.common.InboxTask.checkIfResponsibleRoleEnabled(context);String strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeInstructions");

  String srcPg       = emxGetParameter(request, "srcPg");
  String sCheckBoxValues[]    = emxGetParameterValues(request, "chkItem1");
  sCheckBoxValues = sCheckBoxValues != null ? sCheckBoxValues : 
      com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
  String sRouteId        = emxGetParameter(request,"objectId");
//modified for 316923 Adhoc issue start
  String routeNode[]          = emxGetParameterValues(request, "routeNode");
  String routeOrder[]         = emxGetParameterValues(request, "routeOrder");
  String routeAction[]        = emxGetParameterValues(request, "routeAction");
  String routeInstructions[]  = emxGetParameterValues(request, "routeInstructions");
  String routeTime[]          = emxGetParameterValues(request,"routeTime");
  String taskName[]           = emxGetParameterValues(request,"taskName");
  String strDeltaOffset[]     = emxGetParameterValues(request, "duedateOffset");
  String strDeltaOffsetFrom[] = emxGetParameterValues(request, "duedateOffsetFrom");
  String recepientList[] = emxGetParameterValues(request, "recepientList");
  //Added for Bug 330196 NOV 15 2007
  String strPersonId[]        =  emxGetParameterValues(request, "personId");
  // End of Bug 330196 NOV 15 2007
  String routeNodes           = "";
   
  boolean bDeltaDueDate       = false;

    try {
    // read the Member list passed in

    String routeScheduledCompletionDate;
    String sDueDateOption                   = "";
    String assigneeDueDate                  = "No";
    //Added for Bug 330196 OCT 12 2007
    String sAllowDelegation                   = "FALSE";
    String sReviewTask                   = "No";
    //End for Bug 330196 OCT 12 2007
    Integer integerType                     = null;
    String iString                          = "";

    Relationship routeObjectRel                 = null;
    Attribute routeActionAttribute              = null;
    Attribute routeOrderAttribute               = null;
    Attribute routeInstructionsAttribute        = null;
    Attribute routeScheduledCompletionAttribute = null;
    Attribute routeAssigneeDueDateAttribute     = null;
    Attribute routeDueDateOffsetAttribute       = null;
    Attribute routeDueDateOffsetFromAttribute   = null;
    Attribute taskNameAttribute                 = null;
    Attribute routeAllowDelegationAttribute     = null;
    Attribute routeReviewTaskAttribute          = null;
    AttributeList attrList                      = null;

    

    if (routeNode != null) {
      //preload lookup strings
        String TaskAssignee = null;
        String sAssigneeType = null;
        String sAssignee = null;
        StringTokenizer sAssigneeToken = null;
        DomainObject newPersonObject = DomainObject.newInstance(context);
      for (int i = 0; i < routeNode.length; i++) {
        attrList = new AttributeList();

        integerType = new Integer(i);
        iString = integerType.toString();

        // set route action
        routeActionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_ACTION),routeAction[i]);
        attrList.addElement(routeActionAttribute);
        // Added for Bug 330196 on NOV 15 2007
        TaskAssignee = strPersonId[i];
        if(TaskAssignee.indexOf("~") != -1)
        {
            sAssigneeToken    = new StringTokenizer(TaskAssignee, "~");
            sAssigneeType       = (String)sAssigneeToken.nextToken();
            if(sAssigneeToken.hasMoreTokens()) {
                sAssignee     = (String)sAssigneeToken.nextToken();
            }
        }
        else if(TaskAssignee.indexOf("#")!=-1)
        {
            sAssigneeToken    = new StringTokenizer(TaskAssignee, "#");
            sAssignee       = (String)sAssigneeToken.nextToken();
            if(sAssigneeToken.hasMoreTokens()) {
            	sAssigneeType     = (String)sAssigneeToken.nextToken();
            }
            if (sAssigneeType == null) {
                sAssigneeType = "none";
            }
            if(UIUtil.isNotNullAndNotEmpty(sAssigneeType) && FrameworkUtil.isUserGroupObject(context,sAssigneeType)){
            	sAssigneeType = "UserGroup";
            }else if(!"none".equalsIgnoreCase(sAssigneeType))
            {
                String cmd = MqlUtil.mqlCommand(context, "print user \"" + sAssigneeType + "\" select isaperson isarole isagroup dump |");
                boolean isPerson = "TRUE|FALSE|FALSE".equalsIgnoreCase(cmd);
                boolean isRole = "FALSE|TRUE|FALSE".equalsIgnoreCase(cmd);
                boolean isGroup = "FALSE|FALSE|TRUE".equalsIgnoreCase(cmd);
                if(isPerson)
                {
                    sAssigneeType = "Person";
                }
                else if(isRole)
                {
                    sAssignee = FrameworkUtil.getAliasForAdmin(context, "role", sAssigneeType, true);
                    sAssigneeType = "Role";
                }
                else if(isGroup)
                {
                    sAssignee = FrameworkUtil.getAliasForAdmin(context, "group", sAssigneeType, true);
                    sAssigneeType = "Group";
                }
            }
        }

        DomainRelationship DoRelShip = new DomainRelationship(routeNode[i]);
        DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER, DomainConstants.TEAM);
        rtaskUser.createObject(context,DomainConstants.TYPE_ROUTE_TASK_USER,null,null,DomainObject.POLICY_ROUTE_TASK_USER,context.getVault().getName());
        if("Person".equalsIgnoreCase(sAssigneeType) ||  "UserGroup".equalsIgnoreCase(sAssigneeType))
        {
            newPersonObject.setId(sAssignee);
            DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
            DoRelShip.modifyTo(context,routeNode[i],newPersonObject);
        }else if("Role".equalsIgnoreCase(sAssigneeType) || "Group".equalsIgnoreCase(sAssigneeType))
        {
            DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,sAssignee);
            if(isResponsibleRoleEnabled&&null!=recepientList&&!recepientList[i].isEmpty()&&!recepientList[i].equals("Any")){
            	   rtaskUser=PersonUtil.getPersonObject(context, recepientList[i]);
           		  
       			 }
            DoRelShip.modifyTo(context,routeNode[i],rtaskUser);
        }
        else if("none".equalsIgnoreCase(sAssigneeType))
        {
            DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
            DoRelShip.modifyTo(context,routeNode[i],rtaskUser);
        }
        DoRelShip = null;
        sDueDateOption = emxGetParameter(request, "duedateOption"+iString);
        //End of Bug 330196 on NOV 15 2007
        //Added for Bug 330196 OCT 12 2007
        sAllowDelegation = emxGetParameter(request, "allowDelegation"+routeNode[i]);
        sReviewTask = emxGetParameter(request, "reviewTask"+routeNode[i]);

        if(sAllowDelegation == null || "null".equals(sAllowDelegation)){
         sAllowDelegation = "FALSE";
        }
        else
        {
            sAllowDelegation = "TRUE";
        }
        routeAllowDelegationAttribute = new Attribute(new AttributeType(Person.ATTRIBUTE_ALLOW_DELEGATION),sAllowDelegation);
        attrList.addElement(routeAllowDelegationAttribute);


        if(sReviewTask == null || "null".equals(sReviewTask)){
         sReviewTask = "No";
        }
        else
        {
            sReviewTask = "Yes";
        }
        routeReviewTaskAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_REVIEW_TASK),sReviewTask);
        attrList.addElement(routeReviewTaskAttribute);
        
        //End for Bug 330196 OCT 12 2007

        if(sDueDateOption == null || "null".equals(sDueDateOption)){
         sDueDateOption = "";
        }

        // set Due-Date option - calendar or Assignee-set
        assigneeDueDate = "No";
        if("assignee".equalsIgnoreCase(sDueDateOption)){
          assigneeDueDate = "Yes";
        }else{
          assigneeDueDate = "No";
        }
        routeAssigneeDueDateAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE),assigneeDueDate);
        attrList.addElement(routeAssigneeDueDateAttribute);

        // setting delta offset attributes.
        if("delta".equalsIgnoreCase(sDueDateOption)){
          bDeltaDueDate = true;
        }else{
          bDeltaDueDate = false;
        }

        if(bDeltaDueDate){
          if (strDeltaOffset[i] != null) {
            routeDueDateOffsetAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DUEDATE_OFFSET),strDeltaOffset[i]);
            attrList.addElement(routeDueDateOffsetAttribute);
            routeDueDateOffsetFromAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM),strDeltaOffsetFrom[i]);
            attrList.addElement(routeDueDateOffsetFromAttribute);
          }
       }else{
         // reset delta offset attributes, as now the option has changed.
         routeDueDateOffsetAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DUEDATE_OFFSET),"");
         attrList.addElement(routeDueDateOffsetAttribute);
       }

        // set task name
        taskNameAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_TITLE),taskName[i]);
        attrList.addElement(taskNameAttribute);

        // set route order
        routeOrderAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_SEQUENCE),routeOrder[i]);
        attrList.addElement(routeOrderAttribute);
        
        // set route instructions
        routeInstructionsAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_INSTRUCTIONS),routeInstructions[i]);
        attrList.addElement(routeInstructionsAttribute);

        // set route scheduled completion date

        routeScheduledCompletionDate = emxGetParameter(request, "routeScheduledCompletionDate"+iString);
        String strDateTime = "";
        if (!"Yes".equals(assigneeDueDate) && !bDeltaDueDate && routeScheduledCompletionDate != null && !routeScheduledCompletionDate.equals("") ) {

          strDateTime = routeScheduledCompletionDate + " " + routeTime[i];

          double clientTZOffset           = (new Double((String)session.getValue("timeZone"))).doubleValue();

          strDateTime = eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate,routeTime[i],clientTZOffset,request.getLocale());
         }else {
            strDateTime = "";
         }

         routeScheduledCompletionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE),strDateTime);
         attrList.addElement(routeScheduledCompletionAttribute);

        routeObjectRel = new Relationship(routeNode[i]);
        routeObjectRel.open(context);

       
        routeNodes += routeNode[i] + "~";
        routeObjectRel.setAttributes(context,attrList);
        routeObjectRel.close(context);
      }
    }
  } catch (Exception ex ){

    session.putValue("error.message"," " + ex);
  }
  ////modified for 316923 Adhoc issue end
    String newTaskIds                      = emxGetParameter(request,"newTaskIds");
        if (newTaskIds == null) 
            newTaskIds="";
	String isRouteTemplateRevised = emxGetParameter(request,"isRouteTemplateRevised");

  boolean isRouteTemplate     = false;

    try {

    //Start: Resume Process Modifications
        //
        // Find the tasks connected to route object but which are not connected to the person object (sideeffect of Resume Process)
        //
        final String SELECT_TASK_ASSIGNEE_ID = "from[" + DomainObject.RELATIONSHIP_PROJECT_TASK + "].to.id";
        final String SELECT_ATTRIBUTE_ROUTE_NODE_ID = "attribute[" + DomainObject.ATTRIBUTE_ROUTE_NODE_ID + "]";

        Route objRoute = (Route)DomainObject.newInstance(context, DomainObject.TYPE_ROUTE);
        objRoute.setId(sRouteId);

        StringList slBusSelect = new StringList(DomainObject.SELECT_ID);
        slBusSelect.add(SELECT_ATTRIBUTE_ROUTE_NODE_ID);
        slBusSelect.add(SELECT_TASK_ASSIGNEE_ID);

        StringList slRelSelect = new StringList();

        MapList mlRouteTasks = objRoute.getRouteTasks(context, slBusSelect, slRelSelect, null, false);

        // Filter the tasks for partially connected tasks
        MapList mlPartialTasks = new MapList();
        Map mapPartialTask = null;
        for (Iterator itrRouteTasks = mlRouteTasks.iterator(); itrRouteTasks.hasNext();) {
            mapPartialTask = (Map)itrRouteTasks.next();
            if (mapPartialTask.get(SELECT_TASK_ASSIGNEE_ID) == null) {
                mlPartialTasks.add(mapPartialTask);
            }
        }
        mlRouteTasks = null;
    //End: Resume Process Modifications


      for (int i = 0; i < sCheckBoxValues.length; i++) {
        String checkBoxValue = sCheckBoxValues[i];

        StringTokenizer stToken = ( null != srcPg && srcPg.equals("taskSummary")) ?
               					   new StringTokenizer(checkBoxValue, ",") : new StringTokenizer(checkBoxValue, "z");
        while (stToken.hasMoreTokens())
        {
          String relId = stToken.nextToken();
		  relId = FrameworkUtil.getRelIDfromPID(context, relId);  	//Added since Physical ID is coming in place of Object ID
          Relationship relationship = new Relationship(relId);
          // Modified on Oct 12 2007 to remove already deleted relation id's from the req parameter "newTaskIds"
          relId = relId.trim();
          if(newTaskIds.indexOf(relId)!=-1)
          {
                if(newTaskIds.startsWith(relId) && !newTaskIds.endsWith(relId))
                {
                    newTaskIds=newTaskIds.replace(relId+"|","");
                }
                else if(newTaskIds.endsWith(relId) && !newTaskIds.startsWith(relId))
                {
                    newTaskIds=newTaskIds.replace("|"+relId,"");
                }
                else if(!newTaskIds.startsWith(relId) && !newTaskIds.endsWith(relId))
                {
                    newTaskIds=newTaskIds.replace("|"+relId+"|","|");
                }
                else
                {
                    newTaskIds=newTaskIds.replace(relId,"");
                }
          }
          // End of modification on Oct 12 2007 to remove already deleted relation id's from the req parameter "newTaskIds"

          relationship.open(context);
          relationship.remove(context);
          relationship.close(context);
          while (stToken.hasMoreTokens())
          {
            String taskId = stToken.nextToken();
            BusinessObject boTask = new BusinessObject(taskId);
             // Modified on Oct 12 2007 to remove already deleted task id's from the req parameter "newTaskIds" 
            taskId = taskId.trim();
            if(newTaskIds.indexOf(taskId)!=-1)
            {
                if(newTaskIds.startsWith(taskId) && !newTaskIds.endsWith(taskId))
                {
                    newTaskIds=newTaskIds.replace(taskId+"|","");
                }
                else if(newTaskIds.endsWith(taskId) && !newTaskIds.startsWith(taskId))
                {
                    newTaskIds=newTaskIds.replace("|"+taskId,"");
                }
                else if(!newTaskIds.startsWith(taskId) && !newTaskIds.endsWith(taskId))
                {
                    newTaskIds=newTaskIds.replace("|"+taskId+"|","|");
                }
                else
                {
                    newTaskIds=newTaskIds.replace(taskId,"");
                }
             }
             // End of modification on Oct 12 2007 to remove already deleted task id's from the req parameter "newTaskIds"
            boTask.open(context);
            boTask.remove(context);
            boTask.close(context);
          }

          //
          // Due to Resume Process implememtation, there can be tasks which are connected to route object but not connected to
          // the person object, these tasks are reused in next reassignment. When the route node relationship will be removed,
          // such tasks must also be deleted.
          //
          for (Iterator itrPartialTasks = mlPartialTasks.iterator(); itrPartialTasks.hasNext();) {
                mapPartialTask = (Map)itrPartialTasks.next();
                if (relId.equals((String)mapPartialTask.get(SELECT_ATTRIBUTE_ROUTE_NODE_ID))) {
                    DomainObject.deleteObjects(context, new String[]{(String)mapPartialTask.get(DomainObject.SELECT_ID)});
                }
          }
        }
      }
      //Uncommented the commented code on Oct 12th 2007 since need this logic for Route template -  delete task to work and for adjusting the order of Task seq no. in Routes after deleting other tasks.
      if(sRouteId != null && !"".equals(sRouteId))
      {

        DomainObject domRoute = DomainObject.newInstance(context , sRouteId);
        if(domRoute.getType(context).equals(DomainConstants.TYPE_ROUTE)){
          Route routeObect =(Route)domRoute;
          routeObect.adjustSequenceNumber(context);
        }else{
          isRouteTemplate     = true;
        }

      }
      //Uncommented the code on Oct 12th 2007 since need this logic for Route template -  delete task to work and for adjusting the order of Task seq no. in Routes after deleting other tasks.

    } catch (Exception ex ){
      session.putValue("error.message",ex);

    }


  if (srcPg == null) {
    srcPg = "";
  }

  if ( (srcPg.equals("editAllTasks")) && (isRouteTemplate == false) ) {
%>
  <body>
    <form name="newForm" target="_parent">
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sRouteId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="sortName" value="true" />
      <input type="hidden" name="newTaskIds"    value="<xss:encodeForHTMLAttribute><%=newTaskIds%></xss:encodeForHTMLAttribute>" />
    </form>
  </body>
    <script language="javascript">
      document.newForm.action = "emxRouteEditAllTasksDialogFS.jsp";
      document.newForm.submit();
    </script>
<%
  } else {
%>
    <script language="Javascript">

      //
      // If the route template was active then the edit all tasks page would have created the new revision of route template object
      // Therfore, make sure that your replace the route template id from parent page's url while refreshing.
      //
      parent.location.href = changeURLParam(changeURLParam(changeURLParam(parent.location.href, "objectId", "<%=XSSUtil.encodeForURL(context, sRouteId)%>"), "newTaskIds",  "<%=XSSUtil.encodeForURL(context, newTaskIds)%>"), "isRouteTemplateRevised",  "<%=XSSUtil.encodeForURL(context, isRouteTemplateRevised)%>");

    </script>
<%
  }
%>

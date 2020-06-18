<%--  emxTeamEditRouteTaskProcess.jsp   -   Edit Details of Tasks
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxEditRouteTaskProcess.jsp.rca 1.22 Wed Oct 22 16:18:14 2008 przemek Experimental przemek $"
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>

<%
  DomainObject domainObject = DomainObject.newInstance(context);
  DomainRelationship domainRel = DomainRelationship.newInstance(context);
  String routeId          = emxGetParameter(request,"routeId");
  String taskId           = emxGetParameter(request,"taskId");

  String routeNodeId      = emxGetParameter(request,"routeNodeId");

  String taskCreated      = emxGetParameter(request,"taskCreated");
  String scheduledDate    = emxGetParameter(request,"scheduledDate");
  String allowDelegation  = emxGetParameter(request,"allowDelegation");
  String comboAssignee    = emxGetParameter(request,"comboAssignee");
  String txtOldAssigneeId = emxGetParameter(request,"txtOldAssigneeId");
  String routeAction      = emxGetParameter(request,"routeAction");
  String instructions     = emxGetParameter(request,"instructions");
  String routeTime        = emxGetParameter(request,"routeTime");
  String comments         = emxGetParameter(request,"comments");

  String attrRouteAction         = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String attrRouteInstruction    = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
  String attrRouteNodeID         = PropertyUtil.getSchemaProperty(context, "attribute_RouteNodeID");
  String attrTitle               = PropertyUtil.getSchemaProperty(context, "attribute_Title");
  String attrSequence            = PropertyUtil.getSchemaProperty(context, "attribute_RouteSequence");
  String attrCompletionDate      = PropertyUtil.getSchemaProperty(context, "attribute_ScheduledCompletionDate");
  String attrAllowDelegation     = PropertyUtil.getSchemaProperty(context, "attribute_AllowDelegation");
  String sAttrRouteTaskUser      = PropertyUtil.getSchemaProperty(context, "attribute_RouteTaskUser");
  String relRouteNode            = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
  String relProjectTask          = PropertyUtil.getSchemaProperty(context, "relationship_ProjectTask");
  String relRouteTemplates       = PropertyUtil.getSchemaProperty(context, "relationship_RouteTemplates");

  String typeRoute               = PropertyUtil.getSchemaProperty(context, "type_Route");
  String sTypeRouteTemplate      = PropertyUtil.getSchemaProperty(context, "type_RouteTemplate");
  String typePerson              = PropertyUtil.getSchemaProperty(context, "type_Person");
  String typeCompany             = PropertyUtil.getSchemaProperty(context, "type_Company");
  String typeInboxTask           = PropertyUtil.getSchemaProperty(context, "type_InboxTask");
  String sTypeRouteTaskUser      = PropertyUtil.getSchemaProperty(context, "type_RouteTaskUser");

  String taskDueDate         = "";
  String taskAllowDelegation = "";
  String taskTitle           = "";
  String taskSequence        = "";
  String taskAction          = "";
  String taskInstructions    = "";
  String projectTaskId       = "";
  String sType               = "";
  String sSymbolicRouteTaskUser = "";
  boolean bChange            = false;
  boolean bFlag              = false;
  String sPersonName = null;

  ExpansionWithSelect personSelect            = null;
  Pattern relPattern                          = null;
  Pattern typePattern                         = null;
  SelectList selectStmt                       = null;
  SelectList selectRelStmt                    = null;
  ExpansionWithSelect expWithRouteTemp        = null;
  RelationshipWithSelectItr relItr            = null;
  BusinessObject boGeneric                    = null;
  BusinessObject personObj                    = null;
  Relationship relationShipRouteNode          = null;
  Hashtable routeNodeAttributesTable          = new Hashtable();

  String timeZone = (String)session.getValue("timeZone");

  String sNewAssigneeId = comboAssignee.substring(0, comboAssignee.indexOf("#"));
  String sNewAsigneeName = comboAssignee.substring(comboAssignee.indexOf("#") + 1);

  String attrBracket  = "attribute[";
  String closeBracket = "]";
  int attrLen  = attrBracket.length() + closeBracket.length();
  String fromBracket  = "from[";
  String closeBracketId = "].id";
  int fromLen  = fromBracket.length() + closeBracketId.length();

  // if task object is created, the details are in the object
  if (taskCreated.equals("yes") &&
      taskId != null &&
      !taskId.equals(""))
  {
    domainObject.setId(taskId);
    StringBuffer selTaskDueDate = new StringBuffer(attrLen + domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE.length());
    selTaskDueDate.append(attrBracket);
    selTaskDueDate.append(domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
    selTaskDueDate.append(closeBracket);

    StringBuffer selTaskAllowDelegation = new StringBuffer(attrLen + domainObject.ATTRIBUTE_ALLOW_DELEGATION.length());
    selTaskAllowDelegation.append(attrBracket);
    selTaskAllowDelegation.append(domainObject.ATTRIBUTE_ALLOW_DELEGATION);
    selTaskAllowDelegation.append(closeBracket);

    StringBuffer selTaskAction = new StringBuffer(attrLen + attrRouteAction.length());
    selTaskAction.append(attrBracket);
    selTaskAction.append(attrRouteAction);
    selTaskAction.append(closeBracket);

    StringBuffer selTaskInstructions = new StringBuffer(attrLen + attrRouteInstruction.length());
    selTaskInstructions.append(attrBracket);
    selTaskInstructions.append(attrRouteInstruction);
    selTaskInstructions.append(closeBracket);

    StringBuffer selRouteNodeId = new StringBuffer(attrLen + attrRouteNodeID.length());
    selRouteNodeId.append(attrBracket);
    selRouteNodeId.append(attrRouteNodeID);
    selRouteNodeId.append(closeBracket);

    StringBuffer selProjectTaskId = new StringBuffer(fromLen + relProjectTask.length());
    selProjectTaskId.append(fromBracket);
    selProjectTaskId.append(relProjectTask);
    selProjectTaskId.append(closeBracketId);

    StringList busSelects = new StringList();
    busSelects.addElement(selTaskDueDate.toString());
    busSelects.addElement(selTaskAllowDelegation.toString());
    busSelects.addElement(selTaskAction.toString());
    busSelects.addElement(selTaskInstructions.toString());
    busSelects.addElement(selRouteNodeId.toString());
    busSelects.addElement(selProjectTaskId.toString());
    Map taskMap = domainObject.getInfo(context, busSelects);

    taskDueDate           = (String)taskMap.get(selTaskDueDate.toString());
    taskAllowDelegation   = (String)taskMap.get(selTaskAllowDelegation.toString());
    taskAction            = (String)taskMap.get(selTaskAction.toString());
    taskInstructions      = (String)taskMap.get(selTaskInstructions.toString());
    routeNodeId           = (String)taskMap.get(selRouteNodeId.toString());
    projectTaskId         = (String)taskMap.get(selProjectTaskId.toString());
  }
  else if (taskCreated.equals("no") &&
           routeNodeId != null &&
           !routeNodeId.equals(""))
  {
    //if task object is not created, the details are in the Route Node Rel
    domainObject.setId(routeId);
    domainRel = DomainRelationship.newInstance(context,routeNodeId);
    Map taskMap = domainRel.getAttributeMap(context);
    taskDueDate = (String)taskMap.get(domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
    taskAllowDelegation = (String)taskMap.get(domainObject.ATTRIBUTE_ALLOW_DELEGATION);
    taskAction= (String)taskMap.get(attrRouteAction);
    taskInstructions = (String)taskMap.get(attrRouteInstruction);
  }
  Map attrMap = new Hashtable();
  sType       = domainObject.getType(context);

  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();

  String strDateTime = "";
  if (scheduledDate != null &&
      !"".equals(scheduledDate) &&
      !"null".equals(scheduledDate))
  {
    strDateTime = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDateTime(scheduledDate, routeTime,clientTZOffset,request.getLocale());
  }

  if (!(taskDueDate.equals("") ||
        taskDueDate==null ||
        taskDueDate.equals("null")))
  {
    if ( ! taskDueDate.equals(strDateTime) ) {
      bChange = true;
      attrMap.put(domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,strDateTime);
    }
  }
  else
  {
      bChange = true;
      attrMap.put(domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,strDateTime);
  }

  if(!taskAllowDelegation.equalsIgnoreCase(allowDelegation))
  {
    bChange = true;
    attrMap.put(domainObject.ATTRIBUTE_ALLOW_DELEGATION, allowDelegation);
  }
  if(!taskAction.equals(routeAction))
  {
    bChange = true;
    attrMap.put(attrRouteAction, routeAction);
  }

  if(!taskInstructions.equals(instructions))
  {
    bChange = true;
    attrMap.put(attrRouteInstruction, instructions);
  }

  if(taskCreated.equals("yes") &&
     taskId != null &&
     !taskId.equals(""))
  {
    if(sType.equals(typeRoute) ||
       !bChange && sType.equals(sTypeRouteTemplate) ) {
      domainObject.setAttributeValues(context, attrMap);
      domainRel.setAttributeValues(context, routeNodeId, attrMap);
    }
   // if(!txtOldAssigneeId.equals(comboAssignee))  sNewAssigneeId
   DomainObject assigneeObject = DomainObject.newInstance(context,sNewAssigneeId);
   if(!txtOldAssigneeId.equals(sNewAssigneeId)) {
      assigneeObject.open(context);
      domainRel.modifyTo(context, routeNodeId, assigneeObject);
      domainRel.modifyTo(context, projectTaskId, assigneeObject);
      domainObject.setOwner(context, sNewAsigneeName);
      assigneeObject.close(context);

    }
    //set route task user attribute
    if (sTypeRouteTaskUser.equals(assigneeObject.getType(context)))
    {
      try
      {
          sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context,
                                                "role", sNewAsigneeName, true);
          if (sSymbolicRouteTaskUser == null ||
              "".equals(sSymbolicRouteTaskUser) ||
              "null".equals(sSymbolicRouteTaskUser))
          {
            sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sNewAsigneeName, true);
          }
        }
        catch (FrameworkException fe)
        {
        }
    } 
    else
    {
      sSymbolicRouteTaskUser = "";
    }
    attrMap.put(sAttrRouteTaskUser,sSymbolicRouteTaskUser);

    //update the attributes
    if (sType.equals(typeInboxTask))
    {
      domainObject.setAttributeValues(context, attrMap);
      domainRel.setAttributeValues(context, routeNodeId, attrMap);
    }
  }
  else if(taskCreated.equals("no") &&
          routeNodeId != null &&
          !routeNodeId.equals("") &&
          !sType.equals(sTypeRouteTemplate))
  {
    DomainObject assigneeObject = DomainObject.newInstance(context,sNewAssigneeId);
    if (!txtOldAssigneeId.equals(sNewAssigneeId))
    {
      domainRel.modifyTo(context, routeNodeId, assigneeObject);
    }

    if (sTypeRouteTaskUser.equals(assigneeObject.getType(context)))
    {
      try
      {
          sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "role", sNewAsigneeName, true);
          if (sSymbolicRouteTaskUser == null ||
              "".equals(sSymbolicRouteTaskUser) ||
              "null".equals(sSymbolicRouteTaskUser))
          {
            sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sNewAsigneeName, true);
          }
      }
      catch (FrameworkException fe)
      {
          sSymbolicRouteTaskUser = "";
      }

      if (sSymbolicRouteTaskUser == null ||
              "".equals(sSymbolicRouteTaskUser) ||
              "null".equals(sSymbolicRouteTaskUser))
      {
          sSymbolicRouteTaskUser = "";
      }
    } 
    else
    {
      sSymbolicRouteTaskUser = "";
    }

    attrMap.put(sAttrRouteTaskUser,sSymbolicRouteTaskUser);

    domainRel.setAttributeValues(context, attrMap);
  }

  // if the task attribute is changed then the route template object
  // should be revised
  if (bChange && sType.equals(sTypeRouteTemplate) ) {

    // to get the latest revision of the object
    String newDocId = FrameworkUtil.getLastRevision(context, routeId);
    BusinessObject boNewTemplate = new BusinessObject(newDocId);
    boNewTemplate.open(context);

    try {
      BusinessObject boRouteRevise = boNewTemplate.revise(context,boNewTemplate.getNextSequence(context),context.getVault().getName());

      // to get the person/company object connected to Route Template
      relPattern     = new Pattern(relRouteTemplates);
      typePattern    = new Pattern(typePerson);
      typePattern.addPattern(typeCompany);

      selectStmt    = new SelectList();
      selectRelStmt = new SelectList();

      expWithRouteTemp = domainObject.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),selectStmt,selectRelStmt,true, false, (short)1);
      relItr = new RelationshipWithSelectItr(expWithRouteTemp.getRelationships());

      // to connect the company/person object to Revised Route Template .
      while (relItr.next()) {
        boGeneric = relItr.obj().getFrom();
        try
        {
          boGeneric.connect(context,new RelationshipType(relRouteTemplates),true,boRouteRevise);
        }
        catch(Exception e)
        {
        }
      }
      Attribute routeActionAttribute              = null;
      Attribute routeInstructionsAttribute        = null;
      Attribute routeScheduledCompDate            = null;
      Attribute routeAllowDelegation              = null;
      Attribute routeTitle                        = null;
      Attribute routeSequence                     = null;
      AttributeList attrList                      = null;

      // to get the Route Node relationship connected to Route Template object
      relPattern   = new Pattern(relRouteNode);
      typePattern  = new Pattern(typePerson);
      SelectList selectPersonStmts = new SelectList();
      SelectList selectPersonRelStmts = new SelectList();
      selectPersonRelStmts.addAttribute(attrSequence);
      selectPersonRelStmts.addAttribute(attrTitle);
      selectPersonRelStmts.addAttribute(attrRouteInstruction);
      selectPersonRelStmts.addAttribute(attrRouteAction);
      selectPersonRelStmts.addAttribute(attrCompletionDate);
      selectPersonRelStmts.addAttribute(attrAllowDelegation);

      personSelect = domainObject.expandSelect(context,
                                               relPattern.getPattern(),
                                               typePattern.getPattern(),
                                               selectPersonStmts,
                                               selectPersonRelStmts,
                                               false,
                                               true,
                                               (short)1);
      relItr = new RelationshipWithSelectItr(personSelect.getRelationships());
      String sRouteNodeId = "";

      while (relItr != null && relItr.next())
      {
        if(relItr.obj().getTypeName().equals(relRouteNode))
        {
          personObj    = relItr.obj().getTo();
          sRouteNodeId = relItr.obj().getName();
          personObj.open(context);
          bFlag = false;
          try
          {
            // to connect the route template object and update the
            // attribute values
            if (sRouteNodeId.equals(taskId) )
              bFlag = true;
            relationShipRouteNode = boRouteRevise.connect(context, new RelationshipType(relRouteNode),true,personObj);
            personObj.close(context);

            routeNodeAttributesTable  =  relItr.obj().getRelationshipData();
            taskTitle = (String)routeNodeAttributesTable.get(attrBracket + attrTitle + closeBracket );
            taskSequence        = (String)routeNodeAttributesTable.get(attrBracket + attrSequence + closeBracket );
            taskAction          = (String)routeNodeAttributesTable.get(attrBracket + attrRouteAction + closeBracket );
            taskInstructions    = (String)routeNodeAttributesTable.get(attrBracket + attrRouteInstruction + closeBracket );
            taskDueDate         = (String)routeNodeAttributesTable.get(attrBracket + attrCompletionDate + closeBracket );
            taskAllowDelegation = (String)routeNodeAttributesTable.get(attrBracket + attrAllowDelegation + closeBracket );


            // updating the route node relationship values for Route Templae Object
            Relationship relationShipRouteNode1 = new Relationship(relationShipRouteNode.getName());
            attrList = new AttributeList();
            relationShipRouteNode1.open(context);

            // set title
            routeTitle  = new Attribute(new AttributeType(attrTitle),taskTitle);
            attrList.addElement(routeTitle);

            // set route order
            routeSequence = new Attribute(new AttributeType(attrSequence),taskSequence);
            attrList.addElement(routeSequence);

            // set route action
            routeActionAttribute = new Attribute(new AttributeType(attrRouteAction),routeAction);
            attrList.addElement(routeActionAttribute);

            // set route instructions
            routeInstructionsAttribute = new Attribute(new AttributeType(attrRouteInstruction),instructions);
            attrList.addElement(routeInstructionsAttribute);

            // set route scheduled completion date
            routeScheduledCompDate = new Attribute(new AttributeType(attrCompletionDate),taskDueDate);
            attrList.addElement(routeScheduledCompDate);

            // set allow delegation
            routeAllowDelegation = new Attribute(new AttributeType(attrAllowDelegation),allowDelegation);
            attrList.addElement(routeAllowDelegation);

            relationShipRouteNode1.setAttributes(context,attrList);
            relationShipRouteNode1.close(context);
          }
          catch(Exception e)
          {
          }
        }
      }
    }
    catch(Exception e)
    {
    }
  }
%>
<script language="javascript">
  parent.window.getWindowOpener().parent.window.location.href="emxRouteTaskDetailsFS.jsp?routeId=<%=XSSUtil.encodeForURL(context, routeId)%>&taskId=<%=XSSUtil.encodeForURL(context, taskId)%>&routeNodeId=<%=XSSUtil.encodeForURL(context, routeNodeId)%>&taskCreated=<%=XSSUtil.encodeForURL(context, taskCreated)%>";
  parent.window.close();
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

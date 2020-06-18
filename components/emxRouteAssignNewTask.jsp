<%--  emxRouteAssignNewTask.jsp   -  Creating the WorkSpace Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteAssignNewTask.jsp.rca 1.21 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%

   boolean isResponsibleRoleEnabled=com.matrixone.apps.common.InboxTask.checkIfResponsibleRoleEnabled(context);String strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeInstructions");

  DomainObject newPersonObject  = DomainObject.newInstance(context);
  DomainObject routeObject      = DomainObject.newInstance(context);
  DomainObject personObject     = DomainObject.newInstance(context);

  String routeId       = emxGetParameter(request, "objectId");
  String sTemplateId   = emxGetParameter(request,"templateId");
  String sTemplateName = emxGetParameter(request,"template");
  String fromPage      = emxGetParameter(request,"fromPage");
  String isTemplate    = emxGetParameter(request,"isTemplate");
  String taskRelIds    = emxGetParameter(request,"newTaskIds");
  if (taskRelIds == null)
    taskRelIds = "";

  if(fromPage == null) fromPage = "";

  String routeNode[]          = emxGetParameterValues(request, "routeNode");
  String routeOrder[]         = emxGetParameterValues(request, "routeOrder");
  String routeAction[]        = emxGetParameterValues(request, "routeAction");
  String routeInstructions[]  = emxGetParameterValues(request, "routeInstructions");
  String routeTime[]          = emxGetParameterValues(request,"routeTime");
  String taskName[]           = emxGetParameterValues(request,"taskName");
  String folderId             = emxGetParameter(request, "folderId");
  String pageNum              = emxGetParameter(request, "pageNum");
  String personId[]           = emxGetParameterValues(request,"personId");
  String strDeltaOffset[]     = emxGetParameterValues(request, "duedateOffset");
  String strDeltaOffsetFrom[] = emxGetParameterValues(request, "duedateOffsetFrom");
  String templateId           = emxGetParameter(request,"templateId");
  String template             = emxGetParameter(request,"template");
  String recepientList[] = emxGetParameterValues(request, "recepientList");

  String person               = "";
  String routeInst            = "";
  String routeOrd             = "";
  String routeAct             = "";
  String routeNodes           = "";

  String slctdd               = emxGetParameter(request,"slctdd");
  String slctmm               = emxGetParameter(request,"slctmm");
  String slctyy               = emxGetParameter(request,"slctyy");
  final String PROXY_GROUP_TYPE = PropertyUtil.getSchemaProperty(context,"type_GroupProxy");
  final String GROUP_TYPE = PropertyUtil.getSchemaProperty(context,"type_Group");
  boolean bDeltaDueDate       = false;

  // Set the domain object as Route to connect person.
  routeObject.setId(routeId);
  
  try {
    // read the Member list passed in

    String routeScheduledCompletionDate;
    String sDueDateOption                   = "";
    String assigneeDueDate                  = "No";

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
    AttributeList attrList                      = null;

    Date routeDateTime                          = new Date();

    //Place Holder for a Route Task User Object
    DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER);

    if (routeNode != null)
    {
        //preload lookup strings
        for (int i = 0; i < routeNode.length; i++)
        {
            attrList = new AttributeList();

            integerType = new Integer(i);
            iString = integerType.toString();

            // set route action
            routeActionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_ACTION),routeAction[i]);
            attrList.addElement(routeActionAttribute);

            sDueDateOption = emxGetParameter(request, "duedateOption"+iString);

            if(sDueDateOption == null || "null".equals(sDueDateOption))
            {
                sDueDateOption = "";
            }
            // set Due-Date option - calendar or Assignee-set
            assigneeDueDate = "No";
            if("assignee".equalsIgnoreCase(sDueDateOption))
            {
                assigneeDueDate = "Yes";
            }
            else
            {
                assigneeDueDate = "No";
            }
            routeAssigneeDueDateAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE),assigneeDueDate);
            attrList.addElement(routeAssigneeDueDateAttribute);

            // setting delta offset attributes.
            if("delta".equalsIgnoreCase(sDueDateOption))
            {
                bDeltaDueDate = true;
            }
            else
            {
                bDeltaDueDate = false;
            }
            if(bDeltaDueDate)
            {
                if (strDeltaOffset[i] != null)
                {
                    routeDueDateOffsetAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DUEDATE_OFFSET),strDeltaOffset[i]);
                    attrList.addElement(routeDueDateOffsetAttribute);
                    routeDueDateOffsetFromAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM),strDeltaOffsetFrom[i]);
                    attrList.addElement(routeDueDateOffsetFromAttribute);
                }
            }
            else
            {
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
            if (!"Yes".equals(assigneeDueDate) && !bDeltaDueDate && routeScheduledCompletionDate != null && !routeScheduledCompletionDate.equals("") )
            {
                strDateTime = routeScheduledCompletionDate + " " + routeTime[i];

                double clientTZOffset           = (new Double((String)session.getValue("timeZone"))).doubleValue();
                // Bug No : 295337
                strDateTime = eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate,routeTime[i],clientTZOffset,request.getLocale());
            }
            else
            {
                strDateTime = "";
            }
            // Bug No : 295337
            routeScheduledCompletionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE),strDateTime);
            attrList.addElement(routeScheduledCompletionAttribute);

            routeObjectRel = new Relationship(routeNode[i]);
            routeObjectRel.open(context);

            BusinessObject boPerson = routeObjectRel.getTo();
            boPerson.open(context);
            String sOldPersonId = boPerson.getObjectId();
            String objectType = boPerson.getTypeName();
            if(DomainObject.TYPE_PERSON.equals(objectType))
            {
                sOldPersonId= "Person~"+sOldPersonId;
            }else if (PROXY_GROUP_TYPE.equals(objectType) || GROUP_TYPE.equals(objectType)){
            	 sOldPersonId= "UserGroup~"+sOldPersonId;
            }
            else
            {
                String attrRouteTaskUser = FrameworkUtil.getRelAttribute(context, routeObjectRel, DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
                if(attrRouteTaskUser==null || "".equals(attrRouteTaskUser))
                {
                    sOldPersonId = "none~none";
                }
                else
                {
                    sOldPersonId = "Role~"+attrRouteTaskUser;
                }
            }
            boPerson.close(context);

            StringTokenizer tokenizer = new StringTokenizer(personId[i],"~");
            String persObject = tokenizer.nextToken();
            if ( !(sOldPersonId.equals(personId[i]))||(isResponsibleRoleEnabled&&null!=recepientList&&!recepientList[i].isEmpty()&&!recepientList[i].equals("Any")) )
            {
                DomainRelationship DoRelShip = DomainRelationship.newInstance(context,routeNode[i]);

                if("none".equals(persObject)) {
					// Route.getRouteTaskUserObject() creates RTU object if no RTU is already connected and returns if the boolean parameter is passed as true
					// If RTU is already connected then it returns the RTU object
                    rtaskUser = Route.getRouteTaskUserObject(context, routeObject, true);
                    
                    DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
                    DoRelShip.modifyTo(context,routeNode[i],rtaskUser);
                } else if("Role".equals(persObject) || "Group".equals(persObject)) {
					// Route.getRouteTaskUserObject() creates RTU object if no RTU is already connected and returns if the boolean parameter is passed as true
					// If RTU is already connected then it returns the RTU object
                    rtaskUser = Route.getRouteTaskUserObject(context, routeObject, true);
                    
                    DoRelShip.setAttributeValue(context, routeNode[i], DomainObject.ATTRIBUTE_ROUTE_TASK_USER, tokenizer.nextToken());
                     if(isResponsibleRoleEnabled&&null!=recepientList&&!recepientList[i].isEmpty()&&!recepientList[i].equals("Any")){
                        rtaskUser=PersonUtil.getPersonObject(context, recepientList[i]);
                  
					}
                    DoRelShip.modifyTo(context, routeNode[i], rtaskUser);
                } else {
                    newPersonObject.setId(tokenizer.nextToken());
                    DoRelShip.setAttributeValue(context, routeNode[i] ,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
                    DoRelShip.modifyTo(context, routeNode[i], newPersonObject);
                }
            }
            routeNodes += routeNode[i] + "~";
            routeObjectRel.setAttributes(context,attrList);
            routeObjectRel.close(context);
        }
    }
  } catch (Exception ex ){

    session.putValue("error.message"," " + ex);
  }

  String sPerson = PropertyUtil.getSchemaProperty(context, "type_Person");
  String objectId  = "";
 
  BusinessObject boRoute = new BusinessObject(routeId);
  Pattern relPattern     = new Pattern(DomainObject.RELATIONSHIP_ROUTE_NODE);
  Pattern typePattern    = new Pattern(DomainObject.TYPE_PERSON);
  typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);

  BusinessObject bo = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boRoute,relPattern.getPattern(),typePattern.getPattern(),false,true,null, "attribute[Route Task User].value==''");

  // If project Id is not null then the page is from workspace
  if ( bo != null ) {
    objectId = bo.getObjectId();
    personObject.setId(objectId);
  } else {

    String Idperson = PersonUtil.getPersonObjectID(context);
    personObject.setId(Idperson);

  }
  String taskRelId = "";
  try
  {
    DomainRelationship taskRel = routeObject.connectTo(context,DomainObject.RELATIONSHIP_ROUTE_NODE, personObject);
    taskRelId = taskRel.getName();

    if (!"".equals(taskRelIds))
    {
      taskRelIds += "|" + taskRelId;
    }
    else
    {
      taskRelIds = taskRelId;
    }

  }
  catch(Exception exp)
  {
    String sErrorMsg = i18nNow.getI18nString("emxComponents.Common.ConnectError", "emxComponentsStringResource",sLanguage) +  personObject.getName(context);
    session.putValue("error.message", sErrorMsg);
  }


%>
<html>
<body>
<form name="newForm" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sTemplateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=sTemplateName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="sortName" value="true"/>
  <input type="hidden" name="slctdd" value="<xss:encodeForHTMLAttribute><%=slctdd%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="slctmm" value="<xss:encodeForHTMLAttribute><%=slctmm%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="slctyy" value="<xss:encodeForHTMLAttribute><%=slctyy%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="addTasks" value="true"/>
  <input type="hidden" name="isTemplate" value="<xss:encodeForHTMLAttribute><%=isTemplate%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="newTaskIds" value="<xss:encodeForHTMLAttribute><%=taskRelIds%></xss:encodeForHTMLAttribute>"/>
</form>
<script language="javascript">

    document.newForm.action = "emxRouteEditAllTasksDialogFS.jsp";
    document.newForm.submit();

</script>
</body>
</html>

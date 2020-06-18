<%--  emxSortTaskList.jsp  --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxSortTaskList.jsp.rca 1.11 Wed Oct 22 16:18:01 2008 przemek Experimental przemek $
 --%>


<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<%
  DomainObject newPersonObject  = DomainObject.newInstance(context);

  String routeId              = emxGetParameter(request, "routeId");
  String projectId            = emxGetParameter(request, "objectId");
  String sTemplateId          = emxGetParameter(request,"templateId");
  String sTemplateName        = emxGetParameter(request,"template");
  String isTemplate           = emxGetParameter(request,"isTemplate");

  String sCheckBoxValues[]    = emxGetParameterValues(request, "chkItem1");

  String routeNode[]          = emxGetParameterValues(request, "routeNode");
  String routeOrder[]         = emxGetParameterValues(request, "routeOrder");
  String routeAction[]        = emxGetParameterValues(request, "routeAction");
  String routeInstructions[]  = emxGetParameterValues(request, "routeInstructions");
  String routeTime[]          = emxGetParameterValues(request,"routeTime");
  String taskName[]           = emxGetParameterValues(request,"taskName");
  String strDeltaOffset[]     = emxGetParameterValues(request, "duedateOffset");
  String strDeltaOffsetFrom[] = emxGetParameterValues(request, "duedateOffsetFrom");
  String folderId             = emxGetParameter(request, "folderId");
  String pageNum              = emxGetParameter(request, "pageNum");
  String sortName             = emxGetParameter(request, "sortName");
  String fromPage             = emxGetParameter(request,"fromPage");

  String newTaskIds                      = emxGetParameter(request,"newTaskIds");
        if (newTaskIds == null || "null".equals(newTaskIds)) 
            newTaskIds="";
  boolean bExecute            = false;
  boolean bDeltaDueDate       = false;

  String personId[]           = emxGetParameterValues(request,"personId");
  String templateId           = emxGetParameter(request,"templateId");
  String template             = emxGetParameter(request,"template");

  String person               = "";
  String routeInst            = "";
  String routeOrd             = "";
  String routeAct             = "";
  String routeNodes           = "";

  if(fromPage == null){
   fromPage = "";
  }

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
    Attribute taskNameAttribute                 = null;
    Attribute routeDueDateOffsetAttribute       = null;
    Attribute routeDueDateOffsetFromAttribute   = null;
    AttributeList attrList                      = null;

    Date routeDateTime = new Date();

    DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER);
    rtaskUser.createObject(context,DomainConstants.TYPE_ROUTE_TASK_USER,null,null,DomainObject.POLICY_ROUTE_TASK_USER,context.getVault().getName());

    if (routeNode != null) {
      //preload lookup strings

      for (int i = 0; i < routeNode.length; i++) {

        integerType = new Integer(i);
        iString = integerType.toString();

        sDueDateOption = emxGetParameter(request, "duedateOption"+iString);

        if(sDueDateOption == null || "null".equals(sDueDateOption)){
         sDueDateOption = "";
        }

        attrList = new AttributeList();

        // set route action
        routeActionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_ACTION),routeAction[i]);
        attrList.addElement(routeActionAttribute);

        // set Due-Date option - calendar or Assignee-set or delta
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

         

          double clientTZOffset           = (new Double((String)session.getValue("timeZone"))).doubleValue();
//Bug No:305966 Date :10-Jun-2005
 //         Date date1 = new Date(routeScheduledCompletionDate);
//          routeScheduledCompletionDate = (date1.getMonth()+1)+"/"+(date1.getDate())+"/"+(date1.getYear()+1900);
 //         routeScheduledCompletionDate = routeScheduledCompletionDate + " " + routeTime[i];
//Bug No:305966 Date :10-Jun-2005
          //Formatting Date to Ematrix Date Format
          strDateTime = eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate,routeTime[i],clientTZOffset,request.getLocale());  
        }else{
          strDateTime = "";
        }
        routeScheduledCompletionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE),strDateTime);
        attrList.addElement(routeScheduledCompletionAttribute);

        routeObjectRel = new Relationship(routeNode[i]);
        routeObjectRel.open(context);

        BusinessObject boPerson = routeObjectRel.getTo();
        boPerson.open(context);
        String sOldPersonId = boPerson.getObjectId();
        if(boPerson.getTypeName().equals(DomainObject.TYPE_PERSON)){
          sOldPersonId= "Person~"+sOldPersonId;
        }else{
          String attrRouteTaskUser = FrameworkUtil.getRelAttribute(context, routeObjectRel, DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
          if(attrRouteTaskUser==null || "".equals(attrRouteTaskUser)){
            sOldPersonId = "none~none";
          }else{
        	  String isRoleGroup = attrRouteTaskUser.substring(0,attrRouteTaskUser.indexOf("_"));
        	  if("role".equals(isRoleGroup)){
            sOldPersonId = "Role~"+attrRouteTaskUser;
                }else if("group".equals(isRoleGroup)){
                  sOldPersonId = "Group~"+attrRouteTaskUser;
                }
          }
        }

        boPerson.close(context);

        StringTokenizer tokenizer = new StringTokenizer(personId[i],"~");
        String persObject = tokenizer.nextToken();

        if ( !(sOldPersonId.equals(personId[i])) ) {
          DomainRelationship DoRelShip = DomainRelationship.newInstance(context,routeNode[i]);

          if("none".equals(persObject)){
            DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
            DoRelShip.modifyTo(context,routeNode[i],rtaskUser);
          }else if("Role".equals(persObject)){
            DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,tokenizer.nextToken());
            DoRelShip.modifyTo(context,routeNode[i],rtaskUser);
          }else{
            newPersonObject.setId(tokenizer.nextToken());
            DoRelShip.setAttributeValue(context,routeNode[i],DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
            DoRelShip.modifyTo(context,routeNode[i],newPersonObject);
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
%>
<html>
<body>
<form name="newForm" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sTemplateId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=sTemplateName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="sortName" value="<xss:encodeForHTMLAttribute><%=sortName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="addTasks" value="true" />
  <input type="hidden" name="isTemplate" value="<xss:encodeForHTMLAttribute><%=isTemplate%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=fromPage%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="newTaskIds" value="<xss:encodeForHTMLAttribute><%=newTaskIds%></xss:encodeForHTMLAttribute>"/>
</form>

<script language="javascript">
<%
  if(fromPage.equals("task")) {
%>
    document.newForm.action = "emxRouteEditAllTasksDialogFS.jsp";
    document.newForm.submit();
<%
  } else  {
%>
    document.newForm.action = "emxRouteWizardAssignTaskFS.jsp";
    document.newForm.submit();
<%
  }
%>

</script>
</body>
</html>

<%--  emxTeamAllowDelegation.jsp  --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxAllowDelegation.jsp.rca 1.15 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  DomainObject oldPersonObject = DomainObject.newInstance(context);
  DomainObject newPersonObject = DomainObject.newInstance(context);

  String srcPg         = emxGetParameter(request, "srcPg");
  String routeId       = emxGetParameter(request, "routeId");
  String projectId     = emxGetParameter(request, "objectId");
  String sTemplateId   = emxGetParameter(request,"templateId");
  String sTemplateName = emxGetParameter(request,"template");
  String portalMode    = emxGetParameter(request,"portalMode");

  String routeAllowDelegation = PropertyUtil.getSchemaProperty(context, "attribute_AllowDelegation");
  String sCheckBoxValues[]    = emxGetParameterValues(request, "chkItem1");

  String routeNode[]          = emxGetParameterValues(request, "routeNode");
  String routeOrder[]         = emxGetParameterValues(request, "routeOrder");
  String routeAction[]        = emxGetParameterValues(request, "routeAction");
  String routeInstructions[]  = emxGetParameterValues(request, "routeInstructions");
  String routeTime[]          = emxGetParameterValues(request,"routeTime");
  String taskName[]           = emxGetParameterValues(request,"taskName");
  String folderId             = emxGetParameter(request, "folderId");
  String pageNum              = emxGetParameter(request, "pageNum");
  boolean bExecute            = false;
  String personId[]           = emxGetParameterValues(request,"personId");
  String templateId           = emxGetParameter(request,"templateId");
  String template             = emxGetParameter(request,"template");
  String person = "";
  String routeInst="";
  String routeOrd="";
  String routeAct="";
  String routeNodes="";

  try {
    // read the Member list passed in

    String routeScheduledCompletionDate;

    String routeSequenceStr                 = PropertyUtil.getSchemaProperty(context, "attribute_RouteSequence");
    String routeActionStr                   = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
    String routeInstructionsStr             = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
    String routeScheduledCompletionDateStr  = PropertyUtil.getSchemaProperty(context, "attribute_ScheduledCompletionDate");
    String taskNameStr                      = PropertyUtil.getSchemaProperty(context, "attribute_Title");

    Relationship routeObjectRel = null;
    Attribute routeActionAttribute = null;
    Attribute routeOrderAttribute = null;
    Attribute routeInstructionsAttribute = null;
    Attribute routeScheduledCompletionAttribute = null;
    Attribute taskNameAttribute = null;
    AttributeList attrList = null;

    Date routeDateTime = new Date();
    if (routeNode != null) {
      //preload lookup strings
      for (int i = 0; i < routeNode.length; i++) {
        attrList = new AttributeList();

        // set route action
        routeActionAttribute = new Attribute(new AttributeType(routeActionStr),routeAction[i]);
        attrList.addElement(routeActionAttribute);

        // set task name
        taskNameAttribute = new Attribute(new AttributeType(taskNameStr),taskName[i]);
        attrList.addElement(taskNameAttribute);
        // set route order
        routeOrderAttribute = new Attribute(new AttributeType(routeSequenceStr),routeOrder[i]);
        attrList.addElement(routeOrderAttribute);
        // set route instructions
        routeInstructionsAttribute = new Attribute(new AttributeType(routeInstructionsStr),routeInstructions[i]);
        attrList.addElement(routeInstructionsAttribute);

        // set route scheduled completion date
        Integer integerType = new Integer(i);

        String iString = integerType.toString();
        routeScheduledCompletionDate = emxGetParameter(request, "routeScheduledCompletionDate"+iString);
        if ( routeScheduledCompletionDate != null && !routeScheduledCompletionDate.equals("") ) {
          double iTimeZone = (new Double((String)session.getValue("timeZone"))).doubleValue(); //60*60*1000 *-1;

          String strDateTime = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate, routeTime[i],iTimeZone,request.getLocale());
          routeScheduledCompletionAttribute = new Attribute(new AttributeType(routeScheduledCompletionDateStr),strDateTime);
          attrList.addElement(routeScheduledCompletionAttribute);
        }
        routeObjectRel = new Relationship(routeNode[i]);
        routeObjectRel.open(context);
        BusinessObject boPerson = routeObjectRel.getTo();
        boPerson.open(context);
        String sOldPersonId = boPerson.getObjectId();
        boPerson.close(context);
        if ( !(sOldPersonId.equals(personId[i])) ) {
          oldPersonObject.setId(sOldPersonId);
          newPersonObject.setId(personId[i]);
          DomainRelationship DoRelShip = DomainRelationship.newInstance(context,routeNode[i]);
          DoRelShip.modifyTo(context,routeNode[i],newPersonObject);
        }
        routeNodes += routeNode[i] + "~";
        routeObjectRel.setAttributes(context,attrList);
        routeObjectRel.close(context);
      }
    }
  } catch (Exception ex ){
    session.putValue("error.message"," " + ex);
    bExecute = true;
  }

  if ( sCheckBoxValues != null) {
    for (int i = 0; i < sCheckBoxValues.length; i++) {
      Relationship relationship = new Relationship(sCheckBoxValues[i]);
      AttributeList attributeList = new AttributeList();
      relationship.open( context );
      AttributeItr attributeItr = new AttributeItr( relationship.getAttributes( context ) );
      while( attributeItr.next() ) {
        Attribute attribute = attributeItr.obj();
        if (attribute.getName().equals(routeAllowDelegation)) {
          if ( attribute.getValue().equals("FALSE") ) {
            attribute.setValue("TRUE");
          } else {
            attribute.setValue("FALSE");
          }
          attributeList.add( attribute);
          relationship.setAttributes( context, attributeList );
          break;
        }
      }
      relationship.close( context );
    }
  }
%>
<body>
  <form name="newForm" target="_parent">
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sTemplateId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=sTemplateName%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="sortName" value="true" />
    <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" /> 
  </form>
</body>
<%
  if (srcPg == null){
    srcPg = "";
  }

  if (srcPg.equals("editAllTasks")) {
%>
    <script language="javascript">
      document.newForm.action = "emxEditAllTasksDialogFS.jsp";
      document.newForm.submit();
      //parent.window.getWindowOpener().location.reload();
      parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
    </script>

<%
  } else {
%>
    <script language="javascript">
      document.newForm.action = "emxRouteAssignTaskDialogFS.jsp";
      document.newForm.submit();
    </script>
<%
  }
%>

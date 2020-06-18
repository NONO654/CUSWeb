<%--  emxRouteAssignTaskProcess.jsp  --  Editing Route object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteAssignTaskProcess.jsp.rca 1.18 Wed Oct 22 16:18:09 2008 przemek Experimental przemek $
 --%>
<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>

<%

  String routeNode[]          = emxGetParameterValues(request, "routeNode");
  String routeOrder[]         = emxGetParameterValues(request, "routeOrder");
  String routeAction[]        = emxGetParameterValues(request, "routeAction");
  String routeInstructions[]  = emxGetParameterValues(request, "routeInstructions");
  String routeTime[]          = emxGetParameterValues(request,"routeTime");
  String taskName[]           = emxGetParameterValues(request,"taskName");
  String folderId             = emxGetParameter(request, "folderId");
  String routeId              = emxGetParameter(request, "routeId");
  String pageNum              = emxGetParameter(request, "pageNum");
  String projectId            = emxGetParameter(request, "objectId");
  String portalMode           = emxGetParameter(request,"portalMode");
  boolean bExecute            = false;
  String personId[]           = emxGetParameterValues(request,"personId");
  String templateId           = emxGetParameter(request,"templateId");
  String templateName         = emxGetParameter(request,"templateName");
  String person = "";
  String routeInst="";
  String routeOrd="";
  String routeAct="";
  String routeNodes="";
  String sRouteTaskUser = "";
  String sPersonId = "";
  String sPersonName = "";
  String sAssigneeType="";

  try {
    // read the Member list passed in
    String routeScheduledCompletionDate;

    String routeSequenceStr                 = Framework.getPropertyValue( session, "attribute_RouteSequence");
    String routeActionStr                   = Framework.getPropertyValue( session, "attribute_RouteAction");
    String routeInstructionsStr             = Framework.getPropertyValue( session, "attribute_RouteInstructions");
    String routeScheduledCompletionDateStr  = Framework.getPropertyValue( session, "attribute_ScheduledCompletionDate");
    String taskNameStr                      = Framework.getPropertyValue( session, "attribute_Title");
    String sAttrRouteTaskUser               = Framework.getPropertyValue( session, "attribute_RouteTaskUser");
    String sTypeRouteTaskUser               = Framework.getPropertyValue( session, "type_RouteTaskUser");
    String sRelRouteNode                    = Framework.getPropertyValue( session, "relationship_RouteNode");

    DomainObject oldPersonObject = DomainObject.newInstance(context);
    DomainObject newPersonObject = DomainObject.newInstance(context);

    Relationship routeObjectRel = null;
    Attribute routeActionAttribute = null;
    Attribute routeOrderAttribute = null;
    Attribute routeInstructionsAttribute = null;
    Attribute routeScheduledCompletionAttribute = null;
    Attribute taskNameAttribute = null;
    Attribute routeTaskUserAttribute = null;
    AttributeList attrList = null;
    Date routeDateTime = new Date();
    double iTimeZone = (new Double((String)session.getValue("timeZone"))).doubleValue(); //60*60*1000 *-1;

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


        /*
        * Modified to use the same code from emxEditAllTasksProcess.jsp
        */
        //SimpleDateFormat formatterTest = new SimpleDateFormat("M/d/yy hh:mm:ss a", Locale.US);

        //String strDateTime = routeScheduledCompletionDate + " " + routeTime[i];
        String strDateTime = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate, routeTime[i],iTimeZone,request.getLocale());

        //double clientTZOffset           = (new Double((String)session.getValue("timeZone"))).doubleValue();
        // adjust the time to GMT
        //strDateTime                     = strDateTime + " GMT";

        //Date currentTime                = formatterTest.parse(strDateTime);

        // get the equivalent server time
        //currentTime.setTime(currentTime.getTime() + (new Double(clientTZOffset*(1000*60*60))).intValue());

        //formatterTest  = new SimpleDateFormat ("M/d/yy hh:mm:ss a", Locale.US);
        //strDateTime    = formatterTest.format(currentTime);
        routeScheduledCompletionAttribute = new Attribute(new AttributeType(routeScheduledCompletionDateStr),strDateTime);
        attrList.addElement(routeScheduledCompletionAttribute);
        routeObjectRel = new Relationship(routeNode[i]);
        routeObjectRel.open(context);
        BusinessObject boPerson = routeObjectRel.getTo();
        boPerson.open(context);
        String sOldPersonId = boPerson.getObjectId();
        boPerson.close(context);

        sPersonId = personId[i].substring(0, personId[i].indexOf("#"));
        sPersonName = personId[i].substring(personId[i].indexOf("#") + 1);

        newPersonObject.setId(sPersonId);

        if (!(sOldPersonId.equals(sPersonId)) ) {
            oldPersonObject.setId(sOldPersonId);
            //String relationDisconnect = routeNode[i];
            DomainRelationship DoRelShip = DomainRelationship.newInstance(context,routeNode[i]);
            DoRelShip.modifyTo(context,routeNode[i],newPersonObject);
        }

        String sSymbolicRouteTaskUser = null;

        if (sTypeRouteTaskUser.equals(newPersonObject.getType(context))) {
          try{
            sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "role", sPersonName, true);
            if (sSymbolicRouteTaskUser == null || "".equals(sSymbolicRouteTaskUser) || "null".equals(sSymbolicRouteTaskUser)) {
              sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sPersonName, true);
              if (sAssigneeType.equals("")){
                sAssigneeType ="Group";
              }else{
                sAssigneeType +="~Group";
              }
            }
            else
            {
              if (sAssigneeType.equals("")){
                sAssigneeType ="Role";
              }else{
                sAssigneeType += "~Role";
              }
            }


          } catch (FrameworkException fe){

          }

          routeTaskUserAttribute = new Attribute(new AttributeType(sAttrRouteTaskUser),sSymbolicRouteTaskUser);
        }
        else {
          routeTaskUserAttribute = new Attribute(new AttributeType(sAttrRouteTaskUser),sSymbolicRouteTaskUser);
          if (sAssigneeType.equals("")){
            sAssigneeType ="Person";
          }else{
            sAssigneeType +="~Person";
          }

        }
        attrList.addElement(routeTaskUserAttribute);

        if (sTypeRouteTaskUser.equals(newPersonObject.getType(context))){
          sRouteTaskUser = DomainRelationship.getAttributeValue(context,routeNode[i],sAttrRouteTaskUser);
          if (sRouteTaskUser == null || "".equals(sRouteTaskUser) || "null".equals(sRouteTaskUser))
          {
            sRouteTaskUser = sSymbolicRouteTaskUser;
          }
          person = person + Framework.getPropertyValue(session, sRouteTaskUser) + "~";
        }else {
          person = person + newPersonObject.getName(context) + "~";
        }
        routeNodes += routeNode[i] + "~";
        routeObjectRel.setAttributes(context,attrList);
        routeObjectRel.close(context);

      }
    }
/*
  String select = "to[" + sRelRouteNode + "]." + Route.SELECT_ROUTE_TASK_USER;
  for(int i1=0;i1 <personId.length;i1++ ) {
    //BusinessObject bo=new BusinessObject(personId[i1]);
    newPersonObject.setId(personId[i1]);

    if (sTypeRouteTaskUser.equals(newPersonObject.getType(context))){
      sRouteTaskUser = newPersonObject.getInfo(context,select);
      person = person + Framework.getPropertyValue(session, sRouteTaskUser) + "~";
    }else {
      person = person + newPersonObject.getName(context) + "~";
    }
  }*/

  for(int i11=0;i11 <routeInstructions.length;i11++ ) {
    routeInst = routeInst + routeInstructions[i11] + "~";
  }

  for(int i12=0;i12 <routeOrder.length;i12++ ) {
    routeOrd = routeOrd + routeOrder[i12] + "~";
  }

  for(int i13=0;i13 <routeAction.length;i13++ ) {
    routeAct = routeAct + routeAction[i13] + "~";
  }

  if(routeNode != null) {
    for(int i14=0;i14 <routeNode.length;i14++ ) {
      routeNodes = routeNodes + routeNode[i14] + "~";
    }
  }

  } catch (Exception ex ){
    ex.printStackTrace(System.err);
    session.putValue("error.message"," " + ex);
    bExecute = true;
  }
%>

<html>
<body>
<form name="newForm" method="post" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrd%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInst%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAct%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=person%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=sAssigneeType%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
</form>

<script language="javascript">
<%
    if(!bExecute) {
%>
      document.newForm.action = "emxRouteActionRequiredDialogFS.jsp";
<%
    }  else {
%>
       document.newForm.action = "emxRouteAssignTaskDialogFS.jsp";
<%
    }
%>
  document.newForm.submit();
</script>
</body>
</html>

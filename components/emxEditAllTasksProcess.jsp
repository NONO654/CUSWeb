<%--  emxTeamEditAllTasksProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxEditAllTasksProcess.jsp.rca 1.14 Wed Oct 22 16:17:51 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  DomainObject objectGeneral = DomainObject.newInstance(context);
  DomainObject newPersonObject = DomainObject.newInstance(context);

  String sRelRouteNode                  = Framework.getPropertyValue( session, "relationship_RouteNode" );

  String sTypeRoute                     = Framework.getPropertyValue(session, "type_Route");
  String sTypeRouteTemplate             = Framework.getPropertyValue(session, "type_RouteTemplate");

  String sAttrRouteAction               = Framework.getPropertyValue(session, "attribute_RouteAction");
  String sAttrRouteInstructions         = Framework.getPropertyValue(session, "attribute_RouteInstructions");
  String sAttrScheduledCompletionDate   = Framework.getPropertyValue(session, "attribute_ScheduledCompletionDate");
  String sAttrAllowDelegation           = Framework.getPropertyValue(session, "attribute_AllowDelegation");
  String sAttrTitle                     = Framework.getPropertyValue(session, "attribute_Title");
  String sAttrRouteSequence             = Framework.getPropertyValue(session, "attribute_RouteSequence");
  String sTypeRouteTaskUser             = Framework.getPropertyValue( session, "type_RouteTaskUser");
  String sAttrRouteTaskUser             = Framework.getPropertyValue( session, "attribute_RouteTaskUser");
  String sRouteTaskUser = "";

  String objectId = emxGetParameter(request, "objectId");


  String routeId = emxGetParameter(request, "routeId");

  String strRelIds[] = emxGetParameterValues(request, "relIds");

  String sRouteAction[] = emxGetParameterValues(request, "routeAction");

  String sInstructions[] = emxGetParameterValues(request, "routeInstructions");

  String sDueDate = "";
  //String sDueDate[] = emxGetParameterValues(request, sAttrScheduledCompletionDate);
  String sTitle[] = emxGetParameterValues(request, "taskName");

  String sSequence[] = emxGetParameterValues(request, "routeOrder");

  String strNewAssigneeIds[] = emxGetParameterValues(request, "personId");

  String strOldAssigneeIds[] = emxGetParameterValues(request, "oldAssignee");

  String strTime[] = emxGetParameterValues(request, "routeTime");

  String sAttrValue = "";

  String routeInst = "";
  String routeOrd = "";
  String routeAct = "";
  String person = "";
  String routeNodes = "";
  String templateId = "";
  String template = "";
  boolean bExecute = false;
  String sPersonId = "";
  String sPersonName = null;
  String sRelId = "";
  String sAssigneeType="";
  BusinessObject boRoute = new BusinessObject(routeId);
  boRoute.open(context);
  String sType = boRoute.getTypeName();
  try {
  if (strRelIds != null) {
    for (int i = 0; i < strRelIds.length; i++) {

     /* BusinessObject boPerson = new BusinessObject(strNewAssigneeIds[i]);
      boPerson.open(context);
      String personName = boPerson.getName();
      boPerson.close(context);
*/
        sPersonId = strNewAssigneeIds[i].substring(0, strNewAssigneeIds[i].indexOf("#"));
        sPersonName = strNewAssigneeIds[i].substring(strNewAssigneeIds[i].indexOf("#") + 1);
        newPersonObject.setId(sPersonId);

      //person = person + personName + "~";
        String sSymbolicRouteTaskUser = null;

      if (sTypeRouteTaskUser.equals(newPersonObject.getType(context)))
      {
        try{
          sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "role", sPersonName, true);

          if (sSymbolicRouteTaskUser == null || "".equals(sSymbolicRouteTaskUser) || "null".equals(sSymbolicRouteTaskUser)) {
            sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sPersonName, true);
            if (sAssigneeType.equals("")) {
              sAssigneeType ="Group";
            }
            else {
              sAssigneeType +="~Group";
            }
          }
          else
          {
            if (sAssigneeType.equals("")) {
              sAssigneeType ="Role";
            }
            else {
              sAssigneeType += "~Role";
            }
          }

        } catch (FrameworkException fe){

        }

        //routeTaskUserAttribute = new Attribute(new AttributeType(sAttrRouteTaskUser),sSymbolicRouteTaskUser);
      }
      else
      {
        //routeTaskUserAttribute = new Attribute(new AttributeType(sAttrRouteTaskUser),sSymbolicRouteTaskUser);
        sSymbolicRouteTaskUser = "";
        if (sAssigneeType.equals("")) {
          sAssigneeType ="Person";
        }
        else {
          sAssigneeType +="~Person";
        }
      }
      //attrList.addElement(routeTaskUserAttribute);

      if (sTypeRouteTaskUser.equals(newPersonObject.getType(context)))
      {
        sRouteTaskUser = DomainRelationship.getAttributeValue(context,strRelIds[i],sAttrRouteTaskUser);
        if (sRouteTaskUser == null || "".equals(sRouteTaskUser) || "null".equals(sRouteTaskUser))
        {
          sRouteTaskUser = sSymbolicRouteTaskUser;
        }
        person = person + Framework.getPropertyValue(session, sRouteTaskUser) + "~";
      }else {
        person = person + newPersonObject.getName(context) + "~";
      }

      routeInst = routeInst + sInstructions[i] + "~";
      routeOrd = routeOrd + sSequence[i] + "~";
      routeAct = routeAct + sRouteAction[i] + "~";

      if (strOldAssigneeIds[i] != null && strNewAssigneeIds[i] != null && !(strOldAssigneeIds[i].equals(sPersonId))) {
        BusinessObject oldPerson = new BusinessObject(strOldAssigneeIds[i]);
        BusinessObject newPerson = new BusinessObject(strNewAssigneeIds[i]);
      //  newPersonObject.setId(newPerson.getObjectId());
        sRelId = strRelIds[i];
        DomainRelationship DoRelShip = DomainRelationship.newInstance(context,sRelId);
        DoRelShip.modifyTo(context,sRelId,newPersonObject);
      } else {
        sRelId = strRelIds[i];
      }
      routeNodes = routeNodes + sRelId + "~";
      Integer integerType = new Integer(i);
      String iString = integerType.toString();
      String routeScheduledCompletionDate = emxGetParameter(request, "routeScheduledCompletionDate"+iString);
      double iTimeZone = (new Double((String)session.getValue("timeZone"))).doubleValue(); //60*60*1000 *-1;
      String strDateTime = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDateTime(context,routeScheduledCompletionDate, strTime[i],iTimeZone,request.getLocale());

      Map map = new HashMap();
      map.put(sAttrRouteAction,sRouteAction[i]);
      map.put(sAttrRouteInstructions,sInstructions[i]);
      map.put(sAttrScheduledCompletionDate,strDateTime);
      map.put(sAttrTitle,sTitle[i]);
      map.put(sAttrRouteSequence,sSequence[i]);
      map.put(sAttrRouteTaskUser,sSymbolicRouteTaskUser);
      DomainRelationship.setAttributeValues(context,sRelId,map);

    }
  }
  boRoute.close(context);
} catch (Exception ex ){
  session.putValue("error.message"," " + ex);
  bExecute = true;

%>
  <form name="newForm">
   </form>
    <html>
    <body>
    <script language="javascript">
     parent.window.location.reload();
    </script>
    </body>
    </html>
<%

}
%>
<%

if(!bExecute) {
  if (sTypeRouteTemplate.equals(sType)) {

%>
    <html>
    <body>
    <script language="javascript">
      parent.window.getWindowOpener().location.reload();
      window.closeWindow();
    </script>
    </body>
    </html>
<%
  } else if (sTypeRoute.equals(sType)) {

      // to get the template id from route
      String strRelIniRoute = Framework.getPropertyValue( session, "relationship_InitiatingRouteTemplate");
      String strTemplateType      = Framework.getPropertyValue( session, "type_RouteTemplate");

      Pattern relPattern  = new Pattern(strRelIniRoute);
      Pattern typePattern = new Pattern(strTemplateType);

      SelectList selectStmts = new SelectList();
      selectStmts.addName();
      SelectList selectRelStmts = new SelectList();


      ExpansionWithSelect projectSelect = null;
      RelationshipWithSelectItr relItr  = null;

      projectSelect = boRoute.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(), selectStmts, selectRelStmts,false,true,(short)1);
      relItr        = new RelationshipWithSelectItr(projectSelect.getRelationships());

      // loop thru the rels and get the template object
      while (relItr != null && relItr.next()) {
        BusinessObject boTemplate = relItr.obj().getTo();
        templateId = boTemplate.getObjectId();
        boTemplate.open(context);
        template = boTemplate.getName();
        boTemplate.close(context);
      }


%>
<html>
<body>
    <form name="newForm" method="post" target="_parent">
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrd%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInst%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAct%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=person%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="sourcePage" value="EditAllTasks"/>
      <input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=sAssigneeType%></xss:encodeForHTMLAttribute>"/>
    </form>
    <script language="javascript">
      document.newForm.action = "emxRouteActionRequiredDialogFS.jsp";
      document.newForm.submit();
    </script>
</html>
</body>
<%
  }
}

%>

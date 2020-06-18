<%--  emxTeamEditAllTasksProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxEditRouteTemplateAllTasksProcess.jsp.rca 1.10 Wed Oct 22 16:18:00 2008 przemek Experimental przemek $
 --%>

<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%! static final String ROUTE_ACCESS_GRANTOR = "Route Access Grantor"; %>


<%
  DomainObject objectGeneral = DomainObject.newInstance(context);
  DomainObject newPersonObject = DomainObject.newInstance(context);

  String sRelRouteNode                  = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode" );

  String sTypeRoute                     = PropertyUtil.getSchemaProperty(context, "type_Route");
  String sTypeRouteTemplate             = PropertyUtil.getSchemaProperty(context, "type_RouteTemplate");

  String sAttrRouteAction               = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String sAttrRouteInstructions         = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
  String sAttrScheduledCompletionDate   = PropertyUtil.getSchemaProperty(context, "attribute_ScheduledCompletionDate");
  String sAttrAllowDelegation           = PropertyUtil.getSchemaProperty(context, "attribute_AllowDelegation");
  String sAttrTitle                     = PropertyUtil.getSchemaProperty(context, "attribute_Title");
  String sAttrRouteSequence             = PropertyUtil.getSchemaProperty(context, "attribute_RouteSequence");
  String sTypeRouteTaskUser             = PropertyUtil.getSchemaProperty(context, "type_RouteTaskUser");
  String sAttrRouteTaskUser             = PropertyUtil.getSchemaProperty(context, "attribute_RouteTaskUser");
  String sRouteTaskUser = "";
  String fromPage                 = emxGetParameter(request, "fromPage");

  String routeId = emxGetParameter(request, "objectId");

  String strRelIds[] = emxGetParameterValues(request, "relIds");
  String sRouteAction[] = emxGetParameterValues(request, "routeAction");

  String sInstructions[] = emxGetParameterValues(request, "routeInstructions");
  String sTitle[] = emxGetParameterValues(request, "taskName");
  String sSequence[] = emxGetParameterValues(request, "routeOrder");
  String strNewAssigneeIds[] = emxGetParameterValues(request, "personId");
  String strOldAssigneeIds[] = emxGetParameterValues(request, "oldAssignee");
  String strDeltaOffset[]               = emxGetParameterValues(request, "duedateOffset");
  String strDeltaOffsetFrom[]           = emxGetParameterValues(request, "duedateOffsetFrom");
  String recepientList[]           = emxGetParameterValues(request, "recepientList");
  String isRouteTemplateRevised = emxGetParameter(request,"isRouteTemplateRevised");

  //Added for IR-043896V6R2011
  String newTaskIds=emxGetParameter(request,"newTaskIds");
  if (newTaskIds == null)
       newTaskIds="";
  //Addition ends for IR-043896V6R2011

  String sAttrValue = "";

  String routeInst = "";
  String routeOrd = "";
  String routeAct = "";
  String person = "";
  String title = "";
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
  Integer integerType        = null;
  String sDueDateOption      = "";
  String boolStr             = "No";
  String iString             = "";
  boolean bAssigneeDueDate   = false;
  boolean bDeltaDueDate      = false;
  String sAllowDelegation      = "";
  String sReviewTask ="";
   DomainObject routeTemplateObject = DomainObject.newInstance(context);
  try {

  routeTemplateObject.setId(routeId);

    if (strRelIds != null) {
        Map mapAttributes = null;

        for (int i = 0; i < strRelIds.length; i++) {

            integerType   = new Integer(i);
            iString       = integerType.toString();

            sDueDateOption = emxGetParameter(request, "duedateOption"+iString);


            if(sDueDateOption == null || "null".equals(sDueDateOption)){
                sDueDateOption = "";
            }

			sAllowDelegation = emxGetParameter(request, "allowDelegation"+strRelIds[i]);
            sReviewTask = emxGetParameter(request, "reviewTask"+strRelIds[i]);

			if(sAllowDelegation == null || "null".equals(sAllowDelegation)){
			 sAllowDelegation = "FALSE";
			}
			else
			{
				sAllowDelegation = "TRUE";
			}
			if(sReviewTask == null || "null".equals(sReviewTask)){
			 sReviewTask = "No";
			}
			else
			{
				sReviewTask = "Yes";
			}

            // boolStr temp string for determining whether this attribute has indeed changed; Only if yes, update to database
            if("assignee".equalsIgnoreCase(sDueDateOption)){
                boolStr          = "Yes";
                bAssigneeDueDate = true;
            }else{
                boolStr          = "No";
                bAssigneeDueDate = false;
            }

            if("delta".equalsIgnoreCase(sDueDateOption)){
                bDeltaDueDate = true;
            }else{
                bDeltaDueDate = false;
            }
            sPersonId = strNewAssigneeIds[i].substring(0, strNewAssigneeIds[i].indexOf("#"));
            sPersonName = strNewAssigneeIds[i].substring(strNewAssigneeIds[i].indexOf("#") + 1);
            person    = person + sPersonName + "~";
            if(sTitle[i].equals(""))
                 title     = title +"none~";
            else
                 title     = title + sTitle[i] + "~";
            routeInst = routeInst + sInstructions[i] + "~";
            routeOrd  = routeOrd + sSequence[i] + "~";
            routeAct  = routeAct + sRouteAction[i] + "~";
            
            if(!sPersonName.equals("none"))
            {
                newPersonObject.setId(sPersonId);
                String sSymbolicRouteTaskUser = null;

                if (sTypeRouteTaskUser.equals(newPersonObject.getType(context)))
                {
                    try {
                        sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "role", sPersonName, true);
                        if (sSymbolicRouteTaskUser == null || "".equals(sSymbolicRouteTaskUser) || "null".equals(sSymbolicRouteTaskUser))
                        // sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sPersonName, true);
                        //modified for 311950
                        sSymbolicRouteTaskUser = FrameworkUtil.getAliasForAdmin(context, "group", sPersonName, false);
                        //till here

                    } catch (FrameworkException fe){}
                }else{
                    sSymbolicRouteTaskUser = "";
                }
                if (strOldAssigneeIds[i] != null && strNewAssigneeIds[i] != null && !(strOldAssigneeIds[i].equals(sPersonId))) {
                    BusinessObject oldPerson = new BusinessObject(strOldAssigneeIds[i]);
                    BusinessObject newPerson = new BusinessObject(strNewAssigneeIds[i]);

                    sRelId = strRelIds[i];
                    DomainRelationship DoRelShip = DomainRelationship.newInstance(context,sRelId);
                    DoRelShip.modifyTo(context,sRelId,newPersonObject);
                } else {
                    sRelId = strRelIds[i];
                }

                boolean isResponsibleRoleEnabled=com.matrixone.apps.common.InboxTask.checkIfResponsibleRoleEnabled(context);
				String strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeInstructions");

                 if(isResponsibleRoleEnabled&&(null!=recepientList)&&!recepientList[i].isEmpty()){
            	 DomainRelationship doRelShip = DomainRelationship.newInstance(context,sRelId);
				 if(UIUtil.isNullOrEmpty(sSymbolicRouteTaskUser)){
            	 sSymbolicRouteTaskUser= doRelShip.getAttributeValue(context,sRelId,DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
				 }
             	if(!recepientList[i].equals("Any")){
            	 doRelShip.modifyTo(context,sRelId,PersonUtil.getPersonObject(context, recepientList[i]));
            	 AccessUtil accessUtil=new AccessUtil();
            	  accessUtil.setAccess( recepientList[i],ROUTE_ACCESS_GRANTOR,accessUtil.getReadAccess());
            	  if(accessUtil.getAccessList().size() > 0){
                      //emxGrantAccess GrantAccess = new emxGrantAccess(DomainObject.newInstance(context,routeId));
                      //GrantAccess.grantAccess(context, accessUtil);
                      String[] args = new String[]{routeId};
                      JPO.invoke(context, "emxWorkspaceConstants", args, "grantAccess", JPO.packArgs(accessUtil.getAccessList()));
              }
              }else{
            	  DomainObject objRTU = DomainObject.newInstance(context);
            	  objRTU.createObject(context,routeTemplateObject.TYPE_ROUTE_TASK_USER, null, null, null, null);
                  DomainRelationship.modifyTo(context, sRelId, objRTU);
              }
            	 }
                
                integerType = new Integer(i);
                iString = integerType.toString();

                Map map = new HashMap();
                map.put(sAttrRouteAction,sRouteAction[i]);
                map.put(sAttrRouteInstructions,sInstructions[i]);
                map.put(sAttrTitle,sTitle[i]);
                if(bAssigneeDueDate){
                    map.put(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE,"Yes");
                }else{
                    map.put(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE,"No");
                }
                map.put(DomainObject.ATTRIBUTE_DUEDATE_OFFSET,strDeltaOffset[i]);
                map.put(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM,strDeltaOffsetFrom[i]);
                map.put(sAttrRouteSequence,sSequence[i]);
                map.put(sAttrRouteTaskUser,sSymbolicRouteTaskUser);
                map.put(DomainObject.ATTRIBUTE_ALLOW_DELEGATION,sAllowDelegation);
                map.put(DomainObject.ATTRIBUTE_REVIEW_TASK,sReviewTask);

                DomainRelationship.setAttributeValues(context,sRelId,map);
            }
            else {
                sRelId = strRelIds[i];

                // If there exists a relationship Route Node that represent the task, then
                // the attributes of the task should also be set on the relationship.
                mapAttributes = new HashMap();
                mapAttributes.put(sAttrRouteAction, sRouteAction[i]);
                mapAttributes.put(sAttrRouteInstructions, sInstructions[i]);
                mapAttributes.put(sAttrTitle, sTitle[i]);
                if(bAssigneeDueDate){
                    mapAttributes.put(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE, "Yes");
                }else{
                    mapAttributes.put(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE, "No");
                }
                mapAttributes.put(DomainObject.ATTRIBUTE_DUEDATE_OFFSET, strDeltaOffset[i]);
                mapAttributes.put(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM, strDeltaOffsetFrom[i]);
                mapAttributes.put(sAttrRouteSequence, sSequence[i]);
                mapAttributes.put(DomainObject.ATTRIBUTE_ALLOW_DELEGATION, sAllowDelegation);
                mapAttributes.put(DomainObject.ATTRIBUTE_REVIEW_TASK, sReviewTask);

                if(!sPersonId.equals("none"))
                {
                    newPersonObject.setId(sPersonId);
                    String toType = newPersonObject.getTypeName();
                    if( (toType != null) && (toType.equals(newPersonObject.TYPE_ROUTE_TASK_USER)) ){
                        mapAttributes.put(sAttrRouteTaskUser,"");
                        DomainRelationship.setAttributeValues(context, sRelId, mapAttributes);
                    }else{
                        DomainObject routeTaskUser = DomainObject.newInstance(context);
                        routeTaskUser.createObject(context,routeTemplateObject.TYPE_ROUTE_TASK_USER, null, null, null, null);
                        DomainRelationship.modifyTo(context, sRelId, routeTaskUser);
                        DomainRelationship.setAttributeValues(context, sRelId, mapAttributes);
                    }
                }
                else {
                    //create Route Task User and modify relationship  to connect to Route Template
                    DomainObject routeTaskUser = DomainObject.newInstance(context);
                    routeTaskUser.createObject(context,routeTemplateObject.TYPE_ROUTE_TASK_USER, null, null, null, null);
                    DomainRelationship.modifyTo(context,sRelId,routeTaskUser);

                    mapAttributes.put(sAttrRouteTaskUser,"");
                    DomainRelationship.setAttributeValues(context, sRelId, mapAttributes);
                }
            }
            routeNodes = routeNodes + sRelId + "~";
         }//~for
    }//~if

    boRoute.close(context);
} catch (Exception ex ){
  session.putValue("error.message"," " + ex);
  bExecute = true;

%>
    <script language="javascript">
     parent.window.location.reload();
    </script>
<%

}
String strRelId = "";
MapList mapList = null;
StringList objSelects = new StringList(2);
objSelects.add(DomainConstants.SELECT_ID);
objSelects.add(DomainConstants.SELECT_NAME);
StringList relSelects = new StringList(1);
relSelects.add(DomainRelationship.SELECT_ID);
Map map = null;
StringList st =new StringList();

if( (fromPage !=null)&& (fromPage.equals("addtask")) )
{
  // Set the domain object as Route to connect person.
  //DomainObject personObject = DomainObject.newInstance(context);
  //personObject.setId(JSPUtil.getPerson(context, session).getObjectId());
  DomainObject routeTaskUser = DomainObject.newInstance(context);
  routeTaskUser.createObject(context,routeTemplateObject.TYPE_ROUTE_TASK_USER, null, null, null, null);
  
  try {
      DomainRelationship taskRel = routeTemplateObject.connectTo(context,sRelRouteNode, routeTaskUser);
    
    strRelId = taskRel.getName();
    if (!"".equals(newTaskIds))
    {
        newTaskIds += "|" + strRelId;
    }
    else
    {
        newTaskIds = strRelId;
    }
    
  } catch(Exception exp) {
    session.putValue("error.message", exp.getMessage());
  }
}

%>
<html>
<body>
    <form name="newForm" target="_parent">
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
	 <!--Added for IR-043896V6R2011-->
    <input type="hidden" name="newTaskIds" value="<xss:encodeForHTMLAttribute><%=newTaskIds%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="title" value="<xss:encodeForHTMLAttribute><%=title%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrd%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInst%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAct%></xss:encodeForHTMLAttribute>"/>
     <input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=person%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=sAssigneeType%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="sourcePage" value="EditAllTasks"/>
     <input type="hidden" name="isRouteTemplateRevised" value="<xss:encodeForHTMLAttribute><%=isRouteTemplateRevised%></xss:encodeForHTMLAttribute>"/>
    
    <%

if(!bExecute) {
	// Added for the Bug 339301
  String strTreeURL =    UINavigatorUtil.getComponentDirectory(context)+"/emxTaskSummaryFS.jsp?objectId=" + routeId;
  // Till Here
%>
      <script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
      <script language="javascript">
      <%
          if( (fromPage.equals("addtask")) || (fromPage.equals("sorttask"))) {
      %>
          
          document.newForm.action = "emxEditAllTasksDialogFS.jsp";
		  document.newForm.method="POST";
          document.newForm.submit();
      <%
        }else{
	  %>
		 //Added for the Bug 339301
		  document.newForm.action = "emxRouteTemplateWizardActionRequiredFS.jsp";
		  document.newForm.method="POST";
          document.newForm.submit();
	//getTopWindow().getWindowOpener().location= getTopWindow().getWindowOpener().location;
	//getTopWindow().close();
        // Till Here
        <%
         }
        %>
      </script>
</html>
</body>
<%
}
%>

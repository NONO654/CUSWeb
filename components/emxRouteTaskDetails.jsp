<%--  emxTeamRouteTaskDetails.jsp   -   Display Details of Tasks if coming through a route
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains prtaskOwneroprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxRouteTaskDetails.jsp.rca 1.22 Wed Oct 22 16:18:02 2008 przemek Experimental przemek $"
--%>


<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
  DomainObject domainObject = DomainObject.newInstance(context);
  String languageStr  = request.getHeader("Accept-Language");
  String routeId      = emxGetParameter(request,"routeId");
  String taskId       = emxGetParameter(request,"taskId");
  String routeNodeId  = emxGetParameter(request,"routeNodeId");
  String taskCreated  = emxGetParameter(request,"taskCreated");
  final String STRING_NONE = i18nNow.getI18nString("emxComponents.Common.None", "emxComponentsStringResource", languageStr);
%>

<script language = javascript>
  function showEditDialogPopup()
  {
    emxShowModalDialog("emxEditRouteTaskDetailsDialogFS.jsp?routeId=<%=XSSUtil.encodeForURL(context, routeId)%>&taskCreated=<%=XSSUtil.encodeForURL(context, taskCreated)%>&routeNodeId=<%=XSSUtil.encodeForURL(context, routeNodeId)%>&taskId=<%=XSSUtil.encodeForURL(context, taskId)%>",575,575);
  }

  function AcceptTask()
  {
    document.frmTaskDetails.submit();
  }

  function closeWindow()
  {
	  getTopWindow().closeWindow();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  String suiteKey    = emxGetParameter(request,"suiteKey");

  String attrRouteAction         = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String attrRouteInstruction    = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
  String attrComments            = PropertyUtil.getSchemaProperty(context, "attribute_Comments");
  String attrApprovalStatus      = PropertyUtil.getSchemaProperty(context, "attribute_ApprovalStatus");
  String attrRouteTaskUser       = PropertyUtil.getSchemaProperty(context, "attribute_RouteTaskUser");

  String taskName = "";
  String taskOwner = "";
  String taskCreateDate = "";
  String taskDueDate = "";
  String taskAllowDelegation = "";
  String taskAssignee = "";
  String taskRouteName = "";
  String taskAction= "";
  String taskState = "";
  String taskInstructions = "";
  String taskComments = "";
  String taskApprovalStatus = "";
  String taskAssigneeType = "";
  String sPolicy=null;
  String timeZone = (String)session.getValue("timeZone");
  String objType = "";

  if(taskId != null && !taskId.equals("") && !"null".equals(taskId))
  {

    domainObject.setId(taskId);

    String selTaskName = "attribute["+domainObject.ATTRIBUTE_TITLE+"]";
    String selTaskDueDate = "attribute["+domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]";
    String selTaskAllowDelegation = "attribute["+domainObject.ATTRIBUTE_ALLOW_DELEGATION+"]";
    String selRouteName = "from["+domainObject.RELATIONSHIP_ROUTE_TASK+"].to.name";
    String selTaskAction = "attribute["+attrRouteAction+"]";
    String selTaskInstructions = "attribute["+attrRouteInstruction+"]";
    String selTaskComments = "attribute["+attrComments+"]";
    String selTaskApprovalStatus = "attribute["+attrApprovalStatus+"]";


    StringList busSelects = new StringList();

    busSelects.addElement(selTaskName);
    busSelects.addElement(domainObject.SELECT_OWNER);
    busSelects.addElement(domainObject.SELECT_ORIGINATED);
    busSelects.addElement(selTaskDueDate);
    busSelects.addElement(selTaskAllowDelegation);
    busSelects.addElement(selRouteName);
    busSelects.addElement(selTaskAction);
    busSelects.addElement(domainObject.SELECT_POLICY);
    busSelects.addElement(domainObject.SELECT_CURRENT);
    busSelects.addElement(selTaskInstructions);
    busSelects.addElement(selTaskComments);
    busSelects.addElement(selTaskApprovalStatus);


    Map taskMap = domainObject.getInfo(context, busSelects);

    taskName              = (String)taskMap.get(selTaskName);
    taskOwner             = (String)taskMap.get(domainObject.SELECT_OWNER);
    taskCreateDate        = (String)taskMap.get(domainObject.SELECT_ORIGINATED);
    taskDueDate           = (String)taskMap.get(selTaskDueDate);
    taskAllowDelegation   = (String)taskMap.get(selTaskAllowDelegation);
    taskAssignee          = (String)taskMap.get(domainObject.SELECT_OWNER);
    taskRouteName         = (String)taskMap.get(selRouteName);
    taskAction            = (String)taskMap.get(selTaskAction);
    taskState             = (String)taskMap.get(domainObject.SELECT_CURRENT);
    taskInstructions      = (String)taskMap.get(selTaskInstructions);
    taskComments          = (String)taskMap.get(selTaskComments);
    taskApprovalStatus    = (String)taskMap.get(selTaskApprovalStatus);

    sPolicy         = (String)taskMap.get("policy");
  }
  else if(routeNodeId != null && !routeNodeId.equals("") && !"null".equals(routeNodeId))
  {

    domainObject.setId(routeId);

    StringList busSelects = new StringList();

    busSelects.addElement(domainObject.SELECT_TYPE);
    busSelects.addElement(domainObject.SELECT_NAME);
    busSelects.addElement(domainObject.SELECT_ORIGINATED);

    Map routeMap = domainObject.getInfo(context, busSelects);

    DomainRelationship domainRel = DomainRelationship.newInstance(context,routeNodeId);
    domainRel.open(context);
    Map taskMap = domainRel.getAttributeMap(context);

    taskName = (String)taskMap.get(domainObject.ATTRIBUTE_TITLE);
    taskCreateDate = (String)routeMap.get(domainObject.SELECT_ORIGINATED);
    taskDueDate = (String)taskMap.get(domainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
    taskAllowDelegation = (String)taskMap.get(domainObject.ATTRIBUTE_ALLOW_DELEGATION);
    taskRouteName = (String)routeMap.get(domainObject.SELECT_NAME);
    taskAction= (String)taskMap.get(attrRouteAction);
    taskInstructions = (String)taskMap.get(attrRouteInstruction);
    taskComments = (String)taskMap.get(attrComments);
    taskApprovalStatus = (String)taskMap.get(attrApprovalStatus);
    taskAssigneeType = (String)taskMap.get(attrRouteTaskUser);
    objType = (String)routeMap.get(domainObject.SELECT_TYPE);

    if(taskAssigneeType != null && !"".equals(taskAssigneeType)) {
      if(taskAssigneeType.substring(0, taskAssigneeType.indexOf("_")).equals("role") ) {
        taskAssignee = PropertyUtil.getSchemaProperty(context,taskAssigneeType);
        taskAssignee =i18nNow.getAdminI18NString("Role", taskAssignee , languageStr);
      }
      else
      {
        taskAssignee = PropertyUtil.getSchemaProperty(context,taskAssigneeType);
        taskAssignee =i18nNow.getAdminI18NString("Group", taskAssignee , languageStr);

      }

    } else {
        DomainObject dmoAssignee = new DomainObject (domainRel.getTo());

        StringList slBusSelect = new StringList();
        slBusSelect.add (DomainObject.SELECT_NAME);
        slBusSelect.add (DomainObject.SELECT_TYPE);

        Map mapAssigneeInfo = dmoAssignee.getInfo (context, slBusSelect);

        String strAssigneeName = (String)mapAssigneeInfo.get (DomainObject.SELECT_NAME);
        String strAssigneeType = (String)mapAssigneeInfo.get (DomainObject.SELECT_TYPE);
        if(strAssigneeType.equalsIgnoreCase("Person")){
            strAssigneeName = PersonUtil.getFullName(context, strAssigneeName);
        }

        if (DomainObject.TYPE_ROUTE_TASK_USER.equals(strAssigneeType)) {
            taskAssignee = ""; // If task has been assigned to None
        }
        else {
            taskAssignee = strAssigneeName;
        }
    }
      domainRel.close(context);

  }
  String sRouteNextUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?AppendParameters=true&objectId=" + XSSUtil.encodeForURL(context, routeId);
  String sRouteUrl  = "javascript:emxShowModalDialog('" + sRouteNextUrl + "',800,575)";


%>

 <form name = "frmTaskDetails" method = "post" action="emxRouteAcceptTask.jsp">
  <input type="hidden" name="taskId" value="<xss:encodeForHTMLAttribute><%=taskId%></xss:encodeForHTMLAttribute>" />

    <table>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, taskName)%>&nbsp;</td>
    </tr>

<%
  if (taskCreated.equals("yes"))
  {
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Owner</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, taskOwner)%>&nbsp;</td>
    </tr>
<%
  }
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Originated</emxUtil:i18n></td>
      <!-- //XSSOK -->
      <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=timeZone%>' format='<%=DateFrm %>' ><%=taskCreateDate%></emxUtil:lzDate>&nbsp;</td>
    </tr>
<%
if(!objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
{
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.DueDate</emxUtil:i18n></td>
      <!-- //XSSOK -->
      <td class="field"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=timeZone%>' format='<%=DateFrm %>' ><%=taskDueDate%></emxUtil:lzDate>&nbsp;</td>
    </tr>
<%
}
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.AllowDelegation</emxUtil:i18n></td>
<%
    if ("true".equalsIgnoreCase(taskAllowDelegation))
    {
%>
      <td class="field"><emxUtil:i18n localize="i18nId">emxComponents.Common.Yes</emxUtil:i18n>&nbsp;</td>
<%
    } else {

%>
      <td class="field"><emxUtil:i18n localize="i18nId">emxComponents.Common.No</emxUtil:i18n>&nbsp;</td>
<%
    }
%>
    </tr>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Assignee</emxUtil:i18n></td>
      <!-- //XSSOK -->
      <td class="field"><%=(taskAssignee == null || "".equals (taskAssignee))?STRING_NONE:taskAssignee%>&nbsp;</td>
    </tr>

<%
String parentType = "emxComponents.Common.Route";
String parentIcon = "../common/images/iconSmallRoute.png";
if(objType.equals(DomainObject.TYPE_ROUTE_TEMPLATE))
{
  parentType = "emxComponents.Common.RouteTemplate";
  parentIcon= "../common/images/iconSmallRouteTemplate.gif";
}
%>
    <tr>
       <!-- //XSSOK -->
      <td class="label"><emxUtil:i18n localize="i18nId"><%=parentType%></emxUtil:i18n></td>
      <td class="field">
      	<!-- //XSSOK -->
        <a href="<%=sRouteUrl%>"><img src="<%=parentIcon%>" border="0" name="imgRoute" id="imgRoute" alt="*" /><%=XSSUtil.encodeForHTML(context, taskRouteName)%></a>&nbsp;
      </td>
    </tr>

    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Action</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, i18nNow.getRangeI18NString( attrRouteAction, taskAction, languageStr))%></td>
    </tr>
<%
  if(taskAction==null) {
    taskAction="";
  }
  if(taskAction.equals("Approve")) {
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.ApprovalStatus</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, i18nNow.getRangeI18NString( attrApprovalStatus, taskApprovalStatus, languageStr))%>&nbsp;</td>
    </tr>
<%
  }
  if (taskCreated.equals("yes"))
  {
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.State</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(sPolicy,taskState,languageStr))%>&nbsp;</td>
    </tr>
<%
  }
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Instructions</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, taskInstructions) %>&nbsp;</td>
    </tr>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.TaskDetails.Comments</emxUtil:i18n></td>
      <td class="field"><%=XSSUtil.encodeForHTML(context, taskComments)%>&nbsp;</td>
    </tr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

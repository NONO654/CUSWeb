<%--  emxRouteAcceptTask.jsp  --  Allows person to accept Task when assigned to a group or role
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteAcceptTask.jsp.rca 1.12 Wed Oct 22 16:18:24 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String taskId         = emxGetParameter(request, "objectId");
  InboxTask inboxTaskObject = (InboxTask)DomainObject.newInstance(context,
                                                                  DomainConstants.TYPE_INBOX_TASK);
  if( taskId == null || "".equals(taskId) || "null".equals(taskId) )
  {
      taskId = emxGetParameter(request, "taskId");
  }

  if(taskId != null)
  {
      inboxTaskObject.setId(taskId);
      // Added for Bug 356437 to check whether this task has accepted by some other user in between the current
      // user accepts. If the task has accepted by other user then display the alert message to the current user
      StringList busSelects = new StringList(2);
      busSelects.add(DomainConstants.SELECT_TYPE);
      busSelects.add(DomainConstants.SELECT_NAME);
      String strKindOfProxyGroup = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_GroupProxy") +"]";
      busSelects.add(strKindOfProxyGroup);
      String strRouteTaskUser = PropertyUtil.getSchemaProperty(context,"type_RouteTaskUser");

      Map taskAssigneeInfoMap =  inboxTaskObject.getRelatedObject(context,"Project Task",true,busSelects,null);
    String strType = (String) taskAssigneeInfoMap.get(DomainConstants.SELECT_TYPE);
    String strName = (String) taskAssigneeInfoMap.get(DomainConstants.SELECT_NAME);
    String kindOf = (String) taskAssigneeInfoMap.get(strKindOfProxyGroup);
    //Validating the to side connected object of Project Task relationship is Route Task User or not. If it is
    // Route Task User then no one has accepted the task.
    if(strRouteTaskUser.equals(strType) || "true".equalsIgnoreCase(kindOf))
    {
      try {

        //set the RPE Variable
        String treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceComponents.treeMenu.InboxTask");
        if(treeMenu != null && !"".equals(treeMenu)){
          MQLCommand mql = new MQLCommand();
          mql.open(context);
          String mqlCommand = "set env global MX_TREE_MENU " + treeMenu;
          mql.executeCommand(context, mqlCommand);
          mql.close(context);
        }

        //accept task
        inboxTaskObject.acceptTask(context);
      } catch (Exception ex ) {
        session.putValue("error.message", ex.getMessage());
      }
    }// End if for project task to type validation
    else
    {
    %>
    <script language="javascript">
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Task.Accepted</emxUtil:i18nScript>"+" "+"<%=XSSUtil.encodeForJavaScript(context, strName)%>");
    </script>

    <%
  }
  }
%>

<html>
<body>
<script language="javascript">
//
// Actually, if the execution comes here then it should be the table page inside a portal tab.
// For refreshing table page, the method parent.refreshTableBody() can be called
// but this does not refresh the contents of the table, so below way of refreshing is used.
//
  parent.location.href = parent.location.href;
</script>
</body>
</html>

<%--  emxECRECOTasksApproveProcess.jsp   -  Update related Data and Promote Tasks to Complete State
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.  
    This program contains proprietary and trade secret information of MatrixOne,
    Inc.  Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: emxMultitaskCompleteProcess.jsp.rca 1.7 Wed Oct 22 16:18:37 2008 przemek Experimental przemek $"   
 --%>

 <%@include file  = "../emxUICommonAppInclude.inc"%>

 <%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

 <%@include file = "../emxUICommonHeaderEndInclude.inc" %>

 <%@include file  = "emxComponentsCommonUtilAppInclude.inc"%>

<%
   try{
    String strCommentsAttr       = PropertyUtil.getSchemaProperty(context,"attribute_Comments");

    String strApprovalStatusAttr = PropertyUtil.getSchemaProperty(context,"attribute_ApprovalStatus");

    DomainObject task = DomainObject.newInstance(context);
    Route route = (Route)DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE);

    String[] taskIdArr = emxGetParameterValues(request,"emxTableRowId");

    String taskId     = "";
    String Comments = "";
    String ApprovalStatus = "";
    String taskName = "";
    String routeId = "";
    
    boolean commentNotPresent = false;

    String noComments="";
    String url = "";

    StringTokenizer strToken = null;

    StringList strList = new StringList();
    strList.addElement(DomainConstants.SELECT_NAME);
    strList.addElement(DomainObject.getAttributeSelect(strCommentsAttr));
    strList.addElement(DomainObject.getAttributeSelect(strApprovalStatusAttr));
    strList.addElement("from["+DomainConstants.RELATIONSHIP_ROUTE_TASK+"].to.id");


    //added for Bug no : 313384
    strList.addElement("attribute["+DomainConstants.ATTRIBUTE_ROUTE_ACTION+"]");
     //Till here   
    Map map = null;
        
    for(int j=0; j<taskIdArr.length; j++)
    {
        taskId     = taskIdArr[j];
        if(taskId.indexOf("|") != -1)
        {
            strToken = new StringTokenizer(taskId,"|");
            strToken.nextToken();
            taskId = strToken.nextToken();
        }

        task.setId(taskId);
      

        map = task.getInfo(context,strList);
        


        Comments = (String)map.get(DomainObject.getAttributeSelect(strCommentsAttr));
        ApprovalStatus = (String)map.get(DomainObject.getAttributeSelect(strApprovalStatusAttr));
        taskName = (String)map.get(DomainConstants.SELECT_NAME);
        routeId = (String)map.get("from["+DomainConstants.RELATIONSHIP_ROUTE_TASK+"].to.id");
        
        //added for Bug no : 313384
        String taskAction=(String)map.get("attribute["+DomainConstants.ATTRIBUTE_ROUTE_ACTION+"]");

        if( ( Comments == null || "".equals(Comments) ) && !taskAction.equals("Notify Only"))
        {
            commentNotPresent = true;
            noComments=noComments+taskName+",";

        }// Till Here
		// Added for the Bug No : 336329 1 6/14/2007 6:52 PM Begin
     else if ("None".equals(ApprovalStatus)) {
  %>
  <script>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.ApprovalStatusNone</emxUtil:i18nScript>")
    </script>
  <%// Added for the Bug No : 336329 1 6/14/2007 6:52 PM End
	  }else
        {
            task.promote(context);
            InboxTask.setTaskTitle(context, routeId);
            url = UINavigatorUtil.notificationURL(context, request, routeId, "Menu", false);
            route.setId(routeId);

		}
    } // eof for

    if (commentNotPresent)
    {
     String NoComments1 = i18nNow.getI18nString("emxComponents.TaskSummary.NoComments1","emxComponentsStringResource",request.getHeader("Accept-Language"));
     String NoComments2 = i18nNow.getI18nString("emxComponents.TaskSummary.NoComments2","emxComponentsStringResource",request.getHeader("Accept-Language"));
     session.setAttribute("error.message",NoComments1+" \""+noComments+"\" "+NoComments2);
    }
  } catch (Exception ex ){
      session.setAttribute("error.message"," " + ex.toString());
  }
%>
<script language="javascript">

if(getTopWindow().refreshTablePage)
{
    getTopWindow().refreshTablePage();
}
else
{
    parent.document.location.href = parent.document.location.href;
}
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>  

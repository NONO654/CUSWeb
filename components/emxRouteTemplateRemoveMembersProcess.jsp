<%--  emxRouteAccessMembersProcess.jsp  --  DisConnecting Members from Route

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteTemplateRemoveMembersProcess.jsp.rca 1.8 Wed Oct 22 16:18:52 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%
  String[] selPersons   = emxGetParameterValues(request, "chkItem");
  selPersons		= (selPersons != null) ? selPersons : emxGetParameterValues(request, "emxTableRowId");
  String objectId = emxGetParameter(request,"objectId");
  String objState = "";
  //Added for Bug No:341550 Rev1 Dated 11/21/2007 Begin. 
  Vector taskUserList=new Vector();
  Vector personIdList=new Vector();
  String[] revPersons=new String[selPersons.length];
  StringList objectSelects=new StringList();
  StringList relSelects=new StringList();
  StringList relationshipSelects = new StringList(3);
  relationshipSelects.add(RouteTemplate.SELECT_ROUTE_TASK_USER);
  relationshipSelects.add("to.id");
  relationshipSelects.add("to.type");
  //Added for Bug No:341550 Rev1 Dated 11/21/2007 Ends.
  boolean isRouteTemplateActive = false;

  RouteTemplate boRouteTemplate = (RouteTemplate)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TEMPLATE);

  if(objectId != null && !"null".equals(objectId))
  {
    boRouteTemplate.setId(objectId);
    objState = (String)boRouteTemplate.getInfo(context,DomainObject.SELECT_CURRENT);
   //Modified for Bug No:341550 Rev1 Dated 11/21/2007 Begin. 
      if(objState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE))
      {
        MapList actualMemberList=DomainRelationship.getInfo(context,
                           selPersons,
                               relationshipSelects);
            Iterator personItr = actualMemberList.iterator();
            while(personItr.hasNext())
              {
                Map map = (Map)personItr.next();
                String personType=(String)map.get("to.type");
                String personId=(String)map.get("to.id");
                String routeUserAttrVal=(String)map.get(RouteTemplate.SELECT_ROUTE_TASK_USER);
                  if(personType.equals(DomainObject.TYPE_ROUTE_TASK_USER))
                    {
                        taskUserList.addElement(routeUserAttrVal);
                    }
                  if(personType.equals(DomainObject.TYPE_PERSON))
                    {
                        personIdList.addElement(personId);
                    }
                }
              String revisedTemplateId = boRouteTemplate.revise(context);
              boRouteTemplate.setId(revisedTemplateId);
              MapList revisedMemberList=boRouteTemplate.getRouteTemplateMembers(context,
                                       objectSelects,
                                       relSelects,
                                       false);
              Iterator mapItr = revisedMemberList.iterator();
              int index=-1;
              while(mapItr.hasNext())
              {
                Map memberMap = (Map)mapItr.next();
                String memberId=(String)memberMap.get(DomainObject.SELECT_ID);
                String memberType=(String)memberMap.get(DomainObject.SELECT_TYPE);
                String taskUserName=(String)memberMap.get(RouteTemplate.SELECT_ROUTE_TASK_USER);
                String relId=(String)memberMap.get(DomainObject.SELECT_RELATIONSHIP_ID);
                if(memberType.equals(DomainObject.TYPE_ROUTE_TASK_USER)&&taskUserList.contains(taskUserName))
                  {
                    index++;
                    revPersons[index]=relId;
                  }
                if(memberType.equals(DomainObject.TYPE_PERSON)&&personIdList.contains(memberId))
                  {
                    index++;
                    revPersons[index]=relId;
                  }
               }
              isRouteTemplateActive = true;
              selPersons=revPersons;
          }  
        //Modified for Bug No:341550 Rev1 Dated 11/21/2007 Ends.
       // boRouteTemplate.removeRouteTemplateMembers(context,selPersons);
       boRouteTemplate.removeMembers(context,selPersons);
        
  }

  String strpopUpURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, boRouteTemplate.getId()) + "&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory);
        
%>


<script language="javascript">
<%
if(!isRouteTemplateActive) {
%>
  parent.window.location.reload();
<%
} else {
%>//XSSOK
  parent.parent.location.href = '<%=strpopUpURL%>';
<%
}
%>
</script>

<%--  emxRouteSelectProjectRolesOrGroupsProcess.jsp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteSelectProjectRolesOrGroupsProcess.jsp.rca 1.8 Wed Oct 22 16:18:34 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxRouteInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%  // read the Member list passed in

  String keyValue = emxGetParameter(request, "keyValue");
  String memberID[]           = emxGetParameterValues(request, "chkItem1");
  String memberType             = emxGetParameter(request, "memberType");
  String sRouteId             = emxGetParameter(request, "routeId");

StringList roleList = new StringList();
StringList groupList = new StringList();
String sErrorMsg = "";
String memberNames          = "";
boolean allowExtend         = true;
if(sRouteId==null || sRouteId.equals("") || sRouteId.equals("null")  )
{
  int i = 0;
  int j = 0;
  boolean isFound=false;
  DomainObject personObject= null;
  MapList memberMapList =null;

  try{
  	  memberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
   }catch(Exception mml){
      memberMapList = new MapList();
   }

  if(memberMapList == null) {
    memberMapList = new MapList();
  }

 MapList taskMapList = null;
  try{
    taskMapList = (MapList)formBean.getElementValue("taskMapList");
  }catch(Exception tml){
      taskMapList = new MapList();
  }

  if(taskMapList == null){
    taskMapList = new MapList();
  }

 if(memberType.equals("Role"))
{

 MapList roleMapList =null;
 try{
      roleMapList = (MapList)formBean.getElementValue("routeRoleMapList");
  }catch(Exception rmt){
	  roleMapList = new MapList();
  }

 if(roleMapList == null)
  {
    roleMapList = new MapList();
  }


MapList tempRoleMapList = new MapList();

if(memberID.length > 0)
{
	isFound           = true;

  for( int count = 0; count < memberID.length; count++ )
  {

    String roleName = memberID[count];
    if( !"".equals(roleName))
    {
      HashMap tempMap = new HashMap();
      tempMap.put(DomainObject.SELECT_NAME,roleName);
      tempMap.put("LastFirstName", roleName);
      tempMap.put(DomainObject.SELECT_TYPE, "Role");
      tempMap.put("projectLead", "");
      tempMap.put("createRoute", "");
      tempMap.put("OrganizationName","");
      tempMap.put("access","Read");
      tempMap.put(DomainConstants.SELECT_ID , "Role");
      tempRoleMapList.add((Map)tempMap);

      boolean updatedMapList = false;

      Iterator mapItr = taskMapList.iterator();
      while(mapItr.hasNext()){
        HashMap taskMap = (HashMap)mapItr.next();
        if("none".equals((String)taskMap.get("PersonId"))){
          taskMap.put("PersonId","Role");
          taskMap.put("PersonName",roleName);
          taskMap.put(DomainConstants.SELECT_NAME,roleName);
          updatedMapList = true;
          i = i + 1;
          break;
        }

      }

     if(!updatedMapList && allowExtend){
        //For the 4the Step
        HashMap tempHashMap = new HashMap();
        tempHashMap.put("name", roleName);
        tempHashMap.put("PersonId", "Role");
        tempHashMap.put("PersonName", roleName);
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_SEQUENCE,"");
        tempHashMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_ACTION ,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_INSTRUCTIONS ,"");
        tempHashMap.put(personObject.ATTRIBUTE_TITLE ,"");
        tempHashMap.put(personObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,"");
//14nov        tempHashMap.put(personObject.RELATIONSHIP_ROUTE_NODE,String.valueOf(++routeNodeIds));
        taskMapList.add((Map)tempHashMap);
      }
      else {
          if((!updatedMapList) && (!allowExtend)){
            memberNames = memberNames + roleName;
          }
      }

    }

  }
    memberMapList.addAll(tempRoleMapList);
    roleMapList.addAll(tempRoleMapList);
  }
    formBean.setElementValue("routeRoleMapList",roleMapList);
}

if(memberType.equals("Group") )
{
 MapList groupMapList =(MapList)formBean.getElementValue("groupMapList");

 if(groupMapList == null)
  {
    groupMapList = new MapList();
  }


MapList tempGroupMapList = new MapList();

if(memberID.length > 0)
{
	isFound           = true;

  for( int count = 0; count < memberID.length; count++ )
  {

    String groupName = memberID[count];//(String)groupList.elementAt(count);
    if( !"".equals(groupName))
    {
      HashMap tempMap = new HashMap();
      tempMap.put(DomainObject.SELECT_NAME,groupName);
      tempMap.put("LastFirstName", groupName);
      tempMap.put(DomainObject.SELECT_TYPE, "Group");
      tempMap.put("projectLead", "");
      tempMap.put("createRoute", "");
      tempMap.put("OrganizationName","");
      tempMap.put("access","Read");
      tempMap.put(DomainConstants.SELECT_ID , "Group");
      tempGroupMapList.add((Map)tempMap);

      boolean updatedMapList = false;

      Iterator mapItr = taskMapList.iterator();
      while(mapItr.hasNext()){
        HashMap taskMap = (HashMap)mapItr.next();
        if("none".equals((String)taskMap.get("PersonId"))){
          taskMap.put("PersonId","Group");
          taskMap.put("PersonName",groupName);
          taskMap.put(DomainConstants.SELECT_NAME,groupName);
          updatedMapList = true;
          i = i + 1;
          break;
        }

      }

     if(!updatedMapList && allowExtend){
        //For the 4the Step
        HashMap tempHashMap = new HashMap();
        tempHashMap.put("name", groupName);
        tempHashMap.put("PersonId", "Group");
        tempHashMap.put("PersonName", groupName);
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_SEQUENCE,"");
        tempHashMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_ACTION ,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_INSTRUCTIONS ,"");
        tempHashMap.put(personObject.ATTRIBUTE_TITLE ,"");
        tempHashMap.put(personObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,"");
//14nov        tempHashMap.put(personObject.RELATIONSHIP_ROUTE_NODE,String.valueOf(++routeNodeIds));
        taskMapList.add((Map)tempHashMap);
      }
      else {
          if((!updatedMapList) && (!allowExtend)){
            memberNames = memberNames + groupName;
          }
      }

    }
  }
    memberMapList.addAll(tempGroupMapList);
    groupMapList.addAll(tempGroupMapList);
  }
	    formBean.setElementValue("routeGroupMapList",groupMapList);
}


//to put the MapList reqd for the 4th step of Route Wizard in the session
  formBean.setElementValue("taskMapList",taskMapList);
  formBean.setElementValue("routeMemberMapList",memberMapList);
}
else if("Role".equalsIgnoreCase(memberType))
      {Route routeObject = (Route)DomainObject.newInstance(context, sRouteId,
                                                             DomainConstants.TEAM);
		  
		  String strRoles       = emxGetParameter(request, "roleList");

		  if(strRoles != null)
			{
			    roleList = FrameworkUtil.split(strRoles,";");
			  }
			  		  
		  if(roleList != null && roleList.size() > 0){
			  for(int k=0;k<roleList.size();k++)
				  try{
					 	routeObject.addRoleAsRouteMember(context, roleList , allowExtend);
					}catch(Exception e){
						session.putValue("error.message", i18nNow.getI18nString(e.getMessage(), "emxComponentsStringResource" ,sLanguage));
											}
		 }

    Route routeObject1 = (Route)DomainObject.newInstance(context, sRouteId,DomainConstants.TEAM);
     if(routeObject1 != null && DomainConstants.TYPE_ROUTE.equals(routeObject1.getType(context)))
    {		  
      routeObject1.adjustSequenceNumber(context);
    }

    if(!sErrorMsg.equals("")){
      session.putValue("error.message", sErrorMsg);
    }
  }
  else if("Group".equals(memberType))
      {Route routeObject = (Route)DomainObject.newInstance(context, sRouteId,
                                                             DomainConstants.TEAM);
		  String strGroups       = emxGetParameter(request, "groupList");

		  if(strGroups != null)
			{
			    groupList = FrameworkUtil.split(strGroups,";");
			  }
			  		  
		 if(groupList != null && groupList.size() > 0){
			 
			 for(int k=0;k<groupList.size();k++)
				 
			  try{
					 routeObject.addGroupAsRouteMember(context, groupList);
				}catch(Exception e){
						session.putValue("error.message", i18nNow.getI18nString(e.getMessage(), "emxComponentsStringResource", sLanguage));
											}
		 }

    Route routeObject1 = (Route)DomainObject.newInstance(context, sRouteId,DomainConstants.TEAM);
     if(routeObject1 != null && DomainConstants.TYPE_ROUTE.equals(routeObject1.getType(context)))
    {		  
      routeObject1.adjustSequenceNumber(context);
    }

    if(!sErrorMsg.equals("")){
      session.putValue("error.message", sErrorMsg);
    }
  }


%>

<script language="javascript">
<%
if(!"".equals(memberNames)){
%>
alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteWizard.MaintainExactTaskListAlert</emxUtil:i18nScript>");
<%
}
%>
  parent.window.getWindowOpener().parent.location.href=parent.window.getWindowOpener().parent.location.href;
  window.closeWindow();
</script>

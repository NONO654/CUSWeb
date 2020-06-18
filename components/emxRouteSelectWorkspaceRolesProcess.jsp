<%--  emxRouteSelectWorkspaceRolesProcess.jsp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteSelectWorkspaceRolesProcess.jsp.rca 1.9 Wed Oct 22 16:18:33 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxRouteInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<%
  String keyValue = emxGetParameter(request, "keyValue");
  String memberType     = emxGetParameter(request, "memberType");
  String objectId             = emxGetParameter(request, "projectId");
  String sRouteId             = emxGetParameter(request, "routeId");

  String sAttrProjectAccess   =  PropertyUtil.getSchemaProperty(context, "attribute_ProjectAccess");
  String sProjectId           = "";
  String relRouteScope        = PropertyUtil.getSchemaProperty(context, "relationship_RouteScope");
  String typeProject          = PropertyUtil.getSchemaProperty(context, "type_Project");
  String attrTaskEditSetting  = PropertyUtil.getSchemaProperty(context, "attribute_TaskEditSetting");
  String relRouteTemp                   = PropertyUtil.getSchemaProperty(context, "relationship_InitiatingRouteTemplate");
  String attrTemplateTask               = PropertyUtil.getSchemaProperty(context, "attribute_TemplateTask");
  String memberNames          = "";
  String strRoles       = emxGetParameter(request, "roleList");

  int i = 0;
  int j = 0;
  boolean allowExtend         = true;
  boolean addRoles      = false;
  StringList roleList  = new StringList();

  if(strRoles != null)
  {
    roleList = FrameworkUtil.split(strRoles,";");
  }

  DomainObject personObject= null;
  BusinessObject tempObj = new BusinessObject(objectId);
  tempObj.open(context);

  if(!(tempObj.getTypeName().equals(typeProject))){
    sProjectId = UserTask.getProjectId(context, objectId);
  }else{
    sProjectId = objectId;
  }
  tempObj.close(context);

  if(sRouteId != null && (!sRouteId.equals(""))){

    // Set the domain object as Route to connect persons.
    Route routeObject = (Route)DomainObject.newInstance(context, sRouteId);

    String sErrorMsg = "";

    String sTempId = routeObject.getInfo(context , "from[" + relRouteTemp + "].to.id");
    if(sTempId != null && !"".equals(sTempId)){
      DomainObject routeTempObj = DomainObject.newInstance(context , sTempId);
      String strTaskEditSetting = routeTempObj.getAttributeValue(context,attrTaskEditSetting);
      if(strTaskEditSetting != null && strTaskEditSetting.trim().equals("Maintain Exact Task List")){
        allowExtend = false;
      }
    }
    if(roleList != null && roleList.size() > 0){
      try{
        routeObject.addRoleAsRouteMember(context, roleList , allowExtend);
      }catch(Exception e){
         session.putValue("error.message", i18nNow.getI18nString(e.getMessage(), "emxComponentsStringResource", sLanguage));
      }
    }

    Route routeObject1 = (Route)DomainObject.newInstance(context, sRouteId);
    if(routeObject1 != null && DomainConstants.TYPE_ROUTE.equals(routeObject1.getType(context)))
    {
      routeObject1.adjustSequenceNumber(context);
    }

    if(!sErrorMsg.equals("")){
      session.putValue("error.message", sErrorMsg);
    }

  } else{

  //Starting Route Wizard Part

  int routeNodeIds           = 0;
  int tempRouteNodeIds       = 0;

  
MapList memberMapList = null;
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

  }else{
    taskMapList.sort("Route Sequence","ascending","integer");
    Iterator mapItr = taskMapList.iterator();
    while(mapItr.hasNext()) {
      Map  map                = (Map)mapItr.next();
      tempRouteNodeIds        = Integer.parseInt((String)map.get(personObject.RELATIONSHIP_ROUTE_NODE));
      routeNodeIds = (tempRouteNodeIds>routeNodeIds)?tempRouteNodeIds:routeNodeIds;
    }
  }

 MapList roleMapList = null;
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

if(roleList.size() > 0)
{
  for( int count = 0; count < roleList.size(); count++ )
  {
    String roleName = (String)roleList.elementAt(count);
    if( !"".equals(roleName))
    {
      HashMap tempMap = new HashMap();
      tempMap.put("name", roleName);
      tempMap.put("LastFirstName", roleName);
      tempMap.put("type", "Role");
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
        tempHashMap.put(personObject.RELATIONSHIP_ROUTE_NODE,String.valueOf(++routeNodeIds));
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


  //to put the MapList reqd for the 4th step of Route Wizard in the session

  formBean.setElementValue("taskMapList",taskMapList);
  formBean.setElementValue("routeMemberMapList",memberMapList);
  formBean.setElementValue("routeRoleMapList",roleMapList);

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
/*  parent.window.getWindowOpener().parent.location.href=parent.window.getWindowOpener().parent.location.href;
  parent.window.close();2 dec*/
  parent.window.getWindowOpener().parent.location.reload();
   window.closeWindow();
</script>

<%--  emxRouteSelectWorkspaceMembersProcess.jsp   -  Creating the WorkSpace Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteSelectWorkspaceMembersProcess.jsp.rca 1.11 Wed Oct 22 16:17:58 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxRouteInclude.inc" %>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

  String keyValue = emxGetParameter(request, "keyValue");
  String sUser = context.getUser();
  // read the Member list passed in
//17dec  String memberID[]           = emxGetParameterValues(request, "chkItem1");

  String memberID[]           = emxGetParameterValues(request, "selectedPerson");
  String memberType     = emxGetParameter(request, "memberType");
  String objectId             = emxGetParameter(request, "projectId");
  String sRouteId             = emxGetParameter(request, "routeId");
  String sAttrProjectAccess   =  PropertyUtil.getSchemaProperty(context, "attribute_ProjectAccess");
  String sProjectId           = "";
  String relRouteScope        = PropertyUtil.getSchemaProperty(context, "relationship_RouteScope");
  String typeProject          = PropertyUtil.getSchemaProperty(context, "type_Project");
  String attrTaskEditSetting  = PropertyUtil.getSchemaProperty(context, "attribute_TaskEditSetting");
  String relRouteTemp                   = PropertyUtil.getSchemaProperty(context, "relationship_InitiatingRouteTemplate");
  //String attrTemplateTask               = PropertyUtil.getSchemaProperty(context, "attribute_TemplateTask");
  String memberNames          = "";
  int i = 0;
  int j = 0;
  boolean allowExtend         = true;
  StringList roleList  = new StringList();

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

   if("Person".equalsIgnoreCase(memberType)){
    String sScopeType = routeObject.getInfo(context, "to["+relRouteScope+"].from.type");
    sProjectId = objectId;
    if(!sScopeType.equals(typeProject)) {
      sProjectId = UserTask.getProjectId(context, objectId);
    }
    AccessUtil accessUtil = new AccessUtil();
    AccessList accList = new AccessList();
    Access access = new Access();
    //preload lookup strings
    String sRouteNode = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");
    String[] args = new String[]{sRouteId};
    Pattern typePattern = new Pattern(DomainObject.TYPE_PERSON);
    typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
    Pattern relPattern = new Pattern(sRouteNode);
    StringList selectTypeStmts = new StringList();
    selectTypeStmts.add(DomainObject.SELECT_TYPE);
    StringList selectRelStmts = new StringList();
    selectRelStmts.add(DomainObject.SELECT_RELATIONSHIP_ID);
    selectRelStmts.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]");
    selectRelStmts.add("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
    MapList tskMapList = routeObject.getRelatedObjects(context,
                                                        relPattern.getPattern(),  //String relPattern
                                                        typePattern.getPattern(), //String typePattern
                                                        selectTypeStmts,          //StringList objectSelects,
                                                        selectRelStmts,                     //StringList relationshipSelects,
                                                        false,                    //boolean getTo,
                                                        true,                     //boolean getFrom,
                                                        (short)1,                 //short recurseToLevel,
                                                        "",                       //String objectWhere,
                                                        "",                       //String relationshipWhere,
                                                        null,                     //Pattern includeType,
                                                        null,                     //Pattern includeRelationship,
                                                        null);                    //Map includeMap
    tskMapList.sort("attribute["+DomainObject.ATTRIBUTE_ROUTE_SEQUENCE+"]","ascending","integer");
    for(int count =0; count < memberID.length; count++ ) {
      StringTokenizer stTok = new StringTokenizer(memberID[count] , "~");
      String typeVar        = stTok.nextToken();


    if("Person".equals(typeVar))
    {
      String typePersonId = stTok.nextToken();

      personObject = DomainObject.newInstance(context , typePersonId);
      Iterator mapItr = tskMapList.iterator();
      boolean updatedList = false;
      while(mapItr.hasNext()){
       Map taskMap = (Map)mapItr.next();
       String typeStr = (String)taskMap.get(DomainObject.SELECT_TYPE);
       String routeTaskUser = (String)taskMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
       if(typeStr != null && DomainObject.TYPE_ROUTE_TASK_USER.equals(typeStr) && (routeTaskUser==null ||"".equals(routeTaskUser))){
          String relId = (String)taskMap.get(DomainObject.SELECT_RELATIONSHIP_ID);
            DomainRelationship.modifyTo(context,relId,personObject);
            AccessUtil accUt = new AccessUtil();
            accUt.setRead(personObject.getName(context));

          if(accUt.getAccessList().size() > 0){
            emxGrantAccess GrantAccess = new emxGrantAccess(DomainObject.newInstance(context,sRouteId));
            GrantAccess.grantAccess(context, accUt);

          }


          taskMap.put(DomainObject.SELECT_TYPE,DomainObject.TYPE_PERSON);
          updatedList = true;
          i = i + 1;
          break;
        }
      }
      if ((!updatedList) && allowExtend){
         try {
               DomainRelationship domNewRel = personObject.connectFrom(context,sRouteNode, routeObject);
             } catch(Exception exp) {
                 if(sErrorMsg.equals("")) {
                   sErrorMsg = i18nNow.getI18nString("emxComponents.Common.ConnectError", "emxComponentsStringResource", sLanguage);
                 }
                 sErrorMsg += personObject.getName() + ":" + exp.getMessage();
              }
       }else{
         if((!updatedList) && (!allowExtend)){
           memberNames = memberNames + personObject.getName(context)  + ", " ;
           j = j + 1;
          }
       }
      }
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
  }

 else{

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
  if( memberID != null )
  {

  for(int count =0; count < memberID.length; count++ ) {


    StringTokenizer stTok = new StringTokenizer(memberID[count] , "~");
    String typeVar        = stTok.nextToken();
    if("Person".equals(typeVar) || !stTok.hasMoreTokens())
    {

      String personTypeId     = "";

      if(!stTok.hasMoreTokens())
      {
        personTypeId = memberID[count];
      }else
      {
        personTypeId = stTok.nextToken();
      }

      personObject =   DomainObject.newInstance(context , personTypeId);
      BusinessObject memberObject = JSPUtil.getProjectMember(context,  session , sProjectId, new BusinessObject(personTypeId.trim()));
      String sProjectLead         = JSPUtil.getAttribute(context, session,memberObject,personObject.ATTRIBUTE_PROJECT_ACCESS);
      String sCreateRoute         = JSPUtil.getAttribute(context, session,memberObject,PropertyUtil.getSchemaProperty(context, "attribute_CreateRoute"));
      String sOrgName             = personObject.getInfo(context,"to["+personObject.RELATIONSHIP_EMPLOYEE+"].from.name");
      String sFirstName           = personObject.getInfo(context,"attribute["+personObject.ATTRIBUTE_FIRST_NAME +"]");
      String sLastName            = personObject.getInfo(context,"attribute["+personObject.ATTRIBUTE_LAST_NAME +"]");
      String userName             = personObject.getName();

    HashMap tempMap = new HashMap();
      tempMap.put(personObject.SELECT_ID,personTypeId);
      tempMap.put(personObject.SELECT_NAME, userName);
      tempMap.put("LastFirstName",sLastName+", "+sFirstName);
      tempMap.put(personObject.SELECT_TYPE,personObject.getType(context));
      tempMap.put("projectLead",sProjectLead);
      tempMap.put("createRoute",sCreateRoute);
      tempMap.put("OrganizationName",sOrgName);
      if(userName.equals(sUser)){
        tempMap.put("access","Add Remove");
        }else{
                tempMap.put("access","Read");
        }
      memberMapList.add((Map)tempMap);
      boolean updatedMapList = false;
      Iterator mapItr = taskMapList.iterator();
      while(mapItr.hasNext()){
        HashMap taskMap = (HashMap)mapItr.next();
        if("none".equals((String)taskMap.get("PersonId"))){
          taskMap.put("PersonId",personTypeId);
          taskMap.put("PersonName",sLastName+", "+sFirstName);
          taskMap.put(DomainConstants.SELECT_NAME,userName);
          updatedMapList = true;
          i = i + 1;
          break;
        }

      }

      //For the 4th Step
      if(!updatedMapList && allowExtend){
        HashMap tempHashMap = new HashMap();
        tempHashMap.put("PersonId",personTypeId);
        tempHashMap.put(personObject.SELECT_NAME, userName);
        tempHashMap.put("PersonName",sLastName+", "+sFirstName);
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_SEQUENCE,"");
        tempHashMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_ACTION ,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_INSTRUCTIONS ,"");
        tempHashMap.put(personObject.ATTRIBUTE_TITLE ,"");
        tempHashMap.put(personObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,"");
        tempHashMap.put(personObject.RELATIONSHIP_ROUTE_NODE,String.valueOf(++routeNodeIds));
        taskMapList.add((Map)tempHashMap);
        //routeNodeIds++;
      }
      else {
        if((!updatedMapList) && (!allowExtend)){
          j = j + 1;
          memberNames = memberNames + sFirstName + " " + sLastName + ", " ;
        }
      }
    }
    else if("Role".equals(typeVar))
    {
      String roleTypeName = stTok.nextToken();
      if(roleTypeName != null && !roleList.contains(roleTypeName))
      {
        roleList.add(roleTypeName);
      }
    }
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
  formBean.setFormValues(session);

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

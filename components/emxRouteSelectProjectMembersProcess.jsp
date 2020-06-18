<%--  emxRouteSelectProjectMembersProcess.jsp  - The person search summary page

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxRouteSelectProjectMembersProcess.jsp.rca 1.11 Wed Oct 22 16:18:32 2008 przemek Experimental przemek $
--%>

<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
com.matrixone.apps.common.Person person =
      (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
      DomainConstants.TYPE_PERSON);


String keyValue = emxGetParameter(request, "keyValue");
String selectMultiple= emxGetParameter(request,"selectMultiple");
String memberID[]           = emxGetParameterValues(request, "selectedPerson");
if(memberID == null)
{
   memberID = emxGetParameterValues(request, "chkItem1");
}
String memberType     = emxGetParameter(request, "memberType");
String objectId             = emxGetParameter(request, "projectId");
String sRouteId             = emxGetParameter(request, "routeId");

StringList roleList = new StringList();
StringList groupList = new StringList();

boolean allowExtend         = true;
String memberNames          = "";
int i = 0;

String relRouteTemp                   = PropertyUtil.getSchemaProperty(context, "relationship_InitiatingRouteTemplate");
String attrTaskEditSetting  = PropertyUtil.getSchemaProperty(context, "attribute_TaskEditSetting");
  int j = 0;
if(sRouteId != null && (!sRouteId.equals(""))){
    // Set the domain object as Route to connect persons.
    Route routeObject = (Route)DomainObject.newInstance(context, sRouteId,
                                                             DomainConstants.TEAM);

    String sErrorMsg = "";

    String sTempId = routeObject.getInfo(context , "from[" + relRouteTemp + "].to.id");
    if(sTempId != null && !"".equals(sTempId)){
      DomainObject routeTempObj = DomainObject.newInstance(context , sTempId);
      String strTaskEditSetting = routeTempObj.getAttributeValue(context,attrTaskEditSetting);
      if(strTaskEditSetting != null && strTaskEditSetting.trim().equals("Maintain Exact Task List")){
        allowExtend = false;
      }
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

    DomainObject personObject= null;
    if("Person".equals(memberType))
    {
	  
	  for(int count =0; count < memberID.length; count++ ) {
      String typePersonId = memberID[count];
	  
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
                   sErrorMsg = i18nNow.getI18nString("emxComponents.Common.ConnectError", "emxComponentsStringResource" ,sLanguage);
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
      else if("Role".equalsIgnoreCase(memberType) || "Group".equalsIgnoreCase(memberType) )//typeVar))
      {
		  String strRoles       = emxGetParameter(request, "roleList");

		  if(strRoles != null)
			{
			    roleList = FrameworkUtil.split(strRoles,";");
			  }
			
		  if(roleList != null && roleList.size() > 0){
				  try{
				  if("Role".equalsIgnoreCase(memberType))
						routeObject.addRoleAsRouteMember(context, roleList , allowExtend);
				  else if("Group".equalsIgnoreCase(memberType))
				  {
					  routeObject.addGroupAsRouteMember(context, roleList);
				  }
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
}

else
{ MapList roleMapList = null;

   MapList memberMapList = null;
   try{
    memberMapList = (MapList)formBean.getElementValue("routeMemberMapList");
          if(memberMapList == null)
                memberMapList = new MapList();
   }catch(Exception mml){
      memberMapList = new MapList();
   }
MapList taskMapList = null;
  try{
    taskMapList = (MapList)formBean.getElementValue("taskMapList");
    if(taskMapList == null)
        taskMapList = new MapList();
  }catch(Exception tml){
      taskMapList = new MapList();
  }

  DomainObject personObject= null;
if(memberID!=null && memberID.length>0)
{
for(int count =0; count < memberID.length; count++ )
{
  
if(memberType.equals("Person"))
{
      HashMap tempMap = new HashMap();
      String personId = (String)memberID[count];
	  personObject = DomainObject.newInstance(context ,personId);

	  String sOrgName             = personObject.getInfo(context,"to["+personObject.RELATIONSHIP_MEMBER+"].from.name");
      String sFirstName           = personObject.getInfo(context,"attribute["+personObject.ATTRIBUTE_FIRST_NAME +"]");
      String sLastName            = personObject.getInfo(context,"attribute["+personObject.ATTRIBUTE_LAST_NAME +"]");
      String userName             = personObject.getName();

      tempMap.put(personObject.SELECT_ID,personId);
      tempMap.put(personObject.SELECT_NAME, userName);
      tempMap.put("LastFirstName",sLastName+","+sFirstName);
      tempMap.put(personObject.SELECT_TYPE,"Person");
      tempMap.put("projectLead","");
      tempMap.put("createRoute","");
      tempMap.put("OrganizationName",sOrgName);
      tempMap.put("access","Read");
      memberMapList.add((Map)tempMap);

      boolean updatedMapList = false;
      Iterator mapItr = taskMapList.iterator();
      while(mapItr.hasNext()){
        HashMap taskMap = (HashMap)mapItr.next();
        if("none".equals((String)taskMap.get("PersonId"))){
          taskMap.put("PersonId",personId);
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
        tempHashMap.put("PersonId",personId);
        tempHashMap.put(personObject.SELECT_NAME, userName);
        tempHashMap.put("PersonName",sLastName+", "+sFirstName);
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_SEQUENCE,"");
        tempHashMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_ACTION ,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_INSTRUCTIONS ,"");
        tempHashMap.put(personObject.ATTRIBUTE_TITLE ,"");
        tempHashMap.put(personObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,"");
        taskMapList.add((Map)tempHashMap);
      }
      else {
        if((!updatedMapList) && (!allowExtend)){
                  memberNames = memberNames + sLastName+", "+sFirstName ;
        }
      }
}
else if(memberType.equals("Role") || memberType.equals("Group")  )
		{
		String strRoles       = emxGetParameter(request, "roleList");
		 if(strRoles != null)
		  {
		    roleList = FrameworkUtil.split(strRoles,";");
		  }

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
  for( int rcount = 0; rcount < roleList.size(); rcount++ )
  {
    String roleName = (String)roleList.elementAt(rcount);
	
    if( !"".equals(roleName))
    {
      HashMap tempMap = new HashMap();
      tempMap.put("name", roleName);
      tempMap.put("LastFirstName", roleName);
      tempMap.put("type", memberType);
      tempMap.put("projectLead", "");
      tempMap.put("createRoute", "");
      tempMap.put("OrganizationName","");
      tempMap.put("access","Read");
      tempMap.put(DomainConstants.SELECT_ID , memberType);
      tempRoleMapList.add((Map)tempMap);

      boolean updatedMapList = false;

      Iterator mapItr = taskMapList.iterator();
      while(mapItr.hasNext()){
        HashMap taskMap = (HashMap)mapItr.next();
        if("none".equals((String)taskMap.get("PersonId"))){
          taskMap.put("PersonId",memberType);
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
        tempHashMap.put("PersonId",memberType);
        tempHashMap.put("PersonName", roleName);
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_SEQUENCE,"");
        tempHashMap.put(personObject.ATTRIBUTE_ALLOW_DELEGATION,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_ACTION ,"");
        tempHashMap.put(personObject.ATTRIBUTE_ROUTE_INSTRUCTIONS ,"");
        tempHashMap.put(personObject.ATTRIBUTE_TITLE ,"");
        tempHashMap.put(personObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE,"");
        taskMapList.add((Map)tempHashMap);
      }
      else {
          if((!updatedMapList) && (!allowExtend)){
            memberNames = memberNames + roleName;
          }
      }
        memberMapList.addAll(tempRoleMapList);
        roleMapList.addAll(tempRoleMapList);
      }
    }
  }
 }
}
}
  //to put the MapList reqd for the 4th step of Route Wizard in the session

  formBean.setElementValue("taskMapList",taskMapList);
  formBean.setElementValue("routeMemberMapList",memberMapList);
  formBean.setElementValue("routeRoleMapList",roleMapList);
  formBean.setFormValues(session);
}

%>
<script>
  parent.window.getWindowOpener().parent.location.reload();
  window.closeWindow();
  </script>




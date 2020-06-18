<%--  emxRouteDeleteWorkspaceMembersProcess.jsp   -  Deleting the Selected Members and dosconnecting the route members.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $ Exp $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>

<%
  // read the objId and ProjectId passed in
  String objId[]         = emxGetParameterValues(request, "chkItem");
  String sSelectPersonId = emxGetParameter(request, "personIds");

  String jsTreeID        = emxGetParameter(request, "jsTreeID");
  String objectId        = emxGetParameter(request, "objectId");
  String workspaceId     = emxGetParameter(request, "workspaceId");
  String sTypeName       = emxGetParameter(request, "type");

  String typeRoute           = PropertyUtil.getSchemaProperty(context, "type_Route");
  String typeWorkspace       = PropertyUtil.getSchemaProperty(context, "type_Project");
  String typeMessage         = PropertyUtil.getSchemaProperty(context, "type_Message");
  String typeThread          = PropertyUtil.getSchemaProperty(context, "type_Thread");
  String typeDocument        = PropertyUtil.getSchemaProperty(context, "type_Document");
  String typeWorkspaceVault  = PropertyUtil.getSchemaProperty(context, "type_ProjectVault");
  String type_Event          = PropertyUtil.getSchemaProperty(context, "type_Event");
  String type_Pub_Subscribe  = PropertyUtil.getSchemaProperty(context, "type_PublishSubscribe");

  String sAttrAccessType = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
  String relMessage      = PropertyUtil.getSchemaProperty(context, "relationship_Message");
  String relThread       = PropertyUtil.getSchemaProperty(context, "relationship_Thread");
  String relReply  =  PropertyUtil.getSchemaProperty(context, "relationship_Reply");
  String relSubVaults  =  PropertyUtil.getSchemaProperty(context, "relationship_SubVaults");
  String relRouteScope  =  PropertyUtil.getSchemaProperty(context, "relationship_RouteScope");
  String relVaultedObjects  =  PropertyUtil.getSchemaProperty(context, "relationship_VaultedDocuments");
  String relWorkspaceVaults  =  PropertyUtil.getSchemaProperty(context, "relationship_ProjectVaults");
  String relSubscribedItem  =  PropertyUtil.getSchemaProperty(context, "relationship_SubscribedItem");
  String relSubscribedPerson  =  PropertyUtil.getSchemaProperty(context, "relationship_SubscribedPerson");
  String relPushedSubscription  =  PropertyUtil.getSchemaProperty(context, "relationship_PushedSubscription");
  String relProjectMembership  =  PropertyUtil.getSchemaProperty(context, "relationship_ProjectMembership");
  String relProjectMembers  =  PropertyUtil.getSchemaProperty(context, "relationship_ProjectMembers");
  boolean reArrangeTasks  = false;

  String sPersonId    = "";
  StringTokenizer sPersonIdsToken =null;

  DomainObject    domainObject   =  DomainObject.newInstance(context);
  DomainObject    message        =  DomainObject.newInstance(context);
  Route route                    = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  Document document              = (Document)DomainObject.newInstance(context,DomainConstants.TYPE_DOCUMENT);
  Message messageBean            = (Message)DomainObject.newInstance(context,DomainConstants.TYPE_MESSAGE);
  WorkspaceVault folder          = (WorkspaceVault)DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT);
  Workspace workspace            = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE);

  DomainRelationship routeNodeRelObj  = new DomainRelationship();
  StringList granteeList              = new StringList();
  StringList roleList                 = new StringList();

  String conObjectId = "";
  String threadId    = "";

  AccessUtil accessUtil    = new AccessUtil();
  BusinessObject conObject = null;
  BusinessObject person    = null;
  String strIsRole         = "";
  Access noneAccess        = null;
  boolean flagStr          = true;




  DomainObject ObjectGeneral = new DomainObject(objectId);
  String strType = ObjectGeneral.getType(context);

  if(strType != null && strType.equals(DomainObject.TYPE_PROJECT)){
  StringList objSelects = new StringList();
  objSelects.add(DomainObject.SELECT_OWNER);

  StringList ownerList    = new StringList();
  String personNameStr = "";


  // get all workspaces that the user is a Project-Member
  MapList routeTemplateList = ObjectGeneral.getRelatedObjects(context,
                                                      DomainObject.RELATIONSHIP_ROUTE_TEMPLATES,  //String relPattern
                                                      DomainObject.TYPE_ROUTE_TEMPLATE,           //String typePattern
                                                      objSelects,                                 //StringList objectSelects,
                                                      null,                     //StringList relationshipSelects,
                                                      true,                     //boolean getTo,
                                                      true,                     //boolean getFrom,
                                                      (short)1,                 //short recurseToLevel,
                                                      "",                       //String objectWhere,
                                                      "",                       //String relationshipWhere,
                                                      null,                     //Pattern includeType,
                                                      null,                     //Pattern includeRelationship,
                                                      null);                    //Map includeMap


   Iterator routeTemplateListItr = routeTemplateList.iterator();


   while(routeTemplateListItr.hasNext()){
       Map routeTempMap = (Map)routeTemplateListItr.next();
       String ownerName = (String)routeTempMap.get(DomainObject.SELECT_OWNER);
       if(!ownerList.contains(ownerName)){
         ownerList.add(ownerName);
       }
     }

    StringTokenizer personIdsToken = new StringTokenizer(sSelectPersonId,";",false);
    com.matrixone.apps.common.Person personObj1 = new com.matrixone.apps.common.Person();
    String netName = "";
    while (personIdsToken.hasMoreTokens()) {
    String personIdStr = personIdsToken.nextToken();
      if(personIdStr != null){
        personObj1.setId(personIdStr);
        String nameStr = personObj1.getName(context);
         if (ownerList.contains(nameStr)){
          netName = netName + nameStr + " ,";
        }
      }
    }
    if (!"".equals(netName))
    {
%>
<script language="javascript">
  alert("<%=netName + " " %>" + "<emxUtil:i18nScript localize="i18nId">emxComponents.AccessSummary.RemoveTemplateOwner</emxUtil:i18nScript>");
  parent.location.reload();
</script>

<%
    flagStr = false;
    }
  }

if(flagStr)
{
  try{
    if(!typeMessage.equals(sTypeName)){
      for (int i = 0; i < objId.length; i++) {

        if (typeRoute.equals(sTypeName)){
          String rtState = ObjectGeneral.getInfo(context, DomainObject.SELECT_CURRENT);
          if(rtState != null && "Define".equals(rtState)){
            StringTokenizer tokenizer = new StringTokenizer(objId[i],"~");
            while (tokenizer.hasMoreTokens()) {
              String rtNode = tokenizer.nextToken();                        

              DomainRelationship domRel = new DomainRelationship(rtNode);  
              DomainObject rtaskUser = DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TASK_USER);
              rtaskUser.createObject(context,DomainConstants.TYPE_ROUTE_TASK_USER,null,null,DomainObject.POLICY_ROUTE_TASK_USER,context.getVault().getName());

			  
              if (rtaskUser != null){
				
                DomainRelationship.setAttributeValue(context,rtNode,DomainObject.ATTRIBUTE_ROUTE_TASK_USER,"");
                DomainRelationship.modifyTo(context,rtNode,rtaskUser);
				              }
            }
          }
          else
          {
            StringTokenizer tokenizer = new StringTokenizer(objId[i],"~");
            while (tokenizer.hasMoreTokens()) {
              String rtNode = tokenizer.nextToken();                        
              DomainRelationship.disconnect(context , rtNode);            
            }
            reArrangeTasks = true;
          }
    
       } else {
          strIsRole = emxGetParameter(request,objId[i]);
          StringList personList = new StringList();
          StringList subscribedItemList = new StringList();
          String persId = "";
          String personName = "";
          if ("true".equalsIgnoreCase(strIsRole)){
            //The object deleted is a Role
            workspace.setId(objectId);
            Pattern typePattern1 = new Pattern(type_Event);
            typePattern1.addPattern(type_Pub_Subscribe);
            typePattern1.addPattern(DomainObject.TYPE_PERSON);

            Pattern relPattern1 = new Pattern(DomainObject.RELATIONSHIP_PUBLISH);
            relPattern1.addPattern(DomainObject.RELATIONSHIP_PUBLISH_SUBSCRIBE);
            relPattern1.addPattern(DomainObject.RELATIONSHIP_SUBSCRIBED_PERSON);

            StringList objectSelects = new StringList();

            objectSelects.add(DomainObject.SELECT_ID);
            objectSelects.add(DomainObject.SELECT_TYPE);

            //Retrieve all subscribed persons to all subscribed events from the workspace
            MapList tempPersonList = workspace.getRelatedObjects(context,
                                                          relPattern1.getPattern(),
                                                          typePattern1.getPattern(),
                                                          objectSelects,
                                                          null,
                                                          true,
                                                          true,
                                                          (short)0,
                                                          "",
                                                          "",
                                                          new Pattern(DomainObject.TYPE_PERSON),
                                                          new Pattern(DomainObject.RELATIONSHIP_SUBSCRIBED_PERSON),
                                                          null);

            //Retrieve all project members of the workspace
            StringList personProjMemList = workspace.getInfoList(context,"from["+relProjectMembers+"].to.to["+relProjectMembership+"].from.id");
            if(personProjMemList==null){
              personProjMemList = new StringList();
            }
            Iterator personItr = tempPersonList.iterator();
            while(personItr.hasNext()){
              Map personMap = (Map)personItr.next();
              persId = (String)personMap.get(DomainObject.SELECT_ID);
              Person person1 = (Person)DomainObject.newInstance(context,persId);
              //Person belongs to Role selected but is not a Project member of the workspace
              if(person1.hasRole(context, objId[i]) && !personProjMemList.contains(persId)){
                personList.add(persId);
              }
            }
           } else{
             // check for subscriptions only if "SubscribedItem" Rel exists for the project member
             DomainObject projectMemberObject = new DomainObject(objId[i]);
             subscribedItemList = projectMemberObject.getInfoList(context, "to["+relSubscribedItem+"].from.id");
             persId = projectMemberObject.getInfo(context, "to["+relProjectMembership+"].from.id");
             personName = projectMemberObject.getInfo(context, "to["+relProjectMembership+"].from.name");
             personList.add(persId);
            }

             if(subscribedItemList.size() > 0 || personList.size() > 0){
               for(int j=0;j<personList.size();j++){
                 // remove all subscriptions that this person has to the given object, also remove from the sub-level objects.
                 // check is done only for Workspace, Folder and Document objects

                // check for the current object, remove all subscriptions for the user
                String personId = (String)personList.elementAt(j);
                workspace.setId(objectId);
                SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
                subscriptionMgr.removeAllSubscriptions(context, objectId, personId, objId[i]);

                StringList objectSelects = new StringList();
                objectSelects.addElement(workspace.SELECT_ID);
                objectSelects.addElement(workspace.SELECT_TYPE);

                Pattern typePattern = new Pattern(typeWorkspaceVault);
                typePattern.addPattern(typeDocument);
                typePattern.addPattern(typeRoute);
                typePattern.addPattern(typeThread);
                typePattern.addPattern(typeMessage);

                Pattern relPattern = new Pattern(relWorkspaceVaults);
                relPattern.addPattern(relVaultedObjects);
                relPattern.addPattern(relRouteScope);
                relPattern.addPattern(relSubVaults);
                relPattern.addPattern(relThread);
                relPattern.addPattern(relMessage);
                relPattern.addPattern(relReply);

                //loop thro. and get all the objects down and check for subscriptions
                MapList objectMapList = workspace.getRelatedObjects
                                       (context,
                                        relPattern.getPattern(),  //relationshipPattern
                                        typePattern.getPattern(), //typePattern
                                        objectSelects,            //objectSelects
                                        new StringList(),         //relationshipSelects
                                        false,                     //getTo
                                        true,                     //getFrom
                                        (short)0,                 //recurseToLevel
                                        "",                       //objectWhere
                                        ""                        //relationshipWhere
                                       );
                Iterator objectItr = objectMapList.iterator();
                //iterate thro. the objects and remove the subscriptions for the user
                while(objectItr.hasNext())
                {
                  Map objectMap = (Map) objectItr.next();
                  String subscribedId = (String) objectMap.get(workspace.SELECT_ID);
                  String subscribedType = (String) objectMap.get(workspace.SELECT_TYPE);

                  DomainObject subscribedObject = new DomainObject(subscribedId);

                  if(subscribedType.equals(typeWorkspaceVault))
                  {
                    folder.setId(subscribedId);
                    subscriptionMgr = folder.getSubscriptionManager();
                    subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, objId[i]);
                  }
                  else if(subscribedType.equals(typeDocument))
                  {
                    document.setId(subscribedId);
                    subscriptionMgr = document.getSubscriptionManager();
                    subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, objId[i]);
                  }
                  else if(subscribedType.equals(typeMessage))
                  {
                    messageBean.setId(subscribedId);
                    subscriptionMgr = messageBean.getSubscriptionManager();
                    subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, objId[i]);
                  }
                  else if(subscribedType.equals(typeRoute))
                  {
                    route.setId(subscribedId);
                    subscriptionMgr = route.getSubscriptionManager();
                    subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, objId[i]);
                  }
                }
              }
            }
             // subscription checks end
          if ("true".equalsIgnoreCase(strIsRole)){
            Workspace.removeProjectMember(context,objectId, objId[i], null);
          }
          else{
            Workspace.removeProjectMember(context,objectId, personName, objId[i]);
          }

        }
      }
      
      if(reArrangeTasks)
      {
        //Reordering the Route Sequence Numbers of the Route node relationships
        Route routeObect =(Route)DomainObject.newInstance(context,objectId);
        routeObect.adjustSequenceNumber(context);
      }
      
      

      if (typeWorkspace.equals(sTypeName)){
         workspace.setId(objectId);
      }

    } else {

      message.setId(objectId);
      String sAccessType = message.getInfo(context,"to["+relMessage+"].attribute["+sAttrAccessType+"]");
      if("Specific".equals(sAccessType)){
        granteeList = message.getGrantees(context);
      } else {
      // getting the object id connected to Thread type
        conObjectId = message.getInfo(context,"to["+relMessage+"].from.to["+relThread+"].from.id");
        conObject   = new BusinessObject(conObjectId);
        conObject.open(context);
        granteeList = conObject.getGrantees(context);
        conObject.close(context);
        threadId = message.getInfo(context,"to["+relMessage+"].from.id");
     }
     String relMessageId = message.getInfo(context,"to["+relMessage+"].id");
     DomainRelationship.setAttributeValue(context,relMessageId,sAttrAccessType,"Specific");
     if (granteeList == null){
        granteeList = new StringList();
     }
     //removing the duplicates
     boolean exist=true;
     for (int k=0;k<granteeList.size();k++){
         Object obj = granteeList.elementAt(k);
         exist=true;
         while(exist){
           if(granteeList.indexOf(obj) == granteeList.lastIndexOf(obj) ){
             exist = false;
           } else{
             granteeList.remove(obj);
           }
         }
     }
     BusinessObjectList objList = new BusinessObjectList();
     objList.addElement((BusinessObject)message);
     //revoking Access for the members for Thread object
     try {
      BusinessObject.revokeAccessRights(context,objList);
     } catch(Exception exp){
       session.putValue("error.message", exp.getMessage());
     }
     for (int i = 0; i < objId.length; i++) {

       granteeList.removeElement(objId[i]);

     }
     //granting ADD Access to the members for Thread object
     for (int j = 0;j < granteeList.size(); j++) {
      accessUtil.setAdd((String)granteeList.elementAt(j));
     }
     try {
      if (accessUtil.getAccessList().size() > 0){
         emxGrantAccess grantAccess = new emxGrantAccess(new DomainObject(objectId));
         grantAccess.grantAccess(context, accessUtil);
      }
     } catch(Exception exp) {
       session.putValue("error.message", exp.getMessage());
     }
   }
  } catch(Exception e){
    session.putValue("error.message",e.getMessage());
  }
%>

  <script language="javascript">
    var tree = getTopWindow().objDetailsTree;
<%

    sPersonIdsToken = new StringTokenizer(sSelectPersonId,";",false);
    while (sPersonIdsToken.hasMoreTokens()) {
      sPersonId = sPersonIdsToken.nextToken();
%>
      tree.getSelectedNode().removeChild("<%=XSSUtil.encodeForJavaScript(context, sPersonId)%>");
<%
    }
%>
    parent.location.reload();
  </script>

<%
}
%>

<%--  emxTeamEventsFrmwrk.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamEventsFrmwrk.inc.rca 1.23 Wed Oct 22 16:06:24 2008 przemek Experimental przemek $
--%>
<%@ page import="java.util.*" %>

<%!
    public TreeMap AddProjectEvents(HttpServletRequest request) throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(Workspace.EVENT_ROUTE_STARTED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteStarted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_ROUTE_COMPLETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteCompleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_FOLDER_CREATED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.TopicCreated","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_FOLDER_DELETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.TopicDeleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_MEMBER_ADDED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.MemberAdded","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_MEMBER_REMOVED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.MemberRemoved","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_FOLDER_CONTENT_MODIFIED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.CategoryModified","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_NEW_DISCUSSION, i18nNow.getI18nString("emxTeamCentral.DiscussionSummary.NewDiscussion","emxTeamCentralStringResource", request.getHeader("Accept-Language")));      
      return eventMap;
    }
%>
<%!
    public TreeMap AddRouteEvents(HttpServletRequest request) throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(Workspace.EVENT_ROUTE_STARTED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteStarted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Workspace.EVENT_ROUTE_COMPLETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteCompleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Route.EVENT_CONTENT_ADDED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.FileAdded","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Route.EVENT_CONTENT_REMOVED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.FileRemoved","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Route.EVENT_TASK_COMPLETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.TaskCompleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      return eventMap;
    }
%>
<%!
    public TreeMap AddTopicsEvents(HttpServletRequest request) throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(WorkspaceVault.EVENT_CONTENT_ADDED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.FileAdded","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(WorkspaceVault.EVENT_CONTENT_REMOVED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.FileRemoved","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(WorkspaceVault.EVENT_FOLDER_CREATED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.TopicCreated","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(WorkspaceVault.EVENT_FOLDER_DELETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.TopicDeleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(WorkspaceVault.EVENT_ROUTE_STARTED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteStarted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(WorkspaceVault.EVENT_ROUTE_COMPLETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteCompleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      return eventMap;
    }
%>
<%!
    public TreeMap AddDocumentEvents(HttpServletRequest request) throws Exception {
      TreeMap eventMap = new TreeMap();
      //eventMap.put(Document.EVENT_FILE_CHECK_OUT,  i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.FileCheckOut","emxComponentsStringResource", request.getHeader("Accept-Language")));
      //eventMap.put(Document.EVENT_FILE_CHECKED_IN, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.FileCheckedIn","emxComponentsStringResource", request.getHeader("Accept-Language")));

      eventMap.put(Document.BASE_REVISED, i18nNow.getI18nString("emxComponents.Event.Document_Revised","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.BASE_MODIFIED, i18nNow.getI18nString("emxComponents.Event.Document_Modified","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.BASE_DELETED, i18nNow.getI18nString("emxComponents.Event.Document_Deleted","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.CONTENT_ADDED, i18nNow.getI18nString("emxComponents.Event.Content_Added","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.CONTENT_MODIFIED, i18nNow.getI18nString("emxComponents.Event.Content_Modified","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.CONTENT_DELETED, i18nNow.getI18nString("emxComponents.Event.Content_Deleted","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.CONTENT_CHECKED_OUT, i18nNow.getI18nString("emxComponents.Event.Content_Checked_Out","emxComponentsStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.EVENT_ROUTE_STARTED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteStarted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      eventMap.put(Document.EVENT_ROUTE_COMPLETED, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.RouteCompleted","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
    
      return eventMap;
    }
%>
<%!
    public TreeMap AddDiscussionEvents(HttpServletRequest request) throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(MessageHolder.EVENT_NEW_DISCUSSION, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.NewDiscussion","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      return eventMap;
    }
%>
<%!
    public TreeMap AddMessageEvents(HttpServletRequest request) throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(Message.EVENT_NEW_REPLY, i18nNow.getI18nString("emxTeamCentral.EventFrmwrk.NewReply","emxTeamCentralStringResource", request.getHeader("Accept-Language")));
      return eventMap;
    }
%>


<%!
  //
  //Returns objectIds of all members connected to a project in a Vector
  //
  static public Hashtable getAllPersonEvents(matrix.db.Context context, HttpSession session) throws MatrixException
  {
    String sRelSubscribe      = Framework.getPropertyValue(session, "relationship_SubscribedPerson");
    String sTypeEvent   = Framework.getPropertyValue(session, "type_Event");

    //matrix.db.Context context   = getPageContext();

    BusinessObject boPerson   = JSPUtil.getPerson(context, session);
    boPerson.open(context);

    Pattern relPattern    = new Pattern(sRelSubscribe);
    Pattern typePattern   = new Pattern(sTypeEvent);

    //Build select params
    SelectList selectStmts  = new SelectList();
    selectStmts.addName();
    selectStmts.addId();

    //Build select params for Relationship
    SelectList selectRelStmts   = new SelectList();

    ExpansionWithSelect expandWSelectAny = boPerson.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                             selectStmts, selectRelStmts,true, true, (short)1);

    BusinessObject boEvent  = null;

    RelationshipWithSelectItr relWSelectAnyItr = new RelationshipWithSelectItr(expandWSelectAny.getRelationships());

    Hashtable evtHash     = new Hashtable();
    Hashtable attrHash    = new Hashtable();
    String sEventId = null;

    //If the PS object doesn't exist then create PS & Event Objects
    while (relWSelectAnyItr != null && relWSelectAnyItr.next()) {
      attrHash      = relWSelectAnyItr.obj().getTargetData();
      sEventId      = (String) attrHash.get("id");
      evtHash.put(sEventId, sEventId);
    }

    boPerson.close(context);

    return evtHash;
 }
%>

<%!
  //
  //Returns objectIds of all members connected to a project in a Vector
  //
  static public TreeMap getAllObjectEvents(matrix.db.Context context, HttpSession session, String objectId) throws MatrixException
  {
    TreeMap eventList     = new TreeMap();
    Hashtable evtProjMemHash  = getAllPersonEvents(context, session);
    //matrix.db.Context context = getPageContext();

    String newPSName    = null;
    String newEventName   = null;


    //Preload lookup strings
    String sTypeEvent       = Framework.getPropertyValue(session, "type_Event");
    String sTypePubSubscribe    = Framework.getPropertyValue(session, "type_PublishSubscribe");
    String sRelPublish    = Framework.getPropertyValue(session, "relationship_Publish");
    String sRelSubscribePerson  = Framework.getPropertyValue(session, "relationship_SubscribedPerson");
    String sRelSubscribeItem    = Framework.getPropertyValue(session, "relationship_SubscribedItem");
    String sRelPublishSubscribe = Framework.getPropertyValue(session, "relationship_PublishSubscribe");
    String sPolicyPubSubscribe  = Framework.getPropertyValue(session, "policy_PublishSubscribe");
    String sPolicyEvent       = Framework.getPropertyValue(session, "policy_Event");
    String sAttrEventType     = Framework.getPropertyValue(session, "attribute_EventType");

    Pattern relPattern    = new Pattern(sRelPublishSubscribe);
    Pattern typePattern   = new Pattern(sTypePubSubscribe);

    BusinessObject boAny    = new BusinessObject(objectId);
    boAny.open(context);

    //Build select params
    SelectList selectStmts  = new SelectList();
    selectStmts.addName();
    selectStmts.addId();

    //Build select params for Relationship
    SelectList selectRelStmts   = new SelectList();

    ExpansionWithSelect expandWSelectAny = boAny.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                             selectStmts, selectRelStmts,true, true, (short)1);

    BusinessObject boPS   = null;

    RelationshipWithSelectItr relWSelectAnyItr = new RelationshipWithSelectItr(expandWSelectAny.getRelationships());

    Hashtable anyHash     = new Hashtable();
    Hashtable psHash    = new Hashtable();
    String sPSId    = null;

    //If the PS object doesn't exist then create PS & Event Objects
    if (relWSelectAnyItr != null && relWSelectAnyItr.next()) {
      anyHash       = relWSelectAnyItr.obj().getTargetData();
      sPSId       = (String) anyHash.get("id");
      boPS      = new BusinessObject(sPSId);
      boPS.open(context);

      Pattern relPSPattern    = new Pattern(sRelPublish);
      Pattern typePSPattern   = new Pattern(sTypeEvent);

      ExpansionWithSelect expandWSelectPS = boPS.expandSelect(context,relPSPattern.getPattern(),typePSPattern.getPattern(),
                                                         selectStmts,selectRelStmts,true, true, (short)1);

      RelationshipWithSelectItr relWSelectPSItr = new RelationshipWithSelectItr(expandWSelectPS.getRelationships());
      BusinessObject boEvent  = null;
      boolean eventFoundBool  = false;

      while (!eventFoundBool && relWSelectPSItr.next()) {
        psHash      = relWSelectPSItr.obj().getTargetData();
        String sEventId   = (String) psHash.get("id");
        boEvent     = new BusinessObject(sEventId);
        boEvent.open(context);

        String eventTypeStr = "";
        AttributeItr  attrItr   = new AttributeItr(boEvent.getAttributes(context).getAttributes());
        AttributeList attrList  = new AttributeList();

        while (attrItr.next()){
          Attribute attr  = attrItr.obj();

          if (attr.getName().equals(sAttrEventType)) {
            eventTypeStr  = attr.getValue();

            if (evtProjMemHash.get(sEventId) != null) {
              eventList.put(eventTypeStr, sEventId);
            }
          }
        }
      }
    }
    return eventList;
  }
%>

<%!
  //
  //Returns BusinessObjectList of all events connected to a project member
  //
  static public BusinessObjectList getAllProjectMemberEvents(matrix.db.Context context, HttpSession session, String projectId, BusinessObject person) throws MatrixException
  {
    //matrix.db.Context context   = getPageContext();

    BusinessObjectList projectEventList = new BusinessObjectList();
    BusinessObject projectEvent = null;


    //Preload lookup strings
    String sTypeEvent       = Framework.getPropertyValue(session, "type_Event");
    String sRelSubcribedItem    = Framework.getPropertyValue(session, "relationship_SubscribedItem");
    String sAttrEventType     = Framework.getPropertyValue(session, "attribute_EventType");

    //Get the project member object
    BusinessObject projectMember = JSPUtil.getProjectMember(context,  session , projectId , person);



    //Build Relationship and Type patterns
    Pattern relPattern    = new Pattern(sRelSubcribedItem);
    Pattern typePattern   = new Pattern(sTypeEvent);

    //Build selectlist  params
    SelectList typeSelectList   = new SelectList();
    typeSelectList.addName();
    typeSelectList.addId();
    typeSelectList.addAttribute(sAttrEventType);

    if(projectMember != null && !("".equals(projectMember)) && !("null".equals(projectMember))){
      projectMember.open(context);

      ExpansionWithSelect projectMemberSelect = projectMember.expandSelect(context, relPattern.getPattern(),typePattern.getPattern(),
                                               typeSelectList, new SelectList(), true, true, (short)1);

      projectMember.close(context);

      // check the Project Member relations
      RelationshipWithSelectItr relItr = new RelationshipWithSelectItr(projectMemberSelect.getRelationships());

      while (relItr.next()) {
        projectEvent    = relItr.obj().getFrom();
        projectEventList.add(projectEvent);

      }
    }

    return projectEventList;
  }
%>

<%!
  //
  //Returns BusinessObjectList of all events connected to a project member
  //
  static public String getFileName(matrix.db.Context context, HttpSession session, String ThreadId) throws MatrixException
  {
    //matrix.db.Context context   = getPageContext();

    //Preload lookup strings
    String sTypeThread      = Framework.getPropertyValue(session, "type_Thread");
    String sTypeDocument  = Framework.getPropertyValue(session, "type_Document");
    String sRelThread   = Framework.getPropertyValue(session, "relationship_Thread");

    //Get the project member object
    BusinessObject boThread   = new BusinessObject(ThreadId);


    //Build Relationship and Type patterns
    Pattern relPattern    = new Pattern(sRelThread);
    Pattern typePattern   = new Pattern(sTypeDocument);

    //Build selectlist  params
    SelectList typeSelectList = new SelectList();
    typeSelectList.addId();

    boThread.open(context);

    ExpansionWithSelect threadMemberSelect = boThread.expandSelect(context, relPattern.getPattern(),typePattern.getPattern(),
                                             typeSelectList, new SelectList(), true, true, (short)1);

    boThread.close(context);

    //Check the Project Member relations
    RelationshipWithSelectItr relItr = new RelationshipWithSelectItr(threadMemberSelect.getRelationships());
    Hashtable psHash    = new Hashtable();

    while (relItr     != null && relItr.next()) {
        psHash = relItr.obj().getTargetData();
        return (String) psHash.get("id");
      }

    return "";
  }
%>

<%!
  //Returns BusinessObjectList of all events connected to a Role User of a Project
  static public BusinessObjectList getAllRoleUserEvents(matrix.db.Context context, HttpSession session, String sProjectId) throws MatrixException  {
    Hashtable eventHash = getAllPersonEvents(context,session);
    BusinessObjectList projectEventList = new BusinessObjectList();

    String sTypePublishSubscribe  = Framework.getPropertyValue(session, "type_PublishSubscribe");
    String typeProjectVault       = Framework.getPropertyValue( session, "type_ProjectVault");
    String typeDocument           = Framework.getPropertyValue( session, "type_Document");
    String typeMessage            = Framework.getPropertyValue( session, "type_Message");
    String typeThread             = Framework.getPropertyValue( session, "type_Thread");
    String strProjectType         = Framework.getPropertyValue( session, "type_Project");
    String sAttrEventType         = Framework.getPropertyValue(session, "attribute_EventType");
    String sRelSubscribePerson    = Framework.getPropertyValue(session, "relationship_SubscribedPerson");
    String sRelPublishSubscribe   = Framework.getPropertyValue(session, "relationship_PublishSubscribe");
    String sRelPublish            = Framework.getPropertyValue(session, "relationship_Publish");
    String relProjectVaultsStr     = Framework.getPropertyValue( session, "relationship_ProjectVaults");
    String relSubVaultsStr         = Framework.getPropertyValue( session, "relationship_SubVaults");
    String relVaultedDocumentsStr  = Framework.getPropertyValue( session, "relationship_VaultedDocuments");
    String relMessageStr           = Framework.getPropertyValue( session, "relationship_Message");
    String relThreadStr            = Framework.getPropertyValue( session, "relationship_Thread");
    String strVaultedDocumentsRel   = Framework.getPropertyValue(session, "relationship_VaultedDocuments");
    String sTypeEvent            = Framework.getPropertyValue(session, "type_Event");

    RelationshipWithSelectItr relItr = null;
    ExpansionWithSelect boGeneric = null;


    BusinessObject boProject = new BusinessObject(sProjectId);
    boProject.open(context);

    Pattern typePattern   = new Pattern(typeProjectVault);
    typePattern.addPattern(typeDocument);
    typePattern.addPattern(typeThread);
    typePattern.addPattern(typeMessage);
    typePattern.addPattern(sTypePublishSubscribe);
    typePattern.addPattern(sTypeEvent);

    Pattern  relPattern  = new Pattern(relProjectVaultsStr);
    relPattern.addPattern(relSubVaultsStr);
    relPattern.addPattern(sRelPublishSubscribe);
    relPattern.addPattern(sRelPublish);
    relPattern.addPattern(relThreadStr);
    relPattern.addPattern(relMessageStr);
    relPattern.addPattern(strVaultedDocumentsRel);

    //Build selectlist  params
    SelectList typeSelectList   = new SelectList();
    typeSelectList.addName();
    typeSelectList.addId();
    typeSelectList.addAttribute(sAttrEventType);

    boGeneric = boProject.expandSelect( context,
                                           relPattern.getPattern(),
                                           typePattern.getPattern(),
                                           typeSelectList,
                                           new SelectList(),
                                           true,
                                           true,
                                           (short)0);
    boProject.close(context);
    relItr = new RelationshipWithSelectItr( boGeneric.getRelationships());
    while (relItr.next()) {
      if(relItr.obj().getTypeName().equals(sRelPublish)) {
        BusinessObject  obj = relItr.obj().getTo();
        obj.open(context);
        String objId = obj.getObjectId();
        if(eventHash.contains(objId)) {
            projectEventList.add(obj);
        }
        obj.close(context);
      }
    }
    return projectEventList;

  }
%>

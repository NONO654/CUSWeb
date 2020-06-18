<%--  emxTeamSubscribeWorkspaceOptions.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSubscribeWorkspaceOptions.jsp.rca 1.23 Wed Oct 22 16:06:16 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@ include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "emxTeamEventsFrmwrk.inc"%>
<%@ include file = "emxTeamProfileUtil.inc" %>
<%@ include file = "emxTeamUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%!

  static public String getThreadId(matrix.db.Context context, HttpSession session, String MsgId) throws MatrixException {
        String strReplyRel    = Framework.getPropertyValue( session, "relationship_Reply" );
        String strMsgType     = Framework.getPropertyValue( session, "type_Message");
        String strMsgRel      = Framework.getPropertyValue( session, "relationship_Message");
        String strThreadType  = Framework.getPropertyValue( session, "type_Thread" );

        String sThreadId = null;
        BusinessObject boGeneric  = new BusinessObject(MsgId);
        BusinessObject ThreadObj = null;

        boGeneric.open(context);

        Pattern relPattern  = new Pattern(strMsgRel);
        relPattern.addPattern(strReplyRel);
        Pattern typePattern = new Pattern(strMsgType);
        typePattern.addPattern(strThreadType);
        SelectList selectStmts = new SelectList();
        selectStmts.addName();
        selectStmts.addDescription();

        SelectList selectRelStmts = new SelectList();

        ExpansionWithSelect projectSelect = null;
        RelationshipWithSelectItr relItr  = null;

        projectSelect = boGeneric.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(), selectStmts, selectRelStmts,true,false,(short)0);

        relItr = new RelationshipWithSelectItr(projectSelect.getRelationships());

        // loop thru the rels and get the folder object
        while (relItr != null && relItr.next()) {

          if (relItr.obj().getTypeName().equals(strMsgRel)) {
            ThreadObj = relItr.obj().getFrom();

          }
        }
        return ThreadObj.getObjectId();
    }
%>

<%
  //Read the objectId list passed in
  String saObjectKey[]    = emxGetParameterValues(request, "chkSubscribeEvent");
  String sObjectId        = emxGetParameter(request, "objectId");
  String sUnsubEvtIds     = emxGetParameter(request, "sUnsubscribedEventIds");
  String flag             = emxGetParameter(request,"flag");
  String personIds[]      = emxGetParameterValues(request,"chkItem1");

  //Preload lookup strings
  String sTypeEvent            = Framework.getPropertyValue(session, "type_Event");
  String sTypePublishSubscribe = Framework.getPropertyValue(session, "type_PublishSubscribe");
  String strProjectType        = Framework.getPropertyValue( session, "type_Project");
  String strRouteType          = Framework.getPropertyValue( session, "type_Route");
  String strContentType        = Framework.getPropertyValue( session, "type_DOCUMENTS");
  String strPackageType        = Framework.getPropertyValue( session, "type_Package");
  String strRFQType            = Framework.getPropertyValue( session, "type_RequestToSupplier");
  String strFolderType         = Framework.getPropertyValue( session, "type_ProjectVault");
  String strMessage            = Framework.getPropertyValue( session, "type_Message");
  String strThread             = Framework.getPropertyValue( session, "type_Thread");

  String sRelPublish           = Framework.getPropertyValue(session, "relationship_Publish");
  String sRelSubscribePerson   = Framework.getPropertyValue(session, "relationship_SubscribedPerson");
  String sRelPushSubscribePerson = Framework.getPropertyValue(session, "relationship_PushedSubscription");
  String sRelSubscribeItem     = Framework.getPropertyValue(session, "relationship_SubscribedItem");
  String sRelPublishSubscribe  = Framework.getPropertyValue(session, "relationship_PublishSubscribe");
  String strRouteRel           = Framework.getPropertyValue( session, "relationship_ObjectRoute" );
  String strDocumentRel        = Framework.getPropertyValue( session, "relationship_VaultedDocuments" );
  String strProjectFolderRel   = Framework.getPropertyValue( session, "relationship_ProjectFolders");
  String strProjectVault       = Framework.getPropertyValue( session, "relationship_ProjectVaults" );
  String strRouteScope         = Framework.getPropertyValue( session, "relationship_RouteScope");
  String relRouteScope         = Framework.getPropertyValue(session,"relationship_RouteScope");
  String relThread             = Framework.getPropertyValue(session,"relationship_Thread");
  String relMessage            = Framework.getPropertyValue(session,"relationship_Message");
  String sAttrEventType        = Framework.getPropertyValue(session, "attribute_EventType");
  String strProjectVaultType   = Framework.getPropertyValue(session, "type_ProjectVault");
  String strVaultedDocumentsRel= Framework.getPropertyValue(session, "relationship_VaultedDocuments");

  DomainObject domainObject=DomainObject.newInstance(context);
  Workspace workspace = (Workspace)DomainObject.newInstance(context, DomainConstants.TYPE_WORKSPACE, DomainConstants.TEAM);
;
 

  ExpansionWithSelect projectSelect = null;
  RelationshipWithSelectItr relItr  = null;

  SelectList selectStmts     = new SelectList();
  SelectList selectRelStmts  = new SelectList();
  selectStmts.addName();
  selectStmts.addId();

  Pattern relPattern  = null;
  Pattern typePattern = null;

  BusinessObject boEvent      = null;
  BusinessObject ProjectObj   = null;
  BusinessObject ConnectedObj = null;
  String sProjectId             = null;
  String threadId                   ="";

  //Open the  object and get object type
  BusinessObject boAny    = new BusinessObject(sObjectId);
  boAny.open(context);
  String sObjectTypeStr   = boAny.getTypeName();
 Vault vault = new Vault(JSPUtil.getVault(context,session));
  String BaseType= FrameworkUtil.getBaseType(context,sObjectTypeStr,vault);
  if(sObjectTypeStr.equals(strMessage)){

            threadId        = getThreadId(context,session,sObjectId);
            BusinessObject threadObj = new BusinessObject(threadId);
            threadObj.open(context);
            relPattern  = new Pattern(relThread);
            typePattern = new Pattern(strProjectType);
			if(strRFQType != null && !strRFQType.equals(null) && !strRFQType.equals("null") && !strRFQType.equals(""))
			{	
              typePattern.addPattern(strRFQType);
			}
            ConnectedObj = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,threadObj,relPattern.getPattern(),typePattern.getPattern(),true,false);
            // If project Id is not null then the page is from workspace
            if ( ConnectedObj != null ) {
                sProjectId  = ConnectedObj.getObjectId();
            }
             
            // folder type
            typePattern = new Pattern(strFolderType);
            relPattern  = new Pattern(strVaultedDocumentsRel);

            ConnectedObj = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,threadObj,relPattern.getPattern(),typePattern.getPattern(),true,false);
            // If folder Id is not null then the page is from folder
            if ( ConnectedObj != null ) {
                String FolderId = ConnectedObj.getObjectId();
                sProjectId = UserTask.getProjectId(context,FolderId);

            }

            // Content type
            typePattern = new Pattern(strContentType);
            ConnectedObj = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,threadObj,relPattern.getPattern(),typePattern.getPattern(),true,false);

            // If content Id is not null then the page is from content
            if ( ConnectedObj != null ) {
                    String contentId = ConnectedObj.getObjectId();

                    Pattern RelPattern       = new Pattern(strVaultedDocumentsRel);
                    Pattern TypePattern      = new Pattern(strProjectVaultType);
                    BusinessObject boContent = new BusinessObject(contentId);
                    BusinessObject boGeneric = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boContent,RelPattern.getPattern(),TypePattern.getPattern(),true,false);
                    sProjectId   = UserTask.getProjectId(context, boGeneric.getObjectId());
            }
            //bomsg.close(context);
            threadObj.close(context);

  }

  if (sObjectTypeStr.equals(strRouteType)) {
            BusinessObject boRoute = new BusinessObject(sObjectId);
            boRoute.open(context);

            // to get the folder Id from route Id
            relPattern  = new Pattern(strRouteScope);
            typePattern = new Pattern(strProjectType);

            ProjectObj = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boRoute,relPattern.getPattern(),typePattern.getPattern(),true,false);

            // If project Id is not null then the page is from workspace
            if ( ProjectObj != null ) {

                sProjectId = ProjectObj.getObjectId();
            }

            // If the projectId is null then get the project Id from Workspace Vault.
            if ( ProjectObj == null ) {
                relPattern   = new Pattern(relRouteScope);
                typePattern  = new Pattern(strFolderType);
                ProjectObj   = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boRoute,relPattern.getPattern(),typePattern.getPattern(),true,false);
                sProjectId   = UserTask.getProjectId(context,ProjectObj.getObjectId());
            }
            boRoute.close(context);

  } else if (sObjectTypeStr.equals(strProjectType)) {
        sProjectId = sObjectId;

  } else if (BaseType.equals(strContentType) || sObjectTypeStr.equals(strPackageType) || sObjectTypeStr.equals(strRFQType)) {

            BusinessObject boContent = new BusinessObject(sObjectId);
            boContent.open(context);
            BusinessObject boGeneric = null;
            // to get the project id from workspace vault.
            relPattern  = new Pattern(strDocumentRel);
            typePattern = new Pattern(strFolderType);

            boGeneric = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boContent,relPattern.getPattern(),typePattern.getPattern(),true,false);
            // If project Id is not null then the page is from workspace
            if ( boGeneric != null ) {
                sProjectId = UserTask.getProjectId(context,boGeneric.getObjectId());
            }

            if ( boGeneric == null ) {
                // to get the project id from workspace vault.
                relPattern  = new Pattern(strRouteRel);
                typePattern = new Pattern(strRouteType);

                boGeneric = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boContent,relPattern.getPattern(),typePattern.getPattern(),true,false);

                // to get the project id from workspace vault.
                relPattern  = new Pattern(strRouteRel);
                typePattern = new Pattern(strProjectType);

                boGeneric  = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boContent,relPattern.getPattern(),typePattern.getPattern(),true,false);
                sProjectId = boGeneric.getObjectId();
            }
            boContent.close(context);

  } else if (sObjectTypeStr.equals(strFolderType)) {

    // to get the project id from workspace folder.
    //This takes care of workspace sub folders to n level.

    try {
          sProjectId = UserTask.getProjectId(context,sObjectId);
    } catch (MatrixException ex) {
    }

  }


  int i, j;
  String sProjectVault = null;

  //To get the Vault
  if(sProjectId != null)
  {
    BusinessObject busProject = new BusinessObject(sProjectId);
    busProject.open(context);
    sProjectVault = busProject.getVault();
    busProject.close(context);

    if (sUnsubEvtIds != null && !"".equals(sUnsubEvtIds)) {
    StringTokenizer st = new StringTokenizer(sUnsubEvtIds, ";");

    while (st.hasMoreTokens()) {
      //Process unsubscribed events and disconnect relationships
      if (!"".equals(sUnsubEvtIds)) {
        boEvent = new BusinessObject(st.nextToken());
        boEvent.open(context);

        BusinessObject boPerson = JSPUtil.getPerson(context, session);
        boPerson.open(context);
        boPerson.disconnect(context, new RelationshipType(sRelSubscribePerson), false, boEvent);
        boPerson.close(context);
        if ( sProjectId != null ) {
          // disconnect the subscribedItem rel only if both "pushed subscription" and "subscribed person" rel are absent
          domainObject.setId(boEvent.getObjectId());
          StringList subsPersonList = domainObject.getInfoList(context, "from["+sRelSubscribePerson+"].to.id");
          StringList pushedPersonList = domainObject.getInfoList(context, "from["+sRelPushSubscribePerson+"].to.id");
          boolean shouldRemove = true;
          if(subsPersonList.contains(boPerson.getObjectId()))
          {
            shouldRemove = false;
          }
          else if(pushedPersonList.contains(boPerson.getObjectId()))
          {
            shouldRemove = false;
          }
          if(shouldRemove)
          {
            BusinessObject boProjectMember = JSPUtil.getProjectMember(context, session, sProjectId, JSPUtil.getPerson(context, session));
            if(boProjectMember != null) {
                            boProjectMember.open(context);
                            boProjectMember.disconnect(context, new RelationshipType(sRelSubscribeItem), false, boEvent);
                            boProjectMember.close(context);
                        }
          }
        }
      } else {
        st.nextToken();
      }
    }
  }
 }
  //Process subscribed events, create objects and connect relationships
  try {
  if (saObjectKey != null) {
    boAny = new BusinessObject(sObjectId);
    boAny.open(context);
    sObjectTypeStr = boAny.getTypeName();
    if(sProjectVault == null){
      sProjectVault = boAny.getVault();
    }  
    for (i = 0; i < saObjectKey.length; i++) {

      relPattern = new Pattern(sRelPublishSubscribe);
      typePattern = new Pattern(sTypePublishSubscribe);

      ExpansionWithSelect expandWSelectAny = boAny.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                             selectStmts, selectRelStmts,true, true, (short)1);
      BusinessObject boPS = null;
      RelationshipWithSelectItr relWSelectAnyItr = new RelationshipWithSelectItr(expandWSelectAny.getRelationships());

      Hashtable anyHash = new Hashtable();
      Hashtable psHash  = new Hashtable();
      String sPSId = null;
      boolean bFlag = false;

      //Check if the PS object exist get data & open object
      if (relWSelectAnyItr  != null && relWSelectAnyItr.next()) {
        anyHash = relWSelectAnyItr.obj().getTargetData();
        sPSId   = (String) anyHash.get("id");
        boPS    = new BusinessObject(sPSId);
        boPS.open(context);

        //If the PS object does not exist create it
      } else {
        sPSId = FrameworkUtil.autoName(context, "type_PublishSubscribe", "", "policy_PublishSubscribe", sProjectVault);
        boPS  = new BusinessObject(sPSId);
        boPS.open(context);
        //Use SubscriptionManager.initiate() method to connect Publish Subscribe Object thru Super user

        workspace.setId(sProjectId);
        workspace.getSubscriptionManager().initiate(context, sObjectId, sPSId);
      }

      Pattern relPSPattern    = new Pattern(sRelPublish);
      Pattern typePSPattern   = new Pattern(sTypeEvent);

      ExpansionWithSelect expandWSelectPS = boPS.expandSelect(context,relPSPattern.getPattern(),typePSPattern.getPattern(),
                                                       selectStmts,selectRelStmts,true, true, (short)1);
      RelationshipWithSelectItr relWSelectPSItr = new RelationshipWithSelectItr(expandWSelectPS.getRelationships());

      boolean bEventFound   = false;

      //Check if the Event object exist get data & open object
      while (!bEventFound && relWSelectPSItr.next()) {
        psHash = relWSelectPSItr.obj().getTargetData();
        String sEventId = (String) psHash.get("id");
        boEvent = new BusinessObject(sEventId);
        boEvent.open(context);

        String sEventTypeStr   = "";
        AttributeItr  attrItr  = new AttributeItr(boEvent.getAttributes(context).getAttributes());
        AttributeList attrList = new AttributeList();

        while (attrItr.next()){
          Attribute attr = attrItr.obj();

          if (attr.getName().equals(sAttrEventType)) {
            sEventTypeStr = attr.getValue();

            if (sEventTypeStr.equals(saObjectKey[i])) {
              bEventFound = true;
            }
          }
        }
      }
      //If the event object does not exist create it
      if (!bEventFound) {
        String sEventId = FrameworkUtil.autoName(context, "type_Event", "", "policy_Event", sProjectVault);
        boEvent = new BusinessObject(sEventId);
        boPS.connect(context, new RelationshipType(sRelPublish), true, boEvent);
        boEvent.open(context);

        //Set EventType Attribute
        AttributeItr  attrItr  = new AttributeItr(boEvent.getAttributes(context).getAttributes());
        AttributeList attrList = new AttributeList();

        while (attrItr.next()) {
          Attribute attr  = attrItr.obj();
          if (attr.getName().equals(sAttrEventType)) {
            attr.setValue(saObjectKey[i]);
            attrList.addElement(attr);
          }
        }
        boEvent.setAttributes(context, attrList);
      }

      if(flag == null || !flag.equals("pushSubscription"))
      {
        //After getting Person connectEvent with Person
        BusinessObject boPerson = JSPUtil.getPerson(context, session);
        boPerson.open(context);
        boEvent.connect(context, new RelationshipType(sRelSubscribePerson), true, boPerson);
        boPerson.close(context);

        //After getting Project Member connect Event with Project Member
        if (sProjectId != null ) {
            BusinessObject boProjectMember = JSPUtil.getProjectMember(context, session, sProjectId, JSPUtil.getPerson(context, session));
            if(boProjectMember != null) {
                        boProjectMember.open(context);
                        domainObject.setId(boEvent.getObjectId());
                        StringList subscribeItemList = domainObject.getInfoList(context, "from["+sRelSubscribeItem+"].to.id");

                        // connect using the rel only if it does not already exist to the same person
                        if(!subscribeItemList.contains(boProjectMember.getObjectId()))
                        {
                    boEvent.connect(context, new RelationshipType(sRelSubscribeItem), true, boProjectMember);
                        }
                        boProjectMember.close(context);
                    }
        }
      }else{
        for(int count=0;count<personIds.length;count++)
        {
          BusinessObject boPerson = null;
          StringTokenizer tokenizer = new StringTokenizer(personIds[count],"~");
          String typeVar = tokenizer.nextToken();
          if(typeVar!=null && typeVar.equals("Person")){
            //After getting Person connectEvent with Person
            boPerson = new BusinessObject(tokenizer.nextToken());
          }
          boPerson.open(context);
          try {
            boEvent.connect(context, new RelationshipType(sRelPushSubscribePerson), true, boPerson);
          }catch (Exception e){
             bFlag = true;
          }

      if (sProjectId != null && !bFlag ) {
        BusinessObject boProjectMember = JSPUtil.getProjectMember(context, session, sProjectId, boPerson);
                    if(boProjectMember != null) {
                    boProjectMember.open(context);
                    domainObject.setId(boEvent.getObjectId());
                    StringList subscribeItemList = domainObject.getInfoList(context, "from["+sRelSubscribeItem+"].to.id");
                    // connect using the rel only if it does not already exist to the same person
                    if(!subscribeItemList.contains(boProjectMember.getObjectId()))
                    {
                        boEvent.connect(context, new RelationshipType(sRelSubscribeItem), true, boProjectMember);
                    }
                    boProjectMember.close(context);
                    }
                    boPerson.close(context);
                }
      }
    }
    boEvent.close(context);
   }
  }
 }catch(Exception e)
 {
   session.putValue("error.message", e.getMessage());
 }
%>

<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
  
  //parent.window.getWindowOpener().parent.location.reload();
  //commented above line and added below line as its giving error 284582
  parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
  parent.window.closeWindow();
</script>
</body>
</html>

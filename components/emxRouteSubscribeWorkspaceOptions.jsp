<%--  emxRouteSubscribeWorkspaceOptions.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteSubscribeWorkspaceOptions.jsp.rca 1.8 Wed Oct 22 16:18:25 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>

<%
  //Read the objectId list passed in
  String saObjectKey[]    = emxGetParameterValues(request, "chkSubscribeEvent");
  String sObjectId        = emxGetParameter(request, "objectId");
  String sUnsubEvtIds     = emxGetParameter(request, "sUnsubscribedEventIds");
  String flag             = emxGetParameter(request,"flag");
  String personIds[]      = emxGetParameterValues(request,"selectedPerson");


  //Preload lookup strings
  String sTypeEvent            = PropertyUtil.getSchemaProperty(context, "type_Event");
  String sTypePublishSubscribe = PropertyUtil.getSchemaProperty(context, "type_PublishSubscribe");
  String strProjectType        = PropertyUtil.getSchemaProperty(context, "type_Project");
  String strRouteType          = PropertyUtil.getSchemaProperty(context, "type_Route");


  String sRelPublish           = PropertyUtil.getSchemaProperty(context, "relationship_Publish");
  String sRelSubscribePerson   = PropertyUtil.getSchemaProperty(context, "relationship_SubscribedPerson");
  String sRelPushSubscribePerson = PropertyUtil.getSchemaProperty(context, "relationship_PushedSubscription");
  String sRelSubscribeItem     = PropertyUtil.getSchemaProperty(context, "relationship_SubscribedItem");
  String sRelPublishSubscribe  = PropertyUtil.getSchemaProperty(context, "relationship_PublishSubscribe");
  String strRouteScope         = PropertyUtil.getSchemaProperty(context, "relationship_RouteScope");
  String sAttrEventType        = PropertyUtil.getSchemaProperty(context, "attribute_EventType");
  
  DomainObject domainObject=DomainObject.newInstance(context);
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

  if (sObjectTypeStr.equals(strRouteType)) {  
            BusinessObject boRoute = new BusinessObject(sObjectId);
            boRoute.open(context);

            // to get the folder Id from route Id
            relPattern  = new Pattern(strRouteScope);
            typePattern = new Pattern(strProjectType);
            ProjectObj = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boRoute,relPattern.getPattern(),typePattern.getPattern(),true,false);
            boRoute.close(context);

  }
  int i, j;
  String sProjectVault = null;
 
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

        //Use SubscriptionManager method to connect Publish Subscribe Object
        Route route = (Route)DomainObject.newInstance(context ,sObjectId);
        route.getSubscriptionManager().initiate(context, sObjectId, sPSId);
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

        domainObject.setId(boEvent.getObjectId());
        StringList subscribeItemList1 = domainObject.getInfoList(context, "from["+sRelSubscribeItem+"].to.id");

        // connect using the rel only if it does not already exist to the same person
        if(!subscribeItemList1.contains(boPerson.getObjectId()))
          {
            boEvent.connect(context, new RelationshipType(sRelSubscribeItem), true, boPerson);
           }
      }else{
        for(int count=0;count<personIds.length;count++)
        {
          BusinessObject boPerson = null;
          boPerson = new BusinessObject(personIds[count]);
          boPerson.open(context);
          try {
            boEvent.connect(context, new RelationshipType(sRelPushSubscribePerson), true, boPerson);
            
          }catch (Exception e){
             bFlag = true;
          }


      if (!bFlag ) {
                    domainObject.setId(boEvent.getObjectId());
                    StringList subscribeItemList = domainObject.getInfoList(context, "from["+sRelSubscribeItem+"].to.id");
                    // connect using the rel only if it does not already exist to the same person
                    if(!subscribeItemList.contains(boPerson.getObjectId()))
                    { 
                        boEvent.connect(context, new RelationshipType(sRelSubscribeItem), true, boPerson);                        
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
<script language="javascript">
  parent.window.getWindowOpener().parent.location.reload();
  window.closeWindow();
</script>
</body>
</html>

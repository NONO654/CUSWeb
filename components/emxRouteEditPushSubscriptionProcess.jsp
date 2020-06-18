<%--  emxRouteEditPushSubscriptionProcess.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $ Exp $
--%>
<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%
  //Read the objectId list passed in
  String personIds[]  = emxGetParameterValues(request,"personIds");
  String projectId    = emxGetParameter(request,"projectId");

  //Preload lookup strings
  String sRelPushSubscribePerson = PropertyUtil.getSchemaProperty(context, "relationship_PushedSubscription");
  String sRelSubscribeItem       = PropertyUtil.getSchemaProperty(context, "relationship_SubscribedItem");
  String sRelSubscribePerson     = PropertyUtil.getSchemaProperty(context, "relationship_SubscribedPerson");

  BusinessObject boEvent          = null;
  BusinessObject boProjectMember  = null;
  BusinessObject boPerson         = null;
  String eventId                  = "";

  try
  {
    for(int count=0;count<personIds.length;count++)
    {
      eventId = emxGetParameter(request,personIds[count]);
      boEvent = new BusinessObject(eventId);
      boEvent.open(context);
      boPerson = new BusinessObject(personIds[count]);
                
      boPerson.disconnect(context, new RelationshipType(sRelPushSubscribePerson), false, boEvent);
      if ( projectId != null ) {
        // disconnect the subscribedItem rel only if both "pushed subscription" and "subscribed person" rel are absent
        DomainObject domainObject = DomainObject.newInstance(context, boEvent.getObjectId());
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
          boPerson.disconnect(context, new RelationshipType(sRelSubscribeItem), false, boEvent);
        }
      }
      boEvent.close(context);
    }
  }
  catch(Exception e)
  {
   session.putValue("error.message",e.getMessage());
  }
%>

<html>
<body>
<script language="javascript">
  parent.window.location.reload();
</script>
</body>
</html>


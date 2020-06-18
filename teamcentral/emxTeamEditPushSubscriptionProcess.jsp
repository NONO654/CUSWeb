<%--  emxTeamEditPushSubscriptionProcess.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamEditPushSubscriptionProcess.jsp.rca 1.9 Wed Oct 22 16:06:06 2008 przemek Experimental przemek $
--%>
<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@ include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "emxTeamEventsFrmwrk.inc"%>
<%@ include file = "emxTeamProfileUtil.inc" %>
<%@ include file = "emxTeamUtil.inc"%>

<%
  //Read the objectId list passed in
  String personIds[]  = emxGetParameterValues(request,"personIds");
  String projectId    = emxGetParameter(request,"projectId");

  //Preload lookup strings
  String sRelPushSubscribePerson = Framework.getPropertyValue(session, "relationship_PushedSubscription");
  String sRelSubscribeItem       = Framework.getPropertyValue(session, "relationship_SubscribedItem");
  String sRelSubscribePerson     = Framework.getPropertyValue(session, "relationship_SubscribedPerson");

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
          boProjectMember = JSPUtil.getProjectMember(context, session, projectId, boPerson);
          if(boProjectMember != null){
        	  boProjectMember.disconnect(context, new RelationshipType(sRelSubscribeItem), false, boEvent);
          }
          
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
  parent.window.location.href = parent.window.location.href;
</script>
</body>
</html>


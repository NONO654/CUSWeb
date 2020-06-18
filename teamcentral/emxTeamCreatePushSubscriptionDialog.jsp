<%--  emxTeamCreatePushSubscriptionDialog.jsp - Dialog page for creating push subscription.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreatePushSubscriptionDialog.jsp.rca 1.23 Wed Oct 22 16:06:04 2008 przemek Experimental przemek $
--%>

<%@ include file= "../emxUICommonAppInclude.inc" %>
<%@ include file="emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "emxTeamEventsFrmwrk.inc"%>
<%@ include file = "emxTeamUtil.inc" %>
<%@ include file = "eServiceUtil.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">
  function submitForm(){
    var sAllIds = "";

    for( var i = 0; i < document.formEvents.elements.length; i++ ){
      if (   (document.formEvents.elements[i].type == "checkbox")
          && (!document.formEvents.elements[i].checked)
          && (document.formEvents.elements[i].name == "chkUnSubscribeEvent") ){
            sAllIds += document.formEvents.elements[i].value + ";";
      }
    }
    document.formEvents.sUnsubscribedEventIds.value = sAllIds;
    document.formEvents.submit();
    return;
  }
  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
  

  //Get ObjectID passed in
  String sObjId       = emxGetParameter(request, "objectId");
  String strDiscussion = emxGetParameter(request, "discussion");
  if (sObjId != null){
    sObjId = sObjId.trim();
  }
  /*10-7-0-0 Conversion Start*/
  if(strDiscussion==null)
  {
    strDiscussion="Discussion";
  }
  /*10-7-0-0 Conversion End*/
  person.setToContext(context);
  String objectFlag = emxGetParameter(request,"objectFlag");

  //Get ProjectID
  String sProjectId = "";

  //preload strings
  String sTypeDocument          = Framework.getPropertyValue(session, "type_Document");
  String sTypeEvent             = Framework.getPropertyValue(session, "type_Event");
  String sTypePerson            = Framework.getPropertyValue(session, "type_Person");
  String sTypeWorkspaceVault    = Framework.getPropertyValue(session, "type_ProjectVault");
  String sTypeProject           = Framework.getPropertyValue(session, "type_Project");
  String sTypeRoute             = Framework.getPropertyValue(session, "type_Route");
  String sTypeMessage           = Framework.getPropertyValue(session, "type_Message");

  String sRelPushedSubscription = Framework.getPropertyValue(session, "relationship_PushedSubscription");
  String sRelPublish            = Framework.getPropertyValue(session, "relationship_Publish");
  String sRelPublishSubscribe   = Framework.getPropertyValue(session, "relationship_PublishSubscribe");
  String sRelRouteScope         = Framework.getPropertyValue(session, "relationship_RouteScope");
  String sRelWorkspaceVaults    = Framework.getPropertyValue(session, "relationship_ProjectVaults");
  String sRelVaultedObjects     = Framework.getPropertyValue(session, "relationship_VaultedDocuments");
  String sAttrEventType         = Framework.getPropertyValue(session, "attribute_EventType");

  //get object type name
  DomainObject domainObject   = DomainObject.newInstance(context,sObjId);


  String sObjectTypeStr   = domainObject.getType(context);
  String SELECT_ROUTE_SCOPE_ID = "to[" + sRelRouteScope + "].from.id";
  String SELECT_ROUTE_SCOPE_TYPE = "to[" + sRelRouteScope + "].from.type";

  String SELECT_FOLDER_PROJECT_ID = "to[" + sRelWorkspaceVaults + "].from.id";

  if(sObjectTypeStr.equals(sTypeProject) || sObjectTypeStr.equals(sTypeMessage) ) {

    sProjectId = sObjId;

  } else if(sObjectTypeStr.equals(sTypeRoute)) {

    if((domainObject.getInfo(context,SELECT_ROUTE_SCOPE_TYPE)).equals(sTypeWorkspaceVault)){
      sProjectId = UserTask.getProjectId(context, domainObject.getInfo(context,SELECT_ROUTE_SCOPE_ID));
    }
    else {
      sProjectId = domainObject.getInfo(context,SELECT_ROUTE_SCOPE_ID);
    }

  } else if(sObjectTypeStr.equals(sTypeDocument)||(sObjectTypeStr.equals(domainObject.TYPE_PACKAGE)) || (sObjectTypeStr.equals(domainObject.TYPE_RTS_QUOTATION)) || (sObjectTypeStr.equals(domainObject.TYPE_REQUEST_TO_SUPPLIER))) {

    sProjectId = UserTask.getProjectId(context,domainObject.getInfo(context,"to[" + sRelVaultedObjects + "].from.id"));

  } else if(sObjectTypeStr.equals(sTypeWorkspaceVault)) {

    sProjectId = UserTask.getProjectId(context,sObjId);

  }
///Commented for IR-011752V6R2011
 /* if ("Discussion".equals(strDiscussion)) {
       sObjectTypeStr = "Discussion";
  }*/

  //Create a TreeMap & populate the map with the appropriate type of events
  TreeMap projectMap    = new TreeMap();
  if(sObjectTypeStr.equals("Discussion")) {

    projectMap = AddDiscussionEvents(request);

  } else if (sTypeProject.equals(sObjectTypeStr)) {

    projectMap = AddProjectEvents(request);

  } else if (sTypeRoute.equals(sObjectTypeStr)) {

    projectMap = AddRouteEvents(request);

  } else if (sTypeWorkspaceVault.equals(sObjectTypeStr)) {

    projectMap = AddTopicsEvents(request);

  } else if (sTypeDocument.equals(sObjectTypeStr)) {

    projectMap = AddDocumentEvents(request);

  } else if (sTypeMessage.equals(sObjectTypeStr)) {

    projectMap = AddMessageEvents(request);

  }

  if(objectFlag != null && objectFlag.equals("discussion")) {
    projectMap = AddDiscussionEvents(request);
  }
%>
<form name="formEvents" method="post" action="emxTeamSubscribeWorkspaceOptions.jsp">
<input type="hidden" name="removeAll" value="yes" />
 <img src="images/utilSpace.gif" width="1" height="8" />
 <table class = "list" id="searchResultList" border="0" cellpadding="5" cellspacing="2" width="100%">
   <tr>
     <th  class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.PublishSubscribeSummary.AlertEvents</emxUtil:i18n></th>
     <th  class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.DiscussionSummary.Recipients</emxUtil:i18n></th>
   </tr>
<%
  java.util.Set projectKeys   = projectMap.keySet();
  Iterator it = projectKeys.iterator();
  String sKeyStr = "";
  while (it.hasNext()) {
    sKeyStr = (String) it.next();
%>
   <tr><!-- XSSOK -->
       <td class="inputField"><xss:encodeForHTML><%=projectMap.get(sKeyStr)%></xss:encodeForHTML><br/></td>
       <td class="inputField">

<%
  String whereExpression = "(attribute[" + sAttrEventType + "] == \"" + sKeyStr + "\") && (to[" + sRelPublish + "].from.to[" + sRelPublishSubscribe + "].from.id == \"" + sObjId + "\")";
  MapList subscribedPersons = new MapList();
  StringList objectSelects = new StringList(1);
  objectSelects.add(domainObject.SELECT_ID);

  com.matrixone.apps.common.Person person1 = com.matrixone.apps.common.Person.getPerson(context);
  Company company = person1.getCompany(context);

  MapList subscribedEvent =  domainObject.querySelect(context,
                                                        sTypeEvent, // type pattern
                                                        domainObject.QUERY_WILDCARD, // namePattern
                                                        domainObject.QUERY_WILDCARD,  // revPattern
                                                        domainObject.QUERY_WILDCARD, // ownerPattern
                                                        company.getAllVaults(context,true), // vault pattern
                                                        whereExpression, // where expression
                                                        true,            // expandType
                                                        objectSelects,   // object selects
                                                        null,            // cached list
                                                        false);          // use cache


  if (subscribedEvent.size() != 0) {

    Iterator i =  subscribedEvent.iterator();
    String eventId = "";

    while( i.hasNext()){
      Map map = (Map)i.next();
      eventId = (String)map.get(domainObject.SELECT_ID);
      domainObject.setId( eventId );
      objectSelects = new StringList();
      subscribedPersons =  domainObject.expandSelect(context,
                                                            sRelPushedSubscription,
                                                            sTypePerson,
                                                            objectSelects,
                                                            null,
                                                            true,
                                                            true,
                                                            (short)1,
                                                            null,
                                                            null,
                                                            null,
                                                            false);


      }
  }

%>
   <!-- //XSSOK -->
       <a href="javascript:emxShowModalDialog('emxTeamEditPushSubscriptionDialogFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, sProjectId)%>&flag=pushSubscription&chkSubscribeEvent=<%=Framework.encodeURL(response,sKeyStr)%>&objectId=<%=XSSUtil.encodeForURL(context, sObjId)%>',550, 500);" ><%=subscribedPersons.size()%></a>
       </td>
     </tr>
<%
  }
%>
  </table>
  <input type=hidden name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="sUnsubscribedEventIds" value="" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

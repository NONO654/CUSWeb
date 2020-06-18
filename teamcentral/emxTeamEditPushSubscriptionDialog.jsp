<%--  emxTeamEditPushSubscriptionDialog.jsp - Dialog page for creating push subscription.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamEditPushSubscriptionDialog.jsp.rca 1.23 Wed Oct 22 16:06:20 2008 przemek Experimental przemek $
--%>


<%@ include file= "../emxUICommonAppInclude.inc" %>
<%@ include file="emxTeamCommonUtilAppInclude.inc" %>
<%@ include file = "../emxPaginationInclude.inc" %>
<%@ include file= "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String chkSubscribeEvent  = emxGetParameter(request,"chkSubscribeEvent");
  String projectId          = emxGetParameter(request,"projectId");
  String objectId           = emxGetParameter(request,"objectId");
  String sParams            = "chkSubscribeEvent="+XSSUtil.encodeForURL(context, chkSubscribeEvent)+"&projectId="+XSSUtil.encodeForURL(context, projectId)+"&objectId="+XSSUtil.encodeForURL(context, objectId);
  if (objectId != null){
    objectId = objectId.trim();
  }  
  DomainObject domainObject = DomainObject.newInstance(context);
%>

<script language="javascript">

  function removeSelected() {
    var varChecked = "false";
    var objForm = document.formEvents;

    for (var i=0; i < objForm.elements.length; i++) {
      if (objForm.elements[i].type == "checkbox") {
        if ((objForm.elements[i].name.indexOf('personIds') > -1) && (objForm.elements[i].checked == true)) {
              varChecked = "true";
         }
      }
    }

    if (varChecked == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Access.AlertMessage</emxUtil:i18nScript>");
      return;
    } else {
    document.formEvents.submit();
    return;
   }
  }

  function closeWindow() {
    parent.window.closeWindow();
    parent.window.getWindowOpener().document.location.reload();
    return;
  }
  function addSelected()
  {
  emxShowModalDialog('emxTeamSearchWorkspaceMembersDialogFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, projectId)%>&flag=pushSubscription&chkSubscribeEvent=<%=XSSUtil.encodeForURL(context, chkSubscribeEvent)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>',775, 500);
  }

  function doCheckCheckBox() {
    var objForm = document.forms[0];
    var chkList = objForm.checkAll;
    var reChkName = /personIds/gi;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('personIds') > -1){
    objForm.elements[i].checked = chkList.checked;
    }
  }

  function updateCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.checkAll;
    chkList.checked = false;
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  //preload strings
  MapList subscribedPersons = new MapList();

  String sTypeEvent             = Framework.getPropertyValue(session, "type_Event");
  String sTypePerson            = Framework.getPropertyValue(session, "type_Person");
  String sRelPushedSubscription = Framework.getPropertyValue(session, "relationship_PushedSubscription");
  String sAttrEventType         = Framework.getPropertyValue(session,"attribute_EventType");
  String eventId                = null;
  String whereExpression        = "(attribute[" + sAttrEventType + "] == \"" + chkSubscribeEvent + "\") && (to[" + Framework.getPropertyValue(session, "relationship_Publish") + "].from.to["
                                  + Framework.getPropertyValue(session, "relationship_PublishSubscribe")
                                  + "].from.id == \"" + objectId + "\")";

  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  Company company = person.getCompany(context);

  StringList objectSelects      = new StringList(1);
  objectSelects.add(domainObject.SELECT_ID);
  try {
  MapList subscribedEvent       =  domainObject.findObjects(context,
                                                        sTypeEvent, // type pattern
                                                        domainObject.QUERY_WILDCARD, // namePattern
                                                        domainObject.QUERY_WILDCARD,  // revPattern
                                                        domainObject.QUERY_WILDCARD, // ownerPattern
                                                        company.getAllVaults(context,true), // vault pattern
                                                        whereExpression, // where expression
                                                        true,            // expandType
                                                        objectSelects);   // object selects
  Iterator i =  subscribedEvent.iterator();

  while( i.hasNext()){
    Map map = (Map)i.next();
    eventId = (String)map.get(domainObject.SELECT_ID);
    break;
  }

  if( eventId != null){
   domainObject.setId( eventId );

  if (emxPage.isNewQuery()) {

   objectSelects = new StringList();
   objectSelects.add(domainObject.SELECT_ID);
   objectSelects.add(domainObject.SELECT_NAME);

   subscribedPersons =  domainObject.getRelatedObjects(context,
                                                        sRelPushedSubscription,
                                                        sTypePerson,
                                                        objectSelects,
                                                        null,
                                                        true,
                                                        true,
                                                        (short)1,
                                                        null,
                                                        null);

     // pass the resultList to the following method
        emxPage.getTable().setObjects(subscribedPersons);
        // pass in the selectables to the following method
        emxPage.getTable().setSelects(objectSelects);
     }

      // this Maplist is the one which is used to make the table.
      subscribedPersons = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
      subscribedPersons = com.matrixone.apps.common.Person.replaceNameInMapList(context, subscribedPersons,domainObject.SELECT_NAME);
    }
    }catch(Exception e)
    {}
%>
<!-- //XSSOK -->
<form name="formEvents" method="post" action="emxTeamEditPushSubscriptionProcess.jsp">
<!-- //XSSOK -->
<framework:sortInit  defaultSortKey="<%=domainObject.SELECT_NAME%>"  defaultSortType="string"  mapList="<%= subscribedPersons %>"  resourceBundle="emxTeamCentralStringResource"  ascendText="emxTeamCentral.Common.SortAscending"  descendText="emxTeamCentral.Common.SortDescending"  params = "<%=sParams%>"  />

<img src="images/utilSpace.gif" width=1 height=8>
 <table class="list" id="searchResultList" border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
      <th width="5%" style="text-align:center">
        <table border="0">
          <tr>
            <td style="text-align:center">
              <input type="checkbox" name="checkAll" id="checkAll" onclick="doCheckCheckBox()" />
            </td>
          </tr>
       </table>
      </th>
      <th >
        <framework:sortColumnHeader
         title="emxTeamCentral.DiscussionSummary.Recipients"
         sortKey="<%=domainObject.SELECT_NAME%>"
         sortType="string"
         anchorClass="sortMenuItem"/>
      </th>

   </tr>
<%
  if( subscribedPersons == null || subscribedPersons.size() == 0)  {
%>
    <tr class=odd>
      <td style="text-align:center" class="noresult" colspan="3" ><emxUtil:i18n localize="i18nId"> emxTeamCentral.TeamMemberSearch.NoMembers</emxUtil:i18n></td>
    </tr>
<%
  }else{
%>
<!-- \\XSSOK -->
   <framework:mapListItr mapList="<%=subscribedPersons%>" mapName="subscribedPerson">

   <tr>
       <td class="inputField" align="center">
       <input type="checkbox"  value="<%=XSSUtil.encodeForHTMLAttribute(context,subscribedPerson.get(domainObject.SELECT_ID).toString())%>"  name="personIds" id="personIds" onclick="updateCheck()" />
       <input type="Hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context,subscribedPerson.get(domainObject.SELECT_ID).toString())%>" value="<%= XSSUtil.encodeForHTMLAttribute(context,eventId)%>" />
       </td>
       <td class="inputField">
       <%=XSSUtil.encodeForHTML(context,subscribedPerson.get(domainObject.SELECT_NAME).toString())%>
       </td>
   </tr>

   </framework:mapListItr>
<%
  }
%>
  </table>
  <input type=hidden name="projectId" value="<xss:encodeForHTMLAttribute><%= projectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="sUnsubscribedEventIds" value="" />

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

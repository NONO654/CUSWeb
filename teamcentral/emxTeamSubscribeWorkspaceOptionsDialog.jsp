<%--  emxTeamSubscribeWorkspaceOptionsDialog.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamSubscribeWorkspaceOptionsDialog.jsp.rca 1.15 Wed Oct 22 16:06:34 2008 przemek Experimental przemek $

--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@ include file = "emxTeamCommonUtilAppInclude.inc" %>
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
  //handle double-click issue
	if(jsDblClick())
	{
       document.formEvents.sUnsubscribedEventIds.value = sAllIds;
       document.formEvents.submit();
	} else {
	   alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
	}
    return;
  }
  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  //Get ObjectID passed in
  String sObjId       = emxGetParameter(request, "objectId");


  //preload strings
  String sTypeDocument        = Framework.getPropertyValue(session, "type_DOCUMENTS");// Bug No: 298129
  String sTypeDiscussion      = Framework.getPropertyValue(session, "type_Thread");
  String sTypeTopic           = Framework.getPropertyValue(session, "type_ProjectVault");
  String sTypeProject         = Framework.getPropertyValue(session, "type_Project");
  String sTypeRoute           = Framework.getPropertyValue(session, "type_Route");
  String sTypeMessage         = Framework.getPropertyValue(session, "type_Message");

  //Open the  object and get object type & name
  BusinessObject boAny    = new BusinessObject(sObjId);
  boAny.open(context);
  String sObjectTypeStr   = boAny.getTypeName();
 // Bug No : 298129 
  Vault vault = new Vault(JSPUtil.getVault(context,session));
  String BaseType= FrameworkUtil.getBaseType(context,sObjectTypeStr,vault);
 // upto here
  //Create a TreeMap & populate the map with the appropriate type of events
  TreeMap projectMap    = new TreeMap();
  if (sTypeProject.equals(sObjectTypeStr)) {
    projectMap      = AddProjectEvents(request);

  } else if (sTypeRoute.equals(sObjectTypeStr)) {
    projectMap      = AddRouteEvents(request);

  } else if (sTypeTopic.equals(sObjectTypeStr)) {
    projectMap      = AddTopicsEvents(request);

  } else if (BaseType.equals(sTypeDocument) && BaseType != null && !"".equals(BaseType)) {
    projectMap      = AddDocumentEvents(request);

  } else if (sTypeDiscussion.equals(sObjectTypeStr)) {
    projectMap      = AddDiscussionEvents(request);
  }
  else if (sTypeMessage.equals(sObjectTypeStr))
  {
    projectMap = AddMessageEvents(request);
  }

 %>
 <img src="images/utilSpace.gif" width="1" height="8" />
 <form name="formEvents" method="post" action="emxTeamSubscribeWorkspaceOptions.jsp">
 <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <tr>
     <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.PublishSubscribeSummary.AlertEvents</emxUtil:i18n></td>
     <td class="inputField">
       <table border="0">
         <tr>
           <td class="field">
<%

  //Create a TreeMap of all events, and list both events with checkboxes checked/unchecked
  TreeMap hashSubEvt    = getAllObjectEvents(context, session, sObjId);
  //Commented for IR-054716V6R2011x 
 // if(hashSubEvt.containsKey(MessageHolder.EVENT_NEW_DISCUSSION))
  //{
  //    hashSubEvt.remove(MessageHolder.EVENT_NEW_DISCUSSION);
 // }
  java.util.Set hashSubEvntKeys = hashSubEvt.keySet();

  Iterator itEvents     = hashSubEvntKeys.iterator();
  String sKeyRemoveStr    = "";

  while (itEvents.hasNext()) {
    sKeyRemoveStr     = (String) itEvents.next();

%>
                  <!-- //XSSOK -->
                  <input type="checkbox"  value="<%=hashSubEvt.get(sKeyRemoveStr)%>"  name=chkUnSubscribeEvent checked />
                  <!-- //XSSOK -->
                  <%=projectMap.get(sKeyRemoveStr)%><br/>
<%
    projectMap.remove(sKeyRemoveStr);
  }

  java.util.Set projectKeys   = projectMap.keySet();
  Iterator it       = projectKeys.iterator();
  String sKeyStr    = "";

  while (it.hasNext()) {
    sKeyStr       = (String) it.next();
%>
                    <!-- //XSSOK -->
                    <input type="checkbox"  value="<%=sKeyStr%>"  name=chkSubscribeEvent><%=projectMap.get(sKeyStr)%><br/>
<%
  }
%>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <input type=hidden name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="sUnsubscribedEventIds" value="" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

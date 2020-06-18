<%--  emxTeamDiscussionSubscribeDialog.jsp   -   Dialog page for subscribing to new discussions.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamDiscussionSubscribeDialog.jsp.rca 1.11 Wed Oct 22 16:06:18 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "emxTeamUtil.inc" %>
<%@ include file = "eServiceUtil.inc"%>
<%@ include file = "emxTeamEventsFrmwrk.inc"%>
<%@ include file = "../emxJSValidation.inc" %>
<%@ include file = "emxTeamNoCache.inc" %>
<%@include file = "emxTeamStartReadTransaction.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<script language = javascript>
  function submitForm() {
    if (!document.subscribeForm.Unsubscribe) {
      var checkedFlag = "false";
      for( var i = 0; i < document.subscribeForm.elements.length; i++ ) {
        if (document.subscribeForm.elements[i] != null) {
          if (document.subscribeForm.elements[i].type == "checkbox" && document.subscribeForm.elements[i].checked == true) {
            checkedFlag = "true";
          }
        }
      }
      if(checkedFlag == "false") {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.DiscussionSummary.EventAlert</emxUtil:i18nScript>");
        return;
      }
    } else {
      if(document.subscribeForm.chkUnSubscribeEvent.checked == false) {
        document.subscribeForm.sUnsubscribedEventIds.value = document.subscribeForm.chkUnSubscribeEvent.value;
      }
    }
    document.subscribeForm.submit();
  }
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  String jsTreeID   = emxGetParameter(request,"jsTreeID");
  String objectId   = emxGetParameter(request,"objectId");
  String suiteKey   = emxGetParameter(request,"suiteKey");
%>
<form name="subscribeForm" method="post" action="emxTeamSubscribeWorkspaceOptions.jsp">
<input type= hidden  name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
<input type= hidden  name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
<input type= hidden  name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
 <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <tr>
     <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxTeamCentral.PublishSubscribeSummary.AlertEvents</emxUtil:i18n></td>
     <td class="inputField">
       <table border="0">
         <tr>
           <td class="field">
<%

  //Create a TreeMap of all events, and list both events with checkboxes checked/unchecked
  TreeMap hashSubEvt = getAllObjectEvents(context, session, objectId);
  if(hashSubEvt.containsKey(MessageHolder.EVENT_NEW_DISCUSSION)) {
%>
            <input type="hidden" name="Unsubscribe" value="" />
            <!-- //XSSOK -->
            <input type="checkbox"  value="<%=hashSubEvt.get(MessageHolder.EVENT_NEW_DISCUSSION)%>"  name="chkUnSubscribeEvent" checked />
            <emxUtil:i18n localize="i18nId">emxTeamCentral.DiscussionSummary.NewDiscussion</emxUtil:i18n>
            <br/>
<%
  } else {
%>
            <input type="checkbox"  value="<%=MessageHolder.EVENT_NEW_DISCUSSION%>"  name="chkSubscribeEvent"><emxUtil:i18n localize="i18nId">emxTeamCentral.DiscussionSummary.NewDiscussion</emxUtil:i18n><br/>
<%
  }
%>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
  <input type="hidden" name="sUnsubscribedEventIds" value="" />
</form>
<%@ include file = "emxTeamCommitTransaction.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

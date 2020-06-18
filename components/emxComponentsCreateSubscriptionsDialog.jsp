 <%--  emxComponentsCreateSubscriptionsDialog.jsp -  Displays the screen to subscribe to new Events

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxComponentsCreateSubscriptionsDialog.jsp.rca 1.16 Wed Oct 22 16:18:45 2008 przemek Experimental przemek $"
--%>

<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="emxComponentsDiscussionEvents.inc"%>

<%@page import = "com.matrixone.apps.common.*" %>
<%@page import = "com.matrixone.apps.common.Subscribable.*" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">
   function submit()
   {
      var sAllIds = "";
      var sAllUnckdIds = "";
      for( var i = 0; i < document.formEvents.elements.length; i++ )
      {
         if ((document.formEvents.elements[i].type == "checkbox") && (document.formEvents.elements[i].checked) )
         {
            sAllIds += document.formEvents.elements[i].value + ";";
         }
         if ((document.formEvents.elements[i].type == "checkbox") && !(document.formEvents.elements[i].checked) )
         {
            sAllUnckdIds += document.formEvents.elements[i].value + ";";
         }
      }

      document.formEvents.sUnsubscribedEventIds.value = sAllIds;
      var sObjectType=document.formEvents.sObjectTypeStr.value;
      var sobjectId=document.formEvents.objectId.value;
      document.formEvents.action="emxComponentsCreateSubscriptionsUtil.jsp?selectedEvents="+sAllIds+"&UnselectedEvents="+sAllUnckdIds+"&objectId="+sobjectId+"&mode=Subscribe";
      document.formEvents.submit();
   }

   function closeWindow()
   {
      window.closeWindow();
      return;
   }
</script>
<%
   String sObjId = emxGetParameter(request, "objectId");
   String sFromPage = emxGetParameter(request, "fromPage");
   StringItr eventItr = null;
   String languageStr  = request.getHeader("Accept-Language");
   String subscriptionEventsJPO = emxGetParameter(request, "SubscriptionEventsJPO");

   DomainObject boAny= DomainObject.newInstance(context);
   boAny.setId(sObjId);
   String sObjectTypeStr   = boAny.getInfo(context,DomainConstants.SELECT_POLICY);

   String sObjectType   = boAny.getInfo(context,DomainConstants.SELECT_TYPE);
   com.matrixone.apps.common.CommonSubscriptionEvent subscribe = null;
   subscribe = new com.matrixone.apps.common.CommonSubscriptionEvent();
   //Gettting all subscribed Events
   StringList sl=subscribe.getEvents(context,sObjId);

   // populate the StringList with the appropriate type of events for the object passed in
   // if this newInstance call fails, check properties file emxCommonMappingFile to
   // make sure the type that your trying to subscribe to is in there
   StringList listEvents = new StringList();
   if(subscriptionEventsJPO != null)
   {
       String programName  = subscriptionEventsJPO.substring(0,subscriptionEventsJPO.indexOf(":"));
       String methodName   = subscriptionEventsJPO.substring(subscriptionEventsJPO.indexOf(":")+1);
       Map paramMap        = new HashMap();
       paramMap.put("objectId", sObjId);
       String[] methodargs = JPO.packArgs(paramMap);
	   FrameworkUtil.validateMethodBeforeInvoke(context, programName, methodName, "Program");
       listEvents= (StringList) JPO.invoke(context, programName, null, methodName, methodargs, StringList.class);
   } else {
	   if (DomainConstants.POLICY_MESSAGE.equals(sObjectTypeStr))
	   {
	      listEvents.addElement(DiscussionEvent.EVENT_DISCUSSION_NEW_REPLY);
	   }
	   //Changed the type check as fix for IR-061355.
	   //else if(DomainConstants.TYPE_PART.equals(sObjectType) /*REMOVED || DomainConstants.TYPE_PART_FAMILY.equals(sObjectType)*/){
		else if(boAny.isKindOf(context, DomainConstants.TYPE_PART)){
	       if(sFromPage !=null && sFromPage.equals("AlternatePart"))
	       {
	          listEvents.addElement(com.matrixone.apps.common.Part.EVENT_ALTERNATE_PART_ADDED);
	          listEvents.addElement(com.matrixone.apps.common.Part.EVENT_ALTERNATE_PART_REMOVED);
	       }
	       else if(sFromPage !=null && sFromPage.equals("SparePart")){
	          listEvents.addElement(com.matrixone.apps.common.Part.EVENT_SPARE_PART_ADDED);
	          listEvents.addElement(com.matrixone.apps.common.Part.EVENT_SPARE_PART_REMOVED);
	       }
	       else if(sFromPage !=null && sFromPage.equals("SubstitutePart")){
	          listEvents.addElement(com.matrixone.apps.common.Part.EVENT_SUBSTITUTE_PART_ADDED);
	          listEvents.addElement(com.matrixone.apps.common.Part.EVENT_SUBSTITUTE_PART_REMOVED);
	       }
	       else
	       {
	         Subscribable boSubscribable = (Subscribable)DomainObject.newInstance(context,sObjId,DomainConstants.ENGINEERING);
	         listEvents = boSubscribable.getSubscribableEvents(context);
	         listEvents.addElement(DiscussionEvent.EVENT_DISCUSSION_NEW_DISCUSSION);
	       }
	   }
	   
	   else if(DomainConstants.TYPE_PART_FAMILY.equals(sObjectType)){
		     Subscribable boSubscribable = (Subscribable)DomainObject.newInstance(context,sObjId);
	         listEvents = boSubscribable.getSubscribableEvents(context);
	
			 //
			 // If Library Central is not installed then do not show the 'Content Modified' event.
			 //
			 boolean isLCInstalled = FrameworkUtil.isThisSuiteRegistered(context,session, "eServiceSuiteLibraryCentral");
			 if ( !isLCInstalled)
		     {
				listEvents.remove(com.matrixone.apps.common.PartFamily.EVENT_CONTENT_MODIFIED);
		     }
	    }
	   
	   else
	   {
	      try
	      {
	
		          Subscribable boSubscribable = (Subscribable)DomainObject.newInstance(context,sObjId);
		          listEvents = boSubscribable.getSubscribableEvents(context);
				  //Added for Bug-314984 on 10/May/2006
				  if(listEvents==null || "".equals(listEvents))
				  {
					  listEvents = new StringList();
				  }
				  listEvents.addElement(DiscussionEvent.EVENT_DISCUSSION_NEW_DISCUSSION);
	    	   
	      } catch (Exception ex)
	      {
	          listEvents.addElement(Document.EVENT_ROUTE_STARTED);
	          listEvents.addElement(Document.EVENT_ROUTE_COMPLETED);
	      }
	   }
   }

%>
 <form name="formEvents" method="post" >
  <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <tr>
     <td width="150" class="label">
     <emxUtil:i18n localize="i18nId"> emxComponents.SubscribeSummary.AlertEvents </emxUtil:i18n>
     </td>
     <td class="inputField">
       <table border="0">
         <tr>
           <td class="field">
           <table border="0">
             <%
               eventItr = new StringItr(listEvents);
               if (eventItr != null) {
                  while (eventItr.next()) {
                     String eventName = eventItr.obj();
                     String propertiesName = "emxComponents.Event." + eventName.replace(' ', '_');
                     String displayName = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), propertiesName); 
                     if (sl.contains(eventName)) {
%>
                        <tr>
							<td><input type="checkbox"  value="<%=XSSUtil.encodeForHTMLAttribute(context,eventName)%>" name="chkSubscribeEvent" checked /></td>
							<td><%=XSSUtil.encodeForHTML(context,displayName)%></td>
						</tr>                        
<%
                     } else {
%>
					<tr>
					  <td><input type="checkbox"  value="<%=XSSUtil.encodeForHTMLAttribute(context,eventName)%>" name="chkSubscribeEvent"/></td>
					  <td><%=XSSUtil.encodeForHTML(context,displayName)%></td>
					 </tr>                        
                        
<%
                     }
                  }
               }
%>
			</table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

  <input type="hidden" name="sObjectTypeStr" value="<%=XSSUtil.encodeForHTMLAttribute(context,sObjectTypeStr)%>" />
  <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context,sObjId)%>" />
  <input type="hidden" name="sUnsubscribedEventIds" value="" />
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


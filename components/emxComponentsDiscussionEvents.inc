<%--  emxComponentsDiscussionEvents.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
 
   static const char RCSID[] = "$Id: emxComponentsDiscussionEvents.inc.rca 1.5 Wed Oct 22 16:18:28 2008 przemek Experimental przemek $"
--%>
<%@ page import="java.util.*,
com.matrixone.apps.common.DiscussionEvent " %>


<%!
    public TreeMap AddDiscussionEvents(HttpServletRequest request)throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(DiscussionEvent.EVENT_DISCUSSION_NEW_REPLY, com.matrixone.apps.common.util.ComponentsUtil.i18nStringNow("emxComponents.Discussion.NewReply",request.getHeader("Accept-Language")));
      return eventMap;
    }
%>
<%!
    public TreeMap AddCreateDiscussionEvents(HttpServletRequest request)throws Exception {
      TreeMap eventMap = new TreeMap();
      eventMap.put(DiscussionEvent.EVENT_DISCUSSION_NEW_DISCUSSION, com.matrixone.apps.common.util.ComponentsUtil.i18nStringNow("emxComponents.Discussion.NewDiscussion",request.getHeader("Accept-Language")));
      return eventMap;
    }
%>

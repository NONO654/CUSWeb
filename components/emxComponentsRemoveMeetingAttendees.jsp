<%--  emxComponentsRemoveMeetingAttendees.jsp  --  Process page for the Remove attendees to the meeting

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] =  $Id: emxComponentsRemoveMeetingAttendees.jsp.rca 1.1 Wed Nov 26 11:27:59 2008 ds-lmanukonda Experimental $
 --%>
 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@include file = "emxComponentsUtil.inc"%>
 <%@include file = "eServiceUtil.inc"%>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
 <%@page import="java.util.* "%>
 <%@page import="matrix.util.* "%>
 <%@page import="matrix.db.*"%>
 <%@page import="com.matrixone.apps.domain.*"%>
 <%@ page import="com.matrixone.apps.domain.util.*" %>
 <%
  String strMeetingId             = emxGetParameter(request, "objectId");
  DomainObject busPerson        = null;
  String strAssignedMeetingsRel   = DomainObject.RELATIONSHIP_ASSIGNED_MEETINGS;
  DomainObject busMeeting = DomainObject.newInstance(context,strMeetingId);
  Enumeration enumParam = emxGetParameterNames(request);
  String personIds[] = emxGetParameterValues(request, "emxTableRowId");
  String strMemberId = null;
  String strMeetingHost = "";
  String strCtxUser = context.getUser();
  String strAttendee = "";
  strMeetingHost = (String)busMeeting.getInfo(context,DomainConstants.SELECT_OWNER);
  for(int i=0; i<personIds.length; i++){
	  StringTokenizer stk = new StringTokenizer(personIds[i],"|");
	  strMemberId = stk.nextToken();
	  busPerson        = DomainObject.newInstance(context,strMemberId);
	  strAttendee = (String)busPerson.getInfo(context,DomainConstants.SELECT_NAME);
	  
	  try {
        
            		if(strAttendee.equalsIgnoreCase(strMeetingHost))
            		{
  %>
            		    <script language="JavaScript">
             			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Meetings.RemoveMeetingHost</emxUtil:i18nScript>");             
            		    </script>
  <%           		    
            		}
            		else
            		{
						busPerson.disconnect(context,new RelationshipType(strAssignedMeetingsRel), true, busMeeting);
            		}
	  }catch(Exception e ) {
		  e.printStackTrace();
	  }
  }
  %>
   <script language="javascript">
    		window.parent.location.href=window.parent.location.href.replace("&persist=true","");
   </script>

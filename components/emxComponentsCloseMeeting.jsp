<%--  emxComponentsCloseMeeting.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program

   static const char RCSID[] = $Id: emxComponentsCloseMeeting.jsp.rca 1.1 Wed Nov 26 11:28:50 2008 ds-lmanukonda Experimental $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "eServiceUtil.inc" %>
<%@page import="matrix.db.MQLCommand"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.common.Company"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
try {
    // Start the update transaction
    ContextUtil.startTransaction(context, true);
  } catch (Exception e) {
    throw new Exception(e.getMessage());
  }
  String strMeetingId     = emxGetParameter(request, "meetingId");
  String strProjectId     = emxGetParameter(request, "projectId");
  String strReturnPage    = emxGetParameter(request, "returnPage");
  String sReturnPage      = emxGetParameter(request, "sReturnPage");
  String strCloseWindow   = emxGetParameter(request, "closeWindow");
  String strcurLocation   = emxGetParameter(request, "currentLocation");
  String policyMeeting    = Framework.getPropertyValue(session, "policy_Meeting");
  String stateInProgress  = FrameworkUtil.lookupStateName(context, policyMeeting, "state_InProgress");
  if ( strCloseWindow == null || strCloseWindow.length() == 0 ){
      strCloseWindow = "";
    }
    DomainObject busMeeting = DomainObject.newInstance(context, strMeetingId);
    busMeeting.setId(strMeetingId);
    busMeeting.open(context);
    String strExistingState = busMeeting.getInfo(context, busMeeting.SELECT_CURRENT);
    //checking the meeting state , if it's 'In progress' state then Promoting it to 'Complete' state.
    if(stateInProgress.equals(strExistingState)) {
      busMeeting.promote(context);
    }
    try {
        // Commit the transaction
        ContextUtil.commitTransaction(context);
      } catch (Exception e) {
        throw new Exception(e.getMessage());
      }
  %>
  <script language="Javascript">
  var strReturnPage = '<%=XSSUtil.encodeForJavaScript(context, strReturnPage)%>';
   </script>

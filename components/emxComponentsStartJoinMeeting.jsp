<%-- emxComponentsStartJoinMeeting.jsp -- This page will give a User Topics
                                      which are connected to active Meetings
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsStartJoinMeeting.jsp.rca 1.1 Wed Nov 26 11:34:55 2008 ds-lmanukonda Experimental $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>


<%@ page import="com.matrixone.apps.common.util.JSPUtil" %>



<html>
<body>

<%
try {
  String strMeetingId = emxGetParameter(request, "meetingId");
  String strAction    = emxGetParameter(request, "strAction");
  String strWebExURL  = emxGetParameter(request,"webExURL");
  String errorMessage = emxGetParameter(request,"errorMessage");
  String status       = emxGetParameter(request,"status");
  String strBackURL   = "";
  String fromPage     = emxGetParameter(request,"fromPage");
  String strReturnPage = emxGetParameter(request,"returnPage"); // added new parameter
  String sReturnPage = emxGetParameter(request,"sReturnPage"); // added new parameter
  // Read the default meeting password from property file

  String strDefaultMeetingPassword = EnoviaResourceBundle.getProperty(context,"emxComponents.MeetingPassword");
  String strProjectId = emxGetParameter(request,"projectId");
  BusinessObject busPerson = JSPUtil.getPerson(context, session);
  String strPersonId = busPerson.getObjectId();
  BusinessObject busContextPerson = JSPUtil.getPerson(context, session);
  BusinessObject busContextOrganization = JSPUtil.getOrganization(context, session,busContextPerson);
  String strMeetingUsernameAttr =  Framework.getPropertyValue( session, "attribute_MeetingUsername" );
  String strMeetingPasswordAttr =  Framework.getPropertyValue( session, "attribute_MeetingPassword" );
  SelectList selectListAttributes = new SelectList();
  selectListAttributes.addAttribute(strMeetingUsernameAttr);
  selectListAttributes.addAttribute(strMeetingPasswordAttr);
  busContextPerson.open(context);
  BusinessObjectWithSelect busWSelectPerson = busContextPerson.select(context,selectListAttributes);
  busContextPerson.close(context);
  String strUserName = busContextPerson.getName();
  String pwd = busWSelectPerson.getSelectData(strMeetingPasswordAttr);
  String strEnableAnonymousUserInMeeting = EnoviaResourceBundle.getProperty(context,"emxComponents.enableAnonymousUserInMeeting");
  String strMeetingExtendedURL = EnoviaResourceBundle.getProperty(context,"emxComponents.MeetingExtendedURL");
  if(status == null || "null".equals(status)){
      status = "";
    }
    if(fromPage == null || "null".equals(fromPage)){
      fromPage = "";
    }
    String strJoinMeetingURL = strMeetingExtendedURL;//"/webex/p.php"
    String strAT = "LI";
    //StringList strListTokens = new StringList();
    //
    String strMeetingUsername = busWSelectPerson.getSelectData(selectListAttributes.getAttributeSelect(strMeetingUsernameAttr));
     String strMeetingPassword = busWSelectPerson.getSelectData(selectListAttributes.getAttributeSelect(strMeetingPasswordAttr));
    if (strAction.equals("JoinMeeting")) {
        if ("TRUE".equalsIgnoreCase(strEnableAnonymousUserInMeeting)) {
          //strJoinMeetingURL = strMeetingExtendedURL+"?PW="+strDefaultMeetingPassword;//"/webex/m.php?PW="+strDefaultMeetingPassword;
          strJoinMeetingURL = strMeetingExtendedURL;
          // newly added param returnPage for detailfs refresh
          strBackURL = "emxTeamMeetingConnectionClose.jsp?Next=JoinMeeting&returnPage="+ strReturnPage +"&sReturnPage="+ sReturnPage + "&meetingId=" + strMeetingId + "&projectId=" + strProjectId;

          strAT = "JM";
        } else {

          //strJoinMeetingURL = strMeetingExtendedURL+"?PW="+strMeetingPassword;
          strJoinMeetingURL = strMeetingExtendedURL+"&"+strMeetingUsername;
          strAT = "LI";
          // newly added param returnPage for detailfs refresh
          strBackURL = "emxComponentsMeetingConnect.jsp?Next=JoinMeeting&returnPage="+ strReturnPage + "&meetingId=" + strMeetingId + "&projectId=" + strProjectId;
        }
      }
    %>
    <script language="javascript">
    var backURL = parent.window.getWindowOpener().location.href;
    var extendedURL = "<%=strMeetingExtendedURL%>";
    backURL = backURL.substring(0,backURL.lastIndexOf("/")+1);
	var webExURL = "<%=XSSUtil.encodeForJavaScript(context, strWebExURL)%>";
	var WID = "<%=XSSUtil.encodeForJavaScript(context,strMeetingUsername)%>";
	var PW = "<%=XSSUtil.encodeForJavaScript(context,strMeetingPassword)%>";
	var MK = "";
	var AN = "<%=XSSUtil.encodeForJavaScript(context,strUserName)%>";
	 
	    function startMeeting(meetingKey,meetingId) {
	        MK = meetingKey;
		    // added returnPage param for detailfs refresh
		    backURL = backURL + "emxComponentsMeetingConnect.jsp?Next=StartMeeting&returnPage=<%=XSSUtil.encodeForURL(context, strReturnPage)%>&sReturnPage=<%=XSSUtil.encodeForURL(context, strReturnPage)%>&webExURL="+webExURL+"&backURL="+ backURL;
		    document.startMeetingForm.action = webExURL + extendedURL;
		    //document.startMeetingForm.action = "emxComponentsMeetingConnect.jsp?Next=StartMeeting&returnPage=<%=strReturnPage%>&sReturnPage=<%=strReturnPage%>&webExURL="+webExURL+"&backURL="+ backURL+"&meetingId=" + meetingId;
		    document.startMeetingForm.AT.value = "LI";
		    document.startMeetingForm.WID.value = WID;
		    document.startMeetingForm.PW.value = PW;
		
		    // added new parameter returnPage to the URL
		    document.startMeetingForm.BU.value = escape(backURL + "&meetingKey="+ meetingKey + "&meetingId=" + meetingId + "&projectId=<%=XSSUtil.encodeForJavaScript(context, strProjectId)%>");
		    document.startMeetingForm.submit();
	  }
	   function joinMeeting(meetingKey,meetingId) {
	   
	//XSSOK
    var joinURL = "<%=strJoinMeetingURL%>";
    var backPageName = "<%=XSSUtil.encodeForJavaScript(context, strBackURL)%>";
    //XSSOK
    var AT = "<%=strAT%>";
    document.startMeetingForm.PW.value="<%=strDefaultMeetingPassword%>";
    MK = meetingKey;
    document.startMeetingForm.WID.value = WID;
    if ( AT != "LI") {
      document.startMeetingForm.AN.value = AN;
    } else {
      document.startMeetingForm.PW.value = PW;
    }

    document.startMeetingForm.AT.value = AT;
    document.startMeetingForm.MK.value = MK;
    document.startMeetingForm.action = webExURL + joinURL;
    // added new parameter returnPage to the URL
    document.startMeetingForm.BU.value = escape(backURL + backPageName + "&meetingKey="+ meetingKey +"&webExURL=" + webExURL);
    document.startMeetingForm.submit();
  }
    </script>
    <%
    String strMeetingKeyAttr =  Framework.getPropertyValue( session, "attribute_MeetingKey" );

    BusinessObject busMeeting = new BusinessObject(strMeetingId);
    String strMeetingKey = JSPUtil.getAttribute(context, session, busMeeting, strMeetingKeyAttr);
    %>
    <form name="startMeetingForm" method="post">
      <input type="hidden" name="AT" value="LI" />
      <input type="hidden" name="AN" value="" />
      <input type="hidden" name="WID" value="" />
      <input type="hidden" name="PW" value="" />
      <input type="hidden" name="MU" value="GOBACK" />
      <input type="hidden" name="MK" value="" />
      <input type="hidden" name="BU" value="" />
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    </form>
    <%
    if (strAction.equals("StartMeeting") ) {
    %>
        <script language="Javascript">
         startMeeting('<%=XSSUtil.encodeForJavaScript(context,strMeetingKey)%>','<%=XSSUtil.encodeForJavaScript(context, strMeetingId)%>');
       </script>
   	<%
    }
    if (strAction.equals("JoinMeeting") ) {
    %>
        <script language="Javascript">
         joinMeeting('<%=XSSUtil.encodeForJavaScript(context,strMeetingKey)%>','<%=XSSUtil.encodeForJavaScript(context, strMeetingId)%>');
       </script>
   	<%
    }
}catch(Exception ex){
    ex.printStackTrace();

}
%>
  
   
   

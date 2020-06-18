<%--
  emxComponentsMeetingsUtil.jsp -- Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsMeetingsUtil.inc.rca 1.6 Wed Oct 22 16:18:16 2008 przemek Experimental przemek $";
--%>

<%@ page import="com.matrixone.apps.common.Person, matrix.db.*, matrix.util.*, com.matrixone.servlet.*, java.util.*, java.net.*, java.io.*, com.matrixone.apps.domain.util.*, com.matrixone.apps.framework.taglib.*"%>

<%!
  // Dependees:
  // The page which include this page should have eServiceUtil.jsp included before this include
  //
  // returns String based on creating webexId with webex apis
  //
  static public String getMeetingId(matrix.db.Context context, HttpSession session, BusinessObject busPerson, String strUserName, String strPassword, String languageStr) throws Exception
  {
    String personId = busPerson.getObjectId();
    Person person = new Person();
    person.setId(personId);
    person.open(context);
    String strBusinessUnitId      = person.getInfo(context, com.matrixone.apps.common.Person.SELECT_BUSINESS_UNIT_ID);
    String strMeetingSiteNameAttr = PropertyUtil.getSchemaProperty(context,"attribute_MeetingSiteName");
    String strEmailAttr           = PropertyUtil.getSchemaProperty(context,"attribute_EmailAddress");
    String strMeetingSiteIdAttr   = PropertyUtil.getSchemaProperty(context,"attribute_MeetingSiteID");
    String strFirstNameAttr       = PropertyUtil.getSchemaProperty(context, "attribute_FirstName");
    String strLastNameAttr        = PropertyUtil.getSchemaProperty(context, "attribute_LastName");

    BusinessObject busOrganization = null;

    if(strBusinessUnitId == null || strBusinessUnitId == "null" || "".equals(strBusinessUnitId)|| "null".equals(strBusinessUnitId)){
      busOrganization = new Person(busPerson).getCompany(context);
    }else{
      busOrganization = new BusinessObject(strBusinessUnitId);
      String strBusMeetSiteName      = getAttribute(context, session,busOrganization,strMeetingSiteNameAttr);
      String strBusMeetSiteId        = getAttribute(context, session,busOrganization,strMeetingSiteIdAttr);
      if(strBusMeetSiteName == null || strBusMeetSiteName == "null" || "".equals(strBusMeetSiteName) || "null".equals(strBusMeetSiteName) || strBusMeetSiteId == null || strBusMeetSiteId == "null" || "".equals(strBusMeetSiteId) || "null".equals(strBusMeetSiteId)){
        busOrganization = new Person(busPerson).getCompany(context);
      }
    }


    String strMeetingSiteName     = getAttribute(context, session,busOrganization,strMeetingSiteNameAttr);
    String strEmail               = getAttribute(context, session,busPerson,strEmailAttr);
    String strMeetingSiteId       = getAttribute(context, session,busOrganization,strMeetingSiteIdAttr);
    String strFirstName           = getAttribute(context, session,busPerson,strFirstNameAttr);
    String strLastName            = getAttribute(context, session,busPerson,strLastNameAttr);
    String strReturn = null;
    String strReason = null;
    String error = null;

    try {
      if ( strMeetingSiteName != null && !"".equals (strMeetingSiteName) && strMeetingSiteName.length() != 0 ) {

        String strURL = strMeetingSiteName + "/webex/p.asp?AT=SU&PID=" + strMeetingSiteId + "&EM=" + strEmail + "&WID=" + strUserName + "&PW=" + strPassword + "&FN=" + strFirstName + "&LN=" + strLastName;
        URL urlMeeting = new URL( strURL );
        URLConnection urlCMeeting = urlMeeting.openConnection();

        BufferedReader bufReaderMeeting = new BufferedReader(new InputStreamReader(urlCMeeting.getInputStream()));

        String strInputLine;
        String strReply = "";
        while ((strInputLine = bufReaderMeeting.readLine()) != null) {
          strReply += strInputLine;
        }
        String strMessage = strReply.substring(strReply.indexOf("<Status>")+8,strReply.indexOf("</Status>"));
        strReturn = strMessage;

        if ( "FAIL".equals(strMessage) ) {
          strReason = strReply.substring(strReply.indexOf("<Reason>")+8,strReply.indexOf("</Reason>"));
          error = strReason;
        }
      } else {
        error = i18nNow.getI18nString("emxTeamCentral.Meeting.MeetingSiteNameError","emxTeamCentralStringResource",languageStr);
        strReturn = "FAIL";
      }

    } catch (UnknownHostException unknowHostEx ) {
      error = i18nNow.getI18nString("emxTeamCentral.Meeting.MeetingSiteNameError","emxTeamCentralStringResource",languageStr);
      strReturn = "FAIL";
    }
    if(error != null){
      session.putValue("error.message", error);
    }
    return strReturn;
  }
%>

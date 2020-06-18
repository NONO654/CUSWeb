<%--  emxTeamEditUserProfile.jsp - To Edit the User Profile

  This page updates the person from the edited person details.

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamEditUserProfile.jsp.rca 1.25 Wed Oct 22 16:06:39 2008 przemek Experimental przemek $

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamProfileUtil.inc" %>

<%!
  private static final String  S_PROTOCOL = "ftp://";
  private static final String  S_FORMAT   = "Image";
  private static final String  S_HOST     = "localhost";
  private static final boolean B_UNLOCK   = true;
%>

<%
  String strFirstNameAttr               = Framework.getPropertyValue(session, "attribute_FirstName");
  String strMiddleNameAttr              = Framework.getPropertyValue(session, "attribute_MiddleName");
  String strLastNameAttr                = Framework.getPropertyValue(session, "attribute_LastName");
  String strLoginTypeAttr               = Framework.getPropertyValue(session, "attribute_LoginType");
  String strJTViewerTypeAttr            = Framework.getPropertyValue(session, "attribute_JTViewerType");
  String strSubscriptionLevelAttr       = Framework.getPropertyValue(session, "attribute_SubscriptionLevel");
  String strHostMeetingsAttr            = Framework.getPropertyValue(session, "attribute_HostMeetings");
  String strAddressAttr                 = Framework.getPropertyValue(session, "attribute_Address");
  String strCityAttr                    = Framework.getPropertyValue(session, "attribute_City");
  String strStateRegionAttr             = Framework.getPropertyValue(session, "attribute_StateRegion");
  String strPostalCodeAttr              = Framework.getPropertyValue(session, "attribute_PostalCode");
  String strCountryAttr                 = Framework.getPropertyValue(session, "attribute_Country");
  String strWorkPhoneNumberAttr         = Framework.getPropertyValue(session, "attribute_WorkPhoneNumber");
  String strEmailAddressAttr            = Framework.getPropertyValue(session, "attribute_EmailAddress");
  String strWebSiteAttr                 = Framework.getPropertyValue(session, "attribute_WebSite");
  String strHomePhoneNumberAttr         = Framework.getPropertyValue(session, "attribute_HomePhoneNumber");
  String strPagerNumberAttr             = Framework.getPropertyValue(session, "attribute_PagerNumber");
  String strFaxNumberAttr               = Framework.getPropertyValue(session, "attribute_FaxNumber");
  String strAbsenceStartDateAttr        = Framework.getPropertyValue(session, "attribute_AbsenceStartDate");
  String strAbsenceEndDateAttr          = Framework.getPropertyValue(session, "attribute_AbsenceEndDate");
  String strAbsenceDelegateAttr         = Framework.getPropertyValue(session, "attribute_AbsenceDelegate");

  String strPersonType                  = Framework.getPropertyValue(session, "type_Person");
  String strCompanyType                 = Framework.getPropertyValue(session, "type_Company");
  String strOrganizationType            = Framework.getPropertyValue(session, "type_Organization");
  String strBusinessUnitType            = Framework.getPropertyValue(session, "type_BusinessUnit");
  String strLocationType                = Framework.getPropertyValue(session, "type_Location");

  String strEmployeeRel                 = Framework.getPropertyValue(session, "relationship_Employee");
  String strDivisionRel                 = Framework.getPropertyValue(session, "relationship_Division");
  String strWorkPlaceRel                = Framework.getPropertyValue(session, "relationship_WorkPlace");
  String strLocationRel                 = Framework.getPropertyValue(session, "relationship_OrganizationLocation");
  String strBusinessUnitEmployeeRel     = Framework.getPropertyValue(session, "relationship_BusinessUnitEmployee");
  String strCompanyRepresentativeRel    = Framework.getPropertyValue(session, "relationship_CompanyRepresentative");

  String strEmployeeRole                = Framework.getPropertyValue(session, "role_Employee");
  String strOrganizationManagerRole     = Framework.getPropertyValue(session, "role_OrganizationManager");


  // this is now determined by the selection on checkin page
  // private static final boolean B_APPEND   = true;
  // Create a temp directory to place the file into
  String S_TEMPDIR;
  {
    String sProgram = "eServicecommonUtFileGetTmpDir.tcl";
    String err = ""; // error message return by MQLCommand
    String res = ""; // results returned by MQLCommand

    // Execute the MQL command
    MQLCommand command = new MQLCommand();
    command.open( context );
    command.executeCommand( context, "execute program $1",sProgram);
    err = command.getError().trim();
    S_TEMPDIR = command.getResult().trim();
    command.close(context);

    if ( S_TEMPDIR.length() == 0){
       throw new MatrixException(i18nNow.getI18nString("emxRequestCentral.Common.Msg8", "emxTeamCentralStringResource",sLanguage) + ": " + err);
    }
  };


  /**
  * Get the form Data from the multipart request.
  * Since the form is multipart we will reference MultpartRequest rather than a standard request.
  */
  MultipartRequest mrequest   = new MultipartRequest( request , S_TEMPDIR , MultipartRequest.UNLIMITED_POST_SIZE );
  boolean B_APPEND = false;
  // Taking Parameters From request of Edit Form

  String strPersonId                = mrequest.getParameter("personId");
  String strFirstName               = mrequest.getParameter("firstname");
  String strMiddleName              = mrequest.getParameter("middlename");
  String strLastName                = mrequest.getParameter("lastname");
  String strSubscriptionLevel       = mrequest.getParameter("subscriptionlevel");
  String strHostMeetings            = mrequest.getParameter("hostmeetings");
  String strMeetingUsername         = mrequest.getParameter("meetingUsername");
  String strMeetingPassword         = mrequest.getParameter("meetingPassword");
  String strAddress                 = mrequest.getParameter("address");
  String strCity                    = mrequest.getParameter("city");
  String strStateRegion             = mrequest.getParameter("stateRegion");
  String strPostalCode              = mrequest.getParameter("postalCode");
  String strCountry                 = mrequest.getParameter("country");
  String strWorkPhoneNumber         = mrequest.getParameter("workphonenumber");
  String strEmailAddress            = mrequest.getParameter("emailaddress");
  String strWebSite                 = mrequest.getParameter("website");
  String strPagerNumber             = mrequest.getParameter("pagernumber");
  String strFaxNumber               = mrequest.getParameter("faxnumber");
  String strHomePhoneNumber         = mrequest.getParameter("homephonenumber");
  String strOriginalMeetingUsername = mrequest.getParameter("originalMeetingUsername");
  String strOriginalMeetingPassword = mrequest.getParameter("originalMeetingPassword");
  String strCompanyId               = mrequest.getParameter("companyId");
  String strOriginalWorkPlace       = mrequest.getParameter("originalWorkPlace");
  String strCheckinFlag             = mrequest.getParameter("checkinFlag");
  String userRole                   = mrequest.getParameter("userRole");
  String strAbsenceStartDate        = mrequest.getParameter("AbsenceStartDate");
  String strAbsenceEndDate          = mrequest.getParameter("AbsenceEndDate");
  String strDelegate                = mrequest.getParameter("person");
  String strLanguagePreference      = mrequest.getParameter("languagePreference");

  String jsTreeID                   = mrequest.getParameter("jsTreeID");
  String suiteKey                   = mrequest.getParameter("suiteKey");

  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON, DomainConstants.TEAM);

  double clientTZOffset           = (new Double((String)session.getValue("timeZone"))).doubleValue();
  
  //Formatting Date to Ematrix Date Format
  if(strAbsenceStartDate!=null && !"".equals(strAbsenceStartDate))
    strAbsenceStartDate = eMatrixDateFormat.getFormattedInputDate(context,strAbsenceStartDate,clientTZOffset,request.getLocale());
  if(strAbsenceEndDate!=null && !"".equals(strAbsenceEndDate))
    strAbsenceEndDate = eMatrixDateFormat.getFormattedInputDate(context,strAbsenceEndDate,clientTZOffset,request.getLocale());

  strHostMeetings = (strHostMeetings == null) ? mrequest.getParameter("hostmeetings1") : strHostMeetings;

  if ( userRole == null || "".equals(userRole) ) {
    userRole =  "user";
  } 
  if ( strOriginalMeetingUsername == null || "".equals(strOriginalMeetingUsername) ) {
    strOriginalMeetingUsername =  "";
  }
  if ( strOriginalMeetingPassword == null || "".equals(strOriginalMeetingPassword) ) {
    strOriginalMeetingPassword =  "";
  }
  if ( strMeetingUsername == null || "".equals(strMeetingUsername) ) {
    strMeetingUsername =  "";
  }

  AttributeList attrListPerson = new AttributeList();

  attrListPerson.add( new Attribute( new AttributeType(strFirstNameAttr)  , strFirstName ) );
  attrListPerson.add( new Attribute( new AttributeType(strMiddleNameAttr)  , strMiddleName ) );
  attrListPerson.add( new Attribute( new AttributeType(strLastNameAttr)  , strLastName ) );
  attrListPerson.add( new Attribute( new AttributeType(strSubscriptionLevelAttr)  , strSubscriptionLevel ) );
  attrListPerson.add( new Attribute( new AttributeType(strAddressAttr)  , strAddress ) );
  attrListPerson.add( new Attribute( new AttributeType(strCityAttr)  , strCity ) );
  attrListPerson.add( new Attribute( new AttributeType(strStateRegionAttr)  , strStateRegion ) );
  attrListPerson.add( new Attribute( new AttributeType(strPostalCodeAttr)  , strPostalCode ) );
  attrListPerson.add( new Attribute( new AttributeType(strCountryAttr)  , strCountry ) );
  attrListPerson.add( new Attribute( new AttributeType(strHostMeetingsAttr)  , strHostMeetings ) );
  attrListPerson.add( new Attribute( new AttributeType(strWorkPhoneNumberAttr)  , strWorkPhoneNumber ) );
  attrListPerson.add( new Attribute( new AttributeType(strEmailAddressAttr)  , strEmailAddress ) );
  attrListPerson.add( new Attribute( new AttributeType(strWebSiteAttr)  , strWebSite ) );
  attrListPerson.add( new Attribute( new AttributeType(strHomePhoneNumberAttr)  , strHomePhoneNumber ) );
  attrListPerson.add( new Attribute( new AttributeType(strPagerNumberAttr)  , strPagerNumber) );
  attrListPerson.add( new Attribute( new AttributeType(strFaxNumberAttr)  , strFaxNumber ) );
  attrListPerson.add( new Attribute( new AttributeType(strAbsenceStartDateAttr)  , strAbsenceStartDate ) );
  attrListPerson.add( new Attribute( new AttributeType(strAbsenceEndDateAttr)  , strAbsenceEndDate ) );
  attrListPerson.add( new Attribute( new AttributeType(strAbsenceDelegateAttr)  , strDelegate ) );

  // Check for a person id.
  if (strPersonId == null) {
    throw new MatrixException(i18nNow.getI18nString("emxTeamCentral.Common.MatrixException","emxTeamCentralStringResource",request.getHeader("Accept-Language")));
  }
  // Get the person business object from the person id.
  BusinessObject busPerson = new BusinessObject(strPersonId);
  busPerson.open(context);

  // Modify the business object's attributes and catch errors.
  busPerson.setAttributes( context , attrListPerson);

  FormatUtil formatUtil = new FormatUtil();

  String formatsStr = EnoviaResourceBundle.getProperty(context,"emxFramework.FormatsWithViewerPreference");

  if( formatsStr != null ){
    StringTokenizer formatsTokenizer = new StringTokenizer(formatsStr,",");
    person.setToContext( context );
    person.open(context);

    while(formatsTokenizer.hasMoreTokens()){
      String formatToken = (String)formatsTokenizer.nextToken();
      String format = PropertyUtil.getSchemaProperty(context,formatToken);//person.getSchemaProperty( formatToken );

      if( format != null && !"".equals(format)){
        formatUtil.setFormatName( formatToken );
        String requestParameter =  format + "viewerPreference";
        String requestParameterValue = mrequest.getParameter(requestParameter);

        if(requestParameterValue != null && !"".equals(requestParameterValue)){
          if("None".equals(requestParameterValue)){
            formatUtil.removeViewerPreference( context, person.getName());
          } else {
            formatUtil.setViewerPreference( context, person.getName(), requestParameterValue);
          }
        }
      }
    }
    person.close(context);
  }

  //update the language preference for a person only if the pref has been changed
  //get the language preference for the person
  String personLanguagePreference = person.getLanguagePreference(context, person.getName());
  if(personLanguagePreference == null) {
    personLanguagePreference = "";
  }
  if(strLanguagePreference == null || strLanguagePreference.equals("None")) {
    strLanguagePreference = "";
  }
  // set the IconMailLanguagePreference for the person
  if(!personLanguagePreference.equals(strLanguagePreference)) {
    person.setLanguagePreference(context, person.getName(), strLanguagePreference);
  }

  // Get the company we represent.
  BusinessObject busRepOrg = Company.getCompanyForRep(context,busPerson);
  String strOrgType = "";
  if ( busRepOrg != null ) {
    busRepOrg.open(context);
    strOrgType = busRepOrg.getTypeName();
    busRepOrg.close(context);
  }

  /**
  * Determine if we are doing an FTP transfer or an HTTP Transfer
  */
  java.io.File oFile = null;
  try {
    String sName ="";
    String sFileName ="";
    String sType ="";
    Enumeration oFiles = mrequest.getFileNames();
    while ( oFiles.hasMoreElements() ) {

    // query the multipart request for HTTP files
      sName = (String)oFiles.nextElement();
      sFileName = mrequest.getFilesystemName( sName );

      if(sFileName !=null) {
        sType = mrequest.getContentType( sName );
        oFile = mrequest.getFile( sName );
        // Check the file into the business object
        // boNewProjectMember.open( context );
        busPerson.checkinFile( context , B_UNLOCK , B_APPEND , S_HOST , S_FORMAT , sFileName , S_TEMPDIR );
        // Delete the temporary file
        oFile = new java.io.File( S_TEMPDIR+"\\"+sFileName );
        oFile.delete();
      }
    }
    busPerson.close(context);
  } catch ( Exception e ) {
    if ( busPerson.isOpen()){
      busPerson.close( context);
    }
       session.putValue("error.message", e.getMessage());
  }

%>


<html>
<body>
<%

  if ( strMeetingUsername != null && !"".equals(strMeetingUsername) && ( !strMeetingUsername.equals( strOriginalMeetingUsername) || !strMeetingPassword.equals( strOriginalMeetingPassword)) ) {

%>
    <form name="personForm" method="post" action="emxTeamCreateMeetingId.jsp">
      <input type= "hidden"  name="personId" value="<xss:encodeForHTMLAttribute><%=strPersonId%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="projectId" value=""/>
      <input type= "hidden"  name="userRole" value="<xss:encodeForHTMLAttribute><%=userRole%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="meetingUsername" value="<xss:encodeForHTMLAttribute><%=strMeetingUsername%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="meetingPassword" value="<xss:encodeForHTMLAttribute><%=strMeetingPassword%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="objectId" value="<xss:encodeForHTMLAttribute><%=strCompanyId%></xss:encodeForHTMLAttribute>"/>
      <input type= "hidden"  name="fromPage" value="EditUserProfile"/>
    </form>
    <script language="javascript">
      document.personForm.submit();
    </script>
 </body>
 </html>
<%
  } else {

%>
    <script language="javascript">
      parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
      parent.window.closeWindow();
    </script>
    </body>
</html>
<%
  }
%>



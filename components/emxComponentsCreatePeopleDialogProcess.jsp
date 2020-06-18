<%--  emxComponentsCreatePeopleDialogProcess.jsp   -   Creating the People Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreatePeopleDialogProcess.jsp.rca 1.29 Wed Oct 22 16:18:03 2008 przemek Experimental przemek $
--%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUICore.js"></script>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String keyPerson = emxGetParameter(request,"keyPerson");
  if(keyPerson == null)
  {
     keyPerson = formBean.newFormKey(session);
  }
  formBean.processForm(session,request,"keyPerson");

  String strPersonType              = PropertyUtil.getSchemaProperty(context, "type_Person");
  String strCompanyType             = PropertyUtil.getSchemaProperty(context, "type_Company");
  String strOrganizationType        = PropertyUtil.getSchemaProperty(context, "type_Organization");
  String strBusinessUnitType        = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String strLocationType            = PropertyUtil.getSchemaProperty(context, "type_Location");

  String strFirstNameAttr           = PropertyUtil.getSchemaProperty(context, "attribute_FirstName");
  String strMiddleNameAttr          = PropertyUtil.getSchemaProperty(context, "attribute_MiddleName");
  String strLastNameAttr            = PropertyUtil.getSchemaProperty(context, "attribute_LastName");

  String strWorkPhoneNumberAttr     = PropertyUtil.getSchemaProperty(context, "attribute_WorkPhoneNumber");
  String strHomePhoneNumberAttr     = PropertyUtil.getSchemaProperty(context, "attribute_HomePhoneNumber");
  String strPagerNumberAttr         = PropertyUtil.getSchemaProperty(context, "attribute_PagerNumber");
  String strFaxNumberAttr           = PropertyUtil.getSchemaProperty(context, "attribute_FaxNumber");  

  String strEmailAddressAttr        = PropertyUtil.getSchemaProperty(context, "attribute_EmailAddress");
  String strWebSiteAttr             = PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
  
  String strLoginTypeAttr           = PropertyUtil.getSchemaProperty(context, "attribute_LoginType");

  String strHostMeetingsAttr        = PropertyUtil.getSchemaProperty(context, "attribute_HostMeetings");
  String strAddressAttr             = PropertyUtil.getSchemaProperty(context, "attribute_Address");
  String strCityAttr                = PropertyUtil.getSchemaProperty(context, "attribute_City");
  String strStateRegionAttr         = PropertyUtil.getSchemaProperty(context, "attribute_StateRegion");
  String strPostalCodeAttr          = PropertyUtil.getSchemaProperty(context, "attribute_PostalCode");
  String strCountryAttr             = PropertyUtil.getSchemaProperty(context, "attribute_Country");

  String strAbsenceStartDateAttr    = PropertyUtil.getSchemaProperty(context, "attribute_AbsenceStartDate");
  String strAbsenceEndDateAttr      = PropertyUtil.getSchemaProperty(context, "attribute_AbsenceEndDate");
  String strAbsenceDelegateAttr     = PropertyUtil.getSchemaProperty(context, "attribute_AbsenceDelegate");
  
  //Added for Organization Person Feature
  String strMailCodeAttr            = PropertyUtil.getSchemaProperty(context, "attribute_MailCode");
  String strTitleAttr               = PropertyUtil.getSchemaProperty(context, "attribute_Title");
  //End
  String strEmployeeRel             = PropertyUtil.getSchemaProperty(context, "relationship_Employee");
  String strDivisionRel             = PropertyUtil.getSchemaProperty(context, "relationship_Division");
  String strWorkPlaceRel            = PropertyUtil.getSchemaProperty(context, "relationship_WorkPlace");
  String strLocationRel             = PropertyUtil.getSchemaProperty(context, "relationship_OrganizationLocation");
  String strBusinessUnitEmployeeRel = PropertyUtil.getSchemaProperty(context, "relationship_BusinessUnitEmployee");
  String strCompanyRepresentativeRel= PropertyUtil.getSchemaProperty(context, "relationship_CompanyRepresentative");
  String strMemberRel               = PropertyUtil.getSchemaProperty(context, "relationship_Member");

  String strEmployeeRole            = PropertyUtil.getSchemaProperty(context, "role_Employee");
  String employeeSymbolicName       = FrameworkUtil.getAliasForAdmin(context, "role", strEmployeeRole, true);
  String strBasicUserRole           = PropertyUtil.getSchemaProperty(context, "role_BasicUser");
  String strExchangeUserRole 		= PropertyUtil.getSchemaProperty(context, "role_ExchangeUser");
  String exchangeUserSymbolicName       = FrameworkUtil.getAliasForAdmin(context, "role", strExchangeUserRole, true);
  
  String strCompanyRepresentative   = PropertyUtil.getSchemaProperty(context, "role_CompanyRepresentative");
  String strOrganizationManager     = PropertyUtil.getSchemaProperty(context, "role_OrganizationManager");

  String strPersonPolicy            = PropertyUtil.getSchemaProperty(context, "policy_Person");
  String attrCountry                = PropertyUtil.getSchemaProperty(context, "attribute_Country");
  
  // Get page parameters.

  String loginName        = (String)formBean.getElementValue("loginName");
  String password         = (String)formBean.getElementValue("password");
  String confirmpassword  = (String)formBean.getElementValue("confirmpassword");
  String firstName        = (String)formBean.getElementValue("firstName");
  String middleName       = (String)formBean.getElementValue("middleName");
  String lastName         = (String)formBean.getElementValue("lastName");
  String licensedHours	  = (String)formBean.getElementValue("licensedHours");
  String companyName      = (String)formBean.getElementValue("companyName");
  String strBusinessUnit  = (String)formBean.getElementValue("businessUnit");
  String location         = (String)formBean.getElementValue("location");
  String strCompanyRep    = (String)formBean.getElementValue("companyrep");
  String workPhoneNumber  = (String)formBean.getElementValue("workPhoneNumber");
  String homePhoneNumber  = (String)formBean.getElementValue("homePhoneNumber");
  String pagerNumber      = (String)formBean.getElementValue("pagerNumber");
  String faxNumber        = (String)formBean.getElementValue("faxNumber");  
  String emailAddress     = (String)formBean.getElementValue("emailAddress");
  String strLanguagePref  = (String)formBean.getElementValue("languagePreference");  
  String webSite          = (String)formBean.getElementValue("webSite");
  String strLoginType     = (String)formBean.getElementValue("logintype");
  String strHostMeetings  = (String)formBean.getElementValue("hostmeetings");
  String meetingUsername  = (String)formBean.getElementValue("meetingUsername");
  String meetingPassword  = (String)formBean.getElementValue("meetingPassword");
  String strAddress       = (String)formBean.getElementValue("address");
  String strCity          = (String)formBean.getElementValue("city");
  String strStateRegion   = (String)formBean.getElementValue("stateRegion");
  String strPostalCode    = (String)formBean.getElementValue("postalCode");
  String strCountry       = (String)formBean.getElementValue(attrCountry);
  String strAbsenceStartDate = (String)formBean.getElementValue("AbsenceStartDate");
  String strAbsenceEndDate   = (String)formBean.getElementValue("AbsenceEndDate");
  String strAbsenceDelegate  = (String)formBean.getElementValue("person");
  String strVault            = (String)formBean.getElementValue("Vault");
  String strDateFormat       = (String)formBean.getElementValue("dateFormat");
  String strListSeparator    = (String)formBean.getElementValue("listSeparator");
  //Added for Organization Person Feature
  String strMailCode         = (String)formBean.getElementValue("mailCode");
  String strTitle            = (String)formBean.getElementValue("title");
  //End
  String strSite             = (String)formBean.getElementValue("Site");
  String strObjectId         = (String)formBean.getElementValue("objectId");

  String jsTreeID         = (String)formBean.getElementValue("jsTreeID");
  String suiteKey         = (String)formBean.getElementValue("suiteKey");
  
  String languageStr = request.getHeader("Accept-Language");
  
// Following code is to remove the values from formBean
  Iterator test = formBean.getElementNames();
  String name = "";
  while(test.hasNext())
  {
    name = (String) test.next();
    formBean.setElementValue(name,"");
  }  
  formBean.removeFormInstance(session,request);
  session.removeAttribute(keyPerson);
//------------------------------------

  String strPersonId = "";

  String strCompanyRepresentativeAlias = FrameworkUtil.getAliasForAdmin(context, "role", strCompanyRepresentative, true);
  String strOrganizationManagerAlias   = FrameworkUtil.getAliasForAdmin(context, "role", strOrganizationManager, true);

  String sProjectUserSubRoles          = EnoviaResourceBundle.getProperty(context,"emxComponents.UserSubRoles.ProjectUser");
  String sExternalProjectUserSubRoles  = EnoviaResourceBundle.getProperty(context,"emxComponents.UserSubRoles.ExternalProjectUser");  
  String strProjectUserAlias           = "role_ProjectUser";
  String strExternalProjectUserAlias   = "role_ExternalProjectUser";  
  

  StringList projectUserSubRolesList = new StringList();

  if(sProjectUserSubRoles!=null && !"null".equals(sProjectUserSubRoles))
  {
    projectUserSubRolesList = FrameworkUtil.split(sProjectUserSubRoles,",");
  }

  StringList externalProjectUserSubRolesList = new StringList();

  if(sExternalProjectUserSubRoles!=null && !"null".equals(sExternalProjectUserSubRoles))
  {
    externalProjectUserSubRolesList = FrameworkUtil.split(sExternalProjectUserSubRoles,",");  
  }
  
  boolean isProjectUser = false;
  boolean isExternalProjectUser = false;


  // Need the user name in order to add a person.
  if (loginName == null || "null".equals(loginName)) 
  {
    throw new MatrixException(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Create.People.UserName"));
  }

  // Need the company id in order to add a person.
  if (companyName == null || "null".equals(companyName)) 
  {
    throw new MatrixException(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Create.People.NeedCompanyID"));
  }
  BusinessObject busCompany = new BusinessObject(companyName);
  busCompany.open(context);
   String companyId = busCompany.getObjectId(context);

  /*
   * Try opening the admin person.  If it works, the person exists, so error.
   * If it fails, then the person doesn't exist, so create the person.
   */
  //BusinessObject busPerson = new BusinessObject (strPersonType, loginName, "-", strVault );

  String strRoles   = "";
  String strGroups  = "";
  String sGrpAlias  = "";
  String sRoleAlias = "";
  
  boolean addBasicUserRole = false;
  
  // to have Project Role values in member relationship between person and businessunit (for Org Roles).
  StringList strListOfRoles = new StringList();
    StringList roleList = new StringList();
  String rolesRequireGroupPerCompany = EnoviaResourceBundle.getProperty(context,"emxComponents.rolesRequireGroupPerCompany");

  
  //boolean isExists = false;
  //if ( isExists )
  if(com.matrixone.apps.common.Person.doesPersonExists(context,loginName))
  {

%>
    <script language="javascript">
      alert("<%=XSSUtil.encodeForJavaScript(context, ComponentsUtil.i18nStringNow("emxComponents.AddPerson.PersonAlreadyExists", request.getHeader("Accept-Language")))%>");
      parent.window.getWindowOpener().location.reload();
      window.closeWindow();
    </script>
<%
    return;
  }
  else 
  {
    String strRole[] = emxGetParameterValues(request, "chkRole");
    String strGroup[] = emxGetParameterValues(request, "chkGroup");

    if(Company.getHostCompany(context).equals(companyName))
    {
        strRoles = employeeSymbolicName;
        strListOfRoles.addElement(strRoles);
    }
    else{
		//Bug :315060 
     	//Purpose: If Subsidiary then person should get the Employee Role
     	//Start
        DomainObject busSubsidiary 	= new DomainObject(companyName);
		String parentCompanyName = (String)busSubsidiary.getInfo(context, "to["+DomainObject.RELATIONSHIP_SUBSIDIARY+"].from.id");

	    if(parentCompanyName != null && Company.getHostCompany(context).equals(parentCompanyName)){
	        strRoles = employeeSymbolicName;
	        strListOfRoles.addElement(strRoles);
	    }
         //End for Bug:315060
     }
    

    if (strRole != null) 
    {
      for(int i = 0; i < strRole.length; i++) {
        String sRole = strRole[i].trim();
        
        if(sRole.equals(strExchangeUserRole) || ComponentsUtil.isChildRole(context, strExchangeUserRole, sRole)){
        	addBasicUserRole = true;
        }
        
        sRoleAlias = FrameworkUtil.getAliasForAdmin(context, "role", sRole, true);
        if(UIUtil.isNotNullAndNotEmpty(sRoleAlias)) {
        if(!isProjectUser && projectUserSubRolesList.contains(sRoleAlias)) {
            isProjectUser = true;
            strRoles += " " + strProjectUserAlias;
            strListOfRoles.addElement(strProjectUserAlias);
        }
        
        if(!isExternalProjectUser && externalProjectUserSubRolesList.contains(sRoleAlias)) {
            isExternalProjectUser = true;
            strRoles += " " + strExternalProjectUserAlias;
            strListOfRoles.addElement(strExternalProjectUserAlias);
        }        
        
        if( rolesRequireGroupPerCompany.indexOf(sRole) > -1 ) {
            roleList.add(sRole);
        }
        
        strRoles += " " + sRoleAlias;        
        strListOfRoles.addElement(sRoleAlias);
      }
      
    }
    
    }
    
    // No role is added in case of person created in host company, then add 'Basic User' role 
    if(strRoles.trim().equals(employeeSymbolicName)){
    	addBasicUserRole = true;
    }
    
    if(strGroup != null)
    {
        for(int i = 0 ; i < strGroup.length; i++)
        {
            sGrpAlias =  FrameworkUtil.getAliasForAdmin(context, "group", strGroup[i].trim(), true);
            strGroups += " " + sGrpAlias;
        }
    }
  }

  	// To check if no other roles or only Exchange User roles or its child roles are selected then add "Basic User" role.    	
  	if(addBasicUserRole){
  		String basicUserRole = FrameworkUtil.getAliasForAdmin(context, "role", strBasicUserRole, true);
  		strRoles += " " + basicUserRole;
        strListOfRoles.addElement(basicUserRole);
  	}

  	Integer licHours = Integer.parseInt(licensedHours);
  	if(licHours>0){
  		licensedHours = "40";
  	}
  	
  	// Use the utility function to create the person, with the employee role.
  strPersonId = JSPUtil.createPersonInCompanyVault(context,session, loginName, password, strRoles, strGroups, emailAddress, strVault);
   	
   ComponentsUtil.assignPersonToGroups(context, companyId, loginName, roleList);

    // If the new person id is blank, then it wasn't created, so error.
    if ( "".equals(strPersonId) ) 
    {
      String sErrMsg = (String)session.getValue("error.message");
      session.removeValue("error.message");
      if ((sErrMsg == null) || (sErrMsg.equals("null")) || (sErrMsg.equals("")))
      {
        sErrMsg = ComponentsUtil.i18nStringNow("emxComponents.AddPerson.NotCreated", request.getHeader("Accept-Language"));
      }
      throw new MatrixException(sErrMsg);
    }

    AttributeList attrListPerson = new AttributeList();
    attrListPerson.add( new Attribute( new AttributeType(strFirstNameAttr)  , firstName ) );
    attrListPerson.add( new Attribute( new AttributeType(strMiddleNameAttr)  , middleName ) );
    attrListPerson.add( new Attribute( new AttributeType(strLastNameAttr)  , lastName ) );
    attrListPerson.add( new Attribute( new AttributeType(DomainObject.ATTRIBUTE_LICENSED_HOURS)  , licensedHours ) );
    attrListPerson.add( new Attribute( new AttributeType(strWorkPhoneNumberAttr)  , workPhoneNumber ) );
    attrListPerson.add( new Attribute( new AttributeType(strHomePhoneNumberAttr)  , homePhoneNumber ) );
    attrListPerson.add( new Attribute( new AttributeType(strPagerNumberAttr)  , pagerNumber) );
    attrListPerson.add( new Attribute( new AttributeType(strFaxNumberAttr)  , faxNumber ) );
    attrListPerson.add( new Attribute( new AttributeType(strEmailAddressAttr)  , emailAddress ) );
    attrListPerson.add( new Attribute( new AttributeType(strWebSiteAttr)  , webSite ) );
    attrListPerson.add( new Attribute( new AttributeType(strLoginTypeAttr)  , strLoginType ) );
    attrListPerson.add( new Attribute( new AttributeType(strHostMeetingsAttr)  , strHostMeetings ) );
    attrListPerson.add( new Attribute( new AttributeType(strAddressAttr)  , strAddress ) );
    attrListPerson.add( new Attribute( new AttributeType(strCityAttr)  , strCity ) );
    attrListPerson.add( new Attribute( new AttributeType(strStateRegionAttr)  , strStateRegion ) );
    attrListPerson.add( new Attribute( new AttributeType(strPostalCodeAttr)  , strPostalCode ) );
    attrListPerson.add( new Attribute( new AttributeType(strCountryAttr)  , strCountry ) );
    //Added for Organization Person Feature
    attrListPerson.add( new Attribute( new AttributeType(strMailCodeAttr)  , strMailCode ) );
    attrListPerson.add( new Attribute( new AttributeType(strTitleAttr)  , strTitle ) );
    //End

    double tz = (new Double((String)session.getValue("timeZone"))).doubleValue();
	String strStartInputTime = "00:00:00 AM";
	String strEndInputTime = "11:59:59 PM";
    if(strAbsenceStartDate != null && !"".equals(strAbsenceStartDate) && !"null".equals(strAbsenceStartDate))
    {
        strAbsenceStartDate = eMatrixDateFormat.getFormattedInputDateTime(context,strAbsenceStartDate,strStartInputTime,tz,request.getLocale());
    }
    if(strAbsenceEndDate != null && !"".equals(strAbsenceEndDate) && !"null".equals(strAbsenceEndDate))
    {
        strAbsenceEndDate = eMatrixDateFormat.getFormattedInputDateTime(context,strAbsenceEndDate,strEndInputTime,tz,request.getLocale());
    }    
    attrListPerson.add( new Attribute( new AttributeType(strAbsenceStartDateAttr)  , strAbsenceStartDate ) );
    attrListPerson.add( new Attribute( new AttributeType(strAbsenceEndDateAttr)  , strAbsenceEndDate ) );
    attrListPerson.add( new Attribute( new AttributeType(strAbsenceDelegateAttr)  , strAbsenceDelegate ) );

    if(strDateFormat != null && !"None".equals(strDateFormat) && !"null".equals(strDateFormat))
    {
        strDateFormat = strDateFormat.trim();
        com.matrixone.apps.common.Person.setExportImportDateFormat(context, loginName, strDateFormat);
    }
    
    if(strListSeparator != null && !"None".equals(strListSeparator) && !"null".equals(strListSeparator))
    {
        strListSeparator = strListSeparator.trim();
        com.matrixone.apps.common.Person.setExportImportDelimiter(context, loginName, strListSeparator);
    }

    // Get the person business object from the person id.
    BusinessObject busPerson = new BusinessObject(strPersonId);
    busPerson.open(context);

    // Modify the business object's attributes and catch errors.
    busPerson.setAttributes( context , attrListPerson);
    busPerson.connect(context, new RelationshipType(strEmployeeRel),false, busCompany);

    // get the member relationship id between the person and the company
    StringList strList = new StringList();
    strList.addElement("to["+DomainObject.RELATIONSHIP_MEMBER+"].id");    
    BusinessObjectWithSelect busWithSelect = busPerson.select(context,strList);
    String strMemberRelId = busWithSelect.getSelectData("to["+DomainObject.RELATIONSHIP_MEMBER+"].id");

    /*
     * Update the person's business unit.
     */

    // If a new business unit object was selected, then connect it.
    if (strBusinessUnit != null && !"null".equals(strBusinessUnit) && ! "".equals(strBusinessUnit)) 
    {
      busPerson.connect(context, new RelationshipType(strBusinessUnitEmployeeRel),false, new BusinessObject(strBusinessUnit));
      Relationship rel = busPerson.connect(context, new RelationshipType(strMemberRel),false, new BusinessObject(strBusinessUnit));
      String strMemberRelIdBusUnit = rel.toString();
      // setting the Project Role attribute value on Member Relationship between person and business unit
      if(strListOfRoles.size() > 0)
      {
        AttributeUtil.setAttributeList(context
                                      ,new DomainRelationship(strMemberRelIdBusUnit)
                                      ,DomainObject.ATTRIBUTE_PROJECT_ROLE
                                      ,strListOfRoles
                                      ,false
                                      ,
                                      "~");
      }
      // to check which Person node is selected (Business Unit or Company). If condition returns false
      // then by default "Company" node is selected. If condition is true then setting the strMemberRelId
      // to the member rel id between person and business unit
      if(strBusinessUnit.equals(strObjectId))
      {
        strMemberRelId = strMemberRelIdBusUnit;
      }
    }

    // Set the Site
    Person doPerson = new Person(busPerson);
    if (strSite == null || "null".equalsIgnoreCase(strSite) || "None".equalsIgnoreCase(strSite))
    {
       strSite = "";
    }
    doPerson.setSite(context, strSite);
    
    /*
    * Update the person's workplace location.
    */

    // If a new Location object was selected, then connect it.
    if (location != null && ! "null".equals(location) && ! "".equals(location)) 
    {
      busPerson.connect(context, new RelationshipType(strWorkPlaceRel),true, new BusinessObject(location));
    }

    /*
    *  If Company Representative role is removed, then remove the value for strCompanyRep
    */
    if(strRoles.indexOf(strCompanyRepresentativeAlias) == -1)
    {
        strCompanyRep = "";
    }

    /*
    * If Company Rep is selected, then attach the Company or Business Unit with the person with
    * Company Representative relation
    */
    String busId = "";
    if ( strCompanyType.equals(strCompanyRep) )
    {
      busId = companyName;
    }
    else if ( strBusinessUnitType.equals(strCompanyRep) ) 
    {
      busId = strBusinessUnit;
    }
    if (busId != null && !"".equals(busId)) 
    {
      //Connecting person for first time to an organization as a company representative
      BusinessObject busCompanyOrBU = new BusinessObject(busId);
      busPerson.connect(context, new RelationshipType(strCompanyRepresentativeRel),false, new BusinessObject(busId));
    }
    
    /*
    *  set the IconMailLanguagePreference for the person
    */
    //Added and condition for kernel check for VPM Icon Mail preference issue
    if(strLanguagePref != null && !"None".equals(strLanguagePref) && !"".equals(strLanguagePref) && !"null".equals(strLanguagePref) && !"kernel".equalsIgnoreCase(strLanguagePref))
    {
        new Person(busPerson).setLanguagePreference(context, busPerson.getName(), strLanguagePref);
		PropertyUtil.setAdminProperty(context, Person.personAdminType, busPerson.getName(), PersonUtil.PREFERENCE_ICON_MAIL_LANGUAGE, strLanguagePref);
    }
    
    /*
    * to set the viewer preference
    */

    FormatUtil formatUtil = new FormatUtil();

    String formatsStr = null;
    try
    {
        formatsStr = EnoviaResourceBundle.getProperty(context,"emxFramework.FormatsWithViewerPreference");
    }
    catch (Exception ex) { }

    if( formatsStr != null )
    {
      StringTokenizer formatsTokenizer = new StringTokenizer(formatsStr,",");
      String formatToken = "";
      String format = "";
      String requestParameter =  "";
      String requestParameterValue = "";

      while(formatsTokenizer.hasMoreTokens())
      {
        formatToken = (String)formatsTokenizer.nextToken();
        format = PropertyUtil.getSchemaProperty(context, formatToken );

        if( format != null && !"".equals(format))
        {
          formatUtil.setFormatName( formatToken );

          requestParameter =  format + "viewerPreference";
          requestParameterValue = emxGetParameter(request, requestParameter);

          if(requestParameterValue != null && !"null".equals(requestParameterValue) && !"".equals(requestParameterValue) && !"None".equals(requestParameterValue))
          {
             formatUtil.setViewerPreference( context, loginName, requestParameterValue);
          }
        }
      }
    }

    /*
    * promote the person to Active state
    */
    if(!DomainConstants.STATE_PERSON_ACTIVE.equals(doPerson.getInfo(context, DomainConstants.SELECT_CURRENT))){
    busPerson.promote(context);
    }

    //Assign CSV license if it is not assigned already
  String sPersonName =   busPerson.getName();
  String strPersonCommand = "print product $1 select $2 dump $3";
		String strPersonResult = MqlUtil.mqlCommand(context, strPersonCommand, true, "CSV", "person", "|");
		StringList strResultList = FrameworkUtil.split(strPersonResult,"|");
		if(!strResultList.contains(sPersonName) && Integer.parseInt(licensedHours) == 0){  
			String strUserCommand = "modify product $1 add $2 $3";
			MqlUtil.mqlCommand(context, strUserCommand, true, "CSV", "person", sPersonName);
		}
	
    // Determine if we are a host rep.
    boolean isHostRep = Company.isHostRep(context, busPerson);
  
    // Get the company we represent.
    BusinessObject busRepOrg = Company.getCompanyForRep(context,busPerson);
  
    // Determine if we are a company rep.
    boolean isCompanyRep = (busRepOrg != null);
  
    // find the User Role
    String userRole = null;
    if (isHostRep){
      userRole = "hostRep";
    }else if (!isHostRep && isCompanyRep){
      userRole = "nonHostRep";
    }else{
      userRole = "user";
    }
    String actionURL =  "../common/emxTree.jsp?mode=insert&AppendParameters=true&emxSuiteDirectory=" + appDirectory + "&objectId=" + strPersonId + "&relId=" + strMemberRelId;
    
    busPerson.close(context);
   
%>    
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%
    if ( meetingUsername != null && !"".equals(meetingUsername) && !"null".equals(meetingUsername) ) 
    {
%>  
       <form name="personForm" method="post" action="emxComponentsCreateMeetingId.jsp">
       <input type= hidden  name="personId" value="<xss:encodeForHTMLAttribute><%=strPersonId%></xss:encodeForHTMLAttribute>"/>
       <input type= hidden  name="projectId" value=""/>
       <!-- //XSSOK -->
       <input type="hidden" name="userRole" value="<%=userRole%>"/>
       <input type="hidden" name="meetingUsername" value="<xss:encodeForHTMLAttribute><%=meetingUsername%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="meetingPassword" value="<xss:encodeForHTMLAttribute><%=meetingPassword%></xss:encodeForHTMLAttribute>"/>
       <input type= hidden  name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
       <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
       <input type= hidden  name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>"/>
       <input type= hidden  name="fromPage" value="CreatePeople"/>
     </form>
     <script language="javascript">
       document.personForm.submit();
     </script>
<%
    }
    else 
    {
%>  
     <script language="javascript">
      //var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content"); 
      //frameContent.document.location.href = frameContent.document.location.href;
      //XSSOK
      loadTreeNode("<%=strPersonId%>", null, null, "<%=appDirectory%>", true, "<%=actionURL%>");
       getTopWindow().closeWindow();
    </script>
<%
  }
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

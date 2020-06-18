<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreatePeopleDialog.jsp.rca 1.29 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $
--%>
<%@page import="javax.json.JsonObject"%>
<%@include file = "emxCalendarInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<%@ include file = "../emxJSValidation.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

  String keyPerson = emxGetParameter(request,"keyPerson");

  // Load lookup strings.
  String strCompanyType             = PropertyUtil.getSchemaProperty(context, "type_Company");
  String strOrganizationType        = PropertyUtil.getSchemaProperty(context, "type_Organization");
  String strBusinessUnitType        = PropertyUtil.getSchemaProperty(context, "type_BusinessUnit");
  String strLocationType            = PropertyUtil.getSchemaProperty(context, "type_Location");
  String strDivisionRel             = PropertyUtil.getSchemaProperty(context, "relationship_Division");
  String strLocationRel             = PropertyUtil.getSchemaProperty(context, "relationship_OrganizationLocation");
  String strLoginTypeAttr           = PropertyUtil.getSchemaProperty(context, "attribute_LoginType");
  String strPersonType              = PropertyUtil.getSchemaProperty(context, "type_Person");
  String strCompanyRepresentative   = PropertyUtil.getSchemaProperty(context, "role_CompanyRepresentative");
  String attrCountry                = PropertyUtil.getSchemaProperty(context, "attribute_Country");

  String sRoleList        = (String)formBean.getElementValue("roleList");
  if (sRoleList == null || "null".equals(sRoleList)){
    sRoleList="";
  }
  String sGroupList       = (String)formBean.getElementValue("groupList");
  if(sGroupList == null || "null".equals(sGroupList)){
    sGroupList = "";
  }

  String loginName        = (String)formBean.getElementValue("loginName");
  String password         = (String)formBean.getElementValue("password");
  String confirmpassword  = (String)formBean.getElementValue("confirmpassword");
  String firstName        = (String)formBean.getElementValue("firstName");
  String middleName       = (String)formBean.getElementValue("middleName");
  String lastName         = (String)formBean.getElementValue("lastName");
  String licensedHours    = (String)formBean.getElementValue("licensedHours");
  String location         = (String)formBean.getElementValue("location");
  String strCompanyRep    = (String)formBean.getElementValue("companyrep");
  String workPhoneNumber  = (String)formBean.getElementValue("workPhoneNumber");
  String homePhoneNumber  = (String)formBean.getElementValue("homePhoneNumber");
  String pagerNumber      = (String)formBean.getElementValue("pagerNumber");
  String emailAddress     = (String)formBean.getElementValue("emailAddress");
  String faxNumber        = (String)formBean.getElementValue("faxNumber");
  String webSite          = (String)formBean.getElementValue("webSite");
  String strBusinessUnitId= (String)formBean.getElementValue("businessUnitId");
  String organizationId   = (String)formBean.getElementValue("objectId");
  String meetingUsername  = (String)formBean.getElementValue("meetingUsername");
  String meetingPassword  = (String)formBean.getElementValue("meetingPassword");
  String strHostMeetings  = (String)formBean.getElementValue("hostMeetings");
  String strVault         = (String)formBean.getElementValue("Vault");
  String strAddress       = (String)formBean.getElementValue("address");
  String strCity          = (String)formBean.getElementValue("city");
  String strStateRegion   = (String)formBean.getElementValue("stateRegion");
  String strPostalCode    = (String)formBean.getElementValue("postalCode");
  String strCountry       = (String)formBean.getElementValue(attrCountry);
  String strDateFormat    = (String)formBean.getElementValue("dateFormat");
  //Added for Organization Person Feature
  String strMailCode      = (String)formBean.getElementValue("mailCode");
  String strTitle         = (String)formBean.getElementValue("title");
  //End
  String strListSeparator = (String)formBean.getElementValue("listSeparator");
  String strSiteValue     = (String)formBean.getElementValue("Site");
  String vaultAwareness ="true";
  String requiredClass ="label";
  //Error message for string length
  String errMessage=EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Create.NameColumn");
  String fullNameErrMessage=EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.Create.FullName");
		  
  String primaryVault= "";

  vaultAwareness=JSPUtil.getApplicationProperty(context,application,"eServiceSuiteComponents.VaultAwareness","emxComponentsProperties");
  requiredClass=(vaultAwareness.equals("true"))?"label":"labelRequired";

  String strLoginTypeDefaultValue = "Standard";

  if( meetingUsername == null || meetingUsername.equals("null")) {
    meetingUsername="";
  }

  if( meetingPassword == null || meetingPassword.equals("null")) {
    meetingPassword="";
  }

  if( strBusinessUnitId == null || strBusinessUnitId.equals("null")) {
    strBusinessUnitId="";
  }

  if(loginName == null || loginName.equals("null")) {
    loginName = "";
  }
  if(password == null || password.equals("null")) {
    password = "";
  }
  if(confirmpassword == null || confirmpassword.equals("null")) {
    confirmpassword = "";
  }

  if(firstName == null || firstName.equals("null")) {
    firstName = "";
  }
  if(lastName == null || lastName.equals("null")) {
      lastName = "";
  }

  if(middleName == null || middleName.equals("null")) {
    middleName = "";
  }

  if(strVault == null || strVault.equals("null")) {
    strVault = "";
  }

  if(strSiteValue == null || strSiteValue.equals("null") || "None".equalsIgnoreCase(strSiteValue)) {
    strSiteValue = "";
  }

  if(organizationId == null || organizationId.equals("null")|| organizationId.equals(""))
  {
    BusinessObject personObject = Person.getPerson(context);
    BusinessObject boOrganization = Company.getCompanyForRep(context,personObject);
    if (boOrganization != null)
    {
      boOrganization.open(context);
      organizationId = boOrganization.getObjectId();
      boOrganization.close(context);
    }
    else
    {
%>
        <emxUtil:i18n localize = "i18nId">emxComponents.Administration.NoAccess</emxUtil:i18n>
<%
        return;
    }
  }

  if(location == null || location.equals("null"))
  {
    location = "";
  }
  if(strCompanyRep == null || "null".equals(strCompanyRep))
  {
    strCompanyRep = "";
  }

  if(workPhoneNumber == null || workPhoneNumber.equals("null"))
  {
    workPhoneNumber = "";
  }

  if(homePhoneNumber == null || homePhoneNumber.equals("null")) {
    homePhoneNumber = "";
  }

  if(pagerNumber == null || pagerNumber.equals("null")) {
    pagerNumber = "";
  }

  if(emailAddress == null || emailAddress.equals("null")) {
    emailAddress = "";
  }

  if(faxNumber == null || faxNumber.equals("null")) {
    faxNumber = "";
  }

  if(webSite == null || webSite.equals("null")) {
    webSite = "";
  }

  if(strAddress == null || strAddress.equals("null")) {
    strAddress = "";
  }

  if(strCity == null || strCity.equals("null")) {
    strCity = "";
  }

  if(strStateRegion == null || strStateRegion.equals("null")) {
    strStateRegion = "";
  }

  if(strPostalCode == null || strPostalCode.equals("null")) {
    strPostalCode = "";
  }

  if(strCountry == null || strCountry.equals("null")) {
    strCountry = "";
  }
  //Added for Organization Person Feature
   if(strMailCode == null || strMailCode.equals("null")) {
    strMailCode = "";
  } 
   if(strTitle == null || strTitle.equals("null")) {
    strTitle = "";
  }
  //End
  if(strDateFormat == null || strDateFormat.equals("null")) {
    strDateFormat = "None";
  }
  if(strListSeparator == null || strListSeparator.equals("null")) {
    strListSeparator = "None";
  }

  String companyName    = organizationId;
  boolean isBusUnitOnly = false;
  String strBusUnitName = "";

  BusinessObject busCompany = new BusinessObject(organizationId);
  Pattern relPattern = new Pattern ( strDivisionRel );
  Pattern typePattern = new Pattern ( strCompanyType );

  busCompany.open(context);
  String sTypeName = busCompany.getTypeName();
  String sCompName = busCompany.getName();
  busCompany.close(context);

  if(sTypeName.equals(strBusinessUnitType))
  {
    strBusinessUnitId = organizationId ;
    strBusUnitName = sCompName;

    StringList strList = new StringList();
    strList.addElement("to["+strDivisionRel+"].from.id");
    strList.addElement("to["+strDivisionRel+"].from.type");

    String strObjId = "";
    BusinessObjectWithSelect busWithSelect = null;

    while(sTypeName.equals(strBusinessUnitType))
    {
        busWithSelect = busCompany.select(context,strList);
        sTypeName = busWithSelect.getSelectData("to["+strDivisionRel+"].from.type");
        strObjId = busWithSelect.getSelectData("to["+strDivisionRel+"].from.id");
        busCompany = new BusinessObject(strObjId);
    }
    companyName = strObjId;
    isBusUnitOnly = true;
  }

  Pattern patternType = new Pattern ( strOrganizationType );
  patternType.addPattern(strLocationType);

  Pattern patternRel = new Pattern ( strLocationRel );
  patternRel.addPattern(strDivisionRel);
  SelectList selListType = new SelectList();
  selListType.addName();
  selListType.addId();
  selListType.addCurrentState();
  SelectList selListRel = new SelectList();

  StringList strListBUIds = new StringList();
  StringList strListBUNames = new StringList();
  StringList strListLocationNames = new StringList();
  StringList strListLocationIds = new StringList();
  StringList strListLocationStates = new StringList();
  
  busCompany.open(context);
  
  Hashtable hashTypeData = null;

  ExpansionWithSelect expWSelectCompanyDetails = busCompany.expandSelect(context, patternRel.getPattern(), patternType.getPattern(), selListType, selListRel, false, true, (short)0);
  RelationshipWithSelectItr relWSelectItrCompany = new RelationshipWithSelectItr(expWSelectCompanyDetails.getRelationships());
  while (relWSelectItrCompany.next())
  {
    RelationshipWithSelect relWSelectPerson = relWSelectItrCompany.obj();
    if (strLocationRel.equals(relWSelectPerson.getTypeName()) )
    {
      hashTypeData = relWSelectPerson.getTargetData();
      strListLocationIds.addElement((String)hashTypeData.get(DomainObject.SELECT_ID));
      strListLocationNames.addElement((String)hashTypeData.get(DomainObject.SELECT_NAME));
	  strListLocationStates.addElement((String)hashTypeData.get(DomainObject.SELECT_CURRENT));
      
    }
    else if ( strDivisionRel.equals(relWSelectPerson.getTypeName()) )
    {
      hashTypeData = relWSelectPerson.getTargetData();
      strListBUIds.addElement((String)hashTypeData.get(DomainObject.SELECT_ID));
      strListBUNames.addElement((String)hashTypeData.get(DomainObject.SELECT_NAME));
    }
  }

  String strcompanyName = busCompany.getName();

  primaryVault = busCompany.getVault();
  String secondaryVaults = new Company(companyName).getSecondaryVaults(context);
  StringList vaultList = FrameworkUtil.split(secondaryVaults,",");
  Iterator itr = vaultList.iterator();

  busCompany.close(context);

  /*
   * Determine the current user's privileges (not the person being edited).
   */

  // Get the current person from the context.
  BusinessObject busLoggedPerson = JSPUtil.getPerson(context,session);
  busLoggedPerson.open(context);

  boolean isHostRep = Company.isHostRep(context, busLoggedPerson);
  boolean isCompanyRep = false;
  boolean isRep = false;

  // Get the company we represent.

  BusinessObject busLoggedRep = Company.getCompanyForRep(context, busLoggedPerson);
  
  busLoggedPerson.close(context);

  // Determine if we are a company rep.
  if ( busLoggedRep != null )
  {
      isCompanyRep = true;
  }

  if ( isHostRep || isCompanyRep )
  {
    isRep = true;
  }

  String languageStr = request.getHeader("Accept-Language");

  //Get the list of Sites
  MQLCommand cmd = new MQLCommand();
  cmd.open(context);
  cmd.executeCommand(context, "list site");
  String sResult = cmd.getResult();  
  cmd.close(context);
  StringTokenizer siteToken = new StringTokenizer(sResult, "\n");
  
  

%>
<script language="javascript" type="text/javascript" src ="../common/scripts/emxUICalendar.js"></script>
<script language = javascript>

  var typeComp      = "<%=XSSUtil.encodeForHTML(context, (String)strCompanyType)%>";
  var typeBusUnit   = "<%=XSSUtil.encodeForHTML(context, (String)strBusinessUnitType)%>";
  var CompRep       = "<%=XSSUtil.encodeForHTML(context, (String)strCompanyRepresentative)%>";

  function removeCompRep()
  {
    rolelistvalue = document.CreatePeople.roleList.value;
    selVal = document.CreatePeople.companyrep.options[document.CreatePeople.companyrep.selectedIndex].value;
    if(selVal == "" && rolelistvalue.indexOf(CompRep) != -1)
    {
        rolelistvalue = rolelistvalue.replace(CompRep,"");
        document.CreatePeople.roleList.value=rolelistvalue;
    }
  }

  function trimval(str)
  {
    while(str.length != 0 && str.substring(0,1) == ' '){
      str = str.substring(1);
    }
    while(str.length != 0 && str.substring(str.length -1) == ' '){
      str = str.substring(0, str.length -1);
    }
    return str;
  }

  function validateDate()
  {

     var date1 = new Date();
     date1.setTime(document.CreatePeople.AbsenceStartDate_msvalue.value);
     var date2 = new Date();
     date2.setTime(document.CreatePeople.AbsenceEndDate_msvalue.value);
     
     var temptoday = new Date();
     //converting JS date to a date1 & date 2 format.
     var today = new Date((temptoday.getMonth()+1)+"/"+temptoday.getDate()+"/"+temptoday.getFullYear());

    //  Addressing  Y2K.
     if (today.getFullYear()< 1950)
     {
       // add 100 years.
        today.setFullYear(date1.getFullYear() + 100);
     }
     if (date1.getFullYear()< 1950)
     {
       // add 100 years.
        date1.setFullYear(date1.getFullYear() + 100);
     }
     if (date2.getFullYear()< 1950)
     {
       // add 100 years.
        date2.setFullYear(date2.getFullYear() + 100);
     }
      // comparing the dates
      if(Date.parse(date1.toGMTString()) >= Date.parse(today.toGMTString()))
      {
          if ( Date.parse(date1.toGMTString()) > Date.parse(date2.toGMTString()))
          {
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PersonDialog.EndDateAlert</emxUtil:i18nScript>");
             return false;

          }else{
             return true;
          }
      }
      else
      {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PersonDialog.StartDateAlert</emxUtil:i18nScript>");
         return false;
      }
  }
  //checks whether AbsenceStartDate, AbsenceEndDate, Delegate person fields has values or not.
  function hasAllValue()
  {
      var startDate = document.CreatePeople.AbsenceStartDate.value;
      var endDate   = document.CreatePeople.AbsenceEndDate.value;
      var person    = document.CreatePeople.person.value;
      if(trimval(startDate)== "" || trimval(endDate) == "" || trimval(person) == "")
      {
        if (trimval(startDate)== "" && trimval(endDate) == "" && trimval(person) == "")
        {
          return true;
        }
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PersonDialog.ValueMissAlert</emxUtil:i18nScript>");
          return false;
      }
      else
      {
          return validateDate();
      }

  }

  function submitForm() {

    // Create an alias for the form.
    var CreatePeople = document.CreatePeople;
    CreatePeople.loginName.value = trimval (CreatePeople.loginName.value);
    CreatePeople.firstName.value = trimval (CreatePeople.firstName.value);
    CreatePeople.middleName.value=trimval (CreatePeople.middleName.value);
    CreatePeople.lastName.value = trimval (CreatePeople.lastName.value);
    CreatePeople.licensedHours.value = trimval (CreatePeople.licensedHours.value);    
    CreatePeople.workPhoneNumber.value = trimval ( CreatePeople.workPhoneNumber.value);
    CreatePeople.emailAddress.value = trimval( CreatePeople.emailAddress.value);
    CreatePeople.password.value = trimval( CreatePeople.password.value);
    CreatePeople.webSite.value = trimval( CreatePeople.webSite.value);

    var loginNameBadChars = checkForNameBadCharsList(CreatePeople.loginName);
    var firstNameBadChars = checkForNameBadCharsList(CreatePeople.firstName);
    var lastNameBadChars = checkForNameBadCharsList(CreatePeople.lastName);
    var middleNameBadChars = checkForNameBadCharsList(CreatePeople.middleName);
    var loginNameLengthCheck= checkValidUserNameLength(CreatePeople.loginName.value);
    var validNameLengthCheck=checkValidLength(CreatePeople.firstName.value+CreatePeople.middleName.value+CreatePeople.lastName.value);
  
   

    if (loginNameBadChars.length != 0) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
      CreatePeople.loginName.focus();
      return;
    }else if(!(loginNameLengthCheck))
    	{
    	alert("<%=errMessage%>");
        CreatePeople.loginName.focus();
        return;
    	}
    else if (CreatePeople.loginName.value == "" ) {
      CreatePeople.loginName.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.LoginNameRequired</emxUtil:i18nScript>");
      return;
    } else if ( CreatePeople.password.value == "" ) {
      CreatePeople.password.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.PasswordRequired</emxUtil:i18nScript>");
      return;
    }
    else if ( CreatePeople.confirmpassword.value == "" ) {
      CreatePeople.confirmpassword.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.ConfirmpwRequired</emxUtil:i18nScript>");
      return;
    } else if ( CreatePeople.confirmpassword.value != CreatePeople.password.value  ) {
      CreatePeople.confirmpassword.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.PasswordNotMatch</emxUtil:i18nScript>");
      return;
    } else if (firstNameBadChars.length != 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
        CreatePeople.firstName.focus();
        return;
    } else if ( CreatePeople.firstName.value == "" ) {
      CreatePeople.firstName.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.FirstNameRequired</emxUtil:i18nScript>");
      return;
    } 
    else if(!(validNameLengthCheck))
	{
    	 CreatePeople.firstName.focus();
    	 alert("<%=fullNameErrMessage%>");
         return;
	} 
    else if (middleNameBadChars.length != 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
        CreatePeople.middleName.focus();
        return;
    } 
    
    else if (lastNameBadChars.length != 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
        CreatePeople.lastName.focus();
        return;
    } 
    
    else if ( CreatePeople.lastName.value == "" ) {
      CreatePeople.lastName.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.LastNameRequired</emxUtil:i18nScript>");
      return;
    }else if(CreatePeople.licensedHours.value != parseInt(CreatePeople.licensedHours.value, 10)){
    	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidLicensedHours</emxUtil:i18nScript>");
       	CreatePeople.licensedHours.focus();
    	return;
    }
   
    else if (CreatePeople.emailAddress.value == ""){
      CreatePeople.emailAddress.focus();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.EmailAddressRequired</emxUtil:i18nScript>");
      return;
     } else if (CreatePeople.emailAddress.value.indexOf("@") < 0 ||  
				CreatePeople.emailAddress.value.lastIndexOf(".") < CreatePeople.emailAddress.value.indexOf("@") ) {
      CreatePeople.emailAddress.focus();
      CreatePeople.emailAddress.select();
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.InvalidEmail</emxUtil:i18nScript>");
      return;
    } else if (!checkemail()){
     CreatePeople.emailAddress.focus();
	  alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.validEmailId</emxUtil:i18nScript>");
     return;
    } else {
        if(hasAllValue()) {
		  var namebadCharactersMailCode = checkForNameBadCharsList(document.CreatePeople.mailCode);
		  if(namebadCharactersMailCode.length != 0) {
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharactersMailCode);
			return;
		  }
		  var namebadCharactersTitle = checkForNameBadCharsList(document.CreatePeople.title);
		  if(namebadCharactersTitle.length != 0) {
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharactersTitle);
			return;
		  }
        CreatePeople.action =  "emxComponentsPeopleRoleSummaryFS.jsp";
        CreatePeople.submit();
      }
      return;
    }

  }

  function closeWindow()
  {
    getTopWindow().location.href="emxComponentsCreatePeopleDialogClose.jsp?keyPerson=<%=XSSUtil.encodeForURL(context, keyPerson)%>";
  }

  function reload () {
    var CreatePeople = document.CreatePeople;
    CreatePeople.action= "emxComponentsCreatePeopleDialogFS.jsp";
    CreatePeople.submit();
  }

  function clearField(formName,fieldName,idName)
  {

    var operand = "document." + formName + "." + fieldName+".value = \"\";";
    eval (operand);
    if(idName != null){
        var operand1 = "document." + formName + "." + idName+".value = \"\";";
        eval (operand1);
    }
    return;
  }
 //<!--Added for the Bug No: 340487 09/06/2007 3:00 PM Start -->
 var testresults
function checkemail(){ 	
var str=document.CreatePeople.emailAddress.value
//IR-054638V6R2011x: Modified to allow apostrophe charecter in email id.           
//var filter=/^[a-zA-Z][\w\.-]*[a-zA-Z0-9]*@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]*\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
var filter=/^[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9']*@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]*\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
if (filter.test(str))
testresults=true
else{
testresults=false
}
return (testresults)
}
//<!--Ended for the Bug No: 340487 09/06/2007 3:00 PM End --> 

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="CreatePeople" method="post" action="" target="_parent" onSubmit="submitForm(); return false;">
<%
    formBean.setElementValue("roleList",sRoleList);
    formBean.setElementValue("groupList",sGroupList);
    formBean.setElementValue("objectId",organizationId);
%>

  <input type="hidden" name="roleList" value="<xss:encodeForHTMLAttribute><%=sRoleList%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="groupList" value="<xss:encodeForHTMLAttribute><%=sGroupList%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= organizationId %></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="keyPerson" value="<xss:encodeForHTMLAttribute><%=keyPerson%></xss:encodeForHTMLAttribute>" />

  <table>
    <tr>
      <td class="labelRequired"><label for="LoginName"><emxUtil:i18n localize="i18nId">emxComponents.Common.UserName</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <input type="text" size="30" name="loginName" value="<xss:encodeForHTMLAttribute><%=loginName%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="labelRequired"><label for="PassWord"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.PassWord</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <input type="password" size="30" name="password" value="<xss:encodeForHTMLAttribute><%=password%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="labelRequired"><label for="ConfirmPassWord"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.ConfirmPassWord</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <input type="password" size="30" name="confirmpassword" value="<xss:encodeForHTMLAttribute><%=confirmpassword%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="label"><label for="State"><emxUtil:i18n localize="i18nId">emxComponents.Common.State</emxUtil:i18n></label></td>
      <td class="inputField"><input type="text" name="State" id="State" value="<framework:i18n localize="i18nId">emxComponents.PersonDetails.Active</framework:i18n>" size="20" READONLY />&nbsp;</td>
    </tr>

    <tr>
      <td class="labelRequired"><label for="FirstName"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.FirstName</emxUtil:i18n></lable>&nbsp;</td>
      <td class="inputField">
        <input type="text" name="firstName" size="30" value="<xss:encodeForHTMLAttribute><%=firstName%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="label"><label for="MiddleName"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.MiddleName</emxUtil:i18n></label></td>
      <td class="inputField">
        <input type="text" name="middleName" size="30" value="<xss:encodeForHTMLAttribute><%=middleName%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="labelRequired"><label for="LastName"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.LastName</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <input type="text" name="lastName" size="30" value="<xss:encodeForHTMLAttribute><%=lastName%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="labelRequired"><label for="Company"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.CompanyName</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <img src="../common/images/iconCompany16.png" border="0" />
        <input type="hidden" name="companyName" value="<xss:encodeForHTMLAttribute><%= companyName %></xss:encodeForHTMLAttribute>"/>
<%
        formBean.setElementValue("companyName",companyName);
%>
        <%= XSSUtil.encodeForHTML(context, strcompanyName) %>
      </td>
    </tr>
    
    <tr>
      <td class="label"><label for="LicensedHours"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.LicensedHours</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <input type="text" name="licensedHours" size="10" value="0" />
      </td>
    </tr>

    <tr>
    	<td class="label"><label for="businessUnit"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.BusinessUnit</emxUtil:i18n></label>&nbsp;</td>
    	<td class="inputField">

<%
    // If this is add mode or we are a company rep, and a company
    // is selected and there is at least one business unit in the list,
    // then show the business units.
    	if ( !isBusUnitOnly && isRep &&  strListBUIds.size() > 0 ) {
      StringItr strItrBUIds = new StringItr (strListBUIds);
      StringItr strItrBUNames = new StringItr (strListBUNames);
%>
      <select name="businessUnit" size="1" >
        <option value=""></option>
<%
        // Loop through the sorted business unit names
        // and create the select options.
        String strBUName = "";
        String strBUId = "";
        String strSelected = "";
        	while (strItrBUIds.next() && strItrBUNames.next()) {
          strBUId       = (String) strItrBUIds.obj();
          strBUName     = (String) strItrBUNames.obj();
          strSelected   = strBUId.equals(strBusinessUnitId) ? "selected" : "";
%>
<%--//XSSOK--%>
          <option value="<%= XSSUtil.encodeForHTMLAttribute(context, (String)strBUId) %>" <%= strSelected %>><%= strBUName %></option>
<%
        }
%>
      </select>
<%
    } else if(!"".equals(strBusinessUnitId)) {
%>
      <img src="../common/images/iconBusinessUnit16.png" border="0" />
      <input type="hidden" name="businessUnit" value="<%=XSSUtil.encodeForHTMLAttribute(context, (String)strBusinessUnitId)%>"/>
<%
        formBean.setElementValue("businessUnit",strBusinessUnitId);
%>
      <%=XSSUtil.encodeForHTML(context, (String)strBusUnitName)%>
<%
    } else {
%>
        <input type="hidden" name="businessUnit" value=""/>
<%
        formBean.setElementValue("businessUnit","");
%>
      &nbsp;
<%
    }
%>
    </td>

  </tr>

    <tr>
  	<td class="label"><label for="Location"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.Location</emxUtil:i18n></label>&nbsp;</td>
    <td class="inputField">

<%
    // If this is add mode or we are a company rep, and a company
    // is selected and there is at least on location in the list,
    // then show the locations.

    if ( strListLocationIds.size() > 0 )
    {
      StringItr strItrLocationIds = new StringItr (strListLocationIds);
      StringItr strItrLocationNames = new StringItr (strListLocationNames);
      StringItr strItrLocationStates = new StringItr (strListLocationStates);
	  
%>
      <select name="location" size="1" >
        <option value="" "selected"></option>
<%
        // Loop through the sorted location names
        // and create the select options.
        String strLocationName = "";
        String strLocationId = "";
        String strLocationState = "";
         String stateActive = FrameworkUtil.lookupStateName(context, DomainConstants.POLICY_LOCATION, "state_Active");
        String strSelected = "";
        while (strItrLocationIds.next() && strItrLocationNames.next() && strItrLocationStates.next()) {
          strLocationId     = (String)strItrLocationIds.obj();
          strLocationName   = (String) strItrLocationNames.obj();
		  strLocationState   = (String) strItrLocationStates.obj();
          strSelected       = strLocationId.equals(location) ? "selected" : "";
		  if(stateActive.equals(strLocationState)){
%>
<%--//XSSOK--%>
          <option value="<%= XSSUtil.encodeForHTMLAttribute(context, (String)strLocationId) %>"<%=strSelected%>><%= XSSUtil.encodeForHTML(context, (String)strLocationName) %></option>
<%
		  }
        }
%>
      </select>
<%
    } else {
%>
        <input type="hidden" name="location" value=""/>
<%
        formBean.setElementValue("location","");
%>
      &nbsp;
<%
    }
%>
      </td>
    </tr>

<tr>
    <td class="label"><label for="CompanyRep"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.CompanyRep</emxUtil:i18n></label>&nbsp;</td>
    <td class="inputField">

<%
    if (isRep) {
%>
      <select name="companyrep" size="1" onchange="removeCompRep()" >
        <option value="" selected><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.NotCompanyRep</emxUtil:i18n></option>
        <%--//XSSOK--%>
        <option value="<%= XSSUtil.encodeForHTMLAttribute(context, (String)strCompanyType) %>" <%=(strCompanyType.equals(strCompanyRep))?"selected":""%>><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.ForCompany</emxUtil:i18n></option>
        <%--//XSSOK--%>
        <option value="<%= XSSUtil.encodeForHTMLAttribute(context, (String)strBusinessUnitType) %>" <%=(strBusinessUnitType.equals(strCompanyRep))?"selected":""%>><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.ForBusinessUnit</emxUtil:i18n></option>
   </select>
<%
    } else {
%>
        <input type="hidden" name="companyrep" value=""/>
<%
        formBean.setElementValue("companyrep","");
%>
      <input type="text" size="30" READONLY value="<emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.NotCompanyRep</emxUtil:i18n>"/>
<%
    }

%>
    </td>
  </tr>

    <tr>
      <td class="label"><label for="OfficePhone"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.WorkPhone</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField" align="left">
        <input type="text" name="workPhoneNumber" size="30" value="<xss:encodeForHTMLAttribute><%=workPhoneNumber%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="label"><label for="HomePhone"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.HomePhone</emxUtil:i18n></label></td>
      <td class="inputField">
        <input type="text" name="homePhoneNumber" size="30" value="<xss:encodeForHTMLAttribute><%=homePhoneNumber%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="label"><label for="Pager"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.Pager</emxUtil:i18n></label></td>
      <td class="inputField">
        <input type="text" name="pagerNumber" size="30" value="<xss:encodeForHTMLAttribute><%=pagerNumber%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="label"><label for="Fax"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.Fax</emxUtil:i18n></label></td>
      <td class="inputField">
        <input type="text" name="faxNumber" size="30" value="<xss:encodeForHTMLAttribute><%=faxNumber%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>

    <tr>
      <td class="labelRequired"><label for="Email"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.E-mail</emxUtil:i18n></label>&nbsp;</td>
      <td class="inputField">
        <input type="text" name="emailAddress" size="30" value="<xss:encodeForHTMLAttribute><%=emailAddress%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>


<% // from Sourcing Central create new page
  //get the language preference for the person
  String languagePref       = EnoviaResourceBundle.getProperty(context,"emxFramework.IconMailLanguagePreference");
  StringTokenizer strToken  = null;
  String language = "";
  String locale = "";
  String i18nLanguage = "";
%>
    <tr class="label">
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.LanguagePreference</emxUtil:i18n> &nbsp;</td>
      <td class="inputField">
        <select name="languagePreference" >
           <option value="None"><emxUtil:i18n localize="i18nId">emxComponents.Common.None</emxUtil:i18n></option>
<%
        strToken = new StringTokenizer(languagePref, " ");
        while(strToken.hasMoreElements())
        {
          language = strToken.nextToken();
          locale   = EnoviaResourceBundle.getProperty(context,"emxFramework.IconMailLanguageLocale"+language);
          i18nLanguage = i18nNow.getI18nString("emxFramework.IconMailLanguage"+language,"emxFrameworkStringResource",request.getHeader("Accept-Language"));
%>
          <option value="<%=locale%>"><%=XSSUtil.encodeForHTML(context, i18nLanguage)%></option>
<%
        }
%>
        </select>
      </td>
    </tr>

    <tr>
      <td class="label"><label for="WebSite"><emxUtil:i18n localize="i18nId">emxComponents.CreatePeopleDialog.WebSite</emxUtil:i18n></label></td>
      <td class="inputField">
        <input type="text" name="webSite" size="30" value="<xss:encodeForHTMLAttribute><%=webSite%></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>



  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.LoginType</emxUtil:i18n>&nbsp;</td>
    <td class="inputField">
<%
//from edit details page of SPC.

      // If this is add mode or we are a company rep, then let user edit LoginType
      if (isRep)
      {
          StringList strListLoginTypeRange = FrameworkUtil.getRanges(context , strLoginTypeAttr);
          StringItr strItrLoginTypeRange   = new StringItr (strListLoginTypeRange);
%>
        <table border="0">
<%
          // Loop through the LoginType range and create the select options
          String strLoginTypeRange = "";
          String strSelected = "";
          String i18NstrLoginTypeRange = "";
          while (strItrLoginTypeRange.next())
          {
            strLoginTypeRange = strItrLoginTypeRange.obj();
            strSelected = strLoginTypeRange.equals(strLoginTypeDefaultValue) ? "checked" : "";
            i18NstrLoginTypeRange = i18nNow.getRangeI18NString(strLoginTypeAttr, strLoginTypeRange, request.getHeader("Accept-Language"));
%>
            <tr>
            <%--//XSSOK--%>
              <td><input type="radio" name="logintype" id = "logintype" value="<%=XSSUtil.encodeForHTMLAttribute(context, strLoginTypeRange)%>" <%= strSelected%>  />
              &nbsp;	
              <%= XSSUtil.encodeForHTML(context, i18NstrLoginTypeRange) %></td>
            </tr>
<%
          }
%>
        </table>
<%
      } else {
%>
<%--//XSSOK--%>
        <input type="hidden" name="logintype" value="<%= strLoginTypeDefaultValue %>"/>
<%
        formBean.setElementValue("logintype",strLoginTypeDefaultValue);
%>
<%--//XSSOK--%>
          <input type="text" size="30" READONLY value="<%= strLoginTypeDefaultValue %>"/>
<%
      }
%>
     </td>
  </tr>


  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.HostMeetings</emxUtil:i18n></td>
    <td class="inputField" align="left">
    <table border="0">
        <tr>
        <%--//XSSOK--%>
          <td><input type="radio" name="hostmeetings" id="hostmeetings" value="Yes" <%=("no".equalsIgnoreCase(strHostMeetings))?"":"checked" %> />
          &nbsp;
          <emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.Yes</emxUtil:i18n></td>
        </tr>
        <tr>
        <%--//XSSOK--%>
          <td><input type="radio" name="hostmeetings" id="hostmeetings" value="No" <%=("no".equalsIgnoreCase(strHostMeetings))?"checked":"" %> />
          &nbsp;
          <emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.No</emxUtil:i18n></td>
        </tr>
    </table>
    </td>
    </td>
 </tr>
  <tr>
    <td align="left" class="label" valign="top">
      <framework:i18n localize="i18nId">emxComponents.PersonDialog.Address</framework:i18n>
    </td>
    <td class="field" align="left">
      <textarea name="address" rows="3" cols="30" wrap="wrap" ><xss:encodeForHTML><%=strAddress%></xss:encodeForHTML></textarea>
    </td>
  </tr>
  <tr>
    <td align="left" class="label">
      <framework:i18n localize="i18nId">emxComponents.PersonDialog.City</framework:i18n>
    </td>
    <td class="field" align="left"><input type="text" name="city" size="36" value="<xss:encodeForHTMLAttribute><%=strCity%></xss:encodeForHTMLAttribute>" /></td>
  </tr>
  <tr>
  <td align="left" class="label">
     <framework:i18n localize="i18nId">emxComponents.PersonDialog.StateRegion</framework:i18n>
  </td>
    <td class="field" align="left"><input type="text" name="stateRegion" size="36" value="<xss:encodeForHTMLAttribute><%=strStateRegion%></xss:encodeForHTMLAttribute>" /></td>
  </tr>
  <tr>
    <td align="left" class="label">
      <framework:i18n localize="i18nId">emxComponents.PersonDialog.PostalCode</framework:i18n>
    </td>
    <td class="field" align="left"><input type="text" name="postalCode" size="36" value="<xss:encodeForHTMLAttribute><%=strPostalCode%></xss:encodeForHTMLAttribute>" /></td>
  </tr>
  <tr>
    <td align="left" class="label">
      <framework:i18n localize="i18nId">emxComponents.PersonDialog.Country</framework:i18n>
    </td>
    <td class="field" align="left">
<%             
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
    java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
  	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");  	    
    String countryDefaultValue = (String)countryChoiceDetails.get("default");
%>
          <!-- //XSSOK -->
		  <framework:editOptionList disabled="false" name="<%=attrCountry%>" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=XSSUtil.encodeForHTML(context, countryDefaultValue)%>" manualEntryList="<%=manualEntryList%>"/>
    </td>
  </tr>


 <tr>
    <td class="label"><label for="Absence Start Date"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.AbsenceStartDate</emxUtil:i18n></label></td>
    <td class="inputField"><input type="text" name="AbsenceStartDate" id="AbsenceStartDate" value="" size="20" READONLY/>&nbsp;<a href="javascript:showCalendar('CreatePeople','AbsenceStartDate','')"><img src="../common/images/iconSmallCalendar.gif" border=0 width="16" height="16" ></a>&nbsp;

<%
    long strms = 0;
    long endms = 0;
%>
    <input type="hidden" name="AbsenceStartDate_msvalue" value="<xss:encodeForHTMLAttribute><%=strms%></xss:encodeForHTMLAttribute>"/> 



    <a href="JavaScript:clearField('CreatePeople','AbsenceStartDate','AbsenceStartDate')" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
    </td>
 </tr>

 <tr>
    <td class="label"><label for="Absence End Date"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.AbsenceEndDate</emxUtil:i18n></label></td>
    <td class="inputField"><input type="text" size="20" value="" name="AbsenceEndDate" id="AbsenceEndDate" READONLY />&nbsp;<a href="javascript:showCalendar('CreatePeople','AbsenceEndDate','')"><img src="../common/images/iconSmallCalendar.gif" border=0 width="16" height="16" ></a>&nbsp;

    <%//  To get the value in the hidden variable%>
    <input type="hidden" name="AbsenceEndDate_msvalue" value="<xss:encodeForHTMLAttribute><%=endms%></xss:encodeForHTMLAttribute>"/>

    <a href="JavaScript:clearField('CreatePeople','AbsenceEndDate','AbsenceEndDate')" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>    
    </td>
 </tr>

 <%
  
  String addMembersURL="../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&submitLabel=emxFramework.GlobalSearch.Done&table=AEFPersonChooserDetails&form=BPSUserSearchForm&selection=single&submitURL=../common/AEFSearchUtil.jsp&showInitialResults=true&fieldNameActual=person&fieldNameDisplay=person";
 
 %>
   <tr>
     <td class="label"><label for="Absence Delegate"><emxUtil:i18n localize="i18nId">emxComponents.PersonDialog.AbsenceDelegate</emxUtil:i18n></label></td>
     <td class="inputField"><input type="text" name="person" id="person" value="" READONLY size="25" />&nbsp;<input type="button" value="..." name="btn" id="btn" onclick="javascript:showModalDialog('<%=XSSUtil.encodeForHTML(context, addMembersURL)%>',575,575);" />&nbsp;
     <a href="JavaScript:clearField('CreatePeople','person','person')" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
     </td>
   </tr>
  
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Site</emxUtil:i18n></td>
    <td class="inputField">
        <select name="Site" >
        <%--//XSSOK--%>
           <option value="None" <%=("".equals(strSiteValue))?"selected": ""%>><emxUtil:i18n localize="i18nId">emxComponents.Common.None</emxUtil:i18n></option>
<%        
        while(siteToken.hasMoreElements())
        {
          String strSite = siteToken.nextToken();
%>        
<%--//XSSOK--%>
            <option value="<%=XSSUtil.encodeForHTMLAttribute(context, (String)strSite)%>" <%=(strSite.equals(strSiteValue))?"selected": ""%>> <%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Site", strSite, languageStr))%> </option>
<%      }
%>            
        </select>
    
   </td>
  </tr>
  
<%
    // display all possible Viewer options available to him/her
    // Get the list of formats for which user can switch viewer prefernce
  String formatsStr = EnoviaResourceBundle.getProperty(context,"emxFramework.FormatsWithViewerPreference"); // Reading the property file for all  viewers
  if( formatsStr != null )
  {
    StringTokenizer formatsTokenizer = new StringTokenizer(formatsStr,",");
    FormatUtil formatUtil = new FormatUtil();
    String formatToken = "";
    String format = "";
    while(formatsTokenizer.hasMoreTokens())//Iterating through all the viewers
    {
      formatToken = (String)formatsTokenizer.nextToken();
      format = PropertyUtil.getSchemaProperty( context,formatToken);

      if( format != null && !"".equals(format))
      {
        formatUtil.setFormatName( formatToken );

         //get all the Option sfor the viewer
         StringList viewerList = formatUtil.getViewerOptions( context ); //This will get all the registered viewers for that format

         Iterator i = viewerList.iterator();
%>
    <tr>
        <td class="label"><%=XSSUtil.encodeForHTML(context, (String)format)%>&nbsp;<emxUtil:i18n localize="i18nId">emxComponents.PersonDetails.ViewerPreference</emxUtil:i18n>&nbsp;</td>
        <td class="inputField">
          <select name = <%= format + "viewerPreference"%> >
             <option value = "None" ><emxUtil:i18n localize="i18nId">emxComponents.Common.None</emxUtil:i18n></option>
<%
          String viewerURL = "";
          String viewerName = "";
          while( i.hasNext())
          {
            viewerURL = (String)i.next();
            viewerName = null;

            // get the ViewerName to display from Servlet Name
            if( viewerURL != null && !"".equals(viewerURL))
            {
              viewerName = formatUtil.getViewerName( context, viewerURL);
            }
%>
            <option value = "<%=XSSUtil.encodeForHTMLAttribute(context, (String)viewerURL)%>" ><%=XSSUtil.encodeForHTML(context, (String)viewerName)%></option>   // Adding the selected viewers for each  format to the drop down
<%
         }
%>
        </select>
      </td>
    </tr>
<%
      }
    }
  }

  String dateFormats = EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.ExportImportDateFormats");
  StringTokenizer strFormatToken  = null;
  String format = "";
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.PersonDetails.DateFormat</emxUtil:i18n> &nbsp;</td>
      <td class="inputField">
        <select name="dateFormat" size="1" >
           <option value="None"><emxUtil:i18n localize="i18nId">emxComponents.Common.None</emxUtil:i18n></option>
<%
            strFormatToken = new StringTokenizer(dateFormats, ",");
            while(strFormatToken.hasMoreElements())
            {
                format = strFormatToken.nextToken().trim();
%>
<%--//XSSOK--%>
                <option value="<%=XSSUtil.encodeForHTMLAttribute(context, (String)format)%>" <%=(strDateFormat.equals(format))?"selected":""%>><%=XSSUtil.encodeForHTML(context, (String)format)%></option>
<%
            }
%>
        </select>
      </td>
    </tr>

<%
  String listSeparator = EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.ExportImportDelimiters");
  StringTokenizer strDelimiterToken  = null;
  String separator = "";
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId">emxComponents.PersonDetails.ListSeparator</emxUtil:i18n> &nbsp;</td>
      <td class="inputField">
        <select name="listSeparator" size="1" >
           <option value="None"><emxUtil:i18n localize="i18nId">emxComponents.Common.None</emxUtil:i18n></option>
<%
            strDelimiterToken = new StringTokenizer(listSeparator, " ");
            while(strDelimiterToken.hasMoreElements())
            {
                separator = strDelimiterToken.nextToken().trim();
%>
<%--//XSSOK--%>
                <option value="<%=separator%>" <%=(strListSeparator.equals(separator))?"selected":""%> ><%=separator%></option>
<%
            }
%>
        </select>
      </td>
    </tr>
  <!--Added for Organization Person Feature -->
  <tr>
    <td align="left" class="label">
      <framework:i18n localize="i18nId">emxComponents.PersonDetails.MailCode</framework:i18n>
    </td>
    <td class="field" align="left"><input type="text" name="mailCode" size="36" value="<xss:encodeForHTMLAttribute><%=strMailCode%></xss:encodeForHTMLAttribute>" /></td>
  </tr>
  <tr>
    <td align="left" class="label">
      <framework:i18n localize="i18nId">emxComponents.Common.Title</framework:i18n>
    </td>
    <td class="field" align="left"><input type="text" name="title" size="36" value="<xss:encodeForHTMLAttribute><%=strTitle%></xss:encodeForHTMLAttribute>" /></td>
  </tr>
  <!--End -->
  </table>
  &nbsp;
</form>

<%
    formBean.setFormValues(session);
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

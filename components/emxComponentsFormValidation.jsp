<%--  emxComponentsFormValidation.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxComponentsFormValidation.jsp.rca 1.14 Tue Oct 28 19:01:07 2008 przemek Experimental przemek $

 --%>
<%-- Common Includes --%>
<%@page import="java.text.SimpleDateFormat"%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../emxUICommonAppNoDocTypeInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil" %>
<%@ page import = "com.matrixone.apps.domain.DomainConstants" %>
<%@ page import = "com.matrixone.apps.domain.DomainObject" %>
<%@ page import = "com.matrixone.apps.domain.util.eMatrixDateFormat" %>

<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
    int allowedDunsDigit = Integer.parseInt(EnoviaResourceBundle.getProperty(context,"emxComponents.allowedDUNSNumberDigitDisplay"));
    String attrDUNS                = PropertyUtil.getSchemaProperty(context, "attribute_DUNSNumber");
    String attrWebSite             = PropertyUtil.getSchemaProperty(context, "attribute_WebSite");
    String languageStr = request.getHeader("Accept-Language");
    String ResFormFileId = "emxComponentsStringResource";
    String msg1 = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.InvalidChars");  
    String msg2 = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.RemoveInvalidChars"); 
    String msg3 = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.checkDateMsg"); 
    String msg4 = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.isInvalid"); 
    String meetingDateAlert = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.MeetingDate"); 
    String meetingTimeAlert = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.MeetingTime"); 
    String strBaseSkillType = DomainConstants.TYPE_BUSINESS_SKILL;
    String meetingDurationAlert = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.MeetingDuration"); 
    String nonNumericValueAlert = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.NonNumericValue"); 
    String durationAlert = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.Duration"); 
    String ShowCommentsForTaskApproval = EnoviaResourceBundle.getProperty(context,"emxComponents",context.getLocale(), "emxComponents.Routes.ShowCommentsForTaskApproval"); 
    String IgnoreCommentsForRejection= EnoviaResourceBundle.getProperty(context,"emxComponents",context.getLocale(), "emxComponentsRoutes.InboxTask.IgnoreComments"); 

    int intDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
    double clientTZOffset   = (new Double((String)session.getValue("timeZone"))).doubleValue();
    String objectId = request.getParameter("objectId");
    String meetingStartDateTime = "";

	if(UIUtil.isNotNullAndNotEmpty(objectId)){

    DomainObject domainObject = new DomainObject(objectId);
	String objType = domainObject.getType(context);
		if(DomainConstants.TYPE_MEETING.equals(objType)) {
			meetingStartDateTime = domainObject.getInfo(context, "attribute["+DomainConstants.ATTRIBUTE_MEETING_START_DATETIME+"]");
		} 
    }

	String isUniqueCageCode = EnoviaResourceBundle.getProperty(context,"emxComponents.cageCode.Uniqueness");
	isUniqueCageCode = (isUniqueCageCode!=null && isUniqueCageCode.trim().equalsIgnoreCase("true")) ? "true" : "false";
%>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>

<SCRIPT LANGUAGE="JavaScript">
//XSSOK
 var msg1 = "<%=msg1%>";
 var msg2 = "<%=msg2%>";
 var msg3 = "<%=msg3%>";
 var msg4 = "<%=msg4%>";
 var meetingDateAlert = "<%=meetingDateAlert%>";
 var meetingTimeAlert = "<%=meetingTimeAlert%>";
 var meetingDurationAlert = "<%=meetingDurationAlert%>";
 var nonNumericValueAlert = "<%=nonNumericValueAlert%>";
 var durationAlert = "<%=durationAlert%>";
 var meetingStartDateTime = "<%=meetingStartDateTime%>";
var MAX_LENGTH =<%=FrameworkProperties.getProperty(context,"emxComponents.MAX_FIELD_LENGTH")%>;

  function meetingEditPastDateCheck()
  {
    var strMeeingDate = document.forms[0].MeetingDate.value;
    var strMeetingTime = document.forms[0].StartTime.value;
    var meetingNewDate_msValue = document.forms[0].MeetingDate_msvalue.value;

    //modified for other language support (de,fr)   
    var meetingNewDate = new Date(parseInt(meetingNewDate_msValue));
    meetingNewDate = new Date((meetingNewDate.getMonth()+1)+"/"+meetingNewDate.getDate()+"/"+meetingNewDate.getFullYear()+" "+strMeetingTime);
    var actualDate = new Date(meetingStartDateTime);

    if (trimWhitespace(strMeeingDate) == '')
        return true; // AEF will take care of mandatory field validation
    
    var fieldDay = meetingNewDate.getDate();

    var currentDate = new Date();
    var currentDay = currentDate.getDate();
    
    var fieldDateMod = Date.parse(meetingNewDate); 
    var currentDateMod = Date.parse(currentDate);

    if (fieldDateMod < currentDateMod && (Date.parse(meetingNewDate) != Date.parse(actualDate))) {
    
    if (fieldDateMod < currentDateMod) {
        if(fieldDay == currentDay){
            alert(meetingTimeAlert);
        }else {
            alert(meetingDateAlert);
        }
        return false;
    }
  }
    return true;
  }
  
function validateMeetingDuration()
{
    var strMeetingDuration = document.forms[0].Duration.value;  
    var returnFlag = true;
        
    if(trimWhitespace(strMeetingDuration) == '')        
        returnFlag = true; // AEF will take care of mandatory field validation  
    if(isNaN(strMeetingDuration))
    {
    	//XSSOK
        alert(nonNumericValueAlert +" <%=EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Alert.Duration")%>" );     
        returnFlag = false;
    }else if(strMeetingDuration > 0 && strMeetingDuration <= 500)
    {
        returnFlag = true;      
    }
    else
    {
        alert(meetingDurationAlert);
        returnFlag = false; 
    }   
return returnFlag;
}

function validateAgendaItemDuration()
{
    var strDuration = document.forms[0].Duration.value;  
    var returnFlag = true;
        
    if(trimWhitespace(strDuration) == '')        
        returnFlag = true; // AEF will take care of mandatory field validation  
    if(isNaN(strDuration))
    {
    	//XSSOK
        alert(nonNumericValueAlert +" <%=EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.Common.Duration")%>" );     
        returnFlag = false;
    }else if(strDuration > 0 && strDuration <= 500)
    {
        returnFlag = true;      
    }
    else
    {
        alert(durationAlert);
        returnFlag = false; 
    }   
return returnFlag;
}

function isContainBadChar(field)
{
    var apostrophePosition = field.value.indexOf("'");
    var hashPosition = field.value.indexOf("#");
    var doublequotesPosition = field.value.indexOf("\"");

    if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
        field.value="";
        field.focus();
        return true;
    }
}


  function validateAttendeeSearch() {
    var preference ="<%=EnoviaResourceBundle.getProperty(context,"emxComponents.Meetings.AddPeoplePreference")%>";
    
    var userNameFld = document.forms["editDataForm"]["User Name"];
    var firstNameFld = document.forms["editDataForm"]["First Name"];
    var lastNameFld = document.forms["editDataForm"]["Last Name"];
    
    userNameFld.value = jsTrim(userNameFld.value);
    firstNameFld.value = jsTrim(firstNameFld.value);
    lastNameFld.value = jsTrim(lastNameFld.value);    
    
    if(isContainBadChar(userNameFld) || isContainBadChar(firstNameFld) || isContainBadChar(lastNameFld))
    {
        return false;
    }

    //Validating the name fields contains any character or digit and if not throwing alert message saying that enter atleast one character.
    var userName = userNameFld.value.replace(/[^a-zA-Z\d]/g, '');
    var firstName = firstNameFld.value.replace(/[^a-zA-Z\d]/g, '');
    var lastName = lastNameFld.value.replace(/[^a-zA-Z\d]/g, '');
    
    var temp = (userName.length == 0)&&(firstName.length == 0)&&(lastName.length == 0);
    if(preference.toUpperCase()=="TRUE" && temp)
    {
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.PleaseEnterNameDetails</emxUtil:i18nScript>");
        userNameFld.focus();
        return false;
    }

    return true;
  }  

function disableOrganization()
{

  for(i=0;i<document.forms[0].elements.length;i++)
  {
    if(document.forms[0].elements[i].name == 'Organization')
    {
    document.forms[0].elements[i+2].disabled=true;
     document.forms[0].OrganizationDisplay.value="";
    break;
    }
  }
}

function enableOrganization(name,id)
{


  for(i=0;i<document.forms[0].elements.length;i++)
  {
    if(document.forms[0].elements[i].name == 'Organization')
    {
    document.forms[0].elements[i+2].disabled=false;
    document.forms[0].OrganizationDisplay.value=name;
    document.forms[0].OrganizationOID.value=id;
    break;
    }
  }
}


function disablePersonalRadio(){
  if(document.forms[0].rb[1].checked){
        document.forms[0].rb[1].checked = false;
        document.forms[0].rb[0].checked = true;
        return;
      }else{
        document.forms[0].rb[0].checked = false;
        document.forms[0].rb[1].checked = true;
        return;
      }

  }

function IssueWaitOnDateValidate()
{
    var strWaitOnDate = document.forms[0].txtWaitOnDate_msvalue.value;

    if(strWaitOnDate != null && strWaitOnDate.length > 0)
    {
        var dWaitOnDate = new Date(strWaitOnDate-0);
        //var dOriginatedDate = new Date(document.forms[0].OriginatedDate.value);
		var dOriginatedDate = new Date(document.forms[0].originatedDate_formattedvalue.value);
        
        //above Originated Date will have the time also. To ingore the time. Set the Date without time.
		//dOriginatedDate = new Date((dOriginatedDate.getMonth()+1)+"/"+dOriginatedDate.getDate()+"/"+dOriginatedDate.getYear());
        var dServerCurrentDate = new Date(document.forms[0].ServerCurrentDate.value - 0);

		if(dWaitOnDate.getTime() < dOriginatedDate.getTime())
        {
			//XSSOK
            alert("<%=i18nNow.getI18nString("emxComponents.Common.Issue.Alert.WaitOnDate.Originated",bundle,acceptLanguage)%>");
            return false;
        }
    }
    return true;
}

function IssueCloseResolutionDateValidate() {
	var strResolutionDate = document.forms[0].ResolutionDate_msvalue.value;
	var fieldDate = new Date(parseInt(strResolutionDate));
    
    var sFieldDate = fieldDate.getDate();
    var sFieldMonth = fieldDate.getMonth();
    var sFieldYear = fieldDate.getFullYear();
    var resDate = new Date(sFieldYear, sFieldMonth, sFieldDate);
    
    var tempDay = new Date();
    var sTempDate = tempDay.getDate();
    var sTempMonth = tempDay.getMonth();
    var sTempYear = tempDay.getFullYear();
    var today = new Date(sTempYear, sTempMonth, sTempDate);
	if(resDate > today) {
		//XSSOK
        alert("<%=i18nNow.getI18nString("emxComponents.Alert.checkDate",bundle,acceptLanguage)%>");
        return false;
    }
    return true;
}


function IssueResolutionDateValidate()
{

    var strResolutionDate = document.forms[0].ResolutionDate_msvalue.value;

    if(strResolutionDate != null && strResolutionDate.length > 0)
    {
        var dResolutionDate = new Date(strResolutionDate-0);
        var dOriginatedDate = new Date(document.forms[0].OriginatedDate.value);
        //above Originated Date will have the time also. To ingore the time. Set the Date without time.
        dOriginatedDate = new Date((dOriginatedDate.getMonth()+1)+"/"+dOriginatedDate.getDate()+"/"+dOriginatedDate.getYear());
        var dServerCurrentDate = new Date(document.forms[0].ServerCurrentDate.value - 0);

        if(dResolutionDate < dOriginatedDate)
        {
        	//XSSOK
            alert("<%=i18nNow.getI18nString("emxComponents.Common.Issue.Alert.ResolutionDate.Originated",bundle,acceptLanguage)%>");
            return false;
        }
        if(dResolutionDate > dServerCurrentDate)
        {
        	//XSSOK
            alert("<%=i18nNow.getI18nString("emxComponents.Common.Issue.Alert.ResolutionDate.ServerDate",bundle,acceptLanguage)%>");
            return false;
        }
//      var strWaitOnDate = eval("document.forms[0].txtWaitOnDate_msvalue.value");
        var strWaitOnDate = "";
        if (document.forms[0].txtWaitOnDate_msvalue != undefined)
        {
            strWaitOnDate = eval("document.forms[0].txtWaitOnDate_msvalue.value");
        }

        if(strWaitOnDate != null && strWaitOnDate.length > 0)
        {
            var dWaitOnDate = new Date(strWaitOnDate-0);
            if(dResolutionDate < dWaitOnDate)
            {
            	//XSSOK
                alert("<%=i18nNow.getI18nString("emxComponents.Common.Issue.Alert.ResolutionDate.WaitOnDate",bundle,acceptLanguage)%>");
                return false;
            }
        }
    }
    return true;
}

//Validating for Date Value
function IssueDateValidate(){

        //Begin of modify by Infosys on 18-May-05 for Bug# 304697
        var strESD = document.forms[0].EstimatedStartDate_msvalue.value;
        var strEFD = document.forms[0].EstimatedFinishDate_msvalue.value;
        //End of modify by Infosys on 18-May-05 for Bug# 304697

        var msg = "";

       // var fieldESD = new Date(strESD);
       // var fieldEFD = new Date(strEFD);

        if ((trimWhitespace(strESD) != '') && (trimWhitespace(strEFD) != '') )
        {
        
                //Begin of modify by Infosys on 18-May-05 for Bug# 304697
                if (strESD > strEFD)
                {
               //End of modify by Infosys on 18-May-05 for Bug# 304697
            //Condition check when Estimated Start Date is after Estimated Finish Date. It should be before the Estimated Finish Date
                        //XSSOK 
                        alert("<%=i18nNow.getI18nString("emxComponents.Common.Issue.Alert.EstimatedStartAndEndDates",bundle,acceptLanguage)%>");
                        return false;
                }

        }
        return true;
}

//Checking for Maxlength as defined in properties for the webform field
function checkLength(fieldname)
{
    if(!fieldname)
    {
        fieldname=this;    
    }
    if (!isValidLength(fieldname.value,0,MAX_LENGTH))
    {
    	//XSSOK
        var msg = "<%=i18nNow.getI18nString("emxComponents.Alert.checkLength",bundle,acceptLanguage)%>";
        msg += ' ' + MAX_LENGTH + ' ';
        alert(msg);
        fieldname.focus();
        return false;
    }
    return true;
}

// Checking for Bad characters in the field and Maximum length of field
function checkBadNameCharsLength()
{
       if(!checkBadNameChars(this))
       {
           return false;
       }
       return checkLength(this);
}

// Checking for Bad characters in the field
function checkBadNameChars(fieldName) 
{
    if(!fieldName)
    {
    	fieldName=this;
    }
    if(fieldName.value!=null && fieldName.value!="" )
    {
      var isBadNameChar=checkForNameBadChars(fieldName,true);
      var fieldValue=fieldName.value;
      var orgLen = fieldValue.replace(/[.]/g, '');
  	  var name;
  	  
      if(fieldName.title!="undefined" && fieldName.title!="" && fieldName.title!="null"){
    	  	name = fieldName.title;
    	  }
      else {
    	  	name = fieldName.name;
    	  }
  
      if(( isBadNameChar.length > 0 || orgLen.length==0)&& isBadNameChar!="")
      {
    	//XSSOK
    	  var nameAllBadCharName = getAllNameBadChars(fieldName);
    	  msg = "<%=i18nNow.getI18nString("emxComponents.ErrorMsg.InvalidInputMsg",bundle,acceptLanguage)%>";
        msg += isBadNameChar;
        msg += "<%=i18nNow.getI18nString("emxComponents.Common.AlertInvalidInput", bundle,acceptLanguage)%>";
        msg += nameAllBadCharName;
        msg += name;
        msg += "  <%=i18nNow.getI18nString("emxComponents.Alert.Field", bundle,acceptLanguage)%> ";
        fieldName.focus();
        alert(msg);
        return false;
      }
    }
    return true;
 }


//Checking for Bad characters in the Text Area field
function checkBadChars(fieldName)
{
    if(!fieldName)
    fieldName=this;
    var badChars = "";
    badChars=checkForBadChars(fieldName);
    var name;
      if(fieldName.title!="undefined" && fieldName.title!="" && fieldName.title!="null"){
	  	name = fieldName.title;
	  }
 		 else {
	  	name = fieldName.name;
	  }
    
    if ((badChars).length != 0)
    {
    	//XSSOK
        msg = "<%=i18nNow.getI18nString("emxComponents.Alert.InvalidChars",bundle,acceptLanguage)%>";
        msg += badChars;
        msg += "<%=i18nNow.getI18nString("emxComponents.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
        msg += name;
        msg += "  <%=i18nNow.getI18nString("emxComponents.Alert.Field", bundle,acceptLanguage)%> ";
        fieldName.focus();
        alert(msg);
        return false;
    }
    return true;
}


//Checking for Bad characters in the 'Reason For Change' Text Area field
function checkBadCharsForEditAll(fieldName)
{
    if(!fieldName)
    fieldName=this;
    var badChars = "";
    badChars=checkForBadChars(fieldName);
    if ((badChars).length != 0)
    {    
    	//XSSOK
        msg = "<%=i18nNow.getI18nString("emxComponents.Alert.InvalidChars",bundle,acceptLanguage)%>";
        msg += badChars;
        msg += "<%=i18nNow.getI18nString("emxComponents.Alert.RemoveInvalidChars", bundle,acceptLanguage)%> ";
        msg += "<%=i18nNow.getI18nString("emxComponents.EngineeringChange.ReasonforChange",bundle,acceptLanguage)%>";
        fieldName.focus();
        alert(msg);
        return false;
    }
    return true;
}

//Checking for Positive Integer value of the field
function checkPositiveInteger(fieldname)
{
    if(!fieldname) {
        fieldname=this;
    }    

    if( isNaN(fieldname.value) || fieldname.value < 0 || parseInt(fieldname.value) != fieldname.value )
    {
    	//XSSOK
        msg = "<%=i18nNow.getI18nString("emxComponents.Alert.IntegerPositive",bundle,acceptLanguage)%>";
        alert(msg);
        fieldname.focus();
        return false;
    }
    return true;
}

//Checking for Positive Real value of the field
function checkPositiveReal(fieldname)
{
    if(!fieldname) {
        fieldname=this;
    }    

    if( isNaN(fieldname.value) || fieldname.value < 0 )
    {
    	//XSSOK
        msg = "<%=i18nNow.getI18nString("emxComponents.Alert.checkPositiveNumeric",bundle,acceptLanguage)%>";
        alert(msg);
        fieldname.focus();
        return false;
    }
    return true;
}

function populateTypePolicies()
{ 
  var f = document.forms[0];
  var selectedValue;
  var policyFieldName = 'Default Part Policy';

  for( var i = 0; i < f.elements.length; i++ ) 
  {
    if(f.elements[i].name == 'Default Part Type')
    {
      selectedValue = f.elements[i].value;
    }
  }

  document.forms[0].target = "formEditHidden";
  document.forms[0].action = "../components/emxComponentsPartFamilyFormPopulatePolicies.jsp?selectedType="+selectedValue+"&policyFieldName="+policyFieldName;
  document.forms[0].submit();
}


//Validating for Date Value
function RequestGrantExpirationDateValidate(){
    var strGED = document.forms[0].GrantExpirationDateEdit.value;
    var msg = "";

    var fieldGED = new Date(strGED);
    var fieldDate = new Date();
   
    if ((trimWhitespace(strGED) != '') )
    {
        if (fieldDate > fieldGED)
        {
            //Condition check when Estimated Start Date is after Estimated Finish Date. It should be before the Estimated Finish Date
            //XSSOK
            msg = "<%=i18nNow.getI18nString("emxComponents.Alert.ExpirationDateValidate",bundle,acceptLanguage)%>";
            alert(msg);
            return false;
        }
    }
    return true;
}

//Validating for Date Value
function RequestExtensionDateValidate(){

    var strED = document.forms[0].ExtensionDateEdit.value;
    var msg = "";
        
    var fieldED = new Date(strED);
    var fieldDate = new Date();
   
    if ((trimWhitespace(strED) != '') )
    {
        if (fieldDate > fieldED)
        {
            //Condition check when Estimated Start Date is after Estimated Finish Date. It should be before the Estimated Finish Date
            //XSSOK
            msg = "<%=i18nNow.getI18nString("emxComponents.Alert.ExtensionDateValidate",bundle,acceptLanguage)%>";
            alert(msg);
            return false;
        }
    }
    return true;
}

//validates Name bad characters and also includes apostrophe in the bad chars list
function checkBadNameCharsIncludesApostrophe(fieldName) {
    if(!fieldName) {
        fieldName=this;
    }
    if(!checkBadNameChars(fieldName)) {
        return false;
    }
    var bSingleQuote = /\'/.test(fieldName.value);
    if(bSingleQuote) {
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
        return false;
    }
    return true;
}

//validates DUNS Number
function validateDunsNumber(fieldName) {
    if(!fieldName) {
        fieldName=this;
    }

    if(fieldName.value < 0) {
    	//XSSOK
        alert("<%= i18nNow.getAttributeI18NString(attrDUNS,languageStr) %> " + "<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PositiveNumber</emxUtil:i18nScript>");
        return false;
    }
    if(fieldName.value.length > '<%=allowedDunsDigit%>') {
    	//XSSOK
        alert("<%= i18nNow.getAttributeI18NString(attrDUNS,languageStr) %> " + "<emxUtil:i18nScript localize="i18nId">emxComponents.Common.allowedDunsNumber</emxUtil:i18nScript>"+'<%=allowedDunsDigit%>');
        return false;
    }
    return true;
}

//validates website contains space or not
function isWebsiteContainsSpace(fieldName) {
    if(!fieldName) {
        fieldName=this;
    }

    var result = /\s/.test(fieldName.value);
    if(result) {
    	//XSSOK
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.Invalid</emxUtil:i18nScript>" + " <%= i18nNow.getAttributeI18NString(attrWebSite,languageStr)%>.");
        return false;
    }
    return true;
}

//opens the chooser for secondary vaults.
function showSecondaryVaultsSelector(objectId) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.SecondaryVaultAlertMessage</emxUtil:i18nScript>");
      showChooser('../common/emxVaultChooser.jsp?fieldNameActual=SecondaryVaults&fieldNameDisplay=SecondaryVaultsDisplay&action=editCompany&objectId=' + objectId);
}

//validate secondary vaults field
function validateSecondaryVaults(fieldName) {
    if(!fieldName) {
        fieldName=this;
    }

    var secondaryvaults = document.editDataForm.elements[fieldName.name].value;
    var primaryvault = document.editDataForm.elements['vaultPrime'].value;
    var secondaryvaultsArray = secondaryvaults.split(",");
    for( j=0;j<secondaryvaultsArray.length;j++) {
        if(secondaryvaultsArray[j] == primaryvault) {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.AlertSecondaryVaultMessage</emxUtil:i18nScript>");
            return false;
        }
    }

    return true;
}

//validate parent company  field
function validateParentCompany(fieldName) {
    if(!fieldName) {
        fieldName=this;
    }
    
    var parentcompany = document.editDataForm.elements[fieldName.name].value;

// Commented for IR-034293V6R2011 Dated 4th Mar 2010 Begins.
//    var hostcompany = document.editDataForm.elements['Name1'].value;
// Commented for IR-034293V6R2011 Dated 4th Mar 2010 Ends.
// Added for IR-034293V6R2011 Dated 4th Mar 2010 Begins.
    var hostcompany = "";
    if(null != document.editDataForm.elements['Name1'])
    {
    	hostcompany = document.editDataForm.elements['Name1'].value;
    }
    else
    {
    	hostcompany = document.editDataForm.parentOID.value;
    	parentcompany=document.editDataForm.parentNameOID.value;
    }
// Added for IR-034293V6R2011 Dated 4th Mar 2010 Ends.

        if(parentcompany == hostcompany) {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.AlertParentCompanyMessage</emxUtil:i18nScript>");
            return false;
        }   

    return true;
}

//validate the URL
function validateURL(fieldName) {
    if(!fieldName) {
        fieldName=this;
    }

    if (fieldName.value != "" ) {
        if ( fieldName.value.indexOf("http://") < 0 && fieldName.value.indexOf("https://") < 0 ) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.SiteNameAlert</emxUtil:i18nScript>");
            return false;
        }
    }
    return true;
}
/*******************************************************************************/
/* function checkNonProductionDays()                                         */
/* Validates Non Production Days while Create and Edit Plant.                */
/* X3                                                                     */
/**************************************************************************/
function checkNonProductionDays()
{
   var isStringValid = false;
   var arrobj= null;
   var strNonPaymentDays = this.value;
   var arrNonPaymentDays= new Array(strNonPaymentDays.length);

  //Date Format to be enetered should be of Format dd/mm/yyyy,dd/mm/yyyy    
   arrNonPaymentDays=strNonPaymentDays.split(",");
      for(var i = 0;i<arrNonPaymentDays.length;i++)
      {
          arrobj = arrNonPaymentDays[i];
          /*isDate() does the validation on the Value enetered in the Non Producation Days Text Area.The String can only have comma      seperated Date values.*/
          var isValidDate = isValidDateFormat(arrobj);

        if(isValidDate)
         {
            isStringValid = true;
         }
    else
     {
        isStringValid = false;
        break;
     }
    }

    if(isStringValid)
    {
        return true;
    }
    else
    {
    alert(msg3+" "+arrobj+ " "+msg4);
    }
}//End Function 

//validating date in dd/mm/yyyy format
function isValidDateFormat(DateToCheck)
{
  if(DateToCheck==""){return true;}
      if(DateToCheck.indexOf("/") < 0){
       return false;
    }

  var m_arrDate = DateToCheck.split("/");
      if(m_arrDate.length != 3){
       return false;
    }
    
    var m_MONTH = m_arrDate[0];
    var m_DAY   = m_arrDate[1];
    var m_YEAR  = m_arrDate[2]; 
    
   if(m_DAY.length > 2 || m_MONTH.length > 2 || m_YEAR.length != 4)
    {
        return false;
    }
    var m_strDate = m_MONTH + "/" + m_DAY + "/" + m_YEAR;
    var testDate=new Date(m_strDate);

    if(testDate.getMonth()+1==m_MONTH)
    {
      return true;
    }
    else
    {
        return false;
    }
}

function isDate(DateToCheck)
{

    if(DateToCheck==""){return true;}
    var m_strDate = FormatDate(DateToCheck);

    if(m_strDate==""){
        return false;
    }

    var m_arrDate = m_strDate.split("/");
    var m_DAY = m_arrDate[0];
    var m_MONTH = m_arrDate[1];
    var m_YEAR = m_arrDate[2];

    if(m_YEAR.length > 4)
    {
        return false;
    }

    m_strDate = m_MONTH + "/" + m_DAY + "/" + m_YEAR;
    var testDate=new Date(m_strDate);

    if(testDate.getMonth()+1==m_MONTH)
    {
      return true;
    }
    else
    {
        return false;
    }

}//end function


function FormatDate(DateToFormat,FormatAs){

    if(DateToFormat==""){return"";}

    if(!FormatAs){FormatAs="dd/mm/yyyy";}

    var strReturnDate;
    FormatAs = FormatAs.toLowerCase();
    DateToFormat = DateToFormat.toLowerCase();
    var arrDate
    var arrMonths = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
    var strMONTH;
    var Separator;

    while(DateToFormat.indexOf("st")>-1){
       DateToFormat = DateToFormat.replace("st","");
    }

    while(DateToFormat.indexOf("nd")>-1){
        DateToFormat = DateToFormat.replace("nd","");
    }

    while(DateToFormat.indexOf("rd")>-1){
        DateToFormat = DateToFormat.replace("rd","");
    }

    while(DateToFormat.indexOf("th")>-1){
       DateToFormat = DateToFormat.replace("th","");
    }
     
    if(DateToFormat.indexOf(".")>-1){
       Separator = ".";
    }

    if(DateToFormat.indexOf("-")>-1){
       Separator = "-";
    }
    if(DateToFormat.indexOf("/")>-1){
       Separator = "/";
    }
    if(DateToFormat.indexOf(" ")>-1){
       Separator = " ";
    }
    arrDate = DateToFormat.split(Separator);
    DateToFormat = "";

    for(var iSD = 0;iSD < arrDate.length;iSD++){
        if(arrDate[iSD]!=""){
             DateToFormat += arrDate[iSD] + Separator;
        }
    }

    DateToFormat = DateToFormat.substring(0,DateToFormat.length-1);
    arrDate = DateToFormat.split(Separator);

    if(arrDate.length < 3){
       return "";
    }

    var DAY = arrDate[0];
    var MONTH = arrDate[1];
    var YEAR = arrDate[2];

    if(parseFloat(arrDate[1]) > 12){
        DAY = arrDate[1];
        MONTH = arrDate[0];
    }

    if(parseFloat(DAY) && DAY.toString().length==4){
        YEAR = arrDate[0];
        DAY = arrDate[2];
        MONTH = arrDate[1];
    }

    for(var iSD = 0;iSD < arrMonths.length;iSD++){
       var ShortMonth = arrMonths[iSD].substring(0,3).toLowerCase();
       var MonthPosition = DateToFormat.indexOf(ShortMonth);
       if(MonthPosition > -1){
             MONTH = iSD + 1;
             if(MonthPosition == 0){
                  DAY = arrDate[1];
                  YEAR = arrDate[2];
             }
             break;
        }
    }

    var strTemp = YEAR.toString();

    if(strTemp.length==2){
        if(parseFloat(YEAR)>40){
              YEAR = "19" + YEAR;
         }
         else{
             YEAR = "20" + YEAR;
         }    
    }

    if(parseInt(MONTH)< 10 && MONTH.toString().length < 2){
           MONTH = "0" + MONTH;
    }

    if(parseInt(DAY)< 10 && DAY.toString().length < 2)
    {
         DAY = "0" + DAY;
    }

    switch (FormatAs){
         case "dd/mm/yyyy":
         return DAY + "/" + MONTH + "/" + YEAR;

         case "mm/dd/yyyy":
         return MONTH + "/" + DAY + "/" + YEAR;
                
         case "dd/mmm/yyyy":
         return DAY + " " + arrMonths[MONTH -1].substring(0,3) + " " + YEAR;
                
         case "mmm/dd/yyyy":
         return arrMonths[MONTH -1].substring(0,3) + " " + DAY + " " + YEAR;
                
         case "dd/mmmm/yyyy":
         return DAY + " " + arrMonths[MONTH -1] + " " + YEAR;   
                
         case "mmmm/dd/yyyy":
         return arrMonths[MONTH -1] + " " + DAY + " " + YEAR;
    }

    return DAY + "/" + strMONTH + "/" + YEAR;

} //End Function


// Begin Bug: 349911 rev 3

/////////
// Autonomy search integration
//
       //This function is for displaying the available Reviewer List objects
       function showECReviewerList()
       {
           var objCommonAutonomySearch = new emxCommonAutonomySearch();

            objCommonAutonomySearch.field = "TYPES=type_RouteTemplate:CURRENT=policy_Organization.state_Active:ROUTE_BASE_PURPOSE=Review";
            objCommonAutonomySearch.selection = "single";
            objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitECReviewerList"; 
                
            objCommonAutonomySearch.open();
       }
       function submitECReviewerList (arrSelectedObjects) {
            var objForm = document.forms["editDataForm"];
            if (!objForm) {
                return;
            }
            
            for (var i = 0; i < arrSelectedObjects.length; i++) {
                var objSelection = arrSelectedObjects[i];
                
                if (objForm.elements["ReportedAgainst"]) {
                    objForm.elements["ReportedAgainst"].value = objSelection.objectId;
                }
                if (objForm.elements["ReportedAgainstOID"]) {
                    objForm.elements["ReportedAgainstOID"].value = objSelection.objectId;
                }
                if (objForm.elements["ReportedAgainstDisplay"]) {
                    objForm.elements["ReportedAgainstDisplay"].value = objSelection.name;
                }
                
                break;
            }
        }

       //This function is for displaying the available Approval List objects
       function showECApprovalList()
       {
           var objCommonAutonomySearch = new emxCommonAutonomySearch();

            objCommonAutonomySearch.field = "TYPES=type_RouteTemplate:CURRENT=policy_Organization.state_Active:ROUTE_BASE_PURPOSE=Approval";
            objCommonAutonomySearch.selection = "single";
            objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitECApprovalList"; 
                
            objCommonAutonomySearch.open();
       }
       function submitECApprovalList (arrSelectedObjects) {
            var objForm = document.forms["editDataForm"];
            if (!objForm) {
                return;
            }
            
            for (var i = 0; i < arrSelectedObjects.length; i++) {
                var objSelection = arrSelectedObjects[i];
                
                if (objForm.elements["ApprovalList"]) {
                    objForm.elements["ApprovalList"].value = objSelection.objectId;
                }
                if (objForm.elements["ApprovalListDisplay"]) {
                    objForm.elements["ApprovalListDisplay"].value = objSelection.name;
                }
                
                break;
            }
        }
//
// Autonomy search integration
///////////

// End Bug: 349911 rev 3

//Added for Full Search configuration for owner
strPersonFormFieldName = "txtOwner";
function showPersonSelector()
{
      var objCommonAutonomySearch = new emxCommonAutonomySearch();
      objCommonAutonomySearch.txtType = "type_Person";
      objCommonAutonomySearch.selection = "single";
      objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner"; 
      objCommonAutonomySearch.open();

}
function submitAutonomySearchOwner(arrSelectedObjects) 
{
   
      var objForm = document.forms["editDataForm"];
      var displayElement = objForm.elements[strPersonFormFieldName + "Display"];
      var hiddenElement1 = objForm.elements[strPersonFormFieldName];
      var hiddenElement2 = objForm.elements[strPersonFormFieldName + "OID"];

      for (var i = 0; i < arrSelectedObjects.length; i++) 
      { 
         var objSelection = arrSelectedObjects[i];
         displayElement.value = objSelection.name;
         hiddenElement1.value = objSelection.name;
         hiddenElement2.value = objSelection.objectId;
 
         break;
      }      
}
//Added:4-Nov-08:oef:R207:PRG Resource Planning 
function showResourceManagerSelector()
    {
        var objCommonAutonomySearch = new emxCommonAutonomySearch();

       objCommonAutonomySearch.txtType = "type_Person";
       objCommonAutonomySearch.selection = "multiple";
       objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchResourceManager"; 
       objCommonAutonomySearch.excludeOIDprogram = "emxOrganization:getExcludeOIDForResourceManagerSearch";
       objCommonAutonomySearch.open();
    
    }
    
    function submitAutonomySearchResourceManager(arrSelectedObjects) 
    {

        var objForm = document.forms["editDataForm"];
        
        var displayElement = objForm.elements["ResourceManagerDisplay"];
        var hiddenElement = objForm.elements["ResourceManagerOID"];

        displayElement.value = "";
        hiddenElement.value = "";

        for (var i = 0; i < arrSelectedObjects.length; i++) 
        { 
            var objSelection = arrSelectedObjects[i];
            
            if (displayElement.value != "") {
                displayElement.value += ",";
            }
            if (hiddenElement.value != "") {
                hiddenElement.value += ",";
            }
            
            displayElement.value += objSelection.name;
            hiddenElement.value += objSelection.objectId;
        }
    }    

    
    function showBusinessSkillTypeSelector()
    {
           var sURL    = '../common/emxTypeChooser.jsp?fieldNameDisplay=TypeDisplay';
           sURL        = sURL + '&fieldNameActual=TypeOID&formName=editDataForm&SelectType=single';
           sURL        = sURL + '&SelectAbstractTypes=true&InclusionList=<%=strBaseSkillType%>&ObserveHidden=true';
           sURL        = sURL + '&SuiteKey=Components&ShowIcons=true';
           showChooser(sURL,500,400);
    }


    //Validate Currency rate
    function validateCurrencyValue()
    {       
        var returnFlag = true;     
        var strRate = trimWhitespace(document.forms[0].Rate.value);  
          
        if (strRate == "" || isNaN(strRate) || ((strRate)<=0) ) {
          var decimalQtySetting = emxUIConstants.DECIMAL_QTY_SETTING;

          if(strRate.contains(decimalQtySetting)){
            strRate=strRate.replace(decimalQtySetting,".");
            if(!isNaN(strRate) && strRate != "" && !((strRate)<=0)){
              strRate=strRate.replace(".",decimalQtySetting);
            } else {
				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertNumber</emxUtil:i18nScript>");
                returnFlag = false;
			}
          } else{
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertNumber</emxUtil:i18nScript>");
                returnFlag = false;
          }
        }else if (strRate.length>15 ) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertCurrencyRateLengthExceeded</emxUtil:i18nScript>");
          returnFlag = false;
        }
        if( !returnFlag ){
    	   document.forms[0].Rate.focus();
       }       
       return returnFlag;
    }
        

//End:R207:PRG Resource Planning 

//Added:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning
    function validateStandardCost() {
        var standardCostValue = document.forms[0].StandardCost.value;
        if (isNaN(standardCostValue))
         {
        	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.StandardCost.EnterNumericValue</emxUtil:i18nScript>");
           return false;
         } 
         else if (parseInt(standardCostValue,10) < 0 )
         {
        	 alert("<emxUtil:i18nScript localize="i18nId">emxComponents.StandardCost.EnterPositiveValue</emxUtil:i18nScript>");
           return false;
         }
         else{
             return true;    
         }
        
    }
  //End:01-June-2010:s4e:R210 PRG:AdvanceResourcePlanning       

  function routeTemplateEditScopeClearAll()
{
	var objForm = document.forms["editDataForm"];
    <%
	String strSelectScope = EnoviaResourceBundle.getProperty(context,ResFormFileId,context.getLocale(), "emxComponents.CreateRoute.SelectScope"); 
	com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
	boolean hasEnterpriseAccess = false;
	if(person.hasRole(context,DomainObject.ROLE_ORGANIZATION_MANAGER) || person.hasRole(context,DomainObject.ROLE_COMPANY_REPRESENTATIVE))
	{
 	 hasEnterpriseAccess = true;
	} %>
     objForm.txtWSFolder.value="<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>";
     objForm.folderId.value="";
     objForm.ellipseButton.disabled=true;

    <%
     if (hasEnterpriseAccess)
     {
     %>
       objForm.organization.value = "";
       objForm.organizationId.value = "";
       objForm.selectOrganization.disabled=true;    
    <%
     }
    %>
}

  function setRouteTemplateEditOrganization() {
  var objForm = document.forms["editDataForm"];
  <%
  String templateId  = emxGetParameter(request, "objectId");
  if(UIUtil.isNotNullAndNotEmpty(templateId)){
  com.matrixone.apps.common.RouteTemplate boRouteTemplate = (com.matrixone.apps.common.RouteTemplate)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TEMPLATE);
  boRouteTemplate.setId(templateId);
  SelectList selectStmts = new SelectList(7);
  selectStmts.addElement("to[" + boRouteTemplate.RELATIONSHIP_OWNING_ORGANIZATION + "].from.name");
  selectStmts.addElement("to[" + boRouteTemplate.RELATIONSHIP_OWNING_ORGANIZATION + "].from.id");
  selectStmts.addElement("owner");
  Map resultMap = boRouteTemplate.getInfo(context, selectStmts);
  String sOwningOrganization = (String)resultMap.get("to["+boRouteTemplate.RELATIONSHIP_OWNING_ORGANIZATION+"].from.name");
  String sOwningOrganizationId = (String)resultMap.get("to["+boRouteTemplate.RELATIONSHIP_OWNING_ORGANIZATION+"].from.id");
  String owner                 = (String)resultMap.get("owner");
  String companyName = "";
  String companyId = "";
  if(UIUtil.isNullOrEmpty(sOwningOrganization)&&UIUtil.isNullOrEmpty(sOwningOrganizationId) && boRouteTemplate.isKindOf(context,DomainConstants.TYPE_ROUTE_TEMPLATE)){
 	com.matrixone.apps.common.Person routeOwnerObj = com.matrixone.apps.common.Person.getPerson(context,owner);
  	com.matrixone.apps.common.Company ownerCompany = routeOwnerObj.getCompany(context);
	companyName = ownerCompany.getName();
	companyId = ownerCompany.getId();
  }else{
	companyName = sOwningOrganization;
	companyId = sOwningOrganizationId;
  }
  %>
    objForm.organization.value = "<%=companyName%>";
    objForm.organizationId.value = "<%=companyId%>";
    objForm.ellipseButton.disabled=true;

    objForm.txtWSFolder.value="<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>";
    objForm.folderId.value="";
    objForm.selectOrganization.disabled=false;  
  <%
  }
  %>  

  }
  
      function setRouteTemplateEditAvailability()
     {
        var objForm = document.forms["editDataForm"];
	    objForm.txtWSFolder.value="<%=XSSUtil.encodeForJavaScript(context, strSelectScope)%>";
	    objForm.folderId.value="";

		<%
        if(FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null))
           {
		%>  
			objForm.ellipseButton.disabled=false;
		<%
			}

          if( hasEnterpriseAccess)
          {
       %>
               objForm.organization.value = "";
               objForm.organizationId.value = "";
               objForm.selectOrganization.disabled=true;    
      <%
           }
       %>

  }
  
    function showRouteTemplateEditWSChooser() {
      showModalDialog("../common/emxIndentedTable.jsp?expandProgram=emxWorkspace:getWorkspaceFoldersForSelection&table=TMCSelectFolder&program=emxWorkspace:getDisabledWorkspaces&header=emxComponents.CreateRoute.SelectAvailability&submitURL=../components/emxCommonSelectWorkspaceFolderProcess.jsp&cancelLabel=Cancel&submitLabel=Done&type=Route Template&suiteKey=Components", 650, 500);
    }

    function showRTEditOrganizationChooser() {
	  <%
	  com.matrixone.apps.common.Company company = person.getCompany(context);
	  String companyName = company.getName();
	  String companyId = company.getId();
	  %>
	  var organizationURL = "../components/emxComponentsSelectOwningOrganizationDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, companyId)%>&fieldName=organization&fieldId=organizationId&selectParent=true";
      showModalDialog(organizationURL, 650, 500);
  }
  
  function checkDefaultAssigneeSelectionOnLoad()
  {
	var role = findFrame(getTopWindow(),"slideInFrame").document.getElementById("taskRole").value;
	if(null != role && role.indexOf("role_") == 0)
			document.editDataForm.AssigneeSelection.checked=true;
	else
	document.editDataForm.AssigneeSelection[0].checked=true;
  }
  
  function cleardate(defaultTime) {
   document.editDataForm.DueDate.value="";
	 var sCombo = document.getElementById("routeTime");
           for ( var z = 0; z < sCombo.options.length; z++ ) {
             if(sCombo.options[z].value==defaultTime) {
               sCombo.options[z].selected=true;
               break;
             }
           }
  }
  
  function validateDepartmentName(fieldName) {
  		if(!fieldName) {
			 fieldName=this;
   		}
  		var isNameValid = validateName(fieldName);
  		if(!isNameValid)
  			return false;
	  	return validateOrgName(getOrgCurrentValueFromFieldName(fieldName), trim(fieldName.value));		
  }
  
  function getOrgCurrentValueFromFieldName(fieldName) {
  	var oldValueFieldName = fieldName.name +"fieldValue";
  	var oldValueField = getTopWindow().document.getElementsByName(oldValueFieldName)[0];
  	oldValueField = oldValueField == null ? document.forms[0][oldValueFieldName] : oldValueField;
  	return oldValueField.value;
  }
  
  function validateCompanyName(fieldName) {
   		if(!fieldName) {
			 fieldName=this;
   		}
  		var isNameValid = checkBadNameChars(fieldName);
  		if(!isNameValid)
  			return false;
	  	return validateOrgName(getOrgCurrentValueFromFieldName(fieldName), trim(fieldName.value));	
  }
  
  function validateBusinessUnitName(fieldName) {
   		if(!fieldName) {
			 fieldName=this;
   		}
  		var isNameValid = checkBadNameCharsIncludesApostrophe(fieldName);
  		if(!isNameValid)
  			return false;
	  	return validateOrgName(getOrgCurrentValueFromFieldName(fieldName), trim(fieldName.value));	
  }
  
    function validatePlantName(fieldName) {
   		if(!fieldName) {
			 fieldName=this;
   		}
  		var isNameValid = checkBadNameChars(fieldName);
  		if(!isNameValid)
  			return false;
	  	return validateOrgName(getOrgCurrentValueFromFieldName(fieldName), trim(fieldName.value));	
  }
  
  function validateOrgName(orgOldName, orgCurrentName) {
  	    if(orgOldName == orgCurrentName)
  	    	return true;
	  	var url = "../components/emxComponentsOrgNameCheck.jsp?orgName=" + encodeURIComponent(orgCurrentName);	
	  	var xmlResult = emxUICore.getXMLData(url);
	    try{
	        var root = xmlResult.documentElement;
			var resultNodeVal = emxUICore.getText(emxUICore.selectSingleNode(root, "/mxOrgNameCheck/result"));
			if(resultNodeVal == "success") {
				return true;
			} else {
				var messageNodeVal = emxUICore.getText(emxUICore.selectSingleNode(root, "/mxOrgNameCheck/errorMsg"));
				alert(messageNodeVal);
				return false;
			} 
	    } catch(e){
	    	return true;
	    }  	
	}
  
  
  //Validating Name Field in Location Page
	function validateName(fieldName)
	{
		if(!fieldName) {
			fieldName=this;
		}
		var namebadCharName = checkForNameBadCharsList(fieldName);
		
		if (fieldName.value.length == 0 || fieldName.value == "") {
		  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.DepartmentDialog.EnterName</emxUtil:i18nScript>");
		  return false;
		} else if (namebadCharName.length != 0) {
		  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
		  return false;
		} else {
		  return true;
		}
		return true;
	}
	//Validating Postal Code Field in Location Page
	function validateLocationPostalCode()
	{	
		var sLocPostCode = document.forms["editDataForm"]["Postal Code"];
		if (!(isAlphanumeric( trim(sLocPostCode.value), true))) {
			  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.LocationDialog.PleaseTypePostCode</emxUtil:i18nScript>");
			  sLocPostCode.focus();
			  return false;
		} else if ( sLocPostCode.value < 0 ) {
			  alert("<emxUtil:i18n localize='i18nId'>emxComponents.LocationDialog.PostalCode</emxUtil:i18n> <emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.PositiveNumber</emxUtil:i18nScript>");
			  sLocPostCode.focus();
			  return false;
		}
		return true;
	}  
	// start
	function validateDeptCageCode()
	{
		var namebadCharName = checkForNameBadCharsList(this);
		
		if (namebadCharName.length != 0) {
		  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
		  return false;
		} else if( ("true" == "<%=isUniqueCageCode%>") && trim(this.value)=="" ) {
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CompanyDialog.EnterCageCode</emxUtil:i18nScript>");
			return false;
		} else {
			return true;
		}
		return true;
	} 

	function validateDeptId()
	{
		var namebadCharName = checkForNameBadCharsList(this);
		
		if (this.value.length == 0 || this.value == "") {
		  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.DepartmentDialog.EnterDepartmentId</emxUtil:i18nScript>"); 
		  return false;
		} else if (namebadCharName.length != 0) {
		  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
		  return false;
		} else {
		  return true;
		}
		return true;
	}

	function validateDeptWebSite()
	{
		if (validateURL(this) && isWebsiteContainsSpace(this)) {
			return true;
		} else {
			return false;
		}
		return false;    
	}
	
	function validateSelector()
	{
		if(this.value.length <= 0) {
        	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.SelectorEmpty</emxUtil:i18nScript>");
            return false;        
		} else if (!checkBadChars(this)) {
		  	return false;
		} else {
			return true;
		}
		return true;        
	}

  	function inboxTaskChangeAssigneeChooser() {
  		var role = findFrame(getTopWindow(),"slideInFrame").document.getElementById("taskRole").value;
		if(null != role && role.indexOf("role_") == 0 )
		{
			if(document.editDataForm.AssigneeSelection.checked) {
  				if(document.editDataForm.AssigneeSelection.value == "Person") {
  					var url = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE="+role+"&showInitialResults=false&txtType=type_Person&mandatorySearchParam=txtType&table=AEFGeneralSearchResults&form=AEFSearchPersonForm&mode=Chooser&selection=single&fieldNameActual=NewAssignee&fieldNameDisplay=NewAssigneeDisplay&fieldNameOID=NewAssigneeOID&submitURL=../common/AEFSearchUtil.jsp&HelpMarker=emxhelpsearch&suiteKey=Components";
  				}
  			}
		}
		else
		{
		if(document.editDataForm.AssigneeSelection[0].checked) {
  			if(document.editDataForm.AssigneeSelection[0].value == "Person") {
  				var objectId = findFrame(getTopWindow(),"slideInFrame").document.getElementsByName("objectId")[0].value;
  				var url = "../common/emxFullSearch.jsp?fieldQueryProgram=emxRoute:getChangeAssigneeRefinements&showInitialResults=false&txtType=type_Person&contextObjectId="+objectId+"&mandatorySearchParam=txtType&table=AEFGeneralSearchResults&form=AEFSearchPersonForm&mode=Chooser&selection=single&fieldNameActual=NewAssignee&fieldNameDisplay=NewAssigneeDisplay&fieldNameOID=NewAssigneeOID&submitURL=../common/AEFSearchUtil.jsp&HelpMarker=emxhelpsearch&suiteKey=Components";
  			}
  		}
  		if(document.editDataForm.AssigneeSelection[1].checked) {
  			if(document.editDataForm.AssigneeSelection[1].value == "User Group") {
  				if(<%=UINavigatorUtil.isCloud(context)%>){
  					var url = "../common/emxFullSearch.jsp?showInitialResults=true&table=AEFUserGroupsChooser&selection=single&form=AEFSearchUserGroupsForm&cmdName=addUserGroups&field=TYPES=type_Group:CURRENT=policy_Person.state_Active&HelpMarker=emxhelpsearch&editLink=false&fieldNameActual=NewAssignee&fieldNameDisplay=NewAssigneeDisplay&suiteKey=Components&submitURL=../common/AEFSearchUtil.jsp";
  				}else{
  					var url = "../common/emxFullSearch.jsp?showInitialResults=true&table=AEFUserGroupsChooser&selection=single&form=AEFSearchUserGroupsForm&cmdName=addUserGroups&field=TYPES=type_Group:CURRENT=policy_Person.state_Active&HelpMarker=emxhelpsearch&editLink=false&fieldNameActual=NewAssignee&fieldNameDisplay=NewAssigneeDisplay&suiteKey=Components&submitURL=../common/AEFSearchUtil.jsp";
  	  			}
  			}else if(document.editDataForm.AssigneeSelection[1].value == "Group") {
  				var url = "../common/emxIndentedTable.jsp?table=APPGroupSummary&program=emxGroupUtil:getGroupSearchResults&editLink=false&toolbar=APPGroupSearchToolbar&selection=single&objectCompare=false&HelpMarker=emxhelpselectgroup&header=emxComponents.AddGroups.SelectGroups&displayView=details&multiColumnSort=false&fieldNameActual=NewAssignee&fieldNameDisplay=NewAssigneeDisplay&suiteKey=Components&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&customize=false&submitURL=../components/emxComponentsChangeAssigneeProcess.jsp";
  			}
  		}
		}
  		
		showChooser(url,700,600);
	}
  	
	
	function clearNewAssigneeField() {
		document.editDataForm.NewAssigneeDisplay.value="";
	}
	function validateSubjectFieldInDiscussion() {
		if(!(isValidLength(this.value, 1,128))) {
        	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateDiscussionDialog.EnterSubject</emxUtil:i18nScript>");
            return false;
      	} else if(!checkBadNameChars(this)) {        	
        	return false;
        } else {
            return true;
        }
      	return true;
	}

	function validateFromCurrency() {
		var strFromCurrency = document.forms[0].FromCurrency.value;
		var strToCurrency = document.forms[0].ToCurrency.value;
        if(strToCurrency == strFromCurrency)
        {
        	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CurrencyConversion.AddNewExchangeRate</emxUtil:i18nScript>");
            document.forms[0].FromCurrency.value = "";
            document.forms[0].FromCurrency.focus();
            return false;
        }
        else
        {
            return true;
        }
    }
	
	function validateToCurrency() {
        var strFromCurrency = document.forms[0].FromCurrency.value;
        var strToCurrency = document.forms[0].ToCurrency.value;
        if(strToCurrency == strFromCurrency)
        {
        	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CurrencyConversion.AddNewExchangeRate</emxUtil:i18nScript>");
            document.forms[0].ToCurrency.value = "";
            document.forms[0].ToCurrency.focus();
            return false;
        }
        else
        {
            return true;
        }
    }

	function clearMessageInDiscussionReply()
	{
	    document.getElementById("Message").value= "";
	}
	//Checking for Positive Integer value of the field, if a value is entered
	function checkPositiveIntegerIfEntered(fieldname)
	{
	    if(!fieldname) {
	        fieldname=this;
	    }    

	    if(fieldname.value!='' &&  (isNaN(fieldname.value) || fieldname.value < 0 || parseInt(fieldname.value) != fieldname.value) )
	    {
	    	//XSSOK
	        msg = "<%=i18nNow.getI18nString("emxComponents.Alert.IntegerPositive",bundle,acceptLanguage)%>";
	        alert(msg);
	        fieldname.focus();
	        return false;
	    }
	    return true;
	}
	function taskCommentValidation(){
		var textAreaValue = this.value;
		var comboBoxId = this.id.replace("Comments","Approval Status");		
		var action = jQuery("form[name=editDataForm]").find("select[id='"+comboBoxId+"']").val();
		if( action != "No Action" && (("true" == "<%=ShowCommentsForTaskApproval%>" && (action == "Approve" || action == "Abstain")  && emxUIConstants.TASK_COMMENT_REQUIRED) || ("false" == "<%=IgnoreCommentsForRejection%>" && action == "Reject" && emxUIConstants.TASK_COMMENT_REQUIRED) || (action == "Complete"))){	
			if(!/([^\s])/.test(textAreaValue)){
				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.FillComments</emxUtil:i18nScript>");
				this.focus();
				return false;
			}
		}
		return true;
	}
	
	function clearApprovalAndAbstainTaskComments(val,id)
	{
		var element = document.getElementById(val);
		var strValue = element.options[element.selectedIndex].text;
		if(("false" == "<%=ShowCommentsForTaskApproval%>" && strValue === 'Approve' || strValue === 'Abstain') || ("true" == "<%=IgnoreCommentsForRejection%>" && strValue === 'Reject')){			
			document.getElementById('Comments'+id+'Id').value = "";
			document.getElementById('Comments'+id+'Id').disabled = true;
		}
		else{
			document.getElementById('Comments'+id+'Id').disabled = false;
		}
	}
	
	function convertTime12to24(time12h) {
		var timeModifier = time12h.split(' ');
	  	var splitTime= time12h.split(':');
		var hours = splitTime[0];
		if (hours === '12') {
			hours = '00';
		}
  		if (timeModifier[1]=== 'PM') {
			hours = parseInt(hours, 10) + 12;
		}
  		return hours + ':' + splitTime[1];
	}

	function validateTaskDueDate(){
		var assignedDateTime = "";
		var assignedDate = document.getElementById("DueDate_msvalue");
		var assignedTime = document.getElementById("routeTime")
		var taskTime = assignedTime.options[assignedTime.selectedIndex].value
		if(taskTime.indexOf("AM") != -1 || taskTime.indexOf("PM") != -1){
			var taskTime  = convertTime12to24(taskTime);
		}
		var hhmm = taskTime.split(":");
		assignedDateTime  = new Date(Number(assignedDate.value));
		assignedDateTime.setHours(hhmm[0]);
		assignedDateTime.setMinutes(hhmm[1]);
		if(Date.parse(assignedDateTime.toGMTString()) < Date.parse(todayDate.toGMTString())){
			alert("<emxUtil:i18nScript localize="i18nId">emxComponents.EditTaskDetails.DateMessage</emxUtil:i18nScript>" );
			return false;
		}else{
			return true;
		}
	}
//-->
</SCRIPT>

<%--  emxProgramCentralUIFormValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxProgramCentralUIFormValidation.jsp.rca 1.10 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $

 --%>

<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.matrixone.apps.program.fiscal.*"%>
<%@page import="java.util.Calendar"%>


<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ page import="java.util.*" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat" %>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Calendar"%>
<%@ include file="emxProgramTags.inc" %>


<%
boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
String changeProjectType = com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,"type_ChangeProject");
String strmode = emxGetParameter(request,"strmode");
if(strmode!=null)
{
        if(strmode.equalsIgnoreCase("getWeek"))
        {
        	String date = emxGetParameter(request,"date");
        	String month = emxGetParameter(request,"month");
        	String year = emxGetParameter(request,"year");
        	String day = emxGetParameter(request,"day");
        	
        	java.util.Calendar calendar = Calendar.getInstance();
            calendar.set(Integer.parseInt(year), Integer.parseInt(month), Integer.parseInt(date));
            
            if(day.equals("0")){
            	calendar.add(Calendar.DATE,-1);
            }
            
            calendar.setFirstDayOfWeek(Calendar.MONDAY);
            calendar.setMinimalDaysInFirstWeek(4);
            Date tempDate = calendar.getTime();
            int week= calendar.get(Calendar.WEEK_OF_YEAR);
            
            out.clear();
            out.write(String.valueOf(week));
            out.flush();
            return;

        }
        if("maxLengthError".equalsIgnoreCase(strmode))
        {        	
            String strMaxLength = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.ProjectImport.FieldExceedsMaxLength", context.getSession().getLanguage());
            out.clear();
            out.write(strMaxLength);
            out.flush();
            return;
        }

        if(strmode.equalsIgnoreCase("getFormattedDates"))
        {
        	String startDate = emxGetParameter(request,"startDate");
        	String endDate = emxGetParameter(request,"endDate");
        	
        	String startDateInMillis = String.valueOf(new Date(startDate).getTime());
        	String endDateInMillis = String.valueOf(new Date(endDate).getTime());
        	
        	Locale locale = (Locale)request.getLocale();
        	String timeZone = (String)session.getAttribute("timeZone");
        	
        	startDate = eMatrixDateFormat.getDateValue(context, startDateInMillis, timeZone, locale);
        	endDate = eMatrixDateFormat.getDateValue(context, endDateInMillis, timeZone, locale);
        	
        	out.clear();
        	out.write(startDate.trim() + "|" + endDate.trim());
        	out.flush();
			return;        	
        }
}
%>

<%@page import="com.matrixone.apps.program.fiscal.Iterator"%>
<%@page import="com.matrixone.apps.program.fiscal.Helper"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
<SCRIPT LANGUAGE="JavaScript">
var changeProject ="<%=changeProjectType%>";
//End:7-Jun-10:AK4R210:ECH:Bug:035621
/**
* function validateTaskReq(
* Validate Task requirement Value for the change task
*/
function validateTaskReq() {
	<%if(isECHInstalled){%>
		var isChangeTask = document.getElementById("ECHChangeTask").value;
		if(isChangeTask == "true") {
			var taskReqVal = document.getElementById("TaskRequirementId").value;
			if("Mandatory" != taskReqVal) {
				alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.EnterpriseChange.TaskRequirementMandatory</emxUtil:i18nScript>");
				return false;
			}
		}
	<%}%>
	return true;
}

/**
* function validateProjectVisibility(
* Validate Project Visibility Value for the change Project
*/
//Added:27-Feb-09:QZV:R207:ECH:Bug:369865
function validateProjectVisibility() {
	<%if(isECHInstalled){%>
		var isChangeObject = "false";
		var actualType = document.getElementsByName("ActualType");

		if(null!=actualType && ""!=actualType && actualType.length>0){
			if(null!=changeProject && ""!=changeProject){
				if(actualType[0].value!=null && actualType[0].value == changeProject){
					isChangeObject = "true";
				}
			}
		}else{
			var typeFieldValue = document.getElementsByName("TypefieldValue");
			if(null!=typeFieldValue && ""!=typeFieldValue && typeFieldValue.length>0){
				if(null!=changeProject && ""!=changeProject){
					if(typeFieldValue[0].value!=null && typeFieldValue[0].value == changeProject){
						isChangeObject = "true";
					}
				}
			}
		}

		if(isChangeObject == "true"){
			var visibility = document.getElementsByName("Visibility");
			if(null!=visibility && ""!=visibility && visibility.length>0){
				if("Members" != visibility[0].value){
					alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.EnterpriseChange.ProjectVisibilityMembers</emxUtil:i18nScript>");
					return false;
				}
			}
		}
	<%}%>
	return true;
}
//End:R207:ECH:Bug:369865

/**
* Added:13-Jan-11:IQA:R211
* function validateChangeDiscipline()
* check that at least one Discipline is selected
*/
function validateChangeDiscipline(){
	<%if(isECHInstalled){%>
		var isChangeObject = "false";
		var actualType = document.getElementsByName("ActualType");
		var isChangeTask = document.getElementById("ECHChangeTask");

		if(null!=actualType && ""!=actualType && actualType.length>0){
			if(null!=changeProject && ""!=changeProject){
				if(actualType[0].value!=null && actualType[0].value == changeProject){
					isChangeObject = "true";
				}
			}
		}else if(null!=isChangeTask && ""!=isChangeTask){
			if(isChangeTask.value!=null && isChangeTask.value == "true"){
				isChangeObject = "true";
			}
		}

		if(isChangeObject == "true"){
			var disciplinePassed = "false";
			<%
			String strInterfaceName = PropertyUtil.getSchemaProperty(context,"interface_ChangeDiscipline");
			if(strInterfaceName!=null && !strInterfaceName.isEmpty()){
				BusinessInterface busInterface = new BusinessInterface(strInterfaceName, context.getVault());
				AttributeTypeList listInterfaceAttributes = busInterface.getAttributeTypes(context);

				for(int j=0;j<listInterfaceAttributes.size();j++){
				  String attrName = ((AttributeType) listInterfaceAttributes.get(j)).getName();
				  String attrNameSmall = attrName.replaceAll(" ", "");
				  String attrNameSmallHidden = attrNameSmall + "Hidden";
					%>
					var disciplineValue = document.getElementById("<%=XSSUtil.encodeForJavaScript(context,attrNameSmallHidden)%>").value;
					if(disciplineValue=="Yes"){
						disciplinePassed = "true";
					}
					<%
				}
				%>
				if(disciplinePassed=="false"){
					alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ChangeProject.SelectChangeDiscipline</emxUtil:i18nScript>");
					return false;
				}
			<%}%>
		}
	<%}%>
	return true;
}
//End Add:13-Jan-11:IQA:R211

//Checking for Positive Integer value of the field
function checkPositiveInteger()
{
  var txtField=trimWhitespace(this.value);
  this.value = txtField;
  if(isNaN(txtField))
  {

    alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.checkNumeric</emxUtil:i18nScript>");
    this.focus();
    return false;

  }
  else if(parseInt(txtField) < 0)
  {

    alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.NegativeAlert</emxUtil:i18nScript>");
    this.focus();
    return false;

  }
  else if(txtField.length==0)
  {
    var isBlank = confirm("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.ZeroAlert</emxUtil:i18nScript>");
    if(isBlank){
      txtField=0;
      this.value = txtField;
    }else{
      this.focus();
      return false;
    }
  }

  return true;
}

/*External Cross project Dependency*/
function checkAll (allbox, chkprefix) {

  form = allbox.form;
  max = form.elements.length;
  for (var i=0; i<max; i++) {
    fieldname = form.elements[i].name;
    if (fieldname.substring(0,chkprefix.length) == chkprefix) {
      form.elements[i].checked = allbox.checked;
    }
  }
}
/*External Cross project Dependency*/

function checkFieldLength(){
  var txtField=trimWhitespace(this.value);
  var fieldLengthMax = 127;
  var i;
  var asciiCount = 0;
  var unicodeCount = 0;
  for (i = 0; i < txtField.length; i++) {
    var charValue = txtField.charCodeAt(i);
    if (charValue < 256) {
      asciiCount++;
    } else {
      unicodeCount++;
    }
  }
  var byteCount = (unicodeCount * 4) + asciiCount;
  if (byteCount > fieldLengthMax) {
    this.focus();
    alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.ProjectImport.FieldExceedsMaxLength</emxUtil:i18nScript>");
    return;
  } else {
    return true;
  }
  return true;
}

function validateEfforts(effort){
//Added:30-march-09:nr2:R207:PRG Bug :368775
	if(isNaN(effort) || effort.length == 0){
	     alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.InvalidEfforts</emxUtil:i18nScript>");
	     return true;
	     }
//End:R207:PRG Bug :368775

	 var fltVal = parseFloat(effort);
     if(fltVal <0 || fltVal>24){
     alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.InvalidEfforts</emxUtil:i18nScript>");
     return true;
     }else{
     return false;
     }
	}

function updateFields() {
    var form_obj = document.emxTableForm;
    var sun = trimWhitespace(form_obj.sun.value);
    if (isNaN(sun) || sun.length==0)
    {
       sun=0;
       form_obj.sun.value=sun;
    }

    var org_total = form_obj.originalremainingEffort.value;
    var mon = trimWhitespace(form_obj.mon.value);
    if (isNaN(mon) || mon.length==0)
    {
       mon=0;
       form_obj.mon.value=mon;
    }

    var tue = trimWhitespace(form_obj.tue.value);
    if (isNaN(tue) || tue.length==0)
    {
       tue=0;
       form_obj.tue.value=tue;
    }
    var wed = trimWhitespace(form_obj.wed.value);
    if (isNaN(wed) || wed.length==0)
    {
       wed=0;
       form_obj.wed.value=wed;
    }
    var thu = trimWhitespace(form_obj.thru.value);
    if (isNaN(thu) || thu.length==0)
    {
       thu=0;
       form_obj.thru.value=thu;
    }
    var fri = trimWhitespace(form_obj.fri.value);
    if (isNaN(fri) || fri.length==0)
    {
       fri=0;
       form_obj.fri.value=fri;
    }
    var sat = trimWhitespace(form_obj.sat.value);
    if (isNaN(sat) || sat.length==0)
    {
       sat=0;
       form_obj.sat.value=sat;
    }

     var subtotal = parseInt(mon,10) + parseInt(tue,10) + parseInt(wed,10) + parseInt(thu,10) + parseInt(fri,10) + parseInt(sat,10) + parseInt(sun,10);
     org_total=parseInt(org_total,10);
     var results = org_total-subtotal;
     if(results < 0 )
     {
     results=0;
     }
     form_obj.remain.value=results;
    }

    //ADDED FOR FIXING 356897
    function updateFieldsEfforts() {

        var form_obj = document.editDataForm;
        var sun = trimWhitespace(form_obj.Sun.value);
//Added:30-march-09:nr2:R207:PRG Bug :368775
        var org_total = form_obj.originalremainingEffort.value;
        var org_sun = form_obj.dbSun.value;

        if (validateEfforts(sun) || isNaN(sun) || sun.length == 0) {
            //sun = 0;
            sun = org_sun;
            form_obj.Sun.value = sun;
        }
//End:R207:PRG Bug :368775
        var org_mon = form_obj.dbMon.value;
        var org_tue = form_obj.dbTue.value;
        var org_wed = form_obj.dbWed.value;
        var org_thu = form_obj.dbthu.value;
        var org_fri = form_obj.dbFri.value;
        var org_sat = form_obj.dbsat.value;
        var diff_sun = parseInt(sun, 10) - parseInt(org_sun, 10) ;
        var mon = trimWhitespace(form_obj.Mon.value);

//Comment Added By Nishant
	//if (isNaN(sun) || sun.length==0 || validateEfforts(sun))
	//has been replaced by  if (validateEfforts(sun) || isNaN(sun) || sun.length == 0)
//End

        //if (isNaN(mon) || mon.length == 0 || validateEfforts(mon)) {
       if (validateEfforts(mon) || isNaN(mon) || mon.length == 0) {
            //mon = 0;
            mon = org_mon;
            form_obj.Mon.value = mon;
        }

        var diff_mon = parseInt(mon, 10) - parseInt(org_mon, 10) ;
        var tue = trimWhitespace(form_obj.Tue.value);

        //if (isNaN(tue) || tue.length == 0 || validateEfforts(tue)) {
		if (validateEfforts(tue) || isNaN(tue) || tue.length == 0) {
            //tue = 0;
            tue = org_tue;
            form_obj.Tue.value = tue
        }

        var diff_tue = parseInt(tue, 10) - parseInt(org_tue, 10) ;
        var wed = trimWhitespace(form_obj.Wed.value);

        //if (isNaN(wed) || wed.length == 0 || validateEfforts(wed)) {
		if (validateEfforts(wed) || isNaN(wed) || wed.length == 0) {
            //wed = 0;
            wed = org_wed;
            form_obj.Wed.value = wed;
        }

        var diff_wed = parseInt(wed, 10) - parseInt(org_wed, 10) ;
        var thu = trimWhitespace(form_obj.thu.value);

        //if (isNaN(thu) || thu.length == 0 || validateEfforts(thu)) {
		if (validateEfforts(thu) || isNaN(thu) || thu.length == 0) {
            //thu = 0;
            thu = org_thu;
            form_obj.thu.value = thu;
        }

        var diff_thu = parseInt(thu, 10) - parseInt(org_thu, 10) ;
        var fri = trimWhitespace(form_obj.Fri.value);

        //if (isNaN(fri) || fri.length == 0 || validateEfforts(fri)) {
		if (validateEfforts(fri) || isNaN(fri) || fri.length == 0) {
            //fri = 0;
            fri = org_fri;
            form_obj.Fri.value = fri;
        }

        var diff_fri = parseInt(fri, 10) - parseInt(org_fri, 10) ;
        var sat = trimWhitespace(form_obj.sat.value);

        //if (isNaN(sat) || sat.length == 0 || validateEfforts(sat)) {
        if (validateEfforts(sat) || isNaN(sat) || sat.length == 0) {
            //sat = 0;
            sat = org_sat;
            form_obj.sat.value = sat;
        }

        var diff_sat = parseInt(sat, 10) - parseInt(org_sat, 10) ;
        var subtotal = parseInt(diff_mon, 10) + parseInt(diff_tue, 10) + parseInt(diff_wed, 10) + parseInt(diff_thu, 10) + parseInt(diff_fri, 10) + parseInt(diff_sat, 10) + parseInt(diff_sun, 10);
        org_total = parseInt(org_total, 10);
        var results = org_total - subtotal;

        if (results < 0 ) {
            results = 0;
        }

        form_obj.RemainingEffort.value = results;
    }

//ADDED FOR FIXING 356897 ENDS

	// added for
function modifyRPN() {
      f = document.editDataForm;
      probability = f.Probability.value;
      impact = f.Impact.value;
      f.RPN.value = probability * impact;
	  return true;
    }

// added for to nullify the "ProgramName" field.
function removeProgram() {
    document.forms[0].ProgramId.value = null;
    document.forms[0].ProgramName.value = "";
    return true;
}

// added for to nullify the "BusinessUnitName" field.
function removeBusinessUnit() {
    document.forms[0].BusinessUnitId.value = null;
    document.forms[0].BusinessUnitName.value = "";
    return true;
}

 function performPersonSearchBusinessGoal() {
<%
      //Need to pass targetSearchPage parameter
	  String targetSearchPage = "../programcentral/emxProgramCentralSearchPersonPostProcess.jsp";
      HashMap searchMap = new HashMap();
      searchMap.put("targetSearchPage", targetSearchPage);
      session.setAttribute("personSearchMap", searchMap);
%>
      showModalDialog("../programcentral/emxProgramCentralSearchFS.jsp?mode=personSearch&inCompany=true&whoId=owner&selectMultiple=false&bgOwnerSearch=true", 700, 700, true);
    }

	function performPersonSearch() {
<%
      //Need to pass several parameters to search page
      HashMap searchMapNew = new HashMap();
      searchMapNew.put("targetSearchPage", targetSearchPage);
     // searchMap.put("objectId", strParentObjID);
      session.setAttribute("personSearchMap", searchMapNew);
%>
      showModalDialog("../programcentral/emxProgramCentralSearchFS.jsp?mode=personSearch&whoId=owner&projectLeads=false&selectMultiple=false", 700, 700, true);
    }
//Added:24-July-09:yox:R208:PRG:Bug :368172
  	function checkStartEndDateValidate() {

      var strEstimatedEndDate = document.forms[0].EstimatedEndDate.value;
      var fieldEstimatedEndDate = new Date(strEstimatedEndDate);


      var strEstimatedStartDate = document.forms[0].EstimatedStartDate.value;
      var fieldEstimatedStartDate = new Date(strEstimatedStartDate);



     if(fieldEstimatedStartDate.getTime() > fieldEstimatedEndDate.getTime())
     {
         alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Import.EndDateBeforeStartDate</emxUtil:i18nScript>");
         return false;
      }
      return true;
    }
//End:R208:PRG:Bug :368172


function performProjectLeadsSearch()
{
<%
      searchMapNew.put("targetSearchPage", targetSearchPage);
      session.setAttribute("personSearchMap", searchMapNew);
%>
      showModalDialog("../programcentral/emxProgramCentralSearchFS.jsp?mode=personSearch&projectLeads=true&selectMultiple=false", 700, 700, true);
    }

//Added:10-Dec-09:wqy:R209:PRG:Keyword Duration
function validateKeywordDuration()
{
    var objCount = document.forms[0].objCount.value;
    for(var i=0; i<objCount; i++)
    {
	    var durationVal = document.getElementById("Duration"+i).value;
	    var durationMapVal = document.getElementById("Type"+i+"Id").value;
	    var theDuration = durationVal;
	    if (((!(/^[+]?[0-9]+(\.[0-9]*)?$/.test(durationVal))) && durationMapVal!="SlackTime") ||
	             ((!(/^[+-]?[0-9]+(\.[0-9]*)?$/.test(durationVal)) && durationMapVal=="SlackTime")))
	    {
	        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Task.PleaseEnterOnlyNumbers</framework:i18nScript>");
	        document.getElementById("Duration"+i).focus();
	        return false;
	    }

        if (theDuration != "" && theDuration >= 10000)
        {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseEnterADurationValueLessThan</framework:i18nScript>");
            document.getElementById("Duration"+i).focus();
            return false;
        }
    }
    return true;
}

function validateKeywordDurationForm()
{
    var durationVal = document.getElementById("Duration").value;
    var durationMapVal = document.getElementById("DurationMapId").value;
    var theDuration = durationVal;
    if (((!(/^[+]?[0-9]+(\.[0-9]*)?$/.test(durationVal))) && durationMapVal!="SlackTime") ||
    	     ((!(/^[+-]?[0-9]+(\.[0-9]*)?$/.test(durationVal)) && durationMapVal=="SlackTime")))
    {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Task.PleaseEnterOnlyNumbers</framework:i18nScript>");
        document.getElementById("Duration").focus();
        return false;
    }
	if(theDuration <= 0 && durationMapVal == "WBSTask" ){
    	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeAPositiveReal</framework:i18nScript>");
        document.getElementById("Duration").focus();
        return false;
    }

    if (theDuration != "" && theDuration >= 10000)
    {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseEnterADurationValueLessThan</framework:i18nScript>");
        document.getElementById("Duration").focus();
        return false;
    }
    return true;
}

function validateKeywordNameForm()
{
    var nameVal = document.getElementById("Name").value;
    var functionMode = document.getElementsByName("FunctionMode")[0].value;
    if(null!=document.getElementsByName("FunctionMode")&& "create"==functionMode)
    {
    	var badChars = checkForNameBadCharsList(document.getElementById("Name"));
        if (badChars != "") {
          alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</framework:i18nScript>\n"
                 + badChars + "\n<framework:i18nScript localize="i18nId">emxProgramCentral.Common.RemoveInvalidCharacter</framework:i18nScript>");
          document.getElementById("Name").focus();
          return;
        }
	    var validNameCount = document.getElementById("validNameCount").value;
	    for(var i=0; i<validNameCount; i++)
	    {
	        var validateNameVal = document.getElementById("validateName"+i).value;
	        if(nameVal==validateNameVal)
	        {
	        	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DurationKeywords.NameAlreadyExist</framework:i18nScript>");
	        	document.getElementById("Name").focus();
	            return false;
	        }
	    }
    }
    return true;
}
 //End:R209:PRG :Keyword Duration

function calculateWeekStartAndEndDate() {
    form = document.editDataForm;
    var startDate= getWeekStartDate();
    var endDate = getWeekEndDate();
    var url="../programcentral/emxProgramCentralUIFormValidation.jsp?strmode=getFormattedDates&startDate="+startDate+"&endDate="+endDate;
    var formattedStartAndEndDt = emxUICore.getData(url);
	
    form.WeekStart.value = formattedStartAndEndDt.split("|")[0];
    form.WeekEnd.value =  formattedStartAndEndDt.split("|")[1];
    form.ActualWeekEndDate.value = endDate;
    form.WeekNo.value =  getWeekNumber();
}

Date.prototype.getWeek = function() {
      var onejan = new Date(this.getFullYear(),0,1);
      return Math.ceil((((this - onejan) / 86400000) + onejan.getDay())/7);
}

function getWeekNumber() {
     //Added:30-Sep-2010:vf2:R2012
     var selectWeek = document.forms[0].SelectWeek_msvalue.value;
    //End:30-Sep-2010:vf2:R2012
     var today = new Date();
     today.setTime(selectWeek);

     var date = today.getDate();
     var month = today.getMonth();
     var year = today.getFullYear();
     var day = today.getDay();
   
     var url="../programcentral/emxProgramCentralUIFormValidation.jsp?strmode=getWeek&date="+date;
     url = url + "&month="+month;
     url = url + "&year="+year;
     url = url + "&day="+day;

     var weekNumber=emxUICore.getData(url);
     return weekNumber;
}

function getWeekStartDate() {
    var today = new Date();
    //Added:30-Sep-2010:vf2:R2012
    today.setTime(document.forms[0].SelectWeek_msvalue.value);
    //End:30-Sep-2010:vf2:R2012
    var day = today.getDay();
    var date = today.getDate();
    var month = today.getMonth();
    var year = today.getFullYear();
    var format = 'dd-MMM-yyyy';
    <%
    String language = context.getSession().getLanguage();
    com.matrixone.apps.domain.util.i18nNow i18nnow = new com.matrixone.apps.domain.util.i18nNow();
    String strStartDayOfWeek = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.CompanyStandards.FiscalYear.StartDayOfWeek");
    %>
    var startDayOfWeek = <%=strStartDayOfWeek%>;
    var days = parseInt(day)+ 1 - parseInt(startDayOfWeek);

    if(startDayOfWeek == 1){
        today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
    }else if(startDayOfWeek == 2){
        if(parseInt(day) == 0){
            today = formatDate(new Date(year,month,parseInt((date)-6)),format);
        } else {
            today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
        }
    }else if(startDayOfWeek == 3){
        if(parseInt(day) == 0){
            today = formatDate(new Date(year,month,parseInt((date)-5)),format);
        } else if(parseInt(day) == 1){
            today = formatDate(new Date(year,month,parseInt((date)-6)),format);
        } else {
            today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
        }
    }else if(startDayOfWeek == 4){
        if(parseInt(day) == 0){
            today = formatDate(new Date(year,month,parseInt((date)-4)),format);
        } else if(parseInt(day) == 1){
            today = formatDate(new Date(year,month,parseInt((date)-5)),format);
        } else if(parseInt(day) == 2){
            today = formatDate(new Date(year,month,parseInt((date)-6)),format);
        } else {
            today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
        }
    }else if(startDayOfWeek == 5){
        if(parseInt(day) == 0){
            today = formatDate(new Date(year,month,parseInt((date)-3)),format);
        } else if(parseInt(day) == 1){
            today = formatDate(new Date(year,month,parseInt((date)-4)),format);
        } else if(parseInt(day) == 2){
            today = formatDate(new Date(year,month,parseInt((date)-5)),format);
        } else if(parseInt(day) == 3){
            today = formatDate(new Date(year,month,parseInt((date)-6)),format);
        } else {
            today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
        }
    }else if(startDayOfWeek == 6){
        if(parseInt(day) == 0){
            today = formatDate(new Date(year,month,parseInt((date)-2)),format);
        } else if(parseInt(day) == 1){
            today = formatDate(new Date(year,month,parseInt((date)-3)),format);
        } else if(parseInt(day) == 2){
            today = formatDate(new Date(year,month,parseInt((date)-4)),format);
        } else if(parseInt(day) == 3){
            today = formatDate(new Date(year,month,parseInt((date)-5)),format);
        } else if(parseInt(day) == 4){
            today = formatDate(new Date(year,month,parseInt((date)-6)),format);
        } else {
            today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
        }
    }else if(startDayOfWeek == 7){
        if(parseInt(day) == 0){
            today = formatDate(new Date(year,month,parseInt((date)-1)),format);
        } else if(parseInt(day) == 1){
            today = formatDate(new Date(year,month,parseInt((date)-2)),format);
        } else if(parseInt(day) == 2){
            today = formatDate(new Date(year,month,parseInt((date)-3)),format);
        } else if(parseInt(day) == 3){
            today = formatDate(new Date(year,month,parseInt((date)-4)),format);
        } else if(parseInt(day) == 4){
            today = formatDate(new Date(year,month,parseInt((date)-5)),format);
        } else if(parseInt(day) == 5){
            today = formatDate(new Date(year,month,parseInt((date)-6)),format);
        } else {
            today = formatDate(new Date(year,month,parseInt((date)-(days))),format);
        }
    }
    return today;
}

function getWeekEndDate() {
    var today = new Date();
    //Added:30-Sep-2010:vf2:R2012
    today.setTime(document.forms[0].SelectWeek_msvalue.value);
    //End:30-Sep-2010:vf2:R2012
    var day = today.getDay();
    var date = today.getDate();
    var month = today.getMonth();
    var year = today.getFullYear();
    var format = 'dd-MMM-yyyy';
    var startDayOfWeek =  <%=strStartDayOfWeek%>
    var dayDiff = parseInt(startDayOfWeek)- 1;
    if(startDayOfWeek == 1) {
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date) + 6 + dayDiff),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date) + 5 + dayDiff),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date) + 4 + dayDiff),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date) + 3 + dayDiff),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date) + 2 + dayDiff),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date) + 1 + dayDiff),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date) + 0 + dayDiff),format);
        }
    }else if(startDayOfWeek == 2) {
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date)),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date) + 5 + dayDiff),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date) + 4 + dayDiff),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date) + 3 + dayDiff),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date) + 2 + dayDiff),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date) + 1 + dayDiff),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date) + 0 + dayDiff),format);
        }
    }else if(startDayOfWeek == 3){
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date)+1),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date)),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date) + 4 + dayDiff),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date) + 3 + dayDiff),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date) + 2 + dayDiff),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date) + 1 + dayDiff),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date) + 0 + dayDiff),format);
        }
    }else if(startDayOfWeek == 4){
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date)+2),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date)+1),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date)),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date) + 3 + dayDiff),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date) + 2 + dayDiff),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date) + 1 + dayDiff),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date) + 0 + dayDiff),format);
        }
    }else if(startDayOfWeek == 5){
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date)+3),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date)+2),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date)+1),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date)),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date) + 2 + dayDiff),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date) + 1 + dayDiff),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date) + 0 + dayDiff),format);
        }
    }else if(startDayOfWeek == 6){
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date)+4),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date)+3),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date)+2),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date)+1),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date)),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date) + 1 + dayDiff),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date) + 0 + dayDiff),format);
        }
    }else if(startDayOfWeek == 7){
        if(parseInt(day) == 0) {
            today = formatDate(new Date(year,month,parseInt(date)+5),format);
        } else if(parseInt(day) == 1) {
            today = formatDate(new Date(year,month,parseInt(date)+4),format);
        } else if(parseInt(day) == 2) {
            today = formatDate(new Date(year,month,parseInt(date)+3),format);
        } else if(parseInt(day) == 3) {
            today = formatDate(new Date(year,month,parseInt(date)+2),format);
        } else if(parseInt(day) == 4) {
            today = formatDate(new Date(year,month,parseInt(date)+1),format);
        } else if(parseInt(day) == 5) {
            today = formatDate(new Date(year,month,parseInt(date)),format);
        } else if(parseInt(day) == 6) {
            today = formatDate(new Date(year,month,parseInt(date)+ dayDiff),format);
        }
    }
    return today;
}

function addZero(vNumber){
      return ((vNumber < 10) ? "0" : "") + vNumber;
}

function makeArray() {
    for (i = 0; i<makeArray.arguments.length; i++)
    this[i + 1] = makeArray.arguments[i];
}

function formatDate(vDate, vFormat) {
      var months      = new makeArray('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
      var vDay        = addZero(vDate.getDate());
      var vMonth      = addZero(vDate.getMonth()+1);
      var vYearLong   = addZero(vDate.getFullYear());
      var vYearShort  = addZero(vDate.getFullYear().toString().substring(3,4));
      var vYear       = (vFormat.indexOf("yyyy")>-1?vYearLong:vYearShort);
      var vHour       = addZero(vDate.getHours());
      var vMinute     = addZero(vDate.getMinutes());
      var vSecond     = addZero(vDate.getSeconds());
      var vDateString = "";
      if(vMonth == 08){
    	  vDateString = vFormat.replace('dd', vDay).replace('MMM', months[8]).replace('yyyy', vYear);
      } else if(vMonth == 09) {
    	  vDateString = vFormat.replace('dd', vDay).replace('MMM', months[9]).replace('yyyy', vYear);
      } else {
    	  vDateString = vFormat.replace('dd', vDay).replace('MMM', months[parseInt(vMonth)]).replace('yyyy', vYear);
      }
      vDateString = vDateString.replace(/hh/g, vHour).replace(/mm/g, vMinute).replace(/ss/g, vSecond);
      return vDateString;
}
//Added:28-May-2010:s4e:R210 PRG:ARP
function validateStandardCostFromTable(idx) {

    var standardCostValue = idx.value;
    if (isNaN(standardCostValue))
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.StandardCost.EnterNumericValue</emxUtil:i18nScript>");
       idx.value='0';
      return false;
    }
    else if (parseInt(standardCostValue,10) < 0 )
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.StandardCost.EnterPositiveValue</emxUtil:i18nScript>");
      idx.value='0';
      return false;
    }
    else{
        return true;
    }

}
//End:28-May-2010:s4e:R210 PRG:ARP

//Added:26-Aug-10:VF2:R210:059741
function validateReportingYear() {
    form = document.editDataForm;
    //Added:30-Sep-2010:vf2:R2012
    //var reportingYear = trim(form.elements[1].value);
    var reportingYear = trim(document.forms[0].ReportingYear.value);
    //End:30-Sep-2010:vf2:R2012
    if(reportingYear.charAt(0) == "+"){
         reportingYear =reportingYear.length-1;
    }
    form.ReportingYear.value = reportingYear;
    if(isNaN(reportingYear)) {
       alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheetReports.SelectNumericReportingYear</emxUtil:i18nScript>");
       form.ReportingYear.value="";
       form.ReportingYear.focus();
       return false;
    } else if(reportingYear=="") {
       alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheetReports.PMCPlzEntValNo</emxUtil:i18nScript>");
       form.ReportingYear.value="";
       form.ReportingYear.focus();
       return false;
    } else if(parseInt(reportingYear,10) < 0 ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheetReports.PMCPlzEntValNo</emxUtil:i18nScript>");
        form.ReportingYear.value="";
        form.ReportingYear.focus();
    } else if(reportingYear.length!=4) {
           alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheetReports.Select4DigitReportingYear</emxUtil:i18nScript>");
           form.ReportingYear.value="";
           form.ReportingYear.focus();
           return false;
    } else {
        return true;
    }
}
//End:26-Aug-10:VF2:R210 :059741


//Added:09-June-10:VM3:R210 : common search func.
/**
* function chooseRiskOwner(
* Used to update the Owner of the Risk
*/
function chooseRiskOwner()
{
	var objCommonAutonomySearch = new emxCommonAutonomySearch();

	//objCommonAutonomySearch.excludeOIDprogram
	objCommonAutonomySearch.table = "PMCCommonPersonSearchTable";
	objCommonAutonomySearch.txtType = "type_Person&amp;form=PMCCommonPersonSearchForm";
	objCommonAutonomySearch.selection = "single";
	objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitRiskOwner";
	objCommonAutonomySearch.open();
}

/**
* function submitRiskOwner(
* Used to update the Owner of the Risk
*/
function submitRiskOwner(arrSelectedObjects)
{
	for (var i = 0; i < arrSelectedObjects.length; i++) {
        var objSelection = arrSelectedObjects[i];
        //objSelection.debug(); // Alerts the following properties
        document.forms[0].PersonName.value = objSelection.name;
        document.forms[0].Owner.value = objSelection.name;
        break;
    }
}

/**
* function chooseProjectTemplateOwner(
* Used to update the Owner of the Project Template
*/
function chooseProjectTemplateOwner()
{
    var objCommonAutonomySearch = new emxCommonAutonomySearch();

    objCommonAutonomySearch.table = "PMCCommonPersonSearchTable&amp;includeOIDprogram=emxCommonPersonSearch:includePersonsForProjectTemplateOwner";
    objCommonAutonomySearch.txtType = "type_Person&amp;form=PMCCommonPersonSearchForm";
    objCommonAutonomySearch.selection = "single";
    objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitProjectTemplateOwner";
    objCommonAutonomySearch.open();
}

/**
* function chooseProjectTemplateOwner(
* Used to update the Owner of the Project Template
*/
function submitProjectTemplateOwner(arrSelectedObjects)
{
    for (var i = 0; i < arrSelectedObjects.length; i++) {
        var objSelection = arrSelectedObjects[i];
        document.forms[0].PersonName.value = objSelection.name;
        document.forms[0].Owner.value = objSelection.name;
        break;
    }
}

function reloadForm()
{
	 	
	 	emxFormReloadField('Policy');
	 	var taskType = document.getElementById("type").value;
       <%
	      //Find if a Task is Gate or Milestone
	      StringList slGateSubType = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_GATE);
	      String strGateTypes = FrameworkUtil.join(slGateSubType,",");
	      StringList slMileStoneSubType = ProgramCentralUtil.getSubTypesList(context, ProgramCentralConstants.TYPE_MILESTONE);
	      String strMileStoneTypes = FrameworkUtil.join(slMileStoneSubType,",");
	    %>
	      
	      var TYPE_GATE = "<%=strGateTypes%>";
	      var gates = TYPE_GATE.split(",");
	      var isGate = "false";
	      var TYPE_MILESTONE = "<%=strMileStoneTypes%>";
	      var milestones = TYPE_MILESTONE.split(",");
	      var isMilestone = "false";
	      
	      //Check for Gates
	      for(var i = 0;i<gates.length; i++){
	          if(taskType==gates[i]){
	        	    isGate = "true";
	          }
	      }
	      
	      //Check for Milestones
	      for(var i = 0;i<milestones.length; i++){
	    	  if(taskType==milestones[i]){
	    		  isMilestone = "true";
	        }
	      }
	      
	      if(isGate=="true" || isMilestone=="true"){
	    	  document.getElementById("Duration").value = "0";
	      }
	      else
	      {
	    	  document.getElementById("Duration").value = "";
	      }
}

function validateNumberOf()
{
    var numberOfVal = document.getElementById("NumberOf").value;
    if(isNaN(numberOfVal))
    {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Task.PleaseEnterOnlyNumbers</framework:i18nScript>");
        document.getElementById("NumberOf").focus();
        return false;
    }
	if((numberOfVal <= 0) || (numberOfVal >= 1000)){
    	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeAPositiveReal</framework:i18nScript>");
        document.getElementById("NumberOf").focus();
        return false;
    }

    return true;
}


function setScopListVal(){
		//var val = document.getElementsByName("name")[0].type;
		alert("2222");
	}
</SCRIPT>


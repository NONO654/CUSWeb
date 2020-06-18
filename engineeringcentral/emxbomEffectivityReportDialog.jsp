<%--  emxbomEffectivityReportDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%@include file = "emxengchgJavaScript.js"%>

<%
  Part part = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String objectName = emxGetParameter(request,"objectName");

  part.setId(objectId);

  SelectList busSelects = part.getObjectSelectList(4);

  busSelects.add(part.SELECT_ID);
  busSelects.add(part.SELECT_NAME);
  busSelects.add(part.SELECT_REVISION);
  busSelects.add(part.SELECT_TYPE);

  Map boInfo = part.getInfo(context, busSelects);
 String partType= part.getInfo(context ,DomainConstants.SELECT_TYPE);
 String partName = part.getInfo(context ,DomainConstants.SELECT_NAME);
 String partRev= part.getInfo(context ,DomainConstants.SELECT_REVISION);
 String typeIcon=EngineeringUtil.getDisplayPartIcon(context , partType);

  String hours = "";
  String minutes = "";
  String meridian = "";
  String today = "";
  String today_actual = "";

  // Check properties file for default effectivity time
  //
  String defaultEffectivityTime = JSPUtil.getCentralProperty(application,
                                    session,
                                    "emxEngineeringCentral",
                                    "DefaultEffectivityTime");
  // Get the current date and a calendar object
  //
  Date todayDate = new Date();
  Calendar calendar = Calendar.getInstance();

  // If no property set use default
  //
  if (defaultEffectivityTime == null || "".equals(defaultEffectivityTime)) {
    defaultEffectivityTime = "12:00:00 AM";
  }

  int iDateTimeDisplayFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
  try {
    Date defaultDate = DateFormat.getTimeInstance(iDateTimeDisplayFormat, Locale.US).parse(defaultEffectivityTime);
    calendar.setTime(defaultDate);
  }
  catch (ParseException pe) {
    calendar.set(Calendar.HOUR, 0);
    calendar.set(Calendar.MINUTE, 0);
    calendar.set(Calendar.AM_PM, Calendar.AM);
  }

  int hour12 = calendar.get(Calendar.HOUR);

  // Account for midnight
  //
  if (hour12 == 0){
    hour12 = 12;
  }

  hours = Integer.toString(hour12);
  minutes = Integer.toString(calendar.get(Calendar.MINUTE));

  if (calendar.get(Calendar.AM_PM) == Calendar.AM){
    meridian = "AM";
  }else{
    meridian = "PM";
  }





  today = DateFormat.getDateInstance(iDateTimeDisplayFormat, request.getLocale()).format(todayDate);
  today_actual = DateFormat.getDateInstance(iDateTimeDisplayFormat,Locale.US).format(todayDate);
%>

<script language="Javascript" >

var clicked = false;
var objCal = null;
function doneMethod(){
//added for the   form  not to submitted more than once
if (clicked) {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
    return;
  }


//  end of the code added for the   form  not to submitted more than once


  var hours = document.effectivityDate.hours.value;
  var minutes = document.effectivityDate.minutes.value;

  // validate input values
  if (hours == null || hours == "" || minutes == null || minutes == "")
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.EnterTime</emxUtil:i18nScript>");
    document.effectivityDate.txtEffectivityDate.focus();
    return;
  }

  if (!isNumeric(hours))
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.InvalidHours</emxUtil:i18nScript>");
    document.effectivityDate.hours.focus();
    return;
  }else if (hours<0 || hours >12){
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.ValidHoursCheck</emxUtil:i18nScript>");
    document.effectivityDate.hours.focus();
    return;
  }else if(hours.indexOf(".")>=0){
     alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.InvalidHours</emxUtil:i18nScript>");
     return;
  }

  if (!isNumeric(minutes))
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.InvalidMinutes</emxUtil:i18nScript>");
    document.effectivityDate.minutes.focus();
    return;
  }else if (minutes<0 || minutes>59){
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.ValidMinutesCheck</emxUtil:i18nScript>");
    document.effectivityDate.minutes.focus();
    return;
  }else if(minutes.indexOf(".")>=0){
     alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.InvalidHours</emxUtil:i18nScript>");
     return;
  }

  if(document.effectivityDate.txtEffectivityDate.value==null || document.effectivityDate.txtEffectivityDate.value=="")
  {
    if (!document.effectivityDate.effToday.checked)
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EngrEffReport.EnterDate</emxUtil:i18nScript>");
      document.effectivityDate.txtEffectivityDate.focus();
      return;
    }
    else
    {
      //Todays date checked, get todays date and send that as the effective date
      var formattedDate = "<xss:encodeForJavaScript><%=today%></xss:encodeForJavaScript>";
      var ampmindex  = document.effectivityDate.ampm.selectedIndex;
      var formattedTime = document.effectivityDate.hours.value + ":" + document.effectivityDate.minutes.value + ":00 " + document.effectivityDate.ampm[ampmindex].value;

      var URL = "emxbomEffectivityReportSummaryFS.jsp?objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&effectivityDate="+ formattedDate + "&effectivityTime=" + formattedTime;

      startSearchProgressBar(true);
      clicked = true;
 
      document.effectivityDate.action=fnEncode(URL);
      document.effectivityDate.submit();
    }
  }
  else
  {
  	var txtEffectivityDate = "<xss:encodeForJavaScript><%=today_actual%></xss:encodeForJavaScript>";
  	var date = null;
  	if(objCal != null) {
		date = new Date(objCal.selectedDate);
    } else {
    	var date = new Date(txtEffectivityDate);
    }
    var dateStr = (date.getMonth()+1) + "/";
	dateStr += date.getDate() + "/";
	//dateStr += (date.getYear()+1900);
	dateStr += date.getFullYear();
    
    var txtEffectivityDate = dateStr;
    var ampmindex  = document.effectivityDate.ampm.selectedIndex;
    var txtEffectivityTime = hours + ":" + minutes + ":" + "00 " + document.effectivityDate.ampm[ampmindex].value;
    var URL = "emxbomEffectivityReportSummaryFS.jsp?objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&effectivityDate="+txtEffectivityDate+"&effectivityTime="+txtEffectivityTime;
	    startProgressBar(true);
    clicked = true;

    document.effectivityDate.action=fnEncode(URL);
    document.effectivityDate.submit();
  }
}

function clearDate(){
  // clears the date field , when the today's check box is enabled
  if ( document.effectivityDate.effToday.checked ) {

    myDate = new Date();

    hours = myDate.getHours();
    minutes = myDate.getMinutes();
    
    if (hours < 12) {
      document.effectivityDate.ampm[0].selected = true;
    }
    else if(hours > 12){
      document.effectivityDate.ampm[1].selected = true;
      hours -= 12;
    }
    else {
      document.effectivityDate.ampm[1].selected = true;
    }

    document.effectivityDate.hours.value = hours;
    document.effectivityDate.minutes.value = minutes;
    document.effectivityDate.txtEffectivityDate.value = "<xss:encodeForJavaScript><%=today%></xss:encodeForJavaScript>";

  }
}

function displayCalendar(effectivityDate, txtEffectivityDate) {
	showCalendar(effectivityDate,txtEffectivityDate,'');
	objCal = localCalendars[txtEffectivityDate];
	clearCheck();
}

function clearCheck(){
  // clears the today's check box , when the date field is entered
  if ( document.effectivityDate.effToday.checked ) {
    document.effectivityDate.effToday.click();
  }
}
</script>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script>
var nameHeading="<xss:encodeForJavaScript><%=partName%></xss:encodeForJavaScript>" +" <emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18nScript>" +"<xss:encodeForJavaScript><%= partRev%></xss:encodeForJavaScript>";
</script>
<form name="effectivityDate" method="post" action="" target="_parent" onsubmit="javascript:doneMethod(); return false">
<table border="0" cellpadding="5" cellspacing="2" width="100%">
  <tr>
    <td width="150" class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></label></td>
    <!-- XSSOK  -->
    <td class="field"><b><img src="../common/images/<%=typeIcon%>" border="0" />&nbsp;<script>document.write(nameHeading)</script></b></td>
  </tr>

  <tr>
    <td width="150" class="labelRequired"><label for="effDateLabel"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.EffectivityDate</emxUtil:i18n></label></td>

    <td class="inputField">
      <table border="0">
        <tr>
          <td><input type="text" name="txtEffectivityDate" id="" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=today%></xss:encodeForHTMLAttribute>" /></td>
          <td><a href="javascript:displayCalendar('effectivityDate','txtEffectivityDate','');" ><img src="../common/images/iconSmallCalendar.gif" border="0" align="absbottom" /></a></td>
          <td>
            <input type="text" name="hours" onchange="javascript:clearCheck();" size="5" value="<xss:encodeForHTMLAttribute><%=hours%></xss:encodeForHTMLAttribute>" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectiveHours</emxUtil:i18n>
            <input type="text" name="minutes" onchange="javascript:clearCheck();" size="5" value="<xss:encodeForHTMLAttribute><%=minutes%></xss:encodeForHTMLAttribute>" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectiveMinutes</emxUtil:i18n>
            <select name="ampm">
<%
            if (meridian.equalsIgnoreCase("am"))
            {
%>
              <option value="AM" SELECTED><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectiveAM</emxUtil:i18n></option>
              <option value="PM"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectivePM</emxUtil:i18n></option>
<%
            }
            else
            {
%>
              <option value="AM"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectiveAM</emxUtil:i18n></option>
              <option value="PM" SELECTED><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectivePM</emxUtil:i18n></option>
<%
            }
%>
            </select>
          </td>
        </tr>
      </table>
      <input type="checkbox" name="effToday" value="" onClick="javascript:clearDate()" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EngrEffReport.EffectiveNow</emxUtil:i18n>
    </td>
  </tr>
</table>
<!-- &nbsp;
  <input type="image" height="1" width="1" border="0" /> -->
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%--
  emxProgramCentralCalendarEventCreateProcess.jsp
  Performs the action that creates a Calendar.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: emxProgramCentralCalendarEventCreateProcess.jsp.rca 1.6 Wed Oct 22 15:49:33 2008 przemek Experimental przemek $";
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@page import="com.matrixone.apps.common.CalendarEventRelationship"%>

<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxTagLibInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
<script src="../programcentral/script/WorkCalendar.js"></script>

<jsp:useBean id="calendar" scope="page" class="com.matrixone.apps.common.WorkCalendar"/>

<%
  Calendar today = Calendar.getInstance();
  int month = today.get(Calendar.MONTH);
  int year = today.get(Calendar.YEAR);
  MapList events = new MapList();
  String calOID = emxGetParameter(request,"parentOID");
  String sWeekDays = emxGetParameter(request,"sWeekDays");
  String startDate = emxGetParameter(request,"StartDate");
  String endDate = emxGetParameter(request,"EndDate");
  String dayNumber = emxGetParameter(request,"DayNumber");
  String title = emxGetParameter(request,"Title");
  String eventType = "Exception";
  String exceptionType = emxGetParameter(request, "exceptionTypeRadio");
  String recurrenceType = emxGetParameter(request, "recurrenceTypeRadio");
  String mode = emxGetParameter(request,"mode");
  String relId = emxGetParameter(request,"relId");
  StringList days = calendar.getShortDaysOfWeek(context, Locale.ENGLISH.getLanguage());
  String sLunchHours = emxGetParameter(request,"lunchHours");
  String sWorkingHours = emxGetParameter(request,"workingHours");
  boolean isHoursConflicting =  sWorkingHours.equals(sLunchHours);
  
  String weekOfMonth = DomainConstants.EMPTY_STRING;
  String dayOfWeek = DomainConstants.EMPTY_STRING;
  String dayOfMonth = DomainConstants.EMPTY_STRING;
  String monthOfYear = DomainConstants.EMPTY_STRING;

  String monthlyRecurrence = emxGetParameter(request, "monthlyRecurringPattern");
  String yearlyRecurrence = emxGetParameter(request, "yearlyRecurringPattern");

  String sLunchStartTime = DomainConstants.EMPTY_STRING;
  String sLunchFinishTime = DomainConstants.EMPTY_STRING;
  String sWorkStartTime = DomainConstants.EMPTY_STRING;
  String sWorkFinishTime = DomainConstants.EMPTY_STRING;
  StringBuffer sbRecurrencePattern = new StringBuffer();

  String conflictError = DomainConstants.EMPTY_STRING;	
  String postProcessConflict = DomainConstants.EMPTY_STRING;

  if(ProgramCentralUtil.isNotNullString(sLunchHours)){
	  StringList slLunchHours = FrameworkUtil.split(sLunchHours, ";");	  
	  sLunchStartTime = (String) slLunchHours.get(0);
	  sLunchFinishTime = (String) slLunchHours.get(1);
  }
  if(ProgramCentralUtil.isNotNullString(sWorkingHours)){
	  StringList slWorkingHours = FrameworkUtil.split(sWorkingHours, ";");	  
	  sWorkStartTime = (String) slWorkingHours.get(0);
	  sWorkFinishTime = (String) slWorkingHours.get(1);
  }
  
  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
  if (startDate != null) {
	  startDate = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,startDate, clientTZOffset,request.getLocale());
  }
  if (ProgramCentralUtil.isNotNullString(endDate)) {
	  endDate = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,endDate, clientTZOffset,request.getLocale());
  }else{
	  endDate = startDate;
  }
  if (dayNumber == null || dayNumber.length() == 0)
  	dayNumber = sWeekDays;

  calendar.setId(calOID);
  try {
    // start a write transaction and lock business object
    calendar.startTransaction(context, true);
    Map attrMap = new HashMap();
    attrMap.put(com.matrixone.apps.common.CalendarEventRelationship.ATTRIBUTE_TITLE, title);
    attrMap.put(com.matrixone.apps.common.CalendarEventRelationship.ATTRIBUTE_START_DATE, startDate);
    attrMap.put(com.matrixone.apps.common.CalendarEventRelationship.ATTRIBUTE_END_DATE, endDate);
    attrMap.put(com.matrixone.apps.common.CalendarEventRelationship.ATTRIBUTE_FREQUENCY, recurrenceType);
   
    if("Weekly".equalsIgnoreCase(recurrenceType)){
    	for(int index=0; index< days.size(); index++){
    		String dayKey = (String) days.get(index);
   			String day = (String) emxGetParameter(request, dayKey);
   			if("on".equalsIgnoreCase(day)){
   				sbRecurrencePattern.append(dayKey);
   				if(index < days.size()){
   					sbRecurrencePattern.append(",");
   				}
   			}
    	}
        attrMap.put("Days Of Week", sbRecurrencePattern.toString());
    }
    else if("Monthly".equalsIgnoreCase(recurrenceType)){
    	  weekOfMonth = emxGetParameter(request, "monthlyRecurringWeekOfMonth");
    	  dayOfWeek = emxGetParameter(request, "monthlyRecurringDayOfWeek");
    	  dayOfMonth = emxGetParameter(request, "monthlyRecurringDate");
    	  if("monthlyRecurringDay".equalsIgnoreCase(monthlyRecurrence)){
              attrMap.put("Week Of Month", weekOfMonth);
              attrMap.put("Day Of Week", dayOfWeek);
              attrMap.put("Day Of Month", "0");
    	  }else if("monthlyRecurringDate".equalsIgnoreCase(monthlyRecurrence)){
              attrMap.put("Day Of Month", dayOfMonth);
              attrMap.put("Week Of Month", DomainConstants.EMPTY_STRING);
    	  } 
    }
    else if("Yearly".equalsIgnoreCase(recurrenceType)){
    	  weekOfMonth = emxGetParameter(request, "yearlyRecurringWeekOfMonth");
    	  dayOfWeek = emxGetParameter(request, "yearlyRecurringDayOfWeek");
    	  monthOfYear = emxGetParameter(request, "yearlyRecurringMonthOfYear");
    	  dayOfMonth = emxGetParameter(request, "yearlyRecurringDate");
    	  if("yearlyRecurringDay".equalsIgnoreCase(yearlyRecurrence)){
              attrMap.put("Week Of Month", weekOfMonth);
              attrMap.put("Day Of Week", dayOfWeek);
              attrMap.put("Month Of Year", monthOfYear);
              attrMap.put("Day Of Month", "0");
    	  }else if("yearlyRecurringDate".equalsIgnoreCase(yearlyRecurrence)){
              attrMap.put("Day Of Month", dayOfMonth);
              attrMap.put("Month Of Year", monthOfYear);
              attrMap.put("Week Of Month", DomainConstants.EMPTY_STRING);
    	  } 
    }
    attrMap.put("Event Type", eventType);
    attrMap.put("Calendar Exception Type", exceptionType);
    
	StringList slWorkTimeBasicFormatRange = calendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.BASIC); 
	StringList slWorkTimeMilitaryFormatRange = calendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.MILITARY);
	
	sWorkStartTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(sWorkStartTime));
	sWorkFinishTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(sWorkFinishTime));
	sLunchStartTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(sLunchStartTime));
	sLunchFinishTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(sLunchFinishTime));
    attrMap.put("Work Start Time", sWorkStartTime);
    attrMap.put("Work Finish Time", sWorkFinishTime);
    attrMap.put("Lunch Start Time", sLunchStartTime);
    attrMap.put("Lunch Finish Time", sLunchFinishTime);
    
	SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
	Date effectiveFrom = sdf.parse(startDate);
	Date effectiveTo = sdf.parse(endDate);
    if("edit".equalsIgnoreCase(mode) && ProgramCentralUtil.isNotNullString(relId)){
		conflictError = calendar.isExceptionConflicting(context, attrMap, relId);
	if (UIUtil.isNullOrEmpty(conflictError) && !isHoursConflicting) {
		DomainRelationship rel = new DomainRelationship(relId);
		rel.setAttributeValues(context, attrMap);
			ContextUtil.commitTransaction(context);
			events = calendar.getEvents(context);
			session.putValue("calendarEvents", events);
	} else if (isHoursConflicting) {
		conflictError = EnoviaResourceBundle.getProperty(context, "ProgramCentral",
		"emxProgramCentral.WorkCalendar.SameWorkAndLunchHourConflict",
		context.getLocale().getLanguage());
		postProcessConflict = "hoursConflict";
		}else{
			postProcessConflict = "exceptionConflict";
		}
    }else if ("create".equalsIgnoreCase(mode)){
		conflictError = calendar.isExceptionConflicting(context, attrMap);
			if (UIUtil.isNullOrEmpty(conflictError) && !isHoursConflicting) {
        calendar.createEvent(context, attrMap);
		    ContextUtil.commitTransaction(context);
			events = calendar.getEvents(context);
			session.putValue("calendarEvents", events);
			} else if (isHoursConflicting) {
				conflictError = EnoviaResourceBundle.getProperty(context, "ProgramCentral",
						"emxProgramCentral.WorkCalendar.SameWorkAndLunchHourConflict",
						context.getLocale().getLanguage());
				postProcessConflict = "hoursConflict";
		}else {
			postProcessConflict = "exceptionConflict";
		}
    }
  } catch (Exception e) {
      ContextUtil.abortTransaction(context);
  }
%>

<html>
    <form name="CalendarCreateProcess" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=calOID%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Calendar Exception Type" value="<xss:encodeForHTMLAttribute><%=exceptionType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Start Date" value="<xss:encodeForHTMLAttribute><%=startDate%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="End Date" value="<xss:encodeForHTMLAttribute><%=endDate%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Title" value="<xss:encodeForHTMLAttribute><%=title%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Frequency" value="<xss:encodeForHTMLAttribute><%=recurrenceType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Days Of Week" value="<xss:encodeForHTMLAttribute><%=sbRecurrencePattern.toString()%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Day Of Month" value="<xss:encodeForHTMLAttribute><%=dayOfMonth%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Day Of Week" value="<xss:encodeForHTMLAttribute><%=dayOfWeek%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Week Of Month" value="<xss:encodeForHTMLAttribute><%=weekOfMonth%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Month Of Year" value="<xss:encodeForHTMLAttribute><%=monthOfYear%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Work Start Time" value="<xss:encodeForHTMLAttribute><%=sWorkStartTime%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Work Finish Time" value="<xss:encodeForHTMLAttribute><%=sWorkFinishTime%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Lunch Start Time" value="<xss:encodeForHTMLAttribute><%=sLunchStartTime%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Lunch Finish Time" value="<xss:encodeForHTMLAttribute><%=sLunchFinishTime%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="Calendar Exception Type" value="<xss:encodeForHTMLAttribute><%=exceptionType%></xss:encodeForHTMLAttribute>" />
    </form>
    <script language="javascript" type="text/javaScript">//<![CDATA[
    var postProcessConflict = '<%=postProcessConflict%>';
    if(postProcessConflict === "hoursConflict" || postProcessConflict === "exceptionConflict"){
		var conflictErr = '<%=conflictError%>';
    	alert(conflictErr);		
        form = document.CalendarCreateProcess;
        form.action="WorkCalendarEventCreateDialog.jsp";
        form.submit();
    }else{
    var mode = '<%=mode%>';
        var calendarId = '<%=calOID%>';
    	var target = window.parent.parent;
    if(mode === "edit"){
        	target.$("#objCalendarExceptions").attr( 'src', function ( i, val ) { return val; });
    }else{
        	target.$("#objCalendarExceptions").attr( 'src', function ( i, val ) { return val; });
    }
    	refreshDatePicker(calendarId, target);
    	displaySelectedDateInfo(new Date(), target);
    	
	window.parent.parent.$("#divEventCreationDialog").dialog("close");
    }
  </script>
</html>

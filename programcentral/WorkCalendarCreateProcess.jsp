<%--
  WorkCalendarCreateProcess.jsp

  Performs the action that creates a Calendar.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralCalendarCreateProcess.jsp.rca 1.7 Wed Oct 22 15:50:31 2008 przemek Experimental przemek $";
--%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@ include file="../emxUICommonAppInclude.inc"%>
<jsp:useBean id="calendar" scope="page" class="com.matrixone.apps.common.WorkCalendar"/>
<%
  String calendarName = emxGetParameter(request,"CalendarName");
  String calendarPolicy = emxGetParameter(request,"Calendar");
  String objectId = emxGetParameter(request,"objectId");
  String calendarDescription = emxGetParameter(request,"CalendarDescription");
  StringList slWorkWeek = new StringList();
  StringList slDaysOfWeek = calendar.getShortDaysOfWeek(context, Locale.ENGLISH.getLanguage());
  String treeUrl = DomainConstants.EMPTY_STRING; 
  for(int index=0; index< slDaysOfWeek.size(); index++){
	String dayKey = (String)slDaysOfWeek.get(index);
	String day = (String)emxGetParameter(request, dayKey);
	if("on".equalsIgnoreCase(day)){
		slWorkWeek.add(dayKey);
	}
  }
  String sLunchHours = emxGetParameter(request,"lunchHours");
  String sWorkingHours = emxGetParameter(request,"workingHours");
  StringList slLunchHours = FrameworkUtil.split(sLunchHours, ";");	  
  StringList slWorkingHours = FrameworkUtil.split(sWorkingHours, ";");	  
  String sLunchStartTime = (String) slLunchHours.get(0);
  String sLunchFinishTime = (String) slLunchHours.get(1);
  String sWorkStartTime = (String) slWorkingHours.get(0);
  String sWorkFinishTime = (String) slWorkingHours.get(1);
  
  try {
    // start a write transaction and lock business object
    calendar.startTransaction(context, true);
    if(UIUtil.isNotNullAndNotEmpty(calendarName)) {
      calendarName = calendarName.trim();
      DomainObject company= DomainObject.newInstance(context, objectId);
      calendar.create(context, calendarName, calendarPolicy, context.getVault().getName(), objectId);

      String workStartTime = (String) slWorkingHours.get(0);
      String workFinishTime = (String) slWorkingHours.get(1);
      String lunchStartTime = (String) slLunchHours.get(0);
      String lunchFinishTime = (String) slLunchHours.get(1);
      StringList slWorkTimeBasicFormatRange = calendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.BASIC);
      StringList slWorkTimeMilitaryFormatRange = calendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.MILITARY);
      workStartTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(workStartTime));
      workFinishTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(workFinishTime));
      lunchStartTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(lunchStartTime));
      lunchFinishTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(lunchFinishTime));

      //Set Calendar's Work Time Per Day.
      double work = calendar.computeWork(workStartTime, workFinishTime, lunchStartTime, lunchFinishTime);
      Double workInMinutes = work * 60;
      calendar.setAttributeValue(context, "Working Time Per Day", workInMinutes.intValue() + DomainConstants.EMPTY_STRING);
		      
      calendar.createWorkWeek(context, slWorkWeek, slWorkingHours, slLunchHours);
      if (calendarDescription != null && ! calendarDescription.equals("")) {
    	  calendar.setDescription(context, calendarDescription);
      }
    }
    // commit the data
    ContextUtil.commitTransaction(context);
    objectId = calendar.getId();
    treeUrl = UINavigatorUtil.getCommonDirectory(context)+ "/emxTree.jsp?AppendParameters=true&objectId=" + objectId  +"&mode=insert";
  } catch (Exception e) {
	  ContextUtil.abortTransaction(context);
      throw e;
  }
%>
    <script language="javascript">
		var href = "<%= treeUrl %>";  
		//var tree = parent.window.opener.getTopWindow().objDetailsTree;
		window.parent.parent.document.location.href = href;
    	/*
		var frameContent = findFrame(window.parent.parent, "content");
		if (parent.window.opener.parent.frames[1].frames[1] != null) {
	    	parent.window.opener.parent.frames[1].frames[1].document.location.href = "<%= treeUrl %>";  <%--- XSSOK --%>
	  	} else {
	    	var frameContent = findFrame(getTopWindow().opener.getTopWindow(), "content");
	    	frameContent.document.location.href="<%=treeUrl%>&jsTreeID=" + '<%=objectId%>';    <%--- XSSOK --%>
	  	}
		*/
		window.parent.parent.$("#divCalendarCreationDialog").dialog("destroy").remove();
   </script>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

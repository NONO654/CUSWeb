<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>


<%
	//Get Exceptions
	String objectId = (String) emxGetParameter(request, "objectId");
	objectId = XSSUtil.encodeForURL(objectId);
	WorkCalendar calendar = new WorkCalendar(objectId);    
	MapList events = calendar.getEvents(context);
	session.putValue("calendarEvents", events);
	//Get Workweek
	MapList mlWorkWeek = calendar.getWorkWeek(context);
	mlWorkWeek.sort("attribute[Title].value", "ascending", "integer");

	String displayLanguage = context.getLocale().getLanguage();
	String lblWorkweek = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.WorkWeek", displayLanguage);
	lblWorkweek = XSSUtil.encodeForXML(context,lblWorkweek);
	String lblExceptions = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.Exceptions", displayLanguage);
	lblExceptions = XSSUtil.encodeForXML(context,lblExceptions);
	String lblWorkException = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.DatePicker.Legend.WorkException", displayLanguage);
	String lblHoliday = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.DatePicker.Legend.Holiday", displayLanguage);
%>

<html lang="en">
<head>
	<link rel="stylesheet" href="../plugins/libs/jqueryui/1.10.3/css/jquery-ui.css">
	<link rel="stylesheet" href="../programcentral/styles/WorkCalendar.css">
	<script src="../common/scripts/jquery-1.9.1.js"></script>
	<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
	<script src="../programcentral/script/WorkCalendar.js"></script>
	<style>
		td {
			vertical-align:top;
		}
	</style>
  <script>
  var calendarId = '<%=objectId%>';
  var workWeekViewHeight = 250;
  var exceptionViewHeight = 425;
  $(function() {
	  	//maintain the order of invoke
		loadDatePicker(calendarId);
		displaySelectedDateInfo();
		loadCalendarEvents();
		loadEventCreateDialog();
  });

  function loadCalendarEvents(){
	  var calendarId = "<%=objectId%>";
	  var lblWorkweek = "<%=lblWorkweek%>";
	  var lblExceptions = "<%=lblExceptions%>";
	  var workWeek = '<iframe style="border:1px solid #BCBCBC; width:100%; height:' + workWeekViewHeight + 'px;" src="../programcentral/WorkCalendarWeekSummary.jsp?&suiteKey=ProgramCentral&SuiteDirectory=programcentral&objectId=' + calendarId + '&parentOID=' + calendarId + '"/> ';
	  var exceptions = '<iframe id="objCalendarExceptions" style="border:1px solid #BCBCBC; width:100%; height:' + exceptionViewHeight + 'px;" src="../common/emxIndentedTable.jsp?table=PMCWorkCalendarExceptions&program=emxWorkCalendar:getExceptions&toolbar=PMCWorkCalendarEventsToolbar&selection=multiple&HelpMarker=emxhelpcalendareventlist&suiteKey=Components&SuiteDirectory=components&multiColumnSort=false&objectCompare=false&editLink=false&hideLaunchButton=true&showClipboard=false&customize=false&displayView=details&rowGrouping=false&showPageURLIcon=false&findMxLink=false&showRMB=false&massPromoteDemote=false&objectId=' + calendarId + '&parentOID=' + calendarId + '"/> ';
	  $('#divWorkweek').html(workWeek);
	  $('#divCalendarEvents').html(exceptions);
  }
	  
  function loadEventCreateDialog(){
	  $( "#divEventCreationDialog" ).dialog({
	      autoOpen: false,
	      height: 550,
	      width: 700,
	      modal: true,
	      show: {
	        duration: 200
	      },
	      hide: {
	        duration: 200
	      }
	    }).dialog("widget").find(".ui-dialog-titlebar").hide();
  }

  </script>
</head>

<body style="background:#EEEEEE;" height=100%>
	<table height="100%">
		<tr>
			<td><div style="color:#5B5D5E;font-size:1.1em;margin-left:10px;margin-top:10px;margin-bottom:5px;"><%=lblWorkweek%></div></td>
			<td><div style="margin:10px;">&nbsp;</div></td>
		</tr>
		<tr>
			<td>
				<div style="margin-left:10px;" id="divWorkweek">&nbsp;</div>
				<div style="color:#5B5D5E;font-size:1.1em;margin-left:10px;margin-top:5px;margin-bottom:5px;"><%=lblExceptions%></div>
				<div style="margin-left:10px;" id="divCalendarEvents">&nbsp;</div>
				<div style="overflow: hidden;" id="divEventCreationDialog"></div>
			</td>				
			<td style="width:320px;">
				<div style="margin-left:12px;" id="datepicker"></div>
				<div style="width:277px;margin-left:10px;padding-top:5px;text-align:center;">
					<div style="display: inline-block;background: #1684C2; width:1em; height:1em; border: 0px #535C65 solid;">&nbsp;</div>&nbsp;<span style="font-size:0.9em;"><%=lblWorkException %></span> 
					<div style="display: inline-block;background: #FF8000; width:1em; height:1em; border: 0px #535C65 solid;">&nbsp;</div>&nbsp;<span style="font-size:0.9em;"><%=lblHoliday%></span>
				</div>	
				<hr style="margin-left:10px;margin-right:10px;">						
				<div style="margin-left:10px;" id="divEventInfoHeader">&nbsp;</div><br/>
				<div style="margin-left:10px;" id="divEventWorkHours">&nbsp;</div>
			</td>		
		</tr>
	</table>	
</body>
</html>

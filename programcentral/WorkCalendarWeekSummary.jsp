<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	  
<%@ include file = "../emxTagLibInclude.inc"%>

<%
	String calendarId = emxGetParameter(request, "objectId");
	calendarId = XSSUtil.encodeURLForServer(context, calendarId);
	//Get workweek
	WorkCalendar workCalendar = new WorkCalendar(calendarId);
	MapList mlWorkWeek = workCalendar.getWorkWeek(context);
	
	//Sort workweek.
	mlWorkWeek.sort("attribute[Title].value", "ascending", "integer");
	
	//Get First Working day in the workweek
	int firstWorkingDayIndex = 0;
	for (Iterator iterator = mlWorkWeek.iterator(); iterator.hasNext();){
		Map weekDayInfo = (Map) iterator.next();
		String exceptionType = (String) weekDayInfo.get("attribute[Calendar Exception Type]");
		if("Working".equals(exceptionType)){
			break;
		}
		firstWorkingDayIndex++;
	}
	
	String relId = DomainConstants.EMPTY_STRING;
	String exceptionType = DomainConstants.EMPTY_STRING;
	String dayOfWeek = DomainConstants.EMPTY_STRING;
	String dayOfWeekGlobalized = DomainConstants.EMPTY_STRING;
	int dayOfWeekIndex = 0;
	int tabIndex = 0;
	String displayLanguage= context.getLocale().getLanguage();
	StringList days = workCalendar.getDayOfWeekAttributeRange(context, Locale.ENGLISH.getLanguage());
	StringList daysGlobalized = workCalendar.getDayOfWeekAttributeRange(context, displayLanguage);
	StringList slWorkTimeMilitaryFormatRange = workCalendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.MILITARY);
	
	String lblWorkHours = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.WorkHours", displayLanguage);
	String lblLunchHours = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.LunchHours", displayLanguage);
	String lblWorking = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.Attribute.CalendarExceptionType.Range.Working", displayLanguage);
	String lblNonWorking = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.Attribute.CalendarExceptionType.Range.NonWorking", displayLanguage);
	
%>
<html lang="en-EN">
	<link rel="stylesheet" href="../plugins/libs/jqueryui/1.10.3/css/jquery-ui.css">
	<link rel="stylesheet" href="../programcentral/styles/WorkCalendar.css">
	<script src="../common/scripts/jquery-1.9.1.js"></script>
	<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
	<script src="../programcentral/script/WorkCalendar.js"></script>
	<script language="Javascript">
		var calendarId = "<%=calendarId%>";
		$(function(){
			$( "#tabs" ).tabs({
				active: <%=firstWorkingDayIndex%> 				
			}).addClass( "ui-tabs-vertical ui-helper-clearfix" );
		});
	</script>
	<style>
</style>
	<body>
		<div id="divWorkWeekView">
			<framework:ifExpr expr="<%= mlWorkWeek.size() > 0 %>">	
				<div id="tabs" class="tabs ui-tabs" style="background:#fff;border:none;">
					<ul class="ui-tabs-nav ui-tabs">
						<framework:mapListItr mapList="<%=mlWorkWeek%>" mapName="workWeekInfo">
						<%
			               	relId = (String) workWeekInfo.get("id");
							tabIndex ++ ;
			               	String tabId = "#tab" + "_" + relId;
			               	exceptionType = (String) workWeekInfo.get("attribute[Calendar Exception Type]");
			               	dayOfWeekIndex = Integer.parseInt((String)workWeekInfo.get("attribute[Title].value"));
			               	dayOfWeekIndex--;
			               	dayOfWeek = (String) days.get(dayOfWeekIndex);
			               	dayOfWeekGlobalized = (String)daysGlobalized.get(dayOfWeekIndex);
			               	dayOfWeekGlobalized = XSSUtil.encodeForHTML(context, dayOfWeekGlobalized);
			            %>			               	
						<li><b><a href="<%=XSSUtil.encodeForHTMLAttribute(context, tabId)%>"> <%=dayOfWeekGlobalized %></a></b></li>
						</framework:mapListItr>
					</ul>
					<% tabIndex = 0; %>
					<framework:mapListItr mapList="<%=mlWorkWeek%>" mapName="workWeekInfo">
						<%
							tabIndex ++ ;
			               	relId = (String) workWeekInfo.get("id");
							exceptionType = (String) workWeekInfo.get("attribute[Calendar Exception Type]");							
			               	dayOfWeekIndex = Integer.parseInt((String)workWeekInfo.get("attribute[Title].value"));
			               	
			               	int iStartTime = slWorkTimeMilitaryFormatRange.indexOf((String)workWeekInfo.get("attribute[Work Start Time]"));
			               	int iFinishTime = slWorkTimeMilitaryFormatRange.indexOf((String)workWeekInfo.get("attribute[Work Finish Time]"));
			               	int iLunchStartTime = slWorkTimeMilitaryFormatRange.indexOf((String)workWeekInfo.get("attribute[Lunch Start Time]"));
			               	int iLunchFinishTime = slWorkTimeMilitaryFormatRange.indexOf((String)workWeekInfo.get("attribute[Lunch Finish Time]"));
			               	
			               	dayOfWeekIndex--;
			               	dayOfWeek = (String)days.get(dayOfWeekIndex);
			               	dayOfWeekGlobalized = (String)daysGlobalized.get(dayOfWeekIndex);
							String tabId = "tab" + "_" + relId;
							String inputId = "input" + tabIndex;
			               	String divExceptionType = "divExceptionType" + tabIndex;
			               	String exceptionTypeWorkingId = "exceptionTypeWorking" + "_" + relId; 
			               	String exceptionTypeNonWorkingId = "exceptionTypeNonWorking" + "_" + relId; 
			               	String radioGroup = "radioGroup" + tabIndex; 
			               	String divWorkHourId = "divWorkHours" + tabIndex; 
			               	String divLunchHourId = "divLunchHours" + tabIndex;
						%>
						<div  id="<%=XSSUtil.encodeForHTMLAttribute(context, tabId)%>">
							<table style="margin:1px;border:1px solid #BCBCBC;">
								<tr>
									<td class="label" width="120px"><%=dayOfWeekGlobalized%></td>
									<td class="field" width="500px">
										<div id="<%=divExceptionType%>">
											<framework:ifExpr expr='<%="Working".equalsIgnoreCase(exceptionType)%>'>
												<input type="radio" id="<%=exceptionTypeNonWorkingId%>" value="Non Working" name="<%=radioGroup%>"><label class="label" for="<%=exceptionTypeNonWorkingId%>"><%=XSSUtil.encodeForXML(context, lblNonWorking)%></label>
												<input type="radio" id="<%=exceptionTypeWorkingId%>" value="Working" name="<%=radioGroup%>" checked="checked"><label class="label" for="<%=exceptionTypeWorkingId%>"><%=XSSUtil.encodeForXML(context, lblWorking)%></label>
											</framework:ifExpr>
											<framework:ifExpr expr='<%="Non Working".equalsIgnoreCase(exceptionType)%>'>
												<input type="radio" id="<%=exceptionTypeNonWorkingId%>" value="Non Working" name="<%=radioGroup%>" checked="checked"><label class="label" for="<%=exceptionTypeNonWorkingId%>"><%=XSSUtil.encodeForXML(context, lblNonWorking)%></label>
												<input type="radio" id="<%=exceptionTypeWorkingId%>" value="Working" name="<%=radioGroup%>"><label class="label" for="<%=exceptionTypeWorkingId%>"><%=XSSUtil.encodeForXML(context, lblWorking)%></label>
											</framework:ifExpr>
										</div>
										<script>
											var divExceptionType = '<%=divExceptionType%>';
											var radioGroup = '<%=radioGroup%>';
											$("#" + divExceptionType ).buttonset();
											//Change in exception mode 
											$("input[name=" + radioGroup + " ]").change(function(){
												var radioId = this.id;
												var newExceptionType = this.value;
												var idParts = radioId.split("_");
												var relId = idParts[1];
												updateExceptionType(calendarId, relId, newExceptionType);
												
												var divExceptionType = this.parentElement.id;
												var size = divExceptionType.length;
												size = size-1;
												var index = divExceptionType.charAt(size);
												toggleSliderState(index);
											});														
										</script>
									</td>
									<td class="field">&nbsp;</td>
								</tr>
								<tr>
									<td class="label"><%=lblWorkHours %></td>
									<td class="field">
										<br/><br/>
										<div id="<%=divWorkHourId%>" value="<%=relId%>"></div>
									</td>
									<td class="field">&nbsp;</td>
								</tr>
								<tr>
									<td class="label"><%=lblLunchHours%></td>
									<td class="field">
										<br/><br/>
										<div id="<%=divLunchHourId%>" value="<%=relId%>"></div>
									</td>
									<td class="field">&nbsp;</td>
								</tr>
							</table>
						</div>
											<script>
												var relId = '<%=relId%>';
							var divWorkHourId = '<%=divWorkHourId%>';
							var workStartTime = <%=iStartTime%>;
							var workFinishTime = <%=iFinishTime%>;
							
												var divLunchHourId = '<%=divLunchHourId%>';
												var lunchStartTime = <%=iLunchStartTime%>;
												var lunchFinishTime = <%=iLunchFinishTime%>;

												var disabled = <%= ("Non Working".equalsIgnoreCase(exceptionType))?true:false %>;

							//Work Slider 
							var options = {"mode": "Work Hours", "values": [workStartTime, workFinishTime], "disabled": disabled};
							loadTimeSlider(calendarId, relId, divWorkHourId, divLunchHourId, options);
							// Lunch Slider
							options = {"mode": "Lunch Hours", "values": [lunchStartTime, lunchFinishTime], "disabled": disabled};
							loadTimeSlider(calendarId, relId, divLunchHourId, divWorkHourId, options);
											</script>

					</framework:mapListItr>
				</div>		
			</framework:ifExpr>							
		</div>
	</body>	
</html>

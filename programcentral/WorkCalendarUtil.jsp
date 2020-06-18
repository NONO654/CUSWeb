
<%-- Common Includes --%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@page import="com.matrixone.apps.program.fiscal.Helper"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="java.util.Set"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.common.Company,matrix.util.StringList" %>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>

<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.program.FTE"%>
<%@page import="com.matrixone.apps.program.ResourceRequest"%>
<%@page import="com.matrixone.apps.program.Question"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
<script src="../programcentral/script/WorkCalendar.js"></script>

<%
	String sLanguage = request.getHeader("Accept-Language");	 
	String strMode = emxGetParameter(request, "mode");
	strMode = XSSUtil.encodeURLForServer(context, strMode);

	if ("getCalendarMonthlyEvents".equalsIgnoreCase(strMode)) {
		//[true, 'Holiday', 'Makar Sankranti']
		JsonObjectBuilder jsonObjectBuilder = Json.createObjectBuilder();

		Map monthlyEvents = new HashMap();
		String calendarId = (String) emxGetParameter(request, "objectId");
		WorkCalendar calendar = new WorkCalendar(calendarId);
		MapList events = (MapList) calendar.getEvents(context);
		session.putValue("calendarEvents", events);
		events.addSortKey("attribute[Start Date]", "ascending", "date");
		events.sort();
		String year = (String) emxGetParameter(request, "year");
		int iYear = Integer.parseInt(year);
		String month = (String) emxGetParameter(request, "month");
		int iMonth = Integer.parseInt(month);
		int iDayOfMonth = 0;
		Calendar currentStart = Calendar.getInstance();
		currentStart.set(iYear, iMonth, 1);
		currentStart.setTime(Helper.cleanTime(currentStart.getTime()));
		
		Calendar currentEnd = Calendar.getInstance();
		currentEnd.setTime(currentStart.getTime());
		currentEnd.add(Calendar.MONTH, 1);
		currentEnd.set(Calendar.DAY_OF_MONTH, 1);
		currentEnd.add(Calendar.DATE, -1);
		
		Calendar currentIndex = Calendar.getInstance();
		currentIndex.setTime(currentStart.getTime());
		
		while(!(currentIndex.after(currentEnd))){
			iYear = currentIndex.get(Calendar.YEAR);
			iDayOfMonth = currentIndex.get(Calendar.DAY_OF_MONTH);
			String dateKey = iYear + "/" + month + "/" + iDayOfMonth;
			WorkCalendar wc = new WorkCalendar();						
			Map eventInfo  = new HashMap();
			try{
				eventInfo = wc.getEventInfoByDate(context, currentIndex.getTime(), events);
			}catch(Exception e){
				e.printStackTrace();
				throw e;
			}
			String eventTitle = (String) eventInfo.get("attribute[Title].value");
			String exceptionType = (String) eventInfo.get("attribute[Calendar Exception Type]");
			String eventType = (String) eventInfo.get("attribute[Event Type]");
			String eventStyle = (String) eventInfo.get("eventStyle");

			if("Exception".equalsIgnoreCase(eventType)){						
				jsonObjectBuilder.add(dateKey + "_event", eventTitle);											
			}
			jsonObjectBuilder.add(dateKey + "_css", eventStyle);					

			currentIndex.add(Calendar.DATE, 1);
		}	
		out.clear();
		out.write(jsonObjectBuilder.build().toString());
		out.flush();
	    return;
	}else if ("getEventInfoBydate".equalsIgnoreCase(strMode)) {
		String day = (String)emxGetParameter(request, "day");
		String month = (String)emxGetParameter(request, "month");
		String year = (String)emxGetParameter(request, "year");
		
		int iDay = Integer.parseInt(day);
		int iMonth = Integer.parseInt(month);
		int iYear = Integer.parseInt(year);
		JsonObjectBuilder jsonObjectBuilder = Json.createObjectBuilder();
		Calendar calendar = Calendar.getInstance();
		calendar.set(iYear, iMonth, iDay);
		calendar.setTime(Helper.cleanTime(calendar.getTime()));
		WorkCalendar wc = new WorkCalendar();
		MapList events = (MapList) session.getAttribute("calendarEvents");						
		StringList slWorkTimeBasicFormatRange = wc.getWorkingTimeIntervals(WorkCalendar.TimeFormat.BASIC);
		StringList slWorkTimeMilitaryFormatRange = wc.getWorkingTimeIntervals(WorkCalendar.TimeFormat.MILITARY);
		Map eventInfo = wc.getEventInfoByDate(context, calendar.getTime(), events);
		String dateKey = iYear + "/" + month + "/" + iDay;
		
		String eventTitle = (String) eventInfo.get("attribute[Title].value");
		String exceptionType = (String) eventInfo.get("attribute[Calendar Exception Type]");
		String eventStartTime = (String) eventInfo.get("attribute[Work Start Time]");
		String eventFinishTime = (String) eventInfo.get("attribute[Work Finish Time]");
		String translatedExceptionType = exceptionType;
		if("Working".equalsIgnoreCase(exceptionType)){
			translatedExceptionType = EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Range.Calendar_Exception_Type.Working",context.getSession().getLanguage());
		}else{
			translatedExceptionType = EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Range.Calendar_Exception_Type.Non_Working",context.getSession().getLanguage());
		}
		
		
		String strLang = context.getSession().getLanguage();
		StringList transMonths = new StringList();
		transMonths.add(EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.Calendar.January", strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.February",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.March",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.April",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.May",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.June",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.July",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.August",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.September",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.October",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.November",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.December",strLang));
		String translatedMonthString = FrameworkUtil.join(transMonths, ",");
		
		String translated_Working_Timings = EnoviaResourceBundle.getProperty(context,"ProgramCentral", "emxProgramCentral.Calendar.Working_Timings",strLang);
		
		try{
			eventStartTime = (String) slWorkTimeBasicFormatRange.get(slWorkTimeMilitaryFormatRange.indexOf(eventStartTime));
			eventFinishTime = (String) slWorkTimeBasicFormatRange.get(slWorkTimeMilitaryFormatRange.indexOf(eventFinishTime));
		}catch(Exception e){
			e.printStackTrace();
		}
		
		jsonObjectBuilder.add(dateKey + "_css", 				"Holiday");
		jsonObjectBuilder.add(dateKey + "_event", 				eventTitle);					
		jsonObjectBuilder.add(dateKey + "_eventStartTime",		eventStartTime);					
		jsonObjectBuilder.add(dateKey + "_eventFinishTime",	eventFinishTime);					
		jsonObjectBuilder.add(dateKey + "_eventExceptionType",	exceptionType);
		jsonObjectBuilder.add("translatedExceptionType",	translatedExceptionType);
		jsonObjectBuilder.add("translatedMonthString",translatedMonthString);
		jsonObjectBuilder.add("translated_Working_Timings",translated_Working_Timings);
		out.clear();
		out.write(jsonObjectBuilder.build().toString());
		out.flush();
	    return;
	}else if ("updateWorkWeek".equalsIgnoreCase(strMode)) {
		String newExceptionType = emxGetParameter(request, "newExceptionType");
		String calendarId = emxGetParameter(request, "objectId");
		String relId = emxGetParameter(request, "relId");
		String startTime = emxGetParameter(request, "startTime");
		String finishTime = emxGetParameter(request, "finishTime");
		String lunchStartTime = emxGetParameter(request, "lunchStartTime");
		String lunchFinishTime = emxGetParameter(request, "lunchFinishTime");
		WorkCalendar workCalendar = new WorkCalendar(calendarId);
		StringList slWorkTimeBasicFormatRange = workCalendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.BASIC);
		StringList slWorkTimeMilitaryFormatRange = workCalendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.MILITARY);

		Map attributes = new HashMap();
		if(ProgramCentralUtil.isNotNullString(newExceptionType)){
			attributes.put("Calendar Exception Type", newExceptionType);	
		}
		
		if(ProgramCentralUtil.isNotNullString(startTime)){
			startTime =  (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(startTime));
	attributes.put("Work Start Time", startTime);	
		}
		if(ProgramCentralUtil.isNotNullString(finishTime)){
			finishTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(finishTime));
	attributes.put("Work Finish Time", finishTime);	
		}
		if(ProgramCentralUtil.isNotNullString(lunchStartTime)){
			lunchStartTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(lunchStartTime));
			attributes.put("Lunch Start Time", lunchStartTime);	
		}
		if(ProgramCentralUtil.isNotNullString(lunchFinishTime)){
			lunchFinishTime = (String) slWorkTimeMilitaryFormatRange.get(slWorkTimeBasicFormatRange.indexOf(lunchFinishTime));
			attributes.put("Lunch Finish Time", lunchFinishTime);	
		}
		
		DomainRelationship rel = new DomainRelationship(relId);
		try{
			rel.setAttributeValues(context, attributes);
			MapList events = new MapList();
			events = workCalendar.getEvents(context);
			session.putValue("calendarEvents", events);
		}catch(Exception e){
			e.printStackTrace();
		}
		return;
	}else if ("getWorkingHourRange".equalsIgnoreCase(strMode)) {
		WorkCalendar workCal = new WorkCalendar();
		StringList workTimeIntervals = workCal.getWorkingTimeIntervals(WorkCalendar.TimeFormat.BASIC);
		StringBuffer sbCSTimeRange = new StringBuffer();
		String delim = ProgramCentralConstants.EMPTY_STRING;
		for (int index=0; index<workTimeIntervals.size(); index++) {
			sbCSTimeRange.append(delim).append(workTimeIntervals.get(index));
		    delim = ProgramCentralConstants.COMMA;
		}
		JsonObject jsonObject = Json.createObjectBuilder()
				                .add("workingHourRange", sbCSTimeRange.toString())
				                .build();
		
		out.clear();
		out.write(jsonObject.toString());
		return;
	}else if ("createWorkCalendarEvent".equalsIgnoreCase(strMode)) {
		String parentOID = emxGetParameter(request, "parentOID");
		parentOID = XSSUtil.encodeURLForServer(context, parentOID);
		String objectId = emxGetParameter(request, "objectId");
		objectId = XSSUtil.encodeURLForServer(context, objectId);
		%>
		<script>
			var parentOID = "<%=parentOID%>";
			var objectId = "<%=objectId%>";
			window.parent.parent.$("#divEventCreationDialog").dialog( "open" );
			window.parent.parent.$("#divEventCreationDialog").html( '<iframe style="border:1px solid #BCBCBC" src="../components/emxCommonFS.jsp?functionality=CreateWorkCalendarEvent&HelpMarker=emxhelpcalendarcreate&suiteKey=ProgramCentral&emxSuiteDirectory=components&mode=create&parentOID=' + parentOID + '&objectId=' + objectId + '" />' );
		</script>
		<%
	}else if ("editWorkCalendarEvent".equalsIgnoreCase(strMode)) {
		String parentOID = emxGetParameter(request, "parentOID");
		parentOID = XSSUtil.encodeURLForServer(context, parentOID);
		StringBuffer sbUrl = new StringBuffer();
		sbUrl.append("../components/emxCommonFS.jsp?functionality=EditWorkCalendarEvent&HelpMarker=emxhelpcalendareventcreate");
		String relId = emxGetParameter(request, "relId");
		DomainRelationship rel = new DomainRelationship(relId);
		Map relAttributes = rel.getAttributeDetails(context);
		Iterator itrKeys = relAttributes.keySet().iterator();
		while(itrKeys.hasNext()){
			String attribute = (String)itrKeys.next();
			Map attributeValueMap = (Map)relAttributes.get(attribute);
			String attributeValue = (String)attributeValueMap.get("value");
			attributeValue = XSSUtil.encodeURLForServer(context, attributeValue);
			//To escape ampersand in url. 
			if(UIUtil.isNotNullAndNotEmpty(attributeValue) && attributeValue.contains("&")){
				attributeValue = FrameworkUtil.findAndReplace(attributeValue, "&", "%26");
			}
			sbUrl.append("&");
			sbUrl.append(attribute);
			sbUrl.append("=");
			sbUrl.append(attributeValue);			
		}
		sbUrl.append("&mode=edit");
		sbUrl.append("&relId=");
		sbUrl.append(relId);
		sbUrl.append("&suiteKey=ProgramCentral");
		sbUrl.append("&emxSuiteDirectory=components");
		sbUrl.append("&objectId=").append(parentOID);				
		String url = sbUrl.toString(); 		
		%>
		<script>
			var contentUrl = '<%=url%>'; /* XSSOK */
			window.parent.parent.$("#divEventCreationDialog").dialog( "open" );
			window.parent.parent.$("#divEventCreationDialog").html( '<iframe style="margin: 1px;border:1px solid #BCBCBC" src="'+ contentUrl + '" />' );
		</script>
		<%
	    return;
	}else if ("createWorkCalendar".equalsIgnoreCase(strMode)) {
		String parentOID = emxGetParameter(request, "parentOID");
		parentOID = XSSUtil.encodeURLForServer(context, parentOID);
		String objectId = emxGetParameter(request, "objectId");
		objectId = XSSUtil.encodeURLForServer(context, objectId);
		%>
		<script>
			var parentOID = "<%=parentOID%>";
			var objectId = "<%=objectId%>";
			var div = document.createElement("div");
			div.id= "divCalendarCreationDialog";
			div.style.overflow = "hidden";
			div.innerHTML = '<iframe style="border:1px solid #BCBCBC;" src="../components/emxCommonFS.jsp?functionality=CreateWorkCalendar&HelpMarker=emxhelpcalendarcreate&suiteKey=ProgramCentral&emxSuiteDirectory=components&parentOID=' + parentOID + '&objectId=' + objectId + '" />';
			window.parent.document.body.appendChild(div);
			window.parent.$("#divCalendarCreationDialog").dialog({
				autoOpen: true,
				height: 550,
				width: 700,
				modal: true,
				show: {
			        duration: 200
			    },
    	        hide: {
			        duration: 200
			      },
			    close: function(event, ui) {
		    	  window.parent.$("#divCalendarCreationDialog").remove();
		        }
			}).dialog("widget").find(".ui-dialog-titlebar").hide();
		</script>
		<%
	}else if ("deleteWorkCalendar".equalsIgnoreCase(strMode)) {
		String[] calendarIds = emxGetParameterValues(request,"emxTableRowId");
		String sObjId = "";
		String sTempRowId = "";
		String partialXML = "";
		String[] strObjectIDArr    = new String[calendarIds.length];
		for(int i=0; i<calendarIds.length; i++)	{
			String sTempObj = calendarIds[i];
			Map mParsedObject = ProgramCentralUtil.parseTableRowId(context,sTempObj);
			sObjId = (String)mParsedObject.get("objectId");
			strObjectIDArr[i] = sObjId;
			sTempRowId = (String)mParsedObject.get("rowId");
			partialXML += "<item id=\"" + sTempRowId + "\" />";		
		}
		
		/////////////Push-Pop is used because there is no toDisconnect/toConnect acces for public user on Project Space policy.//////////////
		 try {
			 ProgramCentralUtil.pushUserContext(context);
		DomainObject.deleteObjects(context,strObjectIDArr) ;
		 } finally {
			 ProgramCentralUtil.popUserContext(context);
		 }
		//////////////Delete Calendar Ends///////////////////
		
		String xmlMessage = "<mxRoot>";
		String message = "";
		xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
		xmlMessage += partialXML;
		xmlMessage += "<message><![CDATA[" + message + "]]></message>";
		xmlMessage += "</mxRoot>";
		 %>
		 <script type="text/javascript" language="JavaScript">
			window.parent.removedeletedRows('<%= xmlMessage %>');
         </script>
		 <% 
	}else if ("deleteWorkCalendarException".equalsIgnoreCase(strMode)) {
		String[] calendarIds = emxGetParameterValues(request,"emxTableRowId");
		String[] strObjectIDArr    = new String[calendarIds.length];
		String[] calendarEventIds = new String[calendarIds.length];
		String parentOID = DomainConstants.EMPTY_STRING;
		
		for(int i=0; i<calendarIds.length; i++)	{
			String sTempObj = calendarIds[i];
			Map mParsedObject = ProgramCentralUtil.parseTableRowId(context, sTempObj);
			String relId = (String)mParsedObject.get("relId");
			parentOID = (String)mParsedObject.get("parentOId");
			calendarEventIds[i] = relId;
		}
		//Disconnnect selected relids.
		DomainRelationship.disconnect(context, calendarEventIds);
		if(UIUtil.isNotNullAndNotEmpty(parentOID)){
			%>
		    <script language="javascript" type="text/javaScript">
		    	var calendarId = '<%=parentOID%>';
		    	var target = window.parent.parent;
	        	target.$("#objCalendarExceptions").attr( 'src', function ( i, val ) { return val; });
		    	refreshDatePicker(calendarId, target);
		    	displaySelectedDateInfo(new Date(), target);
		  	</script>
			<%
		}
	}else if ("isCalendarNameNotUnique".equalsIgnoreCase(strMode)) {
		String objectId = emxGetParameter(request, "objectId");
		String calendarName = emxGetParameter(request, "calendarName");
		WorkCalendar calendar = new WorkCalendar(objectId);
		boolean isCalendarNameNotUnique = calendar.checkForUniqueCalendar(context, objectId, calendarName);
		JsonObjectBuilder jsonObjectBuilder = Json.createObjectBuilder();
		if(isCalendarNameNotUnique){
			jsonObjectBuilder.add("isCalendarNameNotUnique", "true");
		}else{
			jsonObjectBuilder.add("isCalendarNameNotUnique", "false");
		}
		out.clear();
		out.write(jsonObjectBuilder.build().toString());
		out.flush();
		return;
	}else if("translateMonthsForWorkCalendar".equalsIgnoreCase(strMode)){
		String key = request.getParameter("key");
		String strLang = context.getSession().getLanguage();
		StringList transMonths = new StringList();
		transMonths.add(EnoviaResourceBundle.getProperty(context, "Framework", "emxFramework.Calendar.January", strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.February",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.March",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.April",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.May",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.June",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.July",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.August",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.September",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.October",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.November",strLang));
		transMonths.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.December",strLang));
		String translatedMonthString = FrameworkUtil.join(transMonths, ",");
		
		StringList transWkDay = new StringList();
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.SundayAbbr",strLang));
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.MondayAbbr",strLang));
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.TuesdayAbbr",strLang));
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.WednesdayAbbr",strLang));
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.ThursdayAbbr",strLang));
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.FridayAbbr",strLang));
		transWkDay.add(EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Calendar.SaturdayAbbr",strLang));
		String translatedWkDayString = FrameworkUtil.join(transWkDay, ",");
		
		String transCurrentText = EnoviaResourceBundle.getProperty(context,"Framework", "emxFramework.Widget.Date.TODAY",strLang);
		
		JsonObject jsonObject = Json.createObjectBuilder()
								.add("translatedMonthString",translatedMonthString)
								.add("translatedWkDayString",translatedWkDayString)
								.add("translatedCurrentText",transCurrentText)
								.build();

		out.clear();
		out.write(jsonObject.toString());
		return;
}
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>

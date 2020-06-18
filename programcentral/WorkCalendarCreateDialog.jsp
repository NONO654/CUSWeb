<%-- WorkCalendarCreateDialog.jsp

  Displays a window for creating a Calendar.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: WorkCalendarCreateDialog.jsp.rca 1.6 Wed Oct 22 15:49:13 2008 przemek Experimental przemek $";
--%>

<%@page import="com.matrixone.apps.common.util.ComponentsUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.common.WorkCalendar"%>
<%@include file = "../components/emxComponentsCommonInclude.inc" %>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<jsp:useBean id="calendar" scope="page" class="com.matrixone.apps.common.WorkCalendar"/>
<%
  String objectId = (String) emxGetParameter(request, "objectId");
  objectId = XSSUtil.encodeURLForServer(context, objectId);
  String displayLanguage = context.getLocale().getLanguage();
  
  String errMessage1 = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.Common.AlertInValidChars", displayLanguage);
  String errMessage2 = EnoviaResourceBundle.getProperty(context, "Components", "emxComponents.Common.AlertRemoveInValidChars", displayLanguage);
  String errMessage3 = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Calendar.EnterCalendarName", displayLanguage);
  String errMessage4 = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Calendar.UniqueNameMessage", context.getSession().getLanguage());

  String lblName =  ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.Common.Name", displayLanguage);
  String lblWorkweek = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.WorkWeek", displayLanguage);
  String lblWorkHours = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.WorkHours", displayLanguage);
  String lblLunchHours = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WorkCalendar.LunchHours", displayLanguage);
  String lblDescription = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.Common.Description", displayLanguage);
  String requiredText = ComponentsUtil.i18nStringNow("emxComponents.Commom.RequiredText", displayLanguage);
  
  StringList slWorkTimeBasicFormatRange = calendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.BASIC);
  StringList slWorkTimeMilitaryFormatRange = calendar.getWorkingTimeIntervals(WorkCalendar.TimeFormat.MILITARY);
  
  int iStartTime = slWorkTimeMilitaryFormatRange.indexOf("0800");
  int iFinishTime = slWorkTimeMilitaryFormatRange.indexOf("1700");
  int iLunchStartTime = slWorkTimeMilitaryFormatRange.indexOf("1200");
  int iLunchFinishTime = slWorkTimeMilitaryFormatRange.indexOf("1300");

  //Don't translate
  StringList days = calendar.getShortDaysOfWeek(context, Locale.ENGLISH.getLanguage());
  StringList daysTranslated = calendar.getShortDaysOfWeek(context, displayLanguage);

  MapList pcPolicyList = mxType.getPolicies(context, calendar.TYPE_CALENDAR, true);
  Iterator pcPolicyListItr = pcPolicyList.iterator();
  StringList pcTypePolicyList = new StringList();
  while (pcPolicyListItr.hasNext()){
      Map pcPolicyObj = (Map) pcPolicyListItr.next();
      String policyName = (String) pcPolicyObj.get(calendar.SELECT_NAME);
      pcTypePolicyList.add (policyName);
  }
%>
<html>
	<link rel="stylesheet" href="../plugins/libs/jqueryui/1.10.3/css/jquery-ui.css">
	<link rel="stylesheet" href="../programcentral/styles/WorkCalendar.css">
	<script src="../common/scripts/jquery-1.9.1.js"></script>
	<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
	<script src="../programcentral/script/WorkCalendar.js"></script>

  <body onload="document.CalendarCreate.CalendarName.focus()">
    <form name="CalendarCreate" method="post" onSubmit="return false;">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
    <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTMLAttribute(context, objectId)%>" />
      <table>
        <tr>
          <td>
            <table border="0" width="100%">
              <tr>
					<td></td>
					<td class="requiredNotice"><%=XSSUtil.encodeForHTMLAttribute(context, requiredText)%></td>
					<td></td>
				</tr>        
              <tr>
                <td nowrap="nowrap" class="labelRequired">
                  <%=lblName%>
                </td>
                <td class="field"><input type="text" name="CalendarName" size="30" /></td>
				<td class="field" style="width:50px;">&nbsp;</td>
              </tr>
              <tr>
                <td class="label"><%=lblWorkweek%></td>
                <td class="field">
                	<div id="checkboxgroup">
                		<%for(int index=0; index<days.size(); index++){
							String day = (String) days.get(index);
							String dayTranslated = (String) daysTranslated.get(index);
							String checkBoxId = "chk" + day;		
							if("Sat".equalsIgnoreCase(day) || "Sun".equalsIgnoreCase(day)){%>
								<input type="checkbox" id="<%=XSSUtil.encodeForHTMLAttribute(context, checkBoxId)%>" name="<%=XSSUtil.encodeForHTMLAttribute(context, day)%>"><label class="label" for="<%=XSSUtil.encodeForHTMLAttribute(context, checkBoxId)%>"><%=XSSUtil.encodeForHTMLAttribute(context, dayTranslated)%></label>
							<%}else{%>
								<input type="checkbox" id="<%=XSSUtil.encodeForHTMLAttribute(context, checkBoxId)%>" name="<%=XSSUtil.encodeForHTMLAttribute(context, day)%>" checked><label class="label" for="<%=XSSUtil.encodeForHTMLAttribute(context, checkBoxId)%>"><%=XSSUtil.encodeForHTMLAttribute(context, dayTranslated)%></label>
							<%	} 
						} %>
					</div>
				</td>
				<td class="field"></td>				
              </tr>
              <tr>
                <td class="label" ><%=XSSUtil.encodeForHTMLAttribute(context, lblWorkHours)%></td>
                <td class="field">
					<hr class="slider-space" />
                	<div id="divWorkHours" name="divWorkHours"></div>
                </td>
				<td class="field"></td>
              </tr>
              <tr >
                <td class="label" ><%=XSSUtil.encodeForHTMLAttribute(context, lblLunchHours)%></td>
                <td class="field">
					<hr class="slider-space" />
                	<div id="divLunchHours" name="divLunchHours" ></div>
                </td>
				<td class="field"></td>
              </tr>
              <tr>
                <td class="label" ><%=XSSUtil.encodeForHTMLAttribute(context, lblDescription)%></td>
                <td class="field"><textarea name="CalendarDescription" rows="3" ></textarea></td>
				<td class="field"></td>
              </tr>
              <%
              String strDefaultPolicy = (String) pcTypePolicyList.get( 0 );
              %>
              <input type="hidden" name="Policy" value="<xss:encodeForHTMLAttribute><%=XSSUtil.encodeForHTMLAttribute(context, strDefaultPolicy)%></xss:encodeForHTMLAttribute>" />
            </table>
          </td>
        </tr>
      </table>
    </form>
  </body>

	 <script>
		var startTime;
		var finishTime;
		var lunchStartTime;
		var lunchFinishTime;
		$(function() {
			$( "#checkboxgroup" ).buttonset();			
			startTime = <%=iStartTime%>;
			finishTime = <%=iFinishTime%>;
			lunchStartTime = <%=iLunchStartTime%>;
			lunchFinishTime = <%=iLunchFinishTime%>;
			var options = {"mode": "Work Hours", "values": [startTime, finishTime]};
			loadTimeSlider(null, null, "divWorkHours", "divLunchHours", options);
			
			options = {"mode": "Lunch Hours", "values": [lunchStartTime, lunchFinishTime]};
			loadTimeSlider(null, null, "divLunchHours", "divWorkHours", options);
		});

    f = document.CalendarCreate;
    var bool = false;
    function closeWindow() {
    	window.parent.parent.$("#divCalendarCreationDialog").dialog("destroy").remove();
    }
 	function submit() {
		var workingHours = getSelectedWorkingHours();  
		var lunchHours = getSelectedLunchHours();

     if (!bool) {
      if (validateForm()) {
         bool = true;
		 f.action="WorkCalendarCreateProcess.jsp?workingHours=" + workingHours + "&lunchHours=" + lunchHours;
         f.submit();
      }
     }
    }
    function validateForm() {
      var badChars = checkForNameBadCharsList(f.CalendarName);
      if (badChars != "") {
        alert( "<%=errMessage1%>" + badChars + "\n" + "<%=errMessage2%>" );
        f.CalendarName.focus();
        return false;
      }
      if (f.CalendarName.value == "" || (f.CalendarName.value.replace(/ /g,"")).length == 0) {
        alert("<%=errMessage3%>");
        f.CalendarName.focus();
        return false;
      }
      return isCalendarNameNotUnique();
    }
    function isCalendarNameNotUnique(){
    	var objectId = "<%=objectId%>";
    	var url = "../programcentral/WorkCalendarUtil.jsp?mode=isCalendarNameNotUnique&objectId=" + objectId  + "&calendarName=" + f.CalendarName.value;
    	url = encodeURI(url);
    	var response = emxUICore.getData(url);
    	var responseJSONObject = emxUICore.parseJSON(response);
    	var isCalendarNameNotUnique = responseJSONObject["isCalendarNameNotUnique"];
		if(isCalendarNameNotUnique === "true"){
			var errMessage = "<%=errMessage4%>";
			alert(errMessage);
			return false;
		}
		return true;
    }

	 </script>
</html>

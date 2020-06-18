<%--  emxPrefTimeZone.jsp  --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPrefTimeZone.jsp.rca 1.8.2.1 Fri Nov  7 09:40:26 2008 ds-kvenkanna Experimental $
 --%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<%
    String sTimeZonePref = PersonUtil.getTimeZonePreference(context);
    if (sTimeZonePref == null) {
        sTimeZonePref = "";
    }
    
    String sUseDaylight = PersonUtil.getDaylightSavingPreference(context);
%>

<HTML>
  <HEAD>
    <TITLE></TITLE>
    <SCRIPT language="JavaScript" src="scripts/emxUICore.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUICoreMenu.js"
    type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUICalendar.js"
    type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");

      var useDayLightSaving = new Object();
      useDayLightSaving["Pacific/Majuro"] = "NO";
      useDayLightSaving["Pacific/Apia"] = "NO";
      useDayLightSaving["Pacific/Honolulu"] = "NO";
      useDayLightSaving["America/Anchorage"] = "YES";
      useDayLightSaving["America/Los_Angeles"] = "YES";
      useDayLightSaving["America/Phoenix"] = "NO";
      useDayLightSaving["America/Denver"] = "YES";
      useDayLightSaving["GMT+6:00"] = "NO";
      useDayLightSaving["America/Chicago"] = "YES";
      useDayLightSaving["America/Mexico_City"] = "YES";
      useDayLightSaving["America/Regina"] = "NO";
      useDayLightSaving["America/Bogota"] = "NO";
      useDayLightSaving["America/New_York"] = "YES";
      useDayLightSaving["America/Indianapolis"] = "NO";
      useDayLightSaving["America/Halifax"] = "YES";
      useDayLightSaving["America/Caracas"] = "NO";
      useDayLightSaving["America/Santiago"] = "YES";
      useDayLightSaving["America/St_Johns"] = "YES";
      useDayLightSaving["America/Sao_Paulo"] = "YES";
      useDayLightSaving["America/Buenos_Aires"] = "NO";
      useDayLightSaving["America/Godthab"] = "YES";
      useDayLightSaving["Atlantic/South_Georgia"] = "YES";
      useDayLightSaving["Atlantic/Azores"] = "YES";
      useDayLightSaving["Atlantic/Cape_Verde"] = "NO";
      useDayLightSaving["Africa/Casablanca"] = "NO";
      useDayLightSaving["Europe/London"] = "YES";
      useDayLightSaving["Europe/Amsterdam"] = "YES";
      useDayLightSaving["Europe/Belgrade"] = "YES";
      useDayLightSaving["Europe/Brussels"] = "YES";
      useDayLightSaving["Europe/Belgrade"] = "YES";
      useDayLightSaving["Africa/Libreville"] = "NO";
      useDayLightSaving["Europe/Athens"] = "YES";
      useDayLightSaving["Europe/Bucharest"] = "YES";
      useDayLightSaving["Africa/Cairo"] = "YES";
      useDayLightSaving["Africa/Harare"] = "NO";
      useDayLightSaving["Europe/Helsinki"] = "YES";
      useDayLightSaving["Asia/Jerusalem"] = "NO";
      useDayLightSaving["Asia/Baghdad"] = "YES";
      useDayLightSaving["Asia/Kuwait"] = "NO";
      useDayLightSaving["Europe/Moscow"] = "YES";
      useDayLightSaving["Africa/Nairobi"] = "NO";
      useDayLightSaving["Asia/Tehran"] = "YES";
      useDayLightSaving["Asia/Muscat"] = "NO";
      useDayLightSaving["Asia/Baku"] = "YES";
      useDayLightSaving["Asia/Kabul"] = "NO";
      useDayLightSaving["Asia/Yekaterinburg"] = "YES";
      useDayLightSaving["Asia/Karachi"] = "NO";
      useDayLightSaving["Asia/Calcutta"] = "NO";
      useDayLightSaving["Asia/Katmandu"] = "NO";
      useDayLightSaving["Asia/Almaty"] = "YES";
      useDayLightSaving["Asia/Dhaka"] = "NO";
      useDayLightSaving["Asia/Colombo"] = "NO";
      useDayLightSaving["Asia/Rangoon"] = "NO";
      useDayLightSaving["Asia/Bangkok"] = "NO";
      useDayLightSaving["Asia/Krasnoyarsk"] = "YES";
      useDayLightSaving["Asia/Shanghai"] = "NO";
      useDayLightSaving["Asia/Irkutsk"] = "YES";
      useDayLightSaving["Asia/Singapore"] = "NO";
      useDayLightSaving["Australia/Perth"] = "NO";
      useDayLightSaving["Asia/Taipei"] = "NO";
      useDayLightSaving["Asia/Tokyo"] = "NO";
      useDayLightSaving["Asia/Seoul"] = "NO";
      useDayLightSaving["Asia/Yakutsk"] = "YES";
      useDayLightSaving["Australia/Adelaide"] = "YES";
      useDayLightSaving["Australia/Darwin"] = "NO";
      useDayLightSaving["Australia/Brisbane"] = "NO";
      useDayLightSaving["Australia/Sydney"] = "YES";
      useDayLightSaving["Pacific/Guam"] = "NO";
      useDayLightSaving["Australia/Hobart"] = "YES";
      useDayLightSaving["Asia/Vladivostok"] = "YES";
      useDayLightSaving["Asia/Magadan"] = "NO";
      useDayLightSaving["Pacific/Auckland"] = "YES";
      useDayLightSaving["Pacific/Fiji"] = "NO";
      useDayLightSaving["Pacific/Tongatapu"] = "NO";

      function doLoad() {
        if (document.forms[0].elements.length > 0) {
          var objElement = document.forms[0].timeZoneList;

          if (objElement.focus) objElement.focus();
          if (objElement.select) objElement.select();
        }
      }

      function loadDayLightSaving(bLoadCheck) {
        var tz = document.forms[0].timeZoneList.value;
        for (var i=0; i<document.forms[0].elements.length; i++) {
          if (document.forms[0].elements[i].name == "useDayLight") {
            if (useDayLightSaving[tz] == "NO") {
              document.forms[0].elements[i].disabled = true;
              if (bLoadCheck && document.forms[0].elements[i].value == "Yes") {
                document.forms[0].elements[i].checked = false;
              }
            } else {
              document.forms[0].elements[i].disabled = false;
              if (bLoadCheck && document.forms[0].elements[i].value == "Yes") {
                document.forms[0].elements[i].checked = true;
              }
            }
          }
        }
      }

      function shiftFocus(strForm, objInput) {

        var objForm = document.forms[strForm];

        for (var i=0; i < objForm.elements.length; i++) {
          if (objInput == objForm.elements[i]) {
            if (objForm.elements[i+1]) {
              objForm.elements[i+1].focus();
              return;
            } //End: if (objForm.elements[i+1])
          } //End: if (objInput == objForm.elements[i])
        } //End: for (var i=0; i < objForm.elements.length; i++)
      } //End: function shiftFocus(strForm, objInput)
    </SCRIPT>
  </HEAD>
  <BODY onload="turnOffProgress(), doLoad()">
    <FORM method="post" action="emxPrefTimeZoneProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.DaylightSavings</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
              <TR>
                <TD width = '8'>
<%
    if (sUseDaylight != null && sUseDaylight.equals("Yes")) {
%>
                  <INPUT type="radio" name="useDayLight" id=
                  "useDayLight" value="Yes" disabled checked />
<%
    } else {
%>
                  <INPUT type="radio" name="useDayLight" id=
                  "useDayLight" value="Yes" disabled />
<%
    }
%>
                </TD>
                <TD>
                  <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.Yes</emxUtil:i18n>
                </TD>
              </TR>
              <TR>
                <TD>
<%
    if (sUseDaylight != null && sUseDaylight.equals("No")) {
%>
                  <INPUT type="radio" name="useDayLight" id=
                  "useDayLight" value="No" disabled checked />
<%
    } else {
%>
                  <INPUT type="radio" name="useDayLight" id=
                  "useDayLight" value="No" disabled />
<%
    }
%>
                </TD>
                <TD>
                  <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.No</emxUtil:i18n>
                </TD>
              </TR>
            </TABLE>
          </TD>
        </TR>
        <TR>
          <TD>
            &nbsp;
          </TD>
          <TD>
            &nbsp;
          </TD>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <SELECT style="font-size: 9pt" name="timeZoneList" onChange="loadDayLightSaving(true)">
              <OPTION value="Pacific/Majuro">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-12</emxUtil:i18n>
              </OPTION>
              <OPTION value="Pacific/Apia">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-11</emxUtil:i18n>
              </OPTION>
              <OPTION value="Pacific/Honolulu">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-10</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Anchorage">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-9</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Los_Angeles">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-8</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Phoenix">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-7_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Denver">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-7_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="GMT+6:00">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-6_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Chicago">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-6_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Mexico_City">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-6_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Regina">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-6_4</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Bogota">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-5_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/New_York">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-5_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Indianapolis">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-5_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Halifax">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-4_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Caracas">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-4_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Santiago">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-4_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/St_Johns">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-3_30</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Sao_Paulo">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-3_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Buenos_Aires">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-3_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="America/Godthab">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-3_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Atlantic/South_Georgia">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Atlantic/Azores">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-1_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Atlantic/Cape_Verde">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT-1_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Africa/Casablanca">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/London">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Amsterdam">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+1_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Belgrade">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+1_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Brussels">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+1_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Belgrade">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+1_4</emxUtil:i18n>
              </OPTION>
              <OPTION value="Africa/Libreville">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+1_5</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Athens">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+2_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Bucharest">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+2_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Africa/Cairo">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+2_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Africa/Harare">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+2_4</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Helsinki">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+2_5</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Jerusalem">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+2_6</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Baghdad">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+3_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Kuwait">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+3_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Europe/Moscow">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+3_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Africa/Nairobi">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+3_4</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Tehran">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+3_30</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Muscat">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+4_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Baku">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+4_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Kabul">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+4_30</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Yekaterinburg">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+5_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Karachi">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+5_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Calcutta">
                <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+5_30</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Katmandu">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+5_45</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Almaty">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+6_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Dhaka">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+6_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Colombo">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+6_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Rangoon">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+6_30</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Bangkok">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+7_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Krasnoyarsk">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+7_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Shanghai">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+8_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Irkutsk">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+8_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Singapore">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+8_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Australia/Perth">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+8_4</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Taipei">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+8_5</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Tokyo">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+9_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Seoul">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+9_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Yakutsk">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+9_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Australia/Adelaide">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+9_30_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Australia/Darwin">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+9_30_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Australia/Brisbane">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+10_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Australia/Sydney">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+10_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Pacific/Guam">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+10_3</emxUtil:i18n>
              </OPTION>
              <OPTION value="Australia/Hobart">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+10_4</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Vladivostok">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+10_5</emxUtil:i18n>
              </OPTION>
              <OPTION value="Asia/Magadan">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+11</emxUtil:i18n>
              </OPTION>
              <OPTION value="Pacific/Auckland">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+12_1</emxUtil:i18n>
              </OPTION>
              <OPTION value="Pacific/Fiji">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+12_2</emxUtil:i18n>
              </OPTION>
              <OPTION value="Pacific/Tongatapu">
                 <emxUtil:i18n localize="i18nId">emxFramework.Preferences.TimeZone.GMT+13</emxUtil:i18n>
              </OPTION>
            </SELECT>
          </TD>
        </TR>
      </TABLE>
    </FORM>
  <SCRIPT type="text/javascript">
    //XSSOK
    if (useDayLightSaving["<%=sTimeZonePref%>"]) {
      //XSSOK
      document.forms[0].timeZoneList.value = "<%=sTimeZonePref%>";
      //XSSOK
      if ("<%=sUseDaylight%>" != null && "<%=sUseDaylight%>" == "No") {
        document.forms[0].useDayLight.value = "No";
      }
      loadDayLightSaving(false);
    }
  </SCRIPT>
  </BODY>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</HTML>


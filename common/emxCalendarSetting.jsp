<%-- emxCalendarSetting.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCalendarSetting.jsp.rca 1.24 Wed Oct 22 15:47:52 2008 przemek Experimental przemek $
--%>


<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>


<%  //clear the output buffer
  out.clear(); 
  response.setContentType("text/plain; charset=UTF-8");


try {
    String mon = Request.getParameter(request, "mon");
    String day = Request.getParameter(request, "day");
    String year = Request.getParameter(request, "year");
    String formName = Request.getParameter(request, "formName");
    String dateField = Request.getParameter(request, "dateField");

    StringBuffer dateStr = new StringBuffer(30);
    String inputDateFormat = eMatrixDateFormat.getInputDateFormat();
    if (inputDateFormat != null && inputDateFormat.startsWith("dd"))
    {
        dateStr.append(day);
        dateStr.append("/");
        dateStr.append(mon);
        dateStr.append("/");
        dateStr.append(year);
    } else if(inputDateFormat != null && inputDateFormat.startsWith("yyyy")){
    	dateStr.append(year);
    	dateStr.append("/");
    	dateStr.append(mon);
        dateStr.append("/");
        dateStr.append(day);
    }else {
        dateStr.append(mon);
        dateStr.append("/");
        dateStr.append(day);
        dateStr.append("/");
        dateStr.append(year);
    }

    double iClientTimeOffset = (new Double((String)session.getAttribute("timeZone"))).doubleValue();
    // dateStr = eMatrixDateFormat.getFormattedInputDateTime(dateStr, "", iClientTimeOffset, Locale.US);
    String dStr = dateStr.toString();
    dateStr = new StringBuffer(30);
    dateStr.append(eMatrixDateFormat.parseCalendarInputDateTime(dStr.toString(), "", iClientTimeOffset, Locale.US));

    // dateStr = eMatrixDateFormat.getFormattedInputDateTime(dateStr, "", iClientTimeOffset, request.getLocale());

    // Adjust the input date string to display format
    String displayDateFormat = eMatrixDateFormat.getEMatrixDateFormat();
    String timeString = "";
    if ( displayDateFormat.indexOf("HH") > 0 ||
                displayDateFormat.indexOf("hh") > 0)
    {
        if ( inputDateFormat.indexOf("HH") < 0 &&
                inputDateFormat.indexOf("hh") < 0)
        {
            if ( displayDateFormat.indexOf("a") > 0 )
            {
                timeString = "12:00:00 PM";
            } else {
               timeString = "12:00:00";
            }
            dateStr.append(" ");
            dateStr.append(timeString);
            dateStr.append(" GMT");
        }
    }

    // String strDateVisible = eMatrixDateFormat.getFormattedDisplayDateTime(dateStr, bDisplayTime,iDateFormat, iClientTimeOffset, request.getLocale());
    // String strDateVisible = eMatrixDateFormat.getFormattedDisplayDate(dateStr, iClientTimeOffset, request.getLocale());
    // String strDateVisible = eMatrixDateFormat.getFormattedDisplayDateTime(dateStr, iClientTimeOffset, request.getLocale());

    // int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
    int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
    // boolean bDisplayTime = PersonUtil.getPreferenceDisplayTimeValue(context);
    String strDateVisible = eMatrixDateFormat.getFormattedDisplayDateTime(dateStr.toString(), false, iDateFormat, iClientTimeOffset, request.getLocale());

%>
<%-- just output the date as plain text (no HTML needed) --%>
<%-- //XSSOK --%>
<%=strDateVisible%>
<%
} catch (Exception ex) {
    System.out.println("emxCalendarSetting : " + ex.toString());
    if(ex.toString()!=null && ex.toString().length()>0)
        emxNavErrorObject.addMessage(ex.toString());
}
%>

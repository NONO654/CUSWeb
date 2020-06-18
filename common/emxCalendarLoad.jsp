<%--  emxCalendarLoad.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCalendarLoad.jsp.rca 1.14 Wed Oct 22 15:48:16 2008 przemek Experimental przemek $
--%>


<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="java.text.*"%>


<% 	//clear the output buffer
	out.clear(); 
	response.setContentType("text/plain; charset=UTF-8");

try {
        String strDate = Request.getParameter(request, "date");
        Calendar cal = Calendar.getInstance();
        try {
            if (strDate != null &&
                    strDate.length() > 0 &&
                    !strDate.equals("undefined") )
            {
				 Date dateObject =  new Date(strDate);
                cal.setTime(dateObject);
            }
        } catch (Exception ex) {
            // Ignore the exception and use the current date for display
            // ..
        }
        // added code for IR-135085V6R2013x   
        String timeZonePref = PersonUtil.getActualTimeZonePreference(context);
        if(UIUtil.isNullOrEmpty(timeZonePref)){ //Changed for IR-219913V6R2014x
        	TimeZone defTimeZone = TimeZone.getDefault();
        	defTimeZone = TimeZone.getTimeZone(defTimeZone.getID());
            cal.setTimeZone(defTimeZone);
        }else{
        	TimeZone clientTZ = TimeZone.getTimeZone(timeZonePref);
        	cal.setTimeZone(clientTZ);
        }

%>
<%-- just output plain text in the form YEAR|MONTH|DAY --%>
<%-- //XSSOK --%>
<%=cal.get(Calendar.YEAR)%>|<%=cal.get(Calendar.MONTH)%>|<%=cal.get(Calendar.DAY_OF_MONTH)%>
<%
} catch (Exception ex) {
    System.out.println("emxCalendarLoad : " + ex.toString());
    if(ex.toString()!=null && ex.toString().length()>0)
        emxNavErrorObject.addMessage(ex.toString());
}
%>



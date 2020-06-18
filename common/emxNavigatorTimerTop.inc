<%-- emxTableTimingTopInclude.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorTimerTop.inc.rca 1.4 Wed Oct 22 15:48:53 2008 przemek Experimental przemek $
--%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%

String emxTimerLogFile = "";
long emxTimerStart = 0;

try {
    emxTimerLogFile = EnoviaResourceBundle.getProperty(context, "emxFramework.Timing.LogFile");

    if (emxTimerLogFile != null && emxTimerLogFile.trim().length() > 0)
    {
        emxTimerStart = System.currentTimeMillis();
    }
} catch (Exception ex) {
    // do nothing..
}

%>

<%@ page buffer="100kb" autoFlush="false" %>
<%--  emxMetricsReportCleanupSession.jsp - Cleans up the Report Data associated with a timestamp

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsReportCleanupSession.jsp.rca 1.6 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>
<html>
<head>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>
</head>
<body>
<%
    String timeStamp = emxGetParameter(request, "timeStamp");
    String reportType = emxGetParameter(request, "reportType");
    
    String strWebReport = ".emx"+reportType+timeStamp;
    
    boolean isWebReportExists = metricsReportBean.checkWorkSpaceObject(context,strWebReport,context.getUser());
    
    WebReport emxWebReport = new WebReport(strWebReport, context.getUser());
    
    if(isWebReportExists){
        emxWebReport.remove(context);
    }    
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

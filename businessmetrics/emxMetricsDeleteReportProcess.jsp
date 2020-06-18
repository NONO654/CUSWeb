<%--  emxMetricsDeleteReportProcess.jsp - This JSP is used to delete a webreport

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsDeleteReportProcess.jsp.rca 1.4 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>

<%    
    String strReportName = emxGetParameter(request,"reportName");
    String strReporttype = emxGetParameter(request, "reporttype");

    String closeWindow = "true";
    try
    {
        metricsReportBean.deleteReport(context,strReportName,strReporttype);
    }
    catch (Exception ex){
         closeWindow = "false";
         if(ex.toString() != null && (ex.toString().trim()).length()>0){
                emxNavErrorObject.addMessage("emxReport:" + ex.toString().trim());
        }
    }    
%>   
    <script language="javascript">
    //XSSOK
        if("true"=="<%=closeWindow%>")
            getTopWindow().closeWindow();
    </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

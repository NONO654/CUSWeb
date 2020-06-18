<%@ page buffer="100kb" autoFlush="false" %>
<%-- emxMetricsGetSavedReport.jsp - This JSP is used for streaming out the XML saved in notes field.
                                    This streamed XML is again used for reading values into the dialog page
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsGetSavedReport.jsp.rca 1.9 Wed Oct 22 16:11:55 2008 przemek Experimental $
--%>
<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.Document,
                 com.matrixone.jdom.input.*,
                 com.matrixone.jdom.output.*" %>                 
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>
<%
String saveName = emxGetParameter(request,"saveName","");
String reporttype = emxGetParameter(request,"reporttype");
String strOwner = emxGetParameter(request,"owner");
String timeStamp = emxGetParameter(request,"timeStamp");
String sMode = emxGetParameter(request,"mode");
String strNotes = "";
XMLOutputter outputter = new XMLOutputter();
try
{
    ContextUtil.startTransaction(context, true);
    String reportData = "";
    reportData = metricsReportBean.getParsedNotes(context,saveName,strOwner,XSSUtil.encodeForURL(context, reporttype),timeStamp,XSSUtil.encodeForURL(context, sMode));
    
    if (reportData != null && !"".equals(reportData)){
        reportData = reportData.substring(reportData.indexOf(">=") + 2,reportData.length()).trim();
        strNotes = FrameworkUtil.decodeURL(reportData, "UTF-8");
    }
%>
<% out.clear();%><%= strNotes %><%  

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0 && (ex.toString().trim().indexOf("does not exist")==-1) )
        emxNavErrorObject.addMessage(ex.toString().trim());
%><%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%><%  
} finally {
    ContextUtil.commitTransaction(context);
}
%>

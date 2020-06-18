<%@ page buffer="100kb" autoFlush="false" %>

<%-- emxMetricsResultsAsSave.jsp - This JSP is used to save the Report Results. 
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxMetricsResultsSaveAs.jsp.rca 1.7 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.apps.metrics.*" %>

<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%
    String strSaveType      = emxGetParameter(request,"saveType");
    String strReportName    = emxGetParameter(request,"reportName");
    String strReportTitle   = emxGetParameter(request,"reportTitle");
    String strDefaultReport = emxGetParameter(request,"defaultReport");
    String strMode          = emxGetParameter(request,"mode");
    String timeStamp        = emxGetParameter(request,"timeStamp");
    String existingReportName = emxGetParameter(request,"existingReportName");
    String strOwner         = emxGetParameter(request,"owner");
    String chartType          = emxGetParameter(request,"chartType");
    String fromDisplayFormat   = emxGetParameter(request,"fromDisplayFormat");
    String reportResultsSaved = "false";

    try
    {
        ContextUtil.startTransaction(context, true);
        metricsReportBean.saveAsReportResults(context,strReportName, strOwner, strReportTitle, strDefaultReport,strSaveType,timeStamp,existingReportName,chartType,fromDisplayFormat);
        reportResultsSaved = "true";
%>
        <script>            
            //XSSOK
            var resultsSaved = "<%=reportResultsSaved%>";
            var reportResultsFrame = parent.openerFindFrame(getTopWindow(),"metricsReportResultsContent");
            if(reportResultsFrame == null){
                reportResultsFrame = parent.openerFindFrame(parent.getWindowOpener(),"metricsReportResultsContent");
            }            
            
            if(resultsSaved=="true")
            {
                if(reportResultsFrame.parent.WINDOW_REF){
                    reportResultsFrame.parent.WINDOW_REF.close();
                }
                else{
                    getTopWindow().close();
                }
            }
            //end of close
        </script>
<%
    }
    catch(Exception ex) 
    {
        ContextUtil.abortTransaction(context);
        if(ex.toString() != null && (ex.toString().trim()).length()>0){
            String displayException = ex.toString();
            int index = ex.toString().indexOf(":");
            if(displayException.indexOf(":") != -1){
                String actualException = displayException.substring(index,displayException.length());
                displayException = "Unable to Save Report "+actualException;
            }
            emxNavErrorObject.addMessage(displayException);
        }
    }  
    finally 
    {
        ContextUtil.commitTransaction(context);
    }    
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

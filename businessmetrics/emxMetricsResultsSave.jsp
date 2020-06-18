<%@ page buffer="100kb" autoFlush="false" %>

<%-- emxMetricsResultsSave.jsp - This JSP is used to save the Report Results. 
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsResultsSave.jsp.rca 1.11 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>
<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.metrics.*" %>

<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
</head>
<body>
<%
    String strSaveType            = emxGetParameter(request,"saveType");
    String strReportName          = emxGetParameter(request,"reportName");
    String strReportTitle         = emxGetParameter(request,"reportTitle");
    String strDefaultReport       = emxGetParameter(request,"defaultReport");
    String strMode                = emxGetParameter(request,"mode");
    String timeStamp              = emxGetParameter(request,"timeStamp");
    String displayFormat          = emxGetParameter(request,"displayFormat");
    String booleanDisplayFormat   = emxGetParameter(request,"booleanDisplayFormat");
    String strOwner               = emxGetParameter(request,"owner");
    
    // coming from saveReportResults() of emxMetrics.js
    String portalMode             = emxGetParameter(request,"fromPortalMode");

    try
    {
        metricsReportBean.saveReportResults(context,strReportName,strOwner,strReportTitle, strDefaultReport,strSaveType,timeStamp,displayFormat,booleanDisplayFormat);

      if(portalMode == null || "".equals(portalMode) || "null".equalsIgnoreCase(portalMode)){
%>
           <script>
                // after successful save operation, the name, results title etc.
                // need to be set to pageControl of the "results" page
                var reportResultsFrame = getTopWindow().openerFindFrame(getTopWindow(),"metricsReportResultsContent");
                var reportDialogFrame = getTopWindow().openerFindFrame(getTopWindow(),"metricsReportContent");
                
                reportResultsFrame.getTopWindow().pageControl.setSavedReportName("<xss:encodeForJavaScript><%=strReportName%></xss:encodeForJavaScript>");
                reportResultsFrame.getTopWindow().pageControl.setResultsTitle("<xss:encodeForJavaScript><%=strReportTitle%></xss:encodeForJavaScript>");
                reportResultsFrame.getTopWindow().pageControl.setTitle("<xss:encodeForJavaScript><%=strReportTitle%></xss:encodeForJavaScript>");
                reportResultsFrame.getTopWindow().pageControl.setOwner("<xss:encodeForJavaScript><%= strOwner %></xss:encodeForJavaScript>");                
                        
                // and of the dialog
                reportDialogFrame.pageControl.setSavedReportName("<xss:encodeForJavaScript><%=strReportName%></xss:encodeForJavaScript>");
                reportDialogFrame.pageControl.setResultsTitle("<xss:encodeForJavaScript><%=strReportTitle%></xss:encodeForJavaScript>");
                reportDialogFrame.pageControl.setOpenedLast(false);
                
                // Disable the "Save" command
                reportResultsFrame.getTopWindow().enableFunctionality(getTopWindow().STR_METRICS_SAVE_COMMAND,false);
                if(parent.openerFindFrame(parent,"reportSaveHidden"))
                {
                   getTopWindow().closeWindow();
                }
           </script>     
<%      }
        else if("true".equalsIgnoreCase(portalMode)){ 
%>
            <script>
                // only for results page as dialog page will not be available in portal mode
                parent.pageControl.setSavedReportName("<xss:encodeForJavaScript><%=strReportName%></xss:encodeForJavaScript>");
                parent.pageControl.setResultsTitle("<xss:encodeForJavaScript><%=strReportTitle%></xss:encodeForJavaScript>");
                parent.pageControl.setTitle("<xss:encodeForJavaScript><%=strReportTitle%></xss:encodeForJavaScript>");
                // Disable the "Save" command
                parent.enableFunctionality(parent.STR_METRICS_SAVE_COMMAND,false);
            </script>
<%      }
    }
    catch(Exception ex) {
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
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

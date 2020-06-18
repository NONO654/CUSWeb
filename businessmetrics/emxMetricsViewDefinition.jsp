<%@ page buffer="100kb" autoFlush="false" %>

<%-- emxMetricsViewDefinition.jsp - This page displays the corresponding dialog page for which the result is displayed.    
   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsViewDefinition.jsp.rca 1.13 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="metricsReportUIBean" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>

<%
    String strSaveType      = emxGetParameter(request,"saveType");
    String strReportName    = emxGetParameter(request,"reportName");
    String strReportTitle   = emxGetParameter(request,"reportTitle");
    String strMode          = emxGetParameter(request,"mode");
    String strDefaultReport = emxGetParameter(request,"defaultReport");
    String strFromPortalMode = emxGetParameter(request,"fromPortalMode");
    String reportOwner = emxGetParameter(request,"reportOwner");
    String timeStamp = emxGetParameter(request,"timeStamp");
    String launched = emxGetParameter(request,"launched");
    
    if(strFromPortalMode == null){
        strFromPortalMode = "false";
    }

    String reportToolbar    = PropertyUtil.getSchemaProperty(context,"menu_MetricsGlobalToolbar");
    HashMap paramMap        = UINavigatorUtil.getRequestParameterMap(request);
    HashMap metricsRelatedSettings = metricsReportUIBean.getMetricsRelatedSettingsOfCommand(context,
                                                                                          strDefaultReport,
                                                                                          reportToolbar,
                                                                                          paramMap,
                                                                                          lStr);

    String url = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_LINK_HREF);
    String helpMarker = (String)metricsRelatedSettings.get(metricsReportUIBean.HELP_MARKER);
    String registeredSuiteDir = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_REGISTERED_SUITE);
    String resultsURL = (String)metricsRelatedSettings.get(metricsReportUIBean.SETTING_REPORT_RESULTS_URL);
    //suite is hard coded need to replace with query string
    String registeredSuite = "BusinessMetrics";

    String itemTargetLocation = "metricsReportContent";

    StringBuffer sbItemURL = new StringBuffer();
    if(strFromPortalMode.equalsIgnoreCase("true")){
        sbItemURL.append("parent.findReportFrame('");
    }else{
        sbItemURL.append("getTopWindow().findReportFrame('");
    }
    sbItemURL.append(url);
    sbItemURL.append("','");
    sbItemURL.append(itemTargetLocation);
    sbItemURL.append("',''");
    sbItemURL.append(",'");
    sbItemURL.append(strDefaultReport);
    sbItemURL.append("','");
    sbItemURL.append(helpMarker);
    sbItemURL.append("','");
    sbItemURL.append(registeredSuite);
    sbItemURL.append("','");
    sbItemURL.append(registeredSuiteDir);
    sbItemURL.append("','");
    sbItemURL.append(strFromPortalMode);
    sbItemURL.append("',encodeURI(\"");
    sbItemURL.append(strReportName);
    sbItemURL.append("\"),'");
    sbItemURL.append(timeStamp);
    sbItemURL.append("',encodeURI(\"");
    sbItemURL.append(reportOwner);
    sbItemURL.append("\"),'true");
    sbItemURL.append("','");
    sbItemURL.append(strMode);
    sbItemURL.append("','");
    sbItemURL.append("viewDef");
    sbItemURL.append("','");
    sbItemURL.append(launched);
    sbItemURL.append("')");
    
    
%>

<html>
    <body>
		<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>    	
    	<script language="javascript">
            try
            {
                var objHiddenFrame = getTopWindow().openerFindFrame(getTopWindow(), "metricsReportContent");
                
                var vMode = "<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>";
      
                if(objHiddenFrame && (vMode=="reportDisplay"))
                {
                    objHiddenFrame.focus();
                 	// XSSOK
                    objHiddenFrame.getTopWindow().importSavedReportXML(encodeURI("<%=strReportName%>"),"true",encodeURI("<%=reportOwner%>"),"<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>","<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>","ViewDefinition");
                }
                else if(objHiddenFrame && (vMode!=null && (vMode=="reportView" || vMode=="SavedWithNewDisplayFormat")))
                {
                    objHiddenFrame.focus();
                 	// XSSOK
                    objHiddenFrame.getTopWindow().openReport(encodeURI("<%=strReportName%>"),"true",encodeURI("<%=reportOwner%>"));
                }
                else
                {
                    eval("<%=XSSUtil.encodeForJavaScript(context, sbItemURL.toString())%>");
                }
             }
             catch(e)
             {                
                var url = "<%=XSSUtil.encodeForJavaScript(context, sbItemURL.toString())%>";
                eval(url);
             }
        </script>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>        
    </body>
</html>

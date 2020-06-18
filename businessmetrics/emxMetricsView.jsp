<%--  emxMetricsView.jsp - This page contains the header, content and footer elements of the report dialog page.

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsView.jsp.rca 1.7 Tue Oct 28 18:59:28 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
    //Get requestParameters for searchContent
    StringBuffer queryString = new StringBuffer("");

    Enumeration eNumParameters = emxGetParameterNames(request);
    int paramCounter = 0;
    while( eNumParameters.hasMoreElements() ) {
        String strParamName = (String)eNumParameters.nextElement();
        String strParamValue = emxGetParameter(request, strParamName);
        
        //do not pass showAdvanced or url on
        if(!"url".equals(strParamName)){
            if(paramCounter > 0){
                queryString.append("&");
            }
            paramCounter++;
            queryString.append(XSSUtil.encodeForURL(context, strParamName));
            queryString.append("=");
            queryString.append(XSSUtil.encodeForURL(context, strParamValue));
        }
    }
    
    String title = emxGetParameter(request, "title");

    String headerURL = "emxMetricsHeader.jsp";
    String footerURL = "emxMetricsFooter.jsp";

    if(queryString.length() > 1){
        headerURL += "?" + queryString.toString();
        footerURL += "?" + queryString.toString();
    }
%>
<html>
    <head>
        <title><emxUtil:i18n localize="i18nId">emxFramework.GlobalReport.Report</emxUtil:i18n></title>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>        
        <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
        <script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
        <script language="javascript" src="emxMetrics.js"></script>
        <script>
        function loadContentFrame(){
            var reportPageURL = getTopWindow().pageControl.getReportContentURL();
            var reportPageFrame = findFrame(this,"metricsReportContent");
            reportPageFrame.location.href = reportPageURL;
        }
       
       	function disableCommands(){       	   
       	     setTimeout( function() {       	        
       			getTopWindow().enableFunctionality(getTopWindow().STR_METRICS_DELETE_COMMAND,false);
       			getTopWindow().enableFunctionality(getTopWindow().STR_METRICS_SAVE_COMMAND,true);
       		},200);
        }
        </script>
        <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </head>
        <frameset rows="75,*,45" framespacing="0" frameborder="no" border="0" onload="loadContentFrame();"> 
          <frame src="<%= headerURL %>" name="metricsReportHeader" noresize scrolling="no" marginwidth="10" marginheight="10" frameborder="no"  onload="disableCommands();"/>
          <frame src="../common/emxBlank.jsp" name="metricsReportContent" marginwidth="8" marginheight="8" frameborder="no" scrolling="yes" style="overflow:auto"/>
          <frame src="<%= footerURL %>" name="metricsReportFooter" noresize scrolling="no" frameborder="no" marginheight="8" marginwidth="8" />          
        </frameset>
</html>

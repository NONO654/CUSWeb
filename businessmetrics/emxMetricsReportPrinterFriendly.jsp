<%--  emxMetricsReportPrinterFriendly.jsp

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsReportPrinterFriendly.jsp.rca 1.10 Wed Oct 22 16:11:57 2008 przemek Experimental $
--%>

<html>
<head>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>

<jsp:useBean id="chartBean" class="com.matrixone.apps.framework.ui.UIChart" scope="request"/>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>
<jsp:useBean id="metricsReportUIBean" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>


<%
    String resultsTitle    = "";
    String metricsToolbar  = PropertyUtil.getSchemaProperty(context,"menu_MetricsGlobalToolbar");
    String reportName      = emxGetParameter(request, "reportName");
    String timeStamp       = emxGetParameter(request, "timeStamp");
    String chartType       = emxGetParameter(request, "chartType");
    String suiteKey        = emxGetParameter(request, "suiteKey");
    String wrapColSize     = emxGetParameter(request, "wrapColSize");
    String defaultReport   = emxGetParameter(request, "defaultReport");
    String strOwner        = emxGetParameter(request, "owner");
    String strYAxisTitle   = emxGetParameter(request, "strYAxisTitle");
    
    if(strOwner == null || "null".equalsIgnoreCase(strOwner)){
        strOwner = "";
    }
    
    String lastCompletedIn = "";
    String lastRunDetails  = "";
    String subHeader       = "";
    String strBundle       = "emxMetricsStringResource";
    String languageStr     = request.getHeader("Accept-Language");
    String strNoResult     = "";
    String strLabelDirection = "";
    String strDraw3D         = "";
    HashMap XAxisMap = null;

    try{
        if(!"Tabular".equalsIgnoreCase(chartType)){
            XAxisMap = metricsReportBean.getXAxis(timeStamp);
            strLabelDirection = metricsReportBean.getLabelDirection(timeStamp);
            strDraw3D = metricsReportBean.getRenderOption(timeStamp);
            if(XAxisMap == null){
                strNoResult = (String) metricsReportBean.getResultString(timeStamp);
            }else{
                if(chartType.equalsIgnoreCase("PieChart")){
                    chartBean.setShowPercentage(false);
                    chartBean.setShowValues(true);
                }
                chartBean.setChartType(chartType);        
                chartBean.setDelimiter(",");
                chartBean.setXAxis(XAxisMap);
                chartBean.setYAxis(metricsReportBean.getYAxis(timeStamp));
                chartBean.setYAxisTitle(strYAxisTitle);
                if("Horizontal".equalsIgnoreCase(strLabelDirection)){
                    chartBean.setLabelDirection("");
                }else{
                    chartBean.setLabelDirection("Vertical");
                }    
                chartBean.setChartTitle("");
                if("true".equalsIgnoreCase(strDraw3D)){
                    chartBean.set3D(true);
                }else{
                    chartBean.set3D(false);
                }    
            }    
        }    
        
        //to get the Title
        resultsTitle = metricsReportBean.getTitle(timeStamp);
        
        //to get the subHeader
        subHeader = metricsReportBean.getSubHeader(timeStamp);

        //to get the dateformat
        String DateFrm = PersonUtil.getPreferenceDateFormatString(context);
        String userName = PersonUtil.getFullName(context);

        // Get the calendar on server
        Calendar currServerCal = Calendar.getInstance();
        Date currentDateObj = currServerCal.getTime();

        // Date Format initialization
        int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
        String prefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);

        DateFormat outDateFrmt = null;
        if (prefTimeDisp != null && prefTimeDisp.equalsIgnoreCase("true"))
        {
            outDateFrmt = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
        } else {
            outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        }

        currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
        java.util.Date currentDateObject = new java.util.Date(System.currentTimeMillis());
        String currentTime = sdf.format(currentDateObject);
%>

<title><%=resultsTitle%></title><!-- XSSOK -->
<script type="text/javascript">
    addStyleSheet("emxUIDefaultPF");
    addStyleSheet("emxUIListPF");
</script>
</head>

<body>
<form name="emxMetricsReportPrinterForm">

        <hr noshade>
        <table border="0" width="100%" cellspacing="2" cellpadding="4">
        <tr>
            <td class="pageHeader" width="80%">
            <span class="pageHeader"><%=resultsTitle%>&nbsp;</span>
<%
        if (subHeader != null && subHeader.length() > 0 )
        {
            %><br/><span class="pageSubTitle"><%=subHeader%>&nbsp;</span><%
        }
%>
            </td>
            <td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" alt="" /></td>
            <td width="39%" align="right"></td>
            <td nowrap>
                <table>
                <!-- //XSSOK -->
                <tr><td nowrap=""><%=userName%></td></tr>
                <!-- //XSSOK -->
                <tr><td nowrap=""><emxUtil:lzDate localize='i18nId' tz='<%=XSSUtil.encodeForURL(context, (String)session.getAttribute("timeZone")) %>' format='<%= DateFrm %>' displaydate='true' displaytime='<%=prefTimeDisp%>'><%=currentTime%></emxUtil:lzDate></td></tr>
                </table>
            </td>
        </tr>
        </table>
        <hr noshade>
<%
        if(chartType.equalsIgnoreCase("Tabular"))
        {
%>
            <jsp:include page = "emxMetricsResultsTabularFormatDisplay.jsp" flush="false">
                <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
                <jsp:param name="wrapColSize" value="<%=XSSUtil.encodeForURL(context, wrapColSize)%>"/>
                <jsp:param name="mode" value="Print"/>
            </jsp:include>
<%
        }
        else if(XAxisMap != null)
        {
%>
            <jsp:include page = "../common/emxChartInclude.jsp" flush="true">
                <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
            </jsp:include>
<%
        }
        else{
%>
            <table border="0" cellpadding="3" cellspacing="2" width="100%">
                <tr>
                     <td style="text-align:center">
                         <b><%=strNoResult%></b><!-- XSSOK -->
                     </td>
                </tr>
            </table>
<%      
        }
      } catch (Exception ex) {
          if(ex.toString()!=null && (ex.toString().trim()).length()>0)
                  emxNavErrorObject.addMessage("Metrics Printer Friendly:" + ex.toString().trim());
}
%>
</form>
</body>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

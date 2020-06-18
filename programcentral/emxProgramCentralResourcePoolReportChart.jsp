<%-- emxProgramCentralResourcePoolReportChart.jsp --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProgramCentralCommonUtilAppInclude.inc"%>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%@page import="java.util.Map"%>

<%
	try {
		String strTimeStamp = emxGetParameter(request, "timeStamp");
		UITableIndented indentedTableBean = (UITableIndented)session.getAttribute("indentedTableBean");
		HashMap programMap = indentedTableBean.getTableData(strTimeStamp);
		
		Map reportDataMap = ResourcePool.getResourcePoolReportData(context, programMap);
		
		//String strI18ReportTitle = (String) reportDataMap.get("strI18ReportTitle");
		String strI18ReportXTitle = (String) reportDataMap.get("strI18ReportXTitle");
		String strI18ReportYTitle = (String) reportDataMap.get("strI18ReportYTitle");
		String strPlotLine = (String) reportDataMap.get("plotLine");
		String strXAxisValues = (String) reportDataMap.get("xAxisValues");
		String strBarSeries = (String) reportDataMap.get("barSeries");	
%>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript" src="../plugins/highchart/3.0.10/js/highcharts.js"></script>
<script type="text/javascript" src="../plugins/highchart/3.0.10/js/modules/exporting.js"></script>

<style type="text/css">
#container {
	width: 75%;
	height: 300px;
}
</style>

<script type="text/javascript">
$(function () {
	$('#container').highcharts({
        chart: {
            type: 'column'
        },
        legend: {
            layout: 'vertical',
        	align: 'right',
            verticalAlign: 'top',
            y: 50,
            padding: 3,
            itemMarginTop: 5,
            itemMarginBottom: 5,
            itemStyle: {
                lineHeight: '14px'
            }
        },
        title: {
            text: null
        },
        credits: { 
        	enabled : false 
        },
        plotOptions: {
            column: {
                stacking: 'normal'
            }
        },       
        xAxis: {
        	gridLineWidth: 0.5,
            title: {
                text: '<%=strI18ReportXTitle%>' 					<%-- XSSOK --%>
            },
            categories: <%=strXAxisValues%>							<%-- XSSOK --%>
			
        },        
        yAxis: {
            title: {
                text: '<%=strI18ReportYTitle%>'						<%-- XSSOK --%>
            },
            <%=strPlotLine%>										<%-- XSSOK --%>
        },
        series: [
                	<%=strBarSeries%>								<%-- XSSOK --%>
                ]
    });
});
</script>

<%
	} catch ( Exception ex) { 
		ex.printStackTrace();
	}
%>

<html>
		<div id="container" border-color:red></div>
</html>


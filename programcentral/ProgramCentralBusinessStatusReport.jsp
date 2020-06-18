<%@page import="com.matrixone.apps.program.StatusReport"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>
<%
    String sLanguage        = request.getHeader("Accept-Language");
    String sOID             = com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");
	sOID = XSSUtil.encodeURLForServer(context, sOID);
    StatusReport report = new StatusReport(context, sOID, 2);

    //Risk Grid
    String rgXAxis = report.getRiskGridXAxis(context);
    String rgYAxis = report.getRiskGridYAxis(context);
    Map[][] aRisks = report.getProjectRiskGridInfo(context);
    Map[][] opportunityMap = report.getProjectOpportunityGridInfo(context);
    

    //Issues
    Integer[][] issues = report.getIssuesChartInfo();

    //Budget Chart
    String[] budgetChart = report.getProjectBudgetChartData(context);

    //Benefit Chart
    String[] benefitChart = report.getProjectBenefitChartData(context);

    //Assessment
    String[] aAssessmentsData = report.getProjectAssessmentHistoryData(context);

    MapList pendigIssuse = report.getPendingIssues();
    MapList overdueIssuse = report.getOverdueIssues();
    MapList latestartIssuse = report.getLateStartIssues();
    MapList completedIssuse = report.getCompletedIssues();
    
   
    
    CacheUtil.setCacheObject(context, "pendigIssuse", pendigIssuse);
    CacheUtil.setCacheObject(context, "overdueIssuse", overdueIssuse);
    CacheUtil.setCacheObject(context, "latestartIssuse", latestartIssuse);
    CacheUtil.setCacheObject(context, "completedIssuse", completedIssuse);
    CacheUtil.setCacheObject(context, "riskGridInfo", aRisks);
    CacheUtil.setCacheObject(context, "opportunityGridInfo", opportunityMap);

%>
<HTML>
    <HEAD>
        <link rel="stylesheet" href="../programcentral/styles/ProgramCentralStatusReport.css" type="text/css">
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css">
        <link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">
        <link rel="stylesheet" type="text/css" href="styles/statusreport.css">
        <script type="text/javascript" src="../common/scripts/emxDashboardCommon.js"></script>

        <script type="text/javascript" src="../common/scripts/emxDashboardDefaults.js"></script>
        <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
        <script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts.js"></script>
        <script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts-more.js"></script>
        <script type="text/javascript" src="../plugins/highchart/3.0.2/js/modules/funnel.js"></script>
        <script type="text/javascript" src="../plugins/highchart/3.0.2/js/modules/exporting.js"></script>
        <script type="text/javascript">
            function toggleRow(rowNum){
                if(rowNum == 0){
                    toggleChartInfo(divHeaderDetailsTable  , divDetailsTable  , null  , null);
                }
                if(rowNum == 1){
                    toggleChartInfo(divHeaderRiskGrid   , divChartRiskGrid  , null  , null);
                    toggleChartInfo(divHeaderOpportunityGrid   , divChartOpportunityGrid  , null  , null);
                    toggleChartInfo(divHeaderIssues     , divChartIssues    , null  , null);
                }
                else if(rowNum == 2){
                	toggleChartInfo(divHeaderBudget    ,  divChartBudget   , null  , null);
                toggleChartInfo(divHeaderBenefit    , divChartBenefit   , null  , null);
                }
                else if(rowNum == 3){
                    toggleChartInfo(divHeaderAssessments    , divChartAssessments,  null, null);
                }
            }

            var chartPieTasks;
            var chartPieDeliverables;
            var chartPieIssues;
            var chartBarTasks;
            var chartBarDeliverables;
            var chartBarIssues;
            var chartRisks;
            var chartRiskGrid;
            var chartBudget;
            var colorAlternate  = "#f5f5f5";
            var colorBorder     = "#bababa";
            var chartAssessment;

            $(document).ready(function() {

                toggleRow(0);

                chartRiskGrid = new Highcharts.Chart({
                    chart: {
                        renderTo: 'divChartRiskGrid',
                        type: 'column',
                        showAxes: false,
                        spacingBottom: 5,
                        spacingTop: 20,
                        spacingLeft: 0,
                        spacingRight: 5,
                        plotBackgroundColor: null,
                        plotBorderWidth: null,
                        plotShadow: false
                    },
                    exporting:  { enabled : false },
                    credits:    { enabled: false },
                    title: { text: '' },
                    xAxis: {
                        lineWidth: 0,
                        tickLength: 0,
                        title: {
                            text: '<%=report.CHART_RISK_IMPACT%>'
                        },
                        categories: [<%=rgXAxis%>],
                        tickMarkPlacement: 'off'
                    },
                    yAxis: {
                        gridLineColor: '#fff',
                        categories: [<%=rgYAxis%>],
                        title: {
                            text: '<%=report.CHART_RISK_PROBABILITY%>'
                        },
                        labels: {
                            style: {
                                width:'50px',
                            },
                            enabled: true,
                            y: -18
                        },
                        stackLabels: {
                            enabled: false,
                            align: 'center'
                        }
                    },
                    tooltip: {
                        enabled: false,
                        animation: false
                    },
                    plotOptions: {
                        series: {
                            animation: false,
                            showInLegend: false,
                            pointPadding: 0,
                            groupPadding: 0
                        },
                        column: {
                            stacking: 'normal',
                            dataLabels: {
                                enabled: true,
                                color: 'black',
                                style: {
                                    fontSize: "12px"
                                }
                            },
                            events: {
                                click: function(e) {
                                  var pos=e.point.myIndex;
                                  var xyvalue=  pos.split("|");
                                  var objID="<%=sOID%>";
                                  var pointX= xyvalue[0];
                                  var pointY= xyvalue[1];
                                  var cellValue = e.point.dataLabels.format;


                                  var position= '&xValue=' + pointX.toString() + '&yValue=' + pointY.toString();
                                  var href   = "../common/emxIndentedTable.jsp?table=PMCRisksSummary&Export=false&displayView=details&sortColumnName=Title&sortDirection=ascending&header=emxProgramCentral.ProgramTop.RisksProject&HelpMarker=emxhelprisksummary&freezePane=Name&hideLaunchButton=true&program=emxStatusReport:getRiskforStatus&SuiteDirectory=programcentral&showPageHeader=false&parentOID=<%=sOID%>&emxSuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&mode=PMCProjectRisk&jsTreeID=null&suiteKey=ProgramCentral&objectId=<%=sOID%>&expandLevelFilter=false&autoFilter=false&showClipboard=false&cellwrap=false&rowGrouping=false&customize=false&multiColumnSort=false&newTab=true&invokedFrom=statusReport" + position;

                                  if (cellValue != " ") {
                                    // alert ("Cell Data: " + cellValue);
                                      var divLeft         = document.getElementById("tableDetails");
                                      var widthLeft       = $(window).width();
                                      divLeft.innerHTML   = "<iframe id='frameDashboard' name='frameDashboard' style='width:" + widthLeft + "px;border:none;' src='" + href + "'></iframe>"

                                  var visibleChart	= $(divDetailsTable).is(':visible');
                                  if(!visibleChart){
                                	toggleRow(0);
                                  }
                                  }
                                }
                            }
                        }
                    },
                    series: [{
                        data: [{y: 1, dataLabels: {format:'<%=((Map)aRisks[1][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[1][5]).get("Grid Cell Color")%>',myIndex: '1|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[2][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[2][5]).get("Grid Cell Color")%>',myIndex: '2|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[3][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[3][5]).get("Grid Cell Color")%>',myIndex: '3|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[4][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[4][5]).get("Grid Cell Color")%>',myIndex: '4|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[5][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[5][5]).get("Grid Cell Color")%>',myIndex: '5|5'}]     <%--XSSOK--%>
                    }, {
                       data: [{y: 1, dataLabels: {format:'<%=((Map)aRisks[1][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[1][4]).get("Grid Cell Color")%>',myIndex: '1|4'},  <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[2][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[2][4]).get("Grid Cell Color")%>',myIndex: '2|4'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[3][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[3][4]).get("Grid Cell Color")%>',myIndex: '3|4'},
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[4][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[4][4]).get("Grid Cell Color")%>',myIndex: '4|4'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[5][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[5][4]).get("Grid Cell Color")%>',myIndex: '5|4'}]     <%--XSSOK--%>
                    }, {
                      data: [{y: 1, dataLabels: {format:'<%=((Map)aRisks[1][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[1][3]).get("Grid Cell Color")%>',myIndex: '1|3'},       <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[2][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[2][3]).get("Grid Cell Color")%>',myIndex: '2|3'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[3][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[3][3]).get("Grid Cell Color")%>',myIndex: '3|3'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[4][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[4][3]).get("Grid Cell Color")%>',myIndex: '4|3'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[5][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[5][3]).get("Grid Cell Color")%>',myIndex: '5|3'}]     <%--XSSOK--%>
                    }, {
                      data: [{y: 1, dataLabels: {format:'<%=((Map)aRisks[1][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[1][2]).get("Grid Cell Color")%>',myIndex: '1|2'},       <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[2][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[2][2]).get("Grid Cell Color")%>',myIndex: '2|2'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[3][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[3][2]).get("Grid Cell Color")%>',myIndex: '3|2'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[4][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[4][2]).get("Grid Cell Color")%>',myIndex: '4|2'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[5][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[5][2]).get("Grid Cell Color")%>',myIndex: '5|2'}]     <%--XSSOK--%>
                    }, {
                    data: [{y: 1, dataLabels: {format:'<%=((Map)aRisks[1][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[1][1]).get("Grid Cell Color")%>',myIndex: '1|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[2][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[2][1]).get("Grid Cell Color")%>',myIndex: '2|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[3][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[3][1]).get("Grid Cell Color")%>',myIndex: '3|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[4][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[4][1]).get("Grid Cell Color")%>',myIndex: '4|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)aRisks[5][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)aRisks[5][1]).get("Grid Cell Color")%>',myIndex: '5|1'}] <%--XSSOK--%>
                    }],
                });

                chartPieIssues = new Highcharts.Chart({
                    chart: {
                        renderTo: 'chartPieIssues',
                        plotBackgroundColor: null,
                        plotBorderWidth: null,
                        plotShadow: true
                    },
                    title:      { text: null },
                    credits:    { enabled : false },
                    legend:     { enabled : false },
                    exporting:  { enabled : false},
                    tooltip: {
                        formatter: function() {
                            return '<b>'+ this.point.name +'</b>: '+ this.y +' ('+ Math.round(this.percentage*10)/10 +'%)';
                        }
                    },
                    plotOptions: {
                        pie: {
                            cursor: 'pointer',
                            dataLabels: {
                                distance    : 5,
                                enabled     : true ,
                                //format        : '{point.name}: {point.percentage:.1f} %',
                                style       : { fontSize : '10px' },
                                formatter: function() {
                                    if (this.percentage == 0) {
                                      return null;
                                    }else{
                                        return this.point.name +':' + ' '+ Math.round(this.percentage*10)/10 + '%';
                                    }
                                }
                            },
                            showInLegend: true
                        }
                    },
                    series: [{
                        type: 'pie',
                        name: 'Issue Status',
                        data: [
                            {
                                name:'<%=report.STATE_IDLE%>',
                                y:<%=issues[0][0]%>,
                                color:'<%=report.STATE_IDLE_COLOR%>'
                            },
                            {
                                name:'<%=report.STATE_ACTIVE%>',
                                y:<%=issues[0][1]%>,
                                color:'<%=report.STATE_ACTIVE_COLOR%>'
                            },
                            {
                                name:'<%=report.STATE_REVIEW%>',
                                y:<%=issues[0][2]%>,
                                color:'<%=report.STATE_REVIEW_COLOR%>'
                            },
                            {
                                name:'<%=report.STATE_COMPLETE%>',
                                y:<%=issues[0][3]%>,
                                color:'<%=report.STATE_COMPLETE_COLOR%>'
                            }
                        ]
                    }]
                });

                chartBarIssues = new Highcharts.Chart({
                    chart: {
                        renderTo    : 'chartBarIssues',
                        type        : 'bar',
                        marginRight : 20,
                        marginLeft  : 100,
                        plotBorderColor: colorBorder,
                        plotBorderWidth: 1
                    },
                    title:      { text: null },
                    credits:    { enabled : false },
                    legend:     { enabled : false },
                    exporting:  { enabled : false },
                    xAxis:      {
                        tickColor: '#FFF',
                        categories: [
                                     '<%=report.STATUS_PENDING%>',
                                     '<%=report.STATUS_OVERDUE%>',
                                     '<%=report.STATUS_LATE_START%>',
                                     '<%=report.STATUS_COMPLETED%>'
                                     ],
                        labels : {
                            style: { fontSize: '10px'}
                        }
                    },
                    yAxis: {
                        allowDecimals : false,
                        title: { text: null },
                        alternateGridColor: colorAlternate
                    },
                    series: [{
                        name: 'Issues',
                        data: [
                            {
                                name : '<%=report.STATUS_PENDING%>',
                                y:<%=issues[1][0]%>,
                                color:'<%=report.STATUS_PENDING_COLOR%>'
                            },
                            {
                                name : '<%=report.STATUS_OVERDUE%>',
                                y:<%=issues[1][1]%>,
                                color:'<%=report.STATUS_OVERDUE_COLOR%>'
                            },
                            {
                                name : '<%=report.STATUS_LATE_START%>',
                                y:<%=issues[1][2]%>,
                                color:'<%=report.STATUS_LATE_START_COLOR%>'
                            },
                            {
                                name : '<%=report.STATUS_COMPLETED%>',
                                y:<%=issues[1][3]%>,
                                color:'<%=report.STATUS_COMPLETED_COLOR%>'
                            }
                        ]
                    }],
                    tooltip: {
                        formatter: function() {
                            return this.y +' '+ this.x.toLowerCase();
                        }
                    },
                    plotOptions: {
                        series: {
                        	groupPadding: 0.07,
							point:{
			                        events: {
		                            click: function(event) {
		                            	
		                            	var objID="<%=sOID%>";
		                            	var pointX=  this.x;
		                            	var position= '&xValue=' + pointX.toString();
		                            	
		                             	var href   = "../common/emxIndentedTable.jsp?table=PMCIssueList&Export=false&displayView=details&sortColumnName=Name&header=emxComponents.Menu.Issues&HelpMarker=emxhelpissues&freezePane=Name&hideLaunchButton=true&program=emxStatusReport:getIssuesforStatus&SuiteDirectory=programcentral&showPageHeader=false&emxSuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&jsTreeID=null&suiteKey=Components&objectId=<%=sOID%>&expandLevelFilter=false&autoFilter=false&showClipboard=false&cellwrap=false&rowGrouping=false&customize=false&multiColumnSort=false&massPromoteDemote=false&triggerValidation=false"+position;
		                             	
			                            if (this.y> 0) {
		                                
		                                  var divLeft         = document.getElementById("tableDetails");
		                                  var widthLeft       = $(window).width();
		                                  divLeft.innerHTML   = "<iframe id='frameDashboard' name='frameDashboard' style='width:" + widthLeft + "px;border:none;' src='" + href + "'></iframe>"
		
			                              var visibleChart	= $(divDetailsTable).is(':visible');
			                              if(!visibleChart){
			                            	toggleRow(0);
			                              }
		                              }
		                            }
		                        }
		                    }
                        }
                    }
                });

                
                chartOpportunityGrid = new Highcharts.Chart({
                    chart: {
                        renderTo: 'divChartOpportunityGrid',
                        type: 'column',
                        showAxes: false,
                        spacingBottom: 5,
                        spacingTop: 20,
                        spacingLeft: 0,
                        spacingRight: 5,
                        plotBackgroundColor: null,
                        plotBorderWidth: null,
                        plotShadow: false
                    },
                    exporting:  { enabled : false },
                    credits:    { enabled: false },
                    title: { text: '' },
                    xAxis: {
                        lineWidth: 0,
                        tickLength: 0,
                        title: {
                            text: '<%=report.CHART_RISK_IMPACT%>'
                        },
                        categories: [<%=rgXAxis%>],
                        tickMarkPlacement: 'off'
                    },
                    yAxis: {
                        gridLineColor: '#fff',
                        categories: [<%=rgYAxis%>],
                        title: {
                            text: '<%=report.CHART_RISK_PROBABILITY%>'
                        },
                        labels: {
                            style: {
                                width:'50px',
                            },
                            enabled: true,
                            y: -18
                        },
                        stackLabels: {
                            enabled: false,
                            align: 'center'
                        }
                    },
                    tooltip: {
                        enabled: false,
                        animation: false
                    },
                    plotOptions: {
                        series: {
                            animation: false,
                            showInLegend: false,
                            pointPadding: 0,
                            groupPadding: 0
                        },
                        column: {
                            stacking: 'normal',
                            dataLabels: {
                                enabled: true,
                                color: 'black',
                                style: {
                                    fontSize: "12px"
                                }
                            },
                            events: {
                                click: function(e) {
                                  var pos=e.point.myIndex;
                                  var xyvalue=  pos.split("|");
                                  var objID="<%=sOID%>";
                                  var pointX= xyvalue[0];
                                  var pointY= xyvalue[1];
                                  var cellValue = e.point.dataLabels.format;


                                  var position= '&xValue=' + pointX.toString() + '&yValue=' + pointY.toString();
                                  var href   ="../common/emxIndentedTable.jsp?table=PMCOpportunitySummary&Export=false&displayView=details&sortColumnName=Title&sortDirection=ascending&header=emxProgramCentral.ProgramTop.RisksProject&HelpMarker=emxhelprisksummary&freezePane=Name&hideLaunchButton=true&program=emxStatusReport:getOpportunityforStatus&SuiteDirectory=programcentral&showPageHeader=false&parentOID=<%=sOID%>&emxSuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&mode=PMCProjectOpportunity&jsTreeID=null&suiteKey=ProgramCentral&objectId=<%=sOID%>&expandLevelFilter=false&autoFilter=false&showClipboard=false&cellwrap=false&rowGrouping=false&customize=false&multiColumnSort=false&newTab=true&invokedFrom=statusReport" + position;

                                  if (cellValue != " ") {
                                      var divLeft         = document.getElementById("tableDetails");
                                      var widthLeft       = $(window).width();
                                      divLeft.innerHTML   = "<iframe id='frameDashboard' name='frameDashboard' style='width:" + widthLeft + "px;border:none;' src='" + href + "'></iframe>"

                                  var visibleChart	= $(divDetailsTable).is(':visible');
                                  if(!visibleChart){
                                	toggleRow(0);
                                  }
                                  }
                                }
                            }
                        }
                    },
                    series: [{
                        data: [{y: 1, dataLabels: {format:'<%=((Map)opportunityMap[1][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[1][5]).get("Grid Cell Color")%>',myIndex: '1|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[2][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[2][5]).get("Grid Cell Color")%>',myIndex: '2|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[3][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[3][5]).get("Grid Cell Color")%>',myIndex: '3|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[4][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[4][5]).get("Grid Cell Color")%>',myIndex: '4|5'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[5][5]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[5][5]).get("Grid Cell Color")%>',myIndex: '5|5'}]     <%--XSSOK--%>
                    }, {
                       data: [{y: 1, dataLabels: {format:'<%=((Map)opportunityMap[1][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[1][4]).get("Grid Cell Color")%>',myIndex: '1|4'},  <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[2][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[2][4]).get("Grid Cell Color")%>',myIndex: '2|4'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[3][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[3][4]).get("Grid Cell Color")%>',myIndex: '3|4'},
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[4][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[4][4]).get("Grid Cell Color")%>',myIndex: '4|4'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[5][4]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[5][4]).get("Grid Cell Color")%>',myIndex: '5|4'}]     <%--XSSOK--%>
                    }, {
                      data: [{y: 1, dataLabels: {format:'<%=((Map)opportunityMap[1][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[1][3]).get("Grid Cell Color")%>',myIndex: '1|3'},       <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[2][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[2][3]).get("Grid Cell Color")%>',myIndex: '2|3'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[3][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[3][3]).get("Grid Cell Color")%>',myIndex: '3|3'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[4][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[4][3]).get("Grid Cell Color")%>',myIndex: '4|3'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[5][3]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[5][3]).get("Grid Cell Color")%>',myIndex: '5|3'}]     <%--XSSOK--%>
                    }, {
                      data: [{y: 1, dataLabels: {format:'<%=((Map)opportunityMap[1][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[1][2]).get("Grid Cell Color")%>',myIndex: '1|2'},       <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[2][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[2][2]).get("Grid Cell Color")%>',myIndex: '2|2'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[3][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[3][2]).get("Grid Cell Color")%>',myIndex: '3|2'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[4][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[4][2]).get("Grid Cell Color")%>',myIndex: '4|2'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[5][2]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[5][2]).get("Grid Cell Color")%>',myIndex: '5|2'}]     <%--XSSOK--%>
                    }, {
                    data: [{y: 1, dataLabels: {format:'<%=((Map)opportunityMap[1][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[1][1]).get("Grid Cell Color")%>',myIndex: '1|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[2][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[2][1]).get("Grid Cell Color")%>',myIndex: '2|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[3][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[3][1]).get("Grid Cell Color")%>',myIndex: '3|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[4][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[4][1]).get("Grid Cell Color")%>',myIndex: '4|1'},     <%--XSSOK--%>
                           {y: 1, dataLabels: {format:'<%=((Map)opportunityMap[5][1]).get("Grid Cell Value")%>'}, color: '<%=((Map)opportunityMap[5][1]).get("Grid Cell Color")%>',myIndex: '5|1'}] <%--XSSOK--%>
                    }],
                });


                chartBudget = new Highcharts.Chart({
                    chart: {
                        renderTo : 'chartBudget',
                        type: 'line',
                        zoomType    : 'xy'
                    },
                    exporting:  { enabled : false },
                    credits: { enabled: false},
                    title: {
                        text: null
                    },
                    subtitle: {
                        text: null
                    },
                    tooltip: {
                        enabled : true,
                        crosshairs          : true,
                        shared              : true
                    },
                    legend: {
                        y: 10,
                    },
                    xAxis: {
                        categories: [<%=budgetChart[0]%>],
                        labels              : {
                            align           : 'right',
                            y               : 5,
                            rotation        : -90
                        }
                    },
                    yAxis: {
                        title: {
                            text: '<%=report.CHART_FINANCIAL_BUDGET%>'
                        },
                        min : 0,
                    },
                    plotOptions: {
                        line: {
                            dataLabels: {
                                enabled: false
                            },
                            enableMouseTracking: true
                        }
                    },
                    series: [{
                        name: '<%=report.CHART_FINANCIAL_PLANNED%>',
                        data: [<%=budgetChart[1]%>]
                    }, {
                        name: '<%=report.CHART_FINANCIAL_ACTUAL%>',
                        data: [<%=budgetChart[2]%>]
                    }]
                });

                chartBenefit = new Highcharts.Chart({
                    chart: {
                        renderTo : 'chartBenefit',
                        type: 'line',
                        zoomType    : 'xy'
                    },
                    exporting:  { enabled : false },
                    credits: { enabled: false},
                    title: {
                        text: null
                    },
                    subtitle: {
                        text: null
                    },
                    tooltip: {
                        enabled : true,
                        crosshairs          : true,
                        shared              : true
                    },
                    legend: {
                        y: 10,
                    },
                    xAxis: {
                        categories: [<%=benefitChart[0]%>],
                        labels              : {
                            align           : 'right',
                            y               : 5,
                            rotation        : -90
                        }
                    },
                    yAxis: {
                        title: {
                            text: '<%=report.CHART_FINANCIAL_BENEFIT%>'
                        },
                        min : 0,
                    },
                    plotOptions: {
                        line: {
                            dataLabels: {
                                enabled: false
                            },
                            enableMouseTracking: true
                        }
                    },
                    series: [{
                        name: '<%=report.CHART_FINANCIAL_PLANNED%>',
                        data: [<%=benefitChart[1]%>]
                    }, {
                        name: '<%=report.CHART_FINANCIAL_ACTUAL%>',
                        data: [<%=benefitChart[2]%>]
                    }]
                });

                chartAssessment = new Highcharts.Chart({
                    title       : { text    : null  },
                    credits     : { enabled : false },
                    exporting   : { enabled : false },
                    legend      : { enabled : false },
                    chart: {
                        marginTop   : 20,
                        marginRight : 35,
                        marginBottom: 20,
                        marginLeft  : 85,
                        renderTo    : 'chartAssessment',
                        type        : 'scatter',
                        zoomType    : 'xy'
                    },
                    xAxis: {
                        title:       { text: null },
                        startOnTick: false,
                        endOnTick: false,
                        opposite        : true,
                        type:       'datetime'

                    },
                    yAxis: {
                        title:       { text: null },
                        startOnTick : false,
                        endOnTick   : false,
                        categories  : [<%=aAssessmentsData[0]%>],
                        min         : -0.5,
                        max         : 4.5,
                        labels: {
                            formatter: function () {
                                var text = this.value,
                                formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
                                return '<div class="js-ellipse" style="width:115px;z-index:-100; overflow:hidden" title="' + text + '">' + formatted + '</div>';
                            },
                            style   : { width: '145px' },
                            useHTML : false
                        },
                        plotBands: [{
                            color   : '#f1f1f1',
                            from    : 3.5,
                            to      : 4.5
                        }]
                    },
                    plotOptions: {
                        scatter: {
                            marker: {
                                radius: 8,
                                states: {
                                    hover: {
                                        enabled: true,
                                        lineColor: 'rgb(100,100,100)'
                                    }
                                }
                            },
                            states: {
                                hover: {
                                    marker: {
                                        enabled: false
                                    }
                                }
                            },
                            tooltip: {
                                pointFormat: '{point.name}'
                            }
                        }
                    },
                    series: [
                        { name  : '<%=report.ASSESSMENT_LABEL_RED%>'    , color : colorRed          , data : [<%=aAssessmentsData[1]%>] },
                        { name  : '<%=report.ASSESSMENT_LABEL_YELLOW%>' , color : colorYellow       , data : [<%=aAssessmentsData[2]%>] },
                        { name  : '<%=report.ASSESSMENT_LABEL_GREEN%>'  , color : colorGreen        , data : [<%=aAssessmentsData[3]%>] },
                        { name  : '<%=report.ASSESSMENT_LABEL_NONE%>'   , color : colorGrayBright   , data : [<%=aAssessmentsData[4]%>] }
                    ]
                });
        });

        </script>
    </HEAD>
    <body style="overflow-x: auto;overflow-y: auto;">
            <CENTER>
                <table width="100%">
                    <tr>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td width="31%" style="line-height:5px">&nbsp;</td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td width="30%" style="line-height:5px">&nbsp;</td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td width="31%" style="line-height:5px">&nbsp;</td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                    </tr>
                    <tr><td colspan="7" style="line-height:5px">&nbsp;</td></tr>
                    <tr>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td style="line-height:5px">
                            <div class="header expanded" id="divHeaderRiskGrid" onclick="toggleRow(1);"><%=report.CHART_HEADER_RISK_GRID%></div>
                            <div class="chart"  id="divChartRiskGrid" style="height:280px"></div>
                        </td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td style="line-height:5px">
                            <div class="header expanded" id="divHeaderOpportunityGrid" onclick="toggleRow(1);"><%=report.CHART_HEADER_OPPORTUNITY_GRID%></div>
                            <div class="chart"  id="divChartOpportunityGrid" style="height:280px"></div>
                        </td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td style="line-height:5px">
                            <div class="header expanded" id="divHeaderIssues" onclick="toggleRow(1);"><%=report.CHART_HEADER_ISSUE%></div>
                            <div class="chart"  id="divChartIssues" style="height:280px">
                                <div id="chartPieIssues" style="height:50%"></div>
                                <div id="chartBarIssues" style="height:50%"></div>
                            </div>
                        </td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                    </tr>

                    <tr><td colspan="7" style="line-height:5px">&nbsp;</td></tr>
                    </table>
                    <table width="100%">
                    <tr>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td width="90%" style="line-height:5px">&nbsp;</td>
                        <td width="5%"  style="line-height:5px">&nbsp;</td>
                    </tr>
                    <tr><td colspan="3" style="line-height:5px">&nbsp;</td></tr>
                    <tr>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td width="90%" colspan="3" style="line-height:5px">
                            <div class="header expanded" id="divHeaderDetailsTable" onclick="toggleRow(0);"><%=report.TABLE_HEADER_DETAILS%></div>
                            <div class="chart chartBorder" id="divDetailsTable">
                                <div id="tableDetails" style="height:400px"></div>
                            </div>
                        </td>
                         <td width="5%"  style="line-height:5px">&nbsp;</td>
                    </tr>
                </table>
                <table width="100%">
                    <tr>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td width="50%" style="line-height:5px">
                            <div class="header expanded" id="divHeaderBudget" onclick="toggleRow(2);"><%=report.CHART_HEADER_BUDGET%></div>
                            <div class="chart chartBorder" id="divChartBudget">
                                <div id="chartBudget" style="height:280px"></div>
                            </div>
                        </td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td style="line-height:5px">
                            <div class="header expanded" id="divHeaderBenefit" onclick="toggleRow(2);"><%=report.CHART_HEADER_BENEFIT%></div>
                            <div class="chart chartBorder" id="divChartBenefit">
                            <div id="chartBenefit" style="height:280px"></div>
                            </div>
                        </td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                    </tr>
                    <tr><td colspan="7" style="line-height:5px">&nbsp;</td></tr>
                    </table>
                	<table width="100%">
                    <tr>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                        <td colspan="5" style="line-height:5px">
                            <div class="header expanded" id="divHeaderAssessments" onclick="toggleRow(3);"><%=report.CHART_HEADER_ASSESSMENT%></div>
                            <div class="chart chartBorder" id="divChartAssessments" style="height:190px;">
                                <div id="chartAssessment" style="height:100%"></div>
                            </div>
                        </td>
                        <td width="1%"  style="line-height:5px">&nbsp;</td>
                    </tr>
                    <tr><td colspan="7" style="line-height:10px">&nbsp;</td></tr>
                </table>
            </CENTER>
    </body>
</HTML>

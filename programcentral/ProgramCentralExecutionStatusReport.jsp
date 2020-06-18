<%@page import="com.matrixone.apps.program.StatusReport"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>

<%
	String sLanguage		= request.getHeader("Accept-Language");
	String sOID 			= com.matrixone.apps.domain.util.Request.getParameter(request, "objectId");	
	String treeLabel 		= com.matrixone.apps.domain.util.Request.getParameter(request, "treeLabel");
	String localeString 	= context.getLocale().toString();
	String languageString 	= context.getLocale().getLanguage();
	String remainingStr = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Chart.BurnDown.Remaining", languageString);
	
	String projectProgressTile = (String)emxGetParameter(request, "projectProgressTile");
	String slippedByTile = (String)emxGetParameter(request, "slippedByTile");
	String lateTaskTile = (String)emxGetParameter(request, "lateTaskTile");
	String membersTile = (String)emxGetParameter(request, "membersTile");
	String milestonesTile = (String)emxGetParameter(request, "milestonesTile");
	String budgetTile = (String)emxGetParameter(request, "budgetTile");
	String riskTile = (String)emxGetParameter(request, "riskTile");
	String issueTile = (String)emxGetParameter(request, "issueTile");
	
	StatusReport report = new StatusReport(context, sOID, 1);
	
	StringList tileList = new StringList();
	for(int i=0;i<report.PROJECT_STATUS_TILES.length;i++){
		tileList.add(report.PROJECT_STATUS_TILES[i]);
	}
	
	if("false".equalsIgnoreCase(projectProgressTile)){
		tileList.remove("Project Progress");
	}
	if("false".equalsIgnoreCase(slippedByTile)){
		tileList.remove("Slipped By");
	}
	if("false".equalsIgnoreCase(lateTaskTile)){
		tileList.remove("Late Task");
	}
	if("false".equalsIgnoreCase(membersTile)){
		tileList.remove("Overloaded");
	}
	if("false".equalsIgnoreCase(milestonesTile)){
		tileList.remove("Milestone");
	}
	if("false".equalsIgnoreCase(budgetTile)){
		tileList.remove("Budget");
	}
	if("false".equalsIgnoreCase(riskTile)){
		tileList.remove("Risk");
	}
	if("false".equalsIgnoreCase(issueTile)){
		tileList.remove("Issue");
	}
	report.PROJECT_STATUS_TILES = (String[])tileList.toArray(new String[tileList.size()]);
	
	//Store Report object in session as reference in different use case. 
	MapList mlSummaryTasks = report.getWBSSummaryTasks();
	int wbsSize = mlSummaryTasks.size(); 
	session.putValue("store", report);
	session.putValue("objectList", mlSummaryTasks);
	
	Map projectInfo = report.getProjectInfo();
	String sName = (String)projectInfo.get(ProgramCentralConstants.SELECT_NAME);
	
	//Project Status Info
	Map statusTileInfo = report.getStatusTileInfo(context);

	//Top level WBS Tasks Chart Info.
	Integer[] topLevelTasksByStatus = report.getTopLevelTasksChartData();
	
	//All Leaf WBS Task chart Info.
	Integer[][] wbsLeafTasks = report.getAllTasksChartInfo();
	
	//All Deliverables chart Info.
	Integer[][] wbsDeliverableTasks = report.getDeliverablesChartInfo();
	
	//Critical WBS Tasks Chart Info.
	Integer[][] criticalLeafTasks = report.getCriticalTasksChartData();

	//Burn Down Chart Info
	String[] aDataBurndown	= report.getBurnDownChartData(context);
	boolean isPlannedVisible = !(aDataBurndown[1]=="null");
	boolean isActualVisible = !(aDataBurndown[2]=="null");
%>

<HTML>
    <HEAD>
    	<link rel="stylesheet" href="../programcentral/styles/ProgramCentralStatusReport.css" type="text/css">
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css">
        <link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">
		<script type="text/javascript" src="../common/scripts/emxDashboardCommon.js"></script>	
		<script type='text/javascript'>	
		
			$( "" ).ready(function() {
	            drawTiles();
	            fillTiles();
	            return false;
	        });

            var percent = "%";
            var tileId = "";
            var tileExpression = "";
            var tileHeader = "";
            var tileHeaderExpression = "";
			var tileCount = <%=report.PROJECT_STATUS_TILES.length%>;
			
			//Render Dashboard Tiles.
			var drawTiles = function () {
	        	$("#divInnerTileContainer").append('<table class="statusTile" id="statusTileTable">');

	        	$("#divInnerTileContainer").append('<tr>');
        	    $("#divInnerTileContainer").append('<td><br/></td>');
	        	$("#divInnerTileContainer").append('</tr>');

	        	$("#divInnerTileContainer").append('<tr>');
        	    $("#divInnerTileContainer").append('<td>');
		    
        	    for(var elemCount=0; elemCount<tileCount; elemCount++){
	        	    $("#divInnerTileContainer").append('<div class="statusTileHeader" id=\"tileHeader' + elemCount + '\"></div>');
	        	    if(elemCount<tileCount){
		        	    $("#divInnerTileContainer").append('<div class="spacer" id=\"tileHeaderSpacer' + elemCount + '\"></div>');
	        	    }
		        }
	        	$("#divInnerTileContainer").append('</td>');
	        	$("#divInnerTileContainer").append('</tr>');

	        	$("#divInnerTileContainer").append('<tr>');
        	    $("#divInnerTileContainer").append('<td>');
		        
        	    for(var elemCount=0; elemCount<tileCount; elemCount++){
	        	    $("#divInnerTileContainer").append('<div class="statusTile" id=\"tile' + elemCount + '\"></div>');
	        	    if(elemCount<tileCount){
		        	    $("#divInnerTileContainer").append('<div class="spacer" id=\"tileSpacer' + elemCount + '\"></div>');
	        	    }
		        }
	        	$("#divInnerTileContainer").append('</td>');
	        	$("#divInnerTileContainer").append('</tr>');
	        	
				$("#divInnerTileContainer").append('</table>');
			};

			//Populate Dashboard Tiles.
	        var fillTiles = function () {
				<%
					String[] tiles = report.PROJECT_STATUS_TILES;
					for(int index=0; index<tiles.length; index++){
						String tile = tiles[index];
						String tileHeaderKey = tile + ProgramCentralConstants.SPACE + "Status Header";
						String tileBodyKey = tile + ProgramCentralConstants.SPACE + "Status Body";
						String tileFooterKey = tile + ProgramCentralConstants.SPACE + "Status Footer";
						String tileColorKey = tile + ProgramCentralConstants.SPACE + "Status Colorcode";
						
						String sTileHeader = (String)statusTileInfo.get(tileHeaderKey);
						String sTileBody = (String)statusTileInfo.get(tileBodyKey);
						String sTileFooter = (String)statusTileInfo.get(tileFooterKey);
						String sTileColor = (String)statusTileInfo.get(tileColorKey);
%>
						var index = <%=index%>;
						tileId = "tile" + index;
						tileHeader = "tileHeader" + index;
						tileExpression =  "#" + tileId;
						tileHeaderExpression =  "#" + tileHeader;

						//Set Tile Header
						$(tileHeaderExpression).text('<%=sTileHeader%>');
	    				
	    				//Set Tile Body 
						var body = '<%=sTileBody%>';
						
						//Set Tile Footer 
	                    var footer = '<%=sTileFooter%>';
	                    
						$(tileExpression).append('<h1 class="statusTile" >' + body + '</h1>');	                    
						$(tileExpression).append('<span class="statusTile" >' + footer + '</span>');	                    
						
						//Set status color
						var statusColor = '<%=sTileColor%>';
                        $(tileExpression).css('border-bottom', '8px solid ' + statusColor);
<%						
					}				
				%>	        	
	        };
        
		    //To toggle specific div row in Dashobard
			var toggleRow = function(rowNum) {
				if(rowNum == 1){
					toggleChartInfo(divHeaderProjectStatus, divChartProjectStatus, null, null);
					toggleChartInfo(divHeaderTopLevelTasks, divChartTopLevelTasks, null, null);
				}else if(rowNum == 2){
					toggleChartInfo(divHeaderTasks, divChartTasks, null, divInfoTasks);
					toggleChartInfo(divHeaderDeliverables, divChartDeliverables, null, divInfoDeliverables);
					toggleChartInfo(divHeaderCriticalTasks, divChartCriticalTasks, null, divInfoCriticalTasks);
				}else if(rowNum == 3){
					toggleChartInfo(headerTextGantt, divChartGantt, null, null);
				}else if(rowNum == 4){
					toggleChartInfo(divHeaderBurndown, divChartBurnDown, null, null);
				}		
			};
		
			//This fucntion will be called when Back button on the Gantt div is clicked. 
			var reloadGanttChart = function() {
			var url = "../programcentral/emxProgramCentralUtil.jsp?mode=updateSessionWithSummaryTasks&random=" + new Date().getTime();
			emxUICore.getData(url);
			var ganttUrl = "../webapps/ENOGantt/gantt-widget.html?viewId=<%=ProgramCentralConstants.VIEW_STATUS_REPORT%>&initGantt=true&objectId=<%=sOID%>";
				$(".taskViewer").attr('src', ganttUrl);
				$('#headerTextGantt').text('<%=report.CHART_HEADER_GANTT%>');
				$('#button').hide();
			};
		
			//To initialize the Gantt.
			var initGanttChart = function() {
			<%
				if(wbsSize > 0){
			%>
				var headerTextGantt 		= document.getElementById("headerTextGantt");
				var chartGantt 				= document.getElementById("divChartGantt");
				var heightDivGantt 			= 0;				
				var divButton 				= document.getElementById("button");
				headerTextGantt.innerHTML 	= "<%=report.CHART_HEADER_GANTT%>";
				divButton.style.visibility 	= "hidden";
				divButton.style.display 	= "none";
				chartGantt.style.height = "350px";
				chartGantt.innerHTML 	= '<iframe class="taskViewer" width="100%" height="100%" frameBorder="0" type="text/html" src="../webapps/ENOGantt/gantt-widget.html?viewId=<%=ProgramCentralConstants.VIEW_STATUS_REPORT%>&initGantt=true&objectId=<%=sOID%>"></iframe>';
				//toggleChart(divHeaderGantt, divChartGantt, null);
			<%
					}
			%>
				};
				
			//This function will be called when Due Objects link is clicked.	
			var linkClick = function(method, header) {
				
				var url = "../programcentral/emxProjectManagementUtil.jsp?mode=getDueTasks&method=" + method + "&random=" + new Date().getTime();
				var objIds = emxUICore.getData(url);
				
				var chartGantt 				= document.getElementById("divChartGantt");			
				var divButton 				= document.getElementById("button");
				var headerTextGantt 		= document.getElementById("headerTextGantt");
				var divButton 				= document.getElementById("button");
				headerTextGantt.innerHTML 	= header;
				divButton.style.visibility 	= "visible";
				divButton.style.display 	= "inline";					
				
				sessionStorage.setItem("objectId", objIds);
				
				var ganttUrl = "../webapps/ENOGantt/gantt-widget.html?viewId=<%=ProgramCentralConstants.VIEW_STATUS_REPORT%>&projectId=<%=sOID%>";
				if(header.includes("Deliverables")){
					ganttUrl = ganttUrl+"&AddDeliverable=true";
				}
				$(".taskViewer").attr('src', ganttUrl);
			};
		</script>
		
		<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.2/js/modules/exporting.js"></script>		
		
		
		<script type="text/javascript">
			var chartPieTopLevelTasks;
			var chartPieTasks;
			var chartPieDeliverables;
			var chartPieCriticalTasks;
			var chartBarTasks;
			var chartBarDeliverables;
			var chartBurndown; 
			
			var colorAlternate 	= "#f5f5f5";
			var colorBorder 	= "#bababa";
			
			$(document).ready(function() {
				
				chartPieTopLevelTasks = new Highcharts.Chart({
		            chart: {
						renderTo: 'chartPieTopLevelTasks',
		                type: 'bar'
		            },
					title: 		{ text: null },
					credits: 	{ enabled : false },
					exporting: 	{ enabled : false },
					tooltip: {
						positioner: function () {
							 return { x:150, y: 0 };},
						formatter: function() {
							return '<b>'+ this.series.name +'</b>: '+ this.y +' ('+ Math.round(this.percentage*10)/10 +'%)';
						}
					},
		            legend: {
		                backgroundColor: 'white',
		                borderColor: '#CCC',
		                borderWidth: 1,
		                shadow: false
		            },

		            xAxis: {
		                categories: [''],
		                lineWidth: 0
		            },
		            yAxis: {
		            	allowDecimals : false,
	            	   lineWidth: 0,
		                min: 0,
		                title: {
		                    text: null
		                }
		            },
		            plotOptions: {
		                series: {
		                    stacking: 'normal',
		                    point:{
								events: {
					                click: function (event) {
					                	if(this.series.name=='<%=report.STATUS_PENDING%>')//for pending task
					                		linkClick ('getTopLevelPendingTask','<%=report.GANTT_HEADER_TOPLEVEL_PENDING_TASKS%>');
					                	else if(this.series.name=='<%=report.STATUS_OVERDUE%>')//overduetask
					                		linkClick ('getTopLevelOverdueTask','<%=report.GANTT_HEADER_TOPLEVEL_OVERDUE_TASKS%>');	
					                	else if(this.series.name=='<%=report.STATUS_LATE_START%>')//late start
					                		linkClick ('getTopLevelLateStartTask','<%=report.GANTT_HEADER_TOPLEVEL_LATESTART_TASKS%>');
					                	else if(this.series.name=='<%=report.STATUS_COMPLETED%>')//completed
					                		linkClick ('getTopLevelCompleteTask','<%=report.GANTT_HEADER_TOPLEVEL_COMPLETED_TASKS%>');              		
					              	  }
									}
								}
		                },
		                bar: {
		                    stacking: 'normal',
		                    dataLabels: {
		                        enabled: true,
		                        color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white',
		                    }
		                }
		            },
	                series: [{
		                name: '<%=report.STATUS_PENDING%>',
		                color: '<%=report.STATUS_PENDING_COLOR%>',
		                data: [<%=topLevelTasksByStatus[0]%>]
		            }, {
		                name: '<%=report.STATUS_OVERDUE%>',
		                color: '<%=report.STATUS_OVERDUE_COLOR%>',
		                data: [<%=topLevelTasksByStatus[1]%>]
		            }, {
		                name: '<%=report.STATUS_LATE_START%>',
		                color: '<%=report.STATUS_LATE_START_COLOR%>',
		                data: [<%=topLevelTasksByStatus[2]%>]
		            }, {
		                name: '<%=report.STATUS_COMPLETED%>',
		                color: '<%=report.STATUS_COMPLETED_COLOR%>',
		                data: [<%=topLevelTasksByStatus[3]%>]
		            } ]
				});

				chartPieTasks = new Highcharts.Chart({
					chart: {
						renderTo: 'chartPieTasks',
						plotBackgroundColor: null,
						plotBorderWidth: null,
						plotShadow: true
					},
					title: 		{ text: null },
					credits: 	{ enabled : false },
					legend: 	{ enabled : false },	
					exporting: 	{ enabled : false},
					tooltip: {
						formatter: function() {
							return '<b>'+ this.point.name +'</b>: '+ this.y +' ('+ Math.round(this.percentage*10)/10 + '%)';
						}
					},
					plotOptions: {
						pie: {
							cursor: 'pointer',
				            size:'120%',
							dataLabels: { 
								distance	: 5,
								enabled 	: true ,
								style		: { fontSize : '10px' },
								formatter	: function() {
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
						name: 'Activity Status',
						data: [
							{
								y:<%=wbsLeafTasks[0][0]%>,
								name:'<%=report.STATE_IDLE%>',	 	
								color:'<%=report.STATE_IDLE_COLOR%>'
							},
							{
								y:<%=wbsLeafTasks[0][1]%>,
								name:'<%=report.STATE_ACTIVE%>',
								color:'<%=report.STATE_ACTIVE_COLOR%>'
							},
							{
								y:<%=wbsLeafTasks[0][2]%>,
								name:'<%=report.STATE_REVIEW%>',
								color:'<%=report.STATE_REVIEW_COLOR%>'
							},
							{
								y:<%=wbsLeafTasks[0][3]%>, 
								name:'<%=report.STATE_COMPLETE%>',
								color:'<%=report.STATE_COMPLETE_COLOR%>'
							}
						]					
					}]				
				});

				chartPieDeliverables = new Highcharts.Chart({
					chart: {
						renderTo: 'chartPieDeliverables',
						plotBackgroundColor: null, 
						plotBorderWidth: null,
						plotShadow: true
					},
					title: 		{ text: null },
					credits: 	{ enabled : false },
					legend: 	{ enabled : false },	
					exporting: 	{ enabled : false},
					tooltip: {
						formatter: function() {
							return '<b>'+ this.point.name +'</b>: '+ this.y +' ('+ Math.round(this.percentage*10)/10 +'%)';
						}
					},
					plotOptions: {
						pie: {
							cursor: 'pointer',
				            size:'120%',
							dataLabels: { 
								distance	: 5,
								enabled 	: true ,
								style		: { fontSize : '10px' },
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
						name: 'Deliverables Status',
						data: [
								{
									y:<%=wbsDeliverableTasks[0][0]%>,
									name:'<%=report.STATE_IDLE%>',	 	
									color:'<%=report.STATE_IDLE_COLOR%>'
								},
								{
									y:<%=wbsDeliverableTasks[0][1]%>,
									name:'<%=report.STATE_ACTIVE%>',
									color:'<%=report.STATE_ACTIVE_COLOR%>'
								},
								{
									y:<%=wbsDeliverableTasks[0][2]%>,
									name:'<%=report.STATE_REVIEW%>',
									color:'<%=report.STATE_REVIEW_COLOR%>'
								},
								{
									y:<%=wbsDeliverableTasks[0][3]%>, 
									name:'<%=report.STATE_COMPLETE%>',
									color:'<%=report.STATE_COMPLETE_COLOR%>'
								}
							]					
					}]				
				});

				chartPieCriticalTasks = new Highcharts.Chart({
					chart: {
						renderTo: 'chartPieCriticalTasks',
						plotBackgroundColor: null,
						plotBorderWidth: null,
						plotShadow: true
					},
					title: 		{ text: null },
					credits: 	{ enabled : false },
					legend: 	{ enabled : false },	
					exporting: 	{ enabled : false},
					tooltip: {
						formatter: function() {
							return '<b>'+ this.point.name +'</b>: '+ this.y +' ('+ Math.round(this.percentage*10)/10 +'%)';
						}
					},
					plotOptions: {
						pie: {
							cursor: 'pointer',
				            size:'120%',
							dataLabels: { 
								distance	: 5,
								enabled 	: true ,
								style		: { fontSize : '10px' },
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
						name: 'Deliverables Status',
						data: [
								{	
									y:<%=criticalLeafTasks[0][0]%>, 
									name:'<%=report.STATE_IDLE%>',	 	
									color:'<%=report.STATE_IDLE_COLOR%>'
								},
								{
									y:<%=criticalLeafTasks[0][1]%>,
									name:'<%=report.STATE_ACTIVE%>',
									color:'<%=report.STATE_ACTIVE_COLOR%>'
								},
								{
									y:<%=criticalLeafTasks[0][2]%>, 
									name:'<%=report.STATE_REVIEW%>',
									color:'<%=report.STATE_REVIEW_COLOR%>'
								},
								{
									y:<%=criticalLeafTasks[0][3]%>,
									name:'<%=report.STATE_COMPLETE%>',
									color:'<%=report.STATE_COMPLETE_COLOR%>'
								}
						]					
					}]				
				});
				
				chartBarTasks = new Highcharts.Chart({
					chart: {	
						renderTo	: 'chartBarTasks',
						type		: 'bar',
						marginRight	: 20,
						marginLeft	: 100,
						plotBorderColor: colorBorder,
						plotBorderWidth: 1
					},
					title:		{ text: null },
					credits: 	{ enabled : false },
					legend: 	{ enabled : false },
					exporting:	{ enabled : false},
					xAxis: 		{ 
						tickColor: '#FFF', 
						categories: [
						             '<%=report.STATUS_PENDING%>',
						             '<%=report.STATUS_OVERDUE%>',
						             '<%=report.STATUS_LATE_START%>',
						             '<%=report.STATUS_COMPLETED%>'],
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
						name: 'Activities',
						data: [		
							{ 
								y:<%=wbsLeafTasks[1][0]%>,
								name : '<%=report.STATUS_PENDING%>',
								color:'<%=report.STATUS_PENDING_COLOR%>'
							},
							{
								y:<%=wbsLeafTasks[1][1]%>,
								name : '<%=report.STATUS_OVERDUE%>',
								color:'<%=report.STATUS_OVERDUE_COLOR%>'
							},
							{ 
								y:<%=wbsLeafTasks[1][2]%>,
								name : '<%=report.STATUS_LATE_START%>',
								color:'<%=report.STATUS_LATE_START_COLOR%>'
							},
							{ 
								y:<%=wbsLeafTasks[1][3]%>,
								name : '<%=report.STATUS_COMPLETED%>',
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
				                click: function (event) {
				                	if(this.x==0)//for pending task
				                	linkClick ('getAllPendingTask','<%=report.GANTT_HEADER_All_PENDING_TASKS%>');
				                	else if(this.x==1)//overduetask
				                		linkClick ('getAllOverdueTask','<%=report.GANTT_HEADER_All_OVERDUE_TASKS%>');	
				                	else if(this.x==2)//late start
				                		linkClick ('getAllLateStartTask','<%=report.GANTT_HEADER_All_LATESTART_TASKS%>');
				                	else if(this.x==3)//compeleted
				                		linkClick ('getAllCompleteTask','<%=report.GANTT_HEADER_All_COMPLETED_TASKS%>');
				                		
				              	  }
								}
							}
						}	
					}						
				});

				chartBarDeliverables = new Highcharts.Chart({
					chart: {
						renderTo	: 'chartBarDeliverables',
						type		: 'bar',
						marginRight	: 20,
						marginLeft	: 100,
						plotBorderColor: colorBorder,
						plotBorderWidth: 1
					},
					title:		{ text: null },
					credits: 	{ enabled : false },
					legend: 	{ enabled : false },
					exporting:	{ enabled : false },
					xAxis: 		{ 
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
						name: 'Deliverables',
						data: [		
								{ 
									y:<%=wbsDeliverableTasks[1][0]%>,
									name : '<%=report.STATUS_PENDING%>',
									color:'<%=report.STATUS_PENDING_COLOR%>'
								},
								{
									y:<%=wbsDeliverableTasks[1][1]%>,
									name : '<%=report.STATUS_OVERDUE%>',
									color:'<%=report.STATUS_OVERDUE_COLOR%>'
								},
								{ 
									y:<%=wbsDeliverableTasks[1][2]%>,
									name : '<%=report.STATUS_LATE_START%>',
									color:'<%=report.STATUS_LATE_START_COLOR%>'
								},
								{ 
									y:<%=wbsDeliverableTasks[1][3]%>,
									name : '<%=report.STATUS_COMPLETED%>',
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
					                click: function (event) {
					                	if(this.x==0)//for pending task
					                	linkClick ('getPendingDeliverables','<%=report.GANTT_HEADER_PENDING_TASKS_WITH_DELIVERABLES%>');
					                	else if(this.x==1)//overduetask
					                		linkClick ('getOverdueDeliverables','<%=report.GANTT_HEADER_OVERDUE_TASKS_WITH_DELIVERABLES%>');	
					                	else if(this.x==2)//late start
					                		linkClick ('getLateStartDeliverables','<%=report.GANTT_HEADER_LATESTART_TASKS_WITH_DELIVERABLES%>');
					                	else if(this.x==3)//compeleted
					                		linkClick ('getCompletedDeliverables','<%=report.GANTT_HEADER_COMPLETED_TASKS_WITH_DELIVERABLES%>');
					                		
					              	  }
									}
								}
						}							
					}					
				});

				chartBarCriticalTasks = new Highcharts.Chart({
					chart: {
						renderTo	: 'chartBarCriticalTasks',
						type		: 'bar',
						marginRight	: 20,
						marginLeft	: 100,
						plotBorderColor: colorBorder,
						plotBorderWidth: 1
					},
					title:		{ text: null },
					credits: 	{ enabled : false },
					legend: 	{ enabled : false },
					exporting:	{ enabled : false },
					xAxis: 		{ 
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
						name: 'Deliverables',
						data: [		
								{ 
									y:<%=criticalLeafTasks[1][0]%>,
									name : '<%=report.STATUS_PENDING%>',
									color:'<%=report.STATUS_PENDING_COLOR%>'
								},
								{
									y:<%=criticalLeafTasks[1][1]%>,
									name : '<%=report.STATUS_OVERDUE%>',
									color:'<%=report.STATUS_OVERDUE_COLOR%>'
								},
								{ 
									y:<%=criticalLeafTasks[1][2]%>,
									name : '<%=report.STATUS_LATE_START%>',
									color:'<%=report.STATUS_LATE_START_COLOR%>'
								},
								{ 
									y:<%=criticalLeafTasks[1][3]%>,
									name : '<%=report.STATUS_COMPLETED%>',
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
					                click: function (event) {
					                	if(this.x==0)//for pending task
					                	linkClick ('getPendingCriticalTask','<%=report.GANTT_HEADER_CRITICAL_PENDING_TASKS%>');
					                	else if(this.x==1)//overduetask
					                		linkClick ('getOverdueCriticalTask','<%=report.GANTT_HEADER_CRITICAL_OVERDUE_TASKS%>');	
					                	else if(this.x==2)//late start
					                		linkClick ('getLateStartCriticalTask','<%=report.GANTT_HEADER_CRITICAL_LATESTART_TASKS%>');
					                	else if(this.x==3)//compeleted
					                		linkClick ('getCompletedCriticalTask','<%=report.GANTT_HEADER_CRITICAL_COMPLETED_TASKS%>');
					                		
					              	  }
									}
								}
						}							
					}					
				});
				
				chartBurndown = new Highcharts.Chart({
					chart: {
						marginTop			: 30,
						marginBottom		: 80,
						marginLeft			: 60,
						renderTo			: 'divChartBurnDown',
					},
					title:		{ text    	: null  },
					credits: 	{ enabled 	: false },
					exporting:	{ enabled 	: false},
					xAxis: [{
						categories			: [<%=aDataBurndown[0]%>],
						gridLineColor		: '#f1f1f1',
						gridLineWidth 		: 1,
						labels				: { 
							align			: 'right',
							y				: 10,
							rotation		: -90
						},
						tickmarkPlacement 	: 'on',
						plotLines			: [{
			                color			: 'grey',
			                width			: 2,
			                dashStyle		: 'dash',
			                value			: <%=aDataBurndown[3]%>,
			            }]
					}],
					yAxis: [{
						allowDecimals 		: false,
						labels				: {
							style			: {
								fontSize	: '10px',
								color		: 'black',
								fontWeight 	: 'normal'
							}
						},
						min					: 0,
						title				: { text: '<%=report.CHART_BURNDOWN_REMAINING_TASKS%>' }
					}],
					tooltip: {
						enabled : true,
						crosshairs			: true,
						shared				: true,
						useHTML             : true,
						formatter: function() {
							var remaining = "<%=remainingStr%>";
							var plannedToolTip = '<br>'+'<font color=\"#336699\">'+remaining+' '+this.points[0].series.name+'</font>:'+this.points[0].y;
							
							var toolTip = '';
							if(<%=isPlannedVisible%>==true&&this.points[0]){
								toolTip =toolTip + plannedToolTip;
							}
							if(<%=isActualVisible%>==true&&this.points[1]){
								var actualToolTip = '<br>'+'<font color=\"#FF7F00\">'+remaining+' '+this.points[1].series.name+'</font>:'+this.points[1].y ;
								toolTip =toolTip + actualToolTip;
							}
							return this.x+'<br>'+toolTip;
						}
					},
					legend: {
					  	align: 'right',
					  	verticalAlign: 'top',
				      	floating: true,
				      	x: 0,
				      	y: 0,	
						align				: 'right',
						backgroundColor		: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF',
													style			: {
								fontSize	: '8px',
								color		: 'black',
								fontWeight 	: 'normal'
							}
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
						name	: '<%=report.CHART_BURNDOWN_PLANNED%>',
						color 	: '#336699',
						data	: [<%=aDataBurndown[1]%>],
						zIndex	: 4			
					}, {
						name	: '<%=report.CHART_BURNDOWN_ACTUAL%>',
						color 	: '#FF7F00',
						data	: [<%=aDataBurndown[2]%>],
						zIndex	: 3
					}]							
				});	
				
			});			

		</script>		
    </HEAD>
	<body id="reportContainer" onload="initGanttChart()" style="overflow: auto;">
			<CENTER>
				<table id="itemTable" width="100%">
					<tr>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
						<td width="31%" style="line-height:5px">&nbsp;</td>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
						<td width="30%" style="line-height:5px">&nbsp;</td>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
						<td width="31%" style="line-height:5px">&nbsp;</td>
						<td width="1%"  style="line-height:5px">&nbsp;</td>
					</tr>
					
					<tr><td colspan="7" style="line-height:10px">&nbsp;</td></tr>
					<tr>
						<td />
						<td colspan="3" style="line-height:5px">
							<div class="header expanded" id="divHeaderProjectStatus" onclick="toggleRow(1)"><%=report.CHART_HEADER_STATUS_TILE%></div>
							<div class="chart chartBorder outerTileContainer" id="divChartProjectStatus" style="height:150px;">
								<div class="innerTileContainer" id="divInnerTileContainer" style="height:100%">
								</div>								
							</div>
						</td>
						<td />
						<td style="line-height:5px">
							<div class="header expanded" id="divHeaderTopLevelTasks" onclick="toggleRow(1)"><%=report.CHART_HEADER_TASK_TOP_LEVEL%></div>
							<div class="chart chartBorder" id="divChartTopLevelTasks" style="height:150px;">
								<div id="chartPieTopLevelTasks" style="height:100%;"></div>	
							</div>
						</td>
						<td />
					</tr>
					<tr><td colspan="7" style="line-height:10px">&nbsp;</td></tr>					
					<tr><td colspan="7" style="line-height:4px">&nbsp;</td></tr>				
					<tr>
						<td >&nbsp;</td>
						<td>
							<div class="header expanded" id="divHeaderTasks" onclick="toggleRow(2)"><%=report.CHART_HEADER_TASK_ALL%></div>
							<div class="chart"  id="divChartTasks" >
								<div id="chartPieTasks" style="height:120px"></div>					
								<div id="chartBarTasks" style="height:120px"></div>					
							</div>
							<div class="info" id="divInfoTasks"  >
								<table width="100%">
									<tr>
										<td width="5px">&nbsp;</td>
										<td width="25%" class="link" style="text-align:left"><b><%=wbsLeafTasks[2][0]%></b>   <a href="javascript:linkClick('getTasksDueThisWeek' 	, '<%=report.GANTT_HEADER_TASKS_DUE_THIS_WEEK%>')" 	target=""><%=report.DUE_THIS_WEEK%></a></td>
										<td width="25%" class="link" style="text-align:center"><b><%=wbsLeafTasks[2][1]%></b> <a href="javascript:linkClick('getTasksDueThisMonth'	, '<%=report.GANTT_HEADER_TASKS_DUE_THIS_MONTH%>')" target=""><%=report.DUE_THIS_MONTH%></a></td>
										<td width="25%" class="link" style="text-align:center"><b><%=wbsLeafTasks[2][2]%></b> <a href="javascript:linkClick('getTasksDueSoon'		, '<%=report.GANTT_HEADER_TASKS_SOON%>')" 			target=""><%=report.SOON%></a></td>
										<td width="25%" class="link" style="text-align:right"><b><%=wbsLeafTasks[2][3]%></b>  <a href="javascript:linkClick('getTasksOverdue'		, '<%=report.GANTT_HEADER_TASKS_OVERDUE%>')" 		target=""><%=report.OVERDUE%></a></td>
										<td width="5px">&nbsp;</td>
									</tr>
								</table>
							</div>
						</td>
						<td>&nbsp;</td>
						<td>
							<div class="header expanded" id="divHeaderDeliverables" onclick="toggleRow(2)"><%=report.CHART_HEADER_TASK_DELIVERABLES%></div>
							<div class="chart"  id="divChartDeliverables" >
								<div id="chartPieDeliverables" style="height: 120px"></div>					
								<div id="chartBarDeliverables" style="height: 120px"></div>						
							</div>
							<div class="info" id="divInfoDeliverables">
								<table width="100%">
									<tr>
										<td width="5px">&nbsp;</td>	
										<td width="25%" class="link" style="text-align:left"><b><%=wbsDeliverableTasks[2][0]%> </b>  <a href="javascript:linkClick('getDeliverablesDueThisWeek'	, 	'<%=report.GANTT_HEADER_DELIVERABLES_DUE_THIS_WEEK%>' )" target=""><%=report.DUE_THIS_WEEK%></a></td>
										<td width="25%" class="link" style="text-align:center"><b><%=wbsDeliverableTasks[2][1]%></b> <a href="javascript:linkClick('getDeliverablesDueThisMonth', 	'<%=report.GANTT_HEADER_DELIVERABLES_DUE_THIS_MONTH%>')" target=""><%=report.DUE_THIS_MONTH%></a></td>
										<td width="25%" class="link" style="text-align:center"><b><%=wbsDeliverableTasks[2][2]%></b> <a href="javascript:linkClick('getDeliverablesDueSoon'		, 	'<%=report.GANTT_HEADER_DELIVERABLES_SOON%>'     )" target=""><%=report.SOON%></a></td>										
										<td width="25%" class="link" style="text-align:right"><b><%=wbsDeliverableTasks[2][3]%></b>  <a href="javascript:linkClick('getDeliverablesOverdue'		,	'<%=report.GANTT_HEADER_DELIVERABLES_OVERDUE%>'  )" target=""><%=report.OVERDUE%></a></td>									
										<td width="5px">&nbsp;</td>
									</tr>
								</table>
							</div>						
						</td>					
						<td >&nbsp;</td>
						<td>
							<div class="header expanded" id="divHeaderCriticalTasks" onclick="toggleRow(2)"><%=report.CHART_HEADER_TASK_CRITICAL%></div>
							<div class="chart"  id="divChartCriticalTasks" style="height: 240px">
								<div id="chartPieCriticalTasks" style="height: 120px"></div>					
								<div id="chartBarCriticalTasks" style="height: 120px"></div>						
							</div>	
							</div>
							<div class="info" id="divInfoCriticalTasks">
								<table width="100%">
									<tr>
										<td width="5px">&nbsp;</td>			
										<td width="25%" class="link" style="text-align:left"><b><%=criticalLeafTasks[2][0]%></b>   <a href="javascript:linkClick('getCriticalTasksDueThisWeek', '<%=report.GANTT_HEADER_CRITICAL_TASKS_DUE_THIS_WEEK%>' )" target=""><%=report.DUE_THIS_WEEK%></a></td>
										<td width="25%" class="link" style="text-align:center"><b><%=criticalLeafTasks[2][1]%></b> <a href="javascript:linkClick('getCriticalTasksDueThisMonth','<%=report.GANTT_HEADER_CRITICAL_TASKS_DUE_THIS_MONTH%>')" target=""><%=report.DUE_THIS_MONTH%></a></td>
										<td width="25%" class="link" style="text-align:center"><b><%=criticalLeafTasks[2][2]%></b> <a href="javascript:linkClick('getCriticalTasksDueSoon', 	'<%=report.GANTT_HEADER_CRITICAL_TASKS_SOON%>'     )" target=""><%=report.SOON%></a></td>
										<td width="25%" class="link" style="text-align:right"><b><%=criticalLeafTasks[2][3]%> </b> <a href="javascript:linkClick('getCriticalTasksOverdue', 	'<%=report.GANTT_HEADER_CRITICAL_TASKS_OVERDUE%>'  )" target=""><%=report.OVERDUE%></a></td>				
										<td width="5px">&nbsp;</td>
									</tr>
								</table>
							</div>						
						</td>					
						<td >&nbsp;</td>
					</tr>
					<tr><td colspan="7" style="line-height:10px">&nbsp;</td></tr>
					<tr>
						<td />
						<td colspan="5">
							<table width="100%">
								<tr>
									<td width="100%">
										<div class="header expanded" id="headerTextGantt" onclick="toggleRow(3)">
											<%=report.CHART_HEADER_GANTT%>
										</div>
									</td>
									<td class="buttons">
										<div id="button" style="display: none; float: right;">
											<a href="javascript:reloadGanttChart();" class="back"> <%=report.GANTT_HEADER_BACK_BUTTON%></a>
										</div>
									</td>
								</tr>
							</table>
							<div id="divChartGantt"  class="chart chartBorder"></div>
						</td>
						<td />
					</tr>
					<tr><td colspan="7" style="line-height:10px">&nbsp;</td></tr>
						<td>&nbsp;</td>
						<td colspan="5">
							<div class="header expanded" id="divHeaderBurndown" onclick="toggleRow(4)"><%=report.CHART_HEADER_BURN_DOWN %></div>
							<div class="chart chartBorder"	id="divChartBurnDown" style="height:300px"></div>	
						</td>						
						<td>&nbsp;</td>					
					<tr><td colspan="7" style="line-height:15px">&nbsp;</td></tr>					
				</table>	
			</CENTER>
    </body>
</HTML>

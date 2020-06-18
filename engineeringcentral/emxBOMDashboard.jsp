<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.engineering.ChartUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultInclude.inc"%>


<% 	
	String sLanguage		= request.getHeader("Accept-Language");
	String sOID 			= request.getParameter("objectId");
	String sCollapse		= request.getParameter("collapse");	
	
	String parts 		= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Common.Parts"));
	String states 		= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Common.States"));
	String weeks  		= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.Weeks"));
	String weekLimit	= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.WeeksLimit"));
	String partHeader	= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.PartChartHeader"));
	String clickMsg 	= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.ClickMessage"));
	String count		= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.Counts"));
	String headerCO		= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.COChartHeader"));
	String headerCA		= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.CAChartHeader"));
	String changeAction	= XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Markup.RelatedCA"));
	
	String sevLow = XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Range.Severity.Low"));
	String sevMedium = XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Range.Severity.Medium"));
	String sevHigh = XSSUtil.encodeForJavaScript(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Range.Severity.High"));
	
	String hidePanel	= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.HidePanel"));
	String restorePanel	= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.RestoreData"));
	String ownedItems	= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.OwnedItems"));
	String ownedParts	= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.OwnedParts"));
	String ownedChangeOrders	= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.OwnedChangeOrders"));
	String ownedChangeActions	= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Label.OwnedChangeActions"));
	
	//MyENGView change
	String strAppendObjects = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.MyEngViewSubHeader.KPIDataObj"));
	String strAppendState = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.MyEngViewSubHeader.KPIDataState"));
	String strAppendAge = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.MyEngViewSubHeader.KPIDataAge"));
	String strAppendWeeks = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.MyEngViewSubHeader.KPIDataWks"));
	String strAppendSeverity = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.MyEngViewSubHeader.KPIDataSev"));
	String sInitialLimit = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.MyENGViewInitialLoad.QueryLimit"));
	String sMaximumLimit = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.MaximumDisplay.QueryLimit"));
	
	if(UIUtil.isNullOrEmpty(sInitialLimit)){sInitialLimit = "50";}
	if(null == sCollapse) {sCollapse = "0"; }
	
	String initargs[]	= {};
	HashMap params 		= new HashMap();

	params.put("objectId"		, sOID		);		
	params.put("languageStr"	, sLanguage	);		
	
	ChartUtil chartUtil = new ChartUtil(context);
	com.dassault_systemes.enovia.partmanagement.modeler.util.PartMgtUtil partMgtUtil = new com.dassault_systemes.enovia.partmanagement.modeler.util.PartMgtUtil();
	String[] dashBoardData = chartUtil.getCountDataForENGCharts(context);
	String[] messageValues = {sInitialLimit};
	String initialSubHeader = XSSUtil.encodeForURL(context,partMgtUtil.getMacrosConvertedPropertyValue(context, "emxEngineeringCentral.EngView.MyViewSubHeader", messageValues, "emxEngineeringCentralStringResource"));
	String partLabelKey 		= XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Common.Parts"));
	String specLabelKey = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Common.Specifications"));
	String changeLabelKey = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Markup.Change"));
	String refDocLabelKey = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.ECOSummary.ReferenceDocuments"));
	String searchCriteria = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Subheader.SearchCriteria"));
	String sLoading = XSSUtil.encodeForHTML(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxNavigator.UIMenuBar.Loading"));		
%>

<html>

	<head>
	
<% 	if(!"".equals(sOID)) { %>
		<script type="text/javascript">
			var footerurl = 'foot URL';
			addStyleSheet("emxUIToolbar");
			addStyleSheet("emxUIMenu");
			addStyleSheet("emxUIDOMLayout");
		</script>
		<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>	
<% 	} %>	
	
		<link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">			
		<link rel="stylesheet" type="text/css" href="../common/styles/enoDashboardPanelRight.css">	
		<link rel="stylesheet" type="text/css" href="styles/enoENGDashboardPanelRight.css">
<%
	if(UINavigatorUtil.isMobile(context)){
%>
		<link rel="stylesheet" type="text/css" href="../common/mobile/styles/emxUIMobile.css">
<%		
	}
%>	
		
		<script type="text/javascript" src="../common/scripts/emxDashboardDefaults.js"></script>
		<script type="text/javascript" src="../common/scripts/emxDashboardCommon.js"></script>
		<script type="text/javascript" src="../common/scripts/emxDashboardPanelRight.js"></script>
		<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/highcharts.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/highcharts-more.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/modules/funnel.js"></script>
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/modules/exporting.js"></script>	
		<script type="text/javascript" src="../plugins/highchart/3.0.10/js/modules/drilldown.js"></script>		

		<script type="text/javascript">	
		var VALUE_CONFIRMATION_MSG= "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.MyENGView.ConfirmationMessage")%>";
		var VALUE_ALERT_MSG= "<%=EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.MyENGView.AlertMessage")%>";
		function initPage() {
				var divLeft 		= document.getElementById("left");
				var widthLeft 		= $(window).width() - 571;
				<%-- XSSOK --%>
				//divLeft.innerHTML	= "<iframe id='frameDashboard' style='width:" + widthLeft + "px;border:none;' src='../common/emxPortal.jsp?portal=ENCMyENGView&header=emxEngineeringCentral.EngView.MyView&showPageHeader=false&customSearchCriteria=true&HelpMarker=emxhelpmyviewparts'></iframe> ";
				divLeft.innerHTML	= "<iframe id='frameDashboard' name='BOMDashboard' style='width:" + widthLeft + "px;border:none;' src='../engineeringcentral/emxCommonFilterIntermediate.jsp?initialQueryLimit="+<%=sInitialLimit%>+"&table=ENCEngineeringView&header=emxEngineeringCentral.Common.Parts&subHeader="+'<%=initialSubHeader%>'+"&sortColumnName=Last Modified&program=enoENGView:findMyViewObjects&selection=multiple&sortDirection=descending&HelpMarker=emxhelpmyviewparts&toolbar=ENCPartSearchToolbar&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&mode=view&type=type_Part&customFormName=EngineeringDashboardFilter&initialState=&excludePolicy=Manufacturing Part&includeState=&checkOriginator=true&checkUserPreferences=true&freezePane=Name,Title&suiteKey=EngineeringCentral&customSearchCriteria=true'></iframe> ";
				//XSSOK
				var collapse = "<%=XSSUtil.encodeURLForServer(context, sCollapse)%>";
				if(collapse.indexOf("1") != -1) { toggleChartInfo(divHeaderCounters, chartKPI); }
				if(collapse.indexOf("2") != -1) { toggleChartInfo(divHeaderParts, divChartParts, chartParts); }
				//if(collapse.indexOf("3") != -1) { toggleChartInfo(divHeaderSpecs, divChartSpecs, chartSpecs); }
				if(collapse.indexOf("4") != -1) { toggleChartInfo(divHeaderChangeCOs, divChartChangeCOs, chartChangeCOs); }
				if(collapse.indexOf("5") != -1) { toggleChartInfo(divHeaderChangeCAs, divChartChangeCAs, chartChangeCAs); }
			}
		</script>	
		
	</head>
	
	
		<script type="text/javascript">

			var engCounters;
			var chartParts;
			var chartChangeCOs;
			
			var colorSet = ['#2F7ED8','#FF9933','#FFF000','#8BBC21','#A0A0A0','#CC3333'];
			
			//My ENG View changes
			var stateArray;
			var stateArrayEn;
			var statesData = [];
			var prevResponse;
			var prevResponseCO;
			var prevResponseCA;
			var barChartData;
			var barChartDataCO;
			var barChartDataCA;
			var subHeader;
			var maxLimit = "<%=sMaximumLimit%>";
			var displayQty;
			$(document).ready(function () {
				function isOverflown(element) {
				    return element.scrollWidth > element.clientWidth;
				}
				
				function resizeFont(element){
					var el = document.getElementById(element).children[0].children[0];	
					var fontSize = parseInt(el.style.fontSize);
					for (var i = fontSize; i >= 0; i--) {
					    var overflow = isOverflown(el);
					    if (overflow) {
					     fontSize--;
					     el.style.fontSize = fontSize + "pt";
					    }else{
					    	break;
					    }
					}
					return fontSize;
				}
				var idArray = ["part", "specs", "refDoc", "change"];
				var fontSize = [];
				for(var i=0; i<idArray.length; i++){
					
					fontSize[i] = resizeFont(idArray[i]);
					
				}
				var minFontSize = Math.min.apply(null,fontSize);
				if(minFontSize != 25){
					for(var i=0; i<idArray.length; i++){
						document.getElementById(idArray[i]).children[0].children[0].style.fontSize = minFontSize + "pt";
					}	
				}
				
				$("#divHeaderParts").click(function (){
				//creating Drilldown Data for Parts
					if(typeof(prevResponse) == 'undefined' || prevResponse == null || prevResponse == ''){
						//Adds the progress indicator when headers are expanded
						$("#divHeaderParts").prepend("<div id='imgLoadingProgressDiv' class='progress-indicator-text-sm' style='visibility: visible;'>'<%=sLoading%>'</div>");
						var xmlhttp = emxUICore.createHttpRequest();
						//Ajax call to get the objects count
						xmlhttp.open("POST", "emxBOMDashboardCount.jsp?mode=Part", false);
						xmlhttp.setRequestHeader("Content-Type", "text/plain;charset=utf-8");
						xmlhttp.send(null);
						if(xmlhttp.status == 200){
						prevResponse = true;
						var resultMap = new Map();
						resultMap = xmlhttp.responseText.split(':')[2];
						//Todo : Refine the string split
						var stateData = resultMap.split(",")[0].split("=")[1].replace(/-/gi, ",");
						var qtyPart = resultMap.substring(resultMap.indexOf("["), resultMap.lastIndexOf("]")+1).replace(/-/gi, ",");
						var stateDataEn = resultMap.substring(resultMap.lastIndexOf("=")+1, resultMap.lastIndexOf("}")).replace(/-/gi, ",");
						barChartData = new Map();
						barChartData.set('quantityPart', qtyPart);
						barChartData.set('statePart', stateData);
						barChartData.set('statePartEn', stateDataEn);
				}
				}
				statesData = [],
                ages = [],
                drilldownSeries = [];
				
				stateArray = eval(barChartData.get("statePart").split(","));
				stateArrayEn = eval(barChartData.get("statePartEn").split(","));
				//XSSOK
				var ageQtyArray = eval(barChartData.get("quantityPart")); 

				$.each(stateArray, function(index, stateValue){
					
					var totalStateQty = 0;
					for(i=0;i<ageQtyArray[index].length;i++){
						totalStateQty += ageQtyArray[index][i];
					}
					
					var stateValueEn = stateArrayEn[index];
					
					statesData.push({
						name: stateValue,
						y: totalStateQty,
						drilldown: stateValue,
						events: { 
							click: function () {
								displayQty = (totalStateQty > maxLimit) ? maxLimit : totalStateQty;
								subHeader = createSubheader(displayQty, totalStateQty, stateValueEn, null, null);
								openURLInDetailsBOM("../common/emxIndentedTable.jsp?program=emxPart:getFilteredChartData&table=ENCEngineeringView&toolbar=ENCFullSearchToolbar&selection=multiple&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&mode=view&hideExtendedHeader=true&header=emxEngineeringCentral.Common.Parts&subHeader="+subHeader+"&type=type_Part&state="+stateValueEn, totalStateQty,"green");
                			}
            			}
					});
					
					ages[index] = [];
					$.each(ageQtyArray[index], function(i, ageValue){
						ages[index].push({ 
							//XSSOK
											name: (i == 10 ? '<%=weekLimit%>' : i + ' ' + '<%=weeks%>'),
											y: ageValue,
											events: { 
												click: function () {
													displayQty = (ageValue > maxLimit) ? maxLimit : ageValue;
													subHeader = createSubheader(displayQty, ageValue, stateValueEn, +i, null);
													openURLInDetailsBOM("../common/emxIndentedTable.jsp?program=emxPart:getFilteredChartData&table=ENCEngineeringView&toolbar=ENCFullSearchToolbar&selection=multiple&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&mode=view&hideExtendedHeader=true&header=emxEngineeringCentral.Common.Parts&subHeader="+subHeader+"&type=type_Part&state="+stateValueEn+"&age="+i, ageValue, "green");
			                        			}
			                    			}
						});
					});
					
					drilldownSeries.push({
	                    name: stateValue,
	                    id: stateValue,
	                    data: ages[index]
	                });
					
				});
				
	            // Create the chart for Parts
	            chartParts = new Highcharts.Chart({
	            	credits		: { enabled: false	},
	            	exporting   : { enabled : false },
	                chart: {
	                    type: 'column',
	                    renderTo: 'divChartParts',
	                    events:{
	                    	drillup:function(){
	                    		
	                    	}
	                    }
	                },
	                title: {
	                	//XSSOK
	                    text: '<%=partHeader%>'
	                },
	                subtitle: {
	                	//XSSOK
	                    text: '<%=clickMsg%>'
	                },
	                xAxis: {
	                    type: 'category'
	                },
	                yAxis: {
	                	 min: 0,
	                    title: {
	                    	//XSSOK
	                        text: '<%=count%>'
	                    }
	                },
	                legend: {
	                    enabled: false
	                },
	                plotOptions: {
	                    series: {
	                        borderWidth: 1,
	                        dataLabels: {
	                            enabled: true
	                        },
	                        allowPointSelect: true
	                    }
	                },
	                tooltip: {
	                    headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
	                    pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y}</b>'
	                },
	                colors: colorSet,
	                series: [{
	                	//XSSOK
	                    name: '<%=states%>',
	                    colorByPoint: true,
	                    data: statesData
	                }],
	                drilldown: {
	                    series: drilldownSeries
	                }
	            });
	            toggleChartInfo(divHeaderParts, divChartParts, chartParts);  
	            jQuery('#imgLoadingProgressDiv').remove();
	            });           
	            
	         	// Create the chart for Specifications
				
				//openURLInDetails("../common/emxIndentedTable.jsp?program=emxPart:getFilteredChartData&table=ENCEngineeringView&toolbar=ENCFullSearchToolbar&selection=multiple&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&mode=view&hideExtendedHeader=true&header=emxEngineeringCentral.Common.Specifications&type=type_CADModel,type_CADDrawing,type_DrawingPrint,type_Sketch&state="+this.category); }									
					
				$("#divHeaderChangeCOs").click(function (){					
					if(typeof(prevResponseCO) == 'undefined' || prevResponseCO == null || prevResponseCO == ''){
				// Creating Data for Change Orders
				$("#divHeaderChangeCOs").prepend("<div id='imgLoadingProgressDiv' class='progress-indicator-text-sm' style='visibility: visible;'>'<%=sLoading%>'</div>");
				var xmlhttp = emxUICore.createHttpRequest();
					xmlhttp.open("POST", "emxBOMDashboardCount.jsp?mode=ChangeOrder", false);
					xmlhttp.setRequestHeader("Content-Type", "text/plain;charset=utf-8");
					xmlhttp.send(null);
					if(xmlhttp.status == 200){
					prevResponseCO = true;
					var resultMap = new Map();
					resultMap = xmlhttp.responseText.split(':')[2];
					
					//Todo : Refine the string split
					var stateCO = resultMap.substring(resultMap.indexOf("stateCO=")+"stateCO=".length, resultMap.indexOf(", quantityCO=")).replace(/-/gi, ",");
					var qtyCO = resultMap.substring(resultMap.indexOf("quantityCO=")).split("}")[0].split("=")[1].replace(/-/gi, ",");
					var stateCOEn = resultMap.substring(resultMap.indexOf("stateCOEn=")+"stateCOEn=".length, resultMap.indexOf(", stateCO=")).replace(/-/gi, ",");
					
					barChartDataCO = new Map();
					
					barChartDataCO.set('quantityCO', qtyCO);
					barChartDataCO.set('stateCO', stateCO);
					barChartDataCO.set('stateCOEn', stateCOEn);
					}
				}
				 //XSSOK
					var sevQtyArray  = eval(barChartDataCO.get("quantityCO"));
					stateArrayEn = eval((barChartDataCO.get("stateCOEn")).split(","));
					stateArray   = eval((barChartDataCO.get("stateCO")).split(","));
				statesData = [];
				
				$.each(sevQtyArray, function(i, sevValue){
					
					sevData = [];
					
					$.each(stateArrayEn, function(j, stateValue){
						sevData.push({
							stateName : stateValue,
							y : sevQtyArray[i][j]
						});
					});
					
					statesData.push(sevData);
				});
				
				// Create the chart for Change Orders
				chartChangeCOs = new Highcharts.Chart({
					credits		: { enabled: false},
					exporting   : { enabled : false },
					chart: {
			            type: 'column',
		            	renderTo	: 'divChartChangeCOs'
			        },
			        title: {
			        	//XSSOK
			            text: '<%=headerCO%>'
			        },
					xAxis: {
			            categories: stateArray
			        },
			        yAxis: {
			            min: 0,
			            title: {
			            	//XSSOK
			                text: '<%=count%>'
			            },
			            stackLabels: {
			                enabled: true,
			                style: {
			                    fontWeight: 'bold',
			                    color: 'gray'
			                }
			            }
			        },
			        legend: {
			            align: 'center',
			            x: -30,
			            verticalAlign: 'top',
			            y: 25,
			            floating: true,
			            backgroundColor: 'white',
			            borderColor: '#CCC',
			            borderWidth: 1,
			            shadow: false
			        },
			        tooltip: {
			            formatter: function () {
			            	//XSSOK
			                return '<b>' + this.x + '</b><br/>' +
			                    this.series.name + ': ' + this.y + '<br/>' +
			                    '<%=count%>'+': ' + this.point.stackTotal;
			            }
			        },
			        plotOptions: {
			            column: {
			                stacking: 'normal',
			                dataLabels: {
			                    enabled: true,
			                    color:  'white',
			                    style: {
			                        textShadow: '0 0 3px black'
			                    }
			                },
					        point: {
								events:{ click : function() {
									displayQty = (+this.y > maxLimit) ? maxLimit : +this.y;
									subHeader = createSubheader(displayQty, +this.y, this.options.stateName, null, this.series.name);
									openURLInDetailsBOM("../common/emxIndentedTable.jsp?table=ENCChangeMyEngineeringView&program=emxPart:getFilteredChartData&selection=multiple&toolbar=ENCFullSearchToolbar&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&mode=view&hideExtendedHeader=true&header=emxEngineeringCentral.Markup.Change&subHeader="+subHeader+"&type=type_ChangeOrder&state="+this.options.stateName+"&severity="+this.series._i, +this.y, "redBright"); }
								}
							}
			            }
			        },
			        //XSSOk
					series: [ { name: '<%=sevLow%>', data: statesData[0], color:'#009933' },
					          { name: '<%=sevMedium%>', data: statesData[1], color:'#FF8C00' },
					          { name: '<%=sevHigh%>', data: statesData[2], color:'#C00000 ' }
					        ]
				});
				toggleChartInfo(divHeaderChangeCOs, divChartChangeCOs, chartChangeCOs);
				jQuery('#imgLoadingProgressDiv').remove();
			});
				$("#divHeaderChangeCAs").click(function (){
					if(typeof(prevResponseCA) == 'undefined' || prevResponseCA == null || prevResponseCA == ''){
						$("#divHeaderChangeCAs").prepend("<div id='imgLoadingProgressDiv' class='progress-indicator-text-sm' style='visibility: visible;'>'<%=sLoading%>'</div>");
						//Creating Data for Change Actions
					var xmlhttp = emxUICore.createHttpRequest();
					xmlhttp.open("POST", "emxBOMDashboardCount.jsp?mode=ChangeAction", false);
					xmlhttp.setRequestHeader("Content-Type", "text/plain;charset=utf-8");
					xmlhttp.send(null);
					if(xmlhttp.status == 200){
					prevResponseCA = true;
					var resultMap = new Map();
					resultMap = xmlhttp.responseText.split(':')[2];
					
					//Creating Data for Change Actions
					var stateCA = resultMap.substring(resultMap.indexOf("stateCA=")+"stateCA=".length, resultMap.indexOf(", quantityCA")).replace(/-/gi, ",");
					var qtyCA = resultMap.substring(resultMap.indexOf("quantityCA=")+"quantityCA=".length, resultMap.indexOf(", stateCAEn")).replace(/-/gi, ",");
					var stateCAEn = resultMap.substring(resultMap.indexOf("stateCAEn=")).split("}")[0].split("=")[1].replace(/-/gi, ",");
					
					barChartDataCA = new Map();
					
					barChartDataCA.set('quantityCA', qtyCA);
					barChartDataCA.set('stateCA', stateCA);
					barChartDataCA.set('stateCAEn', stateCAEn);
				}
				}
				
				stateArray = eval((barChartDataCA.get("stateCA")).split(","));
				stateArrayEn = eval((barChartDataCA.get("stateCAEn")).split(","));
				//XSSOK
				var qtyArray = eval(barChartDataCA.get("quantityCA"));
				
				statesData = [];
				
				$.each(stateArrayEn, function(index, stateValue){
					statesData.push({
						stateName : stateValue,
						y : qtyArray[index]
					});
				});
				
				// Create the chart for Change Actions
				chartChangeCAs = new Highcharts.Chart({
					credits		: { enabled: false},
					exporting   : { enabled : false },
					chart: {
			            type : 'column',
		            	renderTo : 'divChartChangeCAs'
			        },
			        title: {
			        	//XSSOK
			            text: '<%=headerCA%>'
			        },
					xAxis: {
			            categories: stateArray
			        },
			        yAxis: {
			            min: 0,
			            title: {
			            	//XSSOK
			                text: '<%=count%>'
			            },
			            stackLabels: {
			                enabled: true,
			                style: {
			                    fontWeight: 'bold',
			                    color: 'gray'
			                }
			            }
			        },
			        legend: {
			            align: 'center',
			            x: -30,
			            verticalAlign: 'top',
			            y: 25,
			            floating: true,
			            backgroundColor: 'white',
			            borderColor: '#CCC',
			            borderWidth: 1,
			            shadow: false
			        },
			        tooltip: {
			            formatter: function () {
			            	//XSSOK
			                return '<b>' + this.x + '</b><br/>' +
			                    this.series.name + ': ' + this.y + '<br/>' +
			                    '<%=count%>'+': ' + this.point.stackTotal;
			            }
			        },
			        colors: colorSet,
			        plotOptions: {
			            column: {
			                stacking: 'normal',
			                dataLabels: {
			                    enabled: true,
			                    color:  'white',
			                    style: {
			                        textShadow: '0 0 3px black'
			                    }
			                },
					        point: {
								events:{ click : function() {
									displayQty = (+this.y > maxLimit) ? maxLimit : +this.y;
									subHeader = createSubheader(displayQty, +this.y, this.options.stateName, null, null);
									openURLInDetailsBOM("../common/emxIndentedTable.jsp?table=ENCChangeMyEngineeringView&program=emxPart:getFilteredChartData&selection=multiple&toolbar=ENCFullSearchToolbar&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&mode=view&hideExtendedHeader=true&header=emxEngineeringCentral.Markup.Change&subHeader="+subHeader+"&type=type_ChangeAction&state="+this.options.stateName, +this.y, "redBright"); }
								}
							}
			            }
			        },
			        //XSSOK
					series: [ { name: '<%=changeAction%>', data: statesData, colorByPoint: true}
					        ]
				});
				toggleChartInfo(divHeaderChangeCAs, divChartChangeCAs, chartChangeCAs);
				jQuery('#imgLoadingProgressDiv').remove();
			});
			});

		</script>	
<script type="text/javascript">

function createSubheader(displayQty, totalQty, strState, strAge, strSeverity){
	var sHeader = displayQty+" / "+totalQty+ " " +'<%=strAppendObjects%>';
	if(strState != null){sHeader += " | "+'<%=strAppendState%>'+": "+strState;}
	if(strAge != null){sHeader += " | "+'<%=strAppendAge%>'+": "+strAge+" "+'<%=strAppendWeeks%>';}
	if(strSeverity != null){sHeader += " | "+'<%=strAppendSeverity%>'+": "+strSeverity;}
	return sHeader;
}

/*My ENG View specific
When object count in KPI chart exceeds 5000, a confirmation message is displayed. Change objects are exception, where only alert message is displayed
*/

function openURLInDetailsBOM(url, count, color) {
	var formName = setFormName(color);
	var type = setSearchType(formName);
	var searchView = setSearchView(color);
	var maxLimit = "<%=sMaximumLimit%>";
	
	if(count>maxLimit){
		if(color != "red"){
			var retVal = confirm(VALUE_CONFIRMATION_MSG);
		
       if( retVal == false ){
        	getTopWindow().showSlideInDialog("../common/emxForm.jsp?form="+formName+"&submitAction=doNothing&formHeader=emxEngineeringCentral.EngineeringCriteria.Header&mode=edit&HelpMarker=emxhelppartbomadd&suiteKey=EngineeringCentral&initialLoad=true&postProcessURL=../engineeringcentral/emxENGSearchCriteriaPostProcess.jsp&filterResult=true&searchType="+type+"&searchView="+searchView, false);
        	return true;
        }
		}else{
			alert(VALUE_ALERT_MSG);
		}
	}
		
	if($("#left").is(':visible')) { $("#left").fadeOut("0"); }

	if($("#details").html() == "") {
		$("#details").html("<iframe id='frameDetails' name='frameDetails' style='width:" + widthDetails + "px;border:none;' src=''></iframe>");
	}
	if(!$("#details").is(':visible')) {
		var widthDetails = $(window).width() - $(middle).width() - $("#right").width() - 1;
		$("#details").width(widthDetails + "px");
		$("#details").fadeIn("100");
	}

	if($("#details").is(':visible')) {
		var frameDetails = document.getElementById("frameDetails");
		if(frameDetails != null) {
			var urlTest = 	url.replace(/\.\.\//g, "");
			urlTest = urlTest.replace(/ /g, "%20");
			if(frameDetails.src.indexOf(urlTest) == -1) {
				frameDetails.src = url;
			}
		}
	}


}

function openSearchCriteria(color){
	var form = setFormName(color);
	var type = setSearchType(form);
	var searchView = setSearchView(color);
	var dialogPage = "../engineeringcentral/emxIntrCommon.jsp?formName="+form+"&searchType="+type+"&searchView="+searchView;
	var objWindow = getTopWindow().showSlideInDialog(dialogPage, false);
	return objWindow;
}

function setFormName(color){
	var form;
	switch(color) {
    case "maroon":
    	form = "EngSpecificationFilter";
        break;
    case "blue":
    	form = "EngRefDocFilter";
        break;
    
    default:
    	form = "EngineeringDashboardFilter";
    	break;
}
	return form;
}

function setSearchView(color){
	var view;
	switch(color) {
    case "maroon":
    	view = "SpecificationView";
        break;
    case "blue":
    	view = "ReferenceDocumentView";
        break;
    
    default:
    	view = "PartView";
    	break;
}
	return view;
}

function setSearchType(form){
	var type;
	switch(form) {
    
    case "EngineeringDashboardFilter":
    	type = "Part";
        break;
    
    default:
    	type = "CAD Drawing,CAD Model,Drawing Print,Part Specification";
    	break;
}
	return type;
}

</script>
	<body>
		<div id="left"></div>			
		<div id="details"></div>			
		<div id="middle" onclick="showPanel();">
			<img  class="unhide" src="../common/images/utilPanelToggleArrow.png" />
		</div>		
		<div id="right">
			<table width="100%">	
				<tr><td>
				<!--XSSOK-->
					<div class="title link" onclick="hidePanel();"><img  class="hide" src="../common/images/utilPanelToggleArrow.png" /><%=hidePanel%></div>
					<!--XSSOK-->
					<div class="title link italic" style="float:right;" onclick="restoreLeft();"><%=restorePanel%></div>
				</td></tr>		
				<tr><td>
				<!-- XSSOK -->
				<div class="header expanded" id="divHeaderCounters" onclick="toggleChartInfo(divHeaderCounters, chartKPI, null, null);"><%=ownedItems%></div>
					<div id="chartKPI">
						<!-- <td> -->
						<div class="element" id="part">
							<div class="section_content">
							<!-- XSSOK -->
								<%=dashBoardData[0]%>
							</div>
							<div class="section_label">
								<span class="AppLabel"><%=partLabelKey%></span>
							</div>
						</div>
						<div class="element" id="specs">
							<div class="section_content">
							<!-- XSSOK -->
								<%=dashBoardData[1]%>
							</div>
							<div class="section_label">
								<span class="AppLabel"><%=specLabelKey%></span>	
							</div>
						</div>
						<div class="element" id="refDoc">
							<div class="section_content">
							<!-- XSSOK -->
								<%=dashBoardData[2]%>
							</div>
							<div class="section_label">
								<span class="AppLabel"><%=refDocLabelKey%></span>	
							</div>
						</div>
						<div class="element" id="change">
							<div class="section_content">
							<!-- XSSOK -->
								<%=dashBoardData[3]%>
							</div>
							<div class="section_label">
								<span class="AppLabel"><%=changeLabelKey%></span>	
							</div>
						</div>
					</div>
				</td></tr>
				<tr><td>
				<!-- XSSOK -->
					<div class="header collapsed" id="divHeaderParts"><%=ownedParts%></div>
					<div class="chart"	id="divChartParts"  style="width:500px; height:280px"></div>					
				</td></tr>		
				<tr><td>
				<!-- XSSOK -->
					<div class="header collapsed" id="divHeaderChangeCOs"><%=ownedChangeOrders%></div>
					<div class="chart"	id="divChartChangeCOs"  style="width:500px; height:280px"></div>					
				</td></tr>	
				<tr><td>
				<!-- XSSOK -->
					<div class="header collapsed" id="divHeaderChangeCAs"><%=ownedChangeActions%></div>
					<div class="chart"	id="divChartChangeCAs"  style="width:500px; height:280px"></div>					
				</td></tr>
			</table>
			<br/>
		</div>	
	</body>
</html>

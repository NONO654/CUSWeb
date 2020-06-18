var EnoCockPit=(function(){
	var parameters;
	var expandState=[];
	var colorGrayBright	= "#aab8be";
	init= function(){
		readRequestParameter();
		loadCockpitStyles("emxUIDefault");
		loadCockpitStyles('emxDashboardCommon');
		loadCockpitStyles('enoDashboardPanelRight');
		if(getTopWindow().isMobile){
			loadCockpitStyles("emxUIMobile","../common/mobile/styles/");
		}
		setCustomDateFormats();
		loadCockpit(getCockpitType());
		
		registerEvents();
	};
	setCustomDateFormats = function() {
		Highcharts.dateFormats = {
			//Long day format
			CLD: function (timestamp) {
				var options = {hour12 : true, hour:"numeric", minute :"numeric",  weekday: "long", year: "numeric", month: "short", day: "numeric" };
				var date = new Date(timestamp);
				return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(date);
			},
			//Medium day format
			CMD: function (timestamp) {
				var options = {weekday: "long", year: "numeric", month: "short", day: "numeric" };
				var date = new Date(timestamp);
				return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(date);
			},
			//Short day format
			CSD: function (timestamp) {
				var options = {year: "numeric", month: "short", day: "numeric" };
				var date = new Date(timestamp);
				return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(date);
			},
			//Day and month
			CDM: function(timestamp) {
			    var options = {month: "short",day: "numeric" };
				var date = new Date(timestamp);
				return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(date);
			},
			//Month and year
			CMY: function(timestamp) {
			    var options = {month: "short",year: "numeric" };
				var date = new Date(timestamp);
				return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(date);
			},
			//12hour Time
			CHM: function(timestamp) {
			    var options = {hour12 : true, hour:"numeric", minute :"numeric"};
				var date = new Date(timestamp);
				return Intl.DateTimeFormat(emxUIConstants.BROWSER_LANGUAGE,options).format(date);
			},
			//week number
			CWK: function (timestamp) {
				var date = new Date(timestamp),
					day = date.getUTCDay() === 0 ? 7 : date.getUTCDay(),
					dayNumber;
				date.setDate(date.getUTCDate() + 4 - day);
				dayNumber = Math.floor((date.getTime() - new Date(date.getUTCFullYear(), 0, 1, -6)) / 86400000);
				return 1 + Math.floor(dayNumber / 7);

			}
	    };
	};
	getCockpitType = function(){
		return parameters.type;
	};
	readRequestParameter = function(){
		if(!parameters){
			parameters = [];
			var queryString = window.location.search;
			queryString = queryString.substring(1, queryString.length);
			var arguments =   queryString.split("&");
			var params="";
			for ( var i= 0; i < arguments.length; i++) {
				var argument = arguments[i].split("=");
				params = params+ "\""+argument[0]+"\":\""+argument[1]+"\"";
				if(i<arguments.length-1){
					params=params+",";
				}
			}
			params = "{"+params +"}"; 
			parameters = JSON.parse(params);
		}
	};
	loadCockpit = function(cockpitType){
		appendToWidgetCockpit(jQuery("<td></td>").append(jQuery("<div class=\"title link hidden\"><img class=\"hide\" src=\"../common/images/utilPanelToggleArrow.png\" />"+ emxUIConstants.HIDEPANEL+"</div>").click(function(){EnoCockPit.hidePanel();})));
		jQuery.ajaxSetup({cache: false});
		var url = "./scripts/eno"+cockpitType+".js";
		var dsb = jQuery.getScript(url).done(function(){
			var obj = window[cockpitType];
			obj.init();
		}).fail(function(jqxhr, settings, exception){
			alert("error loading cockpit "+cockpitType+ ". Error: "+exception.message);
		});
	};
	loadCockpitStyles = function(css,cssPath){
		var strCSSFile="";
		if(cssPath)
			{
			 strCSSFile = cssPath + css+".css";
			}else{
				strCSSFile = DIR_STYLES + css+".css";
			}
		var link = document.createElement('link');
		link.setAttribute('rel', 'stylesheet');
	    link.setAttribute('type', 'text/css');
	    link.setAttribute('href', strCSSFile);
	    document.getElementsByTagName('head')[0].appendChild(link);
	};
	appendToWidgetCockpit = function(object){
		var cockpitTable = jQuery("table#cockpit","div#right");
		cockpitTable.append(object);
	};
	setDetailsView = function(url){
		var detailsViewTableFrame = jQuery("iframe#frameTable","div#left");
		detailsViewTableFrame.attr('src',url);
	};
	hidePanel = function() {
		//FIXME Change it, Should be handled in CSS 
		
		jQuery("#right").toggle().fadeOut('200', function() {
		jQuery("#right").width("0px");
		jQuery("#middle").width("20px");
			
		jQuery("#middle").show();
		var widthNew = jQuery(window).width() - 20 - 1;
		if(jQuery("#details").length != 0) {
			if(jQuery("#details").is(':visible')) {
				jQuery("#details").width(widthNew + "px");			
			} else {
				jQuery("#left").width(widthNew + "px");
				jQuery("#frameTable").width(widthNew + "px");			
			}
		} else {
				jQuery("#left").width(widthNew + "px");
				jQuery("#frameTable").width(widthNew + "px");
			}

		});
	};
	showPanel = function(){
		//FIXME Change it, Should be handled in CSS 
		var  chartpanelwidth = 570;
		if(getTopWindow().isMobile == true){
			chartpanelwidth = 320;
		}
		
		var widthNew = jQuery(window).width() - chartpanelwidth - 1;
		jQuery("#middle").hide();
		jQuery("#middle").width("0px");
//		if(jQuery("#details").length != 0) {	
//			if(jQuery("#details").is(':visible')) {
//				jQuery("#details").width(widthNew + "px");			
//			} else {
//				jQuery("#left").width(widthNew + "px");
//				jQuery("#frameTable").width(widthNew + "px");			
//			}
//		} else {
			jQuery("#left").width(widthNew + "px");
			jQuery("#frameTable").width(widthNew + "px");
//		}	
		
		jQuery("#right").width(chartpanelwidth + "px");
		jQuery("#right").fadeIn("0");
	};
	registerEvents = function(){
		jQuery("#middle").click(showPanel);
		attachResizeEvent();
		resizeDetailsView();
	};
	attachResizeEvent= function(){
		jQuery(window).resize(resizeDetailsView);	
		jQuery("#frameTable").load(resizeDetailsView);
	};
	resizeDetailsView = function(){
		var rightDivWidth = jQuery("#right").width();
		if(isIE && jQuery("#right").css('display') === 'none')
		{
			rightDivWidth = 0;
		}
		var widthLeft 			= jQuery(window).width() - jQuery("#middle").width() - rightDivWidth - 1;		
		jQuery("#frameTable").width(widthLeft + "px");
	};
	restoreLeft = function() {
		//FIXME WHY do we need this , try it without 
		var divLeft 		= document.getElementById("left");
		var widthLeft 		= jQuery(window).width() - 571;				
		var visibleLeft		= jQuery("#left").is(':visible');				
		if(jQuery("#details").is(':visible')) { jQuery("#details").fadeOut("0");	}			
		if(!visibleLeft) { jQuery("#left").fadeIn("100");	}			
	};
	getDetailsViewSource = function(){
		var detailsViewTableFrame = jQuery("iframe#frameTable","div#left");
		return detailsViewTableFrame.attr('src');
	};
	cleanRightView = function(){
		jQuery("table#cockpit","div#right").html("");
	};
	expandWidget = function(){
		for(var i=0;i<expandState.length;i++){
			jQuery("div#"+expandState[i]).removeClass("expanded");
			jQuery("div#"+expandState[i]).addClass("collapsed");
		}
	};
	addToExpandState = function(id,expanded){
		if(expanded == "expanded"){
			expanded = "true";
		}else
		{
			expanded="false";
		}
		expandState.push({id:id,expanded:expanded});
	};
	
	facet_dbTableTD = function(){
		return jQuery("<td></td>");
	},
	facet_dbTableTR = function(){
		return jQuery("<tr></tr>");
	},
	
	toggleChartFilter =function(e){		
		jQuery(e.target).toggleClass("expanded").toggleClass("collapsed");	
	},
	
	drawHeader = function(header){
		var td=this.facet_dbTableTD();			
		var rightHeaderDiv = jQuery("<div class=\"title link rightHeader\">"+header.headerString+"</div>").click(resetFilters);
		td.append(jQuery("<div class=\"title link \"><img class=\"hide\" src=\"../common/images/utilPanelToggleArrow.png\" />"+ emxUIConstants.HIDEPANEL+"</div>").click(function(){EnoCockPit.hidePanel();}));
		td.append(rightHeaderDiv);
		return this.facet_dbTableTR().append(td);
	},
	
	drawWidget = function(widget){
		var td=EnoCockPit.facet_dbTableTD();
		EnoCockPit.addToExpandState('divHead'+widget.name,widget.view);
		td.append(jQuery("<div class='header "+widget.view+"' id='divHead"+widget.name+"'> "+widget.label+"</div>").click(function(e){toggleChartFilter(e);}));
		if(widget.filterable){
			td.append(jQuery("<div class='chart chartBorder' id='divChart"+widget.name+"' style='height:"+widget.height+"px;'></div>"));
		}else{
			td.append(jQuery("<div class='chart chartBorder chartAutoCursor' id='divChart"+widget.name+"' style='height:"+widget.height+"px;'></div>"));
		}
		
		return EnoCockPit.facet_dbTableTR().append(td);		
	},
	
	facet_dbChart = function(widget){
		var chartType = widget.type;
		if(chartType == "scatter"){
			templateScatterChart.drawScatterChart(widget);
		}else if(chartType == "bar"){
			templateBarChart.drawBarChart(widget);
		}else if(chartType == "pie"){
			templatePieChart.drawPieChart(widget);
		}else if(chartType == "funnel"){
			templateFunnelChart.drawFunnelChart(widget);
		}else if(chartType == "column"){
			templateColumnChart.drawColumnChart(widget);
		}else if(chartType == "area"){
			templateAreaChart.drawAreaChart(widget);
		}else if(chartType == "columnrange"){
			templateColumnRangeChart.drawColumnRangeChart(widget);
		}else if(chartType == "spline"){
			templateSplineChart.drawSplineChart(widget);
		}		
	};
	
	templateScatterChart = {
			
		drawScatterChart : function(widget){			
			chart = new Highcharts.Chart({
				chart		: this.getChart(widget.type,'divChart'+widget.name),
				title		: this.getTitle(),
				credits 	: this.getChartCredits(),
				exporting	: this.getChartExporting(),	
				legend		: this.getChartLegend(widget.showLegend),	
				xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories, widget.xAxisDateValue),
				yAxis 		: this.getChartYAxis(widget.type, widget.yAxisCategories, widget.yMax),				
				tooltip		: this.getChartTooltip(),
				plotOptions : this.getChartPlotOptions(widget.tooltipObject, widget.filterable, widget.filterURL),
				series		: widget.series
			});
		},
			
		getChart : function(chartType,holder){	
			var  marginTop = 25, marginRight= 35, marginBottom = 15;			
			return {	type	: chartType,
				renderTo		: holder,				
				marginBottom	: marginBottom,
				marginRight		: marginRight,
				marginTop		: marginTop,
				zoomType		: 'x'
			};
		},
		
		getTitle : function(textVal){
			if(!textVal){textVal=null;}
			return { text		: textVal  };
		},
		
		getChartCredits : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return { enabled 	: isEnabled };
		},
		getChartExporting : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	 { enabled 	: isEnabled };
		},
		getChartLegend : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
		},
	
		getChartXAxis : function(chartType,categoriesVal, xAxisDateValue){		
			var colorAlternate = "#f5f5f5";
			var xAxis;
	
				xAxis ={alternateGridColor 	: colorAlternate,
						endOnTick			: true,
						opposite			: true,
						plotLines			: [{
							color: '#cc0000',
							width: 2,
							value: xAxisDateValue
						}],
						showLastLabel	: true,
						startOnTick		: true,
						title			: { text: null },
						minTickInterval : 24 * 3600 * 1000,
						type			: 'datetime',
						dateTimeLabelFormats: {
							day: '%CDM',
							week : '%CDM',
							month : '%CMY',
							hour : '%CHM'
						}
						}
			
			return xAxis;
		},
		
		getChartTooltip :  function(){			
			return {
					style: {			
						fontSize 	: '10px',
						padding		: 5
					}
				};
		},
	
		getChartYAxis : function(chartType,categoriesVal, yMax){
			var colorAlternate = "#f5f5f5";
			var yaxis;
			if(chartType){				
				yaxis = {	title		:	 { text: null },
							startOnTick : false,
							endOnTick 	: false,
							categories 	: categoriesVal,               
							min			: -0.5,
							max			: yMax+0.5,
							labels: {
								formatter: function () {
									var text = this.value,
									formatted = text.length > 18 ? text.substring(0, 18) + '...' : text;
									return '<div class="js-ellipse" style="width:115px;z-index:-100; overflow:hidden" title="' + text + '">' + formatted + '</div>';
								},
								style	: { width: '165px' },
								useHTML	: false
							},
							tickmarkPlacement : 'on'
						};
			}			
			return yaxis;	
		},
	
		getChartPlotOptions : function(tooltipObject, filterable, filterURL){
			return {
				scatter: {
					marker: {
						radius: 6,
						lineWidth: 2,
						symbol: 'diamond',
						states: {
							hover: {
								enabled: true,
								lineColor: colorGrayBright
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
						useHTML		: true,
						//shared	:	true,
						headerFormat: 	'<small style="color: {series.color}">{point.key:%CMD}</small><br/>',
						pointFormat :	"<b>"+tooltipObject.labelRoute+"</b>	: {point.route}<br/>" 	+
										"<b>"+tooltipObject.labelTitle+"</b> 	: {point.title}<br/>" 	+
										"<b>"+tooltipObject.labelAction+"</b>	: {point.action}<br/>" 	+
										"<b>"+tooltipObject.labelAssignee+"</b> : {point.person}<br/>" 	+
										"<b>{point.status}</b> 		    : {point.date:%CLD}<br/>"
					},
					point : 	this. registerEvents(filterURL,filterable),
				}
			}
		},
		registerEvents : function(filterURL,filterable) {
			if (Browser.MOBILE) {
				return {
					events : {
						mouseOver : function() {
							if(filterable){
								clickChart(filterURL + "&objectId=" + this.id);
						}	
					}
				}

				}
			} else {
				return {
					events : {
						click : function() {
						if(filterable){
							clickChart(filterURL + "&objectId=" + this.id);
							}
						}
					}

				}

			}
		}
	};
	
	templateBarChart = {		
	
		drawBarChart : function(widget){		
			chart = new Highcharts.Chart({
				chart		: this.getChartType(widget.type,'divChart'+widget.name),
				title		: this.getChartTitle(),
				credits 	: this.getChartCredits(),
				exporting	: this.getChartExporting(),	
				legend		: this.getChartLegend(widget.showLegend),	
				xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
				yAxis 		: this.getChartYAxis(),				
				tooltip		: this.getChartTooltip(widget.tooltipEnabled),
				plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.label),					
				series		: widget.series
			});
		},
		
		getChartType : function(chartType,holder){			
			var marginBottom=25, marginRight=20;
			return  {	type			: chartType,
				renderTo		: holder,				
				marginBottom	: marginBottom,
				marginRight		: marginRight,
				zoomType		: 'y'
			};
		},
		
		getChartTitle : function(textVal){
			if(!textVal){textVal=null;}
			return { text		: textVal  };
		},
		
		getChartCredits : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return { enabled 	: isEnabled };
		},
		getChartExporting : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	 { enabled 	: isEnabled };
		},
		getChartLegend : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
		},
		
		getChartXAxis : function(chartType,categoriesVal){						

			var xAxis;
			xAxis ={type:"category"};			
			if(categoriesVal && categoriesVal != ""){
				xAxis ={categories:categoriesVal,
						allowDecimals: false,
						labels: {
							formatter: function () {
								var text = this.value,
								formatted = text.length > 15 ? text.substring(0, 15) + '...' : text;
								return '<div class="js-ellipse" style="width:115px;z-index:-100; overflow:hidden" title="' + text + '">' + formatted + '</div>';
							},
							style	: { width: '165px' },
							useHTML	: false
					}
				};
			}		
			return xAxis;
		},
		
		getChartTooltip :  function(isEnabled){
			if(typeof isEnabled != 'undefined' && !isEnabled){
				return { enabled 	: isEnabled };
			}
			
			return {
				shared		: true,						
				crosshairs	: true
			};
		},
		
		getChartYAxis : function(){
			var colorAlternate = "#f5f5f5";
			var yaxis;
			yaxis = {	allowDecimals: false,
						alternateGridColor 	: colorAlternate,
						endOnTick 			: false,
						title: {
							text: null
						},
						stackLabels: {
							enabled: true
						}
					};
			return yaxis;
		
		},
		
		getChartPlotOptions : function(name, filterable, filterURL, headerLabel){
			return {
				bar: {
					stacking: 'normal',
					dataLabels: {
						enabled: false,
						color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
					},
					point : {
						events:{ click : function() {if(filterable){
							if(filterURL && filterURL!= ""){
							   clickChart(filterURL + "&objectId=" + this.id, this.category, name, headerLabel);
							}else{
								clickChart(this.filter, name, this.name);
							}
							}
						}
					}
					}
				},
				series: {
					groupPadding: 0.05
				}						
			};
		}
	};
	
	templateFunnelChart = {
		
		drawFunnelChart : function(widget){		
			chart = new Highcharts.Chart({
				chart		: this.getChartType(widget.type,'divChart'+widget.name),
				title		: this.getChartTitle(),
				credits 	: this.getChartCredits(),
				exporting	: this.getChartExporting(),	
				legend		: this.getChartLegend(),	
				xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
				yAxis 		: this.getChartYAxis(),				
				tooltip		: this.getChartTooltip(),
				plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.label),
				series		:  [{
								name: widget.label,
								data: widget.series
								}]
			});
		},
		
		getChartType : function(chartType,holder){			
			var marginBottom=25, marginRight=20;
			return  {	type			: chartType,
				renderTo		: holder,				
				marginBottom	: marginBottom,
				marginRight		: marginRight				
			};
		},
		
		getChartTitle : function(textVal){
			if(!textVal){textVal=null;}
			return { text		: textVal  };
		},
		
		getChartCredits : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return { enabled 	: isEnabled };
		},
		getChartExporting : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	 { enabled 	: isEnabled };
		},
		getChartLegend : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
		},
		
		getChartXAxis : function(chartType,categoriesVal){						

			var xAxis;
			if(categoriesVal && categoriesVal != ""){
				xAxis ={categories:categoriesVal,
						allowDecimals: false,
						labels: {
					}
				};
			}		
			return xAxis;
		},
		
		getChartTooltip : function(chartType){
			
			return {
				formatter: function() {
					return '<b>'+ this.point.name +'</b>: '+ this.y;
					}
				};
		},
		
		getChartYAxis : function(){
			var colorAlternate = "#f5f5f5";
			var yaxis;
			yaxis = {	allowDecimals: false,
						alternateGridColor 	: colorAlternate,
						min: 0,
						title: {
							text: null
						},
						stackLabels: {
							enabled: true
						}
					};
			return yaxis;
		
		},
		
		getChartPlotOptions : function(name, filterable, filterURL, headerLabel){
			
			return {
				funnel: {
					dataLabels: {
						enabled			: true,
						format			: '<b>{point.name}</b> ({point.y:,.0f})',
						color			: 'black',
						softConnector	: true
					},
					point : {
						events:{ click : function() { 
							if(filterable){
								clickChart(this.filter, name, this.name);
							}}}
					},
					neckWidth: '20%',
					neckHeight: '25%'
				}
			};

		}
	};
	
	templateColumnChart = {
			
			drawColumnChart : function(widget){		
				chart = new Highcharts.Chart({
					chart		: this.getChartType(widget.type,'divChart'+widget.name),
					title		: this.getChartTitle(),
					credits 	: this.getChartCredits(),
					exporting	: this.getChartExporting(),	
					legend		: this.getChartLegend(),	
					xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
					yAxis 		: this.getChartYAxis(),				
					tooltip		: this.getChartTooltip(),
					plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.label),
					tooltip: {
						shared		: true,						
						crosshairs	: true
					},		
					series		:  widget.series
				});
			},
			
			getChartType : function(chartType,holder){			
				var marginBottom=25, marginRight=20;
				return  {	type			: chartType,
					renderTo		: holder,				
					marginBottom	: marginBottom,
					marginRight		: marginRight				
				};
			},
			
			getChartTitle : function(textVal){
				if(!textVal){textVal=null;}
				return { text		: textVal  };
			},
			
			getChartCredits : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return { enabled 	: isEnabled };
			},
			getChartExporting : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	 { enabled 	: isEnabled };
			},
			getChartLegend : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
			},
			
			getChartXAxis : function(chartType,categoriesVal){						

				var xAxis;
				if(categoriesVal && categoriesVal != ""){
					xAxis ={categories:categoriesVal,
							allowDecimals: false,
							labels: {
						}
					};
				}		
				return xAxis;
			},
			
			getChartTooltip : function(chartType){
				
				return {
					formatter: function() {
						return '<b>'+ this.x +'</b><br/>'+
							this.series.name +': '+ this.y +'<br/>'+
							'Total: '+ this.point.stackTotal;
						}
					};			
			},
			
			getChartYAxis : function(){
				var colorAlternate = "#f5f5f5";
				var yaxis;
				yaxis = {	allowDecimals: false,
							alternateGridColor 	: colorAlternate,
							min: 0,
							title: {
								text: null
							},
							stackLabels: {
								enabled: true
							}
						};
				return yaxis;
			
			},
			
			getChartPlotOptions : function(name, filterable, filterURL, headerLabel){
				return {
					column: {
						stacking: 'normal',
						dataLabels: {
							enabled: true,
							color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
						}
					},
					series: {
						groupPadding: 0
					}
				};

			}
		};
	
	templatePieChart = {
		
		drawPieChart : function(widget){		
			chart = new Highcharts.Chart({
				chart		: this.getChartType(widget.type,'divChart'+widget.name),
				title		: this.getChartTitle(),
				credits 	: this.getChartCredits(),
				exporting	: this.getChartExporting(),	
				legend		: this.getChartLegend(),	
				xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
				yAxis 		: this.getChartYAxis(),				
				tooltip		: this.getChartTooltip(),
				plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.label),
				series		: widget.series
			});
		},
		
		getChartType : function(chartType,holder){			
			var marginBottom=25, marginRight=20;
			return  {	type			: chartType,
				renderTo		: holder,				
				marginBottom	: marginBottom,
				marginRight		: marginRight				
			};
		},
		
		getChartTitle : function(textVal){
			if(!textVal){textVal=null;}
			return { text		: textVal  };
		},
		
		getChartCredits : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return { enabled 	: isEnabled };
		},
		getChartExporting : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	 { enabled 	: isEnabled };
		},
		getChartLegend : function(isEnabled){
			if(!isEnabled){isEnabled=false;}
			return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
		},
		
		getChartXAxis : function(chartType,categoriesVal){						

			var xAxis;
			if(categoriesVal && categoriesVal != ""){
				xAxis ={categories:categoriesVal,
						allowDecimals: false,
						labels: {
					}
				};
			}		
			return xAxis;
		},
		
		getChartTooltip : function(chartType){
			
			return {
				formatter: function() {
					return '<b>'+ this.point.name +'</b>: '+ this.y;
					}
				};
		},
		
		getChartYAxis : function(){
			var colorAlternate = "#f5f5f5";
			var yaxis;
			yaxis = {	allowDecimals: false,
						alternateGridColor 	: colorAlternate,
						min: 0,
						title: {
							text: null
						},
						stackLabels: {
							enabled: true
						}
					};
			return yaxis;
		
		},
		
		getChartPlotOptions : function(name, filterable, filterURL, headerLabel){

			return {
				pie: {
					dataLabels: {
						enabled			: true,
						format			: '<b>{point.name}</b> ({point.y:,.0f})',
						color			: 'black',
						softConnector	: true
					},
					point : {
						events:{ click : function() { 
						if(filterable && name != "Status"){
							clickChart(filterURL, this.value, name, headerLabel);					
						} else{
							openURLInDetails("../common/emxIndentedTable.jsp?suiteKey=ProgramCentral&header="+headerLabel+" : " + this.value + "%25&program=emxProgramUI:getMyOpenTasksByPercentComplete&percent=" + this.value + "&table=PMCAssignedWBSTaskSummary&editLink=true&selection=multiple&freezePane=Status,WBSTaskName,Delivarable,NewWindow");
						}}},
					neckWidth: '20%',
					neckHeight: '25%'
				}
				}
			};
		}
	};
	
	templateAreaChart = {			
			drawAreaChart : function(widget){		
				chart = new Highcharts.Chart({
					chart		: this.getChartType(widget.type,'divChart'+widget.name),
					title		: this.getChartTitle(),
					credits 	: this.getChartCredits(),
					exporting	: this.getChartExporting(),	
					legend		: this.getChartLegend(),	
					xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
					yAxis 		: this.getChartYAxis(),				
					tooltip		: this.getChartTooltip(),
					plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.headerLabel),
					series		: widget.series
				});
			},			
			getChartType : function(chartType,holder){			
				var marginBottom=25, marginRight=20;
				return  {	type			: chartType,
					renderTo		: holder,				
					marginBottom	: marginBottom,
					marginRight		: marginRight,
					zoomType		: 'x'
				};
			},			
			getChartTitle : function(textVal){
				if(!textVal){textVal=null;}
				return { text		: textVal  };
			},			
			getChartCredits : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return { enabled 	: isEnabled };
			},
			getChartExporting : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	 { enabled 	: isEnabled };
			},
			getChartLegend : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
			},			
			getChartXAxis : function(chartType,categoriesVal){
				var xAxis;
				xAxis ={
						type	: 'datetime',
						dateTimeLabelFormats: {
							day: '%CDM',
							week : '%CDM',
							month : '%CMY',
							hour : '%CHM'
						}
					};	
				return xAxis;
			},
			
			getChartTooltip : function(){
				return{
					headerFormat: 	'<small style="color: {point.color}">{point.key:%CMD}</small><br/>',
					shared		: true,						
					crosshairs	: true
				};
			},
			
			getChartYAxis : function(){
				var colorVal = "#F1F1F1";
				var yaxis;
				yaxis = {	title				: { text: null	},
							alternateGridColor	: colorVal,
							endOnTick			: false
						};
				return yaxis;
			
			},
			
			getChartPlotOptions : function(name, filterable, filterURL, headerLabel){				
				return {
					area: {
						stacking	: 'normal',
						lineWidth	: 1,
						cursor		: 'pointer',
						point: {
							events:{
								click : function() {
									if(filterURL.indexOf('&header')>0){
										filterURL=filterURL.substring(0,filterURL.indexOf('&header'));
									}
									filterURL += "&header="+encodeURIComponent(headerLabel) + " : "+ encodeURIComponent(Highcharts.dateFormat('%e. %b %Y', new Date(this.x)));
									filterURL += "&date="+encodeURIComponent(this.x);
									clickChart(filterURL, this.value, name, headerLabel);
								}
							}
						}
					}
				};
			}
		};
	
	templateColumnRangeChart = {
			
			drawColumnRangeChart : function(widget){		
				chart = new Highcharts.Chart({
					chart		: this.getChartType(widget.type,'divChart'+widget.name),
					title		: this.getChartTitle(),
					credits 	: this.getChartCredits(),
					exporting	: this.getChartExporting(),	
					legend		: this.getChartLegend(),	
					xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
					yAxis 		: this.getChartYAxis(widget.sNow),				
					tooltip		: this.getChartTooltip(),
					plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.label),
					series		: widget.series
				});
			},
			
			getChartType : function(chartType,holder){			
				var marginBottom=25, marginRight=20;
				return  {	type			: chartType,
					renderTo		: holder,				
					marginBottom	: marginBottom,
					marginRight		: marginRight,	
					zoomType		: 'xy',
					inverted		: true
				};
			},
			
			getChartTitle : function(textVal){
				if(!textVal){textVal=null;}
				return { text		: textVal  };
			},
			
			getChartCredits : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return { enabled 	: isEnabled };
			},
			getChartExporting : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	 { enabled 	: isEnabled };
			},
			getChartLegend : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
			},
			
			getChartXAxis : function(chartType,categoriesVal){
				var xAxis;
				if(categoriesVal && categoriesVal != ""){
					xAxis ={categories: categoriesVal};
				}			
				return xAxis;
			},
			
			getChartTooltip : function(chartType){				
				return{
					formatter: function() {				
						return "<span style='font-weight:bold;color:" + this.point.color + "'>" + this.x + "</span><br/>" + this.point.desc + "<br/>" + Highcharts.dateFormat('%CSD', new Date(this.point.low)) + " - " + Highcharts.dateFormat('%CSD', new Date(this.point.high)) + "<br/>(" + this.point.owner + ")";
					},
					useHTML : true
				}
			},
			
			getChartYAxis : function(sNow){
				
				var colorAlternate = "#f5f5f5";
				var yaxis;
				yaxis = {	alternateGridColor	: '#F1F1F1',
						opposite : true,
						plotLines			: [{
							color: '#cc0000',
							width: 2,
							value: sNow // fill sdatenow
						}],
						title	: { text: null },
						type	: 'datetime',
						minTickInterval: 24 * 3600 * 1000
						};
				
				return yaxis;			
			},
			
			getChartPlotOptions : function(name, filterable, filterURL, headerLabel){
				return {
					columnrange: {
						dataLabels : { enabled: false },
						point: {
							events:{ click : function() { 
								clickChart(filterURL+"&objectId=" + this.id);
								}} 		
						}							
					},
					series: {
						groupPadding: 0.07
					}		
				};
			}
		};
		
templateSplineChart = {
			
			drawSplineChart : function(widget){		
				chart = new Highcharts.Chart({
					chart		: this.getChartType(widget.type,'divChart'+widget.name),
					title		: this.getChartTitle(),
					credits 	: this.getChartCredits(),
					exporting	: this.getChartExporting(),	
					legend		: this.getChartLegend(),	
					xAxis		: this.getChartXAxis(widget.type,widget.xAxisCategories),
					yAxis 		: this.getChartYAxis(),				
					tooltip		: this.getChartTooltip(),
					plotOptions : this.getChartPlotOptions(widget.name,widget.filterable, widget.filterURL, widget.label),
					series		: widget.series
				});
			},
			
			getChartType : function(chartType,holder){			
				var marginBottom=25, marginRight=20;
				return  {	type			: chartType,
					renderTo		: holder,				
					marginBottom	: marginBottom,
					marginRight		: marginRight,	
					zoomType		: 'xy'
				};
			},			
			getChartTitle : function(textVal){
				if(!textVal){textVal=null;}
				return { text		: textVal  };
			},			
			getChartCredits : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return { enabled 	: isEnabled };
			},
			getChartExporting : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	 { enabled 	: isEnabled };
			},
			getChartLegend : function(isEnabled){
				if(!isEnabled){isEnabled=false;}
				return	{ enabled	: isEnabled, itemStyle: { fontSize: '10px' }}
			},
			
			getChartXAxis : function(chartType,categoriesVal){
				var xAxis = {type : 'datetime'};		
				return xAxis;
			},
			
			getChartTooltip : function(chartType){				
				return{
					tooltip: {
						shared		: true,						
						crosshairs	: true
					}
				};
			},
			
			getChartYAxis : function(){				
				var colorAlternate = "#F1F1F1";
				var yaxis = {	
							alternateGridColor	: colorAlternate,
							endOnTick 			: false,
							min					: 0,
							title				: { text: null	}
							};				
				return yaxis;			
			},
			
			getChartPlotOptions : function(name, filterable, filterURL, headerLabel){
				return {
					spline: {
						stacking: 'normal',
						cursor: 'pointer',
						point: {
							events:{ click : function() { 
								openURLInDetails("../common/emxIndentedTable.jsp?suiteKey=ProgramCentral&header=" + headerLabel +" : " + Highcharts.dateFormat('%CSD', new Date(this.x)) + "&date=" + this.x + "&program=emxProgramUI:getMyOpenTasksOfDate&table=PMCAssignedWBSTaskSummary&editLink=true&selection=multiple&freezePane=Status,WBSTaskName,Delivarable,NewWindow"); }									
							}
						}
					}
				};
			}
		};
	
	return{
		init:init,
		addWidget				:	appendToWidgetCockpit,
		setDetailsView 			:	setDetailsView,
		setHeader				:	appendToWidgetCockpit,
		setTools				:	appendToWidgetCockpit,
		hidePanel				:	hidePanel,
		getDetailsView			:	getDetailsViewSource,
		restoreLeft				:	restoreLeft,
		cleanRightView			:	cleanRightView,
		facet_dbChart			:	facet_dbChart,
		drawHeader				:	drawHeader,
		drawWidget				:	drawWidget,
		addToExpandState		: 	addToExpandState,
		expandWidget			:	expandWidget,
		facet_dbTableTD			:	facet_dbTableTD,
		facet_dbTableTR			:	facet_dbTableTR,
		toggleChartFilter		:	toggleChartFilter
	};
})();
EnoCockPit.init();

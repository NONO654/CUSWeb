var RouteCockpit = (function(){
	var filters =[];
	var colorGrayBright	= "#aab8be";
	var url = "../common/emxIndentedTable.jsp?freezePane=Status,Name,NewWindow&toolbar=APPRouteSummaryToolBar" +
			"&program=emxRoute:getMyDeskActiveRoutes,emxRoute:getMyDeskInActiveRoutes,emxRoute:getAllMyDeskRoutes" +
			"&programLabel=emxComponents.Filter.Active,emxComponents.Filter.Complete,emxComponents.Filter.All&table=APPRouteSummary" +
			"&selection=multiple&header=emxComponents.String.RoutesSummary&suiteKey=Components";
	
	var routecockpitService = "../resources/bps/cockpit/routes";
	init = function(filters){
		destroy();
		drawRouteCockpit(filters);
	};
	destroy=function(){
		filters=[];
		EnoCockPit.cleanRightView();
	};
			
	drawWidget = function(widget){
		var td=EnoCockPit.facet_dbTableTD();
		EnoCockPit.addToExpandState('divHead'+widget.name,widget.view);
		td.append(jQuery("<div class='header "+widget.view+"' id='divHead"+widget.name+"'> "+widget.label+"</div>").click(function(e){EnoCockPit.toggleChartFilter(e);}));
		if(widget.filterable){
			td.append(jQuery("<div class='chart chartBorder' id='divChart"+widget.name+"' style='height:"+widget.height+"px;'></div>"));
		}else{
			td.append(jQuery("<div class='chart chartBorder chartAutoCursor' id='divChart"+widget.name+"' style='height:"+widget.height+"px;'></div>"));
		}

		if(widget.bottomLineData){				
			var divWithBottomData = jQuery("<div class='info' id='divInfoPending'></div>");
			var tableObj = jQuery("<table width='100%'></table>");
			var trObj = EnoCockPit.facet_dbTableTR();
			trObj.append(jQuery("<td width='12%'></td><td width='25%'>"+widget.bottomLineData.taskPendingOverDue+"</td>" +
								"<td width='25%'>"+widget.bottomLineData.taskPendingThisMonth+"</td>" +
								"<td width='25%'>"+widget.bottomLineData.taskPendingThisWeek+"</td><td width='12%'></td>"));
			tableObj.append(trObj);
			td.append(divWithBottomData.append(tableObj));
		}
		return EnoCockPit.facet_dbTableTR().append(td);
	};
	
	drawRouteCockpit = function(filters){
		var data = {"filterGlobal":filters};
		jQuery.getJSON(routecockpitService,data)			
		.done(function(data){	
				Highcharts.setOptions({
			        lang: {
			        	months		: data.monthDaysNamesObj.monthArray,
			        	weekdays	: data.monthDaysNamesObj.daysArray,
			        	shortMonths	: data.monthDaysNamesObj.monthShortNameArray			        				        		
			        }
				});
				EnoCockPit.setDetailsView(data.detailedURL);
				EnoCockPit.setHeader(EnoCockPit.drawHeader(data.header));
				for(var i=0;i<data.widgets.length;i++){
					EnoCockPit.addWidget(drawWidget(data.widgets[i]));
					if(data.widgets[i].series){
							EnoCockPit.facet_dbChart(data.widgets[i]);
					}
				}
		});
	};

	clickChart = function(url, value, filter, headerLabel){
		//setViewFilter(value, filter, headerLabel);
		setDetailsView(url, value, filter, headerLabel);
		$("div#divSelectTable").fadeIn("slow");
	};

	setDetailsView = function(detailsUrl, value, filter, headerLabel){
		if(!detailsUrl){
			detailsUrl=url;
		}
		var filterUrl="";
		if(filter){
			filterUrl+= "&filter"+filter+"="+value;
		}
		if(headerLabel){
			filterUrl+= "&header="+encodeURIComponent(headerLabel)+" : "+encodeURIComponent(value);
		}
		EnoCockPit.setDetailsView(detailsUrl+filterUrl);
	};
	
	hideViewOptions = function(){
		if(filters.length==0){
			jQuery("div#divSelectTable").fadeOut("slow");
		}
	};
	resetFilters = function(){
		removeAllFilters();
		EnoCockPit.restoreLeft();
		hideViewOptions();
		setDetailsView();
	};
	removeAllFilters = function(){
		filters=[];
		jQuery("div.appliedFilter").html("").removeClass("appliedFilter");
	};
	return {
		init: init
	};
})();


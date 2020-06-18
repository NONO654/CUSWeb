var HomePageCockpit = (function(){
	var filters =[];
	var colorGrayBright	= "#aab8be";
	var url = "../common/emxPortal.jsp?portal=AEFPowerView&showPageHeader=true&header=emxFramework.String.MyHome&suiteKey=Framework&HelpMarker=emxhelpnewhomepage";
	
	var homePageCockpitService = "../resources/bps/cockpit/homePage";
	init = function(filters){
		destroy();
		drawHomePageCockpit(filters);
	};
	destroy=function(){
		filters=[];
		EnoCockPit.cleanRightView();
	};
			
	drawHomePageCounters = function(widgets, labelAssignedItems){
		var trObj = EnoCockPit.facet_dbTableTR();
		var tdObj = EnoCockPit.facet_dbTableTD();
		tdObj.append(jQuery("<div class='header expanded' id='divHeaderCounters'>"+labelAssignedItems+"</div>").click(function(e){EnoCockPit.toggleChartFilter(e);}));
		var counterDiv = jQuery("<div class='chart' style='height:82px;' id='divChartCounters'></div>");
		var counterTable = jQuery("<table style='width:100%;margin-bottom:5px;'></table>");		
		var updatesDiv = jQuery("<div class='info' id='divInfoCounters'></div>");
		var updatesTable = jQuery("<table width='100%'></table>");
		
		var counterTR = EnoCockPit.facet_dbTableTR();
		var updatesTR = EnoCockPit.facet_dbTableTR();
		for(var i=0;i<widgets.length;i++){
			counterTR.append(widgets[i].counterLink);
			updatesTR.append(widgets[i].updateLink);
		}
		counterTable.append(counterTR);
		counterDiv.append(counterTable);
		tdObj.append(counterDiv);
		
		updatesTable.append(updatesTR);
		updatesDiv.append(updatesTable);
		tdObj.append(updatesDiv);
		
		trObj.append(tdObj);
		return trObj;	
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
			trObj.append(jQuery("<td width='12%'></td><td width='25%'>"+widget.bottomLineData.taskPendingThisWeek+"</td>" +
								"<td width='25%'>"+widget.bottomLineData.taskPendingThisMonth+"</td>" +
								(widget.bottomLineData.taskPendingSoon ?"<td width='25%'>"+widget.bottomLineData.taskPendingSoon+"</td>":"") +
								"<td width='25%'>"+widget.bottomLineData.taskPendingOverDue+"</td><td width='12%'></td>"));
			tableObj.append(trObj);
			td.append(divWithBottomData.append(tableObj));
		}
		if(widget.bottomLineDataDocument){				
			var divWithBottomData = jQuery("<div class='info' id='divInfoPending'></div>");
			var tableObj = jQuery("<table width='100%'></table>");
			var trObj = EnoCockPit.facet_dbTableTR();
			trObj.append(jQuery("<td width='25%'>"+widget.bottomLineDataDocument.newThisWeek+"</td>" +
								"<td width='25%'>"+widget.bottomLineDataDocument.newThisMonth+"</td>" +
								"<td width='25%'>"+widget.bottomLineDataDocument.modThisWeek+"</td>" +
								"<td width='25%'>"+widget.bottomLineDataDocument.modThisMonth+"</td>"));
			tableObj.append(trObj);
			td.append(divWithBottomData.append(tableObj));
		}
		return EnoCockPit.facet_dbTableTR().append(td);
	};
	
	drawHomePageCockpit = function(filters){
		var data = {"filterGlobal":filters};
		EnoCockPit.setDetailsView(url);
		jQuery.ajaxSetup({ cache: false });
		jQuery.getJSON(homePageCockpitService,data)			
		.done(function(data){	
				Highcharts.setOptions({
			        lang: {
			        	months		: data.monthDaysNamesObj.monthArray,
			        	weekdays	: data.monthDaysNamesObj.daysArray,
			        	shortMonths	: data.monthDaysNamesObj.monthShortNameArray			        				        		
			        }
				});				
				EnoCockPit.setHeader(EnoCockPit.drawHeader(data.header));
				EnoCockPit.addWidget(drawHomePageCounters(data.widgets, data.labelAssignedItems));
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
		/*if(filter){
			filterUrl+= "&filter"+filter+"="+value;
		}
		if(headerLabel){
			filterUrl+= "&header="+headerLabel+" : "+value;
		}*/
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
	openURLInDetails = function (url) {
		EnoCockPit.setDetailsView(url);

	};
	return {
		init: init
	};
})();


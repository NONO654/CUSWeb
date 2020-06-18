var IssueCockpit = (function(){
	var filters =[];
	var expandState=[];
	var url = "../common/emxIndentedTable.jsp?massPromoteDemote=true&relationships=&filterGlobal=All&toolbar=IssueToolBar&selection=multiple&table=IssueList&freezePane=Name,Edit,NewWindow&program=emxCommonIssue:getIssuescockpitItems&header=emxFramework.String.IssuesSummary&suiteKey=Framework";
	var issuecockpitService = "../resources/bps/cockpit/issues";
	init = function(filters){
		destroy();
		drawIssueCockpit(filters);
	};
	destroy=function(){
		filters=[];
		EnoCockPit.cleanRightView();
	};
	templateDB = {
		//this is specific to issue 
		facet_dbFilter:function(filters){
			var td=EnoCockPit.facet_dbTableTD();
			var filterDiv1 = jQuery("<div class=\"title rightHeader\" >"+filters[1].filterLabel+": </div>");
			var selectDiv1 = jQuery("<select id='selectTable'></select").change(selectGlobalView);
			for(i=0;i<filters[1].filterValues.length;i++){
				var text = filters[1].filterValues[i];
				var value = filters[1].filterActual[i];
				if(filters[1].selected && filters[1].filterActual[i]==filters[1].selected){
					selectDiv1.append(jQuery("<option value='"+value+"'selected>"+text+"</option>"));
				}else{
					selectDiv1.append(jQuery("<option value='"+value+"'>"+text+"</option>"));
				}
			}
			filterDiv1.append(selectDiv1);
			
			var filterDiv2 = jQuery("<div  style=\"float:right;display:none;\" id='divSelectTable' class=\"title\">"+filters[0].filterLabel+": </div>");
			var selectDiv2 = jQuery("<select></select>").change(getTableView);
			
			for(i=0;i<filters[0].filterValues.length;i++){
				var text = filters[0].filterValues[i];
				var value = filters[0].filterActual[i];
				selectDiv2.append(jQuery("<option value='"+value+"'>"+text+"</option>"));
			}
			filterDiv2.append(selectDiv2);
			
			td.append(filterDiv1);
			td.append(filterDiv2);
			
			return EnoCockPit.facet_dbTableTR().append(td);
						}
					};
	drawWidget = function(widget){
		var td=EnoCockPit.facet_dbTableTD();
		EnoCockPit.addToExpandState('divHead'+widget.name,widget.view);
		td.append(jQuery("<div class='header "+widget.view+"' id='divHead"+widget.name+"'> "+widget.label+"</div>").click(function(e){toggleChartFilter(e);}));
		td.append(jQuery("<div class='filter' id='divFilter"+widget.name+"' ></div>"));
		if(widget.filterable){
			td.append(jQuery("<div class='chart chartBorder' id='divChart"+widget.name+"' ></div>"));
			}else {
			td.append(jQuery("<div class='chart chartBorder chartAutoCursor' id='divChart"+widget.name+"' ></div>"));
				}						
		return EnoCockPit.facet_dbTableTR().append(td);		
			};
			
	drawIssueCockpit = function(filters){
		if (isIE) {
		$.ajaxSetup({ cache: false });
		}
		var data = {"filterGlobal":filters};
		jQuery.getJSON(issuecockpitService,data)
			.done(function(data){
				//FIXME change the name to set , header , just addWidget
				EnoCockPit.setDetailsView(data.detailedURL);
				EnoCockPit.setHeader(EnoCockPit.drawHeader(data.header));
				EnoCockPit.setTools(templateDB.facet_dbFilter(data.filters));
				for(var i=0;i<data.widgets.length;i++){
					EnoCockPit.addWidget(drawWidget(data.widgets[i]));
					if(data.widgets[i].series){
						EnoCockPit.facet_dbChart(data.widgets[i]);
						//templateDB.facet_dbDrawChart(data.widgets[i]);
					}
				}
		});
		if (isIE) {
		$.ajaxSetup({ cache: false });
		}
	};
	clickChart = function(value, filter, label){
		setViewFilter(value, filter, label);
		setDetailsView();
		$("div#divSelectTable").fadeIn("slow");
	};
	setViewFilter = function(value, filter, label){
		var divFilter = jQuery("div#divFilter"+filter);
		divFilter.html("");
		divFilter.append(jQuery("<span></span>").addClass("appliedFilter")).addClass("appliedFilter");
		divFilter.append(emxUIConstants.SELECTED+" : "+label);
		divFilter.click(function(e){
			removeFilter(filter);
			jQuery(e.target).html("").removeClass("appliedFilter");
		});
		addToFilters(value, filter, label);
	};
	removeFilter = function(filterName){
		EnoCockPit.restoreLeft();
		removeFromFilters(filterName);
		hideViewOptions();
		setDetailsView();
	};
	setDetailsView = function(detailsUrl){
		if(!detailsUrl){
			detailsUrl=url;
		}
		var filterUrl="";
		var subHeader="&subHeader=";
		for(var i=0;i<filters.length;i++){
			filterUrl+= "&filter"+encodeURIComponent(filters[i].filter)+"="+encodeURIComponent(filters[i].value[0]);
			subHeader+= encodeURIComponent(filters[i].filter) +" = "+encodeURIComponent(filters[i].value[1]);
			if(i != filters.length-1){
				subHeader+=" | ";
			}
		}
		var viewType = jQuery("#divSelectTable").find("select").val(); 
		if(typeof viewType!='undefined' && viewType==="Details" && detailsUrl.indexOf("IssueListDetails")<0){
			detailsUrl=detailsUrl.replace("IssueList","IssueListDetails");
		}
		EnoCockPit.setDetailsView(detailsUrl+filterUrl+subHeader);
	};
	
	addToFilters = function(value, filter, label){
		for(var i=0;i<filters.length;i++){
			if(filters[i].filter==filter){
				filters[i]= {filter:filter,value:[value,label]};
				return;
			}
		}
		filters.push({filter:filter,value:[value,label]});
	};
	removeFromFilters = function(filter){
		for(var i=0;i<filters.length;i++){
			if(filters[i].filter==filter){
				filters.splice(i, 1);
				break;
			}
		}
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
	selectGlobalView = function(){
		var selectedTableView = this.options[this.selectedIndex].value;
		init(selectedTableView,"filterGlobal","");
	};
	getTableView = function(){
		var selectedView = this.options[this.selectedIndex].value;
		var url = EnoCockPit.getDetailsView();
		var tableNameWithparam="";
		if(url.indexOf("&table=") != -1) 
		{ 
			var strTillTable =  url.substring(0, url.indexOf("&table=")); 
			var fromTableToEnd = url.substring(url.indexOf("&table=")+1,url.length-1);
			tableNameWithparam = fromTableToEnd.substring(fromTableToEnd.indexOf("&table="),fromTableToEnd.indexOf("&"));
		}	
		if(!selectedView){
			selectedView="";
		}
		url =url.replace(tableNameWithparam,"table=IssueList" + selectedView);
		setDetailsView(url);
	};
	return {
		init: init
	};
})();

